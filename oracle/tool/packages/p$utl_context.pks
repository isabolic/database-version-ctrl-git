--------------------------------------------------------
--  DDL for Package P$UTL_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "P$UTL_CONTEXT" as 

   procedure clear_context;

   procedure set_context(p_context varchar2, p_context_value varchar2);

   function get_context_value(p_context varchar2) return varchar2;
   
   procedure set_user(p_user varchar2);
   
   function get_user return varchar2;

end p$utl_context;

/
