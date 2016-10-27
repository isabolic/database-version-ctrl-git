--------------------------------------------------------
--  DDL for Package P$DB_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "P$DB_OBJECT" AUTHID CURRENT_USER as 

    
    procedure export(p_ddl_id ddl_log.id%type) ;
            
    procedure export_db_object_to_ddl_log (p_ddl_id ddl_log.id%type);
    
    procedure generate_db_object_script;
    
    function is_object_valid( p_object_name varchar2
                             ,p_owner       varchar2
                             ,p_object_type varchar2) return boolean;
    
    function is_object_valid_txt ( p_object_name varchar2
                                ,p_owner       varchar2
                                ,p_object_type varchar2) return varchar2;
    
end p$db_object;

/
