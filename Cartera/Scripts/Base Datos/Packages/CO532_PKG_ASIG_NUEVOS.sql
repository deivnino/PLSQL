CREATE OR REPLACE PACKAGE ADMSISA.CO532_pkg_asig_nuevos IS

procedure prc_distribuir_linea (p_id_siniestro IN NUMBER, p_prueba in NUMBER);

PROCEDURE prc_marcar_excl_sin (p_id_siniestro IN NUMBER, p_cod_excl IN NUMBER);
 

FUNCTION fct_variables_sin (p_tip_var IN NUMBER, p_val_var IN STRING) RETURN NUMBER;

FUNCTION fct_ident_regla (p_id_siniestro IN NUMBER)      RETURN NUMBER;

FUNCTION fct_valida_gestores ( p_rd IN NUMBER ) RETURN STRING;

Function fct_exclusiones (p_rd IN NUMBER) Return NUMBER;

PROCEDURE PRC_aplica_asignacion ( p_rd IN NUMBER );

PROCEDURE prc_auditoria (p_cod_hist IN NUMBER, p_paso in NUMBER, p_funcion in VARCHAR , p_observacion in VARCHAR  );
  

END CO532_pkg_asig_nuevos; 
/



CREATE OR REPLACE PACKAGE BODY ADMSISA.co532_pkg_asig_nuevos
IS
   /** VARIABLES  GENERALES PARA LA DISTRIBUCION EN LINEA DE LOS SINIESTROS. **/
   v_rd               NUMBER (10)     := NULL;
   /*Regla de Distribucion a aplicar*/
   v_gestores         STRING (30)     := NULL;
   /*Variable que identifica si existen gestores*/
   v_exclusiones      NUMBER (2)      := NULL;
   /*VVariable que identifica si se excluyo o no el siniestro*/
   v_gestor           NUMBER (2)      := NULL;
   v_porcentaje       NUMBER (30, 10) := NULL;
   v_rango_din        STRING (10)     := NULL;
   v_tipo_dist        NUMBER          := NULL;
   /*tipo de distribucion (algoritmo) que aplica para la asignacion*/
   v_ok               NUMBER (1)      := NULL;
   v_cod_gest         NUMBER          := NULL;          /*Codigo del gestor*/
   v_tip_excl         STRING (10)     := NULL;          /*Codigo del gestor*/
   v_cod_hist         NUMBER (10)     := NULL;
   /**Valores del siniestro que permitiran identificar l regla de distribucion del Siniestro**/
   v_cod_sin          NUMBER (2)      := NULL;
   v_sucursal_sin     VARCHAR (10)    := NULL;     /*Sucursal del Siniestro*/
   v_tip_prod_sin     NUMBER (2)      := NULL;
   /*Tipo de producto del Siniestro*/
   v_subti_prod_sin   VARCHAR (5)     := NULL;     /*Subtipo  del Siniestro*/
   v_est_sin          VARCHAR (5)     := NULL;
   /*Estado siniestro del Siniestro*/
   v_est_pago_sin     VARCHAR (5)     := NULL;
   /*Estado del pago del Siniestro*/
   v_tipo_amp_sin     VARCHAR (5)     := NULL;  /*Tipo amparo del Siniestro*/
   v_tip_pol_sin      VARCHAR (5)     := NULL;
   /*Tipo de poliza del Siniestro*/
   v_area_sin         VARCHAR (5)     := NULL;         /*Area del Siniestro*/
   v_ubicacion_sin    VARCHAR (5)     := NULL;    /*Ubicacion del Siniestro*/
   v_est_ali_sin      VARCHAR (5)     := NULL;
   /*Estado Alistamiento del Siniestro*/
   v_val_cap_sin      NUMBER (20, 4)  := NULL;
   /*Valor del siniestro en CAPITAL*/
   v_val_col_sin      NUMBER (20, 4)  := NULL;
   /*Valor del siniestro en CAPITAL*/
   v_fecha_ing_sin    DATE            := TRUNC (SYSDATE);
   v_fecha_mora       DATE            := NULL;
   
   v_error            VARCHAR2(10);
   v_desc_error       VARCHAR2(100);             

   /***************************************************************************
    NOMBRE:       prc_distribuir_linea
    DESCRIPCION: Permite hacer la distribucion de los siniestros que ingresan en linea .
    PARAMETROS DE ENTRADA: - p_consecutivo_proceso:        Consecutivo del proceso automatico
    PARAMETROS DE SALIDA: TRUE/FALSE
    MODIFICACIONES :
    VERSION      FECHA       AUTOR          REQUERIMIENTO          DESCRIPCION DEL CAMBIO
    ---------------------------------------------------------------------------------------------
    1.0      15/09/2017    Jmurillo         PF 21.1                      Creacion.
    ******************************************************************************/
   PROCEDURE prc_distribuir_linea (
      p_id_siniestro   IN   NUMBER,
      p_prueba         IN   NUMBER
   )
   IS
   BEGIN
      v_cod_sin := p_id_siniestro;
      v_cod_hist:=co532_sec_hist_distr.NEXTVAL;

      INSERT INTO co532_hist_distr
                  (cod_his_dis, fecha, tipo_distribucion_cod_tip_dis,
                   reg_dist, descripcion, usuario
                  )
           VALUES (v_cod_hist, SYSDATE, 1,
                   1, 'SINIESTRO NUEVO', USER
                  );

      prc_auditoria
                  (v_cod_hist,
                   1,
                   'Inicio Proceso',
                      'Inserta encabezado del Historico distribuci?n numero -'
                   || v_cod_hist
                  );

      SELECT sucursal, tip_prod, subti_prod, est_sin,
             est_pag, tip_amp, tip_pol, area,
             ubicacion, est_ali, val_cap, fecha_ing,
             val_col, fecha_mora
        INTO v_sucursal_sin, v_tip_prod_sin, v_subti_prod_sin, v_est_sin,
             v_est_pago_sin, v_tipo_amp_sin, v_tip_pol_sin, v_area_sin,
             v_ubicacion_sin, v_est_ali_sin, v_val_cap_sin, v_fecha_ing_sin,
             v_val_col_sin, v_fecha_mora
        FROM co532_siniestro
       WHERE cod_sin = p_id_siniestro;

      prc_auditoria (v_cod_hist,
                        2,
                        'Datos Siniestro',
                        'Consulta datos del siniestro -' || v_cod_sin
                       );
      prc_auditoria
            (v_cod_hist,
             3,
             'Identifica Regla a Usar',
                'Valida dato x dato siniestro contra variables de reglas, siniestro -'
             || v_cod_sin
            );
      v_rd := fct_ident_regla (p_id_siniestro);

      IF v_rd = -1
      THEN
         prc_auditoria (v_cod_hist,
                           3.4,
                           'NO HAY REGLA',
                           'SALE DEL PROCESO'
                          );
         prc_marcar_excl_sin (p_id_siniestro, 1);
         RETURN;
      END IF;

      prc_auditoria
            (v_cod_hist,
             4,
             'Valida Gestores',
             'Valida si existen gestores para asignar de acuerdo a la regla distribucion'
            );
      v_gestores := fct_valida_gestores (v_rd);

      IF v_gestores = 0
      THEN
         prc_auditoria (v_cod_hist,
                           4.1,
                           'NO HAY GESTORES',
                           'SALE DEL PROCESO'
                          );
         prc_marcar_excl_sin (p_id_siniestro, 2);
         RETURN;
      END IF;

      prc_auditoria
             (v_cod_hist,
              5,
              'Valida exclusiones',
                 'Valida las exclusiones definidas en la regla distribucion -'
              || v_rd
             );
      v_exclusiones := fct_exclusiones (v_rd);

      IF v_exclusiones > 0
      THEN
         prc_auditoria (v_cod_hist,
                           5.3,
                           'EXCLUIDO',
                           'SALE DEL PROCESO'
                          );
         prc_marcar_excl_sin (p_id_siniestro, v_exclusiones);
         RETURN;
      END IF;

      prc_auditoria (v_cod_hist,
                        6,
                        'Asignacion',
                        'Inicia la asignacion'
                       );
      PRC_aplica_asignacion (v_rd);

      UPDATE co532_siniestro
         SET fecha_proceso = SYSDATE,
             regla_distribucion_cod_reg_dis = v_rd
       WHERE cod_sin = p_id_siniestro;

       prc_auditoria (v_cod_hist,
                        8,
                        'Actualiza siniestro',
                           'actualiza fecha de proceso y regla distribucion -'
                        || v_cod_sin
                       );

      SELECT gestor_cod_gest
        INTO v_cod_gest
        FROM co532_asignacion
       WHERE siniestro_cod_sin = v_cod_sin;

     UPDATE co532_hist_distr
         SET reg_dist = v_rd,
             tipo_distribucion_cod_tip_dis = v_tipo_dist
       WHERE cod_his_dis = v_cod_hist;

      prc_auditoria (v_cod_hist,
                        9,
                        'Inserta detalle historico',
                        'Inserta detalle historico del siniestro'
                       );

      INSERT INTO co532_det_hist_distr
                  (cod_det_hist_dis,
                   his_dist_cod_his_dis, siniestro_cod_sin, sucursal,
                   tipo_prod, subtip_prod, est_sin,
                   est_pag, tip_amp, tip_pol, area,
                   ubicacion, est_ali, val_cap,
                   val_col, cod_gest_cap, cod_gest_col, fecha_proceso,
                   cod_tip_gest, tipo_excl, rang_fecha, rang_mora, rang_din,
                   fech_ing, fecha_mora
                  )
           VALUES (co532_sec_det_hist_dist.NEXTVAL,
                   v_cod_hist, v_cod_sin, v_sucursal_sin,
                   v_tip_prod_sin, v_subti_prod_sin, v_est_sin,
                   v_est_pago_sin, v_tipo_amp_sin, v_tip_pol_sin, v_area_sin,
                   v_ubicacion_sin, v_est_ali_sin, v_val_cap_sin,
                   v_val_col_sin, v_cod_gest, NULL, SYSDATE,
                   1, NULL, NULL, NULL, v_rango_din,
                   v_fecha_ing_sin, v_fecha_mora
                  );

      COMMIT;
      prc_auditoria (v_cod_hist,
                        10,
                        'EXITOSO',
                        'FIN DE ASIGNACION'
                       );
   EXCEPTION
      WHEN OTHERS
      THEN
        v_error := SQLCODE;
        v_desc_error := SQLERRM;
        CO532_Pk_integracion_Sai.pr_registrar_aud_siniestro(p_siniestro      => v_cod_sin
                                  ,p_error_generado => 'Siniestro no Asignado'
                                  ,p_proceso        => 'Asignacion_Siniestro_Nuevo'
                                  ,p_esquema_origen => 'CO532'
                                  ,p_esquema_destino =>'CO532'
                                  ,p_sqlcode         => v_error
                                  ,p_sqlerrm         => v_desc_error);
   END prc_distribuir_linea;

/***************************************************************************
   NOMBRE:       fct_regla_distribucion
   DESCRIPCION: Funcion que a partir de la regla de distribucion, identifica el algoritmo (tipo de distribucion)
                y su posible implementacion de acuerdo a los parametros.
   PARAMETROS DE ENTRADA: -P_RD, regla de distribucion encontrada.
   PARAMETROS DE SALIDA: b_ok:

   MODIFICACIONES :
   VERSION      FECHA       AUTOR          REQUERIMIENTO          DESCRIPCION DEL CAMBIO
   ---------------------------------------------------------------------------------------------
   1.0      19/09/2017    Jmurillo         PF 21.1                      Creacion.
   ******************************************************************************/
   FUNCTION fct_regla_distribucion (ps_tip_agru IN STRING)
      RETURN NUMBER
   IS
      b_ok            NUMBER (1)      := 0;
      /*Boolean que indica si existe el valor en la regla de distribucion*/
      n_valor_total   NUMBER (30, 10) := 0;

      CURSOR cur_gest_rango
      IS
         SELECT   a.cod_gest codigo_gestor,
                  NVL ((  (  (SELECT SUM (val_cap)
                                FROM co532_siniestro a,
                                     co532_asignacion b,
                                     co532_gest_loc c
                               WHERE a.cod_sin = b.siniestro_cod_sin
                                 AND b.gestor_cod_gest = c.gestor_cod_gest
                                 AND c.localizacion_cod_loc = a.sucursal
                                 AND a.cod_tip_ges = 1
                                 -- TIPO GESTION DESISTIMIENTOS. SOLO NUEVOS
                                 AND a.sucursal = v_sucursal_sin
                                 AND a.rang_din = v_rango_din
                                 AND b.gestor_cod_gest = a.cod_gest)
                           * 100
                          )
                        / n_valor_total
                       ),
                       0
                      ) porcentaje
             FROM co532_gestor a, co532_gest_loc b
            WHERE a.cod_gest = b.gestor_cod_gest
              AND a.cod_tip_gestor = v_gestores
              AND est_gest = 'A'
              AND b.localizacion_cod_loc = v_sucursal_sin
         ORDER BY 2 ASC;

      CURSOR cur_gest_total
      IS
         SELECT   a.cod_gest codigo_gestor,
                  NVL ((  (  (SELECT SUM (val_cap)
                                FROM co532_siniestro a,
                                     co532_asignacion b,
                                     co532_gest_loc c
                               WHERE a.cod_sin = b.siniestro_cod_sin
                                 AND b.gestor_cod_gest = c.gestor_cod_gest
                                 AND c.localizacion_cod_loc = a.sucursal
                                 AND rang_din IS NULL
                                 AND a.cod_tip_ges = 1
                                 -- TIPO GESTION DESISTIMIENTOS. SOLO NUEVOS
                                 AND a.sucursal = v_sucursal_sin
                                 AND b.gestor_cod_gest = a.cod_gest)
                           * 100
                          )
                        / n_valor_total
                       ),
                       0
                      ) porcentaje
             FROM co532_gestor a, co532_gest_loc b
            WHERE a.cod_gest = b.gestor_cod_gest
              AND a.cod_tip_gestor = v_gestores
              AND est_gest = 'A'
              AND b.localizacion_cod_loc = v_sucursal_sin
         ORDER BY 2 ASC;
   BEGIN
      IF ps_tip_agru IN ('na', 'suc')
      THEN
         prc_auditoria (v_cod_hist,
                           7.1,
                           'Asignacion 2',
                           'Asignacion por sucursal o sin agrupamiento'
                          );

         --Encuentra el total que tiene asignado el Gestor al momento de la distribucion
         SELECT SUM (val_cap)
           INTO n_valor_total
           FROM co532_siniestro a, co532_asignacion b, co532_gest_loc c
          WHERE a.cod_sin = b.siniestro_cod_sin
            AND b.gestor_cod_gest = c.gestor_cod_gest
            AND a.sucursal = c.localizacion_cod_loc
            AND a.sucursal = v_sucursal_sin
            AND a.cod_tip_ges = 1  -- TIPO GESTION DESISTIMIENTOS. SOLO NUEVOS
            AND rang_din IS NULL;

         IF n_valor_total = NULL
         THEN
            n_valor_total := 1;         --NO EXISTE NADA ASIGNADO ASIGNACION;
         END IF;

         FOR r_gest_total IN cur_gest_total
         LOOP
            INSERT INTO co532_asignacion
                        (siniestro_cod_sin, gestor_cod_gest
                        )
                 VALUES (v_cod_sin, r_gest_total.codigo_gestor
                        );
            prc_auditoria (v_cod_hist,
                              7.2,
                              'Asignacion 2',
                                 'Asigna siniestro a gestor -'
                              || r_gest_total.codigo_gestor
                             );
            b_ok := 1;
            
            Insert into CO532_BITA_SINI (COD_BIT_SIN,SINIESTRO_COD_SIN,GESTOR_COD_GEST,MOTIVO_EXCLUSION_COD_MOT_EXC,REGLA_DISTRIBUCION_COD_REG_DIS,FECHA_REAL)
            Values (co532_sec_co532_bita_sini.nextval,v_cod_sin,r_gest_total.codigo_gestor,null,v_rd,sysdate);
            
            EXIT WHEN b_ok = 1;
         END LOOP;
      ELSE
         prc_auditoria (v_cod_hist,
                           7.1,
                           'Asignacion 2',
                           'Asignacion por Rango Dinero'
                          );

         --encuentra el total que tiene asignado el Gestor al momento de la distribucion
         SELECT SUM (val_cap)
           INTO n_valor_total
           FROM co532_siniestro a, co532_asignacion b, co532_gest_loc c
          WHERE a.cod_sin = b.siniestro_cod_sin
            AND b.gestor_cod_gest = c.gestor_cod_gest
            AND a.sucursal = c.localizacion_cod_loc
            AND a.sucursal = v_sucursal_sin
            AND a.cod_tip_ges = 1  -- TIPO GESTION DESISTIMIENTOS. SOLO NUEVOS
            AND a.rang_din = v_rango_din;

         IF n_valor_total = NULL
         THEN
            n_valor_total := 1;         --NO EXISTE NADA ASIGNADO ASIGNACION;
         END IF;

         FOR r_gest_rango IN cur_gest_rango
         LOOP
            INSERT INTO co532_asignacion
                        (siniestro_cod_sin, gestor_cod_gest
                        )
                 VALUES (v_cod_sin, r_gest_rango.codigo_gestor
                        );

            prc_auditoria (v_cod_hist,
                              7.2,
                              'Asignacion',
                                 'Asigna siniestro a gestor -'
                              || r_gest_rango.codigo_gestor
                             );
            b_ok := 1;
            EXIT WHEN b_ok = 1;
         END LOOP;
      END IF;

      RETURN b_ok;
   END fct_regla_distribucion;

/***************************************************************************
   NOMBRE:       fct_aplica_asignacion
   DESCRIPCION: Funcion que busca los gestores que aplica y los asigna al siniestro insertando en ASIGNACION.
   PARAMETROS DE ENTRADA: tipo_agrupacion.
   PARAMETROS DE SALIDA: b_ok:

   MODIFICACIONES :
   VERSION      FECHA       AUTOR          REQUERIMIENTO          DESCRIPCION DEL CAMBIO
   ---------------------------------------------------------------------------------------------
   1.0      20/09/2017    Jmurillo         PF 21.1                      Creacion.
   ******************************************************************************/
   PROCEDURE prc_aplica_asignacion (p_rd IN NUMBER)
      
   IS
      b_ok         NUMBER (1)  := 0;
      /*Boolean que indica si existe el valor en la regla de distribucion*/
      s_tip_agru   STRING (10) := NULL;
      /*Captura el tipo de agrupacion usado en la regla de distribucion*/
      n_tip_agru   NUMBER (1)  := NULL;
   /*Captura el tipo de rango implementadoen la regla de distribucion*/
   BEGIN
      SELECT a.tip_agru, a.tip_ran, b.tipo_distribucion_cod_tip_dis
        INTO s_tip_agru, n_tip_agru, v_tipo_dist
        FROM co532_tip_distr a, co532_reg_dist b
       WHERE a.cod_tip_dis = b.tipo_distribucion_cod_tip_dis
         AND b.cod_reg_dis = p_rd;

      IF s_tip_agru IN ('ran', 'suc ran')
      THEN
         prc_auditoria (v_cod_hist,
                           6.1,
                           'Asignacion 1',
                           'Usa agrupacion por rango'
                          );

         IF n_tip_agru = 1
         THEN
            BEGIN
               SELECT nom_ran
                 INTO v_rango_din
                 FROM co532_rang_agru
                WHERE v_val_cap_sin BETWEEN val_ini AND val_fin
                      AND tip_ran = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  b_ok := 0;                           --NO EXISTE RAAAAANGO;
                  prc_auditoria
                        (v_cod_hist,
                         6.2,
                         'Asignacion 1',
                            'No encuentra rango por dinero aplicable al siniestro -'
                         || v_val_cap_sin
                        );
            END;

            UPDATE co532_siniestro
               SET rang_din = v_rango_din
             WHERE cod_sin = v_cod_sin;
                prc_auditoria (v_cod_hist,
                              6.3,
                              'Asignacion 1',
                              'Actualiza siniestro con rango de dinero'
                             );
             
               prc_auditoria (v_cod_hist,
                              7,
                              'Asignacion 2',
                              'Inicia asignacion del siniestro con agrupacion'
                             );
            b_ok := fct_regla_distribucion (s_tip_agru);
         ELSIF n_tip_agru = 2
         THEN
            b_ok := 0;
         ELSIF n_tip_agru = 3
         THEN
            b_ok := 0;
         ELSE
            b_ok := 0;
         END IF;
      ELSE
         prc_auditoria (v_cod_hist,
                           7,
                           'Asignacion 2',
                           'Inicia asignacion del siniestro sin agrupacion'
                          );
         b_ok := fct_regla_distribucion (s_tip_agru);
      END IF;

   END prc_aplica_asignacion;

/***************************************************************************
   NOMBRE:       fct_exclusiones
   DESCRIPCION: Funcion para recorrer las exclusiones parametrizadas en las reglas de distribuci?n.
   PARAMETROS DE ENTRADA: -P_RD, regla de distribucion encontrada.
   PARAMETROS DE SALIDA:
                        0- el siniestro no fue excluido
                        3- exclusiones por fecha y hora
                        4- excluido por fecha y estado
                        5- excluido por monto
                        6- excluido por caso
                        7- excluido por poliza.
   MODIFICACIONES :
   VERSION      FECHA       AUTOR          REQUERIMIENTO          DESCRIPCION DEL CAMBIO
   ---------------------------------------------------------------------------------------------
   1.0      19/09/2017    Jmurillo         PF 21.1                      Creacion.
   ******************************************************************************/
   FUNCTION fct_exclusiones (p_rd IN NUMBER)
      RETURN NUMBER
   IS
      b_encontro   NUMBER (1) := 0;
      /*Boolean que indica si existe o no la exclusion*/
      n_dia        NUMBER (2) := NULL;
      s_hora       CHAR (6)   := NULL;
      s_hora_ini   CHAR (6)   := NULL;
      s_hora_fin   CHAR (6)   := NULL;

      -- Cursor para obtener las exclusiones de  fecha y hora en regla de distribucion
      CURSOR cur_excl_fec
      IS
         SELECT dia, hora
           FROM co532_excl_fec
          WHERE regla_distribucion_cod_reg_dis = p_rd;

      CURSOR cur_excl_est_fec
      IS
         SELECT est_sin, fecha
           FROM co532_excl_est_fec
          WHERE regla_distribucion_cod_reg_dis = p_rd;

      CURSOR cur_excl_mont
      IS
         SELECT minimo, maximo, tip_excl
           FROM co532_excl_mont
          WHERE regla_distribucion_cod_reg_dis = p_rd;

      CURSOR cur_excl_cas
      IS
         SELECT siniestro_cod_sin, tipo_excl
           FROM co532_excl_cas
          WHERE regla_distribucion_cod_reg_dis = p_rd;

      CURSOR cur_excl_pol
      IS
         SELECT poliza_cod_pol, tip_exc
           FROM co532_excl_pol
          WHERE regla_distribucion_cod_reg_dis = p_rd;
   BEGIN
      FOR r_exc_fec IN cur_excl_fec
      LOOP
         n_dia := TO_NUMBER (TO_CHAR (v_fecha_ing_sin, 'dd'));
         s_hora := TO_CHAR (v_fecha_ing_sin, 'HH24:MI');
         s_hora_ini := TO_CHAR (r_exc_fec.hora, 'HH24:MI');
         s_hora_fin :=
            TO_CHAR (TO_DATE ('01/01/0001 23:59:00', 'MM/DD/YYYY HH24:MI:SS'),
                     'HH24:MI'
                    );

         IF     n_dia = r_exc_fec.dia
            AND (s_hora BETWEEN s_hora_ini AND s_hora_fin)
         THEN
            b_encontro := 3;
            v_tip_excl := 'EM';
            prc_auditoria (v_cod_hist,
                              5.1,
                              'Exclusiones',
                              'Siniestro excluido por dia y hora'
                             );
            RETURN b_encontro;
         END IF;
      END LOOP;

      FOR r_excl_est_fec IN cur_excl_est_fec
      LOOP
         IF     r_excl_est_fec.est_sin = v_est_sin
            AND (TRUNC (r_excl_est_fec.fecha) = TRUNC (v_fecha_ing_sin))
         THEN
            b_encontro := 4;
            v_tip_excl := 'EM';
            prc_auditoria
                        (v_cod_hist,
                         5.1,
                         'Exclusiones',
                         'Siniestro excluido por estado de siniestro y fecha'
                        );
            RETURN b_encontro;
         END IF;
      END LOOP;

      FOR r_excl_mont IN cur_excl_mont
      LOOP
         v_tip_excl := r_excl_mont.tip_excl;

         IF    v_val_cap_sin <= r_excl_mont.minimo
            OR v_val_cap_sin >= r_excl_mont.maximo
         THEN
            b_encontro := 5;
            prc_auditoria (v_cod_hist,
                              5.1,
                              'Exclusiones',
                              'Siniestro excluido por monto'
                             );
            RETURN b_encontro;
         END IF;
      END LOOP;

      FOR r_excl_cas IN cur_excl_cas
      LOOP
         v_tip_excl := r_excl_cas.tipo_excl;

         IF r_excl_cas.siniestro_cod_sin = v_cod_sin
         THEN
            b_encontro := 6;
            prc_auditoria (v_cod_hist,
                              5.1,
                              'Exclusiones',
                              'Siniestro excluido por numero de siniestro'
                             );
            RETURN b_encontro;
         END IF;
      END LOOP;

      FOR r_excl_pol IN cur_excl_pol
      LOOP
         v_tip_excl := r_excl_pol.tip_exc;

         IF r_excl_pol.poliza_cod_pol = v_cod_sin
         THEN
            b_encontro := 7;
            prc_auditoria
                      (v_cod_hist,
                       5.1,
                       'Exclusiones',
                       'Siniestro excluido por numero de poliza/inmobiliaria'
                      );
            RETURN b_encontro;
         END IF;
      END LOOP;

      IF b_encontro = 0
      THEN
         prc_auditoria (v_cod_hist,
                           5.2,
                           'Exclusiones',
                           'NO PRESENTA EXCLUSIONES'
                          );
      END IF;

      RETURN b_encontro;
   END fct_exclusiones;

/***************************************************************************
   NOMBRE:       fct_valida_gestores
   DESCRIPCION: Funciona para validar si existen gestores en la regla de distribucion que aplica para el siniestro
                con la sucursal.
   PARAMETROS DE ENTRADA: -P_RD, regla de distribucion encontrada.

   PARAMETROS DE SALIDA: 1/0 si encontro o no encontro.
   MODIFICACIONES :
   VERSION      FECHA       AUTOR          REQUERIMIENTO          DESCRIPCION DEL CAMBIO
   ---------------------------------------------------------------------------------------------
   1.0      19/09/2017    Jmurillo         PF 21.1                      Creacion.
   ******************************************************************************/
   FUNCTION fct_valida_gestores (p_rd IN NUMBER)
      RETURN STRING
   IS
      b_ok   STRING (10) := 0;
   /*Boolean que indica si existe el valor en la regla de distribucion*/
   BEGIN
      BEGIN
         SELECT DISTINCT a.variable_cod_var
                    INTO b_ok
                    FROM co532_var_regl a, co532_gestor b, co532_gest_loc c
                   WHERE b.cod_tip_gestor = a.variable_cod_var
                     AND b.cod_gest = c.gestor_cod_gest
                     AND c.localizacion_cod_loc = v_sucursal_sin
                     AND a.regla_distribucion_cod_reg_dis = p_rd
                     AND variable_tip_var = 1
                     AND b.est_gest = 'A';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            b_ok := 0;
      END;

      RETURN b_ok;
   END fct_valida_gestores;

   /***************************************************************************
    NOMBRE:       prc_marcar_excl_sin
    DESCRIPCION: Funcion para actualizar el siniestro con la informacion respectiva de excluido por al gun motivo.
    PARAMETROS DE ENTRADA:
                - P_ID_SINIESTRO: Numero del siniestro al cual se le identificar? la regla de distribucion.
                - P_COD_EXCL: Codigo de exclusion para el siniestro.
    PARAMETROS DE SALIDA: N/A
    MODIFICACIONES :
    VERSION      FECHA       AUTOR          REQUERIMIENTO          DESCRIPCION DEL CAMBIO
    ---------------------------------------------------------------------------------------------
    1.0      18/09/2017    Jmurillo         PF 21.1                      Creacion.
    ******************************************************************************/
   PROCEDURE prc_marcar_excl_sin (
      p_id_siniestro   IN   NUMBER,
      p_cod_excl       IN   NUMBER
   )
   IS
   BEGIN
      UPDATE co532_siniestro
         SET motivo_exclusion_cod_mot_exc = p_cod_excl,
             tip_exc = v_tip_excl,
             fecha_proceso = TRUNC (SYSDATE)
       WHERE cod_sin = p_id_siniestro;
      
      Insert into CO532_BITA_SINI (COD_BIT_SIN,SINIESTRO_COD_SIN,GESTOR_COD_GEST,MOTIVO_EXCLUSION_COD_MOT_EXC,REGLA_DISTRIBUCION_COD_REG_DIS,FECHA_REAL)
            Values (co532_sec_co532_bita_sini.nextval, p_id_siniestro,null,p_cod_excl,v_rd,sysdate);
      COMMIT;
   END;

    /***************************************************************************
   NOMBRE:       fct_ident_regla
   DESCRIPCION: Funcion que retorna la regla de distribucion que aplicar? al siniestrop.
   PARAMETROS DE ENTRADA:
               - P_ID_SINIESTRO: Numero del siniestro al cual se le identificar? la regla de distribucion.
   PARAMETROS DE SALIDA: Numerico, regla de distribucion.
   MODIFICACIONES :
   VERSION      FECHA       AUTOR          REQUERIMIENTO          DESCRIPCION DEL CAMBIO
   ---------------------------------------------------------------------------------------------
   1.0      18/09/2017    Jmurillo         PF 21.1                      Creacion.
   ******************************************************************************/
   FUNCTION fct_ident_regla (p_id_siniestro IN NUMBER)
      RETURN NUMBER
   IS
      b_encontro   NUMBER (1);

      /*Boolean que indica si existe o no Regla De Distribucion*/

      -- Cursor para obtener las reglas de distribucion existentes
      CURSOR cur_reglas
      IS
         SELECT   cod_reg_dis
             FROM co532_reg_dist
            WHERE per_reg = 'ESN' AND estado = 1
         ORDER BY prioridad ASC;
   BEGIN
      FOR r_reglas IN cur_reglas
      LOOP
         b_encontro := 1;
         v_rd := r_reglas.cod_reg_dis;
         prc_auditoria (v_cod_hist,
                           3.1,
                           'Consulta las reglas ESN',
                           'Validando Regla Distribucion -' || v_rd
                          );

         IF b_encontro = 1
         THEN
            IF (    v_sucursal_sin IS NOT NULL
                AND fct_variables_sin (3, v_sucursal_sin) = 0
               )
            THEN
               b_encontro := 0;
               prc_auditoria (v_cod_hist,
                                 3.2,
                                 'No Aplica Regla',
                                 'No Aplica regla x sucursal - ' || v_rd
                                );
            END IF;
         END IF;

         IF b_encontro = 1
         THEN
            IF (    v_tip_prod_sin IS NOT NULL
                AND fct_variables_sin (4, v_tip_prod_sin) = 0
               )
            THEN
               prc_auditoria (v_cod_hist,
                                 3.2,
                                 'No Aplica Regla',
                                 'No Aplica regla x tipo producto - ' || v_rd
                                );
               b_encontro := 0;
            END IF;
         END IF;

         IF b_encontro = 1
         THEN
            IF (    v_subti_prod_sin IS NOT NULL
                AND fct_variables_sin (5, v_subti_prod_sin) = 0
               )
            THEN
               prc_auditoria (v_cod_hist,
                                 3.2,
                                 'No Aplica Regla',
                                    'No Aplica regla x subtipo producto - '
                                 || v_rd
                                );
               b_encontro := 0;
            END IF;
         END IF;

         IF b_encontro = 1
         THEN
            IF (v_est_sin IS NOT NULL AND fct_variables_sin (6, v_est_sin) = 0
               )
            THEN
               prc_auditoria (v_cod_hist,
                                 3.2,
                                 'No Aplica Regla',
                                    'No Aplica regla x estado siniestro - '
                                 || v_rd
                                );
               b_encontro := 0;
            END IF;
         END IF;

         IF b_encontro = 1
         THEN
            IF (    v_est_pago_sin IS NOT NULL
                AND fct_variables_sin (7, v_est_pago_sin) = 0
               )
            THEN
               prc_auditoria (v_cod_hist,
                                 3.2,
                                 'No Aplica Regla',
                                 'No Aplica regla x estado pago - ' || v_rd
                                );
               b_encontro := 0;
            END IF;
         END IF;

         IF b_encontro = 1
         THEN
            IF (    v_tipo_amp_sin IS NOT NULL
                AND fct_variables_sin (8, v_tipo_amp_sin) = 0
               )
            THEN
               prc_auditoria (v_cod_hist,
                                 3.2,
                                 'No Aplica Regla',
                                 'No Aplica regla x tipo amparo - ' || v_rd
                                );
               b_encontro := 0;
            END IF;
         END IF;

         IF b_encontro = 1
         THEN
            IF (    v_tip_pol_sin IS NOT NULL
                AND fct_variables_sin (9, v_tip_pol_sin) = 0
               )
            THEN
               prc_auditoria (v_cod_hist,
                                 3.2,
                                 'No Aplica Regla',
                                 'No Aplica regla x tipo poliza - ' || v_rd
                                );
               b_encontro := 0;
            END IF;
         END IF;

         IF b_encontro = 1
         THEN
            IF (    v_area_sin IS NOT NULL
                AND fct_variables_sin (10, v_area_sin) = 0
               )
            THEN
               prc_auditoria (v_cod_hist,
                                 3.2,
                                 'No Aplica Regla',
                                 'No Aplica regla x area - ' || v_rd
                                );
               b_encontro := 0;
            END IF;
         END IF;

         IF b_encontro = 1
         THEN
            IF (    v_ubicacion_sin IS NOT NULL
                AND fct_variables_sin (11, v_ubicacion_sin) = 0
               )
            THEN
               prc_auditoria (v_cod_hist,
                                 3.2,
                                 'No Aplica Regla',
                                 'No Aplica regla x ubicacion - ' || v_rd
                                );
               b_encontro := 0;
            END IF;
         END IF;

         IF b_encontro = 1
         THEN
            IF (    v_est_ali_sin IS NOT NULL
                AND fct_variables_sin (12, v_est_ali_sin) = 0
               )
            THEN
               prc_auditoria
                               (v_cod_hist,
                                3.2,
                                'No Aplica Regla',
                                   'No Aplica regla x estado alistamiento - '
                                || v_rd
                               );
               b_encontro := 0;
            END IF;
         END IF;

         IF b_encontro = 1
         THEN
            prc_auditoria (v_cod_hist,
                              3.3,
                              'Encuentra Regla',
                              'se usa regla distribucion numero: ' || v_rd
                             );
         END IF;

         EXIT WHEN b_encontro = 1;
      END LOOP;

      IF b_encontro = 0
      THEN
         v_rd := -1;
      END IF;

      RETURN v_rd;
   END fct_ident_regla;

/***************************************************************************
   NOMBRE:       fct_variables_sin
   DESCRIPCION: Funcion que valida el valor del siniestro Vs el valor de la variable parametrizada en la Regla de distribucion.
   PARAMETROS DE ENTRADA:
               - p_tip_val: Tipo de la variable a validar.
               - p_val_val: Valor de la Variable.

   PARAMETROS DE SALIDA: 1/0 si encontro o no encontro.
   MODIFICACIONES :
   VERSION      FECHA       AUTOR          REQUERIMIENTO          DESCRIPCION DEL CAMBIO
   ---------------------------------------------------------------------------------------------
   1.0      18/09/2017    Jmurillo         PF 21.1                      Creacion.
   ******************************************************************************/
   FUNCTION fct_variables_sin (p_tip_var IN NUMBER, p_val_var IN STRING)
      RETURN NUMBER
   IS
      b_ok      NUMBER (1)  := 1;
      /*Boolean que indica si existe el valor en la regla de distribucion*/
      s_valor   STRING (10) := NULL;
   /*Bcaptura el valor de la consulta en la regla*/
   BEGIN
      BEGIN
         SELECT variable_cod_var
           INTO s_valor
           FROM co532_var_regl a, co532_variable b
          WHERE a.variable_tip_var = b.tip_var
            AND a.variable_cod_var = b.cod_var
            AND a.variable_tip_var = p_tip_var
            AND b.nom_cul_sai = p_val_var
            AND a.regla_distribucion_cod_reg_dis = v_rd;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            b_ok := 0;
      END;

      IF s_valor = NULL
      THEN
         b_ok := 0;
      END IF;

      RETURN b_ok;
   END fct_variables_sin;

/***************************************************************************
   NOMBRE:       prc_auditoria
   DESCRIPCION:
   PARAMETROS DE ENTRADA: -P_RD, regla de distribucion encontrada.
   PARAMETROS DE SALIDA:

   MODIFICACIONES :
   VERSION      FECHA       AUTOR          REQUERIMIENTO          DESCRIPCION DEL CAMBIO
   ---------------------------------------------------------------------------------------------
   1.0      19/09/2017    Jmurillo         PF 21.1                      Creacion.
   ******************************************************************************/
   procedure prc_auditoria (
      p_cod_hist      IN   NUMBER,
      p_paso          IN   NUMBER,
      p_funcion       IN   VARCHAR,
      p_observacion   IN   VARCHAR
   )
         IS
   BEGIN
      
      INSERT INTO co532_aud_dist
                  (hist_distr_cod_his_dis, siniestro_cod_sin, cod_aud,
                   paso, fecha, funcion, observacion
                  )
           VALUES (p_cod_hist, v_cod_sin, co532_sec_aud_dist.NEXTVAL,
                   p_paso, SYSDATE, p_funcion, p_observacion
                  );
   END prc_auditoria;
END co532_pkg_asig_nuevos; 
/

