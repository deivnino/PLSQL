  -- Author  : Asesoftware - Jorge Gallo.
  -- Created : 19/08/2017.
  -- Purpose :  Script de migración de la tabla rasegurados a riesgos_asegurados
  -- Modificado por:
  --
DECLARE
  CURSOR rasegurados_cursor IS
  SELECT *
  FROM admsisa.rasegurados
  WHERE TO_DATE(FECHA_PAGO,'DD/MM/YY') > TO_DATE('01/01/17','DD/MM/YY');
  t_rasegurados admsisa.rasegurados%ROWTYPE;
BEGIN
  FOR t_rasegurados IN rasegurados_cursor LOOP
      INSERT INTO admsisa.riesgos_asegurados VALUES(t_rasegurados.solicitud, t_rasegurados.periodo, '01','01', NVL(t_rasegurados.canon,0), NVL(t_rasegurados.prima_mes,0),NVL(t_rasegurados.prima_retro,0),t_rasegurados.poliza);
    IF (t_rasegurados.admon IS NOT NULL) THEN
     INSERT INTO admsisa.riesgos_asegurados VALUES(t_rasegurados.solicitud, t_rasegurados.periodo,'01', '02', t_rasegurados.admon,NVL(t_rasegurados.prima_mes,0),NVL(t_rasegurados.prima_retro,0), t_rasegurados.poliza);
    END IF;
    IF (t_rasegurados.serv_pub IS NOT NULL and t_rasegurados.serv_pub>0) THEN
      INSERT INTO admsisa.riesgos_asegurados VALUES(t_rasegurados.solicitud, t_rasegurados.periodo,'04', '03', 0, t_rasegurados.serv_pub,NVL(t_rasegurados.prima_retro,0), t_rasegurados.poliza);
    ELSIF (t_rasegurados.lserv_pub = 'S.P.R.R') THEN
      INSERT INTO admsisa.riesgos_asegurados VALUES(t_rasegurados.solicitud, t_rasegurados.periodo,'04', '03', 0, 0,NVL(t_rasegurados.prima_retro,0), t_rasegurados.poliza);
    END IF;
    
    IF (t_rasegurados.DYF IS NOT NULL and t_rasegurados.dyf>0) THEN
      INSERT INTO admsisa.riesgos_asegurados VALUES(t_rasegurados.solicitud, t_rasegurados.periodo,'05' ,'05', 0, t_rasegurados.DYF,NVL(t_rasegurados.prima_retro,0), t_rasegurados.poliza);
    ELSIF(t_rasegurados.LDYF = 'D.F.') THEN
      INSERT INTO admsisa.riesgos_asegurados VALUES(t_rasegurados.solicitud, t_rasegurados.periodo, '05','05', 0, 0,NVL(t_rasegurados.prima_retro,0), t_rasegurados.poliza);
    END IF;
    
    IF (t_rasegurados.expensas IS NOT NULL and t_rasegurados.expensas>0) THEN
      INSERT INTO admsisa.riesgos_asegurados VALUES(t_rasegurados.solicitud, t_rasegurados.periodo,'06', '06', 0, t_rasegurados.expensas, NVL(t_rasegurados.prima_retro,0), t_rasegurados.poliza);
    ELSIF (t_rasegurados.lexpensas = 'E.C.O.') THEN
      INSERT INTO admsisa.riesgos_asegurados VALUES(t_rasegurados.solicitud, t_rasegurados.periodo,'06', '06', 0, 0,NVL(t_rasegurados.prima_retro,0), t_rasegurados.poliza);
    END IF;
    
    IF (t_rasegurados.ampint IS NOT NULL and t_rasegurados.ampint>0) THEN
      INSERT INTO admsisa.riesgos_asegurados VALUES(t_rasegurados.solicitud, t_rasegurados.periodo,'08' ,'16', 0, t_rasegurados.ampint,NVL(t_rasegurados.prima_retro,0), t_rasegurados.poliza);
    ELSIF (t_rasegurados.lampint = 'A.I.') THEN
      INSERT INTO admsisa.riesgos_asegurados VALUES(t_rasegurados.solicitud, t_rasegurados.periodo,'08', '16', 0, 0,NVL(t_rasegurados.prima_retro,0), t_rasegurados.poliza);
    END IF; 
    
    IF (t_rasegurados.vlor_aseg_hogar IS NOT NULL) THEN
      INSERT INTO admsisa.riesgos_asegurados VALUES(t_rasegurados.solicitud, t_rasegurados.periodo,'11', '26', t_rasegurados.vlor_aseg_hogar, t_rasegurados.AMPHOGAR, NVL(t_rasegurados.prima_retro,0), t_rasegurados.poliza);
    END IF;
  END LOOP;
  COMMIT;
END;
/