--------------------------------------------------------
--  DDL for Table LOG_ERROR
--------------------------------------------------------

  CREATE TABLE "LOG_ERROR" 
   (	"ID_LOG" NUMBER(10,0), 
	"ENTIDAD" VARCHAR2(30), 
	"FECHA_REGISTRO" DATE DEFAULT SYSDATE, 
	"OBSERVACION" VARCHAR2(2000)
   ) ;
   
--------------------------------------------------------
--  Constraints for Table LOG_ERROR
--------------------------------------------------------

  ALTER TABLE "LOG_ERROR" MODIFY ("ID_LOG" NOT NULL ENABLE);
  ALTER TABLE "LOG_ERROR" ADD CONSTRAINT "LOG_ERROR_PK" PRIMARY KEY ("ID_LOG") ENABLE;
  ALTER TABLE "LOG_ERROR" MODIFY ("FECHA_REGISTRO" NOT NULL ENABLE);
  ALTER TABLE "LOG_ERROR" MODIFY ("OBSERVACION" NOT NULL ENABLE);
