--------------------------------------------------------
--  DDL for Package P$APX_UTL
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "P$APX_UTL" 
as   
    
    procedure export(
            p_app_id       number,
            p_page_id      number   default null,
            p_comp_id      number   default null,
            p_component    varchar2 default null,
            p_workspace_id number   default null,
            p_ddl_id       number   default null,
            p_theme_id     number   default null) ;
            
            
    function get_apx_tab_pk(
            p_table_name   varchar2,
            p_object_name  varchar2,
            p_date_time    date,
            p_app_id       number,
            p_workspace_id number,
            p_action       varchar2 default 'I')
        return number;
    
    procedure export_apex_comp_to_ddl_log (
        p_ddl_id      ddl_log.id%type
    );
    
    procedure generate_apex_comp_script;
             
end p$apx_utl;

/
