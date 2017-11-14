--------------------------------------------------------
--  DDL for Table AUMENTO_PENDIENTE
--------------------------------------------------------

  CREATE TABLE "AUMENTO_PENDIENTE" 
   (	"TIPO_OBS_AUM" NUMBER(20,0), 
	"FEC_PEND" DATE DEFAULT SYSDATE, 
	"ESTADO" NUMBER(20,0), 
	"AUMENTO_FEC_AUMENTO" DATE DEFAULT SYSDATE, 
	"AUMENTO_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "AUMENTO_PENDIENTE"."TIPO_OBS_AUM" IS 'Tabla Dominio - tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo en los pendietes';
   COMMENT ON COLUMN "AUMENTO_PENDIENTE"."FEC_PEND" IS 'fecha pendiente- Fecha por la cual el aumento quedo en aumentos pendietes.';
   COMMENT ON COLUMN "AUMENTO_PENDIENTE"."ESTADO" IS 'Tabla Dominio - Campo que por medio de un dominio indica el estado de registro.';
   COMMENT ON COLUMN "AUMENTO_PENDIENTE"."AUMENTO_FEC_AUMENTO" IS 'fecha aumento - Fecha en la cual se esta realizando el aumento.';
   COMMENT ON TABLE "AUMENTO_PENDIENTE"  IS 'Aumento Pendiente - Tabla donde se registran los aumentos pendientes,los que no cumplieron con las reglas de negocio definidas.';
   
--------------------------------------------------------
--  Constraints for Table AUMENTO_PENDIENTE
--------------------------------------------------------

  ALTER TABLE "AUMENTO_PENDIENTE" MODIFY ("TIPO_OBS_AUM" NOT NULL ENABLE);
  ALTER TABLE "AUMENTO_PENDIENTE" MODIFY ("FEC_PEND" NOT NULL ENABLE);
  ALTER TABLE "AUMENTO_PENDIENTE" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "AUMENTO_PENDIENTE" MODIFY ("AUMENTO_FEC_AUMENTO" NOT NULL ENABLE);
  ALTER TABLE "AUMENTO_PENDIENTE" MODIFY ("AUMENTO_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "AUMENTO_PENDIENTE" ADD CONSTRAINT "AUMENTO_PENDIENTE_PK" PRIMARY KEY ("AUMENTO_FEC_AUMENTO", "AUMENTO_SOLICITUD", "TIPO_OBS_AUM") ENABLE;

--------------------------------------------------------
--  DDL for Index AUMENTO_PENDIENTE__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "AUMENTO_PENDIENTE__IDX" ON "AUMENTO_PENDIENTE" ("TIPO_OBS_AUM", "ESTADO") 
  ;

--------------------------------------------------------
--  DDL for Index AUMENTO_PENDIENTE__IDXV1
--------------------------------------------------------

  CREATE UNIQUE INDEX "AUMENTO_PENDIENTE__IDXV1" ON "AUMENTO_PENDIENTE" ("AUMENTO_FEC_AUMENTO", "AUMENTO_SOLICITUD") 
  ;

