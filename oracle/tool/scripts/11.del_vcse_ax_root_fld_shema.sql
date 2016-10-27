begin
delete from version_control_structure where code in ('APEX_ROOT_FOLDER', 'SCHEMA_FOLDER');
end;
/
