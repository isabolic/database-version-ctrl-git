begin
 insert into version_control_structure
     select 'PACKAGE BODY', '#SCHEMA#/packages/', seq_id.nextval, null, 'pkb' from dual;

 insert into version_control_structure
     select 'PLUGIN', '#SCHEMA#/#APEX#/#APP_ID#/plugins/#NAME#', seq_id.nextval, null, null from dual;

 insert into version_control_structure
     select 'BUILD OPTION', '#SCHEMA#/#APEX#/#APP_ID#/build_option/', seq_id.nextval, null, null from dual;

 update version_control_structure
     set file_ext = 'pks' 
     where code = 'PACKAGE';     
 
  update version_control_structure 
     set acmg_id = (select id from apex_comp_maping where apex_table_name = 'WWV_FLOW_PLUGINS')
   where code = 'PLUGIN';
 commit;
  
  update version_control_structure 
     set acmg_id = (select id from apex_comp_maping where apex_table_name = 'WWV_FLOW_PATCHES')
   where code = 'BUILD OPTION';
 commit;
end;
/

