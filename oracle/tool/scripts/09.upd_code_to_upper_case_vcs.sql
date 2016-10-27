
begin
update version_control_structure
   set code = upper(code);
commit;
end;
/