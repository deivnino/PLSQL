--------------------------------------------------------
--  DDL for Table ALERTA
--------------------------------------------------------

  CREATE TABLE "ALERTA" 
   (	"COD_ALE" NUMBER(15,0), 
	"FEC_ALE" DATE DEFAULT SYSDATE, 
	"OBSERVACION" VARCHAR2(400), 
	"ESTADO" NUMBER(20,0), 
	"TRANSACCION_COD_TRAN" NUMBER(5,0)
   ) ;

   COMMENT ON COLUMN "ALERTA"."COD_ALE" IS 'codigo alerta - Codigo autoincremental de la tabla.';
   COMMENT ON COLUMN "ALERTA"."FEC_ALE" IS 'fecha alerta - Campo donde se almacena la fecha del sistema en la que se esta realizando la alerta.';
   COMMENT ON COLUMN "ALERTA"."OBSERVACION" IS 'Campo que indica la observacion de la alerta,la razon por la que se esta generando la alerta.';
   COMMENT ON COLUMN "ALERTA"."ESTADO" IS 'Tabla Dominio - Campo que por medio de un dominio indica el estado de registro.';
   COMMENT ON COLUMN "ALERTA"."TRANSACCION_COD_TRAN" IS 'Codigo autoincremental de la tabla';
   COMMENT ON TABLE "ALERTA"  IS 'Tabla donde se registran las Alertas que se requieran hacer sobre una transaccion,generalmente anulaciones.';

--------------------------------------------------------
--  Constraints for Table ALERTA
--------------------------------------------------------

  ALTER TABLE "ALERTA" MODIFY ("COD_ALE" NOT NULL ENABLE);
  ALTER TABLE "ALERTA" MODIFY ("FEC_ALE" NOT NULL ENABLE);
  ALTER TABLE "ALERTA" MODIFY ("OBSERVACION" NOT NULL ENABLE);
  ALTER TABLE "ALERTA" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "ALERTA" MODIFY ("TRANSACCION_COD_TRAN" NOT NULL ENABLE);
  ALTER TABLE "ALERTA" ADD CONSTRAINT "ALERTA_PK" PRIMARY KEY ("COD_ALE") ENABLE;
  
--------------------------------------------------------
--  DDL for Index ALERTA__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "ALERTA__IDX" ON "ALERTA" ("COD_ALE", "ESTADO") 
  ;

