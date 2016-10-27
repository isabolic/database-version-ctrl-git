--------------------------------------------------------
--  DDL for Package Body P$UTL_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "P$UTL_CONTEXT" as

   PROCEDURE clear_context IS
   BEGIN
      dbms_session.clear_all_context('TOOL');
   END clear_context;

   PROCEDURE set_context(p_context VARCHAR2, p_context_value VARCHAR2) IS
   BEGIN
       dbms_session.set_context('TOOL', upper(p_context), p_context_value);
   END set_context;

   FUNCTION get_context_value(p_context VARCHAR2) RETURN VARCHAR2 AS
   BEGIN
      RETURN sys_context('TOOL', upper(p_context));
   END get_context_value;
   
   PROCEDURE set_user(p_user VARCHAR2) IS
     v_apex_user varchar2(200);          
   begin
       begin
          select apex_user
            into v_apex_user
            from os_users_mapping
           where 1=1
             and (   (upper(os_user) = upper(p_user))
                   or(upper(apex_user) = upper(p_user)));
       exception
            when no_data_found then
            raise_application_error(-20001,'No os user provided in table OS_USERS_MAPPING');
       end;
       dbms_session.set_context('TOOL', 'USER', v_apex_user);
   END set_user;
   
   function get_user return varchar2 is
   begin
     return sys_context('TOOL', 'USER'); 
   end get_user;
end p$utl_context;

/
