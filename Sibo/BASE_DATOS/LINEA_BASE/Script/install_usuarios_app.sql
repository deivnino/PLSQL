begin
  PRC_CREACION_USUARIO_SIBO('USUARIO0','LAB00','Alfonso',null,'pimienta',null);
  PRC_CREACION_USUARIO_SIBO('USUARIO1','LAB01','wilson',null,'albornoz',null);
  PRC_CREACION_USUARIO_SIBO('USUARIO2','LAB02','david',null,'nino',null);
  PRC_CREACION_USUARIO_SIBO('USUARIO3','LAB03','felipe',null,'herrera',null);
  PRC_CREACION_USUARIO_SIBO('USUARIO4','LAB04','carlos',null,'camacho',null);
  EXCEPTION
        WHEN others THEN
          DBMS_OUTPUT.PUT_LINE(sqlcode);
END ;
/