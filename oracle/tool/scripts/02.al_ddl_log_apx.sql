alter table ddl_log add(apex_app_id number);
/
alter table ddl_log add(apex_page_id number, apex_comp_id number);
/
alter table ddl_log add(apex_workspace_id number);
/
alter table ddl_log add(apex_component_type varchar2(200));
/