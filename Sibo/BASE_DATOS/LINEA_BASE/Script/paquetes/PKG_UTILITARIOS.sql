create or replace PACKAGE PKG_UTILITARIOS
AS
  PROCEDURE PRC_CALCULAR_REG(
                          TABLA        IN VARCHAR2 ,
                          TABLA_ERROR  IN VARCHAR2 ,
                          TABLA_BAC    IN VARCHAR2 ,
                          TOTAL_REG    OUT NUMBER,
                          TOTAL_CARGADOS OUT NUMBER ,
                          TOTAL_ERRADOS OUT NUMBER ,
                          TOTAL_BAC OUT NUMBER);

/*
FUNCTION FNC_EXCEPCISIONES_SIBO(  
                                CODERR VARCHAR2,
                                DESERR VARCHAR2) RETURN VARCHAR2;
*/  
PROCEDURE PRC_CALCULA_REG_TIPOPAGO(
                                    P_NRO_CARGA       IN  NUMBER,
                                    TOTAL_DAVIPLATA   OUT NUMBER,
                                    TOTAL_GIRO        OUT NUMBER,
                                    TOTAL_NOPAGO      OUT NUMBER,
                                    P_TOTAL_DAVIPLATA OUT NUMBER,
                                    P_TOTAL_GIRO      OUT NUMBER,
                                    P_TOTAL_NOPAGO    OUT NUMBER                                  
                                  );
                                  
PROCEDURE REPORTA_ERROR(
          P_TIPO IN VARCHAR2,
          DESCRIPCION IN CLOB
);

END PKG_UTILITARIOS;
/
create or replace PACKAGE BODY PKG_UTILITARIOS
AS
  /*****************************************************************************
  APLICACION:           SIBO DAVIPLATA
  NOMBRE:               PKG_UTILITARIOS
  PROPOSITO:            Este paquete se encarga de agrupar todos las funciones utilitarias.
  PARAMETROS:
  ENTRADA:              Ninguno
  SALIDA:               Ninguno
  DISEÑADO POR:         ASESOFTWARE
  DESARROLLADO POR:     ALFONSO PIMIENTA
  REVISIONES:
  Versión      Fecha         Autor                               Descripción
  ---------    ----------    --------------------------------    --------------
  1.0          2016-12-01    Andres Esteban Perez Ramirez        Creación Funcion.
  1.1          2016-12-09    Alfonso Pimienta                    Modificación Funcion
  1.2          2016-12-26    LEONARDO ROJAS ABRIL                CREACION PROCEDIMIENTO
  ******************************************************************************/
  PROCEDURE PRC_CALCULAR_REG(
      TABLA       IN VARCHAR2 ,
      TABLA_ERROR IN VARCHAR2 ,
      TABLA_BAC   IN VARCHAR2 ,
      TOTAL_REG OUT NUMBER ,
      TOTAL_CARGADOS OUT NUMBER ,
      TOTAL_ERRADOS OUT NUMBER ,
      TOTAL_BAC OUT NUMBER )


  AS
    SQL_STMT VARCHAR2(500);

    deadlock_detected EXCEPTION;                                                                               
    PRAGMA EXCEPTION_INIT(deadlock_detected, -942);                                                               

    BEGIN
      SQL_STMT := 'SELECT COUNT(*) FROM ';
      
      BEGIN
        EXECUTE immediate SQL_STMT ||TABLA INTO TOTAL_CARGADOS;
      EXCEPTION
      WHEN deadlock_detected THEN
        TOTAL_CARGADOS := 0;
      END;
      
      BEGIN
        EXECUTE immediate SQL_STMT ||TABLA_ERROR INTO TOTAL_ERRADOS;
      EXCEPTION
      WHEN deadlock_detected THEN
        TOTAL_ERRADOS := 0;
      END;
      
      BEGIN
        EXECUTE immediate SQL_STMT ||TABLA_BAC INTO TOTAL_BAC;
      EXCEPTION
      WHEN deadlock_detected THEN
        TOTAL_BAC := 0;
      END;

      TOTAL_REG :=TOTAL_CARGADOS + TOTAL_ERRADOS + TOTAL_BAC;

      END PRC_CALCULAR_REG;
      /*********************************************************************************************************************************/
      /* APLICATION:  SIBO DAVIPLATA                                                                                                */
      /* DESCRIPTION: PROCEDIMIENTO UTILIADO PARA CALCULAR LOS REGISTROS Y EL VALOR TOTAL POR TIPOPAGO                              */
      /* DATE:        20161226                                                                                                      */
      /* AUTHOR:      ING. LEONARDO ROJAS ABRIL                                                                                     */
      /* VERSION:     1.0                                                                                                           */
      /******************************************************************************************************************************/
      PROCEDURE PRC_CALCULA_REG_TIPOPAGO(
          P_NRO_CARGA IN NUMBER,
          TOTAL_DAVIPLATA OUT NUMBER,
          TOTAL_GIRO OUT NUMBER,
          TOTAL_NOPAGO OUT NUMBER,
          P_TOTAL_DAVIPLATA OUT NUMBER,
          P_TOTAL_GIRO OUT NUMBER,
          P_TOTAL_NOPAGO OUT NUMBER )
      IS
        CURSOR CUR_REG_UARIV
        IS
          SELECT RPT.IDTIPOPAGO   AS TIPO_PAGO,
            COUNT(RPT.IDTIPOPAGO) AS TOTAL_REGISTROS,
            SUM(PU.VALORTOTAL)    AS TOTAL_PAGO
          FROM RESUMEN_CARGUE RES,
            PRELIQ_UARIV PU,
            REL_PRELIQ_TIPOPAGO RPT
          WHERE PU.IDCARGUE = RES.IDCARGUE
          AND RPT.IDCARGUE  = PU.IDCARGUE
          AND RPT.IDPRELIQ  = PU.IDPRELIQ
          AND RES.IDCARGUE  = P_NRO_CARGA
          GROUP BY RPT.IDTIPOPAGO ;
        CURSOR CUR_REG_MFEA
        IS
          SELECT RPT.IDTIPOPAGO   AS TIPO_PAGO,
            COUNT(RPT.IDTIPOPAGO) AS TOTAL_REGISTROS,
            SUM(PMFEA.VALORTOTAL) AS TOTAL_PAGO
          FROM RESUMEN_CARGUE RES,
            PRELIQ_MFEA PMFEA,
            REL_PRELIQ_TIPOPAGO RPT
          WHERE PMFEA.IDCARGUE = RES.IDCARGUE
          AND RPT.IDCARGUE     = PMFEA.IDCARGUE
          AND RPT.IDPRELIQ     = PMFEA.IDPRELIQ
          AND RES.IDCARGUE     = P_NRO_CARGA
          GROUP BY RPT.IDTIPOPAGO ;
        CURSOR CUR_REG_OTROS
        IS
          SELECT RPT.IDTIPOPAGO   AS TIPO_PAGO,
            COUNT(RPT.IDTIPOPAGO) AS TOTAL_REGISTROS,
            SUM(OTR.VALORTOTAL)   AS TOTAL_PAGO
          FROM RESUMEN_CARGUE RES,
            PRELIQ_OTROS OTR,
            REL_PRELIQ_TIPOPAGO RPT
          WHERE OTR.IDCARGUE = RES.IDCARGUE
          AND RPT.IDCARGUE   = OTR.IDCARGUE
          AND RPT.IDPRELIQ   = OTR.IDPRELIQ
          AND RES.IDCARGUE   = P_NRO_CARGA
          GROUP BY RPT.IDTIPOPAGO ;
        CANTIDAD     NUMBER:= 0;
        P_TIPARCHIVO NUMBER:=0;
      BEGIN
        TOTAL_DAVIPLATA   :=0;
        TOTAL_GIRO        :=0;
        TOTAL_NOPAGO      :=0;
        P_TOTAL_DAVIPLATA :=0;
        P_TOTAL_GIRO      :=0;
        P_TOTAL_NOPAGO    :=0;
        BEGIN
          SELECT COUNT(1)
          INTO CANTIDAD
          FROM RESUMEN_CARGUE
          WHERE IDCARGUE = P_NRO_CARGA;
          IF CANTIDAD    = 0 THEN
            DBMS_OUTPUT.PUT_LINE('ERROR EN NRO DE CARGUE '||P_NRO_CARGA||' Y/O CARGUE SIN INFORMACION ');
          END IF;
        END;
        BEGIN
          SELECT B.IDTIPOARCHIVO
          INTO P_TIPARCHIVO
          FROM RESUMEN_CARGUE B
          WHERE B.IDCARGUE = P_NRO_CARGA;
          IF P_TIPARCHIVO  = 2 THEN
            FOR OT IN CUR_REG_OTROS
            LOOP
              IF OT.TIPO_PAGO      = 1 THEN
                TOTAL_DAVIPLATA   := OT.TOTAL_REGISTROS;
                P_TOTAL_DAVIPLATA := OT.TOTAL_PAGO;
              ELSIF OT.TIPO_PAGO   = 2 THEN
                TOTAL_GIRO        := OT.TOTAL_REGISTROS;
                P_TOTAL_GIRO      := OT.TOTAL_PAGO;
              ELSE
                TOTAL_NOPAGO   := OT.TOTAL_REGISTROS;
                P_TOTAL_NOPAGO := OT.TOTAL_PAGO;
              END IF;
            END LOOP;
          ELSIF P_TIPARCHIVO = 3 THEN
            FOR AU IN CUR_REG_UARIV
            LOOP
              IF AU.TIPO_PAGO      = 1 THEN
                TOTAL_DAVIPLATA   := AU.TOTAL_REGISTROS;
                P_TOTAL_DAVIPLATA := AU.TOTAL_PAGO;
              ELSIF AU.TIPO_PAGO   = 2 THEN
                TOTAL_GIRO        := AU.TOTAL_REGISTROS;
                P_TOTAL_GIRO      := AU.TOTAL_PAGO;
              ELSE
                TOTAL_NOPAGO   := AU.TOTAL_REGISTROS;
                P_TOTAL_NOPAGO := AU.TOTAL_PAGO;
              END IF;
            END LOOP;
          ELSIF P_TIPARCHIVO = 4 THEN
            FOR MF IN CUR_REG_MFEA
            LOOP
              IF MF.TIPO_PAGO      = 1 THEN
                TOTAL_DAVIPLATA   := MF.TOTAL_REGISTROS;
                P_TOTAL_DAVIPLATA := MF.TOTAL_PAGO;
              ELSIF MF.TIPO_PAGO   = 2 THEN
                TOTAL_GIRO        := MF.TOTAL_REGISTROS;
                P_TOTAL_GIRO      := MF.TOTAL_PAGO;
              ELSE
                TOTAL_NOPAGO   := MF.TOTAL_REGISTROS;
                P_TOTAL_NOPAGO := MF.TOTAL_PAGO;
              END IF;
            END LOOP;
          END IF;
          DBMS_OUTPUT.PUT_LINE('TOTAL REGISTROS DAVIPLATA: '||TOTAL_DAVIPLATA||' TOTAL VALOR DAVIPLATA: '||P_TOTAL_DAVIPLATA );
          DBMS_OUTPUT.PUT_LINE('TOTAL REGISTROS TOTAL_GIRO: '||TOTAL_GIRO||' TOTAL VALOR GIRO: '||P_TOTAL_GIRO );
          DBMS_OUTPUT.PUT_LINE('TOTAL REGISTROS TOTAL_NOPAGO: '||TOTAL_NOPAGO||' TOTAL VALOR NO PAGAR: '||P_TOTAL_NOPAGO );
        END;
      END PRC_CALCULA_REG_TIPOPAGO;
    PROCEDURE REPORTA_ERROR(
        P_TIPO      IN VARCHAR2,
        DESCRIPCION IN CLOB )
    IS
    BEGIN
      INSERT INTO AUDITORIA
        (TIPO, DESCRIPCION
        ) VALUES
        (P_TIPO, DESCRIPCION
        );
      COMMIT;
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;
END PKG_UTILITARIOS;
/