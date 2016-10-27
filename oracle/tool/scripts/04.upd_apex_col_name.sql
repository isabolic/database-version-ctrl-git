begin
     update apex_comp_maping
    set apex_col_name       = 'NAME'
      where apex_table_name = 'WWV_FLOW_STEPS';
     update apex_comp_maping
    set apex_col_name       = 'NAME'
      where apex_table_name = 'WWV_FLOW_TEMPLATES';
     update apex_comp_maping
    set apex_col_name       = 'SHORTCUT_NAME'
      where apex_table_name = 'WWV_FLOW_SHORTCUTS';
     update apex_comp_maping
    set apex_col_name       = 'NAME'
      where apex_table_name = 'WWV_FLOW_ITEMS';
     update apex_comp_maping
    set apex_col_name       = 'PROCESS_NAME'
      where apex_table_name = 'WWV_FLOW_PROCESSING';
     update apex_comp_maping
    set apex_col_name       = 'COMPUTATION_ITEM'
      where apex_table_name = 'WWV_FLOW_COMPUTATIONS';
     update apex_comp_maping
    set apex_col_name       = 'NAME'
      where apex_table_name = 'WWV_FLOW_SECURITY_SCHEMES';
     update apex_comp_maping
    set apex_col_name       = 'PATCH_NAME'
      where apex_table_name = 'WWV_FLOW_PATCHES';
     update apex_comp_maping
    set apex_col_name       = 'LOV_NAME'
      where apex_table_name = 'WWV_FLOW_LISTS_OF_VALUES$';
     update apex_comp_maping
    set apex_col_name       = 'NAME'
      where apex_table_name = 'WWV_FLOW_PLUGINS';
     update apex_comp_maping
    set apex_col_name       = 'NAME'
      where apex_table_name = 'WWV_FLOW_SHARED_QUERIES';
     update apex_comp_maping
    set apex_col_name       = 'NAME'
      where apex_table_name = 'WWV_FLOW_LISTS';
     update apex_comp_maping
    set apex_col_name       = 'LIST_ITEM_LINK_TEXT'
      where apex_table_name = 'WWV_FLOW_LIST_ITEMS';
    commit;
end;
/