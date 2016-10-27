--------------------------------------------------------
--  DDL for Table VERSION_CONTROL_STRUCTURE
--------------------------------------------------------

  CREATE TABLE "VERSION_CONTROL_STRUCTURE" 
   (    
    "CODE" VARCHAR2(50 BYTE), 
    "PATH" VARCHAR2(2000 BYTE)
   ) ;
/

comment on table version_control_structure is 
'Entry DB objekata i apex comp. (colona code) mapiran sa putanjom na disku gdje se trebaju spusti. DB objekti koji nemaju REPLACE comandu u DDL idu u scripts entry.'
;
/
