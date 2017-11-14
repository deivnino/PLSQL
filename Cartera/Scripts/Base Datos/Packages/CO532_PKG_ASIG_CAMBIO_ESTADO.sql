CREATE OR REPLACE PACKAGE ADMSISA.CO532_PKG_ASIG_CAMBIO_ESTADO IS

PROCEDURE prc_aplica_distri ( ps_tip_agru IN STRING, p_tip_rang IN NUMBER );

PROCEDURE prc_algoritmo_distribucion (p_rd in NUMBER) ;

FUNCTION fct_ident_regla (p_id_siniestro IN NUMBER)      RETURN NUMBER;

FUNCTION fct_variables_sin (p_tip_var IN NUMBER, p_val_var IN STRING) RETURN NUMBER;

FUNCTION fct_valida_gestores ( p_rd IN NUMBER ) RETURN STRING;

FUNCTION fct_exclusiones (p_rd IN NUMBER) RETURN NUMBER;

PROCEDURE prc_asignar_siniestro ( p_cod_sin in NUMBER, p_nuevo_estado in VARCHAR, p_prueba in NUMBER);

PROCEDURE prc_marcar_excl_sin (p_id_siniestro IN NUMBER, p_cod_excl IN NUMBER);

PROCEDURE prc_auditoria (p_cod_hist IN NUMBER, p_paso in NUMBER, p_funcion in VARCHAR , p_observacion in VARCHAR  );
  


END CO532_PKG_ASIG_CAMBIO_ESTADO; 
/

CREATE OR REPLACE PACKAGE BODY ADMSISA.CO532_PKG_ASIG_CAMBIO_ESTADO

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
   v_gestores                   STRING (30)    := NULL;
   v_exclusiones                NUMBER (4)     := NULL;
   v_ok                         NUMBER (1)     := NULL;
   v_tipo_distri                NUMBER (10)    := NULL;
   v_nuevo_estado               varchar(10)    := NULL;
   v_cod_hist                   NUMBER (10)    := NULL;
   
      
   --INFORMACION DEL SINIESTRO
   v_cod_sin                    NUMBER (10)    := NULL;
   v_val_cap_sin                NUMBER (15,3)  := NULL;
   v_val_col_sin                NUMBER (15,3)  := NULL;
   v_fecha_mora                 DATE           := NULL;
   v_fech_desoc                 DATE           := NULL;
   v_cod_tip_gest               NUMBER         := NULL;
   v_sucursal_sin               VARCHAR(10)    := NULL;
   v_fecha_ing_sin              DATE           :=NULL;
   v_cod_gest                   NUMBER         :=NULL;
   v_tip_pol_sin                VARCHAR(5)     :=NULL;
   v_area_sin                   VARCHAR(5)     :=NULL;
   v_ubicacion_sin              VARCHAR(5)     :=NULL;
   v_est_ali_sin                VARCHAR(5)     :=NULL;
   v_tipo_amp_sin               VARCHAR(5)     :=NULL;
   v_tip_prod_sin               NUMBER         :=NULL;
   v_subti_prod_sin             VARCHAR(4)     :=NULL;
   v_est_sin                    VARCHAR(4)     :=NULL;
   v_est_pago_sin               VARCHAR(4)     :=NULL;
                 
PROCEDURE prc_asignar_siniestro ( p_cod_sin in NUMBER, p_nuevo_estado in VARCHAR, p_prueba in NUMBER) 
   IS
   BEGIN 
    v_cod_sin :=p_cod_sin;
    v_nuevo_estado :=p_nuevo_estado;
    v_cod_hist:=co532_sec_hist_distr.nextval;
    insert into CO532_hist_distr  (COD_HIS_DIS, FECHA, TIPO_DISTRIBUCION_COD_TIP_DIS, DESCRIPCION, USUARIO)
    values (v_cod_hist, SYSDATE, 'TIPO DE DISTRIBUCION USADA' ,'CAMBIO DE ESTADO SINIESTRO',USER);
        
    prc_auditoria(v_cod_hist,1,'Inicio Proceso', 'Inserta encabezado del Historico distribuci?n numero -'|| V_COD_HIST);

     
    SELECT VAL_CAP, FECHA_MORA, COD_TIP_GES, SUCURSAL, RANG_DIN ,FECHA_ING ,FECHA_MORA, RANG_FECHA, RANG_MORA, VAL_COL,
    TIP_POL,AREA,UBICACION,EST_ALI,TIP_AMP, TIP_PROD ,SUBTI_PROD,EST_SIN ,EST_PAG
    INTO v_val_cap_sin, v_fecha_mora, v_cod_tip_gest,v_sucursal_sin,v_rango_din,v_fecha_ing_sin, v_fecha_mora,v_rang_fec, v_rango_mor, v_val_col_sin,
    v_tip_pol_sin, v_area_sin, v_ubicacion_sin, v_est_ali_sin,v_tipo_amp_sin, v_tip_prod_sin, v_subti_prod_sin, v_est_sin, v_est_pago_sin 
    FROM CO532_SINIESTRO WHERE cod_sin = v_cod_sin;
    
    prc_auditoria (V_COD_HIST,2, 'Datos Siniestro', 'Consulta datos del siniestro -' || v_cod_sin);
    
    prc_auditoria (v_cod_hist,3,'Identifica Regla a Usar','Valida dato x dato siniestro contra variables de reglas, siniestro -'|| v_cod_sin);
     
    v_rd := fct_ident_regla (v_cod_sin);
    
    IF v_rd = -1 THEN
        prc_auditoria (v_cod_hist,3.4,'NO HAY REGLA','SALE DEL PROCESO');
         prc_marcar_excl_sin (v_cod_sin,1);
      RETURN;
    END IF;
        
     prc_auditoria (v_cod_hist,4,'Valida Gestores','Valida si existen gestores para asignar de acuerdo a la regla distribucion'); 
     v_gestores := fct_valida_gestores (v_rd);
     
     IF v_gestores = 0 THEN
       prc_auditoria (v_cod_hist,4.1,'NO HAY GESTORES','SALE DEL PROCESO');
       prc_marcar_excl_sin (v_cod_sin,2);
       RETURN;
     END IF;
     
     prc_auditoria(v_cod_hist,5,'Valida exclusiones','Valida las exclusiones definidas en la regla distribucion -'|| v_rd);
     v_exclusiones := fct_exclusiones (v_rd);
     
     IF v_exclusiones > 0 THEN
       prc_marcar_excl_sin (v_cod_sin,v_exclusiones);
       prc_auditoria (v_cod_hist,5.3,'EXCLUIDO','SALE DEL PROCESO');
       RETURN;
     END IF;
     
     
     prc_auditoria (v_cod_hist,6,'Asignacion','Inicia la asignacion');
     
     prc_algoritmo_distribucion (v_rd);
     
     IF v_ok = 1 THEN
     
        update CO532_siniestro set FECHA_PROCESO = sysdate, REGLA_DISTRIBUCION_COD_REG_DIS=null where cod_sin=v_cod_sin;
        prc_auditoria (v_cod_hist,8,'Actualiza siniestro','actualiza fecha de proceso y regla distribucion -'|| v_cod_sin);
     
        select GESTOR_COD_GEST into v_cod_gest from CO532_asignacion where SINIESTRO_COD_SIN =v_cod_sin;
        
        UPDATE co532_hist_distr SET reg_dist = v_rd, tipo_distribucion_cod_tip_dis = v_tipo_distri WHERE cod_his_dis = v_cod_hist;
        
        prc_auditoria (v_cod_hist,9,'Inserta detalle historico','Inserta detalle historico del siniestro');
        
        insert into CO532_det_hist_distr (COD_DET_HIST_DIS,HIS_DIST_COD_HIS_DIS,SINIESTRO_COD_SIN,SUCURSAL,TIPO_PROD ,SUBTIP_PROD,EST_SIN ,EST_PAG,TIP_AMP,
                                      TIP_POL,AREA,UBICACION,EST_ALI, VAL_CAP,VAL_COL,COD_GEST_CAP,COD_GEST_COL,FECHA_PROCESO,COD_TIP_GEST,TIPO_EXCL,
                                      RANG_FECHA,RANG_MORA,RANG_DIN ,FECH_ING ,FECHA_MORA)
        Values (CO532_sec_det_hist_dist.nextval,v_cod_hist, v_cod_sin,v_sucursal_sin, v_tip_prod_sin, v_subti_prod_sin, v_est_sin, v_est_pago_sin, v_tipo_amp_sin, 
                        v_tip_pol_sin, v_area_sin, v_ubicacion_sin, v_est_ali_sin, v_val_cap_sin,v_val_col_sin ,v_cod_gest,null, sysdate,v_cod_tip_gest,null,
                        v_rang_fec, v_rango_mor,v_rango_din,v_fecha_ing_sin, v_fecha_mora);
                        
        prc_auditoria (v_cod_hist,10,'EXITOSO','FIN DE ASIGNACION');                
        COMMIT;
     END IF;
     
     EXCEPTION
        WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('Error: '|| SQLERRM);  
        RAISE_APPLICATION_ERROR (-20700, SQLERRM ); 
                        
    END prc_asignar_siniestro; 
    
/***************************************************************************
   NOMBRE:       prc_algoritmo_distribucion
   DESCRIPCION: .
   PARAMETROS DE ENTRADA: -P_RD, regla de distribucion encontrada.                             
   PARAMETROS DE SALIDA: b_ok: 
                        
   MODIFICACIONES :
   VERSION      FECHA       AUTOR          REQUERIMIENTO          DESCRIPCION DEL CAMBIO
   ---------------------------------------------------------------------------------------------
   1.0      27/09/2017    Jmurillo         PF 21.1                      Creacion.
   ******************************************************************************/  
   
PROCEDURE prc_algoritmo_distribucion (p_rd in NUMBER) 
IS
 b_ok         NUMBER (1)     :=1;      /*Boolean que indica si existe el valor en la regla de distribucion*/
            
BEGIN
    

    SELECT TIP_AGRU, TIP_RAN
         INTO  v_rang_agru,  v_tip_rang     
         FROM CO532_TIP_DISTR 
         WHERE COD_TIP_DIS= v_tipo_distri; 
    
    
    IF v_rang_agru in ('ran','suc ran' ) THEN
        prc_auditoria (v_cod_hist,6.1,'Asignacion 1','Usa agrupacion por rango');
        IF v_tip_rang = 1 THEN
            BEGIN
             SELECT NOM_RAN INTO v_rango_din
             FROM CO532_RANG_AGRU WHERE v_val_cap_sin BETWEEN VAL_INI AND VAL_FIN AND TIP_RAN=v_tip_rang;
             EXCEPTION 
              WHEN NO_DATA_FOUND THEN
                b_ok :=0; 
                prc_auditoria (v_cod_hist,6.1,'Asignacion 1','No encuentra rango de dinero');
            END;
             prc_auditoria (v_cod_hist,6.2,'Asignacion 1','Tipo Agrupacion por dinero actualiza informacion del siniestro');
            UPDATE CO532_SINIESTRO SET RANG_DIN = v_rango_din WHERE COD_SIN=v_cod_sin;
            
            prc_auditoria (v_cod_hist,7,'Asignacion 2','Inicia asignacion del siniestro con agrupacion');
            prc_aplica_distri(v_rang_agru, v_tip_rang);
        ELSIF  v_tip_rang=2 then
            BEGIN
             SELECT NOM_RAN INTO v_rango_des
             FROM CO532_RANG_AGRU WHERE (trunc(sysdate) -  trunc(v_fech_desoc)) BETWEEN VAL_INI AND VAL_FIN AND TIP_RAN=v_tip_rang;
             EXCEPTION 
              WHEN NO_DATA_FOUND THEN
                b_ok :=0;
                prc_auditoria (v_cod_hist,6.1,'Asignacion 1','No encuentra rango desocupacion'); 
            END;
            prc_auditoria (v_cod_hist,6.2,'Asignacion 1','Tipo Agrupacion por desocupacion actualiza informacion del siniestro');
            UPDATE CO532_SINIESTRO SET RANG_FECHA = v_rango_des WHERE COD_SIN=v_cod_sin;
            
            prc_auditoria (v_cod_hist,7,'Asignacion 2','Inicia asignacion del siniestro con agrupacion');
            prc_aplica_distri(v_rang_agru, v_tip_rang);
        ELSIF  v_tip_rang=3 then
            BEGIN
             SELECT NOM_RAN INTO v_rango_mor
             FROM CO532_RANG_AGRU WHERE (trunc(sysdate) -  trunc(v_fecha_mora)) BETWEEN VAL_INI AND VAL_FIN AND TIP_RAN=v_tip_rang;
             EXCEPTION 
              WHEN NO_DATA_FOUND THEN
                b_ok :=0; 
                prc_auditoria (v_cod_hist,6.1,'Asignacion 1','No encuentra rango de mora');
            END;
            prc_auditoria (v_cod_hist,6.2,'Asignacion 1','Tipo Agrupacion por mora actualiza informacion del siniestro');
            UPDATE CO532_SINIESTRO SET RANG_MORA = v_rango_mor WHERE COD_SIN=v_cod_sin;
            
            prc_auditoria (v_cod_hist,7,'Asignacion 2','Inicia asignacion del siniestro con agrupacion');
            prc_aplica_distri(v_rang_agru, v_tip_rang);    
        ELSE
            b_ok:= 0;
        END IF;
    ELSE
        prc_auditoria (v_cod_hist,7,'Asignacion 2','Inicia asignacion del siniestro sin agrupacion');
        prc_aplica_distri(v_rang_agru, v_tip_rang);
    END IF;      

 
  
END prc_algoritmo_distribucion;

/***************************************************************************
   NOMBRE:       prc_aplica_distri
   DESCRIPCION: .
   PARAMETROS DE ENTRADA:                    
   PARAMETROS DE SALIDA: b_ok: 
                        
   MODIFICACIONES :
   VERSION      FECHA       AUTOR          REQUERIMIENTO          DESCRIPCION DEL CAMBIO
   ---------------------------------------------------------------------------------------------
   1.0      27/09/2017    Jmurillo         PF 21.1                      Creacion.
   ******************************************************************************/  

PROCEDURE prc_aplica_distri ( ps_tip_agru IN STRING, p_tip_rang IN NUMBER )
IS
 b_ok              NUMBER (1)  :=0;      /*Boolean que indica si existe el valor en la regla de distribucion*/
 n_valor_total     NUMBER (30,10)  :=0;
 
 cursor cur_gest_rango_din IS -- RANGO DE DINERO
     select a.cod_gest codigo_gestor, nvl((((select sum (val_cap) from CO532_siniestro a, CO532_asignacion b , CO532_gest_loc c 
                    where a.cod_sin=b.SINIESTRO_COD_SIN and b.GESTOR_COD_GEST = c.GESTOR_COD_GEST 
                    and c.LOCALIZACION_COD_LOC=a.sucursal
                    and a.COD_TIP_GES= v_cod_tip_gest -- SEGUN TIPO DE GESTION QUE VIENE DEL SINIESTRO
                    and a.SUCURSAL = v_sucursal_sin  AND a.RANG_DIN = v_rango_din
                    and b.GESTOR_COD_GEST=a.cod_gest) * 100)/n_valor_total),0) porcentaje
     from CO532_gestor a, CO532_gest_loc b
     where a.cod_gest=b.GESTOR_COD_GEST
     and a.COD_GEST IN (select cod_gestor from CO532_temp_gestores)  -- CADENA STRING CON LOS CODIGOS DE LOS GESTORES.
     and est_gest='A'
     and b.LOCALIZACION_COD_LOC= v_sucursal_sin
     order by 2 asc;
  
  CURSOR cur_gest_rango_mor IS -- RANGO DE MORA
     select a.cod_gest codigo_gestor, nvl((((select sum (val_cap) from CO532_siniestro a, CO532_asignacion b , CO532_gest_loc c 
                    where a.cod_sin=b.SINIESTRO_COD_SIN and b.GESTOR_COD_GEST = c.GESTOR_COD_GEST 
                    and c.LOCALIZACION_COD_LOC=a.sucursal
                    and a.COD_TIP_GES= v_cod_tip_gest -- SEGUN TIPO DE GESTION QUE VIENE DEL SINIESTRO
                    and a.SUCURSAL = v_sucursal_sin  AND a.RANG_MORA = v_rango_mor
                    and b.GESTOR_COD_GEST=a.cod_gest) * 100)/n_valor_total),0) porcentaje
     from CO532_gestor a, CO532_gest_loc b
     where a.cod_gest=b.GESTOR_COD_GEST
     and a.COD_GEST IN (select cod_gestor from CO532_temp_gestores) -- CADENA STRING CON LOS CODIGOS DE LOS GESTORES.
     and est_gest='A'
     and b.LOCALIZACION_COD_LOC= v_sucursal_sin
     order by 2 asc;
     
  CURSOR cur_gest_rango_des IS -- RANGO DE DESOCUPACION
     select a.cod_gest codigo_gestor, nvl((((select sum (val_cap) from CO532_siniestro a, CO532_asignacion b , CO532_gest_loc c 
                    where a.cod_sin=b.SINIESTRO_COD_SIN and b.GESTOR_COD_GEST = c.GESTOR_COD_GEST 
                    and c.LOCALIZACION_COD_LOC=a.sucursal
                    and a.COD_TIP_GES= v_cod_tip_gest -- SEGUN TIPO DE GESTION QUE VIENE DEL SINIESTRO
                    and a.SUCURSAL = v_sucursal_sin  AND a.RANG_FECHA = v_rango_des
                    and b.GESTOR_COD_GEST=a.cod_gest) * 100)/n_valor_total),0) porcentaje
     from CO532_gestor a, CO532_gest_loc b
     where a.cod_gest=b.GESTOR_COD_GEST
     and a.COD_GEST IN (select cod_gestor from CO532_temp_gestores) -- CADENA STRING CON LOS CODIGOS DE LOS GESTORES.
     and est_gest='A'
     and b.LOCALIZACION_COD_LOC= v_sucursal_sin
     order by 2 asc;
  
 CURSOR cur_gest_total IS -- PARA CUANDO NO SE USA RANGO O ESTA SOLO POR SUCURSAL
     select a.cod_gest codigo_gestor, nvl((((select sum (val_cap) from CO532_siniestro a, CO532_asignacion b , CO532_gest_loc c 
                    where a.cod_sin=b.SINIESTRO_COD_SIN and b.GESTOR_COD_GEST = c.GESTOR_COD_GEST
                    and c.LOCALIZACION_COD_LOC=a.sucursal 
                    and RANG_DIN is null and a.COD_TIP_GES = v_cod_tip_gest -- SEGUN TIPO DE GESTION QUE VIENE DEL SINIESTRO
                    and a.SUCURSAL = v_sucursal_sin
                    and b.GESTOR_COD_GEST=a.cod_gest) * 100)/n_valor_total),0) porcentaje
     from CO532_gestor a, CO532_gest_loc b
     where a.cod_gest=b.GESTOR_COD_GEST
     and a.COD_GEST IN (select cod_gestor from CO532_temp_gestores) -- CADENA STRING CON LOS CODIGOS DE LOS GESTORES.
     and est_gest='A'
     and b.LOCALIZACION_COD_LOC= v_sucursal_sin
     order by 2 asc ; 

BEGIN
   IF ps_tip_agru in ('na','suc') THEN
   
        prc_auditoria (v_cod_hist,7.1,'Asignacion 2','Asignacion por sucursal o sin agrupamiento');
        --encuentra el total que tiene asignado el Gestor al momento de la distribucion
        select sum (val_cap)
        into n_valor_total
        from CO532_siniestro a, CO532_asignacion b , CO532_gest_loc c
        where a.cod_sin=b.SINIESTRO_COD_SIN
        and c.LOCALIZACION_COD_LOC=a.sucursal
        and b.GESTOR_COD_GEST = c.GESTOR_COD_GEST 
        and a.SUCURSAL =v_sucursal_sin
        and a.COD_TIP_GES= v_cod_tip_gest -- SEGUN TIPO DE GESTION QUE VIENE DEL SINIESTRO
        and b.GESTOR_COD_GEST IN (select cod_gestor from CO532_temp_gestores) -- CADENA sTRING CON LOS CODIGOS DE LOS GESTORES.
        and RANG_DIN is null;
      
        IF n_valor_total = NULL THEN
          n_valor_total :=1; --NO EXISTE NADA ASIGNADO ASIGNACION;
        END IF;
        FOR r_gest_total IN cur_gest_total
        LOOP
            insert into CO532_asignacion  (SINIESTRO_COD_SIN,GESTOR_COD_GEST) values (v_cod_sin , r_gest_total.codigo_gestor);
            prc_auditoria (v_cod_hist,7.2,'Asignacion 2','Asigna siniestro a gestor -'|| r_gest_total.codigo_gestor);
            b_ok:=1;
            Insert into CO532_BITA_SINI (COD_BIT_SIN,SINIESTRO_COD_SIN,GESTOR_COD_GEST,MOTIVO_EXCLUSION_COD_MOT_EXC,REGLA_DISTRIBUCION_COD_REG_DIS,FECHA_REAL)
            Values (co532_sec_co532_bita_sini.nextval, v_cod_sin,r_gest_total.codigo_gestor,NULL,v_rd,sysdate);
            EXIT WHEN  b_ok=1;
        END LOOP;           
   ELSE
        IF v_tip_rang = 1 THEN  
             prc_auditoria (v_cod_hist,7.1,'Asignacion 2','Asignacion agrupada por rango dinero');
            --encuentra el total que tiene asignado el Gestor al momento de la distribucion por rango
            select sum (val_cap)
            into n_valor_total
            from CO532_siniestro a, CO532_asignacion b , CO532_gest_loc c
            where a.cod_sin=b.SINIESTRO_COD_SIN
            and c.LOCALIZACION_COD_LOC=a.sucursal
            and b.GESTOR_COD_GEST = c.GESTOR_COD_GEST 
            and a.SUCURSAL =v_sucursal_sin
            and a.COD_TIP_GES=v_cod_tip_gest -- SEGUN TIPO DE GESTION QUE VIENE DEL SINIESTRO
            and b.GESTOR_COD_GEST IN (select cod_gestor from CO532_temp_gestores) -- CADENA STRING CON LOS CODIGOS DE LOS GESTORES.
            AND a.RANG_DIN = v_rango_din;  -- RANGO DE DINERO
      
            IF n_valor_total = NULL THEN
                n_valor_total :=1; --NO EXISTE NADA ASIGNADO ASIGNACION;
            END IF;
     
            FOR r_gest_rango_din IN cur_gest_rango_din
            LOOP
                insert into CO532_asignacion  (SINIESTRO_COD_SIN,GESTOR_COD_GEST) values (v_cod_sin , r_gest_rango_din.codigo_gestor);
                prc_auditoria (v_cod_hist,7.2,'Asignacion 2','Asigna siniestro a gestor -'|| r_gest_rango_din.codigo_gestor);
                b_ok:=1;
                Insert into CO532_BITA_SINI (COD_BIT_SIN,SINIESTRO_COD_SIN,GESTOR_COD_GEST,MOTIVO_EXCLUSION_COD_MOT_EXC,REGLA_DISTRIBUCION_COD_REG_DIS,FECHA_REAL)
                Values (co532_sec_co532_bita_sini.nextval, v_cod_sin,r_gest_rango_din.codigo_gestor,NULL,v_rd,sysdate);
                EXIT WHEN  b_ok=1;
            END LOOP;
        ELSIF v_tip_rang = 2 THEN
            prc_auditoria (v_cod_hist,7.1,'Asignacion 2','Asignacion agrupada por rango desocupacion');
            --encuentra el total que tiene asignado el Gestor al momento de la distribucion rango desocupacion
            select sum (val_cap)
            into n_valor_total
            from CO532_siniestro a, CO532_asignacion b , CO532_gest_loc c
            where a.cod_sin=b.SINIESTRO_COD_SIN
            and c.LOCALIZACION_COD_LOC=a.sucursal
            and b.GESTOR_COD_GEST = c.GESTOR_COD_GEST 
            and a.SUCURSAL =v_sucursal_sin
            and a.COD_TIP_GES=v_cod_tip_gest -- SEGUN TIPO DE GESTION QUE VIENE DEL SINIESTRO
            and b.GESTOR_COD_GEST IN (select cod_gestor from CO532_temp_gestores) -- CADENA sTRING CON LOS CODIGOS DE LOS GESTORES.
            AND a.RANG_FECHA = v_rango_des; -- RANGO DE FEHCA DESOCUPACION
      
            IF n_valor_total = NULL THEN
                n_valor_total :=1; --NO EXISTE NADA ASIGNADO ASIGNACION;
            END IF;
     
            FOR r_gest_rango_des IN cur_gest_rango_des
            LOOP
                insert into CO532_asignacion  (SINIESTRO_COD_SIN,GESTOR_COD_GEST) values (v_cod_sin , r_gest_rango_des.codigo_gestor);
                prc_auditoria (v_cod_hist,7.2,'Asignacion 2','Asigna siniestro a gestor -'|| r_gest_rango_des.codigo_gestor);
                
                Insert into CO532_BITA_SINI (COD_BIT_SIN,SINIESTRO_COD_SIN,GESTOR_COD_GEST,MOTIVO_EXCLUSION_COD_MOT_EXC,REGLA_DISTRIBUCION_COD_REG_DIS,FECHA_REAL)
                Values (co532_sec_co532_bita_sini.nextval, v_cod_sin, r_gest_rango_des.codigo_gestor,NULL,v_rd,sysdate);
                b_ok:=1;
                EXIT WHEN  b_ok=1;
            END LOOP;
        ELSIF   v_tip_rang = 3 THEN
              prc_auditoria (v_cod_hist,7.1,'Asignacion 2','Asignacion agrupada por rango mora');
            --encuentra el total que tiene asignado el Gestor al momento de la distribucion rango MORA
            select sum (val_cap)
            into n_valor_total
            from CO532_siniestro a, CO532_asignacion b , CO532_gest_loc c
            where a.cod_sin=b.SINIESTRO_COD_SIN
            and b.GESTOR_COD_GEST = c.GESTOR_COD_GEST 
            and c.LOCALIZACION_COD_LOC=a.sucursal
            and a.SUCURSAL =v_sucursal_sin
            and a.COD_TIP_GES=v_cod_tip_gest -- SEGUN TIPO DE GESTION QUE VIENE DEL SINIESTRO
            and b.GESTOR_COD_GEST IN (select cod_gestor from CO532_temp_gestores) -- CADENA sTRING CON LOS CODIGOS DE LOS GESTORES.
            AND a.RANG_MORA = v_rango_mor;-- RANGO DE MORA
      
            IF n_valor_total = NULL THEN
                n_valor_total :=1; --NO EXISTE NADA ASIGNADO ASIGNACION;
            END IF;
     
            FOR r_gest_rango_mor IN cur_gest_rango_mor
            LOOP
                insert into CO532_asignacion  (SINIESTRO_COD_SIN,GESTOR_COD_GEST) values (v_cod_sin , r_gest_rango_mor.codigo_gestor);
                prc_auditoria (v_cod_hist,7.2,'Asignacion 2','Asigna siniestro a gestor -'|| r_gest_rango_mor.codigo_gestor);
                Insert into CO532_BITA_SINI (COD_BIT_SIN,SINIESTRO_COD_SIN,GESTOR_COD_GEST,MOTIVO_EXCLUSION_COD_MOT_EXC,REGLA_DISTRIBUCION_COD_REG_DIS,FECHA_REAL)
                Values (co532_sec_co532_bita_sini.nextval, v_cod_sin,r_gest_rango_mor.codigo_gestor,NULL,v_rd,sysdate);
                b_ok:=1;
                EXIT WHEN  b_ok=1;
            END LOOP;
        END IF;
   END IF;
END prc_aplica_distri;


   
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

FUNCTION fct_variables_sin (p_tip_var IN NUMBER, p_val_var IN STRING) RETURN NUMBER
IS
 b_ok        NUMBER (1) :=1;      /*Boolean que indica si existe el valor en la regla de distribucion*/
 s_valor     STRING (10) :=NULL;  /*Bcaptura el valor de la consulta en la regla*/
           
BEGIN
    BEGIN
         SELECT VARIABLE_COD_VAR  INTO s_valor
         FROM CO532_VAR_REGL A, CO532_VARIABLE B 
         WHERE A.VARIABLE_TIP_VAR=B.TIP_VAR
         AND A.VARIABLE_COD_VAR=B.COD_VAR 
         AND A.VARIABLE_TIP_VAR = p_tip_var 
         AND B.NOM_CUL_SAI =   p_val_var
         AND A.REGLA_DISTRIBUCION_COD_REG_DIS = v_rd;
         EXCEPTION
          WHEN NO_DATA_FOUND THEN
            b_ok :=0;
    END;
  
  IF s_valor = NULL THEN
    b_ok :=0;
  END IF;
  
  RETURN b_ok;
  
END fct_variables_sin;


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

FUNCTION fct_exclusiones (p_rd IN NUMBER) RETURN NUMBER
   IS
    b_encontro NUMBER (1):=0; /*Boolean que indica si existe o no la exclusion*/
    n_dia      NUMBER(2) :=NULL;
    s_hora     CHAR(6)   :=NULL;
    s_hora_ini CHAR(6)   :=NULL;
    s_hora_fin CHAR(6)   :=NULL;
    -- Cursor para obtener las exclusiones de  fecha y hora en regla de distribucion
    CURSOR cur_excl_fec IS
        SELECT dia, hora
        FROM co532_EXCL_FEC 
        WHERE REGLA_DISTRIBUCION_COD_REG_DIS= p_rd;
    
    CURSOR cur_excl_est_fec IS
        SELECT EST_SIN,FECHA
        FROM co532_EXCL_EST_FEC 
        WHERE REGLA_DISTRIBUCION_COD_REG_DIS= p_rd;
        
    CURSOR cur_excl_mont IS
        SELECT MINIMO,MAXIMO, TIP_EXCL
        FROM co532_EXCL_MONT
        WHERE REGLA_DISTRIBUCION_COD_REG_DIS= p_rd;
    
    CURSOR cur_excl_cas IS
        SELECT SINIESTRO_COD_SIN, TIPO_EXCL
        FROM co532_EXCL_CAS
        WHERE REGLA_DISTRIBUCION_COD_REG_DIS= p_rd;
    
    CURSOR cur_excl_pol IS
        SELECT POLIZA_COD_POL,TIP_EXC
        FROM co532_EXCL_POL
        WHERE REGLA_DISTRIBUCION_COD_REG_DIS= p_rd;
         
   BEGIN
      FOR r_exc_fec IN cur_excl_fec
        LOOP
        n_dia:=to_number(TO_CHAR(v_fecha_ing_sin,'dd'));
        s_hora := to_char(v_fecha_ing_sin,'HH24:MI');
        s_hora_ini := To_char (r_exc_fec.HORA, 'HH24:MI');
        s_hora_fin := to_char (To_date ('01/01/0001 23:59:00', 'MM/DD/YYYY HH24:MI:SS'),'HH24:MI');
        IF  n_dia = r_exc_fec.dia AND (s_hora BETWEEN s_hora_ini and s_hora_fin )then
            b_encontro:=3;
            v_tip_excl := 'EM'; 
            prc_auditoria (v_cod_hist,5.1,'Exclusiones','Siniestro excluido por dia y hora');
            RETURN b_encontro;                       
        END IF;              
            
        END LOOP;
        
      FOR r_excl_est_fec IN cur_excl_est_fec
        LOOP
         IF  r_excl_est_fec.EST_SIN = v_est_sin AND (trunc (r_excl_est_fec.FECHA) = trunc (v_fecha_ing_sin)) then
            b_encontro:=4;
            v_tip_excl := 'EM';
            prc_auditoria (v_cod_hist,5.1,'Exclusiones','Siniestro excluido por estado de siniestro y fecha'); 
            RETURN b_encontro;                       
         END IF;              
            
        END LOOP;
        
      FOR r_excl_mont IN cur_excl_mont
        
        LOOP
        v_tip_excl := r_excl_mont.TIP_EXCL;
         IF  v_val_cap_sin <= r_excl_mont.MINIMO OR v_val_cap_sin >= r_excl_mont.MAXIMO then
            b_encontro:=5;
            prc_auditoria (v_cod_hist,5.1,'Exclusiones','Siniestro excluido por monto');
            RETURN b_encontro;                       
         END IF;              
            
        END LOOP;
       
      FOR r_excl_cas IN cur_excl_cas
        
        LOOP
        v_tip_excl:=r_excl_cas.TIPO_EXCL;
         IF  r_excl_cas.SINIESTRO_COD_SIN = v_cod_sin  then
            b_encontro:=6;
            prc_auditoria (v_cod_hist,5.1,'Exclusiones','Siniestro excluido por numero de siniestro');
            RETURN b_encontro;                       
         END IF;              
            
        END LOOP;
        
      FOR r_excl_pol IN cur_excl_pol
        
        LOOP
        v_tip_excl := r_excl_pol.TIP_EXC;
         IF  r_excl_pol.POLIZA_COD_POL = v_cod_sin  then
            b_encontro:=7;
            prc_auditoria (v_cod_hist,5.1,'Exclusiones','Siniestro excluido por numero de poliza/inmobiliaria');
            RETURN b_encontro;                       
         END IF;              
            
        END LOOP;
        
     IF b_encontro = 0
      THEN
         prc_auditoria (v_cod_hist,5.2,'Exclusiones','NO PRESENTA EXCLUSIONES');
      END IF;   
      
  RETURN b_encontro;    
   
END fct_exclusiones;

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
PROCEDURE prc_auditoria (
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
   
      /***************************************************************************
   NOMBRE:       fct_vident_regla
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
   FUNCTION fct_valida_gestores (p_rd IN NUMBER) RETURN STRING
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
      Insert into CO532_BITA_SINI (COD_BIT_SIN, SINIESTRO_COD_SIN, GESTOR_COD_GEST, MOTIVO_EXCLUSION_COD_MOT_EXC,REGLA_DISTRIBUCION_COD_REG_DIS,FECHA_REAL)
                           Values (co532_sec_co532_bita_sini.nextval, v_cod_sin,Null,p_cod_excl,v_rd,sysdate);
   END;


END CO532_PKG_ASIG_CAMBIO_ESTADO; 
/

