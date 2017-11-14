CREATE OR REPLACE PACKAGE ADMSISA.CO532_PKG_REASIGNACION IS

procedure prc_aplica_distri ( ps_tip_agru IN STRING, p_tip_rang IN NUMBER ) ;

procedure prc_algoritmo_distribucion (p_rang_agru IN VARCHAR, p_tip_rang IN NUMBER) ;

procedure PRC_AUDITORIA (p_cod_hist IN NUMBER, p_paso in NUMBER, p_funcion in VARCHAR , p_observacion in VARCHAR  );
  
--PROCEDIMIENTO A SER LLAMADO
PROCEDURE prc_distribuir_grupo ( p_cod_sin IN CO532_array_siniestros, p_cod_gest IN CO532_array_gestores , p_tip_distr in NUMBER,p_prueba in NUMBER, p_s_motivo in STRING);

END CO532_PKG_REASIGNACION; 
/



CREATE OR REPLACE PACKAGE BODY ADMSISA.CO532_PKG_REASIGNACION

 IS
   /** VARIABLES  GENERALES PARA LA DISTRIBUCION EN LINEA DE LOS SINIESTROS. **/
   v_rang_agru                  VARCHAR(5)     := NULL; --Rango de Agrupacion del tipo de distribucion a utilizar (algoritmo de distribuci?n)
   v_tip_rang                   NUMBER(5)      := NULL; --Tipo de agrupacion implementado por el tipo  de distribucion (algoritmo de Distribucion).
   v_rango_des                  VARCHAR(5)     := NULL; --Nombre Rango fecha de desocupacion
   v_rango_din                  VARCHAR(5)     := NULL; --Nombre Rango dinero
   b_ok                         NUMBER(1)      := NULL; -- ariable que captura si el procedimiento es ejecutado correctamente.
   v_rang_fec                   VARCHAR(5)     := NULL; -- Nombre para el rango de fecha desocupacion
   v_rango_mor                  VARCHAR(5)     := NULL; -- Nombre del rango de fecha de mora
   v_ok                         NUMBER (1)     := NULL; -- indica si se ejecuto corretamente o no la auditoria
   v_cod_hist                   NUMBER(3)      := NULL; -- codigo de historico de distribucion tomado de secuencia
   
   --INFORMACION DEL SINIESTRO
   v_cod_sin                    NUMBER (10)    := NULL;
   v_val_cap_sin                NUMBER (15,3)  := NULL;
   v_val_col_sin                NUMBER (15,3)  := NULL;
   v_fecha_mora                 DATE           := NULL;
   v_fech_desoc                 DATE           := NULL;
   v_cod_tip_gest               NUMBER         := NULL;
   v_sucursal_sin               VARCHAR(5)     := NULL;
   v_fecha_ing_sin              DATE           := NULL;
   v_tip_pol_sin                VARCHAR(5)     :=NULL;
   v_area_sin                   VARCHAR(5)     :=NULL;
   v_ubicacion_sin              VARCHAR(5)     :=NULL;
   v_est_ali_sin                VARCHAR(5)     :=NULL;
   v_tipo_amp_sin               VARCHAR(5)     :=NULL;
   v_tip_prod_sin               NUMBER         :=NULL;
   v_subti_prod_sin             VARCHAR(4)     :=NULL;
   v_est_sin                    VARCHAR(4)     :=NULL;
   v_est_pago_sin               VARCHAR(4)     :=NULL;
   
   --OTROS--
   v_cod_gest                   NUMBER         :=NULL;
   
                 
   PROCEDURE prc_distribuir_grupo ( p_cod_sin IN CO532_array_siniestros, p_cod_gest IN CO532_array_gestores , p_tip_distr in NUMBER, p_prueba in NUMBER, p_s_motivo in STRING ) 
   IS
    BEGIN
     
         
     FOR r_gest IN 1 ..  p_cod_gest.COUNT
     LOOP
       Insert into CO532_temp_gestores (cod_gestor) values (p_cod_gest(r_gest));
     END LOOP;
    V_COD_HIST:=co532_SEC_hist_distr.NEXTVAL;
    insert into CO532_hist_distr  (COD_HIS_DIS, FECHA, REG_DIST , TIPO_DISTRIBUCION_COD_TIP_DIS, DESCRIPCION, USUARIO)
    values (V_COD_HIST, SYSDATE, 0, p_tip_distr ,'Reasignacion/Asignacion Excluidos: '||p_s_motivo,USER);
     
     PRC_AUDITORIA(co532_sec_hist_distr.CURRVAL,1,'Inicio Proceso', 'Inserta encabezado del Historico distribucion numero -'|| V_COD_HIST);
     
     select tip_agru, tip_ran 
     Into v_rang_agru, v_tip_rang
     from CO532_tip_distr where cod_tip_dis= p_tip_distr;
     
     PRC_AUDITORIA(V_COD_HIST,2,'Tipo Distribucion', 'Consulta si agrupo y con que tipo de agrupacion con tipo de distribucion -'|| p_tip_distr);
        
     FOR r_sin IN 1 .. p_cod_sin.COUNT
     LOOP
          
       v_cod_sin :=p_cod_sin(r_sin);
       
       delete from co532_asignacion where siniestro_cod_sin=v_cod_sin;
       
       SELECT VAL_CAP, FECHA_MORA, COD_TIP_GES, SUCURSAL, RANG_DIN ,FECHA_ING ,FECHA_MORA, RANG_FECHA, RANG_MORA, VAL_COL,
       TIP_POL,AREA,UBICACION,EST_ALI,TIP_AMP, TIP_PROD ,SUBTI_PROD,EST_SIN ,EST_PAG
       INTO v_val_cap_sin, v_fecha_mora, v_cod_tip_gest,v_sucursal_sin,v_rango_din,v_fecha_ing_sin, v_fecha_mora,v_rang_fec, v_rango_mor, v_val_col_sin,
       v_tip_pol_sin, v_area_sin, v_ubicacion_sin, v_est_ali_sin,v_tipo_amp_sin, v_tip_prod_sin, v_subti_prod_sin, v_est_sin, v_est_pago_sin 
       FROM CO532_SINIESTRO WHERE cod_sin = v_cod_sin;
       
       PRC_AUDITORIA(V_COD_HIST,3,'Datos Siniestro', 'Consulta datos del siniestro para historico');

       PRC_AUDITORIA(V_COD_HIST,4,'Inicia Distribucion', 'Inicia la asignacion a partir del tipo de distribucion');       
       
       prc_algoritmo_distribucion (v_rang_agru, v_tip_rang );

       
       IF b_ok = 1 THEN
          update CO532_siniestro set FECHA_PROCESO = sysdate, REGLA_DISTRIBUCION_COD_REG_DIS=null where cod_sin=v_cod_sin;
                              
          select GESTOR_COD_GEST into v_cod_gest from CO532_asignacion where SINIESTRO_COD_SIN =v_cod_sin;
          
          insert into CO532_det_hist_distr (COD_DET_HIST_DIS,HIS_DIST_COD_HIS_DIS,SINIESTRO_COD_SIN,SUCURSAL,TIPO_PROD ,SUBTIP_PROD,EST_SIN ,EST_PAG,TIP_AMP,
                                      TIP_POL,AREA,UBICACION,EST_ALI, VAL_CAP,VAL_COL,COD_GEST_CAP,COD_GEST_COL,FECHA_PROCESO,COD_TIP_GEST,TIPO_EXCL,
                                      RANG_FECHA,RANG_MORA,RANG_DIN ,FECH_ING ,FECHA_MORA)
          Values (CO532_sec_det_hist_dist.nextval, V_COD_HIST, v_cod_sin,v_sucursal_sin, v_tip_prod_sin, v_subti_prod_sin, v_est_sin, v_est_pago_sin, v_tipo_amp_sin, 
                        v_tip_pol_sin, v_area_sin, v_ubicacion_sin, v_est_ali_sin, v_val_cap_sin,v_val_col_sin ,v_cod_gest,null, sysdate,v_cod_tip_gest,null,
                        v_rang_fec, v_rango_mor,v_rango_din,v_fecha_ing_sin, v_fecha_mora);
                    
          PRC_AUDITORIA (V_COD_HIST,10,'Asignado','Siniestro Asignado');
          
      
       END IF;
      
       
     END LOOP;  
     
     v_cod_sin:=null;
     
     PRC_AUDITORIA (V_COD_HIST,10,'EXITOSO','Termina proceso de re asignacion');
     
     DELETE from CO532_temp_gestores;
     COMMIT;
     
     EXCEPTION
        WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('Error: '|| SQLERRM);  
        PRC_AUDITORIA (V_COD_HIST,99,'ERROR',SQLERRM);
        RAISE_APPLICATION_ERROR (-20700, SQLERRM );
                        
    END prc_distribuir_grupo; 
    
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
   
PROCEDURE prc_algoritmo_distribucion (p_rang_agru IN VARCHAR, p_tip_rang IN NUMBER) 
IS
 b_ok         NUMBER (1)     :=1;      /*Boolean que indica si existe el valor en la regla de distribucion*/
            
BEGIN

    IF p_rang_agru in ('ran','suc ran' ) THEN
        PRC_AUDITORIA (V_COD_HIST,4.1,'Asignacion 1','Usa agrupacion por rango');
        IF p_tip_rang = 1 THEN
            BEGIN
             SELECT NOM_RAN INTO v_rango_din
             FROM CO532_RANG_AGRU WHERE v_val_cap_sin BETWEEN VAL_INI AND VAL_FIN AND TIP_RAN=p_tip_rang;
             EXCEPTION 
              WHEN NO_DATA_FOUND THEN
                 PRC_AUDITORIA (V_COD_HIST,4.2,'Asignacion 1','No encuentra rango de dinero');
                b_ok :=0; 
            END;
            
            PRC_AUDITORIA (V_COD_HIST,4.3,'Asignacion 1','Tipo Agrupacion por dinero actualiza informacion del siniestro');
            UPDATE CO532_SINIESTRO SET RANG_DIN = v_rango_din WHERE COD_SIN=v_cod_sin;
            
            PRC_AUDITORIA (V_COD_HIST,5,'Asignacion 2','Inicia asignacion del siniestro con agrupacion');
            prc_aplica_distri(v_rang_agru, v_tip_rang);
            
        ELSIF  p_tip_rang=2 then
            BEGIN
             SELECT NOM_RAN INTO v_rango_des
             FROM CO532_RANG_AGRU WHERE (trunc(sysdate) -  trunc(v_fech_desoc)) BETWEEN VAL_INI AND VAL_FIN AND TIP_RAN=p_tip_rang;
             EXCEPTION 
              WHEN NO_DATA_FOUND THEN
                PRC_AUDITORIA (V_COD_HIST,4.2,'Asignacion 1','No encuentra rango de fecha desocupacion');
                b_ok :=0; 
            END;
            
            PRC_AUDITORIA (V_COD_HIST,4.3,'Asignacion 1','Tipo Agrupacion por fecha desocupacion actualiza informacion del siniestro');
            UPDATE CO532_SINIESTRO SET RANG_FECHA = v_rango_des WHERE COD_SIN=v_cod_sin;
           
            PRC_AUDITORIA (V_COD_HIST,5,'Asignacion 2','Inicia asignacion del siniestro con agrupacion');
            prc_aplica_distri(v_rang_agru, v_tip_rang);
            
        ELSIF  p_tip_rang=3 then
            BEGIN
             SELECT NOM_RAN INTO v_rango_mor
             FROM CO532_RANG_AGRU WHERE (trunc(sysdate) -  trunc(v_fecha_mora)) BETWEEN VAL_INI AND VAL_FIN AND TIP_RAN=p_tip_rang;
             EXCEPTION 
              WHEN NO_DATA_FOUND THEN
                PRC_AUDITORIA (V_COD_HIST,4.2,'Asignacion 1','No encuentra rango de fecha mora');
                b_ok :=0; 
            END;
            
            PRC_AUDITORIA (V_COD_HIST,4.3,'Asignacion 1','Tipo Agrupacion por fecha mora actualiza informacion del siniestro');
            UPDATE CO532_SINIESTRO SET RANG_MORA = v_rango_mor WHERE COD_SIN=v_cod_sin;
            
            PRC_AUDITORIA (V_COD_HIST,5,'Asignacion 2','Inicia asignacion del siniestro con agrupacion');
            prc_aplica_distri(v_rang_agru, v_tip_rang);
                
        ELSE
            b_ok:= 0;
        END IF;
    ELSE
       PRC_AUDITORIA (V_COD_HIST,5,'Asignacion 2','Inicia asignacion del siniestro sin agrupacion');
       prc_aplica_distri(v_rang_agru, v_tip_rang);
    END IF;      
  
END prc_algoritmo_distribucion;

/***************************************************************************
   NOMBRE:       fct_aplica_distri
   DESCRIPCION: .
   PARAMETROS DE ENTRADA:                    
   PARAMETROS DE SALIDA: b_ok: 
                        
   MODIFICACIONES :
   VERSION      FECHA       AUTOR          REQUERIMIENTO          DESCRIPCION DEL CAMBIO
   ---------------------------------------------------------------------------------------------
   1.0      27/09/2017    Jmurillo         PF 21.1                      Creacion.
   ******************************************************************************/  

Procedure prc_aplica_distri ( ps_tip_agru IN STRING, p_tip_rang IN NUMBER ) 
IS
 b_ok              NUMBER (1)  :=0;      /*Boolean que indica si existe el valor en la regla de distribucion*/
 n_valor_total     NUMBER (30,10)  :=0;
 
 cursor cur_gest_rango_din IS -- RANGO DE DINERO
     select a.cod_gest codigo_gestor, nvl((((select sum (val_cap) from CO532_siniestro a, CO532_asignacion b , CO532_gest_loc c 
                    where a.cod_sin=b.SINIESTRO_COD_SIN and b.GESTOR_COD_GEST = c.GESTOR_COD_GEST
                    and c.LOCALIZACION_COD_LOC = a.sucursal  
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
                    and c.LOCALIZACION_COD_LOC = a.sucursal 
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
                    and c.LOCALIZACION_COD_LOC = a.sucursal 
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
                    and c.LOCALIZACION_COD_LOC = a.sucursal 
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
   IF ps_tip_agru in ('na','Suc') THEN
         PRC_AUDITORIA (V_COD_HIST,5.1,'Asignacion 2','Asignacion por sucursal o sin agrupamiento');
        --encuentra el total que tiene asignado el Gestor al momento de la distribucion
        select sum (val_cap)
        into n_valor_total
        from CO532_siniestro a, CO532_asignacion b , CO532_gest_loc c
        where a.cod_sin=b.SINIESTRO_COD_SIN
        and b.GESTOR_COD_GEST = c.GESTOR_COD_GEST 
        and c.LOCALIZACION_COD_LOC = a.sucursal 
        and a.SUCURSAL =v_sucursal_sin
        and a.COD_TIP_GES= v_cod_tip_gest -- SEGUN TIPO DE GESTION QUE VIENE DEL SINIESTRO
        and b.GESTOR_COD_GEST IN (select cod_gestor from CO532_temp_gestores) -- CADENA sTRING CON LOS CODIGOS DE LOS GESTORES.
        and RANG_DIN is null;
      
        IF n_valor_total = NULL THEN
          n_valor_total :=1; --NO EXISTE NADA ASIGNADO ASIGNACION;
        END IF;
        FOR r_gest_total IN cur_gest_total
        LOOP
            PRC_AUDITORIA (V_COD_HIST,5.2,'Asignacion 2','Asigna siniestro a gestor -'|| r_gest_total.codigo_gestor);
            insert into CO532_asignacion  (SINIESTRO_COD_SIN,GESTOR_COD_GEST) values (v_cod_sin , r_gest_total.codigo_gestor);
            b_ok:=1;
                Insert into CO532_BITA_SINI (COD_BIT_SIN, SINIESTRO_COD_SIN, GESTOR_COD_GEST, MOTIVO_EXCLUSION_COD_MOT_EXC,REGLA_DISTRIBUCION_COD_REG_DIS,FECHA_REAL)
                               Values (co532_sec_co532_bita_sini.nextval, v_cod_sin, r_gest_total.codigo_gestor,NULL, NULL ,sysdate);
            EXIT WHEN  b_ok=1;
        END LOOP;           
   ELSE
        IF v_tip_rang = 1 THEN  
            PRC_AUDITORIA (V_COD_HIST,5.1,'Asignacion 2','Asignacion agrupada por rango dinero');
            --encuentra el total que tiene asignado el Gestor al momento de la distribucion por rango
            select sum (val_cap)
            into n_valor_total
            from CO532_siniestro a, CO532_asignacion b , CO532_gest_loc c
            where a.cod_sin=b.SINIESTRO_COD_SIN
            and c.LOCALIZACION_COD_LOC = a.sucursal 
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
                PRC_AUDITORIA (V_COD_HIST,5.2,'Asignacion 2','Asigna siniestro a gestor -'|| r_gest_rango_din.codigo_gestor);
                b_ok:=1;
                Insert into CO532_BITA_SINI (COD_BIT_SIN, SINIESTRO_COD_SIN, GESTOR_COD_GEST, MOTIVO_EXCLUSION_COD_MOT_EXC,REGLA_DISTRIBUCION_COD_REG_DIS,FECHA_REAL)
                               Values (co532_sec_co532_bita_sini.nextval, v_cod_sin, r_gest_rango_din.codigo_gestor,NULL, NULL ,sysdate);
                EXIT WHEN  b_ok=1;
            END LOOP;
        ELSIF v_tip_rang = 2 THEN
            --encuentra el total que tiene asignado el Gestor al momento de la distribucion rango desocupacion
            PRC_AUDITORIA (V_COD_HIST,5.1,'Asignacion 2','Asignacion agrupada por rango desocupacion');
            select sum (val_cap)
            into n_valor_total
            from CO532_siniestro a, CO532_asignacion b , CO532_gest_loc c
            where a.cod_sin=b.SINIESTRO_COD_SIN
            and c.LOCALIZACION_COD_LOC = a.sucursal 
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
                PRC_AUDITORIA (V_COD_HIST,5.2,'Asignacion 2','Asigna siniestro a gestor -'|| r_gest_rango_des.codigo_gestor);
                b_ok:=1;
                Insert into CO532_BITA_SINI (COD_BIT_SIN, SINIESTRO_COD_SIN, GESTOR_COD_GEST, MOTIVO_EXCLUSION_COD_MOT_EXC,REGLA_DISTRIBUCION_COD_REG_DIS,FECHA_REAL)
                               Values (co532_sec_co532_bita_sini.nextval, v_cod_sin, r_gest_rango_des.codigo_gestor,NULL, NULL ,sysdate);
                EXIT WHEN  b_ok=1;
            END LOOP;
        ELSIF   v_tip_rang = 3 THEN
             PRC_AUDITORIA (V_COD_HIST,5.1,'Asignacion 2','Asignacion agrupada por rango mora');
            --encuentra el total que tiene asignado el Gestor al momento de la distribucion rango MORA
            select sum (val_cap)
            into n_valor_total
            from CO532_siniestro a, CO532_asignacion b , CO532_gest_loc c
            where a.cod_sin=b.SINIESTRO_COD_SIN
            and c.LOCALIZACION_COD_LOC = a.sucursal 
            and b.GESTOR_COD_GEST = c.GESTOR_COD_GEST 
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
                PRC_AUDITORIA (V_COD_HIST,5.2,'Asignacion 2','Asigna siniestro a gestor -'|| r_gest_rango_mor.codigo_gestor);
                b_ok:=1;
                Insert into CO532_BITA_SINI (COD_BIT_SIN, SINIESTRO_COD_SIN, GESTOR_COD_GEST, MOTIVO_EXCLUSION_COD_MOT_EXC,REGLA_DISTRIBUCION_COD_REG_DIS,FECHA_REAL)
                               Values (co532_sec_co532_bita_sini.nextval, v_cod_sin, r_gest_rango_mor.codigo_gestor,NULL, NULL ,sysdate);
                EXIT WHEN  b_ok=1;
            END LOOP;
        END IF;
   END IF;


END prc_aplica_distri;

/***************************************************************************
   NOMBRE:       PRC_AUDITORIA
   DESCRIPCION: 
   PARAMETROS DE ENTRADA: -P_RD, regla de distribucion encontrada.                             
   PARAMETROS DE SALIDA: 
                        
   MODIFICACIONES :
   VERSION      FECHA       AUTOR          REQUERIMIENTO          DESCRIPCION DEL CAMBIO
   ---------------------------------------------------------------------------------------------
   1.0      19/09/2017    Jmurillo         PF 21.1                      Creacion.
   ******************************************************************************/   

PROCEDURE PRC_AUDITORIA (p_cod_hist IN NUMBER, p_paso in NUMBER, p_funcion in VARCHAR , p_observacion in VARCHAR  )
   IS
    
 BEGIN
   
  INSERT INTO co532_aud_dist ( HIST_DISTR_COD_HIS_DIS, SINIESTRO_COD_SIN, COD_AUD  ,  PASO, FECHA,FUNCION,OBSERVACION)
  VALUES (p_cod_hist,V_COD_SIN, CO532_SEC_AUD_DIST.NEXTVAL,P_PASO, SYSDATE, P_FUNCION, P_OBSERVACION);
      
 END PRC_AUDITORIA;
 
END CO532_PKG_REASIGNACION; 
/

