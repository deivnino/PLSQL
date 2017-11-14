--------------------------------------------------------
--  DDL for Table DANIO_FALTANTE_PENDIENTE
--------------------------------------------------------

  CREATE TABLE "DANIO_FALTANTE_PENDIENTE" 
   (	"TIPO_OBS" NUMBER(20,0), 
	"FEC_PEND" DATE DEFAULT SYSDATE, 
	"ESTADO" NUMBER(20,0), 
	"REG_DAN_FALT_FEC_REP" DATE DEFAULT SYSDATE, 
	"REG_DAN_FALT_SOLICITUD" NUMBER(10,0), 
	"FEC_OBJECION" DATE DEFAULT SYSDATE
   ) ;

   COMMENT ON COLUMN "DANIO_FALTANTE_PENDIENTE"."TIPO_OBS" IS 'tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo como pendiente';
   
   COMMENT ON COLUMN "DANIO_FALTANTE_PENDIENTE"."FEC_PEND" IS 'fecha pendiente - Campor donde se almacena la fecha del sistema donde la solicitud quedo como pendiente.';
   
   COMMENT ON COLUMN "DANIO_FALTANTE_PENDIENTE"."ESTADO" IS 'Campo que por medio de un dominio indica el estado de registro.';
   
   COMMENT ON COLUMN "DANIO_FALTANTE_PENDIENTE"."REG_DAN_FALT_FEC_REP" IS 'fecha reporte - campo donde se registra la fecha del sistema en la cual se esta haciendo el reporte de danios y faltantes.';
   
   COMMENT ON TABLE "DANIO_FALTANTE_PENDIENTE"  IS 'Danios Faltantes Pendientes - Tabla donde se registran las solicitudes de reporte de daños y faltantes que quedan pendientes,que no cumplieron las reglas de negocio definidas';
   

   --------------------------------------------------------
--  Constraints for Table DANIO_FALTANTE_PENDIENTE
--------------------------------------------------------

  ALTER TABLE "DANIO_FALTANTE_PENDIENTE" MODIFY ("TIPO_OBS" NOT NULL ENABLE);
  ALTER TABLE "DANIO_FALTANTE_PENDIENTE" MODIFY ("FEC_PEND" NOT NULL ENABLE);
  ALTER TABLE "DANIO_FALTANTE_PENDIENTE" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "DANIO_FALTANTE_PENDIENTE" MODIFY ("REG_DAN_FALT_FEC_REP" NOT NULL ENABLE);
  ALTER TABLE "DANIO_FALTANTE_PENDIENTE" MODIFY ("REG_DAN_FALT_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "DANIO_FALTANTE_PENDIENTE" MODIFY ("FEC_OBJECION" NOT NULL ENABLE);
  ALTER TABLE "DANIO_FALTANTE_PENDIENTE" ADD CONSTRAINT "DANIO_FALTANTE_PENDIENTE_PK" PRIMARY KEY ("REG_DAN_FALT_FEC_REP", "REG_DAN_FALT_SOLICITUD", "TIPO_OBS") ENABLE;

