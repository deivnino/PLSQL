--------------------------------------------------------
--  DDL for Table LOG_SERVICIO_SIMI
--------------------------------------------------------

  CREATE TABLE "LOG_SERVICIO_SIMI" 
   (	"COD_LOG_SERV" NUMBER(5,0), 
	"FECHA_REGISTRO" DATE DEFAULT SYSDATE, 
	"REQUEST" VARCHAR2(400), 
	"RESPONSE" VARCHAR2(400), 
	"ESTADO" NUMBER(20,0)
   ) ;

   COMMENT ON COLUMN "LOG_SERVICIO_SIMI"."COD_LOG_SERV" IS 'codigo log servicio SIMI - Codigo autoincremental de la tabla.';
   
   COMMENT ON COLUMN "LOG_SERVICIO_SIMI"."FECHA_REGISTRO" IS 'Fecha del sistema de cuando se hizo el registro';
   
   COMMENT ON COLUMN "LOG_SERVICIO_SIMI"."REQUEST" IS 'Campo donde se almacena la peticion generada al servicio de SIMI.';
   
   COMMENT ON COLUMN "LOG_SERVICIO_SIMI"."RESPONSE" IS 'Campo donde se almacena lar respuesta generada por el servicio de SIMI.';
   
   COMMENT ON COLUMN "LOG_SERVICIO_SIMI"."ESTADO" IS 'Tabla Dominio - Campo que por medio de un dominio indica el estado de registro.';
   
   COMMENT ON TABLE "LOG_SERVICIO_SIMI"  IS 'Tabla donde se almacena la informacion que procesa el servicio web de SIMI.';
   

--------------------------------------------------------
--  Constraints for Table LOG_SERVICIO_SIMI
--------------------------------------------------------

  ALTER TABLE "LOG_SERVICIO_SIMI" MODIFY ("COD_LOG_SERV" NOT NULL ENABLE);
  ALTER TABLE "LOG_SERVICIO_SIMI" MODIFY ("FECHA_REGISTRO" NOT NULL ENABLE);
  ALTER TABLE "LOG_SERVICIO_SIMI" MODIFY ("REQUEST" NOT NULL ENABLE);
  ALTER TABLE "LOG_SERVICIO_SIMI" MODIFY ("RESPONSE" NOT NULL ENABLE);
  ALTER TABLE "LOG_SERVICIO_SIMI" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "LOG_SERVICIO_SIMI" ADD CONSTRAINT "LOG_SERVICIO_SIMI_PK" PRIMARY KEY ("COD_LOG_SERV") ENABLE;
