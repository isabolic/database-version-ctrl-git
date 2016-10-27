begin
Insert into APEX_COMP_MAPING  values ('WWV_FLOW_AUTHENTICATIONS','AUTH SETUP','SH. AUTH SCHEMES', 'NAME', seq_id.nextval);
Insert into APEX_COMP_MAPING  values ('WWV_FLOW_TABS',  'TAB' , 'TAB SH.', 'TAB_NAME', seq_id.nextval);


INSERT INTO VERSION_CONTROL_STRUCTURE (CODE, PATH, ID) VALUES ('TAB', '/#APEX#/#APP_ID#/tabs/', seq_id.nextval);
INSERT INTO VERSION_CONTROL_STRUCTURE (CODE, PATH, ID) VALUES ( 'AUTH SETUP','/#APEX#/#APP_ID#/authentication_schemes' , seq_id.nextval);

update version_control_structure
set acmg_id =
    (
         select id from apex_comp_maping where comp_type = 'TAB'
    )
  where 1    = 1
    and code = 'TAB';


update version_control_structure
set acmg_id =
    (
         select id from apex_comp_maping where comp_type = 'AUTH SETUP'
    )
  where 1    = 1
    and code = 'AUTH SETUP';


commit;
end;
/