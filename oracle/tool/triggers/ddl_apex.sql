--------------------------------------------------------
--  DDL for Trigger DDL_APEX
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "DDL_APEX" after
     insert or
     update or
     delete on apex_050000.wwv_flow_builder_audit_trail referencing new as new old as old
        for each row declare v_os_user varchar2(100) ;
    v_ax_tab_name                      varchar2(100) ;
    v_comp_type                        varchar2(100) ;
    v_object_name                      varchar2(100) ;
    v_apex_user                        varchar2(100) ;
    v_monitor                          number;
    v_script clob;
    v_id          number;
    v_sql         varchar2(2000) ;
    v_flow_tab_pk number;
    begin
         select count(1)
           into v_monitor
           from apex_app_monitor x
          where 1              = 1
            and x.app_id       = :new.flow_id
            and x.workspace_id = :new.security_group_id;
         select max(apex_table_name)
          , max(comp_type)
           into v_ax_tab_name
          , v_comp_type
           from apex_comp_maping
          where apex_table_name = :new.flow_table;
        if v_monitor            > 0 and v_ax_tab_name is not null then
            v_id               := seq_id.nextval;
            v_flow_tab_pk      := :new.flow_table_pk;
             select max(os_user)
              , max(apex_user)
               into v_os_user
              , v_apex_user
               from os_users_mapping
              where upper(apex_user) = upper(:new.flow_user) ;
            if :new.audit_action     = 'I' then
                 insert into ddl_log
                  (
                        id
                      , operation
                      , obj_owner
                      , object_name
                      , attempt_by
                      , attempt_dt
                      , sql_text
                      , os_user
                      , is_exported
                      , apex_app_id
                      , apex_page_id
                      , apex_comp_id
                      , apex_workspace_id
                      , apex_component_type
                    )
                 select v_id
                 
                  , 'CREATE'
                  , 'APEX'
                  , :new.object_name
                  , v_apex_user
                  , :new.audit_date -- important
                  , v_script
                  , v_os_user
                  , 'N'
                  , :new.flow_id
                  , :new.page_id
                  , v_flow_tab_pk
                  , :new.security_group_id
                  , v_comp_type
                   from dual;
            elsif :new.audit_action = 'U' then
                 insert
                   into ddl_log
                    (
                        id
                      , operation
                      , obj_owner
                      , object_name
                      , attempt_by
                      , attempt_dt
                      , sql_text
                      , os_user
                      , is_exported
                      , apex_app_id
                      , apex_page_id
                      , apex_comp_id
                      , apex_workspace_id
                      , apex_component_type
                    )
                 select v_id
                  , 'UPDATE'
                  , 'APEX'
                  , :new.object_name
                  , v_apex_user
                  , :new.audit_date -- important
                  , v_script
                  , v_os_user
                  , 'N'
                  , :new.flow_id
                  , :new.page_id
                  , v_flow_tab_pk
                  , :new.security_group_id
                  , v_comp_type
                   from dual;
                /** DELETE **/
                /*else
                select 'UPDATE'
                , 'APEX'
                , 'f'|| :new.flow_id||'_page_'|| :new.id
                , 'APEX'
                , sysdate
                , null
                , -- ddl for delete apex page TODO
                v_os_user
                , 'N'
                from dual;*/
            end if;
        end if;
    exception
    when others then
        p_log(sqlerrm) ;
        p_log(dbms_utility.format_error_backtrace) ;
    end;
/
ALTER TRIGGER "DDL_APEX" ENABLE;
