--------------------------------------------------------
--  DDL for Package Body P$APX_UTL
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "P$APX_UTL" 
as
    procedure init_http_buffer_for_clob
    is
        l_name_list sys.owa.vc_arr;
        l_value_list sys.owa.vc_arr;
    begin
        l_name_list(1)  := 'REQUEST_CHARSET';
        l_value_list(1) := 'AL32UTF8';
        l_name_list(2)  := 'REQUEST_IANA_CHARSET';
        l_value_list(2) := 'UTF-8';
        sys.owa.init_cgi_env(2, l_name_list, l_value_list) ;
        sys.htp.init() ;
        sys.htp.htbuf_len := 84;
    end init_http_buffer_for_clob;
    
    function get_gen_api_clob return clob
    is
        v_clob clob;
    begin
        
        apex_050000.wwv_flow_gen_api2.g_writer.flush;
        v_clob := treat( 
                     apex_050000.wwv_flow_gen_api2.g_writer as apex_050000.wwv_flow_t_clob_writer
                  ).l_clob;
        apex_050000.wwv_flow_gen_api2.g_writer := apex_050000.wwv_flow_t_htp_writer() ;
        
        return v_clob;
    end get_gen_api_clob;
    
    procedure init_gen_api_clob
      is
    begin
    
    init_http_buffer_for_clob;
    
    apex_050000.wwv_flow_gen_api2
               .g_writer := apex_050000.wwv_flow_t_clob_writer (
                                 p_cache => true,
                                 p_dur   => SYS.DBMS_LOB.session 
                                );        
    end init_gen_api_clob;

    procedure export(            
            p_app_id       number,
            p_page_id      number   default null,
            p_comp_id      number   default null,
            p_component    varchar2 default null,
            p_workspace_id number   default null,
            p_ddl_id       number   default null,
            p_theme_id     number   default null
            )
    as
       v_workspace_id number := p_workspace_id;
       v_admin_ws_id  number;
       v_script       clob;
    begin
    
        if v_workspace_id is null then
          select workspace_id 
            into v_workspace_id
            from apex_app_monitor
           where 1=1
             and app_id = p_app_id;
        end if;
        
        apex_050000.wwv_flow.g_flow_id := p_app_id;
        apex_050000.wwv_flow_security.g_security_group_id := v_workspace_id;

        init_gen_api_clob;

        if p_theme_id is null then

            apex_050000.wwv_flow_gen_api2
                       .export(  p_flow_id                  => p_app_id
                               , p_export_ir_public_reports => 'Y'
                               , p_component_id             => p_comp_id
                               , p_page_id                  => p_page_id
                               , p_component                => p_component
                               ) ;
       else
          
            apex_050000.wwv_flow_gen_api2
                       .export_theme(  
                                 p_flow_id                  => p_app_id
                               , p_theme_id                 => p_theme_id
                               ) ;         
                           
        end if;                   
        
        apex_050000.wwv_flow_gen_api2
                   .file_close( p_commit              => true
                               ,p_is_component_export => true );
        
        v_script := get_gen_api_clob;
        
        if p_ddl_id is not null then
            update ddl_log
               set sql_text =  v_script
             where id = p_ddl_id;  
        end if;
        
    end export;
    
    function null_in_str(p_val varchar2) return varchar2 is
      v_ret varchar2(200) := p_val;
    begin
       if v_ret is null then
          v_ret := 'null';
       end if;
       return v_ret;
    end null_in_str;
    
    procedure export_via_job (
        p_app_id       number,
        p_page_id      number   default null,
        p_comp_id      number   default null,
        p_component    varchar2 default null,        
        p_workspace_id number   default null,
        p_ddl_id       number   default null,
        p_theme_id     number   default null
    ) is 
      v_job_exe varchar2(32000) :=
                 'DECLARE
                  BEGIN
                    p$utl_context.set_user(p_user => ''#USER#'');
                    p$apx_utl.export(
                              p_app_id       => #APP_ID#,
                              p_page_id      => #PAGE_ID#,
                              p_comp_id      => #COMP_ID#, 
                              p_component    => ''#COMPONENT#'',
                              p_workspace_id => #WORKSPACE_ID#,
                              p_ddl_id       => #DDL_LOG_ID#,
                              p_theme_id     => #THEME_ID#);
                   
                   exception
                   when others then                     
                     p_log(''p$apx_utl.export_via_job '' || sqlerrm);
                  END;';
       v_job_name varchar2(200);
     begin
        
        v_job_exe := replace(v_job_exe, '#APP_ID#'      , p_app_id);
        v_job_exe := replace(v_job_exe, '#PAGE_ID#'     , null_in_str(p_page_id));
        v_job_exe := replace(v_job_exe, '#COMP_ID#'     , null_in_str(p_comp_id));
        v_job_exe := replace(v_job_exe, '#COMPONENT#'   , null_in_str(p_component));
        v_job_exe := replace(v_job_exe, '#WORKSPACE_ID#', null_in_str(p_workspace_id));
        v_job_exe := replace(v_job_exe, '#DDL_LOG_ID#'  , null_in_str(p_ddl_id));
        v_job_exe := replace(v_job_exe, '#USER#'        , p$utl_context.get_user);
        v_job_exe := replace(v_job_exe, '#THEME_ID#'    , null_in_str(p_theme_id));
        
        v_job_name := 'APEX_EXPORT_' || p_app_id || '_' || p_ddl_id;
        
        dbms_scheduler.create_job (
           job_name                 =>  v_job_name,
           job_type                 =>  'PLSQL_BLOCK',
           job_action               =>  v_job_exe,
           enabled                  =>  true,
           auto_drop                =>  true
        );
   end export_via_job;
   
   function get_apx_static_file(p_comp_id number, p_table_name varchar2) return blob 
    is
    v_sql       varchar2(2000);
    v_file      blob;
    begin
     
    v_sql := ' select file_content' ||
             '   from apex_050000.' || p_table_name ||
             ' where   1=1 ' ||
             '   and id = '''|| p_comp_id || '''';
    
    p_log('get_apx_tab_pk = ' || v_sql);
    
    execute immediate v_sql into v_file;  
    
    return v_file;
    
    exception 
       when others then
         p_log(sqlerrm);
         return null;        
    end get_apx_static_file;
   
    function get_apx_tab_pk(
            p_table_name   varchar2,
            p_object_name  varchar2,
            p_date_time    date,
            p_app_id       number,
            p_workspace_id number,
            p_action       varchar2 default 'I')
        return number
    is
    v_id        number;
    v_sql       varchar2(2000);
    v_col_name  varchar2(200);
    v_date_time varchar2(50) := to_char(p_date_time, 'DD.MM.YYYY HH24:MI:SS');
    begin
    
     select max(apex_col_name)
           into v_col_name
           from apex_comp_maping
          where apex_table_name = p_table_name;    
   
    v_sql := ' select id          ' ||
             '   from apex_050000.' || p_table_name ||
             ' where  1=1 ' ||
             '   and '      || v_col_name || ' = '''|| p_object_name || '''';
    
    if p_action = 'I' then
       v_sql := v_sql || '   and created_on  = to_date(''' || v_date_time || ''', ''DD.MM.YYYY HH24:MI:SS'')';
    elsif p_action = 'U' then 
       v_sql := v_sql || '  and last_updated_on  = to_date(''' || v_date_time || ''', ''DD.MM.YYYY HH24:MI:SS'')';
    end if;
    
    p_log('get_apx_tab_pk = ' || v_sql);
    
    execute immediate v_sql into v_id;
    
    return v_id;
    exception 
       when others then
         p_log(sqlerrm);
         return null;
    end get_apx_tab_pk;
    
    procedure export_apex_comp_to_ddl_log (
        p_ddl_id      ddl_log.id%type
    ) is
      v_ddl_row       ddl_log%rowtype;
      v_apex_table    apex_comp_maping.apex_table_name%type;
      v_operation     varchar2(1);
      v_theme_id      number;
      v_blb           blob;
      v_file          clob;
      v_warning       integer;
      v_file_size     integer := dbms_lob.lobmaxsize;
      v_dest_offset   integer := 1;
      v_src_offset    integer := 1;
      v_blob_csid     number := dbms_lob.default_csid;
      v_lang_context  number := dbms_lob.default_lang_ctx;
      pragma autonomous_transaction; 
    begin
    
       select * 
         into v_ddl_row
         from ddl_log
        where 1=1
          and id = p_ddl_id;
        
       if v_ddl_row.obj_owner != 'APEX' then
          Raise_Application_Error (-20343, 'The ddl_log row is not obj_owner apex');
       end if;
       
       select apex_table_name
         into v_apex_table
         from apex_comp_maping
        where comp_type = v_ddl_row.apex_component_type;
        
       if     v_ddl_row.apex_page_id is null 
          and v_ddl_row.apex_comp_id is null then
          

           
          case 
            when v_ddl_row.operation = 'CREATE' then
             v_operation := 'I';            
           when v_ddl_row.operation = 'UPDATE' then
             v_operation := 'U';
           when v_ddl_row.operation = 'DELETE' then
             v_operation := 'D';
          end case;
           
          
           v_ddl_row.apex_comp_id := get_apx_tab_pk(
            p_table_name   => v_apex_table,
            p_object_name  => v_ddl_row.object_name,
            p_date_time    => v_ddl_row.attempt_dt,
            p_app_id       => v_ddl_row.apex_app_id,
            p_workspace_id => v_ddl_row.apex_workspace_id,
            p_action       => v_operation);
            
            update ddl_log
               set apex_comp_id = v_ddl_row.apex_comp_id
             where id = v_ddl_row.id; 
             
             p_log (' export_apex_comp_to_ddl_log apex_comp_id = ' || v_ddl_row.apex_comp_id);
       end if;
       
       if v_ddl_row.apex_component_type like '%STATIC%FILE%' then
            v_blb  := get_apx_static_file(v_ddl_row.apex_comp_id, v_apex_table); 
            dbms_lob.createtemporary(v_file, true);
            
            dbms_lob.converttoclob(
                    v_file,
                    v_blb,
                    v_file_size,
                    v_dest_offset,
                    v_src_offset,
                    v_blob_csid,
                    v_lang_context,
                    v_warning);
            
            update ddl_log
               set sql_text = v_file
             where id = v_ddl_row.id;
       end if;
             
       commit;
       
       if v_ddl_row.apex_component_type not like '%STATIC%FILE%' then
           if v_ddl_row.apex_component_type = 'THEME' then
              select max(theme_id)
                into v_theme_id
                from apex_050000.WWV_FLOW_THEMES
               where id = v_ddl_row.apex_comp_id;
           end if;
          
           export_via_job (
                p_app_id        => v_ddl_row.apex_app_id,
                p_page_id       => v_ddl_row.apex_page_id,
                p_comp_id       => v_ddl_row.apex_comp_id,
                p_component     => v_ddl_row.apex_component_type,
                p_workspace_id  => v_ddl_row.apex_workspace_id,
                p_ddl_id        => v_ddl_row.id,
                p_theme_id      => v_theme_id
           );
       end if;
      
      
    end export_apex_comp_to_ddl_log;
    
    
    
    procedure generate_apex_comp_script is
    begin
    for i in (select id 
                from v_user_ddl_log 
               where sql_text is null 
                 and obj_owner = 'APEX' ) 
    loop
       p$apx_utl.export_apex_comp_to_ddl_log(i.id);
    end loop;
    end generate_apex_comp_script;

    
end p$apx_utl;

/
