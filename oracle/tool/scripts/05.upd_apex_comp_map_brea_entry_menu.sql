begin
     insert
       into tool.apex_comp_maping
        (
            apex_table_name
          , comp_type
          , description
          , apex_col_name
        )
        values
        (
            'WWV_FLOW_MENU_OPTIONS'
          , 'BREADCRUMB'
          , 'SH. BREADCRUMBS ENTRY'
          , 'SHORT_NAME'
        ) ;

    insert
       into tool.apex_comp_maping
        (
            apex_table_name
          , comp_type
          , description
          , apex_col_name
        )
        values
        (
            'WWV_FLOW_TEMPLATES'
          , 'PAGE TEMPLATE'
          , 'SH. PAGE TEMPLATE'
          , 'NAME'
        );

     delete
       from apex_comp_maping
      where 1               = 1
        and apex_table_name = 'WWV_FLOW_LISTS'
        and comp_type       = 'MENU';

     delete
       from apex_comp_maping
      where 1               = 1
        and apex_table_name = 'WWV_FLOW_LIST_ITEMS'
        and comp_type       = 'LIST';
    commit;
end;
/

alter table DDL_LOG modify OBJECT_NAME varchar2(300);
/