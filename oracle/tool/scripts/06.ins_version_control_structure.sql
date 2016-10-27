begin
     insert into version_control_structure
     select 'schema_folder', '#SCHEMA#' from dual;
     insert into version_control_structure
     select 'apex_root_folder', '#APEX#' from dual;
     insert into version_control_structure
     select 'app_items', '/#APEX#/#APP_ID#/app_items/' from dual;
     insert into version_control_structure
     select 'app_process', '/#APEX#/#APP_ID#/app_process/' from dual;
     insert into version_control_structure
     select 'application_computation'
      , '/#APEX#/#APP_ID#/application_computation/'
       from dual;
     insert into version_control_structure
     select 'authorization_scheme'
      , '/#APEX#/#APP_ID#/authorization_scheme/'
       from dual;
     insert into version_control_structure
     select 'breadcrumbs', '/#APEX#/#APP_ID#/breadcrumbs/' from dual;
     insert into version_control_structure
     select 'list_of_values', '/#APEX#/#APP_ID#/list_of_values/' from dual;
     insert into version_control_structure
     select 'lists', '/#APEX#/#APP_ID#/lists/' from dual;
     insert into version_control_structure
     select 'navigation_bar', '/#APEX#/#APP_ID#/navigation_bar/' from dual;
     insert into version_control_structure
     select 'pages', '/#APEX#/#APP_ID#/pages/' from dual;
     insert into version_control_structure
     select 'plugins', '/#APEX#/#APP_ID#/plugins/' from dual;
     insert into version_control_structure
     select 'shortcuts', '/#APEX#/#APP_ID#/shortcuts/' from dual;
     insert into version_control_structure
     select 'templates', '/#APEX#/#APP_ID#/templates/' from dual;
     insert into version_control_structure
     select 'templates_page', '/#APEX#/#APP_ID#/#TEMPLATES#/page/' from dual;
     insert into version_control_structure
     select 'plugins', '/#APEX#/#APP_ID#/plugins/' from dual;
     insert into version_control_structure
     select 'packages', '#SCHEMA#/packages/' from dual;
     insert into version_control_structure
     select 'procedures', '#SCHEMA#/procedures/' from dual;
     insert into version_control_structure
     select 'functions', '#SCHEMA#/functions/' from dual;
     insert into version_control_structure
     select 'types', '#SCHEMA#/types/' from dual;
     insert into version_control_structure
     select 'views', '#SCHEMA#/packages/' from dual;
     insert into version_control_structure
     select 'materialized_views', '#SCHEMA#/materialized_views/' from dual;
     insert into version_control_structure
     select 'triggers', '#SCHEMA#/triggers/' from dual;
     insert into version_control_structure
     select 'scripts', '#SCHEMA#/scripts/' from dual;
     insert into version_control_structure
     select 'sequences', '#SCHEMA#/sequences/' from dual;
     insert into version_control_structure
     select 'tables', '#SCHEMA#/tables/' from dual;
     insert into version_control_structure
     select 'jobs', '#SCHEMA#/jobs/' from dual;
     commit;
end;
/

