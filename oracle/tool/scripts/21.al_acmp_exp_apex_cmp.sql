
begin
delete from version_control_structure where code = 'BREADCRUMB ENTRY';
delete from apex_comp_maping where comp_type =  'BREADCRUMB ENTRY';
commit;
end;
/

begin
 insert
   into apex_comp_maping
    (
        apex_table_name
      , comp_type
      , description
      , apex_col_name
      , id
    )
    values
    (
        'WWV_FLOW_ICON_BAR'
      , 'NAVBAR'
      , 'SH. CLASSIC NAVBAR ENTRY'
      , 'ICON_SUBTEXT'
      , seq_id.nextval
    );
    commit;
end;
/

begin
     insert
       into version_control_structure
        (
            code
          , path
          , id
        )
        values
        (
            'NAVBAR'
          , '/#APEX#/#APP_ID#/navbar/'
          , seq_id.nextval
        ) ;
     update version_control_structure
    set acmg_id =
        (
             select id from apex_comp_maping where comp_type = 'NAVBAR'
        )
      where code = 'NAVBAR';
    commit;
end;
/