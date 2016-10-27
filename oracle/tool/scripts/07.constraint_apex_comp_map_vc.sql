
create table BCK_APEX_COMP_MAPING as 
 select * from APEX_COMP_MAPING;
/

begin
 delete from APEX_COMP_MAPING;
 commit;
end;
/

alter table APEX_COMP_MAPING add (id number primary key);
/

begin
 insert into APEX_COMP_MAPING 
 select  APEX_TABLE_NAME,COMP_TYPE,DESCRIPTION,APEX_COL_NAME, seq_id.nextval from BCK_APEX_COMP_MAPING;
 commit;
end;
/


create table bck_version_control_structure as 
 select * from version_control_structure;
/

begin
 delete from version_control_structure;
 commit;
end;
/

alter table version_control_structure add (id number primary key);
/

alter table version_control_structure add (acmg_id number);
/

alter table bck_version_control_structure add (comp_type varchar2 (50));
/

begin
update bck_version_control_structure
   set comp_type = 'APP ITEM'
   where code = 'app_items';

update bck_version_control_structure
   set comp_type = 'APP PROCESS'
   where code = 'app_process';

update bck_version_control_structure
   set comp_type = 'APP COMPUTATION'
   where code = 'application_computation';

update bck_version_control_structure
   set comp_type = 'SECURITY SCHEME'
   where code = 'authorization_scheme';
  
update bck_version_control_structure
   set comp_type = 'BREADCRUMB'
   where code = 'breadcrumbs';

update bck_version_control_structure
   set comp_type = 'LOV'
   where code = 'list_of_values';
   
update bck_version_control_structure
   set comp_type = 'LIST'
   where code = 'lists';   

update bck_version_control_structure
   set comp_type = 'PAGE'
   where code = 'pages';

update bck_version_control_structure
   set comp_type = 'PLUGIN'
   where code = 'plugins'; 

update bck_version_control_structure
   set comp_type = 'SHORTCUTS'
   where code = 'shortcuts';

update bck_version_control_structure
   set comp_type = 'TEMPLATE'
   where code = 'templates';

update bck_version_control_structure
   set comp_type = 'TEMPLATE'
   where code = 'templates';

 delete
   from bck_version_control_structure
  where code in('templates_page', 'navigation_bar', 'plugins') ;
  commit;
end;
/

ALTER TABLE version_control_structure
ADD CONSTRAINT fk_acmg
  FOREIGN KEY (acmg_id)
  REFERENCES APEX_COMP_MAPING(id);
/

begin
insert into version_control_structure
  select code
  , path
  , seq_id.nextval
  , m.id 
  from bck_version_control_structure x
  left join apex_comp_maping m on(m.comp_type = x.comp_type);
  commit;
end;
/

drop table bck_apex_comp_maping;
/

drop table bck_version_control_structure;
/

