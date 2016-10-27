--------------------------------------------------------
--  DDL for Table DDL_LOG
--------------------------------------------------------

  CREATE TABLE "DDL_LOG" 
   (
   "ID"        NUMBER,
   "OPERATION" VARCHAR2(30 BYTE), 
    "OBJ_OWNER" VARCHAR2(30 BYTE), 
    "OBJECT_NAME" VARCHAR2(30 BYTE), 
    "ATTEMPT_BY" VARCHAR2(30 BYTE), 
    "ATTEMPT_DT" DATE, 
    "SQL_TEXT" CLOB, 
    "OS_USER" VARCHAR2(200 BYTE), 
    "IS_EXPORTED" VARCHAR2(1 CHAR) DEFAULT 'N'
   );
/