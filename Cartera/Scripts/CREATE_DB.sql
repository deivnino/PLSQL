-- Generado por Oracle SQL Developer Data Modeler 4.2.0.932
--   en:        2017-10-05 15:39:38 COT
--   sitio:      Oracle Database 11g
--   tipo:      Oracle Database 11g



CREATE TABLE co532_asignacion (
    siniestro_cod_sin   NUMBER(5) NOT NULL,
    gestor_cod_gest     NUMBER(5) NOT NULL
);

COMMENT ON TABLE co532_asignacion IS
    'ASIGNACION-Tabla donde se almacena las asignaciones de los siniestros a los gestores
';

ALTER TABLE co532_asignacion ADD CONSTRAINT asignacion_pk PRIMARY KEY ( siniestro_cod_sin,gestor_cod_gest );

CREATE TABLE co532_atri_calif (
    cod_atrib              NUMBER(5) NOT NULL,
    nom_atri               VARCHAR2(50) NOT NULL,
    par_cal_abog_cod_par   NUMBER(2) NOT NULL
);

COMMENT ON TABLE co532_atri_calif IS
    'Atributo de calificacion de los abogados externos
';

ALTER TABLE co532_atri_calif ADD CONSTRAINT atributo_calificacion_pk PRIMARY KEY ( cod_atrib,par_cal_abog_cod_par );

CREATE TABLE co532_bita_sini (
    cod_bit_sin                      NUMBER(5) NOT NULL,
    siniestro_cod_sin                NUMBER(5) NOT NULL,
    gestor_cod_gest                  NUMBER(5) NOT NULL,
    motivo_exclusion_cod_mot_exc     NUMBER(5) NOT NULL,
    regla_distribucion_cod_reg_dis   NUMBER(5) NOT NULL,
    fecha_real                       DATE DEFAULT SYSDATE NOT NULL
);

COMMENT ON TABLE co532_bita_sini IS
    'BITACORA-SINIESTROTabla donde se almacena la informacion de los movimientos de los siniestros en el sistema';

ALTER TABLE co532_bita_sini ADD CONSTRAINT bitacora_siniestro_pk PRIMARY KEY ( cod_bit_sin );

CREATE TABLE co532_bita_sist (
    cod_bita      NUMBER(5) NOT NULL,
    tip_mov       VARCHAR2(15) NOT NULL,
    observacion   VARCHAR2(255) NOT NULL,
    fecha         DATE NOT NULL,
    usuario       VARCHAR2(50) NOT NULL,
    rol           VARCHAR2(250) NOT NULL,
    pagina        VARCHAR2(250) NOT NULL
);

ALTER TABLE co532_bita_sist ADD CHECK (
    tip_mov IN (
        'D','I','U'
    )
);

COMMENT ON TABLE co532_bita_sist IS
    'Tabla donde se almacena los movimientos de bitacora del sistemas';

COMMENT ON COLUMN co532_bita_sist.observacion IS
    'Observacion de la bitacora';

COMMENT ON COLUMN co532_bita_sist.usuario IS
    'Usuario que realizó el movimiento';

COMMENT ON COLUMN co532_bita_sist.rol IS
    'rol del usuario
';

COMMENT ON COLUMN co532_bita_sist.pagina IS
    'pagina o xhtml donde se ejecuto el proceso
';

ALTER TABLE co532_bita_sist ADD CONSTRAINT bitacora_sistema_pk PRIMARY KEY ( cod_bita );

CREATE TABLE co532_calif_abog (
    cod_calif_abo                   NUMBER(8) NOT NULL,
    fecha_vig                       DATE NOT NULL,
    gestor_cod_gest                 NUMBER(5) NOT NULL,
    localizacion_cod_loc            NUMBER(5) NOT NULL,
    estado                          NUMBER NOT NULL,
    atr_cal_cod_atrib               NUMBER(5) NOT NULL,
    atributo_calificacion_cod_par   NUMBER(2) NOT NULL,
    valor_cal                       NUMBER(5) NOT NULL
);

ALTER TABLE co532_calif_abog ADD CHECK (
    estado IN (
        0,1
    )
);

COMMENT ON TABLE co532_calif_abog IS
    'calificacion de los abogados';

ALTER TABLE co532_calif_abog ADD CONSTRAINT calificacion_abogado_pk PRIMARY KEY ( cod_calif_abo );

CREATE TABLE co532_comis_deta (
    cod_com_det        NUMBER(5) NOT NULL,
    gestor_cod_gest    NUMBER(5) NOT NULL,
    val_dist           NUMBER(15) NOT NULL,
    meta               NUMBER(15) NOT NULL,
    cumplimiento       NUMBER(15) NOT NULL,
    porc_cumpl         NUMBER(3) NOT NULL,
    comision           NUMBER(15) NOT NULL,
    comision_cod_loc   NUMBER(5) NOT NULL,
    comision_cod_per   NUMBER(5) NOT NULL,
    porc_castigo       NUMBER(3) NOT NULL
);

COMMENT ON TABLE co532_comis_deta IS
    'COMISION DETALLE-tabla donde se almacena la informacion de las comisiones liquidadas en el mes (por gestor)';

ALTER TABLE co532_comis_deta ADD CONSTRAINT comision_detalle_pk PRIMARY KEY ( cod_com_det );

CREATE TABLE co532_comision (
    localizacion_cod_loc   NUMBER(5) NOT NULL,
    periodo_cod_per        NUMBER(5) NOT NULL,
    cod_tip_gest           NUMBER NOT NULL
);

ALTER TABLE co532_comision ADD CHECK (
    cod_tip_gest IN (
        1,2,3
    )
);

COMMENT ON TABLE co532_comision IS
    'Tabla donde se almacena la informacion que indica una calculo de comisiones para la entidad';

ALTER TABLE co532_comision ADD CONSTRAINT comision_pk PRIMARY KEY ( localizacion_cod_loc,periodo_cod_per );

CREATE TABLE co532_det_hist_distr (
    cod_det_hist_dis       NUMBER(5) NOT NULL,
    his_dist_cod_his_dis   NUMBER(5) NOT NULL,
    siniestro_cod_sin      NUMBER(10) NOT NULL,
    sucursal               NUMBER(5) NOT NULL,
    tipo_prod              NUMBER(5) NOT NULL,
    subtip_prod            VARCHAR2(3) NOT NULL,
    est_sin                VARCHAR2(3) NOT NULL,
    est_pag                VARCHAR2(3) NOT NULL,
    tip_amp                VARCHAR2(3) NOT NULL,
    tip_pol                VARCHAR2(2) NOT NULL,
    area                   VARCHAR2(3) NOT NULL,
    ubicacion              VARCHAR2(3) NOT NULL,
    est_ali                NUMBER(5) NOT NULL,
    val_cap                NUMBER(15,2),
    val_col                NUMBER(15,2),
    cod_gest_cap           NUMBER(5),
    cod_gest_col           NUMBER(5),
    fecha_proceso          DATE,
    cod_tip_gest           NUMBER(1),
    tipo_excl              VARCHAR2(2),
    rang_fecha             VARCHAR2(5),
    rang_mora              VARCHAR2(5),
    rang_din               VARCHAR2(5),
    fech_ing               DATE,
    fecha_mora             DATE,
    fech_desoc             DATE,
    poliza                 NUMBER(20)
);

COMMENT ON TABLE co532_det_hist_distr IS
    'DETALLE HISTORIAL DISTRIBUCION - tabla donde se almacena la informacion detallada de loas distribuciones ejecutadas por el sistema'
;

COMMENT ON COLUMN co532_det_hist_distr.tipo_excl IS
    'tipo de exclusion';

COMMENT ON COLUMN co532_det_hist_distr.rang_fecha IS
    'Rango de fecha';

COMMENT ON COLUMN co532_det_hist_distr.rang_din IS
    'Rango de Dinero';

COMMENT ON COLUMN co532_det_hist_distr.fecha_mora IS
    'Fecha de mora del siniestro';

COMMENT ON COLUMN co532_det_hist_distr.fech_desoc IS
    'Fecha de desocupacion';

ALTER TABLE co532_det_hist_distr ADD CONSTRAINT det_hist_dist_pk PRIMARY KEY ( cod_det_hist_dis );

CREATE TABLE co532_det_llav_cump (
    por_cump                     NUMBER(3) NOT NULL,
    llave_cumplimiento_cod_loc   NUMBER(5) NOT NULL,
    llave_cumplimiento_cod_per   NUMBER(5) NOT NULL,
    cod_tip_ges                  NUMBER NOT NULL
);

ALTER TABLE co532_det_llav_cump ADD CHECK (
    cod_tip_ges IN (
        1,2,3
    )
);

COMMENT ON TABLE co532_det_llav_cump IS
    'DETALLE LLAVE CUMPLIMIENTO - Tabla donde se alamcena la informacion que compone una llave de cumplimiento,por sus tipos de gestio
'
;

ALTER TABLE co532_det_llav_cump ADD CONSTRAINT detalle_llave_cumplimiento_pk PRIMARY KEY ( llave_cumplimiento_cod_loc,llave_cumplimiento_cod_per
 );

CREATE TABLE co532_excl_cas (
    cod_exc_cas                      NUMBER(5) NOT NULL,
    regla_distribucion_cod_reg_dis   NUMBER(5) NOT NULL,
    siniestro_cod_sin                NUMBER(5) NOT NULL,
    nombre                           VARCHAR2(50) NOT NULL,
    tipo_excl                        VARCHAR2(3) NOT NULL
);

ALTER TABLE co532_excl_cas ADD CHECK (
    tipo_excl IN (
        'EE','EM'
    )
);

COMMENT ON TABLE co532_excl_cas IS
    'EXCLUSION CASO - tabla donde se lamacena la forma de exclusion inplementada por la regla de distribucion.';

ALTER TABLE co532_excl_cas ADD CONSTRAINT exclusion_caso_pk PRIMARY KEY ( cod_exc_cas );

CREATE TABLE co532_excl_est_fec (
    cod_exc_est_fec                  NUMBER(5) NOT NULL,
    regla_distribucion_cod_reg_dis   NUMBER(5) NOT NULL,
    est_sin                          NUMBER NOT NULL,
    fecha                            DATE NOT NULL
);

ALTER TABLE co532_excl_est_fec ADD CHECK (
    est_sin IN (
        1,2,3
    )
);

COMMENT ON TABLE co532_excl_est_fec IS
    'EXCLUSION ESTADO FECHA - tabla donde se lamacena la forma de exclusion inplementada por la regla de distribucion.';

ALTER TABLE co532_excl_est_fec ADD CONSTRAINT exclusion_estado_fecha_pk PRIMARY KEY ( cod_exc_est_fec );

CREATE TABLE co532_excl_fec (
    cod_exc_fec                      NUMBER(5) NOT NULL,
    regla_distribucion_cod_reg_dis   NUMBER(5) NOT NULL,
    dia                              NUMBER(2) NOT NULL,
    hora                             DATE NOT NULL
);

COMMENT ON TABLE co532_excl_fec IS
    'EXCLUSION FECHA - tabla donde se lamacena la forma de exclusion inplementada por la regla de distribucion.';

ALTER TABLE co532_excl_fec ADD CONSTRAINT exclusion_fecha_pk PRIMARY KEY ( cod_exc_fec );

CREATE TABLE co532_excl_mont (
    cod_exc_mon                      NUMBER(5) NOT NULL,
    regla_distribucion_cod_reg_dis   NUMBER(5) NOT NULL,
    minimo                           NUMBER(11) NOT NULL,
    maximo                           NUMBER(11) NOT NULL,
    tip_excl                         VARCHAR2(3) NOT NULL
);

ALTER TABLE co532_excl_mont ADD CHECK (
    tip_excl IN (
        'EE','EM'
    )
);

COMMENT ON TABLE co532_excl_mont IS
    'EXCLUSION RANGOS DE MONTOS - tabla donde se lamacena la forma de exclusion inplementada por la regla de distribucion.';

ALTER TABLE co532_excl_mont ADD CONSTRAINT exclusion_montos_pk PRIMARY KEY ( cod_exc_mon );

CREATE TABLE co532_excl_pol (
    cod_exc_pol                      NUMBER(5) NOT NULL,
    regla_distribucion_cod_reg_dis   NUMBER(5) NOT NULL,
    poliza_cod_pol                   NUMBER(5) NOT NULL,
    tip_exc                          VARCHAR2(3) NOT NULL
);

ALTER TABLE co532_excl_pol ADD CHECK (
    tip_exc IN (
        'EE','EM'
    )
);

COMMENT ON TABLE co532_excl_pol IS
    'EXCLUSION POLIZA - tabla donde se lamacena la forma de exclusion inplementada por la regla de distribucion.';

ALTER TABLE co532_excl_pol ADD CONSTRAINT exclusion_poliza_pk PRIMARY KEY ( cod_exc_pol );

/*CREATE TABLE co532_gest_loc (
    consecutivo            NUMBER(5) NOT NULL,
    gestor_cod_gest        NUMBER(5) NOT NULL,
    localizacion_cod_loc   NUMBER NOT NULL
);

COMMENT ON TABLE co532_gest_loc IS
    'GESTOR LOCALIZACION - tabla donde se almacena las ciudades o sucursales a las cuales pertenece un gestor';

ALTER TABLE co532_gest_loc ADD CONSTRAINT gestor_localizacion_pk PRIMARY KEY ( consecutivo );

CREATE TABLE co532_gestor (
    cod_gest         NUMBER(5) NOT NULL,
    cod_rei          VARCHAR2(6) NOT NULL,
    tipo_iden        VARCHAR2(4) NOT NULL,
    identificacion   VARCHAR2(20) NOT NULL,
    nombre           VARCHAR2(100) NOT NULL,
    email            VARCHAR2(50),
    est_gest         VARCHAR2(10) NOT NULL,
    cod_tip_gestor   NUMBER NOT NULL
);

ALTER TABLE co532_gestor ADD CHECK (
    est_gest IN (
        'A','I'
    )
);

COMMENT ON TABLE co532_gestor IS
    'tabla donde se almacena los gestores
';

COMMENT ON COLUMN co532_gestor.tipo_iden IS
    'tipo de identificacion del gestor';

COMMENT ON COLUMN co532_gestor.identificacion IS
    'Identificacion del gestor';

ALTER TABLE co532_gestor ADD CONSTRAINT gestor_pk PRIMARY KEY ( cod_gest );*/

CREATE TABLE co532_hist_distr (
    cod_his_dis                     NUMBER(5) NOT NULL,
    fecha                           DATE NOT NULL,
    tipo_distribucion_cod_tip_dis   NUMBER(5) NOT NULL,
    reg_dist                        NUMBER NOT NULL,
    descripcion                     VARCHAR2(200) NOT NULL,
    usuario                         VARCHAR2(50) NOT NULL
);

COMMENT ON TABLE co532_hist_distr IS
    'HISTORIAL DISTRIBUCION - Tabla donde se almacena historiales de distribucion realizadas en el sistema';

COMMENT ON COLUMN co532_hist_distr.tipo_distribucion_cod_tip_dis IS
    'Algoritmo de distribucion
';

COMMENT ON COLUMN co532_hist_distr.reg_dist IS
    'Regla de distribucion aplicada
';

ALTER TABLE co532_hist_distr ADD CONSTRAINT historico_distribucion_pk PRIMARY KEY ( cod_his_dis );

CREATE TABLE co532_inact_gest (
    cod_ina_ges       NUMBER(5) NOT NULL,
    gestor_cod_gest   NUMBER(5) NOT NULL,
    fec_ini           DATE NOT NULL,
    fec_fin           DATE NOT NULL,
    est_ant           VARCHAR2(10) NOT NULL,
    motivo            VARCHAR2(200) NOT NULL,
    estado_inac       NUMBER NOT NULL
);

ALTER TABLE co532_inact_gest ADD CHECK (
    est_ant IN (
        'A','I'
    )
);

ALTER TABLE co532_inact_gest ADD CHECK (
    estado_inac IN (
        0,1
    )
);

COMMENT ON TABLE co532_inact_gest IS
    'INACTIVACION GESTOR - Tabla donde se almacena las inactivaciones programadas para los gestores';

COMMENT ON COLUMN co532_inact_gest.est_ant IS
    'estado que tenia el gestor en el momento de la programacion de la inactivacion
';

COMMENT ON COLUMN co532_inact_gest.estado_inac IS
    'estado de la inactivacion... 

Activo= pendiente de ejecucion
Inactivo= ya se ejecuto la inactivacion
';

ALTER TABLE co532_inact_gest ADD CONSTRAINT inactivacion_gestor_pk PRIMARY KEY ( cod_ina_ges );

CREATE TABLE co532_liquidador (
    cod_liq                NUMBER(5) NOT NULL,
    porcentaje             NUMBER(3) NOT NULL,
    val_max_com_pag        NUMBER(15,2) NOT NULL,
    val_tot_car_are        NUMBER(15,2) NOT NULL,
    pro_val_met_glo        NUMBER(15,2) NOT NULL,
    pro_met_mes_car        NUMBER(15,2),
    pro_met_mes_jur        NUMBER(15,2),
    cod_tip_gest           NUMBER NOT NULL,
    periodo_cod_per        NUMBER(5) NOT NULL,
    localizacion_cod_loc   NUMBER NOT NULL
);

ALTER TABLE co532_liquidador ADD CHECK (
    cod_tip_gest IN (
        1,2,3
    )
);

COMMENT ON TABLE co532_liquidador IS
    'Tabla donde se almacena la informacion de liquidador 
';

ALTER TABLE co532_liquidador ADD CONSTRAINT liquidador_pk PRIMARY KEY ( cod_liq );

CREATE TABLE co532_llav_cumpl (
    localizacion_cod_loc   NUMBER(5) NOT NULL,
    periodo_cod_per        NUMBER(5) NOT NULL,
    por_castigo            NUMBER(3) NOT NULL
);

COMMENT ON TABLE co532_llav_cumpl IS
    'LLAVE CUMPLIMIENTO - Tabla donde se almacena las llaves de cumplimiento implementada en los pagos de comisiones';

ALTER TABLE co532_llav_cumpl ADD CONSTRAINT llave_cumplimiento_pk PRIMARY KEY ( localizacion_cod_loc,periodo_cod_per );

/*CREATE TABLE co532_localizacion (
    cod_loc            NUMBER NOT NULL,
    nom_loc            VARCHAR2(50) NOT NULL,
    tip_loc            NUMBER(2) NOT NULL,
    variable_tip_var   NUMBER,
    variable_cod_var   VARCHAR2(50)
);

ALTER TABLE co532_localizacion ADD CHECK (
    variable_tip_var IN (
        1,2,3,4,5,6,7,8,9,10,11,12
    )
);

COMMENT ON TABLE co532_localizacion IS
    'Tabla donde se almacena las localizaciones posibles a implementar en el sistem ciudad/surcursal';

COMMENT ON COLUMN co532_localizacion.cod_loc IS
    'Copnsecutivo.';

COMMENT ON COLUMN co532_localizacion.variable_tip_var IS
    'Tipo de referencia';

COMMENT ON COLUMN co532_localizacion.variable_cod_var IS
    'Codigo de la variable Sucursal';

ALTER TABLE co532_localizacion ADD CONSTRAINT localizacion_pk PRIMARY KEY ( cod_loc );*/

CREATE TABLE co532_meta_glob (
    cod_met_glo    NUMBER(5) NOT NULL,
    ani_vig        NUMBER(4) NOT NULL,
    total          NUMBER(15,2) NOT NULL,
    "Select"       VARCHAR2(250) NOT NULL,
    cod_tip_gest   NUMBER NOT NULL
);

ALTER TABLE co532_meta_glob ADD CHECK (
    cod_tip_gest IN (
        1,2,3
    )
);

COMMENT ON TABLE co532_meta_glob IS
    'META GLOBAL - Tabla donde se almacena la informacion de las metas globales
';

ALTER TABLE co532_meta_glob ADD CONSTRAINT meta_global_pk PRIMARY KEY ( cod_met_glo );

CREATE TABLE co532_meta_glob_det (
    cod_met_glo_det           NUMBER(5) NOT NULL,
    meta_global_cod_met_glo   NUMBER(5) NOT NULL,
    periodo_cod_per           NUMBER(5) NOT NULL,
    valor                     NUMBER(15,2) NOT NULL,
    localizacion_cod_loc      NUMBER(5) NOT NULL
);

COMMENT ON TABLE co532_meta_glob_det IS
    'META GLOBAL DETALLE - Tabla donde se almacena el detalle de la meta global por sucursal y periodo';

CREATE UNIQUE INDEX meta_global_detalle__idx ON
    co532_meta_glob_det ( localizacion_cod_loc ASC );

CREATE UNIQUE INDEX meta_global_detalle__idxv1 ON
    co532_meta_glob_det ( periodo_cod_per ASC );

ALTER TABLE co532_meta_glob_det ADD CONSTRAINT meta_global_detalle_pk PRIMARY KEY ( cod_met_glo_det );

CREATE TABLE co532_mot_excl (
    cod_mot_exc   NUMBER(5) NOT NULL,
    nom_mot_exc   VARCHAR2(60) NOT NULL
);

COMMENT ON TABLE co532_mot_excl IS
    'MOTIVO EXCLUSION - Tabla donde se almacena los motivos de exclusion';

ALTER TABLE co532_mot_excl ADD CONSTRAINT motivo_exclusion_pk PRIMARY KEY ( cod_mot_exc );

CREATE TABLE co532_not_tip_gest (
    cod_noti_gest           NUMBER(5) NOT NULL,
    notificacion_cod_noti   NUMBER(5) NOT NULL,
    cod_tip_ges             NUMBER NOT NULL
);

ALTER TABLE co532_not_tip_gest ADD CHECK (
    cod_tip_ges IN (
        1,2
    )
);

COMMENT ON TABLE co532_not_tip_gest IS
    'NOTIFICACION TIPO GESTOR - Tabla donde se almacena las notificaciones usadas por tipos de gestor';

ALTER TABLE co532_not_tip_gest ADD CONSTRAINT notificacion_tipo_gestor_pk PRIMARY KEY ( cod_noti_gest );

CREATE TABLE co532_notificacion (
    cod_noti   NUMBER(5) NOT NULL
);

COMMENT ON TABLE co532_notificacion IS
    'Tabla donde se almacena las platillas implementadas para las notificaciones';

ALTER TABLE co532_notificacion ADD CONSTRAINT notificacion_pk PRIMARY KEY ( cod_noti );

CREATE TABLE co532_pago (
    cod_pag             NUMBER(5) NOT NULL,
    valor               NUMBER(15,2) NOT NULL,
    cod_tip_ges         NUMBER NOT NULL,
    gestor_cod_gest     NUMBER(5) NOT NULL,
    siniestro_cod_sin   NUMBER(10) NOT NULL
);

ALTER TABLE co532_pago ADD CHECK (
    cod_tip_ges IN (
        1,2,3
    )
);

COMMENT ON TABLE co532_pago IS
    'Tabla donde se almacena los pagos realizados a los siniestros';

ALTER TABLE co532_pago ADD CONSTRAINT pago_pk PRIMARY KEY ( cod_pag );

CREATE TABLE co532_par_cal_abog (
    cod_par     NUMBER(2) NOT NULL,
    nom_par     VARCHAR2(80) NOT NULL,
    porc_peso   NUMBER(3) NOT NULL
);

COMMENT ON TABLE co532_par_cal_abog IS
    'PARAMETRO CALIFICACION PESO - Tabla donde se almacena los parametros de calificacion de abogados externos por porcentaje';

ALTER TABLE co532_par_cal_abog ADD CONSTRAINT pao_cal_abo_pk PRIMARY KEY ( cod_par );

CREATE TABLE co532_periodo (
    cod_per   NUMBER(5) NOT NULL,
    mes       VARCHAR2(10) NOT NULL,
    anio      VARCHAR2(4) NOT NULL
);

COMMENT ON TABLE co532_periodo IS
    'Tabla donde se almacena los periodos implementados en el sistema';

ALTER TABLE co532_periodo ADD CONSTRAINT periodo_pk PRIMARY KEY ( cod_per );

CREATE TABLE co532_poliza (
    cod_pol   NUMBER(5) NOT NULL,
    nombre    VARCHAR2(50) NOT NULL
);

COMMENT ON TABLE co532_poliza IS
    'Tabla donde se almacena las polizas existentes en el sistema';

ALTER TABLE co532_poliza ADD CONSTRAINT poliza_pk PRIMARY KEY ( cod_pol );

CREATE TABLE co532_rang_agru (
    cod_ran_agr   NUMBER(5) NOT NULL,
    tip_ran       NUMBER NOT NULL,
    nom_ran       VARCHAR2(15) NOT NULL,
    val_ini       NUMBER(15,2) NOT NULL,
    val_fin       NUMBER(15,2) NOT NULL
);

ALTER TABLE co532_rang_agru ADD CHECK (
    tip_ran IN (
        0,1,2,3
    )
);

COMMENT ON TABLE co532_rang_agru IS
    'RANGO AGRUPACION - Tabla donde se almacena los rangos de agrupaciones creados en el sistema';

ALTER TABLE co532_rang_agru ADD CONSTRAINT rango_agrupacion_pk PRIMARY KEY ( cod_ran_agr );

CREATE TABLE co532_rang_liqu (
    cod_ran_liq          NUMBER(5) NOT NULL,
    nom_rang             VARCHAR2(50) NOT NULL,
    por_cump             NUMBER(3) NOT NULL,
    porc_com             NUMBER(3) NOT NULL,
    val_cump             NUMBER(15,2) NOT NULL,
    val_com              NUMBER(15,2) NOT NULL,
    area                 NUMBER(5) NOT NULL,
    cod_tip_gest         NUMBER NOT NULL,
    liquidador_cod_liq   NUMBER(5) NOT NULL
);

ALTER TABLE co532_rang_liqu ADD CHECK (
    cod_tip_gest IN (
        1,2,3
    )
);

COMMENT ON TABLE co532_rang_liqu IS
    'RANGO LIQUIDADOR - Tabla donde se almacena los rangos de liquidacion que se aplican por gestor y sus cumplimientos de gestion';

ALTER TABLE co532_rang_liqu ADD CONSTRAINT rango_liquidacion_pk PRIMARY KEY ( cod_ran_liq );

CREATE TABLE co532_re_cal_met_glo (
    cod_rec                   NUMBER(5) NOT NULL,
    meta_global_cod_met_glo   NUMBER(5) NOT NULL,
    periodo_cod_per           NUMBER(5) NOT NULL
);

COMMENT ON TABLE co532_re_cal_met_glo IS
    'RE CALCULO META GLOBAL - Tabla donde se almacena los recalculos de las comisiones mensualmente en caso de que no se cumpla las metas'
;

ALTER TABLE co532_re_cal_met_glo ADD CONSTRAINT re_calculo_meta_global_pk PRIMARY KEY ( cod_rec );

CREATE TABLE co532_reg_dist (
    cod_reg_dis                     NUMBER(5) NOT NULL,
    tipo_distribucion_cod_tip_dis   NUMBER(5) NOT NULL,
    tip_gest                        VARCHAR2(140) NOT NULL,
    per_reg                         VARCHAR2(4) NOT NULL,
    mes_per                         NUMBER(2),
    tip_rec                         VARCHAR2(4) NOT NULL,
    estado                          NUMBER NOT NULL,
    prioridad                       NUMBER(2) NOT NULL
);

ALTER TABLE co532_reg_dist ADD CHECK (
    per_reg IN (
        'CES','ESN','ESV'
    )
);

ALTER TABLE co532_reg_dist ADD CHECK (
    tip_rec IN (
        'C','K','KC'
    )
);

ALTER TABLE co532_reg_dist ADD CHECK (
    estado IN (
        0,1
    )
);

COMMENT ON TABLE co532_reg_dist IS
    'REGLA DISTRIBUCION - Tabla donde se almacena,las reglas de distribucion parametrizadas en el sistema';

ALTER TABLE co532_reg_dist ADD CONSTRAINT regla_distribucion_pk PRIMARY KEY ( cod_reg_dis );

/*CREATE TABLE co532_siniestro (
    cod_sin                          NUMBER(10) NOT NULL,
    sucursal                         NUMBER(5) NOT NULL,
    tip_prod                         NUMBER(5) NOT NULL,
    subti_prod                       VARCHAR2(3) NOT NULL,
    est_sin                          VARCHAR2(3) NOT NULL,
    est_pag                          VARCHAR2(3) NOT NULL,
    tip_amp                          VARCHAR2(3) NOT NULL,
    tip_pol                          VARCHAR2(2) NOT NULL,
    area                             VARCHAR2(3) NOT NULL,
    ubicacion                        VARCHAR2(3) NOT NULL,
    est_ali                          NUMBER(5) NOT NULL,
    val_cap                          NUMBER(15,2),
    val_col                          NUMBER(15,2),
    motivo_exclusion_cod_mot_exc     NUMBER(5),
    fecha_proceso                    DATE,
    cod_tip_ges                      NUMBER NOT NULL,
    tip_exc                          VARCHAR2(2),
    rang_fecha                       VARCHAR2(5),
    rang_mora                        VARCHAR2(5),
    rang_din                         VARCHAR2(5),
    fecha_ing                        DATE,
    fecha_mora                       DATE,
    regla_distribucion_cod_reg_dis   NUMBER(5),
    fech_desoc                       DATE,
    poliza                           NUMBER(20)
);

ALTER TABLE co532_siniestro ADD CHECK (
    cod_tip_ges IN (
        1,2,3
    )
);

COMMENT ON TABLE co532_siniestro IS
    'Tabla donde se almacena la informacion de los siniestros existentes en el sistema';

COMMENT ON COLUMN co532_siniestro.cod_tip_ges IS
    'TIPO DE GESTION DEL SINIESTRO';

COMMENT ON COLUMN co532_siniestro.tip_exc IS
    'Tipo de exclusion';

COMMENT ON COLUMN co532_siniestro.rang_fecha IS
    'Rango De fecha del siniestro cuando se distribuye';

COMMENT ON COLUMN co532_siniestro.fecha_ing IS
    'Fecha de ingreso siniestro
';

COMMENT ON COLUMN co532_siniestro.fecha_mora IS
    'fecha Mora Siniestro';

COMMENT ON COLUMN co532_siniestro.fech_desoc IS
    'Fecha de desocupacion';

CREATE UNIQUE INDEX siniestro__idx ON
    co532_siniestro ( motivo_exclusion_cod_mot_exc ASC );

ALTER TABLE co532_siniestro ADD CONSTRAINT siniestro_pk PRIMARY KEY ( cod_sin );*/

CREATE TABLE co532_tip_distr (
    cod_tip_dis   NUMBER(5) NOT NULL,
    nom_tip_dis   VARCHAR2(100) NOT NULL,
    tip_agru      VARCHAR2(10) NOT NULL,
    tip_ran       NUMBER,
    estado        NUMBER NOT NULL
);

ALTER TABLE co532_tip_distr ADD CHECK (
    tip_ran IN (
        0,1,2,3
    )
);

ALTER TABLE co532_tip_distr ADD CHECK (
    estado IN (
        0,1
    )
);

COMMENT ON TABLE co532_tip_distr IS
    'TIPO DISTRIBUCION - Tabla donde se almacena los tipos de distribucion parametrizados';

COMMENT ON COLUMN co532_tip_distr.tip_ran IS
    'tipo de rango';

ALTER TABLE co532_tip_distr ADD CONSTRAINT tipo_distribucion_pk PRIMARY KEY ( cod_tip_dis );

CREATE TABLE co532_var_regl (
    regla_distribucion_cod_reg_dis   NUMBER(5) NOT NULL,
    cod_var_reg                      NUMBER(5) NOT NULL,
    variable_tip_var                 NUMBER NOT NULL,
    variable_cod_var                 VARCHAR2(50) NOT NULL
);

ALTER TABLE co532_var_regl ADD CHECK (
    variable_tip_var IN (
        1,2,3,4,5,6,7,8,9,10,11,12
    )
);

COMMENT ON TABLE co532_var_regl IS
    'VARIABLE REGLA - Tabla donde se almacena las variables implementadas en la regla de distribucion';

ALTER TABLE co532_var_regl ADD CONSTRAINT variable_regla_pk PRIMARY KEY ( cod_var_reg,regla_distribucion_cod_reg_dis );

/*CREATE TABLE co532_variable (
    tip_var       NUMBER NOT NULL,
    cod_var       VARCHAR2(50) NOT NULL,
    val_var       VARCHAR2(50) NOT NULL,
    estado        NUMBER NOT NULL,
    nom_cul_sai   VARCHAR2(100) NOT NULL,
    gestion       VARCHAR2(1) NOT NULL
);

ALTER TABLE co532_variable ADD CHECK (
    tip_var IN (
        1,2,3,4,5,6,7,8,9,10,11,12
    )
);

ALTER TABLE co532_variable ADD CHECK (
    estado IN (
        0,1
    )
);

COMMENT ON TABLE co532_variable IS
    'Tabla donde se almacena las variables existentes y sus respectivos valores';

COMMENT ON COLUMN co532_variable.cod_var IS
    'Codigo de la variable
';

COMMENT ON COLUMN co532_variable.gestion IS
    'Gestionada o no gestionada
';

ALTER TABLE co532_variable ADD CONSTRAINT variable_pk PRIMARY KEY ( tip_var,cod_var );*/

ALTER TABLE co532_asignacion ADD CONSTRAINT asignacion_gestor_fk FOREIGN KEY ( gestor_cod_gest )
    REFERENCES co532_gestor ( cod_gest );

ALTER TABLE co532_asignacion ADD CONSTRAINT asignacion_siniestro_fk FOREIGN KEY ( siniestro_cod_sin )
    REFERENCES co532_siniestro ( cod_sin );

ALTER TABLE co532_atri_calif ADD CONSTRAINT atro_cal_par_cali_abo_fk FOREIGN KEY ( par_cal_abog_cod_par )
    REFERENCES co532_par_cal_abog ( cod_par );

ALTER TABLE co532_bita_sini ADD CONSTRAINT bit_sin_mo_exc_fk FOREIGN KEY ( motivo_exclusion_cod_mot_exc )
    REFERENCES co532_mot_excl ( cod_mot_exc );

ALTER TABLE co532_bita_sini ADD CONSTRAINT bit_sin_sin_fk FOREIGN KEY ( siniestro_cod_sin )
    REFERENCES co532_siniestro ( cod_sin );

ALTER TABLE co532_bita_sini ADD CONSTRAINT bit_sine_reg_dis_fk FOREIGN KEY ( regla_distribucion_cod_reg_dis )
    REFERENCES co532_reg_dist ( cod_reg_dis );

ALTER TABLE co532_bita_sini ADD CONSTRAINT bitacora_siniestro_gestor_fk FOREIGN KEY ( gestor_cod_gest )
    REFERENCES co532_gestor ( cod_gest );

ALTER TABLE co532_calif_abog ADD CONSTRAINT cal_abog_atr_cali_fk FOREIGN KEY ( atr_cal_cod_atrib,atributo_calificacion_cod_par )
    REFERENCES co532_atri_calif ( cod_atrib,par_cal_abog_cod_par );

ALTER TABLE co532_calif_abog ADD CONSTRAINT cali_abo_loc_fk FOREIGN KEY ( localizacion_cod_loc )
    REFERENCES co532_localizacion ( cod_loc );

ALTER TABLE co532_calif_abog ADD CONSTRAINT calificacion_abogado_gestor_fk FOREIGN KEY ( gestor_cod_gest )
    REFERENCES co532_gestor ( cod_gest );

ALTER TABLE co532_comis_deta ADD CONSTRAINT comision_detalle_comision_fk FOREIGN KEY ( comision_cod_loc,comision_cod_per )
    REFERENCES co532_comision ( localizacion_cod_loc,periodo_cod_per );

ALTER TABLE co532_comis_deta ADD CONSTRAINT comision_detalle_gestor_fk FOREIGN KEY ( gestor_cod_gest )
    REFERENCES co532_gestor ( cod_gest );

ALTER TABLE co532_comision ADD CONSTRAINT comision_localizacion_fk FOREIGN KEY ( localizacion_cod_loc )
    REFERENCES co532_localizacion ( cod_loc );

ALTER TABLE co532_comision ADD CONSTRAINT comision_periodo_fk FOREIGN KEY ( periodo_cod_per )
    REFERENCES co532_periodo ( cod_per );

ALTER TABLE co532_det_hist_distr ADD CONSTRAINT det_his_dis_sin_fk FOREIGN KEY ( siniestro_cod_sin )
    REFERENCES co532_siniestro ( cod_sin );

ALTER TABLE co532_det_hist_distr ADD CONSTRAINT det_hist_dist_his_dis_fk FOREIGN KEY ( his_dist_cod_his_dis )
    REFERENCES co532_hist_distr ( cod_his_dis );

ALTER TABLE co532_det_llav_cump ADD CONSTRAINT det_llav_cto_lla_cump_fk FOREIGN KEY ( llave_cumplimiento_cod_loc,llave_cumplimiento_cod_per
 )
    REFERENCES co532_llav_cumpl ( localizacion_cod_loc,periodo_cod_per );

ALTER TABLE co532_det_hist_distr ADD CONSTRAINT dete_his_dist_gest_fk FOREIGN KEY ( cod_gest_cap )
    REFERENCES co532_gestor ( cod_gest );

ALTER TABLE co532_excl_pol ADD CONSTRAINT exc_pol_reg_dis_fk FOREIGN KEY ( regla_distribucion_cod_reg_dis )
    REFERENCES co532_reg_dist ( cod_reg_dis );

ALTER TABLE co532_excl_cas ADD CONSTRAINT excl_ca_re_dis_fk FOREIGN KEY ( regla_distribucion_cod_reg_dis )
    REFERENCES co532_reg_dist ( cod_reg_dis );

ALTER TABLE co532_excl_est_fec ADD CONSTRAINT excl_est_fech_a_d_fk FOREIGN KEY ( regla_distribucion_cod_reg_dis )
    REFERENCES co532_reg_dist ( cod_reg_dis );

ALTER TABLE co532_excl_fec ADD CONSTRAINT excl_fec_reg_dis_fk FOREIGN KEY ( regla_distribucion_cod_reg_dis )
    REFERENCES co532_reg_dist ( cod_reg_dis );

ALTER TABLE co532_excl_mont ADD CONSTRAINT excl_mon_reg_dist_fk FOREIGN KEY ( regla_distribucion_cod_reg_dis )
    REFERENCES co532_reg_dist ( cod_reg_dis );

ALTER TABLE co532_excl_cas ADD CONSTRAINT exclusion_caso_siniestro_fk FOREIGN KEY ( siniestro_cod_sin )
    REFERENCES co532_siniestro ( cod_sin );

ALTER TABLE co532_excl_pol ADD CONSTRAINT exclusion_poliza_poliza_fk FOREIGN KEY ( poliza_cod_pol )
    REFERENCES co532_poliza ( cod_pol );

/*ALTER TABLE co532_gest_loc ADD CONSTRAINT gest_loc_localizacion_fk FOREIGN KEY ( localizacion_cod_loc )
    REFERENCES co532_localizacion ( cod_loc );*/

ALTER TABLE co532_gest_loc ADD CONSTRAINT gestor_localizacion_gestor_fk FOREIGN KEY ( gestor_cod_gest )
    REFERENCES co532_gestor ( cod_gest );

ALTER TABLE co532_hist_distr ADD CONSTRAINT hist_dis_tip_dist_fk FOREIGN KEY ( tipo_distribucion_cod_tip_dis )
    REFERENCES co532_tip_distr ( cod_tip_dis );

ALTER TABLE co532_inact_gest ADD CONSTRAINT inactivacion_gestor_gestor_fk FOREIGN KEY ( gestor_cod_gest )
    REFERENCES co532_gestor ( cod_gest );

ALTER TABLE co532_liquidador ADD CONSTRAINT liquidador_localizacion_fk FOREIGN KEY ( localizacion_cod_loc )
    REFERENCES co532_localizacion ( cod_loc );

ALTER TABLE co532_liquidador ADD CONSTRAINT liquidador_periodo_fk FOREIGN KEY ( periodo_cod_per )
    REFERENCES co532_periodo ( cod_per );

ALTER TABLE co532_llav_cumpl ADD CONSTRAINT llav_cumo_loc_fk FOREIGN KEY ( localizacion_cod_loc )
    REFERENCES co532_localizacion ( cod_loc );

ALTER TABLE co532_llav_cumpl ADD CONSTRAINT llave_cumplimiento_periodo_fk FOREIGN KEY ( periodo_cod_per )
    REFERENCES co532_periodo ( cod_per );

ALTER TABLE co532_localizacion ADD CONSTRAINT localizacion_variable_fk FOREIGN KEY ( variable_tip_var,variable_cod_var )
    REFERENCES co532_variable ( tip_var,cod_var );

ALTER TABLE co532_meta_glob_det ADD CONSTRAINT met_glo_dete_me_gll_fk FOREIGN KEY ( meta_global_cod_met_glo )
    REFERENCES co532_meta_glob ( cod_met_glo );

ALTER TABLE co532_meta_glob_det ADD CONSTRAINT met_glol_det_loc_fk FOREIGN KEY ( localizacion_cod_loc )
    REFERENCES co532_localizacion ( cod_loc );

ALTER TABLE co532_meta_glob_det ADD CONSTRAINT meta_global_detalle_periodo_fk FOREIGN KEY ( periodo_cod_per )
    REFERENCES co532_periodo ( cod_per );

ALTER TABLE co532_not_tip_gest ADD CONSTRAINT nottip_ges_noti_fk FOREIGN KEY ( notificacion_cod_noti )
    REFERENCES co532_notificacion ( cod_noti );

ALTER TABLE co532_pago ADD CONSTRAINT pago_gestor_fk FOREIGN KEY ( gestor_cod_gest )
    REFERENCES co532_gestor ( cod_gest );

ALTER TABLE co532_pago ADD CONSTRAINT pago_siniestro_fk FOREIGN KEY ( siniestro_cod_sin )
    REFERENCES co532_siniestro ( cod_sin );

ALTER TABLE co532_rang_liqu ADD CONSTRAINT ra_lin_lir_fk FOREIGN KEY ( liquidador_cod_liq )
    REFERENCES co532_liquidador ( cod_liq );

ALTER TABLE co532_re_cal_met_glo ADD CONSTRAINT re_cal_mea_gll_m_global_fk FOREIGN KEY ( meta_global_cod_met_glo )
    REFERENCES co532_meta_glob ( cod_met_glo );

ALTER TABLE co532_re_cal_met_glo ADD CONSTRAINT re_cal_met_glol_per_fk FOREIGN KEY ( periodo_cod_per )
    REFERENCES co532_periodo ( cod_per );

ALTER TABLE co532_reg_dist ADD CONSTRAINT reg_dist_ti_dist_fk FOREIGN KEY ( tipo_distribucion_cod_tip_dis )
    REFERENCES co532_tip_distr ( cod_tip_dis );

ALTER TABLE co532_siniestro ADD CONSTRAINT siniestro_motivo_exclusion_fk FOREIGN KEY ( motivo_exclusion_cod_mot_exc )
    REFERENCES co532_mot_excl ( cod_mot_exc );

ALTER TABLE co532_siniestro ADD CONSTRAINT siniestro_reg_dist_fk FOREIGN KEY ( regla_distribucion_cod_reg_dis )
    REFERENCES co532_reg_dist ( cod_reg_dis );

ALTER TABLE co532_var_regl ADD CONSTRAINT var_reg_regdisn_fk FOREIGN KEY ( regla_distribucion_cod_reg_dis )
    REFERENCES co532_reg_dist ( cod_reg_dis );

ALTER TABLE co532_var_regl ADD CONSTRAINT variable_regla_variable_fk FOREIGN KEY ( variable_tip_var,variable_cod_var )
    REFERENCES co532_variable ( tip_var,cod_var );
-- Informe de Resumen de Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                            38
-- CREATE INDEX                             3
-- ALTER TABLE                            113
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          4
-- CREATE MATERIALIZED VIEW                 0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
