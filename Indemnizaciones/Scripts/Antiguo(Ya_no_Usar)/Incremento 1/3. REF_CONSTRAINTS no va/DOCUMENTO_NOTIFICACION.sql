--------------------------------------------------------
--  Ref Constraints for Table DOCUMENTO_NOTIFICACION
--------------------------------------------------------

  ALTER TABLE "DOCUMENTO_NOTIFICACION" ADD CONSTRAINT "DOCU_NOTI_NOTI_FK" FOREIGN KEY ("NOTIFICACION_SOLICITUD", "NOTIFICACION_FEC_NOTI")
	  REFERENCES "NOTIFICACION" ("SOLICITUD", "FEC_NOTI") ENABLE;
