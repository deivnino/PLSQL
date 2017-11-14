CREATE OR REPLACE PACKAGE admsisa.ObjetarSubsanar IS
  PROCEDURE Principal(RamCdgo      VARCHAR2,
                      CodgoAmpro   VARCHAR2,
                      NmroSnstro   NUMBER,
                      NmroSlctud   NUMBER,
                      Objeta       VARCHAR2,
                      EstSinst     VARCHAR2,
                      EstLiquid    VARCHAR2,
                      NmroPlza     NUMBER,
                      ClsePlza     VARCHAR2,
                      FchaObjecion DATE,
                      FchaSubsn    DATE);
  gPeriodo    VARCHAR2(7);
  gPeriodoNew VARCHAR2(7);
  gInserto    VARCHAR2(7) := 'N';
END ObjetarSubsanar;
/