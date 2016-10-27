--------------------------------------------------------
--  DDL for Package Body P$VER_CTRL
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "P$VER_CTRL" as

  function get_path(  p_ddl_id ddl_log.id%type
                    , withFile varchar2 default 'Y') return varchar2 as
    v_is_apex     boolean := false;
    v_object_type ddl_log.db_object_type%type;
    v_path        varchar2(2000);
    v_r_ddl_log   ddl_log%rowtype;
    v_file_name   varchar2(500);
    v_root        config.value%type;
  begin
  
    select *
      into v_r_ddl_log
      from ddl_log x
     where id = p_ddl_id;
     
     v_file_name := f_get_file_name(p_ddl_id);
   
    if  v_r_ddl_log.apex_app_id is not null then
         v_is_apex     := true;
         v_object_type := v_r_ddl_log.apex_component_type;
    else
         v_object_type := v_r_ddl_log.db_object_type;
    end if;

    if v_is_apex = true then       
         select max(path)
           into v_path 
           from apex_comp_maping acmg
           join version_control_structure vcse on (acmg.id = vcse.acmg_id)
          where acmg.comp_type = v_object_type;
    else
       select path
         into v_path
         from (
           select path
             from version_control_structure
            where code = v_object_type
              and v_r_ddl_log.operation != 'DROP'
            union all
           select path
             from version_control_structure
            where code = 'SCRIPT'
              and not exists(select 1 
                               from version_control_structure
                              where code = v_object_type
                                and v_r_ddl_log.operation != 'DROP')
        );
    end if;
    
    select value
      into v_root
      from config
     where code = 'VER_CON_ROOT_FOLDER';
     
    if   instr(v_root, '/', -1)  
       < length(v_root) then
       v_root := v_root || '/'; -- add backspash
    end if;    
    
    if withFile = 'Y' then
        if   instr(v_path, '/', -1)  
           < length(v_path) then
           v_path := v_path || '/' || v_file_name; -- add backspash
        else
           v_path := v_path || v_file_name;
        end if;
    end if;
    
    v_path := replace(v_root || v_path, '//', '/');
    
    v_path := replace(v_path, '#APEX#'   , 'apex');
    v_path := replace(v_path, '#APP_ID#' , v_r_ddl_log.apex_app_id);
    v_path := replace(v_path, '#SCHEMA#' , lower(v_r_ddl_log.obj_owner));
    v_path := replace(v_path, '#NAME#'   , lower(v_r_ddl_log.object_name));
    
    return v_path;
  end get_path;
  
  procedure upd_export_status_all(p_rev_hash varchar2 default null) is
    pragma autonomous_transaction;
    begin
      update ddl_log
         set is_exported = 'Y',
             revision_hash = p_rev_hash
       where id in (select id from v_user_ddl_log);
       commit;
  end upd_export_status_all;
  
  procedure upd_export_status(p_ddl_id ddl_log.id%type, p_rev_hash varchar2 default null) is
    begin
      update ddl_log
         set is_exported = 'Y',
             revision_hash = p_rev_hash
       where id = p_ddl_id;
    end upd_export_status;
    
    function f_get_file_name (
        p_ddl_id      ddl_log.id%type
    ) return varchar2 
    is
        v_ddl_row      ddl_log%rowtype;
        v_name         varchar2(200);
        v_vcse_id      version_control_structure.id%type;
        v_file_ext     version_control_structure.file_ext%type := g_script_file_type;
    begin
     
     select * 
         into v_ddl_row
         from ddl_log
        where 1=1
          and id = p_ddl_id;
    
    -- apex      
    if v_ddl_row.obj_owner = 'APEX' then
       -- sh. comp.
       if     v_ddl_row.apex_page_id is null
          and v_ddl_row.apex_component_type not like '%STATIC%FILE%'  then
          v_name := lower(
                      translate
                      (
                        (
                          'f' || v_ddl_row.apex_app_id || '_' || 
                           v_ddl_row.apex_component_type  || '_' || 
                           v_ddl_row.object_name || '.' || 
                           v_file_ext
                        ),
                        ' /,', '_'
                      )
                    );
                    
       -- static files
       elsif v_ddl_row.apex_component_type like '%STATIC%FILE%'  then
            v_name :=  v_ddl_row.object_name;
       -- page   
       else
          v_name := lower(
                      translate
                      (
                        ( 
                          'f' || v_ddl_row.apex_app_id || '_page_' || 
                           v_ddl_row.apex_page_id || '.' || v_file_ext
                         )
                        , ' /,', '_'
                      )
                    );
       end if;
    else
    
       -- ddl objects
       select max(id), max(file_ext)
         into v_vcse_id, v_file_ext
         from version_control_structure 
        where 1=1
          and code = v_ddl_row.db_object_type;
          
      if    v_file_ext is null 
         or v_ddl_row.operation = 'DROP' then
         v_file_ext := g_script_file_type;
         -- reset to null for drop objects go into scripts file
         if v_ddl_row.operation = 'DROP' then
            v_vcse_id := null;
         end if;
      end if;

      if v_vcse_id is not null then
          v_name := lower(v_ddl_row.object_name || '.' || v_file_ext );
      else
          v_name := lower(
                      translate
                      ( 
                        (
                          v_ddl_row.id          || '_' || 
                          v_ddl_row.operation   || '_' || 
                          v_ddl_row.object_name || '.' || v_file_ext
                        )
                         ,' /,', '_' 
                      )                      
                   );                      
      end if;
    end if;

    return v_name;
    end f_get_file_name;
    
    function are_job_exports_done return number is
    v_is_running number;
    begin
      select decode(max(id), null, 1, 0)
        into v_is_running
        from v_user_ddl_log
       where 1=1
         and sql_text is null;
    
        return v_is_running;
    end are_job_exports_done;
    
    function f_get_config_value(p_code varchar2) return varchar2
    is
        v_ret varchar2(2000);
    begin
        select value
          into v_ret
          from config 
         where code = upper(p_code);
         
        return v_ret;
    
    end f_get_config_value;
    
    
    function f_get_root_dir return varchar2 
    is
    v_ret varchar2(2000);
    begin
        return f_get_config_value('VER_CON_ROOT_FOLDER');
    end f_get_root_dir;
    
    function f_get_cl_file_location return varchar2
    is
     v_ret varchar2(2000); 
    begin    
        return f_get_config_value('CHANGE.LOG_FILE_LOCATION');     
    end f_get_cl_file_location;
    
    procedure git_commit(p_message varchar2 default null)
    is
      v_report_url  varchar2(2000) := f_get_config_value('NODE_SERVICE');  
      v_request     utl_http.req;
      v_response    utl_http.resp;
      v_res_var     varchar2(32767);
    begin
    sys.htp.init;

    v_report_url := v_report_url  || '/saveToVersionCtrl?user=' || p$utl_context.get_user;
    
    utl_http.set_transfer_timeout(600);
    
  
    p_log('p$ver_ctrl.git_commit url : ' || v_report_url);
   
    v_request := utl_http.begin_request(v_report_url);
    utl_http.set_header(v_request, 'User-Agent', 'Mozilla/4.0');
    v_response := utl_http.get_response(v_request);
    loop
      begin
        utl_http.read_text(v_response, v_res_var, 32767);        
      exception
        when utl_http.end_of_body then
          exit;
      end;
    end loop;
    utl_http.end_response(v_response);
    p_log(v_res_var);
    exception
        when others then
        p_log('git_commit = ' || utl_http.get_detailed_sqlerrm);
        raise_application_error(-20343, utl_http.get_detailed_sqlerrm);
    end git_commit;
    
    
end p$ver_ctrl;

/
