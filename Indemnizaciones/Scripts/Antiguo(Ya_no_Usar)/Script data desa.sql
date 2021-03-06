
ALTER TABLE SOLICITUD_SAI ADD (EMAIL_INMOBILIARIA VARCHAR2(100));
ALTER TABLE SINIESTRO_PENDIENTE ADD (FEC_OBJECION DATE NOT NULL);
ALTER TABLE TRANSACCION ADD NUM_INTENTOS NUMBER(5) NULL;
ALTER TABLE SERVICIO_PUBLICO MODIFY COD_SERV VARCHAR2(10);

Insert into DOMINIO (COD_DOMINIO,NOMBRE,ESTADO) values ('1','ESTADO SINIESTRO','1');
Insert into DOMINIO (COD_DOMINIO,NOMBRE,ESTADO) values ('2','ESTADO PAGO SINIESTRO','1');
Insert into DOMINIO (COD_DOMINIO,NOMBRE,ESTADO) values ('3','CONCEPTOS SINIESTRO','1');
Insert into DOMINIO (COD_DOMINIO,NOMBRE,ESTADO) values ('4','ESTADO PENDIENTES','1');
Insert into DOMINIO (COD_DOMINIO,NOMBRE,ESTADO) values ('5','REGLAS NEGOCIO','1');
Insert into DOMINIO (COD_DOMINIO,NOMBRE,ESTADO) values ('6','ESTADO TRANSACCION','1');
Insert into DOMINIO (COD_DOMINIO,NOMBRE,ESTADO) values ('7','MOTIVO AUT DESOCUPACION','1');

Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('1','NUEVO','1','1');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('2','VIGENTE','1','1');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('3','TERMINADO','1','1');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('4','DESISTIDO','1','1');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('5','DESOCUPADO','1','1');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('6','ANULADO','1','1');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('7','REINTEGRO','1','1');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('8','OBJETADO','1','1');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('9','NUEVO','1','2');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('10','VIGENTE','1','2');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('11','SUSPENDIDO','1','2');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('12','OBJETADO','1','2');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('13','RE01','1','3');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('14','RE02','1','3');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('15','RM01','1','3');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('16','RM02','1','3');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('17','01','1','3');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('18','02','1','3');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('19','Pendiente','1','4');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('20','Procesada','1','4');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('21','Documentos anexos marcados como si aplica','1','5');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('22','Registrado Correctamente','1','6');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('32','Pendiente SAI','1','6');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('33','Motivo 1','1','7');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('34','Motivo 2','1','7');
Insert into VAL_DOMINIO (COD_VAL_DOMINIO,VALOR,ESTADO,DOMINIO_COD_DOMINIO) values ('35','Motivo 3','1','7');

