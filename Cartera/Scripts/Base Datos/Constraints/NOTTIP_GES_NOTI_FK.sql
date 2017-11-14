/**
* Name: NOTTIP_GES_NOTI_FK.sql
* Referencia a la tabla CO532_NOTIFICACION 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_not_tip_gest ADD CONSTRAINT nottip_ges_noti_fk FOREIGN KEY ( notificacion_cod_noti )
    REFERENCES admsisa.co532_notificacion ( cod_noti );
