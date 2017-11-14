create or replace PROCEDURE PRC_CARGAR_ERRORES_SIBO(															
                             P_ID_RESUMEN_CARGUE             IN INTEGER,  									
                             P_FECHA_PROVISTA                IN VARCHAR,--									
                             P_TABLA_ERROR                   IN OUT VARCHAR2,                                 
                             P_TABLA_BAD                     IN OUT VARCHAR2									
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
 ******************************************************************************/                              
 IS                                                                                                           
                                                                                                              
 CAMPOS_SELECT_DE_CARGUE                 VARCHAR2(1000);                                                      
 ID_RESUMEN_CARGUE                       INTEGER;                                                             
 P_NOMBRE_PARAMETRO_ERROR                VARCHAR2(100);                                                        
 P_NOMBRE_PARAMETRO_BAD                  VARCHAR2(100);                                                        
 PREFIJO_ERROR                           VARCHAR2(100);                                                       
 NOMBRE_BAD                              VARCHAR2(100);                                                       
 FECHA_PROVISTA                          VARCHAR2(20); --														
 																												
 L_ERROR_CARGUE                          ERROR_CARGUE_LINEA%ROWTYPE;                                          
 CUR_ERROR                               SYS_REFCURSOR;                                                       
 CUR_BAD                                 SYS_REFCURSOR;                                                       
                                                                                                              
 QUERY_ERROR                             VARCHAR2(1000) ;                                                     
 QUERY_BAD                               VARCHAR2(1000);                                                      
 NOMBRETABLA_ERR                         VARCHAR2(100);                                                       
 NOMBRETABLA_BAD                         VARCHAR2(100);                                                       
 SEC_ERROR_CARGUE                        VARCHAR2(200);                                                       
 DATOS_BAD                               INTEGER;                                                             
 DATOS_ERROR                             INTEGER;                                                             
   deadlock_detected EXCEPTION;                                                                               
PRAGMA EXCEPTION_INIT(deadlock_detected, -942);                                                               
                                                                                                              
BEGIN                                                                                                         
 BEGIN                                                                                                        
    PREFIJO_ERROR                  := P_TABLA_ERROR;                                                          
    NOMBRE_BAD                     := P_TABLA_BAD;  --                                                        
    FECHA_PROVISTA                 := P_FECHA_PROVISTA;--                                                     
																																	
       P_NOMBRE_PARAMETRO_ERROR   := PREFIJO_ERROR;                                                                               
       P_NOMBRE_PARAMETRO_BAD    := NOMBRE_BAD;--                                                                                 
                                                                                                                                  
   EXCEPTION                                                                                                                      
   WHEN OTHERS THEN                                                                                                               
   PKG_UTILITARIOS.REPORTA_ERROR('ERROR EN SELECT A PARAMAETROS: ', SQLERRM);                                                     
   END;                                                                                                                           
                                                                                                                                  
   NOMBRETABLA_ERR                       :=  P_NOMBRE_PARAMETRO_ERROR || TRIM(FECHA_PROVISTA);                                    
   NOMBRETABLA_BAD                       :=  P_NOMBRE_PARAMETRO_BAD;
   --DBMS_OUTPUT.PUT_LINE('NOMBRETABLA_ERR: '||NOMBRETABLA_ERR );

   P_TABLA_ERROR                         :=  NOMBRETABLA_ERR;
   P_TABLA_BAD                           :=  NOMBRETABLA_BAD;

   ID_RESUMEN_CARGUE                     :=  P_ID_RESUMEN_CARGUE;

   QUERY_ERROR                           := 'SELECT 1 ID, 1 AS RESUMEN_CARGUE ,NVL(CODMUNICIPIO,NULL) ||
''|'' || NVL(DEPARTAMENTO,NULL) || 
''|'' || NVL(MUNICIPIO,NULL) || 
''|'' || NVL(CODBENEFICIARIO,NULL) || 
''|'' || NVL(NOMBRE1,NULL) || 
''|'' || NVL(NOMBRE2,NULL) || 
''|'' || NVL(APE1_PROG,NULL) || 
''|'' || NVL(APE2_PROG,NULL) || 
''|'' || NVL(TIPO_ID,NULL) || 
''|'' || NVL(DOCUMENTO,NULL) || 
''|'' || NVL(TELEFONO,NULL) || 
''|'' || NVL(CELULAR,NULL) || 
''|'' || NVL(DIRECCION,NULL) || 
''|'' || NVL(CORREOELECTRONICO,NULL)  || 
''|'' || NVL(FECHANACIMIENTO,NULL)  || 
''|'' || NVL(FECHAEXPEDICION,NULL) || 
''|'' || NVL(SEXO,NULL) || 
''|'' || NVL(VALOR_TOTAL,0) LINEA, , NVL(ORA_ERR_MESG$ , ''SIN DESCRIPCION'') DESCRIPCIONERROR'||' FROM ' || NOMBRETABLA_ERR;
   PKG_UTILITARIOS.REPORTA_ERROR('SELECT: ', QUERY_ERROR);

   QUERY_BAD                             :=  'SELECT 1 AS IDCARGUE, 1 AS IDERRORLINEACARGUE, LINEA, NVL(DESCRIPCION , ''SIN DESCRIPCION'') FROM ' || NOMBRETABLA_BAD;
   --DBMS_OUTPUT.PUT_LINE(QUERY_BAD);
BEGIN
   EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || NOMBRETABLA_ERR INTO DATOS_ERROR;
EXCEPTION WHEN deadlock_detected THEN
DATOS_ERROR := 0;
END;
   IF DATOS_ERROR IS NOT NULL AND DATOS_ERROR <> 0  THEN

   OPEN CUR_ERROR FOR QUERY_ERROR;
   LOOP
    FETCH CUR_ERROR INTO L_ERROR_CARGUE;
     EXIT WHEN CUR_ERROR%NOTFOUND;
       BEGIN            

         INSERT INTO ERROR_CARGUE_LINEA(IDERRORLINEACARGUE, IDCARGUE,  LINEA, DESCRIPCIONERROR)
         VALUES( 
                 SEQ_ERROR_CARGUE_LINEA.NEXTVAL,
                 ID_RESUMEN_CARGUE,
                 L_ERROR_CARGUE.LINEA,
                 L_ERROR_CARGUE.DESCRIPCIONERROR);
           EXCEPTION WHEN OTHERS THEN
         PKG_UTILITARIOS.REPORTA_ERROR('ERROR EN ERROR:  ', ' DESCRIPCION: ' || SQLERRM);
       END;
   END LOOP;
   CLOSE CUR_ERROR;
   COMMIT;
  END IF;

BEGIN
 EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || NOMBRETABLA_BAD INTO DATOS_BAD;
EXCEPTION WHEN deadlock_detected THEN
DATOS_BAD := 0;
END;
   IF DATOS_BAD <> 0  THEN
       OPEN CUR_BAD FOR QUERY_BAD;
   LOOP
    FETCH CUR_BAD INTO L_ERROR_CARGUE;
     EXIT WHEN CUR_BAD%NOTFOUND;
       BEGIN            
             INSERT INTO ERROR_CARGUE_LINEA
             (IDERRORLINEACARGUE, IDCARGUE,  LINEA, DESCRIPCIONERROR)
             VALUES( 
                 SEQ_ERROR_CARGUE_LINEA.NEXTVAL,
                 ID_RESUMEN_CARGUE,
                 L_ERROR_CARGUE.LINEA,
                 L_ERROR_CARGUE.DESCRIPCIONERROR);

       EXCEPTION WHEN OTHERS THEN
         PKG_UTILITARIOS.REPORTA_ERROR('ERROR EN BAD: ', ' DESCRIPCION: ' || SQLERRM);
       END;
   END LOOP;
   CLOSE CUR_BAD;
   COMMIT;

  END IF;
   EXCEPTION WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('ERROR GENERAL: '|| TRIM(SQLCODE) ||  SQLERRM);
   END PRC_CARGAR_ERRORES_SIBO;
/