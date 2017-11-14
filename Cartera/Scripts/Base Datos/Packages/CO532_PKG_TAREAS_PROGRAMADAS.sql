CREATE OR REPLACE PACKAGE ADMSISA.CO532_PKG_TAREAS_PROGRAMADAS IS

PROCEDURE CO532_INACTIVAR_GESTOR;

PROCEDURE CO532_DISTRI_MASIVA_AUT;

PROCEDURE CO532_LLAMADO;

END CO532_PKG_TAREAS_PROGRAMADAS;
/


CREATE OR REPLACE PACKAGE BODY ADMSISA.CO532_PKG_TAREAS_PROGRAMADAS

 IS
 
 
 PROCEDURE CO532_LLAMADO is

  err_num NUMBER;
  err_msg VARCHAR2(255);

  BEGIN
       CO532_INACTIVAR_GESTOR;
       CO532_DISTRI_MASIVA_AUT;
        
   EXCEPTION  
    WHEN OTHERS THEN  
     err_num := SQLCODE;
     err_msg := SQLERRM;
     DBMS_OUTPUT.put_line('Error:'||TO_CHAR(err_num));
     DBMS_OUTPUT.put_line(err_msg);

    COMMIT;
  END CO532_LLAMADO;
   

PROCEDURE CO532_INACTIVAR_GESTOR is

  err_num NUMBER;
  err_msg VARCHAR2(255);

BEGIN

    UPDATE CO532_INACT_GEST SET ESTADO_INAC = 0
    WHERE TO_DATE(FEC_INI,'DD/MM/YY')= TO_DATE(SYSDATE,'DD/MM/YY');

    UPDATE CO532_GESTOR SET EST_GEST = 'I'
    WHERE COD_GEST IN (SELECT GE.COD_GEST FROM CO532_GESTOR GE
    INNER JOIN CO532_INACT_GEST IG
    ON GE.COD_GEST = IG.GESTOR_COD_GEST
    WHERE TO_DATE(IG.FEC_INI,'DD/MM/YY') = TO_DATE(SYSDATE,'DD/MM/YY'));

    UPDATE CO532_INACT_GEST SET ESTADO_INAC = 1
    WHERE TO_DATE(FEC_FIN,'DD/MM/YY')= TO_DATE(SYSDATE,'DD/MM/YY');

    UPDATE CO532_GESTOR SET EST_GEST = 'A'
    WHERE COD_GEST IN (SELECT GE.COD_GEST FROM CO532_GESTOR GE INNER JOIN CO532_INACT_GEST IG
    ON GE.COD_GEST = IG.GESTOR_COD_GEST
    WHERE TO_DATE(IG.FEC_FIN,'DD/MM/YY') = TO_DATE(SYSDATE,'DD/MM/YY'));

EXCEPTION  
    WHEN OTHERS THEN  
     err_num := SQLCODE;
     err_msg := SQLERRM;
     DBMS_OUTPUT.put_line('Error:'||TO_CHAR(err_num));
     DBMS_OUTPUT.put_line(err_msg);

COMMIT;
END CO532_INACTIVAR_GESTOR;



PROCEDURE CO532_DISTRI_MASIVA_AUT IS

  err_num               NUMBER;
  err_msg               VARCHAR2(255);
  
  vn_dias_mes           NUMBER (2)   :=30;
  vn_ult_dist           NUMBER (5)   :=NULL;
  
  cursor cur_reglas IS -- RANGO DE DINERO
    select a.COD_REG_DIS, a.MES_PER from co532_reg_dist a 
    where a.estado=1 and a.per_reg='ESV' and a.MES_PER>0 order by prioridad;

BEGIN
 FOR r_reglas IN cur_reglas  
        LOOP
            select trunc(sysdate) - max(trunc(fecha)) into vn_ult_dist  from co532_hist_distr b where b.REG_DIST= r_reglas.cod_reg_dis;
            IF (vn_ult_dist >= ( r_reglas.MES_PER * vn_dias_mes)) THEN
                ADMSISA.CO532_PKG_ASIG_VIGENTES.PRC_ASIG_VIGENTES (r_reglas.cod_reg_dis,0);
            END IF;
        END LOOP;       
EXCEPTION  
    WHEN OTHERS THEN  
     err_num := SQLCODE;
     err_msg := SQLERRM;
     DBMS_OUTPUT.put_line('Error:'||TO_CHAR(err_num));
     DBMS_OUTPUT.put_line(err_msg);

COMMIT;
END CO532_DISTRI_MASIVA_AUT;
 
END CO532_PKG_TAREAS_PROGRAMADAS;
/
