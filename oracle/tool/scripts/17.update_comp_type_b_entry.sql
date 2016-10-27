begin
update apex_comp_maping
   set comp_type = 'BREADCRUMB ENTRY'
 where 1=1
   and apex_table_name = 'WWV_FLOW_MENU_OPTIONS';
commit;

update version_control_structure
   set code = 'BREADCRUMB ENTRY'
 where acmg_id = (select id
                    from apex_comp_maping
                   where 1=1
                     and apex_table_name = 'WWV_FLOW_MENU_OPTIONS');
  commit;
end;
/