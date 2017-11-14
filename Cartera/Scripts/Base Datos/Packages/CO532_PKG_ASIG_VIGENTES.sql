CREATE OR REPLACE PACKAGE ADMSISA.CO532_PKG_ASIG_VIGENTES IS

--PROCEDIMIENTO A SER LLAMADO
PROCEDURE prc_asig_vigentes ( p_rd in NUMBER, p_prueba in NUMBER);

PROCEDURE prc_ident_siniestros ( p_rd IN NUMBER );

PROCEDURE prc_auditoria (p_cod_hist IN NUMBER,p_paso IN NUMBER,p_funcion IN VARCHAR, p_observacion IN VARCHAR );

PROCEDURE prc_exclusiones (p_rd IN NUMBER);

PROCEDURE prc_algoritmo_distribucion (p_rd in NUMBER);

PROCEDURE prc_aplica_distri ( p_rd in NUMBER , ps_tip_agru IN STRING, p_tip_rang IN NUMBER );

PROCEDURE prc_valida_gestores ( p_rd IN NUMBER );

PROCEDURE prc_optimizar_distribucion_FP(p_rd in NUMBER, p_tip_rang in NUMBER );

procedure prc_limpiar ( p_rd IN VARCHAR); 

procedure prc_det_hist_distr ( p_cod_hist IN NUMBER);

PROCEDURE prc_pruebas (p_rd in NUMBER);

END CO532_PKG_ASIG_VIGENTES; 
/



CREATE OR REPLACE PACKAGE BODY ADMSISA.CO532_PKG_ASIG_VIGENTES

 IS
   /** VARIABLES  GENERALES PARA LA DISTRIBUCION EN LINEA DE LOS SINIESTROS. **/
   v_rang_agru                  VARCHAR(5)     := NULL; --Rango de Agrupacion del tipo de distribucion a utilizar (algoritmo de distribuci?n)
   v_tip_rang                   NUMBER(5)      := NULL; --Tipo de agrupacion implementado por el tipo  de distribucion (algoritmo de Distribucion).
   v_rango_des                  VARCHAR(5)     := NULL; --Nombre Rango fecha de desocupacion
   v_rango_din                  VARCHAR(5)     := NULL; --Nombre Rango dinero
   b_ok                         NUMBER(1)      := NULL;
   v_rang_fec                   VARCHAR(5)     := NULL; 
   v_rango_mor                  VARCHAR(5)     := NULL;
   v_rd                         NUMBER         := NULL;
   v_tip_excl                   VARCHAR(5)     := NULL; 
   v_ok                         NUMBER (1)     := NULL;
   v_cod_hist                   NUMBER (10)    := NULL;
   v_condiciones                Varchar2(1000) := NULL;
   sql_str                      VARCHAR2(2000) := NULL;
   v_td                         Number(5)      := NULL;
   
      
   --INFORMACION DEL SINIESTRO
   v_cod_sin                    NUMBER (10)    := NULL;
   v_val_cap_sin                NUMBER (15,3)  := NULL;
   v_val_col_sin                NUMBER (15,3)  := NULL;
   v_fecha_mora                 DATE           := NULL;
   v_fech_desoc                 DATE           := NULL;
   v_cod_tip_gest               NUMBER         := NULL;
   v_sucursal_sin               VARCHAR(10)    := NULL;
   v_fecha_ing_sin              DATE           := NULL;
   v_cod_gest                   NUMBER         := NULL;
   v_tip_pol_sin                VARCHAR(5)     := NULL;
   v_area_sin                   VARCHAR(5)     := NULL;
   v_ubicacion_sin              VARCHAR(5)     := NULL;
   v_est_ali_sin                VARCHAR(5)     := NULL;
   v_tipo_amp_sin               VARCHAR(5)     := NULL;
   v_tip_prod_sin               NUMBER         := NULL;
   v_subti_prod_sin             VARCHAR(4)     := NULL;
   v_est_sin                    VARCHAR(4)     := NULL;
   v_est_pago_sin               VARCHAR(4)     := NULL;
                 
PROCEDURE prc_asig_vigentes ( p_rd in NUMBER,  p_prueba in NUMBER) 
   IS
   BEGIN 
    v_rd :=p_rd;
    v_cod_hist:=co532_sec_hist_distr.nextval;
        
    select TIPO_DISTRIBUCION_COD_TIP_DIS into v_td  from co532_reg_dist where cod_reg_dis=v_rd;
    
    insert into CO532_hist_distr  (COD_HIS_DIS, FECHA, TIPO_DISTRIBUCION_COD_TIP_DIS, REG_DIST, DESCRIPCION, USUARIO)
    values (v_cod_hist, SYSDATE, v_td, V_RD ,'ESTADO SINIESTRO VIGENTE',USER);
        
    prc_auditoria(v_cod_hist,1,'Inicio Proceso', 'Inserta encabezado del Historico distribuci?n numero -'||v_cod_hist);
    
    prc_limpiar ( v_rd );

    prc_auditoria (v_cod_hist,2, 'Identifica Siniestros', 'Consulta los siniestros que seran usados por la regla de distribucion seleccionada');
    
    prc_ident_siniestros (v_rd);
    
    prc_auditoria (v_cod_hist,3, 'Validando Exclusiones', 'En los Siniestros identificados, se valida las reglas de exclusiones para la regla distribucion');
   
    prc_exclusiones (v_rd );
   
    prc_auditoria (v_cod_hist,4, 'Validando Gestores', 'Encuentra los gestores a los cuales se van asignar los siniestros');
    
    prc_valida_gestores (v_rd);
   
    prc_auditoria (v_cod_hist,5, 'Asignacion 1', 'Valida informacion de la regla distribucion tipo agrupacion.');
    
    prc_algoritmo_distribucion (v_rd);
   
    prc_det_hist_distr ( v_cod_hist );
   
    prc_auditoria (v_cod_hist,7, 'Optimizacion', 'Inicia la optimizacion de la asignacion de los siniestros');
    
    prc_optimizar_distribucion_FP (v_rd, v_tip_rang);
    
    insert into co532_bita_sini  
    select co532_sec_co532_bita_sini.nextval, a.cod_sin,b.gestor_cod_gest,null, v_rd, sysdate
    from co532_siniestro a, co532_asignacion b
    where a.cod_sin=b.siniestro_cod_sin
    and fecha_proceso=trunc(sysdate) and REGLA_DISTRIBUCION_COD_REG_DIS = v_rd;
    
    insert into co532_bita_sini  
    select co532_sec_co532_bita_sini.nextval, a.cod_sin, null, a.MOTIVO_EXCLUSION_COD_MOT_EXC , v_rd, sysdate
    from co532_siniestro a 
    where a.fecha_proceso=trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS = v_rd
    and a.cod_sin not in (select siniestro_cod_sin from co532_asignacion);
    
    prc_auditoria(v_cod_hist,8,'Historico Distribucion', 'Registra en el historico de la distribucion numero: '||v_cod_hist);
    
    v_cod_sin:=NULL;
    
    prc_auditoria (v_cod_hist,9, 'Fin Proceso', 'Finaliza el proceso');
    
    IF p_prueba = 1 THEN
        prc_pruebas (v_rd);
        ROLLBACK;
    ELSE
        COMMIT;
    END IF;
     
     EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.put_line('Error: '|| SQLERRM);  
        RAISE_APPLICATION_ERROR (-20700, SQLERRM ); 
                        
    END prc_asig_vigentes; 

/***************************************************************************
   NOMBRE:       prc_ident_siniestross
   DESCRIPCION: Cnsulta los siniestros en la BD para marcarlos con la regla de distribucion seleccionada.
   PARAMETROS DE ENTRADA:p_rd- regla de distribucion
   PARAMETROS DE SALIDA: 

   MODIFICACIONES :
   VERSION      FECHA       AUTOR          REQUERIMIENTO          DESCRIPCION DEL CAMBIO
   ---------------------------------------------------------------------------------------------
   1.0      19/09/2017    Jmurillo         PF 21.1                      Creacion.
   ******************************************************************************/
   PROCEDURE prc_ident_siniestros ( p_rd IN NUMBER)  
   IS
     n_total number;
     
    cursor cur_variable_regla IS -- identifica las variables que se usan por la regla de distribucion
     select a.tip_var, a.NOM_CUL_SAI 
     from co532_variable a , co532_var_regl b 
     where a.tip_var=b.VARIABLE_TIP_VAR 
     and a.cod_var=b.VARIABLE_COD_VAR
     and b.REGLA_DISTRIBUCION_COD_REG_DIS=p_rd
     order by 1;
     
    cursor cur_valor_regla IS 
     select DISTINCT TIPO_VAR 
     from co532_VALOR_REGLA
     WHERE REG_DISTR=V_RD
     ORDER BY 1;
   BEGIN
   
    Delete from co532_valor_regla;
    
     FOR r_variable_regla IN cur_variable_regla
        LOOP
            INSERT INTO co532_valor_regla (CONSECUTIVO, REG_DISTR, TIPO_VAR, VALOR_VARIABLE) 
            VALUES (CO532_SEC_VALOR_REGLA.NEXTVAL, V_RD, r_variable_regla.TIP_VAR, r_variable_regla.NOM_CUL_SAI );
        END LOOP; 
        
     FOR r_valor_regla IN cur_valor_regla
        LOOP
            CASE r_valor_regla.TIPO_VAR
             WHEN 3 THEN 
                IF v_condiciones is not null then
                    v_condiciones := v_condiciones||' and sucursal in (select valor_variable from co532_valor_regla where tipo_var=3)';
                ELSE
                    v_condiciones := v_condiciones||' sucursal in (select valor_variable from co532_valor_regla where tipo_var=3)';
                end if;
             WHEN 4 THEN 
                IF v_condiciones is not null then
                    v_condiciones := v_condiciones||' and tip_prod in (select valor_variable from co532_valor_regla where tipo_var=4)';
                ELSE
                    v_condiciones := v_condiciones||' tip_prod in (select valor_variable from co532_valor_regla where tipo_var=4)';
                end if;
             WHEN 5 THEN 
                IF v_condiciones is not null then
                    v_condiciones := v_condiciones||' and subti_prod in (select valor_variable from co532_valor_regla where tipo_var=5)';
                ELSE
                    v_condiciones := v_condiciones||' subti_prod in (select valor_variable from co532_valor_regla where tipo_var=5)';
                end if;
             WHEN 6 THEN 
                IF v_condiciones is not null then
                    v_condiciones := v_condiciones||' and est_sin in (select valor_variable from co532_valor_regla where tipo_var=6)';
                ELSE
                    v_condiciones := v_condiciones||' est_sin in (select valor_variable from co532_valor_regla where tipo_var=6)';
                end if;
             WHEN 7 THEN 
                IF v_condiciones is not null then
                    v_condiciones := v_condiciones||' and est_pag in (select valor_variable from co532_valor_regla where tipo_var=7)';
                ELSE
                    v_condiciones := v_condiciones||' est_pag in (select valor_variable from co532_valor_regla where tipo_var=7)';
                end if;
             WHEN 8 THEN 
                IF v_condiciones is not null then
                    v_condiciones := v_condiciones||' and tip_amp in (select valor_variable from co532_valor_regla where tipo_var=8)';
                ELSE
                    v_condiciones := v_condiciones||' tip_ampin (select valor_variable from co532_valor_regla where tipo_var=8)';
                end if;
             WHEN 9 THEN 
                IF v_condiciones is not null then
                    v_condiciones := v_condiciones||' and tip_pol in (select valor_variable from co532_valor_regla where tipo_var=9)';
                ELSE
                    v_condiciones := v_condiciones||' tip_pol in (select valor_variable from co532_valor_regla where tipo_var=9)';
                end if;
             WHEN 10 THEN 
                IF v_condiciones is not null then
                    v_condiciones := v_condiciones||' and area in (select valor_variable from co532_valor_regla where tipo_var=10)';
                ELSE
                    v_condiciones := v_condiciones||' area in (select valor_variable from co532_valor_regla where tipo_var=10)';
                end if;   
             WHEN 11 THEN 
                IF v_condiciones is not null then
                    v_condiciones := v_condiciones||' and ubicacion in (select valor_variable from co532_valor_regla where tipo_var=11)';
                ELSE
                    v_condiciones := v_condiciones||' ubicacion in (select valor_variable from co532_valor_regla where tipo_var=11)';
                end if;
             WHEN 12 THEN 
                IF v_condiciones is not null then
                    v_condiciones := v_condiciones||' and est_ali in (select valor_variable from co532_valor_regla where tipo_var=12)';
                ELSE
                    v_condiciones := v_condiciones||' est_ali in (select valor_variable from co532_valor_regla where tipo_var=12)';
                end if;
             ELSE v_condiciones:= v_condiciones;
            END CASE;
        END LOOP;
       
        sql_str := 'update co532_siniestro set FECHA_PROCESO= trunc(sysdate), REGLA_DISTRIBUCION_COD_REG_DIS ='|| V_RD||'  where COD_TIP_GES = 2 and'||v_condiciones;
       EXECUTE IMMEDIATE sql_str;
       prc_auditoria (v_cod_hist,2.1, 'Identifica Siniestros', 'Marca un total de '|| to_char(SQL%ROWCOUNT)|| ' para asignacion/distribucion'); 
             
   END  prc_ident_siniestros;
    

/***************************************************************************
   NOMBRE:       prc_exclusiones
   DESCRIPCION: Funcion para recorrer las exclusiones parametrizadas en las reglas de distribuci?n.
   PARAMETROS DE ENTRADA: -P_RD, regla de distribucion encontrada.                             
   PARAMETROS DE SALIDA: actualiza en SINIESTRO motivo de exclusion.
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

procedure prc_exclusiones (p_rd IN NUMBER) 
   IS
         
   BEGIN
        prc_auditoria (v_cod_hist,3.1,'Exclusiones','Validacion de siniestros a excluir por fecha y hora'); 
        
        update co532_siniestro set motivo_exclusion_cod_mot_exc= 3 , tip_exc ='EM'
        where fecha_proceso= trunc(sysdate) and REGLA_DISTRIBUCION_COD_REG_DIS= p_rd and COD_TIP_GES = 2 
        and ( to_number(TO_CHAR(FECHA_ING,'dd')) = (select dia from co532_EXCL_FEC where REGLA_DISTRIBUCION_COD_REG_DIS = p_rd)
        and to_char(FECHA_ING,'HH24:MI') between (select To_char (HORA, 'HH24:MI') from co532_EXCL_FEC where REGLA_DISTRIBUCION_COD_REG_DIS = p_rd)  
                                                   and to_char(To_date ('01/01/0001 23:59:00', 'MM/DD/YYYY HH24:MI:SS'),'HH24:MI'));
        IF SQL%ROWCOUNT > 0 then
            prc_auditoria (v_cod_hist,3.2,'Exclusiones','Siniestros excluidos por fecha y hora: '||SQL%ROWCOUNT);
        END IF;     
       
        prc_auditoria (v_cod_hist,3.1,'Exclusiones','Validacion de siniestros a excluir por estado siniestro y fecha');
      
        update co532_siniestro set motivo_exclusion_cod_mot_exc= 4 , tip_exc ='EM'
        where fecha_proceso= trunc(sysdate) and REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and COD_TIP_GES = 2
        and (trunc (FECHA_ING) = (SELECT trunc(fecha) FROM co532_EXCL_EST_FEC where REGLA_DISTRIBUCION_COD_REG_DIS = p_rd)
        and (est_sin = (SELECT y.nom_cul_sai FROM co532_EXCL_EST_FEC x, co532_variable y 
                          where x.EST_SIN=y.COD_VAR and y.TIP_VAR=6 and  REGLA_DISTRIBUCION_COD_REG_DIS = p_rd)));
                          
        IF SQL%ROWCOUNT > 0 then
            prc_auditoria (v_cod_hist,3.2,'Exclusiones','Siniestros excluidos por estado y fecha: '||SQL%ROWCOUNT);
        END IF;        
        
        
        prc_auditoria (v_cod_hist,3.1,'Exclusiones','Validacion de siniestros por rango de montos');
        
        update co532_siniestro a set a.motivo_exclusion_cod_mot_exc= 5, 
        a.tip_exc = (select max(tip_excl) from co532_EXCL_MONT where a.VAL_CAP <= minimo or a.val_cap >=maximo and REGLA_DISTRIBUCION_COD_REG_DIS = p_rd)
        where a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
        and (a.val_cap <= (select minimo from co532_EXCL_MONT where  REGLA_DISTRIBUCION_COD_REG_DIS = p_rd)
                OR a.val_cap >= (select maximo from co532_EXCL_MONT where REGLA_DISTRIBUCION_COD_REG_DIS = p_rd));
       
        IF SQL%ROWCOUNT > 0 then
            prc_auditoria (v_cod_hist,3.2,'Exclusiones','Siniestros excluidos por montos: '||SQL%ROWCOUNT);
        END IF;  
        
        prc_auditoria (v_cod_hist,3.1,'Exclusiones','Validacion de siniestros por numero de siniestro');
      
        update co532_siniestro a set a.motivo_exclusion_cod_mot_exc= 6, 
        a.tip_exc = (select max(TIPO_EXCL) from co532_EXCL_CAS where a.cod_sin = SINIESTRO_COD_SIN and REGLA_DISTRIBUCION_COD_REG_DIS = p_rd)
        where a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
        and a.cod_sin = (select siniestro_cod_sin from co532_EXCL_CAS where  REGLA_DISTRIBUCION_COD_REG_DIS = p_rd);
        
        IF SQL%ROWCOUNT > 0 then
            prc_auditoria (v_cod_hist,3.2,'Exclusiones','Siniestros excluidos por numero de siniestro: '||SQL%ROWCOUNT);
        END IF;  
        
        prc_auditoria (v_cod_hist,3.1,'Exclusiones','Validacion de siniestros por numero de poliza/inmobiliaria');
      
        update co532_siniestro a set a.motivo_exclusion_cod_mot_exc= 7, 
        a.tip_exc = (select max(TIP_EXC) from co532_EXCL_POL where a.POLIZA = POLIZA_COD_POL and REGLA_DISTRIBUCION_COD_REG_DIS = p_rd)
        where a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
        and a.POLIZA = (select POLIZA_COD_POL from co532_EXCL_POL where  REGLA_DISTRIBUCION_COD_REG_DIS = p_rd);
                
        IF SQL%ROWCOUNT > 0 then
            prc_auditoria (v_cod_hist,3.2,'Exclusiones','Siniestros excluidos por poliza/inmobiliaria: '||SQL%ROWCOUNT);
        END IF;
        
        prc_auditoria (v_cod_hist,3.3,'Exclusiones','Finaliza el proceso de exclusion');
        
END prc_exclusiones;
    
/***************************************************************************
   NOMBRE:      prc_algoritmo_distribucion
   DESCRIPCION: en caso de que el algoritmo de distribucion use rangos, actualiza el rango respectivo para los siniestros marcados
   PARAMETROS DE ENTRADA: -P_RD, regla de distribucion encontrada.                             
   PARAMETROS DE SALIDA: 
                        
   MODIFICACIONES :
   VERSION      FECHA       AUTOR          REQUERIMIENTO          DESCRIPCION DEL CAMBIO
   ---------------------------------------------------------------------------------------------
   1.0      27/09/2017    Jmurillo         PF 21.1                      Creacion.
   ******************************************************************************/  
   
PROCEDURE prc_algoritmo_distribucion (p_rd in NUMBER) 
IS
             
BEGIN
    

SELECT b.TIP_AGRU, b.TIP_RAN
INTO  v_rang_agru,  v_tip_rang   
FROM co532_reg_dist a, co532_tip_distr b
WHERE a.TIPO_DISTRIBUCION_COD_TIP_DIS=b.COD_TIP_DIS
AND a.COD_REG_DIS =p_rd;
    
    IF v_rang_agru in ('ran','suc ran' ) THEN
        prc_auditoria (v_cod_hist,5.1,'Asignacion 1','Usa agrupacion por rango');
        IF v_tip_rang = 1 THEN
             
            update co532_siniestro a set RANG_DIN = (select nom_ran from co532_rang_agru where tip_ran=1 and a.val_cap between val_ini and val_fin)
            where a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
            and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null;
            
            IF SQL%ROWCOUNT > 0 then
            prc_auditoria (v_cod_hist,5.2,'Asignacion 2','Siniestros actualizados en rango de dinero: '||SQL%ROWCOUNT);
            END IF;
            
            prc_auditoria (v_cod_hist,6,'Asignacion 2','Inicia asignacion del siniestro con agrupacion dinero');
            
            prc_aplica_distri(v_rd , v_rang_agru, v_tip_rang);
        ELSIF  v_tip_rang=2 then
            
            update co532_siniestro a set RANG_FECHA = (select nom_ran from co532_rang_agru where tip_ran=2 and a.val_cap between val_ini and val_fin)
            where a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
            and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null;
            
            IF SQL%ROWCOUNT > 0 then
             prc_auditoria (v_cod_hist,5.2,'Asignacion 2','Siniestros actualizados en rango fecha desocupacion: '||SQL%ROWCOUNT);
            END IF;
            
            prc_auditoria (v_cod_hist,6,'Asignacion 2','Inicia asignacion del siniestro con agrupacion fecha desocupacion');
            
            prc_aplica_distri(v_rd, v_rang_agru, v_tip_rang);
            
        ELSIF  v_tip_rang=3 then
            update co532_siniestro a set RANG_MORA = (select nom_ran from co532_rang_agru where tip_ran=3 and a.val_cap between val_ini and val_fin)
            where a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
            and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null;
            
            IF SQL%ROWCOUNT > 0 then
             prc_auditoria (v_cod_hist,5.2,'Asignacion 2','Siniestros actualizados en rango fecha mora: '||SQL%ROWCOUNT);
            END IF;
           
            prc_auditoria (v_cod_hist,6,'Asignacion 2','Inicia asignacion del siniestro con agrupacion fecha mora');
           
            prc_aplica_distri( v_rd, v_rang_agru, v_tip_rang);    
        ELSE
            b_ok:= 0;
        END IF;
    ELSE
        prc_auditoria (v_cod_hist,6,'Asignacion 2','Inicia asignacion del siniestro sin agrupacion');
        prc_aplica_distri(v_rd, v_rang_agru, v_tip_rang);
    END IF;      
 
END prc_algoritmo_distribucion;

/***************************************************************************
   NOMBRE:       prc_aplica_distri
   DESCRIPCION: hace la asignacion de los siniestros a los gestores de acuerdo a peso o % total.
   PARAMETROS DE ENTRADA: p_rd-codigo de la regla de distribucion.
                          ps_tip_agru tipo de agrupacion implementada por la regla de distribucion
                          ps_tip_rang tipo de rango agrupacion usada en la regla de distribucion.                    
   PARAMETROS DE SALIDA:  
                        
   MODIFICACIONES :
   VERSION      FECHA       AUTOR          REQUERIMIENTO          DESCRIPCION DEL CAMBIO
   ---------------------------------------------------------------------------------------------
   1.0      27/09/2017    Jmurillo         PF 21.1                      Creacion.
   ******************************************************************************/  

PROCEDURE prc_aplica_distri (p_rd in NUMBER , ps_tip_agru IN STRING, p_tip_rang IN NUMBER ) 
IS
 b_ok              NUMBER (1)  :=0;      /*Boolean que indica si existe el valor_variable en la regla de distribucion*/
 n_valor_variable_total     NUMBER (30,10)  :=0;
 
 --- CURSOR CON TODOS LOS SINIESTROS A DISTRIBUIR LOS SINIESTROS A DISTRIBUIR---
 Cursor cur_siniestros is
  select cod_sin, sucursal,RANG_DIN, RANG_MORA , RANG_FECHA from co532_siniestro 
  where fecha_proceso= trunc(sysdate) and REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  
  and COD_TIP_GES = 2
  and motivo_exclusion_cod_mot_exc is null and  tip_exc is null; 
 
-- RANGO DE DINERO
 cursor cur_gest_rango_din IS 
     select a.cod_gest codigo_gestor, nvl((((select sum (val_cap) from CO532_siniestro a, CO532_asignacion b , CO532_gest_loc c 
                    where a.cod_sin=b.SINIESTRO_COD_SIN and b.GESTOR_COD_GEST = c.GESTOR_COD_GEST
                    and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                    and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null 
                    and c.LOCALIZACION_COD_LOC=a.sucursal
                    and a.SUCURSAL = v_sucursal_sin  
                    AND a.RANG_DIN = v_rango_din ---RANGO DINERO
                    and b.GESTOR_COD_GEST=a.cod_gest) * 100)/n_valor_variable_total),0) porcentaje
     from CO532_gestor a, CO532_gest_loc b
     where a.cod_gest=b.GESTOR_COD_GEST
     and a.COD_GEST IN (select cod_gestor from CO532_temp_gestores)  -- CADENA STRING CON LOS CODIGOS DE LOS GESTORES.
     and a.est_gest='A'
     and b.LOCALIZACION_COD_LOC= v_sucursal_sin
     order by 2 asc;
  

 -- RANGO DE MORA 
  CURSOR cur_gest_rango_mor IS
     select a.cod_gest codigo_gestor, nvl((((select sum (val_cap) from CO532_siniestro a, CO532_asignacion b , CO532_gest_loc c 
                    where a.cod_sin=b.SINIESTRO_COD_SIN and b.GESTOR_COD_GEST = c.GESTOR_COD_GEST
                    and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                    and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null 
                    and c.LOCALIZACION_COD_LOC=a.sucursal
                    and a.SUCURSAL = v_sucursal_sin  
                    AND a.RANG_MORA = v_rango_mor -- RANGO MORA
                    and b.GESTOR_COD_GEST=a.cod_gest) * 100)/n_valor_variable_total),0) porcentaje
     from CO532_gestor a, CO532_gest_loc b
     where a.cod_gest=b.GESTOR_COD_GEST
     and a.COD_GEST IN (select cod_gestor from CO532_temp_gestores) -- CADENA STRING CON LOS CODIGOS DE LOS GESTORES.
     and a.est_gest='A'
     and b.LOCALIZACION_COD_LOC= v_sucursal_sin
     order by 2 asc;
     
-- RANGO DE DESOCUPACION     
  CURSOR cur_gest_rango_des IS 
     select a.cod_gest codigo_gestor, nvl((((select sum (val_cap) from CO532_siniestro a, CO532_asignacion b , CO532_gest_loc c 
                    where a.cod_sin=b.SINIESTRO_COD_SIN and b.GESTOR_COD_GEST = c.GESTOR_COD_GEST 
                    and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                    and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null
                    and c.LOCALIZACION_COD_LOC=a.sucursal
                    and a.SUCURSAL = v_sucursal_sin  
                    AND a.RANG_FECHA = v_rango_des -- RANGO FECHA DESOCUPACION
                    and b.GESTOR_COD_GEST=a.cod_gest) * 100)/n_valor_variable_total),0) porcentaje
     from CO532_gestor a, CO532_gest_loc b
     where a.cod_gest=b.GESTOR_COD_GEST
     and a.COD_GEST IN (select cod_gestor from CO532_temp_gestores) -- CADENA STRING CON LOS CODIGOS DE LOS GESTORES.
     and a.est_gest='A'
     and b.LOCALIZACION_COD_LOC= v_sucursal_sin
     order by 2 asc;
     
 

-- PARA CUANDO NO SE USA RANGO O ESTA SOLO POR SUCURSAL  
CURSOR cur_gest_total IS 
     select a.cod_gest codigo_gestor, nvl((((select sum (val_cap) from CO532_siniestro a, CO532_asignacion b , CO532_gest_loc c 
                    where a.cod_sin=b.SINIESTRO_COD_SIN and b.GESTOR_COD_GEST = c.GESTOR_COD_GEST
                    and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                    and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null
                    and c.LOCALIZACION_COD_LOC=a.sucursal 
                    and a.SUCURSAL = v_sucursal_sin
                    and b.GESTOR_COD_GEST=a.cod_gest) * 100)/n_valor_variable_total),0) porcentaje
     from CO532_gestor a, CO532_gest_loc b
     where a.cod_gest=b.GESTOR_COD_GEST
     and a.COD_GEST IN (select cod_gestor from CO532_temp_gestores) -- CADENA STRING CON LOS CODIGOS DE LOS GESTORES.
     and a.est_gest='A'
     and b.LOCALIZACION_COD_LOC= v_sucursal_sin
     order by 2 asc ; 

BEGIN
   IF ps_tip_agru in ('na','suc') THEN
   
        prc_auditoria (v_cod_hist,6.1,'Asignacion 2','Asignacion por sucursal o sin agrupamiento');
        
        FOR r_siniestros IN cur_siniestros
        LOOP
            --encuentra el total que tiene asignado el Gestor al momento de la distribucion
            v_sucursal_sin:=r_siniestros.sucursal;
            v_cod_sin:=r_siniestros.cod_sin;
            
            select sum (val_cap)
            into n_valor_variable_total
            from CO532_siniestro a, CO532_asignacion b , CO532_gest_loc c
            where a.cod_sin=b.SINIESTRO_COD_SIN
            and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
            and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null
            and c.LOCALIZACION_COD_LOC=a.sucursal
            and b.GESTOR_COD_GEST = c.GESTOR_COD_GEST 
            and a.SUCURSAL = r_siniestros.sucursal
            and b.GESTOR_COD_GEST IN (select cod_gestor from CO532_temp_gestores); 
        
      
            IF n_valor_variable_total = NULL THEN
                n_valor_variable_total :=1; --NO EXISTE NADA ASIGNADO ASIGNACION;
            END IF;
        
            FOR r_gest_total IN cur_gest_total
              LOOP
                  insert into CO532_asignacion  (SINIESTRO_COD_SIN,GESTOR_COD_GEST) values (v_cod_sin , r_gest_total.codigo_gestor);
                  prc_auditoria (v_cod_hist,6.2,'Asignacion 2','Asigna siniestro '|| v_cod_sin ||' a gestor - '|| r_gest_total.codigo_gestor);
                  b_ok:=1;
                  EXIT WHEN  b_ok=1;
            END LOOP;
        END LOOP;             
   ELSE
        IF v_tip_rang = 1 THEN 
        
         
          prc_auditoria (v_cod_hist,6.1,'Asignacion 2','Asignacion agrupada por rango dinero');
         
          FOR r_siniestros IN cur_siniestros
          LOOP
           
            v_sucursal_sin:=r_siniestros.sucursal;
            v_cod_sin:=r_siniestros.cod_sin;
            v_rango_din := r_siniestros.RANG_DIN;
            
            --Encuentra el total que tiene asignado el Gestor al momento de la distribucion por rango
            select sum (val_cap)
            into n_valor_variable_total
            from CO532_siniestro a, CO532_asignacion b , CO532_gest_loc c
            where a.cod_sin=b.SINIESTRO_COD_SIN
            and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
            and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null
            and c.LOCALIZACION_COD_LOC=a.sucursal
            and b.GESTOR_COD_GEST = c.GESTOR_COD_GEST 
            and a.SUCURSAL =v_sucursal_sin
            and b.GESTOR_COD_GEST IN (select cod_gestor from CO532_temp_gestores) 
            AND a.RANG_DIN = v_rango_din;  -- RANGO DE DINERO
            
            IF n_valor_variable_total = NULL THEN
                n_valor_variable_total :=1; --NO EXISTE NADA ASIGNADO ASIGNACION;
            END IF;
     
            FOR r_gest_rango_din IN cur_gest_rango_din
            LOOP
                insert into CO532_asignacion  (SINIESTRO_COD_SIN,GESTOR_COD_GEST) values (v_cod_sin , r_gest_rango_din.codigo_gestor);
                prc_auditoria (v_cod_hist,6.2,'Asignacion 2','Asigna siniestro '|| v_cod_sin ||' a gestor - '||  r_gest_rango_din.codigo_gestor);
                b_ok:=1;
                EXIT WHEN  b_ok=1;
            END LOOP;
         END LOOP;
        
        ELSIF v_tip_rang = 2 THEN
        
          prc_auditoria (v_cod_hist,6.1,'Asignacion 2','Asignacion agrupada por rango desocupacion');
         
          FOR r_siniestros IN cur_siniestros
          LOOP
           
            v_sucursal_sin:=r_siniestros.sucursal;
            v_cod_sin:=r_siniestros.cod_sin;
            v_rango_des := r_siniestros.RANG_FECHA;   
           
            --encuentra el total que tiene asignado el Gestor al momento de la distribucion rango desocupacion
            select sum (val_cap)
            into n_valor_variable_total
            from CO532_siniestro a, CO532_asignacion b , CO532_gest_loc c
            where a.cod_sin=b.SINIESTRO_COD_SIN
            and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
            and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null
            and c.LOCALIZACION_COD_LOC=a.sucursal
            and b.GESTOR_COD_GEST = c.GESTOR_COD_GEST 
            and a.SUCURSAL =v_sucursal_sin
            and b.GESTOR_COD_GEST IN (select cod_gestor from CO532_temp_gestores) -- CADENA sTRING CON LOS CODIGOS DE LOS GESTORES.
            AND a.RANG_FECHA = v_rango_des; -- RANGO DE FEHCA DESOCUPACION
      
            IF n_valor_variable_total = NULL THEN
                n_valor_variable_total :=1; --NO EXISTE NADA ASIGNADO ASIGNACION;
            END IF;
     
            FOR r_gest_rango_des IN cur_gest_rango_des
            LOOP
                insert into CO532_asignacion  (SINIESTRO_COD_SIN,GESTOR_COD_GEST) values (v_cod_sin , r_gest_rango_des.codigo_gestor);
                prc_auditoria (v_cod_hist,6.2,'Asignacion 2','Asigna siniestro '|| v_cod_sin ||' a gestor - '|| r_gest_rango_des.codigo_gestor);
                b_ok:=1;
                EXIT WHEN  b_ok=1;
            END LOOP;
          END LOOP;
          
        ELSIF   v_tip_rang = 3 THEN
          
          prc_auditoria (v_cod_hist,6.1,'Asignacion 2','Asignacion agrupada por rango mora');
          
          FOR r_siniestros IN cur_siniestros
          LOOP
           
            v_sucursal_sin:=r_siniestros.sucursal;
            v_cod_sin:=r_siniestros.cod_sin;
            v_rango_mor := r_siniestros.RANG_MORA;     
            
            --encuentra el total que tiene asignado el Gestor al momento de la distribucion rango MORA
            select sum (val_cap)
            into n_valor_variable_total
            from CO532_siniestro a, CO532_asignacion b , CO532_gest_loc c
            where a.cod_sin=b.SINIESTRO_COD_SIN
            and b.GESTOR_COD_GEST = c.GESTOR_COD_GEST
            and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
            and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null 
            and c.LOCALIZACION_COD_LOC=a.sucursal
            and a.SUCURSAL =v_sucursal_sin
            and b.GESTOR_COD_GEST IN (select cod_gestor from CO532_temp_gestores) -- CADENA sTRING CON LOS CODIGOS DE LOS GESTORES.
            AND a.RANG_MORA = v_rango_mor;-- RANGO DE MORA
      
            IF n_valor_variable_total = NULL THEN
                n_valor_variable_total :=1; --NO EXISTE NADA ASIGNADO ASIGNACION;
            END IF;
     
            FOR r_gest_rango_mor IN cur_gest_rango_mor
            LOOP
                insert into CO532_asignacion  (SINIESTRO_COD_SIN,GESTOR_COD_GEST) values (v_cod_sin , r_gest_rango_mor.codigo_gestor);
                prc_auditoria (v_cod_hist,6.2,'Asignacion 2','Asigna siniestro '|| v_cod_sin ||' a gestor - '|| r_gest_rango_mor.codigo_gestor);
                b_ok:=1;
                EXIT WHEN  b_ok=1;
            END LOOP;
          END LOOP;
        END IF;
   END IF;


END prc_aplica_distri;

/***************************************************************************
   NOMBRE:       prc_valida_gestores
   DESCRIPCION: Funciona para validar si existen gestores en la regla de distribucion que aplica para el siniestro
                con la sucursal.
   PARAMETROS DE ENTRADA: -P_RD, regla de distribucion encontrada.

   MODIFICACIONES :
   VERSION      FECHA       AUTOR          REQUERIMIENTO          DESCRIPCION DEL CAMBIO
   ---------------------------------------------------------------------------------------------
   1.0      25/10/2017    Jmurillo         PF 21.1                      Creacion.
   ******************************************************************************/
   PROCEDURE prc_valida_gestores (p_rd IN NUMBER) 
   IS
   
        n_gestores number :=0;
        
       CURSOR cur_gestores IS
        SELECT DISTINCT  b.cod_gest
                    INTO b_ok
                     FROM co532_var_regl a, co532_gestor b, co532_gest_loc c
                   WHERE b.cod_tip_gestor = a.variable_cod_var
                     AND b.cod_gest = c.gestor_cod_gest
                     AND c.localizacion_cod_loc = (select valor_variable from co532_valor_regla where tipo_var=3)
                     AND a.regla_distribucion_cod_reg_dis = p_rd
                     AND variable_tip_var = 1
                     AND b.est_gest = 'A';
   BEGIN
      delete from CO532_temp_gestores;
      FOR r_gestores IN cur_gestores
         LOOP
            insert into CO532_temp_gestores values (r_gestores.cod_gest);
            n_gestores:=n_gestores+1;
         END LOOP;
      prc_auditoria (v_cod_hist,4.1, 'Validando Gestores', 'Encuentra un total de '||n_gestores||' gestores para la asignacion');          
         
   END prc_valida_gestores;
 


/***************************************************************************
   NOMBRE:       prc_auditoria
   DESCRIPCION: almacena en co532_aud_dist, los pasos de la distribucion.
   PARAMETROS DE ENTRADA: -P_RD, regla de distribucion encontrada.
   PARAMETROS DE SALIDA:

   MODIFICACIONES :
   VERSION      FECHA       AUTOR          REQUERIMIENTO          DESCRIPCION DEL CAMBIO
   ---------------------------------------------------------------------------------------------
   1.0      19/09/2017    Jmurillo         PF 21.1                      Creacion.
   ******************************************************************************/
   procedure prc_auditoria ( p_cod_hist IN NUMBER, p_paso IN NUMBER, p_funcion IN VARCHAR, p_observacion IN VARCHAR)  IS
   BEGIN
      
      INSERT INTO co532_aud_dist(hist_distr_cod_his_dis, siniestro_cod_sin, cod_aud,paso, fecha, funcion, observacion)
                         VALUES (p_cod_hist, v_cod_sin, co532_sec_aud_dist.NEXTVAL,p_paso, SYSDATE, p_funcion, p_observacion);
   END prc_auditoria;
   
   /***************************************************************************
   NOMBRE:        prc_optimizar_distribucion_FP 
   DESCRIPCION: encuentra la distribucion mas optima posible.
   PARAMETROS DE ENTRADA: P_RD, regla de distribucion encontrada.
   
   PARAMETROS DE SALIDA:

   MODIFICACIONES :
   VERSION      FECHA       AUTOR          REQUERIMIENTO          DESCRIPCION DEL CAMBIO
   ---------------------------------------------------------------------------------------------
   1.0      26/09/2017    Jmurillo         PF 21.1                      Creacion.
   ******************************************************************************/
   
   PROCEDURE prc_optimizar_distribucion_FP(p_rd in NUMBER, p_tip_rang in NUMBER) IS

        v_id1 NUMBER;
        v_id2 NUMBER;
        v_val1 NUMBER;
        v_val2 NUMBER;
        v_val_med NUMBER;
        v_n NUMBER := 20000;
        v_m NUMBER := 5;
        v_n_med NUMBER;
        v_delta1 NUMBER;
        v_delta2 NUMBER;
        v_delta NUMBER;
        v_id_cobro1 NUMBER;
        v_id_cobro2 NUMBER;
        v_valor_cobro1 NUMBER;
        v_valor_cobro2 NUMBER;
        v_delta_cobro NUMBER;
        v_cambio1 boolean;
        v_cambio2 boolean;
        v_cobrador_eliminar NUMBER;
        
        Cursor cur_rangos_din is
         select nom_ran from co532_rang_agru where tip_ran= p_tip_rang order by 1;

   BEGIN
        
   IF p_tip_rang IS NULL THEN 
        --SE ENCUENTRA LA CANTIDAD TOTAL DE COBRADORES  JULIO MURILLO
        
        SELECT COUNT(distinct (b.gestor_cod_gest)) 
        INTO v_m
        FROM CO532_SINIESTRO A, CO532_ASIGNACION B
        WHERE A.COD_SIN= B.SINIESTRO_COD_SIN 
        and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
        and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null;
        
        --numero de deudas a distribuir  JULIO MURILLO
        
        SELECT COUNT( *) 
        INTO v_n
        FROM CO532_SINIESTRO A, CO532_ASIGNACION B
        WHERE A.COD_SIN= B.SINIESTRO_COD_SIN 
        and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
        and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null;  
   
        --Obtiene la media del rango JULIO MURILLO
        
        SELECT SUM (a.val_cap) / v_m
        INTO v_val_med
        FROM CO532_SINIESTRO A, CO532_ASIGNACION B
        WHERE A.COD_SIN= B.SINIESTRO_COD_SIN 
        and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
        and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null; 

       LOOP
          v_cambio1 := FALSE;
          
          SELECT MIN (gestor_cod_gest) KEEP (DENSE_RANK FIRST ORDER BY valor) id_che_first,
                 MIN (valor)KEEP (DENSE_RANK FIRST ORDER BY valor) valor_first,
                 MAX (gestor_cod_gest)KEEP (DENSE_RANK LAST ORDER BY valor) id_che_last,
                 MAX (valor)KEEP (DENSE_RANK LAST ORDER BY valor) valor_last
            INTO v_id1,
                 v_val1,
                 v_id2,
                 v_val2
             FROM (SELECT   gestor_cod_gest, SUM (val_cap) valor
                    FROM co532_siniestro a, co532_asignacion b
                   WHERE a.COD_SIN = b.siniestro_cod_sin
                    and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                    and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null
                   GROUP BY gestor_cod_gest);

          v_delta1 := v_val_med - v_val1;
          v_delta2 := v_val2 - v_val_med;
          v_delta := LEAST (v_delta1, v_delta2);
          
          
          FOR r1 IN (select b.gestor_cod_gest codigo_cobrador, b.siniestro_cod_sin id_siniestro, a.val_cap valor_deuda
                     from co532_siniestro a, co532_asignacion b 
                     WHERE a.COD_SIN = b.siniestro_cod_sin and b.gestor_cod_gest=v_id1
                     and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                     and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null
                     ORDER BY valor_deuda)
          LOOP
             v_cambio2 := FALSE;

             FOR r2 IN
                (SELECT MIN (b.siniestro_cod_sin)KEEP (DENSE_RANK LAST ORDER BY a.val_cap, b.siniestro_cod_sin DESC) id_siniestro,
                        MIN (a.val_cap) KEEP (DENSE_RANK LAST ORDER BY a.val_cap, b.siniestro_cod_sin DESC) valor_deuda
                   from co532_siniestro a, co532_asignacion b 
                   WHERE a.COD_SIN = b.siniestro_cod_sin 
                   and b.gestor_cod_gest=v_id2
                   and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                   and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null
                   AND r1.valor_deuda < a.val_cap
                   AND a.val_cap < r1.valor_deuda + v_delta)
             LOOP
                v_delta := v_delta - (r2.valor_deuda - r1.valor_deuda);
                EXIT WHEN v_delta IS NULL OR v_delta <= 0;

                UPDATE co532_asignacion
                   SET gestor_cod_gest = v_id2
                 WHERE siniestro_cod_sin = r1.id_siniestro;

                UPDATE  co532_asignacion
                   SET gestor_cod_gest = v_id1
                 WHERE siniestro_cod_sin = r2.id_siniestro;
                 
                 prc_auditoria (v_cod_hist,7.1, 'Optimizacion', 'Cambia el siniestro '||r1.id_siniestro ||' a '||v_id2);
                 prc_auditoria (v_cod_hist,7.1, 'Optimizacion', 'Cambia el siniestro '||r2.id_siniestro ||' a '||v_id1);
                v_cambio2 := TRUE;
                v_cambio1 := TRUE;
             END LOOP;

             EXIT WHEN NOT v_cambio2;
          END LOOP;

          EXIT WHEN NOT v_cambio1;
       END LOOP;
     END IF;
     
     IF p_tip_rang = 1 THEN 
        
        FOR r_rangos_din IN  cur_rangos_din
         LOOP
            --SE ENCUENTRA LA CANTIDAD TOTAL DE COBRADORES  JULIO MURILLO
                SELECT COUNT(distinct (b.gestor_cod_gest)) 
                INTO v_m
                FROM CO532_SINIESTRO A, CO532_ASIGNACION B
                WHERE A.COD_SIN= B.SINIESTRO_COD_SIN 
                and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null;
        
            --numero de deudas a distribuir  JULIO MURILLO
        
                SELECT COUNT( *) 
                INTO v_n
                FROM CO532_SINIESTRO A, CO532_ASIGNACION B
                WHERE A.COD_SIN= B.SINIESTRO_COD_SIN 
                and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null AND a.RANG_DIN = r_rangos_din.nom_ran;  

   
            --Obtiene la media del rango JULIO MURILLO
        
                SELECT SUM (a.val_cap) / v_m
                INTO v_val_med
                FROM CO532_SINIESTRO A, CO532_ASIGNACION B
                WHERE A.COD_SIN= B.SINIESTRO_COD_SIN 
                and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null AND a.RANG_DIN = r_rangos_din.nom_ran; 

                LOOP
                    v_cambio1 := FALSE;
          
                    SELECT MIN (gestor_cod_gest) KEEP (DENSE_RANK FIRST ORDER BY valor) id_che_first,
                    MIN (valor)KEEP (DENSE_RANK FIRST ORDER BY valor) valor_first,
                    MAX (gestor_cod_gest)KEEP (DENSE_RANK LAST ORDER BY valor) id_che_last,
                    MAX (valor)KEEP (DENSE_RANK LAST ORDER BY valor) valor_last
                    INTO v_id1,v_val1,v_id2,v_val2
                    FROM (SELECT   gestor_cod_gest, SUM (val_cap) valor
                            FROM co532_siniestro a, co532_asignacion b
                            WHERE a.COD_SIN = b.siniestro_cod_sin
                            and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                            and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null AND a.RANG_DIN = r_rangos_din.nom_ran
                            GROUP BY gestor_cod_gest);

                    v_delta1 := v_val_med - v_val1;
                    v_delta2 := v_val2 - v_val_med;
                    v_delta := LEAST (v_delta1, v_delta2);
          
          
                    FOR r1 IN (select b.gestor_cod_gest codigo_cobrador, b.siniestro_cod_sin id_siniestro, a.val_cap valor_deuda
                                from co532_siniestro a, co532_asignacion b 
                                WHERE a.COD_SIN = b.siniestro_cod_sin and b.gestor_cod_gest=v_id1
                                and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                                and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null AND a.RANG_DIN = r_rangos_din.nom_ran
                                ORDER BY valor_deuda)
                    LOOP
                        v_cambio2 := FALSE;

                            FOR r2 IN (SELECT MIN (b.siniestro_cod_sin)KEEP (DENSE_RANK LAST ORDER BY a.val_cap, b.siniestro_cod_sin DESC) id_siniestro,
                                        MIN (a.val_cap) KEEP (DENSE_RANK LAST ORDER BY a.val_cap, b.siniestro_cod_sin DESC) valor_deuda
                                        from co532_siniestro a, co532_asignacion b 
                                        WHERE a.COD_SIN = b.siniestro_cod_sin 
                                        and b.gestor_cod_gest=v_id2
                                        and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                                        and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null AND a.RANG_DIN = r_rangos_din.nom_ran
                                        AND r1.valor_deuda < a.val_cap
                                        AND a.val_cap < r1.valor_deuda + v_delta)
                            LOOP
                                v_delta := v_delta - (r2.valor_deuda - r1.valor_deuda);
                                EXIT WHEN v_delta IS NULL OR v_delta <= 0;

                                UPDATE co532_asignacion SET gestor_cod_gest = v_id2
                                WHERE siniestro_cod_sin = r1.id_siniestro;

                                UPDATE  co532_asignacion SET gestor_cod_gest = v_id1
                                WHERE siniestro_cod_sin = r2.id_siniestro;
                 
                                prc_auditoria (v_cod_hist,7.1, 'Optimizacion', 'Cambia el siniestro '||r1.id_siniestro ||' a '||v_id2);
                                prc_auditoria (v_cod_hist,7.1, 'Optimizacion', 'Cambia el siniestro '||r2.id_siniestro ||' a '||v_id1);
                                v_cambio2 := TRUE;
                                v_cambio1 := TRUE;
                            END LOOP;

                    EXIT WHEN NOT v_cambio2;
                    END LOOP;

                EXIT WHEN NOT v_cambio1;
                END LOOP;
         END LOOP;
     END IF;
     
     IF p_tip_rang = 2 THEN 
        
        FOR r_rangos_din IN  cur_rangos_din
         LOOP
            --SE ENCUENTRA LA CANTIDAD TOTAL DE COBRADORES  JULIO MURILLO
                SELECT COUNT(distinct (b.gestor_cod_gest)) 
                INTO v_m
                FROM CO532_SINIESTRO A, CO532_ASIGNACION B
                WHERE A.COD_SIN= B.SINIESTRO_COD_SIN 
                and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null;
        
            --numero de deudas a distribuir  JULIO MURILLO
        
                SELECT COUNT( *) 
                INTO v_n
                FROM CO532_SINIESTRO A, CO532_ASIGNACION B
                WHERE A.COD_SIN= B.SINIESTRO_COD_SIN 
                and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null AND a.RANG_FECHA = r_rangos_din.nom_ran;  

   
            --Obtiene la media del rango JULIO MURILLO
        
                SELECT SUM (a.val_cap) / v_m
                INTO v_val_med
                FROM CO532_SINIESTRO A, CO532_ASIGNACION B
                WHERE A.COD_SIN= B.SINIESTRO_COD_SIN 
                and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null AND a.RANG_FECHA = r_rangos_din.nom_ran; 

                LOOP
                    v_cambio1 := FALSE;
          
                    SELECT MIN (gestor_cod_gest) KEEP (DENSE_RANK FIRST ORDER BY valor) id_che_first,
                    MIN (valor)KEEP (DENSE_RANK FIRST ORDER BY valor) valor_first,
                    MAX (gestor_cod_gest)KEEP (DENSE_RANK LAST ORDER BY valor) id_che_last,
                    MAX (valor)KEEP (DENSE_RANK LAST ORDER BY valor) valor_last
                    INTO v_id1,v_val1,v_id2,v_val2
                    FROM (SELECT   gestor_cod_gest, SUM (val_cap) valor
                            FROM co532_siniestro a, co532_asignacion b
                            WHERE a.COD_SIN = b.siniestro_cod_sin
                            and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                            and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null AND a.RANG_FECHA = r_rangos_din.nom_ran
                            GROUP BY gestor_cod_gest);

                    v_delta1 := v_val_med - v_val1;
                    v_delta2 := v_val2 - v_val_med;
                    v_delta := LEAST (v_delta1, v_delta2);
          
          
                    FOR r1 IN (select b.gestor_cod_gest codigo_cobrador, b.siniestro_cod_sin id_siniestro, a.val_cap valor_deuda
                                from co532_siniestro a, co532_asignacion b 
                                WHERE a.COD_SIN = b.siniestro_cod_sin and b.gestor_cod_gest=v_id1
                                and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                                and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null AND a.RANG_FECHA = r_rangos_din.nom_ran
                                ORDER BY valor_deuda)
                    LOOP
                        v_cambio2 := FALSE;

                            FOR r2 IN (SELECT MIN (b.siniestro_cod_sin)KEEP (DENSE_RANK LAST ORDER BY a.val_cap, b.siniestro_cod_sin DESC) id_siniestro,
                                        MIN (a.val_cap) KEEP (DENSE_RANK LAST ORDER BY a.val_cap, b.siniestro_cod_sin DESC) valor_deuda
                                        from co532_siniestro a, co532_asignacion b 
                                        WHERE a.COD_SIN = b.siniestro_cod_sin 
                                        and b.gestor_cod_gest=v_id2
                                        and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                                        and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null AND a.RANG_FECHA = r_rangos_din.nom_ran
                                        AND r1.valor_deuda < a.val_cap
                                        AND a.val_cap < r1.valor_deuda + v_delta)
                            LOOP
                                v_delta := v_delta - (r2.valor_deuda - r1.valor_deuda);
                                EXIT WHEN v_delta IS NULL OR v_delta <= 0;

                                UPDATE co532_asignacion SET gestor_cod_gest = v_id2
                                WHERE siniestro_cod_sin = r1.id_siniestro;

                                UPDATE  co532_asignacion SET gestor_cod_gest = v_id1
                                WHERE siniestro_cod_sin = r2.id_siniestro;
                 
                                prc_auditoria (v_cod_hist,7.1, 'Optimizacion', 'Cambia el siniestro '||r1.id_siniestro ||' a '||v_id2);
                                prc_auditoria (v_cod_hist,7.1, 'Optimizacion', 'Cambia el siniestro '||r2.id_siniestro ||' a '||v_id1);
                                v_cambio2 := TRUE;
                                v_cambio1 := TRUE;
                            END LOOP;

                    EXIT WHEN NOT v_cambio2;
                    END LOOP;

                EXIT WHEN NOT v_cambio1;
                END LOOP;
         END LOOP;
     END IF;
     
     IF p_tip_rang = 3 THEN 
        
        FOR r_rangos_din IN  cur_rangos_din
         LOOP
            --SE ENCUENTRA LA CANTIDAD TOTAL DE COBRADORES  JULIO MURILLO
                SELECT COUNT(distinct (b.gestor_cod_gest)) 
                INTO v_m
                FROM CO532_SINIESTRO A, CO532_ASIGNACION B
                WHERE A.COD_SIN= B.SINIESTRO_COD_SIN 
                and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null;
        
            --numero de deudas a distribuir  JULIO MURILLO
            
                  
                SELECT COUNT( *) 
                INTO v_n
                FROM CO532_SINIESTRO A, CO532_ASIGNACION B
                WHERE A.COD_SIN= B.SINIESTRO_COD_SIN 
                and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null AND a.RANG_MORA = r_rangos_din.nom_ran;  

   
            --Obtiene la media del rango JULIO MURILLO
        
                SELECT SUM (a.val_cap) / v_m
                INTO v_val_med
                FROM CO532_SINIESTRO A, CO532_ASIGNACION B
                WHERE A.COD_SIN= B.SINIESTRO_COD_SIN 
                and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null AND a.RANG_MORA = r_rangos_din.nom_ran; 

                LOOP
                    v_cambio1 := FALSE;
          
                    SELECT MIN (gestor_cod_gest) KEEP (DENSE_RANK FIRST ORDER BY valor) id_che_first,
                    MIN (valor)KEEP (DENSE_RANK FIRST ORDER BY valor) valor_first,
                    MAX (gestor_cod_gest)KEEP (DENSE_RANK LAST ORDER BY valor) id_che_last,
                    MAX (valor)KEEP (DENSE_RANK LAST ORDER BY valor) valor_last
                    INTO v_id1,v_val1,v_id2,v_val2
                    FROM (SELECT   gestor_cod_gest, SUM (val_cap) valor
                            FROM co532_siniestro a, co532_asignacion b
                            WHERE a.COD_SIN = b.siniestro_cod_sin
                            and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                            and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null AND a.RANG_MORA = r_rangos_din.nom_ran
                            GROUP BY gestor_cod_gest);

                    v_delta1 := v_val_med - v_val1;
                    v_delta2 := v_val2 - v_val_med;
                    v_delta := LEAST (v_delta1, v_delta2);
          
          
                    FOR r1 IN (select b.gestor_cod_gest codigo_cobrador, b.siniestro_cod_sin id_siniestro, a.val_cap valor_deuda
                                from co532_siniestro a, co532_asignacion b 
                                WHERE a.COD_SIN = b.siniestro_cod_sin and b.gestor_cod_gest=v_id1
                                and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                                and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null AND a.RANG_MORA = r_rangos_din.nom_ran
                                ORDER BY valor_deuda)
                    LOOP
                        v_cambio2 := FALSE;

                            FOR r2 IN (SELECT MIN (b.siniestro_cod_sin)KEEP (DENSE_RANK LAST ORDER BY a.val_cap, b.siniestro_cod_sin DESC) id_siniestro,
                                        MIN (a.val_cap) KEEP (DENSE_RANK LAST ORDER BY a.val_cap, b.siniestro_cod_sin DESC) valor_deuda
                                        from co532_siniestro a, co532_asignacion b 
                                        WHERE a.COD_SIN = b.siniestro_cod_sin 
                                        and b.gestor_cod_gest=v_id2
                                        and a.fecha_proceso= trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS= p_rd  and a.COD_TIP_GES = 2
                                        and a.motivo_exclusion_cod_mot_exc is null and  a.tip_exc is null AND a.RANG_MORA = r_rangos_din.nom_ran
                                        AND r1.valor_deuda < a.val_cap
                                        AND a.val_cap < r1.valor_deuda + v_delta)
                            LOOP
                                v_delta := v_delta - (r2.valor_deuda - r1.valor_deuda);
                                EXIT WHEN v_delta IS NULL OR v_delta <= 0;

                                UPDATE co532_asignacion SET gestor_cod_gest = v_id2
                                WHERE siniestro_cod_sin = r1.id_siniestro;

                                UPDATE  co532_asignacion SET gestor_cod_gest = v_id1
                                WHERE siniestro_cod_sin = r2.id_siniestro;
                 
                                prc_auditoria (v_cod_hist,7.1, 'Optimizacion', 'Cambia el siniestro '||r1.id_siniestro ||' a '||v_id2);
                                prc_auditoria (v_cod_hist,7.1, 'Optimizacion', 'Cambia el siniestro '||r2.id_siniestro ||' a '||v_id1);
                                v_cambio2 := TRUE;
                                v_cambio1 := TRUE;
                            END LOOP;

                    EXIT WHEN NOT v_cambio2;
                    END LOOP;

                EXIT WHEN NOT v_cambio1;
                END LOOP;
         END LOOP;
     END IF;

   END prc_optimizar_distribucion_FP;
   
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
   procedure prc_limpiar ( p_rd IN VARCHAR)  IS
   BEGIN
   
     prc_auditoria(v_cod_hist,1.1,'Limpia Siniestros', 'Limpia los siniestros con regla de distribucion '||p_rd);
      
     
     delete from co532_asignacion where siniestro_cod_sin in (select cod_sin from co532_siniestro where REGLA_DISTRIBUCION_COD_REG_DIS = p_rd);
     
     update co532_siniestro 
     set MOTIVO_EXCLUSION_COD_MOT_EXC = null, fecha_proceso=null,TIP_EXC = NULL,
         rang_fecha=null, rang_mora=null, rang_din=null, REGLA_DISTRIBUCION_COD_REG_DIS = null
     where REGLA_DISTRIBUCION_COD_REG_DIS = p_rd;
          
     prc_auditoria(v_cod_hist,1.2,'Limpia Siniestros', 'Limpia en total '||SQL%ROWCOUNT||' Siniestros');
     
   END prc_limpiar;
   
      /***************************************************************************
   NOMBRE:       prc_historico
   DESCRIPCION:
   PARAMETROS DE ENTRADA: -P_RD, regla de distribucion encontrada.
   PARAMETROS DE SALIDA:

   MODIFICACIONES :
   VERSION      FECHA       AUTOR          REQUERIMIENTO          DESCRIPCION DEL CAMBIO
   ---------------------------------------------------------------------------------------------
   1.0      19/09/2017    Jmurillo         PF 21.1                      Creacion.
   ******************************************************************************/
   procedure prc_det_hist_distr ( p_cod_hist IN NUMBER)  IS
   BEGIN
   
     insert into co532_det_hist_distr
     select co532_sec_det_hist_dist.NEXTVAL,p_cod_hist, a.cod_sin,a.sucursal,a.tip_prod, a.subti_prod , a.est_sin, a.est_pag,
     a.tip_amp, a.tip_pol, a.area, a.ubicacion, a.est_ali, a.val_cap, a.val_col,b.gestor_cod_gest,null, a.fecha_proceso, a.COD_TIP_GES, 
     a.tip_exc, a.rang_fecha, a.rang_mora, a.rang_din, a.fecha_ing, a.fecha_mora, a.fech_desoc, a.poliza
     from co532_siniestro a, co532_asignacion b
     where a.cod_sin=b.siniestro_cod_sin
     and fecha_proceso=trunc(sysdate) and REGLA_DISTRIBUCION_COD_REG_DIS = v_rd;
     
     
     insert into co532_det_hist_distr
     select co532_sec_det_hist_dist.NEXTVAL,p_cod_hist, a.cod_sin,a.sucursal,a.tip_prod, a.subti_prod , a.est_sin, a.est_pag,
     a.tip_amp, a.tip_pol, a.area, a.ubicacion, a.est_ali, a.val_cap, a.val_col,null,null, a.fecha_proceso, a.COD_TIP_GES, 
     a.tip_exc, a.rang_fecha, a.rang_mora, a.rang_din, a.fecha_ing, a.fecha_mora, a.fech_desoc, a.poliza
     from co532_siniestro a
     where a.fecha_proceso=trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS = v_rd
     and a.cod_sin not in (select siniestro_cod_sin from co532_asignacion);   
     
   END prc_det_hist_distr;
   
   
PROCEDURE prc_pruebas (p_rd in NUMBER) IS
    PRAGMA autonomous_transaction;
 BEGIN
    DELETE FROM CO532_PRUEBA;
    insert into co532_prueba 
    (select  a.REGLA_DISTRIBUCION_COD_REG_DIS, c.cod_gest, c.NOMBRE, a.RANG_DIN, count (*) cantidad, sum(a.val_cap) Valores
    from co532_siniestro a, co532_asignacion b, co532_gestor c
    where a.FECHA_PROCESO = trunc(sysdate) and a.REGLA_DISTRIBUCION_COD_REG_DIS=V_RD
    and a.COD_SIN = b.SINIESTRO_COD_SIN and b.GESTOR_COD_GEST = c.COD_GEST
    group by a.REGLA_DISTRIBUCION_COD_REG_DIS, c.cod_gest,c.NOMBRE, a.RANG_DIN );
    DBMS_OUTPUT.put_line('inserto: '|| SQL%ROWCOUNT);  
    commit;
 END prc_pruebas;
   
END CO532_PKG_ASIG_VIGENTES; 
/

