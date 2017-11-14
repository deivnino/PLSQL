create or replace PACKAGE PKG_CARGUE_ARCHIVOS
AS
  /*****************************************************************************
  APLICACION:           SIBO DAVIPLATA
  NOMBRE:               PKG_CARGUE_ARCHIVOS
  PROPOSITO:            Este paquete se encarga de agrupar todas las funciones y/o
  procedimientos utilizados para el cargue de archivos deL sistema DAVIPLATA.
  
  PARAMETROS:
  ENTRADA:              p_prefijo:      Prefijo del archivo de cargue
  SALIDA:               Ninguno
  
  DISEÑADO POR:         ASESOFTWARE
  DESARROLLADO POR:     ALFONSO PIMIENTA
  REVISIONES:
  Versión      Fecha         Autor                               Descripción
  ---------    ----------    --------------------------------    --------------
  1.0          2016-11-30    Alfonso Pimienta Trujillo           Creación Procedimiento.
  ******************************************************************************/    

    PROCEDURE PRC_GENERICO_CARGUE(
                                  P_NOMBRE_ARCHIVO_ORIGEN     IN VARCHAR2,
                                  P_FECHA_ARCHIVO             IN VARCHAR2,                     
                                  P_TIPO_ARCHIVO              IN INTEGER,
                                  P_PREFIJO_TABLA_TEMP_ERROR  IN VARCHAR2,
                                  P_PREFIJO_TABLA_TEMP_BAD    IN VARCHAR2,
                                  P_PREFIJO_TABLA_TEM_STAGE   IN VARCHAR2,
                                  P_TABLA_DE_DESTINO          IN VARCHAR2,
                                  P_CURSORES_CADENA           IN VARCHAR2,
                                  P_COLUMNAS_TABLA_DESTINO    IN VARCHAR2,                                  
                                  P_SECUENCIA_TABLA_DESTINO   IN VARCHAR2,
                                  P_CONCATENA_CADENA_ERROR    IN VARCHAR2,
                                  P_SALIDA                    OUT NUMBER);


END PKG_CARGUE_ARCHIVOS;
/
create or replace PACKAGE BODY PKG_CARGUE_ARCHIVOS
    /*****************************************************************************
    APLICACION:           SIBO DAVIPLATA
    NOMBRE:               PKG_CARGUE_ARCHIVOS
    PROPOSITO:            Este paquete se encarga de agrupar todas las funciones y/o
    procedimientos utilizados para el cargue de archivos deL sistema DAVIPLATA.
    
    PARAMETROS:
    ENTRADA:              Ninguno
    SALIDA:               Ninguno
    
    DISEÑADO POR:         ASESOFTWARE
    DESARROLLADO POR:     ALFONSO PIMIENTA
  
    REVISIONES:
    Versión      Fecha         Autor                               Descripción
    ---------    ----------    --------------------------------    --------------
    1.0          2016-11-30    Alfonso Pimienta Trujillo           Creación Procedimiento.
    ******************************************************************************/
  AS
    --VARIABLES GLOBALES
    GLOB_NOMBRE_TABLA_STAGE                 VARCHAR2(100);
    GLOB_NOMBRE_TABLA_ERROR                 VARCHAR2(100);
    GLOB_NOMBRE_TABLA_BAD                   VARCHAR2(100);
    GLOB_NOMBRE_TABLA_DATOS                 VARCHAR2(100);
    GLOB_CADENA_COLUMNAS                    VARCHAR2(300);
    GLOB_TIPO_ARCHIVO                       VARCHAR2(30);
    GLOBL_SEC_ID_DESTINO                    VARCHAR2(30);
    
    --CONSTANTES
    C_BANDERA_ALTA                          CONSTANT NUMERIC      := 0;
    C_BANDERA_BAJA                          CONSTANT NUMERIC      := 1;
    C_TIPO_ARCHIVO                          CONSTANT INTEGER      := 1;   
    
    PROCEDURE PRC_CREAR_PRC_CARGUE_DINAMICO(
                                            P_NOMBRE_ARCHIVO_ORIGEN         IN VARCHAR2,
                                            P_FECHA_ARCHIVO                 IN VARCHAR2,
                                            P_NOMBRE_TABLA_DESTINO          IN VARCHAR2, 
                                            P_COLUMNAS_TABLA_DESTINO        IN VARCHAR2,
                                            P_CURSORES_CADENA               IN VARCHAR2,
                                            P_CAMPO_CONCATENA_CADENA_ERROR  IN VARCHAR2
                                            )
    IS
    CLOB_PRC_DINAMICO       CLOB;
    
    PREFIJO_TABLA_TEMP_ERROR                VARCHAR2(100);
    PREFIJO_TABLA_TEMP_BAD                  VARCHAR2(100);
    PREFIJO_TABLA_TEM_STAGE                 VARCHAR2(100);
    TABLA_DE_DESTINO                        VARCHAR2(100);    
    CAMPOS_SELECT_DE_CARGUE                 CLOB;
    CADENA_CURSOR__INSERTAR                 CLOB;
    CAMPO_CONCATENA_CADENA_ERROR            CLOB;

    L_ERROR         VARCHAR2(6);
    L_ERRM          CLOB;
    BEGIN
    TABLA_DE_DESTINO                        := P_NOMBRE_TABLA_DESTINO;
    CAMPOS_SELECT_DE_CARGUE                 := P_COLUMNAS_TABLA_DESTINO;
    CADENA_CURSOR__INSERTAR                 := P_CURSORES_CADENA;
    CAMPO_CONCATENA_CADENA_ERROR            := P_CAMPO_CONCATENA_CADENA_ERROR;

      BEGIN
      
      --PKG_UTILITARIOS.REPORTA_ERROR( '0001', 'INICIA CREACIÓN DE PROCEDIMINETO CARGAR SIBO');
            
      CLOB_PRC_DINAMICO := 'CREATE OR REPLACE PROCEDURE PRC_CARGAR_DATOS_SIBO_DINAMIC(P_NOMBRE_TABLA_STAGE     IN VARCHAR2, ' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '                                    P_NOMBRE_TABLA_DATOS      IN VARCHAR2, ' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '                                    P_CADENA_CURSOR__INSERTAR IN VARCHAR2, ' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '                                    P_TIPOARCHIVO             IN INTEGER,  ' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '                                    P_SEC_ID_TABLA_DE_NEGOCIO IN VARCHAR2, ' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '                                    P_ID_RESUMEN              OUT INTEGER) ' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '/*****************************************************************************' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'APLICACION:           SIBO DAVIPLATA' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'NOMBRE:               PRC_CARGUE_ARCHIVOS' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'PROPOSITO:            Procedimiento encargado cargar los datos a SIBO.' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'PARAMETROS:' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'ENTRADA:              Nimguno' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'SALIDA:               Ninguno' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'DISEÑADO POR:         ASESOFTWARE' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'DESARROLLADO POR:     ALFONSO PIMIENTA' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'REVISIONES:' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'Versión      Fecha         Autor                               Descripción'            ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '---------    ----------    --------------------------------    --------------'         ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '1.0          2016-12-14    Alfonso Pimienta Trujillo           Creación Procedimiento.'||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '******************************************************************************/' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || CHR(10);  
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'IS' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'TABLA_ORIGEN                            VARCHAR2(100);'   ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'TABLA_DESTINO                           VARCHAR2(100);'   ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'CADENA_CURSOR__INSERTAR                 VARCHAR2(4000);' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'CADENA_INSERTAR                         VARCHAR2(4000);' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'SQL_DINAMICO_INSERT                     VARCHAR2(4000);' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'SQL_DINAMICO_SELECT                     VARCHAR2(4000);' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'SEC_ID_TABLA_DE_NEGOCIO                 VARCHAR2(30);'   ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'TIPO_ARCHIVO                            INTEGER;' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'SEC_RESUMEN_CARGUE                      INTEGER;' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'SEC_NUMERO_CARGUE_DIARIO                INTEGER;' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'SEC_TABLA_FINAL                         INTEGER;' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || CHR(10);    
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'TYPE REF_CUR                            IS REF CURSOR;' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'CUR_STAGE                               REF_CUR;' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'TIPO_RECORD                             '||TABLA_DE_DESTINO||'%ROWTYPE;' ||CHR(10);
      
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '--EXCEPCIONES' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'MISSING_EXPRESSION EXCEPTION;' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'PRAGMA EXCEPTION_INIT(MISSING_EXPRESSION, -00936);' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || CHR(10);      
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '      BEGIN' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '    TABLA_ORIGEN                        := P_NOMBRE_TABLA_STAGE;'     ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '    TABLA_DESTINO                       := P_NOMBRE_TABLA_DATOS;'     ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '    CADENA_CURSOR__INSERTAR             := P_CADENA_CURSOR__INSERTAR;'||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '    TIPO_ARCHIVO                        := P_TIPOARCHIVO;'            ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '    SEC_ID_TABLA_DE_NEGOCIO             := P_SEC_ID_TABLA_DE_NEGOCIO;'                         ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || CHR(10);        
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || ' PKG_UTILITARIOS.REPORTA_ERROR(''TABLA_ORIGEN:'',TABLA_ORIGEN);'                                ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || ' PKG_UTILITARIOS.REPORTA_ERROR(''TABLA_DESTINO:'',TABLA_DESTINO);'                              ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || ' PKG_UTILITARIOS.REPORTA_ERROR(''CADENA_CURSOR_INSERTAR:'',CADENA_CURSOR__INSERTAR);'          ||CHR(10);
      
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || CHR(10);        
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '    SELECT SEQ_RESUMEN_CARGUE.NEXTVAL INTO SEC_RESUMEN_CARGUE FROM DUAL;' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '    SELECT SEQ_NUMERO_CARGUE_DIARIO.NEXTVAL INTO SEC_NUMERO_CARGUE_DIARIO FROM DUAL;' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || CHR(10);        
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '        P_ID_RESUMEN                        := SEC_RESUMEN_CARGUE;' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || CHR(10);        
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '    BEGIN' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || CHR(10);        
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '      SQL_DINAMICO_INSERT               := SQL_DINAMICO_INSERT || ''INSERT INTO RESUMEN_CARGUE  VALUES'' || CHR(10);' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '      SQL_DINAMICO_INSERT               := SQL_DINAMICO_INSERT || ''('' || SEC_RESUMEN_CARGUE|| '','' || TIPO_ARCHIVO ||'',TO_DATE('''''||P_FECHA_ARCHIVO||''''',''''YYYYMMDD''''), TO_CHAR(SYSDATE, ''''hh:mi:ss''''),'' || CHR(10);' ||CHR(10);
      --CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '      SQL_DINAMICO_INSERT               := SQL_DINAMICO_INSERT || ''('' || SEC_RESUMEN_CARGUE|| '','' || TIPO_ARCHIVO ||'',TO_DATE('''''||P_FECHA_ARCHIVO||'''''), TO_CHAR(SYSDATE, ''''hh:mi:ss''''),'' || CHR(10);' ||CHR(10);
      --CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '    SQL_DINAMICO_INSERT               := SQL_DINAMICO_INSERT || ''TO_NUMBER('' || SEC_NUMERO_CARGUE_DIARIO||''),0,0,0,  TO_NUMBER(TO_CHAR(SYSDATE, ''''DDMMYYYYHH''''))'' || CHR(10);' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '      SQL_DINAMICO_INSERT               := SQL_DINAMICO_INSERT || ''TO_NUMBER('' || SEC_NUMERO_CARGUE_DIARIO||''),0,0,0,  '''''|| P_NOMBRE_ARCHIVO_ORIGEN || ''''''' || CHR(10);' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '      SQL_DINAMICO_INSERT               := SQL_DINAMICO_INSERT || '',0,0)''   || CHR(10);' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || CHR(10);
      
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '      PKG_UTILITARIOS.REPORTA_ERROR(''INF-INSERT:'',SQL_DINAMICO_INSERT);' ||CHR(10);
      
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '      EXECUTE IMMEDIATE SQL_DINAMICO_INSERT;' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '      COMMIT;' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '    EXCEPTION WHEN OTHERS THEN' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '      ROLLBACK;' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '      DBMS_OUTPUT.PUT_LINE(''ERROR EN INSERT DE RESUMEN DE CARGUE -''||SQLERRM);' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '    END;' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || CHR(10);    
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '      SQL_DINAMICO_SELECT := ''SELECT ' || CAMPOS_SELECT_DE_CARGUE || ' FROM '' || TABLA_ORIGEN;' ||CHR(10);
      
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || ' PKG_UTILITARIOS.REPORTA_ERROR(''INF-SELECT:'',SQL_DINAMICO_SELECT);'          ||CHR(10);      
      
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '      OPEN CUR_STAGE FOR SQL_DINAMICO_SELECT; --EN TIEMPO DE EJECUCIÓN' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '      LOOP' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || CHR(10);    
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '        FETCH CUR_STAGE INTO TIPO_RECORD;' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '         EXIT WHEN CUR_STAGE%NOTFOUND;' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '         EXECUTE IMMEDIATE ''SELECT '' || SEC_ID_TABLA_DE_NEGOCIO || ''.NEXTVAL FROM DUAL'' INTO  SEC_TABLA_FINAL;' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || CHR(10);    
      
      
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '         CADENA_INSERTAR                := SEC_TABLA_FINAL;' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '         CADENA_INSERTAR                := CADENA_INSERTAR  || '', '' || SEC_RESUMEN_CARGUE;' ||CHR(10);
      
      IF TABLA_DE_DESTINO LIKE '%LISTAS_R%' THEN
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '         CADENA_INSERTAR                := CADENA_INSERTAR  || '','' ||' || CADENA_CURSOR__INSERTAR ||CHR(10);
      ELSE
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '         CADENA_INSERTAR                := CADENA_INSERTAR  || '', '''''' ||' || CADENA_CURSOR__INSERTAR ||CHR(10);
      END IF;
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '         PKG_UTILITARIOS.REPORTA_ERROR(''INF-INSERT'',CADENA_INSERTAR);' || CHR(10);
      --DBMS_OUTPUT.PUT_LINE(CADENA_INSERTAR);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || CHR(10);    
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '         --INSERTA DATOS EN SIBO' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '       BEGIN' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '         SQL_DINAMICO_INSERT            := ''INSERT INTO ''    || TABLA_DESTINO  ||CHR(10);' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '         SQL_DINAMICO_INSERT            := SQL_DINAMICO_INSERT || '' VALUES(''||CHR(10);' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '         SQL_DINAMICO_INSERT            := SQL_DINAMICO_INSERT || CADENA_INSERTAR||CHR(10);' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '         SQL_DINAMICO_INSERT            := SQL_DINAMICO_INSERT || '')''||CHR(10);' ||CHR(10);

      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '         PKG_UTILITARIOS.REPORTA_ERROR(''INF-INSERT:'',SQL_DINAMICO_INSERT);' ||CHR(10);

      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || CHR(10);  
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '         EXECUTE IMMEDIATE SQL_DINAMICO_INSERT;' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '         COMMIT;' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '       EXCEPTION WHEN OTHERS THEN'  ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '       PKG_UTILITARIOS.REPORTA_ERROR(''ERROR'',SQLERRM);' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '     END;'  ||CHR(10);
      
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || CHR(10);    
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '      END LOOP;' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '      CLOSE CUR_STAGE;' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || CHR(10);    
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '  EXCEPTION ' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '  WHEN MISSING_EXPRESSION THEN' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '  DBMS_OUTPUT.PUT_LINE(''ERROR: DATO OBLIGATORIO NULO EN LA TABLA DESTINO'');' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '  WHEN OTHERS THEN' ||CHR(10);
      
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '    PKG_UTILITARIOS.REPORTA_ERROR(''ERROR'',SQLERRM);' ||CHR(10);      
      
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '  DBMS_OUTPUT.PUT_LINE(''ERROR: ''||SQLERRM);' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '  IF CUR_STAGE%ISOPEN THEN' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '  CLOSE CUR_STAGE;' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || '  END IF;' ||CHR(10);
      CLOB_PRC_DINAMICO := CLOB_PRC_DINAMICO || 'END PRC_CARGAR_DATOS_SIBO_DINAMIC;' ||CHR(10);
      
      PKG_UTILITARIOS.REPORTA_ERROR( 'INF-DINAMICO', CLOB_PRC_DINAMICO);
      
      EXECUTE IMMEDIATE CLOB_PRC_DINAMICO;
      EXCEPTION WHEN OTHERS THEN
      L_ERROR         := SQLCODE;
      L_ERRM          := SQLERRM;
      PKG_UTILITARIOS.REPORTA_ERROR( L_ERROR, L_ERRM);
      CLOB_PRC_DINAMICO     := 'CREATE OR REPLACE PROCEDURE PRC_CARGAR_DATOS_SIBO_DINAMIC(P_NOMBRE_TABLA_STAGE     IN VARCHAR2,' ||CHR(10);
      CLOB_PRC_DINAMICO     := CLOB_PRC_DINAMICO||'P_NOMBRE_TABLA_DATOS      IN VARCHAR2, ' ||CHR(10);
      CLOB_PRC_DINAMICO     := CLOB_PRC_DINAMICO||'P_CADENA_CURSOR__INSERTAR IN VARCHAR2, ' ||CHR(10);
      CLOB_PRC_DINAMICO     := CLOB_PRC_DINAMICO||'P_TIPOARCHIVO             IN INTEGER,  ' ||CHR(10);
      CLOB_PRC_DINAMICO     := CLOB_PRC_DINAMICO||'P_SEC_ID_TABLA_DE_NEGOCIO IN VARCHAR2, ' ||CHR(10);
      CLOB_PRC_DINAMICO     := CLOB_PRC_DINAMICO||'P_ID_RESUMEN              OUT INTEGER)' ||CHR(10);
      CLOB_PRC_DINAMICO     := CLOB_PRC_DINAMICO||'AS' ||CHR(10);
      CLOB_PRC_DINAMICO     := CLOB_PRC_DINAMICO||'BEGIN' ||CHR(10);
      CLOB_PRC_DINAMICO     := CLOB_PRC_DINAMICO||'NULL;' ||CHR(10);
      CLOB_PRC_DINAMICO     := CLOB_PRC_DINAMICO||'END PRC_CARGAR_DATOS_SIBO_DINAMIC;';
      EXECUTE IMMEDIATE CLOB_PRC_DINAMICO;
      DBMS_OUTPUT.PUT_LINE(SQLERRM);    
      END;  

    END PRC_CREAR_PRC_CARGUE_DINAMICO;
    
    PROCEDURE PRC_CREA_CARGAR_ERRORES_SIBO(P_CAMPO_CONCATENA_CADENA_ERROR  IN VARCHAR2)
    IS
    CLOB_PRC_DINAMICO                       CLOB;
    CAMPO_CONCATENA_CADENA_ERROR            CLOB;
    
    BEGIN

    CAMPO_CONCATENA_CADENA_ERROR            :=P_CAMPO_CONCATENA_CADENA_ERROR;

          BEGIN
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || 'CREATE OR REPLACE PROCEDURE PRC_CARGAR_ERRORES_SIBO(' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '                             P_ID_RESUMEN_CARGUE             IN INTEGER,  ' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '                             P_TABLA_ERROR                   IN OUT VARCHAR2,' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '                             P_TABLA_BAD                     IN OUT VARCHAR2 )' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' /*****************************************************************************' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' APLICACION:           SIBO DAVIPLATA' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' NOMBRE:               PRC_CARGUE_ERRORES' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' PROPOSITO:            Este procedimiento se encarga de cargar las líneas  con ' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' errores en ODI al sistema DAVIPLATA.' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO ||   CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' PARAMETROS: ' || CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' ENTRADA:              Nimguno' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' SALIDA:               Ninguno' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO ||   CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' DISEÑADO POR:         ASESOFTWARE' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' DESARROLLADO POR:     ALFONSO PIMIENTA' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO ||   CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' REVISIONES:' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' Versión      Fecha         Autor                               Descripción' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' ---------    ----------    --------------------------------    --------------' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' 1.0          2016-11-30    Alfonso Pimienta Trujillo           Creación Procedimiento.' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' ******************************************************************************/' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' IS' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO ||   CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' CAMPOS_SELECT_DE_CARGUE                 VARCHAR2(1000);' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' ID_RESUMEN_CARGUE                       INTEGER;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' P_NOMBRE_PARAMETRO_ERROR                VARCHAR2(30);' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' P_NOMBRE_PARAMETRO_BAD                  VARCHAR2(30);' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' PREFIJO_ERROR                           VARCHAR2(100);' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' PREFIJO_BAD                             VARCHAR2(100);' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO ||   CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' L_ERROR_CARGUE                          ERROR_CARGUE_LINEA%ROWTYPE;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' CUR_ERROR                               SYS_REFCURSOR;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' CUR_BAD                                 SYS_REFCURSOR;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO ||   CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' QUERY_ERROR                             VARCHAR2(1000) ;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' QUERY_BAD                               VARCHAR2(1000);' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' NOMBRETABLA_ERR                         VARCHAR2(30);' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' NOMBRETABLA_BAD                         VARCHAR2(30);' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' SEC_ERROR_CARGUE                        VARCHAR2(200);' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO ||   CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || 'BEGIN' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || ' BEGIN' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '    PREFIJO_ERROR                  := P_TABLA_ERROR;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '    PREFIJO_BAD                    := P_TABLA_BAD;  ' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '    DBMS_OUTPUT.PUT_LINE(''IMPRIME:''||PREFIJO_ERROR);' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '    DBMS_OUTPUT.PUT_LINE(''IMPRIME:''||PREFIJO_BAD);' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO ||      CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '       BEGIN' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '       P_NOMBRE_PARAMETRO_ERROR   := PREFIJO_ERROR;' ||CHR(10);
      --CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '        SELECT VALOR_PARAMETRO INTO P_NOMBRE_PARAMETRO_ERROR FROM PARAMETROS_SIBO WHERE NOMBRE_PARAMETRO = PREFIJO_ERROR;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '       EXCEPTION WHEN NO_DATA_FOUND THEN' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '       DBMS_OUTPUT.PUT_LINE(''NO EXISTE EL PREFIJO ''||PREFIJO_ERROR);' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '       END;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO ||      CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '       BEGIN' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '       P_NOMBRE_PARAMETRO_BAD    := PREFIJO_BAD;' ||CHR(10);
      --CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '        SELECT VALOR_PARAMETRO INTO P_NOMBRE_PARAMETRO_BAD   FROM PARAMETROS_SIBO WHERE NOMBRE_PARAMETRO = PREFIJO_BAD;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '       EXCEPTION WHEN NO_DATA_FOUND THEN' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '       DBMS_OUTPUT.PUT_LINE(''NO EXISTE EL PREFIJO ''||PREFIJO_BAD);' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '       END;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   EXCEPTION' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   WHEN OTHERS THEN ' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   DBMS_OUTPUT.PUT_LINE(''ERROR EN SELECT A PARAMAETROS: ''|| SQLERRM);' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   --RAISE_APPLICATION_ERROR(-22000, SQLERRM);' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   END;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO ||   CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   NOMBRETABLA_ERR                       :=  P_NOMBRE_PARAMETRO_ERROR || TRIM(TO_CHAR(SYSDATE,''YYYYMMDD''));' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   NOMBRETABLA_BAD                       :=  P_NOMBRE_PARAMETRO_BAD;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   --DBMS_OUTPUT.PUT_LINE(''NOMBRETABLA_ERR: ''||NOMBRETABLA_ERR );' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO ||   CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   P_TABLA_ERROR                         :=  NOMBRETABLA_ERR;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   P_TABLA_BAD                           :=  NOMBRETABLA_BAD;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO ||   CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   ID_RESUMEN_CARGUE                     :=  P_ID_RESUMEN_CARGUE;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO ||   CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   QUERY_ERROR                           := ''SELECT 1 ID, 1 AS RESUMEN_CARGUE ,' || CAMPO_CONCATENA_CADENA_ERROR || '''||'' FROM '' || NOMBRETABLA_ERR;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   --DBMS_OUTPUT.PUT_LINE(QUERY_ERROR);' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO ||   CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   QUERY_BAD                             :=  ''SELECT 1 AS IDCARGUE, 1 AS IDERRORLINEACARGUE, LINEA, NVL(DESCRIPCION , ''''SIN DESCRIPCION'''') FROM '' || NOMBRETABLA_BAD;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   --DBMS_OUTPUT.PUT_LINE(QUERY_BAD);' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO ||   CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   OPEN CUR_ERROR FOR QUERY_ERROR;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   LOOP' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '    FETCH CUR_ERROR INTO L_ERROR_CARGUE;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '     EXIT WHEN CUR_ERROR%NOTFOUND;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '       BEGIN            ' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO ||   CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '         INSERT INTO ERROR_CARGUE_LINEA(IDERRORLINEACARGUE, IDCARGUE,  LINEA, DESCRIPCIONERROR)' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '         VALUES( ' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '                 SEQ_ERROR_CARGUE_LINEA.NEXTVAL,' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '                 ID_RESUMEN_CARGUE,' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '                 L_ERROR_CARGUE.LINEA,' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '                 L_ERROR_CARGUE.DESCRIPCIONERROR);' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '           EXCEPTION WHEN OTHERS THEN' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '         DBMS_OUTPUT.PUT_LINE(''ERROR EN ERROR: ''|| TRIM(SQLCODE) || '' DESCRIPCION: '' || SQLERRM);' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '       END;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   END LOOP;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   CLOSE CUR_ERROR;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   COMMIT;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO ||   CHR(10);    
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '       OPEN CUR_BAD FOR QUERY_BAD;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   LOOP' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '    FETCH CUR_BAD INTO L_ERROR_CARGUE;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '     EXIT WHEN CUR_BAD%NOTFOUND;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '       BEGIN            ' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '             INSERT INTO ERROR_CARGUE_LINEA' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '             (IDERRORLINEACARGUE, IDCARGUE,  LINEA, DESCRIPCIONERROR)' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '             VALUES( ' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '                 SEQ_ERROR_CARGUE_LINEA.NEXTVAL,' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '                 ID_RESUMEN_CARGUE,' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '                 L_ERROR_CARGUE.LINEA,' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '                 L_ERROR_CARGUE.DESCRIPCIONERROR);' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO ||     CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '       EXCEPTION WHEN OTHERS THEN' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '         DBMS_OUTPUT.PUT_LINE(''ERROR EN BAD: ''|| TRIM(SQLCODE) || '' DESCRIPCION: '' || SQLERRM);' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '       END;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   END LOOP;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   CLOSE CUR_BAD;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   COMMIT;' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO ||     CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   EXCEPTION WHEN OTHERS THEN' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '         DBMS_OUTPUT.PUT_LINE(''ERROR GENERAL: ''|| TRIM(SQLCODE) ||  SQLERRM);' ||CHR(10);
      CLOB_PRC_DINAMICO     :=CLOB_PRC_DINAMICO || '   END PRC_CARGAR_ERRORES_SIBO;' ||CHR(10);
     EXECUTE IMMEDIATE CLOB_PRC_DINAMICO;
     EXCEPTION WHEN OTHERS THEN
     DBMS_OUTPUT.PUT_LINE('ERROR EN LA CREACIÓN DEL PRC DINAMICO DE CARGA DE ERRORES SIBO-'||SQLERRM);
     END; 
    END PRC_CREA_CARGAR_ERRORES_SIBO;
    
    /*
    PROCEDURE PRC_CARGAR_ERRORES_SIBO(
                                      P_ID_RESUMEN_CARGUE             IN INTEGER,
                                      P_TABLA_ERROR                   OUT VARCHAR2, 
                                      P_TABLA_BAD                     OUT VARCHAR2
                                      )
    
    /*****************************************************************************
    APLICACION:           SIBO DAVIPLATA
    NOMBRE:               PRC_CARGUE_ERRORES
    PROPOSITO:            Este procedimiento se encarga de cargar las líneas  con 
    errores en ODI al sistema DAVIPLATA.
    
    PARAMETROS:
    ENTRADA:              Nimguno
    SALIDA:               Ninguno
    
    DISEÑADO POR:         ASESOFTWARE
    DESARROLLADO POR:     ALFONSO PIMIENTA
  
    REVISIONES:
    Versión      Fecha         Autor                               Descripción
    ---------    ----------    --------------------------------    --------------
    1.0          2016-11-30    Alfonso Pimienta Trujillo           Creación Procedimiento.
    ******************************************************************************
    IS

    CAMPOS_SELECT_DE_CARGUE                 VARCHAR2(1000);
    ID_RESUMEN_CARGUE                       INTEGER;
    P_NOMBRE_PARAMETRO_ERROR                VARCHAR2(30);
    P_NOMBRE_PARAMETRO_BAD                  VARCHAR2(30);
    PREFIJO_ERROR                           VARCHAR2(30);
    PREFIJO_BAD                             VARCHAR2(30);
    
    L_ERROR_CARGUE                          ERROR_CARGUE_LINEA%ROWTYPE;
    CUR_ERROR                               SYS_REFCURSOR;
    CUR_BAD                                 SYS_REFCURSOR;

    QUERY_ERROR                             VARCHAR2(1000) ;
    QUERY_BAD                               VARCHAR2(1000);
    NOMBRETABLA_ERR                         VARCHAR2(30);
    NOMBRETABLA_BAD                         VARCHAR2(30);
    SEC_ERROR_CARGUE                        VARCHAR2(200);
    
    BEGIN

      BEGIN
        SELECT VALOR_PARAMETRO INTO P_NOMBRE_PARAMETRO_ERROR FROM PARAMETROS_SIBO WHERE NOMBRE_PARAMETRO = PREFIJO_ERROR;
        SELECT VALOR_PARAMETRO INTO P_NOMBRE_PARAMETRO_BAD   FROM PARAMETROS_SIBO WHERE NOMBRE_PARAMETRO = PREFIJO_BAD;
      EXCEPTION
      WHEN OTHERS THEN 
      DBMS_OUTPUT.PUT_LINE('ERROR EN SELECT A PARAMAETROS: '|| SQLERRM);
      --RAISE_APPLICATION_ERROR(-22000, SQLERRM);
      END;

      
      NOMBRETABLA_ERR                       :=  P_NOMBRE_PARAMETRO_ERROR || TRIM(TO_CHAR(SYSDATE,'YYYYMMDD'));
      NOMBRETABLA_BAD                       :=  P_NOMBRE_PARAMETRO_BAD;
      --DBMS_OUTPUT.PUT_LINE('NOMBRETABLA_ERR: '||NOMBRETABLA_ERR );
      
      P_TABLA_ERROR                         :=  'ERR$_PRELIQ_GENERICO20161219'; --NOMBRETABLA_ERR;
      P_TABLA_BAD                           :=  'WTMP_PRELIQ_GENERICO_EXT_BAD'; --NOMBRETABLA_BAD;
      
      ID_RESUMEN_CARGUE                     :=   P_ID_RESUMEN_CARGUE;
      
      QUERY_ERROR                           :=  'SELECT 1 AS IDCARGUE, 1 AS IDERRORLINEACARGUE ';
      
      QUERY_ERROR                           :=  QUERY_ERROR || CAMPOS_SELECT_DE_CARGUE || ' FROM ' || NOMBRETABLA_ERR;
      --DBMS_OUTPUT.PUT_LINE(QUERY_ERROR);
      
      QUERY_BAD                             :=  'SELECT 1 AS IDCARGUE, 1 AS IDERRORLINEACARGUE, LINEA, NVL(DESCRIPCION , ''SIN DESCRIPCION'') FROM '||NOMBRETABLA_BAD;
      --DBMS_OUTPUT.PUT_LINE(QUERY_BAD);


      OPEN CUR_ERROR FOR QUERY_ERROR;
      LOOP
       FETCH CUR_ERROR INTO L_ERROR_CARGUE;
        EXIT WHEN CUR_ERROR%NOTFOUND;
          BEGIN            
             
            INSERT INTO ERROR_CARGUE_LINEA
                (
                IDERRORLINEACARGUE, IDCARGUE,  LINEA, DESCRIPCIONERROR
                )

             VALUES( 
                    SEQ_ERROR_CARGUE_LINEA.NEXTVAL,
                    L_ERROR_CARGUE.IDCARGUE,
                    L_ERROR_CARGUE.LINEA,
                    L_ERROR_CARGUE.DESCRIPCIONERROR
                    );
                    
          EXCEPTION WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR EN ERROR: '|| TRIM(SQLCODE) || ' DESCRIPCION: ' || SQLERRM);
          END;
      END LOOP;
      CLOSE CUR_ERROR;
      COMMIT;


      OPEN CUR_BAD FOR QUERY_BAD;
      LOOP
       FETCH CUR_BAD INTO L_ERROR_CARGUE;
        EXIT WHEN CUR_BAD%NOTFOUND;
          BEGIN            

            INSERT INTO ERROR_CARGUE_LINEA
                (
                IDERRORLINEACARGUE, IDCARGUE,  LINEA, DESCRIPCIONERROR
                )

             VALUES( 
                    SEQ_ERROR_CARGUE_LINEA.NEXTVAL,
                    L_ERROR_CARGUE.IDCARGUE,
                    L_ERROR_CARGUE.LINEA,
                    L_ERROR_CARGUE.DESCRIPCIONERROR
                    );

          EXCEPTION WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR EN BAD: '|| TRIM(SQLCODE) || ' DESCRIPCION: ' || SQLERRM);
          END;
      END LOOP;
      CLOSE CUR_BAD;
      COMMIT;

      EXCEPTION WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR GENERAL: '|| TRIM(SQLCODE) ||  SQLERRM);
      END PRC_CARGAR_ERRORES_SIBO;
    */
    PROCEDURE PRC_ACTUALIZA_RESUMEN_CARGUE(
                                          P_TABLA             IN VARCHAR2,
                                          P_TABLA_ERROR       IN VARCHAR2,
                                          P_TABLA_BAC         IN VARCHAR2,                                    
                                          P_ID_CARGUE         IN NUMBER)
    /*****************************************************************************
    APLICACION:           SIBO DAVIPLATA
    NOMBRE:               PRC_ACTUALIZA_RESUMEN_CARGUE
    PROPOSITO:            Este procedimiento se encarga de calcular y actualizar los 
    reguistros procesados del archivo de cargue.
    
    PARAMETROS:
    ENTRADA:              Nimguno
    SALIDA:               Ninguno
    
    DISEÑADO POR:         ASESOFTWARE
    DESARROLLADO POR:     ALFONSO PIMIENTA
  
    REVISIONES:
    Versión      Fecha         Autor                               Descripción
    ---------    ----------    --------------------------------    --------------
    1.0          2016-11-30    Alfonso Pimienta Trujillo           Creación Procedimiento.
    ******************************************************************************/
    IS
      SAL_TOTAL_REGISTROS                   NUMBER;
      SAL__TOTAL_CARGADOS                   NUMBER;
      SAL_TOTAL_ERRADOS                     NUMBER;
      SAL_TOTAL_BAC                         NUMBER;

      TOTAL_REGISTROS                       NUMBER;
      TOTAL_CARGADOS                        NUMBER;
      TOTAL_ERRADOS                         NUMBER;
      TOTAL_BAC                             NUMBER;
    
    BEGIN
    
      
      PKG_UTILITARIOS.PRC_CALCULAR_REG(
                                  P_TABLA,
                                  P_TABLA_ERROR,
                                  P_TABLA_BAC,
                                  SAL_TOTAL_REGISTROS,
                                  SAL__TOTAL_CARGADOS,
                                  SAL_TOTAL_ERRADOS,
                                  SAL_TOTAL_BAC);
/*
      DBMS_OUTPUT.PUT_LINE('P_TABLA: '||P_TABLA);
      DBMS_OUTPUT.PUT_LINE('P_TABLA_ERROR: '||P_TABLA_ERROR);
      DBMS_OUTPUT.PUT_LINE('P_TABLA_BAC: '||P_TABLA_BAC); 
*/
      TOTAL_REGISTROS         := SAL_TOTAL_REGISTROS;
      TOTAL_CARGADOS          := SAL__TOTAL_CARGADOS;
      TOTAL_ERRADOS           := SAL_TOTAL_ERRADOS + SAL_TOTAL_BAC;
/*
      DBMS_OUTPUT.PUT_LINE('TOTAL_REGISTROS: '||TOTAL_REGISTROS);
      DBMS_OUTPUT.PUT_LINE('TOTAL_REGISTROS: '||TOTAL_CARGADOS);
      DBMS_OUTPUT.PUT_LINE('TOTAL_REGISTROS: '||TOTAL_ERRADOS);
*/      
      BEGIN
        UPDATE RESUMEN_CARGUE
        SET 
          TOTALREGISTROS      = TOTAL_REGISTROS,
          TOTALCARGADOS       = TOTAL_CARGADOS,
          TOTALERRADOS        = TOTAL_ERRADOS
        WHERE IDCARGUE        = P_ID_CARGUE;
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR AL ACTUALIZAR EL RESUMEN DE CARGUE');
      END;

    END PRC_ACTUALIZA_RESUMEN_CARGUE;
  
  /*PKG_CARGUE_ARCHIVOS.PRC_GENERICO_CARGUE(NOMBRE_ARCHIVO_ORIGEN, 
  TIPO_ARCHIVO, 
  PREFIJO_TABLA_TEMP_ERROR, 
  PREFIJO_TABLA_TEMP_BAD, 
  PREFIJO_TABLA_TEM_STAGE, 
  TABLA_DE_DESTINO, 
  CURSORES_CADENA, 
  COLUMNAS_TABLA_DESTINO, 
  SECUENCIA_TABLA_DESTINO, 
  CADENA_CONCATENA_ERROR, 
  SALIDA);*/
    PROCEDURE PRC_GENERICO_CARGUE(
                                  P_NOMBRE_ARCHIVO_ORIGEN     IN VARCHAR2,
                                  P_FECHA_ARCHIVO             IN VARCHAR2,
                                  P_TIPO_ARCHIVO              IN INTEGER,
                                  P_PREFIJO_TABLA_TEMP_ERROR  IN VARCHAR2,
                                  P_PREFIJO_TABLA_TEMP_BAD    IN VARCHAR2,
                                  P_PREFIJO_TABLA_TEM_STAGE   IN VARCHAR2,
                                  P_TABLA_DE_DESTINO          IN VARCHAR2,
                                  P_CURSORES_CADENA           IN VARCHAR2,
                                  P_COLUMNAS_TABLA_DESTINO    IN VARCHAR2,                                  
                                  P_SECUENCIA_TABLA_DESTINO   IN VARCHAR2,
                                  P_CONCATENA_CADENA_ERROR    IN VARCHAR2,
                                  P_SALIDA                    OUT NUMBER)
                                  
    /*****************************************************************************
    APLICACION:           SIBO DAVIPLATA
    NOMBRE:               PRC_CARGUE_ARCHIVOS
    PROPOSITO:            Procedimiento encargado de traer los datos del esquema
    stage al sistema DAVIPLATA.
    PARAMETROS:
    ENTRADA:              Nimguno
    SALIDA:               Ninguno
    DISEÑADO POR:         ASESOFTWARE
    DESARROLLADO POR:     ALFONSO PIMIENTA
    REVISIONES:
    Versión      Fecha         Autor                               Descripción
    ---------    ----------    --------------------------------    --------------
    1.0          2016-11-30    Alfonso Pimienta Trujillo           Creación Procedimiento.
    ******************************************************************************/
    IS
    
    ID_RESUMEN                              INTEGER;
    GLOB_CADENA_CURSOR_INSERT               CLOB;
    COLUMNAS_TABLA_DESTINO                  CLOB;
    CONCATENA_CADENA_ERROR                  CLOB;
    BEGIN 
      
      --PKG_UTILITARIOS.REPORTA_ERROR('1234','ENTRA AL CARGUE ARCHIVOS');
      
      GLOB_NOMBRE_TABLA_ERROR               := P_PREFIJO_TABLA_TEMP_ERROR;
      GLOB_NOMBRE_TABLA_BAD                 := P_PREFIJO_TABLA_TEMP_BAD;
      GLOB_NOMBRE_TABLA_STAGE               := P_PREFIJO_TABLA_TEM_STAGE;
      GLOB_NOMBRE_TABLA_DATOS               := P_TABLA_DE_DESTINO;
      COLUMNAS_TABLA_DESTINO                := P_COLUMNAS_TABLA_DESTINO;
      GLOB_CADENA_CURSOR_INSERT             := P_CURSORES_CADENA;
      GLOB_TIPO_ARCHIVO                     := P_TIPO_ARCHIVO;
      GLOBL_SEC_ID_DESTINO                  := P_SECUENCIA_TABLA_DESTINO;
      CONCATENA_CADENA_ERROR                := P_CONCATENA_CADENA_ERROR;

            
      BEGIN

      PRC_CREAR_PRC_CARGUE_DINAMICO(P_NOMBRE_ARCHIVO_ORIGEN, P_FECHA_ARCHIVO, GLOB_NOMBRE_TABLA_DATOS, COLUMNAS_TABLA_DESTINO, GLOB_CADENA_CURSOR_INSERT, CONCATENA_CADENA_ERROR);
      --PKG_UTILITARIOS.REPORTA_ERROR('2','TERMINÓ CREACIÓN CARGUE DINAMICO');
      PRC_CARGAR_DATOS_SIBO_DINAMIC(GLOB_NOMBRE_TABLA_STAGE,GLOB_NOMBRE_TABLA_DATOS,GLOB_CADENA_CURSOR_INSERT,GLOB_TIPO_ARCHIVO,GLOBL_SEC_ID_DESTINO,ID_RESUMEN);
      --PKG_UTILITARIOS.REPORTA_ERROR('3','TERMINÓ INSERT TABLA DESTINO');
      EXCEPTION WHEN OTHERS THEN       
      --PKG_UTILITARIOS.REPORTA_ERROR('ERROR',SQLERRM);
        NULL;
      END;
            

      BEGIN
      PRC_CREA_CARGAR_ERRORES_SIBO(CONCATENA_CADENA_ERROR);
      DBMS_OUTPUT.PUT_LINE('TERMINA CREACIÓN DE PRC DINAMICO INSERT TABLA ERROR');
      PRC_CARGAR_ERRORES_SIBO(ID_RESUMEN, GLOB_NOMBRE_TABLA_ERROR, GLOB_NOMBRE_TABLA_BAD);
      DBMS_OUTPUT.PUT_LINE('TERMINA CARGUE ERRORES SIBO');
      EXCEPTION WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('PARECE QUE FALLÓ EL CARUGE DE ERRORES');
      END;

      PRC_ACTUALIZA_RESUMEN_CARGUE(GLOB_NOMBRE_TABLA_STAGE, GLOB_NOMBRE_TABLA_ERROR, GLOB_NOMBRE_TABLA_BAD, ID_RESUMEN);
      DBMS_OUTPUT.PUT_LINE('TERMINA ACTUALIZACIÓN RESUMEN DE CARGO');
           
      P_SALIDA                              := C_BANDERA_ALTA;
    EXCEPTION
    WHEN OTHERS THEN
      P_SALIDA                              := C_BANDERA_BAJA;
      EXECUTE IMMEDIATE 'CREATE OR REPLACE PROCEDURE PRC_CARGAR_ERRORES_SIBO(P_ID_RESUMEN_CARGUE IN INTEGER, P_TABLA_ERROR IN OUT VARCHAR2, P_TABLA_BAD IN OUT VARCHAR2 ) AS BEGIN  NULL; END PRC_CARGAR_ERRORES_SIBO;';
      PKG_UTILITARIOS.REPORTA_ERROR('1234','ERROR'|| SQLCODE);
      
    END PRC_GENERICO_CARGUE;  
  
  END PKG_CARGUE_ARCHIVOS;
  /