begin
insert into config (code, value)
select 'CHANGE.LOG_FILE_LOCATION', '/Volumes/Workspace/playground/test_git/changelog.sql' from dual; 
commit;
end;
/

begin
insert into config (code, value)
select 'NODE_SERVICE', 'WAR-MAC.local:9090' from dual; 
commit;
end;
/
