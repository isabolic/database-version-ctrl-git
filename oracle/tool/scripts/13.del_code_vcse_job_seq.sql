begin
delete from VERSION_CONTROL_STRUCTURE where code in ('JOB','TABLE' ,'SEQUENCE');
commit;
end;
/