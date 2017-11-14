--------------------------------------------------------
--  DDL for Table SERVICIO_PUBLICO
--------------------------------------------------------

  CREATE TABLE "SERVICIO_PUBLICO" 
   (	"COD_SERV_PUB" NUMBER(15,0), 
	"COD_SERV" VARCHAR2(10), 
	"NOMBRE" VARCHAR2(200), 
	"VAL_RECL" NUMBER(20,2), 
	"FEC_INI" DATE, 
	"FEC_FIN" DATE, 
	"REG_AMP_INTE_FEC_REP" DATE DEFAULT SYSDATE, 
	"REG_AMP_INT_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "SERVICIO_PUBLICO"."COD_SERV_PUB" IS 'codigo servicio publico - Codigo autoincremental de la tabla';
   
   COMMENT ON COLUMN "SERVICIO_PUBLICO"."COD_SERV" IS 'codigo servicio - Campo donde se almacena el codigo del servicio publico que esta registrado en SAI.';
   
   COMMENT ON COLUMN "SERVICIO_PUBLICO"."NOMBRE" IS 'Campo donde se registra el nombre del servicio publico.';
   
   COMMENT ON COLUMN "SERVICIO_PUBLICO"."VAL_RECL" IS 'valor reclamar - Campo donde se almacena el valor que se va a reclamar por cada servicio publico.';
   
   COMMENT ON COLUMN "SERVICIO_PUBLICO"."FEC_INI" IS 'fecha inicial - Campo donde se registra el iinicio del periodo de facturacion de los servicios publicos.';
   
   COMMENT ON COLUMN "SERVICIO_PUBLICO"."FEC_FIN" IS 'fecha final - Campo donde se registra el fin del periodo de facturacion de los servicios publicos.';
   
   COMMENT ON COLUMN "SERVICIO_PUBLICO"."REG_AMP_INTE_FEC_REP" IS 'fec rep - campo donde se guarda la fecha del sistema de cuando se esta realizando el reporte de la novedad.';
   
   COMMENT ON TABLE "SERVICIO_PUBLICO"  IS 'SERVICIO PUBLICO - Tabla donde se almacenan los valores ingresados de los servicios publicos,en el reporte del amparo integral.';
   

--------------------------------------------------------
--  Constraints for Table SERVICIO_PUBLICO
--------------------------------------------------------

  ALTER TABLE "SERVICIO_PUBLICO" MODIFY ("COD_SERV_PUB" NOT NULL ENABLE);
  ALTER TABLE "SERVICIO_PUBLICO" MODIFY ("COD_SERV" NOT NULL ENABLE);
  ALTER TABLE "SERVICIO_PUBLICO" MODIFY ("NOMBRE" NOT NULL ENABLE);
  ALTER TABLE "SERVICIO_PUBLICO" MODIFY ("VAL_RECL" NOT NULL ENABLE);
  ALTER TABLE "SERVICIO_PUBLICO" MODIFY ("FEC_INI" NOT NULL ENABLE);
  ALTER TABLE "SERVICIO_PUBLICO" MODIFY ("FEC_FIN" NOT NULL ENABLE);
  ALTER TABLE "SERVICIO_PUBLICO" MODIFY ("REG_AMP_INTE_FEC_REP" NOT NULL ENABLE);
  ALTER TABLE "SERVICIO_PUBLICO" MODIFY ("REG_AMP_INT_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "SERVICIO_PUBLICO" ADD CONSTRAINT "SERVICIO_PUBLICO_PK" PRIMARY KEY ("COD_SERV_PUB") ENABLE;

