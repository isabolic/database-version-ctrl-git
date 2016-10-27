begin
update version_control_structure set code = 'PACKAGE' where code = 'PACKAGES';
update version_control_structure set code = 'PROCEDURE' where code = 'PROCEDURES';
update version_control_structure set code = 'FUNCTION' where code = 'FUNCTIONS';
update version_control_structure set code = 'TYPE' where code = 'TYPES';
update version_control_structure set code = 'VIEW' where code = 'VIEWS';
update version_control_structure set code = 'MATERIALIZED_VIEW' where code = 'MATERIALIZED_VIEWS';
update version_control_structure set code = 'TRIGGER' where code = 'TRIGGERS';
update version_control_structure set code = 'SCRIPT' where code = 'SCRIPTS';
update version_control_structure set code = 'SEQUENCE' where code = 'SEQUENCES';
update version_control_structure set code = 'TABLE' where code = 'TABLES';
update version_control_structure set code = 'JOB' where code = 'JOBS';
commit;
end;
/