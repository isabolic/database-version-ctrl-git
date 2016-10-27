--------------------------------------------------------
--  DDL for Package Body P$DB_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "P$DB_OBJECT" as

  procedure export(p_ddl_id ddl_log.id%type)     
  is
   v_clob         ddl_log.sql_text%type;
   v_row_ddl_log  ddl_log%rowtype;
   v_exist        number;
   pragma autonomous_transaction;
  begin
  
    select *
      into v_row_ddl_log
      from ddl_log
     where 1=1
       and id = p_ddl_id;
    
     if v_row_ddl_log.obj_owner = 'APEX' then
        raise_application_error (-20343, 'The ddl_log row is obj_owner apex');
     end if;
     
     select max(1)
       into v_exist 
       from sys.all_objects 
      where 1=1 
        and object_name = v_row_ddl_log.object_name 
        and owner = v_row_ddl_log.obj_owner; 
    
     if v_exist is not null then
         
         if v_row_ddl_log.db_object_type = 'PACKAGE' then  
            v_row_ddl_log.db_object_type := 'PACKAGE_SPEC';
         end if;
        
         v_clob := dbms_metadata.get_ddl
                     (translate(v_row_ddl_log.db_object_type, ' ', '_'),  -- package body => package_body
                      v_row_ddl_log.object_name, 
                      v_row_ddl_log.obj_owner);
        
        update ddl_log
           set sql_text = v_clob
         where id = p_ddl_id;
         commit;
    else
       p_log('OBJECT "'|| v_row_ddl_log.obj_owner || '.' || v_row_ddl_log.object_name || ' doesn''t exist.' );
    end if;
    
  end export;
  
  -- TODO move to pck_utl
  -- exists also as private p$apx_utl
  function null_in_str(p_val varchar2) return varchar2 is
    v_ret varchar2(200) := p_val;
  begin
       if v_ret is null then
          v_ret := 'null';
       end if;
       return v_ret;
  end null_in_str;
  
  --
  --
  procedure export_via_job(p_ddl_id ddl_log.id%type)  is  
    v_job_exe varchar2(32000) :=
                 'DECLARE
                  BEGIN
                    p$utl_context.set_user(p_user => ''#USER#''  );
                    p$db_object.export(p_ddl_id   => #DDL_LOG_ID#);                  
                   exception
                   when others then
                     null;
                     p_log(''p$db_object.export_via_job '' || sqlerrm);
                  END;';
       v_job_name varchar2(200);
     begin
        
        v_job_exe := replace(v_job_exe, '#DDL_LOG_ID#'  , null_in_str(p_ddl_id));
        v_job_exe := replace(v_job_exe, '#USER#'        , p$utl_context.get_user);
        
        v_job_name := 'DB_EXPORT_' || p_ddl_id;
        
        p_log(v_job_exe);
        
        dbms_scheduler.create_job (
           job_name                 =>  v_job_name,
           job_type                 =>  'PLSQL_BLOCK',
           job_action               =>  v_job_exe,
           enabled                  =>  true,
           auto_drop                =>  true
        );
  end export_via_job;

  procedure export_db_object_to_ddl_log (p_ddl_id ddl_log.id%type) as
    v_row_ddl_log  ddl_log%rowtype;
  begin
    select *
      into v_row_ddl_log
      from ddl_log
     where 1=1
       and id = p_ddl_id;
    
     if v_row_ddl_log.obj_owner = 'APEX' then
        raise_application_error (-20343, 'The ddl_log row is obj_owner apex');
     end if;
     
     export(p_ddl_id) ;
     
  end export_db_object_to_ddl_log;

  procedure generate_db_object_script as
  begin
     for i in (select id 
                from v_user_ddl_log 
               where sql_text is null 
                 and obj_owner != 'APEX' ) 
    loop
       p$db_object.export_db_object_to_ddl_log(i.id);
    end loop;
  end generate_db_object_script;
  
  function is_object_valid( p_object_name varchar2
                           ,p_owner       varchar2
                           ,p_object_type varchar2) return boolean is
  is_valid number; 
  begin
  
   select  decode(max(x.status), 'VALID', 1, 0)
       into is_valid 
       from sys.all_objects x
      where 1=1 
        and upper(x.object_name) = upper(p_object_name)
        and upper(x.owner)       = upper(p_owner)
        and upper(x.object_type) = upper(p_object_type); 
        
     if is_valid = 1 then
       return true;
     else
       return false;
     end if;
  end is_object_valid;
  
  function is_object_valid_txt ( p_object_name varchar2
                                ,p_owner       varchar2
                                ,p_object_type varchar2) return varchar2 is 
   begin                             
   if is_object_valid(p_object_name, p_owner, p_object_type) = true then
      return 'Y';
   else
      return 'N';
   end if;
   end is_object_valid_txt;
   
end p$db_object;

/
