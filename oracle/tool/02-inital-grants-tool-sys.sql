grant all privileges to tool identified by xxx;
/

grant select on gv_$session to tool;
/

grant select on gv_$sqltext to tool;
/

grant select_catalog_role to tool;
/

grant execute on utl_http to tool;
/


BEGIN
  sys.dbms_network_acl_admin.create_acl (
    acl         => 'WARLOCAL.xml'
   ,description => 'Pristup WAR-MAC.local mašini'
   ,principal   => 'TOOL'
   ,is_grant    => TRUE
   ,privilege   => 'connect'
   ,start_date  => NULL
   ,end_date    => NULL);
   
  sys.dbms_network_acl_admin.add_privilege (
    acl        => 'WARLOCAL.xml'
   ,principal  => 'TOOL'
   ,is_grant   => TRUE
   ,privilege  => 'connect'
   ,start_date => NULL
   ,end_date   => NULL);
  sys.dbms_network_acl_admin.add_privilege (
    acl        => 'WARLOCAL.xml'
   ,principal  => 'TOOL'
   ,is_grant   => TRUE
   ,privilege  => 'resolve'
   ,start_date => NULL
   ,end_date   => NULL);
  dbms_network_acl_admin.assign_acl (
    acl        => 'WARLOCAL.xml'
   ,HOST       => 'WAR-MAC.local'
   ,lower_port => 9090
   ,upper_port => 9090);
  COMMIT;
END;
/
