--------------------------------------------------------
--  DDL for Table DOMINIO
--------------------------------------------------------

  CREATE TABLE "DOMINIO" 
   (	"COD_DOMINIO" NUMBER(15,0), 
	"NOMBRE" VARCHAR2(200), 
	"ESTADO" VARCHAR2(20)
   ) ;

   COMMENT ON COLUMN "DOMINIO"."COD_DOMINIO" IS 'Codigo autoincremental de la tabla';
   
   COMMENT ON COLUMN "DOMINIO"."NOMBRE" IS 'Campo que indica el nombre que va a tener el dominio.';
   
   COMMENT ON COLUMN "DOMINIO"."ESTADO" IS 'Dominio que indica el estado del dominio,si este esta activo o esta inactivo.';
   
   COMMENT ON TABLE "DOMINIO"  IS 'Tabla donde se crearan los dominios que se haran uso en el sistema.';
   
--------------------------------------------------------
--  DDL for Index DOMINIO__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "DOMINIO__IDX" ON "DOMINIO" ("COD_DOMINIO", "ESTADO") 
  ;
--------------------------------------------------------
--  Constraints for Table DOMINIO
--------------------------------------------------------

  ALTER TABLE "DOMINIO" ADD CONSTRAINT "DOMINIO_PK" PRIMARY KEY ("COD_DOMINIO") ENABLE;
  ALTER TABLE "DOMINIO" ADD CHECK (
    estado IN (
        '1','2'
    )
) ENABLE;
  ALTER TABLE "DOMINIO" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "DOMINIO" MODIFY ("NOMBRE" NOT NULL ENABLE);
  ALTER TABLE "DOMINIO" MODIFY ("COD_DOMINIO" NOT NULL ENABLE);
