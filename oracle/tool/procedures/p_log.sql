--------------------------------------------------------
--  DDL for Procedure P_LOG
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "P_LOG" (
        p_msg clob) as
pragma autonomous_transaction;        
begin
     insert into log
        (msg) 
     values (p_msg);
     commit;
end;

/
