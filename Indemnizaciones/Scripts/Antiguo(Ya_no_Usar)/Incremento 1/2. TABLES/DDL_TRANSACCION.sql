--------------------------------------------------------
--  DDL for Table TRANSACCION
--------------------------------------------------------

  CREATE TABLE "TRANSACCION" 
   (	"COD_TRAN" NUMBER(15,0), 
	"USUARIO" NUMBER(20,0), 
	"IDENTIFICACION" NUMBER(20,0), 
	"FEC_TRAN" DATE DEFAULT SYSDATE, 
	"EQUIPO" VARCHAR2(300), 
	"ESTADO" NUMBER(20,0), 
	"LOG_SERV_SIMI_COD_LOG_SERV" NUMBER(5,0), 
	"DESOCUPACION_FEC_REGI" DATE DEFAULT SYSDATE, 
	"DESO_SOLICITUD_SAI_SOLICITUD" NUMBER(10,0), 
	"DESISTIMIENTO_FEC_REG" DATE DEFAULT SYSDATE, 
	"DESIS_SOL_SAI_SOLICITUD" NUMBER(10,0), 
	"REG_DANIO_FALT_FEC_REP" DATE DEFAULT SYSDATE, 
	"REG_DAN_FAL_SOL_SAI_SOLICITUD" NUMBER(10,0), 
	"REG_AMPARO_INTEGRAL_FEC_REP" DATE DEFAULT SYSDATE, 
	"REG_AMP_INTE_SOL_SAI_SOLICITUD" NUMBER(10,0), 
	"AUMENTO_FEC_AUMENTO" DATE DEFAULT SYSDATE, 
	"AUM_SOLICITUD_SAI_SOLICITUD" NUMBER(10,0), 
	"INGRESO_FEC_REGISTRO_ING" DATE DEFAULT SYSDATE, 
	"ING_SOLICITUD_SAI_SOLICITUD" NUMBER(10,0), 
	"RETIRO_FECHA_RETIRO" DATE DEFAULT SYSDATE, 
	"RETI_SOLICITUD_SAI_SOLICITUD" NUMBER(10,0), 
	"SINIESTRO_FEC_REP" DATE DEFAULT SYSDATE, 
	"SINIESTRO_SOL_SAI_SOLICITUD" NUMBER(10,0), 
	"NUM_INTENTOS" NUMBER(5,0)
   ) ;

   COMMENT ON COLUMN "TRANSACCION"."COD_TRAN" IS 'codigo transaccion - Codigo autoincremental de la tabla';
   
   COMMENT ON COLUMN "TRANSACCION"."USUARIO" IS 'LLave o codigo del usuario que realiz� la transacci�n.';
   
   COMMENT ON COLUMN "TRANSACCION"."IDENTIFICACION" IS 'Campo establecido para las polizas individuales';
   
   COMMENT ON COLUMN "TRANSACCION"."FEC_TRAN" IS 'fecha transaccion - Campo que indica la fecha del sistema en la que se realizo la transaccion.';
   
   COMMENT ON COLUMN "TRANSACCION"."EQUIPO" IS 'Atributo donde se almacena el equipo/ip del usuario que esta haciendo uso de la aplicacion.';
   
   COMMENT ON COLUMN "TRANSACCION"."ESTADO" IS 'Campo que por medio de un dominio indica el estado de registro.';
   
   COMMENT ON COLUMN "TRANSACCION"."LOG_SERV_SIMI_COD_LOG_SERV" IS 'Codigo autoincremental de la tabla.';
   
   COMMENT ON COLUMN "TRANSACCION"."DESOCUPACION_FEC_REGI" IS 'fecha registro - Fecha del sistema de cuando se esta realizando la desocupacion.';
   
   COMMENT ON COLUMN "TRANSACCION"."DESISTIMIENTO_FEC_REG" IS 'fecha registro - fecha del sistema en el que se esta haciendo el desistimiento.';
   
   COMMENT ON COLUMN "TRANSACCION"."REG_DANIO_FALT_FEC_REP" IS 'fecha reporte - campo donde se registra la fecha del sistema en la cual se esta haciendo el reporte de danios y faltantes.';
   
   COMMENT ON COLUMN "TRANSACCION"."REG_AMPARO_INTEGRAL_FEC_REP" IS 'fec rep - campo donde se guarda la fecha del sistema de cuando se esta realizando el reporte de la novedad.';
   
   COMMENT ON COLUMN "TRANSACCION"."AUMENTO_FEC_AUMENTO" IS 'fecha aumento - Fecha en la cual se esta realizando el aumento.';
   
   COMMENT ON COLUMN "TRANSACCION"."INGRESO_FEC_REGISTRO_ING" IS 'Fecha del sistema donde de cuado se esta realizando el registro.';
   
   COMMENT ON COLUMN "TRANSACCION"."RETIRO_FECHA_RETIRO" IS 'fecha retiro - fecha el cual se hizo el retiro.';
   
   COMMENT ON COLUMN "TRANSACCION"."SINIESTRO_FEC_REP" IS 'fecha reporte - Fecha del sistema (sysdate) de cuando se hizo el reporte de sineistro';
   
   COMMENT ON TABLE "TRANSACCION"  IS 'Tabla donde se van a almacenar las transacciones que se realizen sobre el sistema.';
   
   
 
 --------------------------------------------------------
--  Constraints for Table TRANSACCION
--------------------------------------------------------

  ALTER TABLE "TRANSACCION" MODIFY ("COD_TRAN" NOT NULL ENABLE);
  ALTER TABLE "TRANSACCION" MODIFY ("USUARIO" NOT NULL ENABLE);
  ALTER TABLE "TRANSACCION" MODIFY ("IDENTIFICACION" NOT NULL ENABLE);
  ALTER TABLE "TRANSACCION" MODIFY ("FEC_TRAN" NOT NULL ENABLE);
  ALTER TABLE "TRANSACCION" MODIFY ("EQUIPO" NOT NULL ENABLE);
  ALTER TABLE "TRANSACCION" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "TRANSACCION" ADD CONSTRAINT "ARC_3" CHECK (
    (
        (
            aumento_fec_aumento IS NOT NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NOT NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    ) OR (
        (
            ingreso_fec_registro_ing IS NOT NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NOT NULL
        ) AND (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    ) OR (
        (
            desocupacion_fec_regi IS NOT NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NOT NULL
        ) AND (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    ) OR (
        (
            desistimiento_fec_reg IS NOT NULL
        ) AND (
            desis_sol_sai_solicitud IS NOT NULL
        ) AND (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    ) OR (
        (
            reg_danio_falt_fec_rep IS NOT NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NOT NULL
        ) AND (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    ) OR (
        (
            siniestro_fec_rep IS NOT NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NOT NULL
        ) AND (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    ) OR (
        (
            reg_amparo_integral_fec_rep IS NOT NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NOT NULL
        ) AND (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    ) OR (
        (
            log_serv_simi_cod_log_serv IS NOT NULL
        ) AND (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    ) OR (
        (
            retiro_fecha_retiro IS NOT NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NOT NULL
        ) AND (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        )
    ) OR (
        (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    )
) ENABLE;
  ALTER TABLE "TRANSACCION" ADD CONSTRAINT "TRANSACCION_PK" PRIMARY KEY ("COD_TRAN") ENABLE;

--------------------------------------------------------
--  DDL for Index TRANSACCION__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "TRANSACCION__IDX" ON "TRANSACCION" ("LOG_SERV_SIMI_COD_LOG_SERV") 
  ;
--------------------------------------------------------
--  DDL for Index TRANSACCION__IDXV1
--------------------------------------------------------

  CREATE UNIQUE INDEX "TRANSACCION__IDXV1" ON "TRANSACCION" ("RETIRO_FECHA_RETIRO", "RETI_SOLICITUD_SAI_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index TRANSACCION__IDXV2
--------------------------------------------------------

  CREATE UNIQUE INDEX "TRANSACCION__IDXV2" ON "TRANSACCION" ("AUMENTO_FEC_AUMENTO", "AUM_SOLICITUD_SAI_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index TRANSACCION__IDXV3
--------------------------------------------------------

  CREATE UNIQUE INDEX "TRANSACCION__IDXV3" ON "TRANSACCION" ("SINIESTRO_FEC_REP", "SINIESTRO_SOL_SAI_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index TRANSACCION__IDXV4
--------------------------------------------------------

  CREATE UNIQUE INDEX "TRANSACCION__IDXV4" ON "TRANSACCION" ("REG_AMPARO_INTEGRAL_FEC_REP", "REG_AMP_INTE_SOL_SAI_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index TRANSACCION__IDXV5
--------------------------------------------------------

  CREATE UNIQUE INDEX "TRANSACCION__IDXV5" ON "TRANSACCION" ("REG_DANIO_FALT_FEC_REP", "REG_DAN_FAL_SOL_SAI_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index TRANSACCION__IDXV6
--------------------------------------------------------

  CREATE UNIQUE INDEX "TRANSACCION__IDXV6" ON "TRANSACCION" ("DESISTIMIENTO_FEC_REG", "DESIS_SOL_SAI_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index TRANSACCION__IDXV7
--------------------------------------------------------

  CREATE UNIQUE INDEX "TRANSACCION__IDXV7" ON "TRANSACCION" ("DESOCUPACION_FEC_REGI", "DESO_SOLICITUD_SAI_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index TRANSACCION__IDXV8
--------------------------------------------------------

  CREATE UNIQUE INDEX "TRANSACCION__IDXV8" ON "TRANSACCION" ("INGRESO_FEC_REGISTRO_ING", "ING_SOLICITUD_SAI_SOLICITUD") 
  ;
  
