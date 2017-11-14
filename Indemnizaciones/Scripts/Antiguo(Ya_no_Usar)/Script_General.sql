-- Generado por Oracle SQL Developer Data Modeler 4.2.0.932
--   en:        2017-09-27 09:41:19 COT
--   sitio:      Oracle Database 11g
--   tipo:      Oracle Database 11g



CREATE TABLE alerta (
    cod_ale                NUMBER(15) NOT NULL,
    fec_ale                DATE DEFAULT SYSDATE NOT NULL,
    observacion            VARCHAR2(400 BYTE) NOT NULL,
    estado                 NUMBER(20) NOT NULL,
    transaccion_cod_tran   NUMBER(5) NOT NULL
)
    LOGGING;

COMMENT ON TABLE alerta IS
    'Tabla donde se registran las Alertas que se requieran hacer sobre una transaccion,generalmente anulaciones.';

COMMENT ON COLUMN alerta.cod_ale IS
    'codigo alerta - Codigo autoincremental de la tabla.';

COMMENT ON COLUMN alerta.fec_ale IS
    'fecha alerta - Campo donde se almacena la fecha del sistema en la que se esta realizando la alerta.';

COMMENT ON COLUMN alerta.observacion IS
    'Campo que indica la observacion de la alerta,la razon por la que se esta generando la alerta.';

COMMENT ON COLUMN alerta.estado IS
    'Tabla Dominio - Campo que por medio de un dominio indica el estado de registro.';

COMMENT ON COLUMN alerta.transaccion_cod_tran IS
    'Codigo autoincremental de la tabla';

CREATE UNIQUE INDEX alerta__idx ON
    alerta (
        cod_ale
    ASC,
        estado
    ASC )
        LOGGING;

ALTER TABLE alerta ADD CONSTRAINT alerta_pk PRIMARY KEY ( cod_ale );

CREATE TABLE aumento (
    fec_aumento               DATE NOT NULL,
    cano_arrenda_aume         NUMBER(20,2) NOT NULL,
    val_admin_aum             NUMBER(20,2) NOT NULL,
    periodo                   VARCHAR2(10 BYTE) NOT NULL,
    estado                    NUMBER(20) NOT NULL,
    solicitud_sai_solicitud   NUMBER(10) NOT NULL
)
    LOGGING;

COMMENT ON TABLE aumento IS
    'Tabla donde se registran los aumentos que se le van a realizar a una solicitud.';

COMMENT ON COLUMN aumento.fec_aumento IS
    'fecha aumento - Fecha en la cual se esta realizando el aumento.';

COMMENT ON COLUMN aumento.cano_arrenda_aume IS
    'canon arrendamiento aumento - Valor del canon de arrendamiento que esta siendo aumentado';

COMMENT ON COLUMN aumento.val_admin_aum IS
    'valor administracion aumento - Valor de administracion que esta siendo aumentado';

COMMENT ON COLUMN aumento.periodo IS
    'Indica el periodo calculado en SAI en el cual se hace el aumento.';

COMMENT ON COLUMN aumento.estado IS
    'Tabla Dominio - Campo que por medio de un dominio indica el estado de la solicitud.';

CREATE UNIQUE INDEX aumento__idx ON
    aumento (
        fec_aumento
    ASC,
        solicitud_sai_solicitud
    ASC )
        LOGGING;

ALTER TABLE aumento ADD CONSTRAINT aumento_pk PRIMARY KEY ( fec_aumento,solicitud_sai_solicitud );

CREATE TABLE aumento_pendiente (
    tipo_obs_aum          NUMBER(20) NOT NULL,
    fec_pend              DATE DEFAULT SYSDATE NOT NULL,
    estado                NUMBER(20) NOT NULL,
    aumento_fec_aumento   DATE DEFAULT SYSDATE NOT NULL,
    aumento_solicitud     NUMBER(10) NOT NULL
)
    LOGGING;

COMMENT ON TABLE aumento_pendiente IS
    'Aumento Pendiente - Tabla donde se registran los aumentos pendientes,los que no cumplieron con las reglas de negocio definidas.'
;

COMMENT ON COLUMN aumento_pendiente.tipo_obs_aum IS
    'Tabla Dominio - tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo en los pendietes'
;

COMMENT ON COLUMN aumento_pendiente.fec_pend IS
    'fecha pendiente- Fecha por la cual el aumento quedo en aumentos pendietes.';

COMMENT ON COLUMN aumento_pendiente.estado IS
    'Tabla Dominio - Campo que por medio de un dominio indica el estado de registro.';

COMMENT ON COLUMN aumento_pendiente.aumento_fec_aumento IS
    'fecha aumento - Fecha en la cual se esta realizando el aumento.';

CREATE UNIQUE INDEX aumento_pendiente__idx ON
    aumento_pendiente (
        tipo_obs_aum
    ASC,
        estado
    ASC )
        LOGGING;

CREATE UNIQUE INDEX aumento_pendiente__idxv1 ON
    aumento_pendiente (
        aumento_fec_aumento
    ASC,
        aumento_solicitud
    ASC )
        LOGGING;

ALTER TABLE aumento_pendiente ADD CONSTRAINT aumento_pendiente_pk PRIMARY KEY ( aumento_fec_aumento,aumento_solicitud,tipo_obs_aum );

CREATE TABLE autorizacion_desocupacioon (
    codigo_aut_des              NUMBER(15) NOT NULL,
    area_auto                   VARCHAR2(10 BYTE) NOT NULL,
    fec_auto                    DATE DEFAULT SYSDATE NOT NULL,
    responsable                 NUMBER(10) NOT NULL,
    estado                      NUMBER(20) NOT NULL,
    observacion                 VARCHAR2(400 BYTE),
    tipo_mot                    NUMBER(20),
    deso_pend_tipo_obs          NUMBER(20) NOT NULL,
    deso_pend_desoc_fec_regi    DATE NOT NULL,
    deso_pend_desoc_solicitud   NUMBER(10) NOT NULL
)
    LOGGING;

COMMENT ON TABLE autorizacion_desocupacioon IS
    'Autorizacion Desocupacion - Tabla donde se registran las autorizaciones de desocupaciones realizadas,aprobar o rechazar segun sea el caso.'
;

COMMENT ON COLUMN autorizacion_desocupacioon.codigo_aut_des IS
    'Codigo autoincremental de la tabla.';

COMMENT ON COLUMN autorizacion_desocupacioon.area_auto IS
    'Area Autorizacion - Dominio que establece qe area va a realizar la autorización.';

COMMENT ON COLUMN autorizacion_desocupacioon.fec_auto IS
    'fecha autorizacion - Campo donde se almacena la fecha y la hora en el que se proceso la autorizacion.';

COMMENT ON COLUMN autorizacion_desocupacioon.responsable IS
    'Campo donde se almacena el codigo del reponsable de la autorizacion/rechazo del pendiente.';

COMMENT ON COLUMN autorizacion_desocupacioon.estado IS
    'Campo que indica el estado de la autorizacion,si fue aprobada o rechazada.';

COMMENT ON COLUMN autorizacion_desocupacioon.observacion IS
    'Campo donde se registra la observacion realizada en la aprobacion o en el rechazo.';

COMMENT ON COLUMN autorizacion_desocupacioon.tipo_mot IS
    'tipo motivo - Dominio que indica el motivo por el cual esta siendo rechazada la novedad pendiente.';

COMMENT ON COLUMN autorizacion_desocupacioon.deso_pend_tipo_obs IS
    'tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo como pendiente';

COMMENT ON COLUMN autorizacion_desocupacioon.deso_pend_desoc_fec_regi IS
    'fecha registro - Fecha del sistema de cuando se esta realizando la desocupacion.';

CREATE UNIQUE INDEX auto_desocupacioon__idx ON
    autorizacion_desocupacioon (
        deso_pend_tipo_obs
    ASC,
        deso_pend_desoc_fec_regi
    ASC,
        deso_pend_desoc_solicitud
    ASC )
        LOGGING;

ALTER TABLE autorizacion_desocupacioon ADD CONSTRAINT autorizacion_desocupacioon_pk PRIMARY KEY ( codigo_aut_des );

CREATE TABLE autorizacion_indemnizacion (
    cod_aut_ind                 NUMBER(15) NOT NULL,
    area_auto                   VARCHAR2(10 BYTE) NOT NULL,
    fec_autor                   DATE DEFAULT SYSDATE NOT NULL,
    responsable                 NUMBER(10) NOT NULL,
    estado                      NUMBER(20) NOT NULL,
    tipo_mot                    NUMBER(20),
    observacion                 VARCHAR2(400 BYTE),
    dan_falt_pend_tipo_obs      NUMBER(20),
    dan_falt_pend_fec_rep       DATE,
    dan_falt_pend_solicitud     NUMBER(10),
    sini_pend_tip_obs           NUMBER(20),
    sini_pend_sinie_fec_rep     DATE,
    sini_pend_sinie_solicitud   NUMBER(10)
)
    LOGGING;

ALTER TABLE autorizacion_indemnizacion ADD CONSTRAINT arc_2 CHECK (
    (
        (
            sini_pend_sinie_fec_rep IS NOT NULL
        ) AND (
            sini_pend_sinie_solicitud IS NOT NULL
        ) AND (
            sini_pend_tip_obs IS NOT NULL
        ) AND (
            dan_falt_pend_fec_rep IS NULL
        ) AND (
            dan_falt_pend_solicitud IS NULL
        ) AND (
            dan_falt_pend_tipo_obs IS NULL
        )
    ) OR (
        (
            dan_falt_pend_fec_rep IS NOT NULL
        ) AND (
            dan_falt_pend_solicitud IS NOT NULL
        ) AND (
            dan_falt_pend_tipo_obs IS NOT NULL
        ) AND (
            sini_pend_sinie_fec_rep IS NULL
        ) AND (
            sini_pend_sinie_solicitud IS NULL
        ) AND (
            sini_pend_tip_obs IS NULL
        )
    )
);

COMMENT ON TABLE autorizacion_indemnizacion IS
    'Autorizacion Idenmnizacion - Tabla donde se registraran las autorizaciones realizadas para el reporte de siniestros,ya sea aprobar o rechazar la solicitud segun sea el caso.'
;

COMMENT ON COLUMN autorizacion_indemnizacion.cod_aut_ind IS
    'codigo autorizacion indenmnizacion - Codigo autoincremental de la tabla.';

COMMENT ON COLUMN autorizacion_indemnizacion.area_auto IS
    'area autorizar - Dominio que establece quien va a realizar la autorización';

COMMENT ON COLUMN autorizacion_indemnizacion.fec_autor IS
    'feccha auto - Campo donde se almacena la fecha y la hora en el que se proceso la autorizacion.';

COMMENT ON COLUMN autorizacion_indemnizacion.responsable IS
    'Campo donde se almacena el codigo del reponsable de la autorizacion/rechazo del pendiente.';

COMMENT ON COLUMN autorizacion_indemnizacion.estado IS
    'Campo que indica el estado de la autorizacion,si fue aprobada o rechazada.';

COMMENT ON COLUMN autorizacion_indemnizacion.tipo_mot IS
    'tipo motivo - Dominio que indica el motivo por el cual esta siendo rechazada la novedad pendiente.';

COMMENT ON COLUMN autorizacion_indemnizacion.observacion IS
    'Campo donde se almacena la observacion del rechazo o aprobacion del pendinte.';

COMMENT ON COLUMN autorizacion_indemnizacion.dan_falt_pend_tipo_obs IS
    'tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo como pendiente';

COMMENT ON COLUMN autorizacion_indemnizacion.dan_falt_pend_fec_rep IS
    'fecha reporte - campo donde se registra la fecha del sistema en la cual se esta haciendo el reporte de danios y faltantes.';

COMMENT ON COLUMN autorizacion_indemnizacion.sini_pend_tip_obs IS
    'tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo como pendiente';

COMMENT ON COLUMN autorizacion_indemnizacion.sini_pend_sinie_fec_rep IS
    'fecha reporte - Fecha del sistema (sysdate) de cuando se hizo el reporte de sineistro';

CREATE UNIQUE INDEX auto_indemnizacion__idx ON
    autorizacion_indemnizacion (
        dan_falt_pend_fec_rep
    ASC,
        dan_falt_pend_solicitud
    ASC,
        dan_falt_pend_tipo_obs
    ASC )
        LOGGING;

CREATE UNIQUE INDEX auto_indemnizacion__idxv1 ON
    autorizacion_indemnizacion (
        sini_pend_sinie_fec_rep
    ASC,
        sini_pend_sinie_solicitud
    ASC,
        sini_pend_tip_obs
    ASC )
        LOGGING;

ALTER TABLE autorizacion_indemnizacion ADD CONSTRAINT autorizacion_indemnizacion_pk PRIMARY KEY ( cod_aut_ind );

CREATE TABLE autorizacion_operacion (
    cod_auto_oper                    NUMBER(15) NOT NULL,
    observacion                      VARCHAR2(200 BYTE) NOT NULL,
    area_auto                        VARCHAR2(10 BYTE) NOT NULL,
    fec_auto                         DATE DEFAULT SYSDATE NOT NULL,
    responsable                      NUMBER(10) NOT NULL,
    estado                           NUMBER(20) NOT NULL,
    tipo_mot                         NUMBER(20),
    ing_pend_ingr_fec_registro_ing   DATE,
    ing_pend_ingr_solicitud          NUMBER(10),
    ing_pend_tipo_obs_ing            NUMBER(20),
    aum_pend_aume_solicitud          NUMBER(10),
    aum_pend_aum_fec_aumento         DATE DEFAULT SYSDATE,
    aum_pend_tipo_obs_aum            NUMBER(20)
)
    LOGGING;

ALTER TABLE autorizacion_operacion ADD CONSTRAINT arc_1 CHECK (
    (
        (
            ing_pend_ingr_fec_registro_ing IS NOT NULL
        ) AND (
            ing_pend_ingr_solicitud IS NOT NULL
        ) AND (
            ing_pend_tipo_obs_ing IS NOT NULL
        ) AND (
            aum_pend_aum_fec_aumento IS NULL
        ) AND (
            aum_pend_aume_solicitud IS NULL
        ) AND (
            aum_pend_tipo_obs_aum IS NULL
        )
    ) OR (
        (
            aum_pend_aum_fec_aumento IS NOT NULL
        ) AND (
            aum_pend_aume_solicitud IS NOT NULL
        ) AND (
            aum_pend_tipo_obs_aum IS NOT NULL
        ) AND (
            ing_pend_ingr_fec_registro_ing IS NULL
        ) AND (
            ing_pend_ingr_solicitud IS NULL
        ) AND (
            ing_pend_tipo_obs_ing IS NULL
        )
    )
);

COMMENT ON TABLE autorizacion_operacion IS
    'Autorizacion Desocupacion - Tabla donde se registran las autorizaciones de las operaciones de Ingresos y Aumentos,segun sea el caso,ya sea rechazar o aprobar la solicitud.'
;

COMMENT ON COLUMN autorizacion_operacion.cod_auto_oper IS
    'codigo autorizacion operacion - Codigo autoincremental de la tabla';

COMMENT ON COLUMN autorizacion_operacion.area_auto IS
    'area autorizar - Dominio que establece quien va a realizar la autorización';

COMMENT ON COLUMN autorizacion_operacion.fec_auto IS
    'fecha autorizacion - Campo donde se almacena la fecha y la hora en el que se proceso la autorizacion.';

COMMENT ON COLUMN autorizacion_operacion.responsable IS
    'Campo donde se almacena el codigo del reponsable de la autorizacion/rechazo del pendiente.';

COMMENT ON COLUMN autorizacion_operacion.estado IS
    'Tabla Dominio - Campo que indica el estado de la autorizacion,si fue aprobada o rechazada.';

COMMENT ON COLUMN autorizacion_operacion.tipo_mot IS
    'Tabla Dominio - tipo motivo - Dominio que indica el motivo por el cual esta siendo rechazada la novedad pendiente.';

COMMENT ON COLUMN autorizacion_operacion.ing_pend_ingr_fec_registro_ing IS
    'Fecha del sistema donde de cuado se esta realizando el registro.';

COMMENT ON COLUMN autorizacion_operacion.ing_pend_tipo_obs_ing IS
    'tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo en los pendietes';

COMMENT ON COLUMN autorizacion_operacion.aum_pend_aum_fec_aumento IS
    'fecha aumento - Fecha en la cual se esta realizando el aumento.';

COMMENT ON COLUMN autorizacion_operacion.aum_pend_tipo_obs_aum IS
    'Tabla Dominio - tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo en los pendietes'
;

CREATE UNIQUE INDEX autorizacion_operacion__idx ON
    autorizacion_operacion (
        aum_pend_aum_fec_aumento
    ASC,
        aum_pend_aume_solicitud
    ASC,
        aum_pend_tipo_obs_aum
    ASC )
        LOGGING;

CREATE UNIQUE INDEX autorizacion_operacion__idxv1 ON
    autorizacion_operacion (
        ing_pend_ingr_fec_registro_ing
    ASC,
        ing_pend_ingr_solicitud
    ASC,
        ing_pend_tipo_obs_ing
    ASC )
        LOGGING;

ALTER TABLE autorizacion_operacion ADD CONSTRAINT autorizacion_operacion_pk PRIMARY KEY ( cod_auto_oper );

CREATE TABLE danio_faltante_pendiente (
    tipo_obs                 NUMBER(20) NOT NULL,
    fec_pend                 DATE DEFAULT SYSDATE NOT NULL,
    estado                   NUMBER(20) NOT NULL,
    reg_dan_falt_fec_rep     DATE DEFAULT SYSDATE NOT NULL,
    reg_dan_falt_solicitud   NUMBER(10) NOT NULL
)
    LOGGING;

COMMENT ON TABLE danio_faltante_pendiente IS
    'Danios Faltantes Pendientes - Tabla donde se registran las solicitudes de reporte de daños y faltantes que quedan pendientes,que no cumplieron las reglas de negocio definidas'
;

COMMENT ON COLUMN danio_faltante_pendiente.tipo_obs IS
    'tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo como pendiente';

COMMENT ON COLUMN danio_faltante_pendiente.fec_pend IS
    'fecha pendiente - Campor donde se almacena la fecha del sistema donde la solicitud quedo como pendiente.';

COMMENT ON COLUMN danio_faltante_pendiente.estado IS
    'Campo que por medio de un dominio indica el estado de registro.';

COMMENT ON COLUMN danio_faltante_pendiente.reg_dan_falt_fec_rep IS
    'fecha reporte - campo donde se registra la fecha del sistema en la cual se esta haciendo el reporte de danios y faltantes.';

CREATE UNIQUE INDEX dan_falt_pend__idx ON
    danio_faltante_pendiente (
        tipo_obs
    ASC,
        estado
    ASC )
        LOGGING;

CREATE UNIQUE INDEX dan_falt_pend__idxv1 ON
    danio_faltante_pendiente (
        reg_dan_falt_fec_rep
    ASC,
        reg_dan_falt_solicitud
    ASC )
        LOGGING;

ALTER TABLE danio_faltante_pendiente ADD CONSTRAINT danio_faltante_pendiente_pk PRIMARY KEY ( reg_dan_falt_fec_rep,reg_dan_falt_solicitud,
 tipo_obs );

CREATE TABLE desistimiento (
    fec_reg                   DATE NOT NULL,
    cod_sini                  NUMBER(10) NOT NULL,
    fec_desi                  DATE NOT NULL,
    periodo                   VARCHAR2(10 BYTE) NOT NULL,
    tipo_poli                 VARCHAR2(200 BYTE) NOT NULL,
    est_sini                  NUMBER(20) NOT NULL,
    est_pago                  NUMBER(20) NOT NULL,
    solicitud_sai_solicitud   NUMBER(10) NOT NULL
)
    LOGGING;

ALTER TABLE desistimiento ADD CHECK (
    tipo_poli IN (
        '1','2'
    )
);

COMMENT ON TABLE desistimiento IS
    'Tabla donde se registran los desistimientos que se realizen sobre una solicitud que se encuetre siniestrada.';

COMMENT ON COLUMN desistimiento.fec_reg IS
    'fecha registro - fecha del sistema en el que se esta haciendo el desistimiento.';

COMMENT ON COLUMN desistimiento.cod_sini IS
    'codigo siniestro - Codigo del siniestro generado en SAI.';

COMMENT ON COLUMN desistimiento.fec_desi IS
    'fecha desistimiento - Campor donde se registra la fecha del desistimiento.';

COMMENT ON COLUMN desistimiento.periodo IS
    'Indica el periodo efectivo calculado en SAI.';

COMMENT ON COLUMN desistimiento.tipo_poli IS
    'tipo poliza - Dominio que identifica el tipo de poliza que esta registrand,colectiva/individual';

COMMENT ON COLUMN desistimiento.est_sini IS
    'Tabla Dominio - estado siniestro - Campo que indica el estado del siniestro.';

COMMENT ON COLUMN desistimiento.est_pago IS
    'Tabla Dominio - estado pago - Campo que indica el estado del pago del siniestro.';

CREATE UNIQUE INDEX desistimiento__idx ON
    desistimiento (
        fec_reg
    ASC,
        solicitud_sai_solicitud
    ASC )
        LOGGING;

ALTER TABLE desistimiento ADD CONSTRAINT desistimiento_pk PRIMARY KEY ( fec_reg,solicitud_sai_solicitud );

CREATE TABLE desocupacion (
    fec_regi                  DATE NOT NULL,
    fec_deso                  DATE NOT NULL,
    tip_pol                   VARCHAR2(200 BYTE) NOT NULL,
    periodo                   VARCHAR2(10 BYTE) NOT NULL,
    est_sini                  NUMBER(20) NOT NULL,
    est_pag                   NUMBER(20) NOT NULL,
    solicitud_sai_solicitud   NUMBER(10) NOT NULL,
    fec_mor                   DATE NOT NULL,
    num_sini                  NUMBER(20) NOT NULL
)
    LOGGING;

ALTER TABLE desocupacion ADD CHECK (
    tip_pol IN (
        '1','2'
    )
);

COMMENT ON TABLE desocupacion IS
    'Tabla donde se registran las desocupaciones que se van a realizar de manera colectiva e individual segun sea el caso.';

COMMENT ON COLUMN desocupacion.fec_regi IS
    'fecha registro - Fecha del sistema de cuando se esta realizando la desocupacion.';

COMMENT ON COLUMN desocupacion.fec_deso IS
    'fecha desocupacion - Fecha en la cual se va a realizar la desocupacion.';

COMMENT ON COLUMN desocupacion.tip_pol IS
    'tipo poliza - Dominio que identifica el tipo de poliza que esta registrand,colectiva/individual';

COMMENT ON COLUMN desocupacion.periodo IS
    'Indica el periodo efectivo calculado en SAI.';

COMMENT ON COLUMN desocupacion.est_sini IS
    'Tabla Dominio - estado siniestro - Campo que indica el estado del siniestro.';

COMMENT ON COLUMN desocupacion.est_pag IS
    'Tabla Dominio - estado pago - Campo que indica el estado del pago del siniestro.';

COMMENT ON COLUMN desocupacion.fec_mor IS
    'Fecha de mora del siniestro';

COMMENT ON COLUMN desocupacion.num_sini IS
    'Numero del siniestro.';

CREATE UNIQUE INDEX desocupacion__idx ON
    desocupacion (
        fec_regi
    ASC,
        solicitud_sai_solicitud
    ASC )
        LOGGING;

ALTER TABLE desocupacion ADD CONSTRAINT desocupacion_pk PRIMARY KEY ( fec_regi,solicitud_sai_solicitud );

CREATE TABLE desocupacion_pendiente (
    tipo_obs                 NUMBER(20) NOT NULL,
    fec_pen                  DATE DEFAULT SYSDATE NOT NULL,
    estado                   NUMBER(20) NOT NULL,
    desocupacion_fec_regi    DATE DEFAULT SYSDATE NOT NULL,
    desocupacion_solicitud   NUMBER(10) NOT NULL
)
    LOGGING;

COMMENT ON TABLE desocupacion_pendiente IS
    'Desocupacion Pendiente - Tabla donde se registran las desocupaciones que no cumplieron con las reglas de negocio definidas y quedan pendietes a una auotorizacion.'
;

COMMENT ON COLUMN desocupacion_pendiente.tipo_obs IS
    'tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo como pendiente';

COMMENT ON COLUMN desocupacion_pendiente.fec_pen IS
    'fecha pendiente - Fecha del sistema en la que el registro quedo en pendiente.';

COMMENT ON COLUMN desocupacion_pendiente.estado IS
    'Dominio - Campo que por medio de un dominio indica el estado de registro.';

COMMENT ON COLUMN desocupacion_pendiente.desocupacion_fec_regi IS
    'fecha registro - Fecha del sistema de cuando se esta realizando la desocupacion.';

CREATE UNIQUE INDEX desocupacion_pendiente__idx ON
    desocupacion_pendiente (
        tipo_obs
    ASC,
        estado
    ASC )
        LOGGING;

CREATE UNIQUE INDEX desocupacion_pendiente__idxv1 ON
    desocupacion_pendiente (
        desocupacion_fec_regi
    ASC,
        desocupacion_solicitud
    ASC )
        LOGGING;

ALTER TABLE desocupacion_pendiente ADD CONSTRAINT desocupacion_pendiente_pk PRIMARY KEY ( tipo_obs,desocupacion_fec_regi,desocupacion_solicitud
 );

CREATE TABLE documento_notificacion (
    cod_doc_notificacion     NUMBER(15) NOT NULL,
    cod_doc                  NUMBER(5) NOT NULL,
    cod_repo                 NUMBER(10) NOT NULL,
    ruta_repo                VARCHAR2(400 BYTE) NOT NULL,
    estado                   NUMBER(20) NOT NULL,
    notificacion_solicitud   NUMBER(10) NOT NULL,
    notificacion_fec_noti    DATE NOT NULL
)
    LOGGING;

COMMENT ON TABLE documento_notificacion IS
    'Documento Notificacion - Tabla donde se registran los documentos que han sido solicitados en la notificacion para las inmobiliarias.'
;

COMMENT ON COLUMN documento_notificacion.cod_doc_notificacion IS
    'Codigo autoincremental de la tabla.';

COMMENT ON COLUMN documento_notificacion.cod_doc IS
    'codigo documento - Codigo SAI del documento que se esta solicitando.';

COMMENT ON COLUMN documento_notificacion.cod_repo IS
    'codigo repositorio - Campo donde se almancena el codigo que se genera en el repositorio.';

COMMENT ON COLUMN documento_notificacion.ruta_repo IS
    'ruta repositorio - Campo donde se almacena la ruta fisica de los archivos cargados en el repositorio.';

COMMENT ON COLUMN documento_notificacion.estado IS
    'Tabla Dominio - Indicaria si ya fue cargado el archivo solicitado';

COMMENT ON COLUMN documento_notificacion.notificacion_solicitud IS
    'Numero de solicitud que a la que se le esta haciendo la novedad.';

COMMENT ON COLUMN documento_notificacion.notificacion_fec_noti IS
    'fecha notificacion - Fecha del sistema de cuando se esta generando la notificacion.';

CREATE UNIQUE INDEX documento_notificacion__idx ON
    documento_notificacion (
        cod_doc_notificacion
    ASC,
        estado
    ASC )
        LOGGING;

ALTER TABLE documento_notificacion ADD CONSTRAINT documento_notificacion_pk PRIMARY KEY ( cod_doc_notificacion );

CREATE TABLE documento_soporte (
    cod_doc_sop              NUMBER(15) NOT NULL,
    nombre                   VARCHAR2(200 BYTE) NOT NULL,
    cod_repo                 NUMBER(10) NOT NULL,
    ruta_repo                VARCHAR2(400 BYTE) NOT NULL,
    reg_dan_falt_fec_rep     DATE NOT NULL,
    reg_dan_falt_solicitud   NUMBER(10) NOT NULL
)
    LOGGING;

COMMENT ON TABLE documento_soporte IS
    'DOCUMENTO SOPORTE - Tabla donde se almacenan los documentos soportes que se adjuntan en el reporte de daño y faltantes.';

COMMENT ON COLUMN documento_soporte.cod_doc_sop IS
    'codigo documento soporte - Codigo autoincremental de la tabla.';

COMMENT ON COLUMN documento_soporte.nombre IS
    'Campo donde se almacena el nombre del documento.';

COMMENT ON COLUMN documento_soporte.cod_repo IS
    'codigo repositorio - Campo donde se almancena el codigo que se genera en el repositorio.';

COMMENT ON COLUMN documento_soporte.ruta_repo IS
    'ruta repositorio - Campo donde se almacena la ruta fisica de los archivos cargados en el repositorio.';

COMMENT ON COLUMN documento_soporte.reg_dan_falt_fec_rep IS
    'fecha reporte - campo donde se registra la fecha del sistema en la cual se esta haciendo el reporte de danios y faltantes.';

CREATE UNIQUE INDEX documento_soporte__idx ON
    documento_soporte ( cod_doc_sop ASC )
        LOGGING;

ALTER TABLE documento_soporte ADD CONSTRAINT documento_soporte_pk PRIMARY KEY ( cod_doc_sop );

CREATE TABLE dominio (
    cod_dominio   NUMBER(15) NOT NULL,
    nombre        VARCHAR2(200 BYTE) NOT NULL,
    estado        VARCHAR2(20 BYTE) NOT NULL
)
    LOGGING;

ALTER TABLE dominio ADD CHECK (
    estado IN (
        '1','2'
    )
);

COMMENT ON TABLE dominio IS
    'Tabla donde se crearan los dominios que se haran uso en el sistema.';

COMMENT ON COLUMN dominio.cod_dominio IS
    'Codigo autoincremental de la tabla';

COMMENT ON COLUMN dominio.nombre IS
    'Campo que indica el nombre que va a tener el dominio.';

COMMENT ON COLUMN dominio.estado IS
    'Dominio que indica el estado del dominio,si este esta activo o esta inactivo.';

CREATE UNIQUE INDEX dominio__idx ON
    dominio (
        cod_dominio
    ASC,
        estado
    ASC )
        LOGGING;

ALTER TABLE dominio ADD CONSTRAINT dominio_pk PRIMARY KEY ( cod_dominio );

CREATE TABLE ingreso (
    fec_registro_ing          DATE NOT NULL,
    fec_ingreso               DATE NOT NULL,
    can_arrendamiento         NUMBER(20,2) NOT NULL,
    val_administracion        NUMBER(20,2) NOT NULL,
    periodo                   VARCHAR2(10 BYTE) NOT NULL,
    estado                    NUMBER NOT NULL,
    tipo_iva                  NUMBER(20),
    val_amp_integral          NUMBER(20),
    metraje_amp_hogar         NUMBER(20,2),
    val_amp_hogar             NUMBER(20,2),
    solicitud_sai_solicitud   NUMBER(10) NOT NULL
)
    LOGGING;

COMMENT ON TABLE ingreso IS
    'Tabla donde se registran los ingresos de las solicitudes.';

COMMENT ON COLUMN ingreso.fec_registro_ing IS
    'Fecha del sistema donde de cuado se esta realizando el registro.';

COMMENT ON COLUMN ingreso.fec_ingreso IS
    'fecha ingreso  - Fecha en la que se realizó el ingreso.';

COMMENT ON COLUMN ingreso.can_arrendamiento IS
    'canon arrendamiento - Valor del canon de arrendamiento asegurado.';

COMMENT ON COLUMN ingreso.val_administracion IS
    'valor administracion - Valor del cuota de administración asegurado.';

COMMENT ON COLUMN ingreso.periodo IS
    'Indica el periodo efectivo calculado en SAI.';

COMMENT ON COLUMN ingreso.estado IS
    'Tabla Dominio - Campo que por medio de un dominio indica el estado de la solicitud.';

COMMENT ON COLUMN ingreso.tipo_iva IS
    'Tabla Dominio - Dominio que indica el tipo de iva que va a tener como ingreso,si aplica o no.';

COMMENT ON COLUMN ingreso.val_amp_integral IS
    'Tabla Dominio - valor amparo integral - Valor del amapro integral,el cual se va a asegurar';

COMMENT ON COLUMN ingreso.metraje_amp_hogar IS
    'Valor del mentraje del inmueble que se va a asegurar por amparo hogar.';

COMMENT ON COLUMN ingreso.val_amp_hogar IS
    'Valor que se va a asegurar como amaparo hogar.';

CREATE UNIQUE INDEX ingreso__idx ON
    ingreso (
        fec_registro_ing
    ASC,
        solicitud_sai_solicitud
    ASC )
        LOGGING;

ALTER TABLE ingreso ADD CONSTRAINT ingreso_pk PRIMARY KEY ( fec_registro_ing,solicitud_sai_solicitud );

CREATE TABLE ingreso_pendiente (
    tipo_obs_ing               NUMBER(20) NOT NULL,
    fec_pend                   DATE DEFAULT SYSDATE NOT NULL,
    estado                     NUMBER(20) NOT NULL,
    ingreso_fec_registro_ing   DATE DEFAULT SYSDATE NOT NULL,
    ingreso_solicitud          NUMBER(10) NOT NULL
)
    LOGGING;

COMMENT ON TABLE ingreso_pendiente IS
    'Tabla donde se registran los ingresos pendientes,los que no cumplieron con las reglas de negocio definidas.';

COMMENT ON COLUMN ingreso_pendiente.tipo_obs_ing IS
    'tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo en los pendietes';

COMMENT ON COLUMN ingreso_pendiente.fec_pend IS
    'fecha pendiente - Fecha en la cual el ingreso quedo pendiente.';

COMMENT ON COLUMN ingreso_pendiente.estado IS
    'Tabla Dominio - Campo que por medio de un dominio indica el estado de registro.';

COMMENT ON COLUMN ingreso_pendiente.ingreso_fec_registro_ing IS
    'Fecha del sistema donde de cuado se esta realizando el registro.';

CREATE UNIQUE INDEX ingreso_pendiente__idx ON
    ingreso_pendiente (
        tipo_obs_ing
    ASC,
        estado
    ASC )
        LOGGING;

CREATE UNIQUE INDEX ingreso_pendiente__idxv1 ON
    ingreso_pendiente (
        ingreso_fec_registro_ing
    ASC,
        ingreso_solicitud
    ASC )
        LOGGING;

ALTER TABLE ingreso_pendiente ADD CONSTRAINT ingreso_pendiente_pk PRIMARY KEY ( ingreso_fec_registro_ing,ingreso_solicitud,tipo_obs_ing );

CREATE TABLE lista_documento (
    cod_list_doc             NUMBER(15) NOT NULL,
    cod_doc                  NUMBER(5) NOT NULL,
    nombre                   VARCHAR2(200 BYTE) NOT NULL,
    aplica                   CHAR(1) NOT NULL,
    cod_repo                 NUMBER(10),
    ruta_repo                VARCHAR2(400 BYTE),
    siniestro_fec_rep        DATE NOT NULL,
    sini_sol_sai_solicitud   NUMBER(10) NOT NULL
)
    LOGGING;

COMMENT ON TABLE lista_documento IS
    'Lista Documento - Tabla donde se almacena la lista de documentos que se ingresa en el reporte de siniestros.';

COMMENT ON COLUMN lista_documento.cod_list_doc IS
    'codigo lista documento - Codigo autoincremental de la tabla.';

COMMENT ON COLUMN lista_documento.cod_doc IS
    'codigo documento - En este atribuo se almacena el codigo que tiene el documeno en SAI.';

COMMENT ON COLUMN lista_documento.nombre IS
    'Nombre que tiene el documento en SAI.';

COMMENT ON COLUMN lista_documento.aplica IS
    'Campo que indica si el documento aplica o no para el reporte de siniestro.';

COMMENT ON COLUMN lista_documento.cod_repo IS
    'codigo repositorio - Campo donde se almancena el codigo que se genera en el repositorio.';

COMMENT ON COLUMN lista_documento.ruta_repo IS
    'ruta repositorio - Campo donde se almacena la ruta fisica de los archivos cargados en el repositorio.';

COMMENT ON COLUMN lista_documento.siniestro_fec_rep IS
    'fecha reporte - Fecha del sistema (sysdate) de cuando se hizo el reporte de sineistro';

CREATE INDEX lista_documento__idx ON
    lista_documento ( cod_list_doc ASC )
        LOGGING;

ALTER TABLE lista_documento ADD CONSTRAINT lista_documento_pk PRIMARY KEY ( cod_list_doc );

CREATE TABLE log_servicio_simi (
    cod_log_serv     NUMBER(5) NOT NULL,
    fecha_registro   DATE DEFAULT SYSDATE NOT NULL,
    request          VARCHAR2(400 BYTE) NOT NULL,
    response         VARCHAR2(400 BYTE) NOT NULL,
    estado           NUMBER(20) NOT NULL
)
    LOGGING;

COMMENT ON TABLE log_servicio_simi IS
    'Tabla donde se almacena la informacion que procesa el servicio web de SIMI.';

COMMENT ON COLUMN log_servicio_simi.cod_log_serv IS
    'codigo log servicio SIMI - Codigo autoincremental de la tabla.';

COMMENT ON COLUMN log_servicio_simi.fecha_registro IS
    'Fecha del sistema de cuando se hizo el registro';

COMMENT ON COLUMN log_servicio_simi.request IS
    'Campo donde se almacena la peticion generada al servicio de SIMI.';

COMMENT ON COLUMN log_servicio_simi.response IS
    'Campo donde se almacena lar respuesta generada por el servicio de SIMI.';

COMMENT ON COLUMN log_servicio_simi.estado IS
    'Tabla Dominio - Campo que por medio de un dominio indica el estado de registro.';

CREATE UNIQUE INDEX log_servicio_simi__idx ON
    log_servicio_simi ( cod_log_serv ASC )
        LOGGING;

ALTER TABLE log_servicio_simi ADD CONSTRAINT log_servicio_simi_pk PRIMARY KEY ( cod_log_serv );

CREATE TABLE mes_registrado (
    mes                      DATE NOT NULL,
    can_aseg                 NUMBER(20,2) NOT NULL,
    recu_can                 NUMBER(20,2) NOT NULL,
    tot_can                  NUMBER(20,2) NOT NULL,
    adm_aseg                 NUMBER(20,2) NOT NULL,
    recu_admi                NUMBER(20,2) NOT NULL,
    tot_admi                 NUMBER(20,2) NOT NULL,
    total_mes                NUMBER(20,2) NOT NULL,
    siniestro_fec_rep        DATE DEFAULT SYSDATE NOT NULL,
    sini_sol_sai_solicitud   NUMBER(10) NOT NULL
)
    LOGGING;

COMMENT ON TABLE mes_registrado IS
    'MES REGISTRADO - Tabla donde se almacenan los meses que se van a reportar,segun la fecha de mora ingresada.';

COMMENT ON COLUMN mes_registrado.mes IS
    'Mes que se va a reportar.';

COMMENT ON COLUMN mes_registrado.can_aseg IS
    'canon asegurado - Valor de canon asegurado para el mes que se va a reportar.';

COMMENT ON COLUMN mes_registrado.recu_can IS
    'recuperacion canon - Valor de recuperacion para le canon de arrendamiento para el mes reportado.';

COMMENT ON COLUMN mes_registrado.tot_can IS
    'total canon - Valor total de la suma de canon de arredamiento asegurado mas el valor de la recuperacion por mes.';

COMMENT ON COLUMN mes_registrado.adm_aseg IS
    'administracion asegurado - Valor de la cuota de administracion asegurada para el mes que se va a reportar.';

COMMENT ON COLUMN mes_registrado.recu_admi IS
    'recuperacion administracion - Valor de recuperacion para la cuota de administracion  para el mes reportado.';

COMMENT ON COLUMN mes_registrado.tot_admi IS
    'total administracion - Valor total de la suma de la cuota de administracion asegurado mas el valor de la recuperacion por mes.';

COMMENT ON COLUMN mes_registrado.total_mes IS
    'Valor total por mes reportado, que es compuesto por la suma del total canon y el total administracion.';

COMMENT ON COLUMN mes_registrado.siniestro_fec_rep IS
    'fecha reporte - Fecha del sistema (sysdate) de cuando se hizo el reporte de sineistro';

CREATE UNIQUE INDEX mes_registrado__idx ON
    mes_registrado (
        mes
    ASC,
        siniestro_fec_rep
    ASC,
        sini_sol_sai_solicitud
    ASC )
        LOGGING;

ALTER TABLE mes_registrado ADD CONSTRAINT mes_registrado_pk PRIMARY KEY ( mes,siniestro_fec_rep,sini_sol_sai_solicitud );

CREATE TABLE modulo (
    cod_mod   NUMBER(5) NOT NULL,
    nombre    VARCHAR2(200 BYTE) NOT NULL
)
    LOGGING;

COMMENT ON TABLE modulo IS
    'Tabla donde se almacenan las opciones/modulos que tendra la aplicacion';

COMMENT ON COLUMN modulo.cod_mod IS
    'codigo modulo - Codigo autoincremental de la tabla.';

COMMENT ON COLUMN modulo.nombre IS
    'aCampo donde se almacena el nombre del modulo.';

ALTER TABLE modulo ADD CONSTRAINT modulo_pk PRIMARY KEY ( cod_mod );

CREATE TABLE modulo_perfil (
    modulo_cod_mod    NUMBER(5) NOT NULL,
    perfil_cod_perf   NUMBER(5) NOT NULL
)
    LOGGING;

COMMENT ON TABLE modulo_perfil IS
    'MODULO PERFIL - Tabla donde se asignan los modulos que va a tener un perfil determinado.';

ALTER TABLE modulo_perfil ADD CONSTRAINT modulo_perfil_pk PRIMARY KEY ( modulo_cod_mod,perfil_cod_perf );

CREATE TABLE notificacion (
    solicitud   NUMBER(10) NOT NULL,
    fec_noti    DATE NOT NULL
)
    LOGGING;

COMMENT ON TABLE notificacion IS
    'Tabla donde se registran las solicitudes de notificaciones que se requieren por parte de la inmobiliaria.';

COMMENT ON COLUMN notificacion.solicitud IS
    'Numero de solicitud que a la que se le esta haciendo la novedad.';

COMMENT ON COLUMN notificacion.fec_noti IS
    'fecha notificacion - Fecha del sistema de cuando se esta generando la notificacion.';

CREATE UNIQUE INDEX notificacion__idx ON
    notificacion (
        solicitud
    ASC,
        fec_noti
    ASC )
        LOGGING;

ALTER TABLE notificacion ADD CONSTRAINT notificacion_pk PRIMARY KEY ( solicitud,fec_noti );

CREATE TABLE notificacion_correo (
    cod_noti_corr   NUMBER(15) NOT NULL,
    destinatario    VARCHAR2(200 BYTE) NOT NULL,
    asunto          VARCHAR2(200 BYTE) NOT NULL,
    cuerpo          VARCHAR2(400 BYTE) NOT NULL
)
    LOGGING;

COMMENT ON TABLE notificacion_correo IS
    'NOTIFICACION CORREO - Tabla donde se guardaran la informacion correspondiente al envio de correos electronicos.';

COMMENT ON COLUMN notificacion_correo.cod_noti_corr IS
    'codigo notificacion correo';

CREATE UNIQUE INDEX notificacion_correo__idx ON
    notificacion_correo ( cod_noti_corr ASC )
        LOGGING;

ALTER TABLE notificacion_correo ADD CONSTRAINT notificacion_correo_pk PRIMARY KEY ( cod_noti_corr );

CREATE TABLE parametro (
    cod_para      NUMBER(15) NOT NULL,
    descripcion   VARCHAR2(200 BYTE) NOT NULL,
    valor         NVARCHAR2(200) NOT NULL,
    estado        VARCHAR2(20 BYTE) NOT NULL
)
    LOGGING;

ALTER TABLE parametro ADD CHECK (
    estado IN (
        '1','2'
    )
);

COMMENT ON TABLE parametro IS
    'Tabla encargada de guardar los parametros que se van a usar en el sistema.';

COMMENT ON COLUMN parametro.cod_para IS
    'codigo parametro';

CREATE UNIQUE INDEX parametro__idx ON
    parametro ( cod_para ASC )
        LOGGING;

ALTER TABLE parametro ADD CONSTRAINT parametro_pk PRIMARY KEY ( cod_para );

CREATE TABLE perfil (
    cod_perf   NUMBER(15) NOT NULL,
    nombre     VARCHAR2(200 BYTE) NOT NULL
)
    LOGGING;

COMMENT ON TABLE perfil IS
    'Tabla donde se registran los perfiles que se van a manejar en la aplicacion.';

COMMENT ON COLUMN perfil.cod_perf IS
    'codigo perfil - Codigo autoincremental de la tabla.';

COMMENT ON COLUMN perfil.nombre IS
    'Campor donde se guarda el nombre del perfil.';

CREATE UNIQUE INDEX perfil__idx ON
    perfil ( cod_perf ASC )
        LOGGING;

ALTER TABLE perfil ADD CONSTRAINT perfil_pk PRIMARY KEY ( cod_perf );

CREATE TABLE registro_amparo_integral (
    fec_rep                   DATE NOT NULL,
    tipo_poli                 VARCHAR2(200 BYTE) NOT NULL,
    fecha_mora                DATE NOT NULL,
    tot_recl                  NUMBER(20,2) NOT NULL,
    est_sini                  NUMBER(20) NOT NULL,
    est_pago                  NUMBER(20) NOT NULL,
    solicitud_sai_solicitud   NUMBER(10) NOT NULL
)
    LOGGING;

ALTER TABLE registro_amparo_integral ADD CHECK (
    tipo_poli IN (
        '1','2'
    )
);

COMMENT ON TABLE registro_amparo_integral IS
    'REGI AMPA INTE - Tabla donde se registra los reportes de amparo integral.';

COMMENT ON COLUMN registro_amparo_integral.fec_rep IS
    'fec rep - campo donde se guarda la fecha del sistema de cuando se esta realizando el reporte de la novedad.';

COMMENT ON COLUMN registro_amparo_integral.tipo_poli IS
    'tipo poliza - Dominio que identifica el tipo de poliza que esta registrando la desocupacion,colectiva/individual';

COMMENT ON COLUMN registro_amparo_integral.fecha_mora IS
    'fec mora - Campo donde se registra la fecha de mora que se va a ingresar.';

COMMENT ON COLUMN registro_amparo_integral.tot_recl IS
    'total reclamar - Campo donde se registra el valor total que se va a reclamar.';

COMMENT ON COLUMN registro_amparo_integral.est_sini IS
    'Tabla Dominio - estado siniestro - Campo que indica el estado del siniestro.';

COMMENT ON COLUMN registro_amparo_integral.est_pago IS
    'Tabla Dominio - estado pago - Campo que indica el estado del pago del siniestro';

CREATE INDEX registro_amparo_integral__idx ON
    registro_amparo_integral (
        fec_rep
    ASC,
        solicitud_sai_solicitud
    ASC )
        LOGGING;

ALTER TABLE registro_amparo_integral ADD CONSTRAINT registro_amparo_integral_pk PRIMARY KEY ( fec_rep,solicitud_sai_solicitud );

CREATE TABLE registro_danio_faltante (
    fec_rep                   DATE NOT NULL,
    fec_mor                   DATE NOT NULL,
    val_aseg                  NUMBER(20,2) NOT NULL,
    val_recl                  NUMBER(20,2) NOT NULL,
    tip_pol                   VARCHAR2(200 BYTE) NOT NULL,
    periodo                   VARCHAR2(10 BYTE) NOT NULL,
    esta_sini                 NUMBER(20) NOT NULL,
    est_pag                   NUMBER NOT NULL,
    observacion               VARCHAR2(200 BYTE),
    solicitud_sai_solicitud   NUMBER(10) NOT NULL
)
    LOGGING;

ALTER TABLE registro_danio_faltante ADD CHECK (
    tip_pol IN (
        '1','2'
    )
);

COMMENT ON TABLE registro_danio_faltante IS
    'Tabla donde se registran el reporte de daños y faltantes.';

COMMENT ON COLUMN registro_danio_faltante.fec_rep IS
    'fecha reporte - campo donde se registra la fecha del sistema en la cual se esta haciendo el reporte de danios y faltantes.';

COMMENT ON COLUMN registro_danio_faltante.fec_mor IS
    'fecha mora - Campo donde se registra la fecha de mora de el reporte de danios y faltantes.';

COMMENT ON COLUMN registro_danio_faltante.val_aseg IS
    'val aseg - valor del amparo hogar asegurado';

COMMENT ON COLUMN registro_danio_faltante.val_recl IS
    'valor reclamar - Campo donde se almacena el valor que va a ser reclamado.';

COMMENT ON COLUMN registro_danio_faltante.tip_pol IS
    'tipo poliza - Dominio que identifica el tipo de poliza que esta registrand,colectiva/individual';

COMMENT ON COLUMN registro_danio_faltante.periodo IS
    'Indica el periodo efectivo calculado en SAI.';

COMMENT ON COLUMN registro_danio_faltante.esta_sini IS
    'Tabla Dominio - estado siniestro - Campo que indica el estado del siniestro.';

COMMENT ON COLUMN registro_danio_faltante.est_pag IS
    'Tabla Dominio - estado pago - Campo que indica el estado del pago del siniestro.';

COMMENT ON COLUMN registro_danio_faltante.observacion IS
    'Campo donde se guarda la observacion de registro si se tiene.';

CREATE UNIQUE INDEX registro_danio_faltante__idx ON
    registro_danio_faltante (
        fec_rep
    ASC,
        solicitud_sai_solicitud
    ASC )
        LOGGING;

ALTER TABLE registro_danio_faltante ADD CONSTRAINT registro_danio_faltante_pk PRIMARY KEY ( fec_rep,solicitud_sai_solicitud );

CREATE TABLE retiro (
    fecha_retiro              DATE NOT NULL,
    periodo                   DATE NOT NULL,
    estado                    NUMBER(20) NOT NULL,
    solicitud_sai_solicitud   NUMBER(10) NOT NULL
)
    LOGGING;

COMMENT ON TABLE retiro IS
    'Tabla donde se registraran los retiros del seguro a uno solicitud.';

COMMENT ON COLUMN retiro.fecha_retiro IS
    'fecha retiro - fecha el cual se hizo el retiro.';

COMMENT ON COLUMN retiro.periodo IS
    'Indica el periodo calculado en SAI en al cual se hace el retiro.';

COMMENT ON COLUMN retiro.estado IS
    'Tabla Dominio - Campo que por medio de un dominio indica el estado de la solicitud.';

CREATE UNIQUE INDEX retiro__idx ON
    retiro (
        fecha_retiro
    ASC,
        solicitud_sai_solicitud
    ASC )
        LOGGING;

ALTER TABLE retiro ADD CONSTRAINT retiro_pk PRIMARY KEY ( fecha_retiro,solicitud_sai_solicitud );

CREATE TABLE servicio_publico (
    cod_serv_pub            NUMBER(15) NOT NULL,
    cod_serv                NUMBER(5) NOT NULL,
    nombre                  VARCHAR2(200 BYTE) NOT NULL,
    val_recl                NUMBER(20,2) NOT NULL,
    fec_ini                 DATE NOT NULL,
    fec_fin                 DATE NOT NULL,
    reg_amp_inte_fec_rep    DATE DEFAULT SYSDATE NOT NULL,
    reg_amp_int_solicitud   NUMBER(10) NOT NULL
)
    LOGGING;

COMMENT ON TABLE servicio_publico IS
    'SERVICIO PUBLICO - Tabla donde se almacenan los valores ingresados de los servicios publicos,en el reporte del amparo integral.'
;

COMMENT ON COLUMN servicio_publico.cod_serv_pub IS
    'codigo servicio publico - Codigo autoincremental de la tabla';

COMMENT ON COLUMN servicio_publico.cod_serv IS
    'codigo servicio - Campo donde se almacena el codigo del servicio publico que esta registrado en SAI.';

COMMENT ON COLUMN servicio_publico.nombre IS
    'Campo donde se registra el nombre del servicio publico.';

COMMENT ON COLUMN servicio_publico.val_recl IS
    'valor reclamar - Campo donde se almacena el valor que se va a reclamar por cada servicio publico.';

COMMENT ON COLUMN servicio_publico.fec_ini IS
    'fecha inicial - Campo donde se registra el iinicio del periodo de facturacion de los servicios publicos.';

COMMENT ON COLUMN servicio_publico.fec_fin IS
    'fecha final - Campo donde se registra el fin del periodo de facturacion de los servicios publicos.';

COMMENT ON COLUMN servicio_publico.reg_amp_inte_fec_rep IS
    'fec rep - campo donde se guarda la fecha del sistema de cuando se esta realizando el reporte de la novedad.';

CREATE UNIQUE INDEX servicio_publico__idx ON
    servicio_publico ( cod_serv_pub ASC )
        LOGGING;

ALTER TABLE servicio_publico ADD CONSTRAINT servicio_publico_pk PRIMARY KEY ( cod_serv_pub );

CREATE TABLE siniestro (
    fec_rep                   DATE NOT NULL,
    cod_sini_sai              NUMBER(10) NOT NULL,
    fec_mora                  DATE NOT NULL,
    fec_ini_cont              DATE,
    fec_fin_cont              DATE,
    periodo                   VARCHAR2(10 BYTE) NOT NULL,
    tip_pol                   VARCHAR2(200 BYTE) NOT NULL,
    tipo_rep_sini             VARCHAR2(30 BYTE) NOT NULL,
    cuot_adm                  CHAR(1) NOT NULL,
    est_pago                  NUMBER(20) NOT NULL,
    est_sini                  NUMBER(20) NOT NULL,
    cano_arre_repo            NUMBER(20,2),
    val_admi_repo             NUMBER(20,2),
    observacion               VARCHAR2(400 BYTE),
    solicitud_sai_solicitud   NUMBER(10) NOT NULL
)
    LOGGING;

ALTER TABLE siniestro ADD CHECK (
    tip_pol IN (
        '1','2'
    )
);

ALTER TABLE siniestro ADD CHECK (
    tipo_rep_sini IN (
        '1','2'
    )
);

COMMENT ON TABLE siniestro IS
    'Tabla donde se registran el reporte de siniestros personalizado y masivo segun sea el caso.';

COMMENT ON COLUMN siniestro.fec_rep IS
    'fecha reporte - Fecha del sistema (sysdate) de cuando se hizo el reporte de sineistro';

COMMENT ON COLUMN siniestro.cod_sini_sai IS
    'codigo siniestro SAI - Campo donde se almancena el numero del reporte de siniestro generado en SAI.';

COMMENT ON COLUMN siniestro.fec_mora IS
    'fecha mora - Fehca de mora que se esta reportando en el siniestro';

COMMENT ON COLUMN siniestro.fec_ini_cont IS
    'fecha inicio contrato - Fecha de inicio de cuando se inicia el contrato';

COMMENT ON COLUMN siniestro.fec_fin_cont IS
    'fecha fin contrato - Fecha de fin de cuando se inicia el contrato';

COMMENT ON COLUMN siniestro.periodo IS
    'Indica el periodo efectivo calculado en SAI.';

COMMENT ON COLUMN siniestro.tip_pol IS
    'tipo poliza - Dominio que identifica el tipo de poliza que esta registrando la desocupacion,colectiva/individual';

COMMENT ON COLUMN siniestro.tipo_rep_sini IS
    'tipo reporte siniestro - Dominio donde se indica el tipo de reporte de siniestro (Personalizado,Masivo)';

COMMENT ON COLUMN siniestro.cuot_adm IS
    'cuota administracion - campo que indica si se va a reportar o no la cuota de administracion.';

COMMENT ON COLUMN siniestro.est_pago IS
    'Tabla dominio que indica el estado del pago del siniestro.';

COMMENT ON COLUMN siniestro.est_sini IS
    'Tabla dominio que indica el estado del siniestro';

COMMENT ON COLUMN siniestro.cano_arre_repo IS
    'canon arrendamiento reportado - Valor usado para el reporte individual.';

COMMENT ON COLUMN siniestro.val_admi_repo IS
    'valor administracion reportado - Valor usado para el reporte individual';

CREATE UNIQUE INDEX siniestro__idx ON
    siniestro (
        fec_rep
    ASC,
        solicitud_sai_solicitud
    ASC )
        LOGGING;

ALTER TABLE siniestro ADD CONSTRAINT siniestro_pk PRIMARY KEY ( fec_rep,solicitud_sai_solicitud );

CREATE TABLE siniestro_pendiente (
    tip_obs               NUMBER(20) NOT NULL,
    fec_pend              DATE DEFAULT SYSDATE NOT NULL,
    estado                NUMBER(20) NOT NULL,
    siniestro_fec_rep     DATE DEFAULT SYSDATE NOT NULL,
    siniestro_solicitud   NUMBER(10) NOT NULL
)
    LOGGING;

COMMENT ON TABLE siniestro_pendiente IS
    'SINIESTRO PENDIENTE - Tabla donde se almacenan los siniestros pendients,los que no cumplieron con las reglas de negocio definidas,y quedan pendietes a ser verificadas.'
;

COMMENT ON COLUMN siniestro_pendiente.tip_obs IS
    'tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo como pendiente';

COMMENT ON COLUMN siniestro_pendiente.fec_pend IS
    'fecha pendiente -  Fecha del sistema en la que el registro quedo en pendiente.';

COMMENT ON COLUMN siniestro_pendiente.estado IS
    'Dominio - Campo que por medio de un dominio indica el estado de registro.';

COMMENT ON COLUMN siniestro_pendiente.siniestro_fec_rep IS
    'fecha reporte - Fecha del sistema (sysdate) de cuando se hizo el reporte de sineistro';

CREATE UNIQUE INDEX siniestro_pendiente__idx ON
    siniestro_pendiente ( tip_obs ASC )
        LOGGING;

CREATE UNIQUE INDEX siniestro_pendiente__idxv1 ON
    siniestro_pendiente (
        siniestro_fec_rep
    ASC,
        siniestro_solicitud
    ASC )
        LOGGING;

ALTER TABLE siniestro_pendiente ADD CONSTRAINT siniestro_pendiente_pk PRIMARY KEY ( siniestro_fec_rep,siniestro_solicitud,tip_obs );

CREATE TABLE solicitud_sai (
    solicitud        NUMBER(22) NOT NULL,
    inquilino        VARCHAR2(100 BYTE),
    destinacion      VARCHAR2(100 BYTE),
    tipo_inmu        VARCHAR2(100 BYTE),
    poliza           NUMBER(22),
    direccion        VARCHAR2(100 BYTE),
    ciudad           VARCHAR2(100 BYTE),
    canon            NUMBER(20,2),
    administracion   NUMBER(20,2),
    cano_aseg        NUMBER(20,2),
    admi_aseg        NUMBER(20,2),
    amp_hog_aseg     NUMBER(20,2),
    amp_int_aseg     NUMBER(20,2),
    nuev_val_aseg    NUMBER(20,2),
    fec_nove         DATE,
    est_soli         VARCHAR2(2 BYTE),
    est_sini         VARCHAR2(2 BYTE),
    est_pago         VARCHAR2(2 BYTE),
    fec_mora         DATE,
    fec_ingr         DATE,
    fec_estu         DATE,
    fec_deso         DATE,
    fec_reti         DATE,
    fec_ini_cont     DATE
)
    LOGGING;

COMMENT ON TABLE solicitud_sai IS
    'Datos Basicos Sai Conexion - Tabla usada para consultar los datos basicos de SAI,cuan SAI este caido,esta tabla se ira actualizando a medida que se consulte la informacion en SAI.
Actualiza constantemente la tabla con los datos de consulta de SAI,solo se usaria para consultas'
;

COMMENT ON COLUMN solicitud_sai.solicitud IS
    'Numero de la solicitud de SAI';

COMMENT ON COLUMN solicitud_sai.destinacion IS
    'Comercial-Vivienda';

COMMENT ON COLUMN solicitud_sai.tipo_inmu IS
    'Apartamento-Local-Casa-Oficina';

COMMENT ON COLUMN solicitud_sai.canon IS
    'Validar';

CREATE UNIQUE INDEX solicitud_sai__idx ON
    solicitud_sai ( solicitud ASC )
        LOGGING;

ALTER TABLE solicitud_sai ADD CONSTRAINT solicitud_sai_pk PRIMARY KEY ( solicitud );

CREATE TABLE transaccion (
    cod_tran                         NUMBER(15) NOT NULL,
    usuario                          NUMBER(20) NOT NULL,
    identificacion                   NUMBER(20) NOT NULL,
    fec_tran                         DATE DEFAULT SYSDATE NOT NULL,
    equipo                           VARCHAR2(300 BYTE) NOT NULL,
    estado                           NUMBER(20) NOT NULL,
    log_serv_simi_cod_log_serv       NUMBER(5),
    desocupacion_fec_regi            DATE DEFAULT SYSDATE,
    deso_solicitud_sai_solicitud     NUMBER(10),
    desistimiento_fec_reg            DATE DEFAULT SYSDATE,
    desis_sol_sai_solicitud          NUMBER(10),
    reg_danio_falt_fec_rep           DATE DEFAULT SYSDATE,
    reg_dan_fal_sol_sai_solicitud    NUMBER(10),
    reg_amparo_integral_fec_rep      DATE DEFAULT SYSDATE,
    reg_amp_inte_sol_sai_solicitud   NUMBER(10),
    aumento_fec_aumento              DATE DEFAULT SYSDATE,
    aum_solicitud_sai_solicitud      NUMBER(10),
    ingreso_fec_registro_ing         DATE DEFAULT SYSDATE,
    ing_solicitud_sai_solicitud      NUMBER(10),
    retiro_fecha_retiro              DATE DEFAULT SYSDATE,
    reti_solicitud_sai_solicitud     NUMBER(10),
    siniestro_fec_rep                DATE DEFAULT SYSDATE,
    siniestro_sol_sai_solicitud      NUMBER(10)
)
    LOGGING;

ALTER TABLE transaccion ADD CONSTRAINT arc_3 CHECK (
    (
        (
            aumento_fec_aumento IS NOT NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NOT NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    ) OR (
        (
            ingreso_fec_registro_ing IS NOT NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NOT NULL
        ) AND (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    ) OR (
        (
            desocupacion_fec_regi IS NOT NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NOT NULL
        ) AND (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    ) OR (
        (
            desistimiento_fec_reg IS NOT NULL
        ) AND (
            desis_sol_sai_solicitud IS NOT NULL
        ) AND (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    ) OR (
        (
            reg_danio_falt_fec_rep IS NOT NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NOT NULL
        ) AND (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    ) OR (
        (
            siniestro_fec_rep IS NOT NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NOT NULL
        ) AND (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    ) OR (
        (
            reg_amparo_integral_fec_rep IS NOT NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NOT NULL
        ) AND (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    ) OR (
        (
            log_serv_simi_cod_log_serv IS NOT NULL
        ) AND (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    ) OR (
        (
            retiro_fecha_retiro IS NOT NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NOT NULL
        ) AND (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        )
    ) OR (
        (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    )
);

COMMENT ON TABLE transaccion IS
    'Tabla donde se van a almacenar las transacciones que se realizen sobre el sistema.';

COMMENT ON COLUMN transaccion.cod_tran IS
    'codigo transaccion - Codigo autoincremental de la tabla';

COMMENT ON COLUMN transaccion.usuario IS
    'LLave o codigo del usuario que realizó la transacción.';

COMMENT ON COLUMN transaccion.identificacion IS
    'Campo establecido para las polizas individuales';

COMMENT ON COLUMN transaccion.fec_tran IS
    'fecha transaccion - Campo que indica la fecha del sistema en la que se realizo la transaccion.';

COMMENT ON COLUMN transaccion.equipo IS
    'Atributo donde se almacena el equipo/ip del usuario que esta haciendo uso de la aplicacion.';

COMMENT ON COLUMN transaccion.estado IS
    'Campo que por medio de un dominio indica el estado de registro.';

COMMENT ON COLUMN transaccion.log_serv_simi_cod_log_serv IS
    'Codigo autoincremental de la tabla.';

COMMENT ON COLUMN transaccion.desocupacion_fec_regi IS
    'fecha registro - Fecha del sistema de cuando se esta realizando la desocupacion.';

COMMENT ON COLUMN transaccion.desistimiento_fec_reg IS
    'fecha registro - fecha del sistema en el que se esta haciendo el desistimiento.';

COMMENT ON COLUMN transaccion.reg_danio_falt_fec_rep IS
    'fecha reporte - campo donde se registra la fecha del sistema en la cual se esta haciendo el reporte de danios y faltantes.';

COMMENT ON COLUMN transaccion.reg_amparo_integral_fec_rep IS
    'fec rep - campo donde se guarda la fecha del sistema de cuando se esta realizando el reporte de la novedad.';

COMMENT ON COLUMN transaccion.aumento_fec_aumento IS
    'fecha aumento - Fecha en la cual se esta realizando el aumento.';

COMMENT ON COLUMN transaccion.ingreso_fec_registro_ing IS
    'Fecha del sistema donde de cuado se esta realizando el registro.';

COMMENT ON COLUMN transaccion.retiro_fecha_retiro IS
    'fecha retiro - fecha el cual se hizo el retiro.';

COMMENT ON COLUMN transaccion.siniestro_fec_rep IS
    'fecha reporte - Fecha del sistema (sysdate) de cuando se hizo el reporte de sineistro';

CREATE UNIQUE INDEX transaccion__idx ON
    transaccion ( log_serv_simi_cod_log_serv ASC )
        LOGGING;

CREATE UNIQUE INDEX transaccion__idxv1 ON
    transaccion (
        retiro_fecha_retiro
    ASC,
        reti_solicitud_sai_solicitud
    ASC )
        LOGGING;

CREATE UNIQUE INDEX transaccion__idxv2 ON
    transaccion (
        aumento_fec_aumento
    ASC,
        aum_solicitud_sai_solicitud
    ASC )
        LOGGING;

CREATE UNIQUE INDEX transaccion__idxv3 ON
    transaccion (
        siniestro_fec_rep
    ASC,
        siniestro_sol_sai_solicitud
    ASC )
        LOGGING;

CREATE UNIQUE INDEX transaccion__idxv4 ON
    transaccion (
        reg_amparo_integral_fec_rep
    ASC,
        reg_amp_inte_sol_sai_solicitud
    ASC )
        LOGGING;

CREATE UNIQUE INDEX transaccion__idxv5 ON
    transaccion (
        reg_danio_falt_fec_rep
    ASC,
        reg_dan_fal_sol_sai_solicitud
    ASC )
        LOGGING;

CREATE UNIQUE INDEX transaccion__idxv6 ON
    transaccion (
        desistimiento_fec_reg
    ASC,
        desis_sol_sai_solicitud
    ASC )
        LOGGING;

CREATE UNIQUE INDEX transaccion__idxv7 ON
    transaccion (
        desocupacion_fec_regi
    ASC,
        deso_solicitud_sai_solicitud
    ASC )
        LOGGING;

CREATE UNIQUE INDEX transaccion__idxv8 ON
    transaccion (
        ingreso_fec_registro_ing
    ASC,
        ing_solicitud_sai_solicitud
    ASC )
        LOGGING;

CREATE INDEX transaccion__idxv9 ON
    transaccion ( cod_tran ASC )
        LOGGING;

ALTER TABLE transaccion ADD CONSTRAINT transaccion_pk PRIMARY KEY ( cod_tran );

CREATE TABLE usuario_perfil (
    cod_usu           NUMBER(5) NOT NULL,
    perfil_cod_perf   NUMBER(5) NOT NULL
)
    LOGGING;

COMMENT ON TABLE usuario_perfil IS
    'USUARIO PERFIL - Tabla donde se asignaran los perfiles por usuario de la  aplicacion.';

COMMENT ON COLUMN usuario_perfil.cod_usu IS
    'codigo usuario - Campo donde se alamcena el codigo del usuario que se le va asignar el perfil.';

ALTER TABLE usuario_perfil ADD CONSTRAINT usuario_perfil_pk PRIMARY KEY ( perfil_cod_perf );

CREATE TABLE val_dominio (
    cod_val_dominio       NUMBER(15) NOT NULL,
    valor                 VARCHAR2(400 BYTE) NOT NULL,
    estado                VARCHAR2(20 BYTE) NOT NULL,
    dominio_cod_dominio   NUMBER(15) NOT NULL
)
    LOGGING;

ALTER TABLE val_dominio ADD CHECK (
    estado IN (
        '1','2'
    )
);

COMMENT ON TABLE val_dominio IS
    'Tabla donde se almacenaran los posibles valores que puede tomar un dominio.';

COMMENT ON COLUMN val_dominio.cod_val_dominio IS
    'Codigo Autoincremental de la tabla.';

COMMENT ON COLUMN val_dominio.valor IS
    'Posible valor que puede tomar el dominio.';

COMMENT ON COLUMN val_dominio.estado IS
    'Dominio que indica el estado del dominio,si este esta activo o esta inactivo.';

COMMENT ON COLUMN val_dominio.dominio_cod_dominio IS
    'Codigo autoincremental de la tabla';

CREATE INDEX val_dominio__idx ON
    val_dominio ( cod_val_dominio ASC )
        LOGGING;

ALTER TABLE val_dominio ADD CONSTRAINT val_dominio_pk PRIMARY KEY ( cod_val_dominio );

CREATE TABLE valor_reportado (
    cod_val_repor            NUMBER(15) NOT NULL,
    tip_con                  NUMBER(20) NOT NULL,
    per_ini                  DATE NOT NULL,
    per_fin                  DATE NOT NULL,
    val_repo                 NUMBER(20,2) NOT NULL,
    siniestro_fec_rep        DATE NOT NULL,
    sini_sol_sai_solicitud   NUMBER(10) NOT NULL
)
    LOGGING;

COMMENT ON TABLE valor_reportado IS
    'VALOR REPORTADO - Tabla donde se ingresan los valores que se van a reportar en SAI (valores de desfase,valores de reporte de siniestro,Valores por Recueracion).'
;

COMMENT ON COLUMN valor_reportado.cod_val_repor IS
    'codigo valor reportado - Codigo autoincremental de la tabla.';

COMMENT ON COLUMN valor_reportado.tip_con IS
    'tipo concepto - Dominio que indica el tipo de concepto del pago: REM01,RM,01,02';

COMMENT ON COLUMN valor_reportado.per_ini IS
    'periodo inicio - Fecha de inicio del valor reportado del siniestro.';

COMMENT ON COLUMN valor_reportado.per_fin IS
    'periodo fin - Fecha fin del valor reportado del siniestro.';

COMMENT ON COLUMN valor_reportado.val_repo IS
    'valor reportado';

COMMENT ON COLUMN valor_reportado.siniestro_fec_rep IS
    'fecha reporte - Fecha del sistema (sysdate) de cuando se hizo el reporte de sineistro';

CREATE INDEX valor_reportado__idx ON
    valor_reportado ( cod_val_repor ASC )
        LOGGING;

ALTER TABLE valor_reportado ADD CONSTRAINT valor_reportado_pk PRIMARY KEY ( cod_val_repor );

ALTER TABLE alerta ADD CONSTRAINT alerta_transaccion_fk FOREIGN KEY ( transaccion_cod_tran )
    REFERENCES transaccion ( cod_tran )
NOT DEFERRABLE;

ALTER TABLE aumento_pendiente ADD CONSTRAINT aumento_pendiente_aumento_fk FOREIGN KEY ( aumento_fec_aumento,aumento_solicitud )
    REFERENCES aumento ( fec_aumento,solicitud_sai_solicitud )
NOT DEFERRABLE;

ALTER TABLE aumento ADD CONSTRAINT aumento_solicitud_sai_fk FOREIGN KEY ( solicitud_sai_solicitud )
    REFERENCES solicitud_sai ( solicitud )
NOT DEFERRABLE;

ALTER TABLE autorizacion_desocupacioon ADD CONSTRAINT auto_deso_deso_pend_fk FOREIGN KEY ( deso_pend_tipo_obs,deso_pend_desoc_fec_regi,deso_pend_desoc_solicitud
 )
    REFERENCES desocupacion_pendiente ( tipo_obs,desocupacion_fec_regi,desocupacion_solicitud )
NOT DEFERRABLE;

ALTER TABLE autorizacion_indemnizacion ADD CONSTRAINT auto_ind_danio_falt_pend_fk FOREIGN KEY ( dan_falt_pend_fec_rep,dan_falt_pend_solicitud
,dan_falt_pend_tipo_obs )
    REFERENCES danio_faltante_pendiente ( reg_dan_falt_fec_rep,reg_dan_falt_solicitud,tipo_obs )
NOT DEFERRABLE;

ALTER TABLE autorizacion_indemnizacion ADD CONSTRAINT auto_indem_siniestro_pend_fk FOREIGN KEY ( sini_pend_sinie_fec_rep,sini_pend_sinie_solicitud
,sini_pend_tip_obs )
    REFERENCES siniestro_pendiente ( siniestro_fec_rep,siniestro_solicitud,tip_obs )
NOT DEFERRABLE;

ALTER TABLE autorizacion_operacion ADD CONSTRAINT auto_oper_aum_pend_fk FOREIGN KEY ( aum_pend_aum_fec_aumento,aum_pend_aume_solicitud,aum_pend_tipo_obs_aum
 )
    REFERENCES aumento_pendiente ( aumento_fec_aumento,aumento_solicitud,tipo_obs_aum )
NOT DEFERRABLE;

ALTER TABLE autorizacion_operacion ADD CONSTRAINT auto_oper_ing_pend_fk FOREIGN KEY ( ing_pend_ingr_fec_registro_ing,ing_pend_ingr_solicitud
,ing_pend_tipo_obs_ing )
    REFERENCES ingreso_pendiente ( ingreso_fec_registro_ing,ingreso_solicitud,tipo_obs_ing )
NOT DEFERRABLE;

ALTER TABLE danio_faltante_pendiente ADD CONSTRAINT dan_falt_pend_reg_dan_falt_fk FOREIGN KEY ( reg_dan_falt_fec_rep,reg_dan_falt_solicitud
 )
    REFERENCES registro_danio_faltante ( fec_rep,solicitud_sai_solicitud )
NOT DEFERRABLE;

ALTER TABLE desistimiento ADD CONSTRAINT desistimiento_solicitud_sai_fk FOREIGN KEY ( solicitud_sai_solicitud )
    REFERENCES solicitud_sai ( solicitud )
NOT DEFERRABLE;

ALTER TABLE desocupacion_pendiente ADD CONSTRAINT deso_pend_deso_fk FOREIGN KEY ( desocupacion_fec_regi,desocupacion_solicitud )
    REFERENCES desocupacion ( fec_regi,solicitud_sai_solicitud )
NOT DEFERRABLE;

ALTER TABLE desocupacion ADD CONSTRAINT desocupacion_solicitud_sai_fk FOREIGN KEY ( solicitud_sai_solicitud )
    REFERENCES solicitud_sai ( solicitud )
NOT DEFERRABLE;

ALTER TABLE documento_soporte ADD CONSTRAINT doc_sop_reg_dan_falt_fk FOREIGN KEY ( reg_dan_falt_fec_rep,reg_dan_falt_solicitud )
    REFERENCES registro_danio_faltante ( fec_rep,solicitud_sai_solicitud )
NOT DEFERRABLE;

ALTER TABLE documento_notificacion ADD CONSTRAINT docu_noti_noti_fk FOREIGN KEY ( notificacion_solicitud,notificacion_fec_noti )
    REFERENCES notificacion ( solicitud,fec_noti )
NOT DEFERRABLE;

ALTER TABLE ingreso_pendiente ADD CONSTRAINT ingreso_pendiente_ingreso_fk FOREIGN KEY ( ingreso_fec_registro_ing,ingreso_solicitud )
    REFERENCES ingreso ( fec_registro_ing,solicitud_sai_solicitud )
NOT DEFERRABLE;

ALTER TABLE ingreso ADD CONSTRAINT ingreso_solicitud_sai_fk FOREIGN KEY ( solicitud_sai_solicitud )
    REFERENCES solicitud_sai ( solicitud )
NOT DEFERRABLE;

ALTER TABLE lista_documento ADD CONSTRAINT lista_documento_siniestro_fk FOREIGN KEY ( siniestro_fec_rep,sini_sol_sai_solicitud )
    REFERENCES siniestro ( fec_rep,solicitud_sai_solicitud )
NOT DEFERRABLE;

ALTER TABLE mes_registrado ADD CONSTRAINT mes_registrado_siniestro_fk FOREIGN KEY ( siniestro_fec_rep,sini_sol_sai_solicitud )
    REFERENCES siniestro ( fec_rep,solicitud_sai_solicitud )
NOT DEFERRABLE;

ALTER TABLE modulo_perfil ADD CONSTRAINT modulo_perfil_modulo_fk FOREIGN KEY ( modulo_cod_mod )
    REFERENCES modulo ( cod_mod )
NOT DEFERRABLE;

ALTER TABLE modulo_perfil ADD CONSTRAINT modulo_perfil_perfil_fk FOREIGN KEY ( perfil_cod_perf )
    REFERENCES perfil ( cod_perf )
NOT DEFERRABLE;

ALTER TABLE registro_amparo_integral ADD CONSTRAINT reg_ampa_inte_sol_sai_fk FOREIGN KEY ( solicitud_sai_solicitud )
    REFERENCES solicitud_sai ( solicitud )
NOT DEFERRABLE;

ALTER TABLE registro_danio_faltante ADD CONSTRAINT reg_dan_falt_sol_sai_fk FOREIGN KEY ( solicitud_sai_solicitud )
    REFERENCES solicitud_sai ( solicitud )
NOT DEFERRABLE;

ALTER TABLE retiro ADD CONSTRAINT retiro_solicitud_sai_fk FOREIGN KEY ( solicitud_sai_solicitud )
    REFERENCES solicitud_sai ( solicitud )
NOT DEFERRABLE;

ALTER TABLE servicio_publico ADD CONSTRAINT serv_pub_reg_amp_inte_fk FOREIGN KEY ( reg_amp_inte_fec_rep,reg_amp_int_solicitud )
    REFERENCES registro_amparo_integral ( fec_rep,solicitud_sai_solicitud )
NOT DEFERRABLE;

ALTER TABLE siniestro_pendiente ADD CONSTRAINT sini_pend_sini_fk FOREIGN KEY ( siniestro_fec_rep,siniestro_solicitud )
    REFERENCES siniestro ( fec_rep,solicitud_sai_solicitud )
NOT DEFERRABLE;

ALTER TABLE siniestro ADD CONSTRAINT siniestro_solicitud_sai_fk FOREIGN KEY ( solicitud_sai_solicitud )
    REFERENCES solicitud_sai ( solicitud )
NOT DEFERRABLE;

ALTER TABLE transaccion ADD CONSTRAINT tran_log_serv_simi_fk FOREIGN KEY ( log_serv_simi_cod_log_serv )
    REFERENCES log_servicio_simi ( cod_log_serv )
NOT DEFERRABLE;

ALTER TABLE transaccion ADD CONSTRAINT tran_reg_amp_int_fk FOREIGN KEY ( reg_amparo_integral_fec_rep,reg_amp_inte_sol_sai_solicitud )
    REFERENCES registro_amparo_integral ( fec_rep,solicitud_sai_solicitud )
NOT DEFERRABLE;

ALTER TABLE transaccion ADD CONSTRAINT tran_reg_dan_falt_fk FOREIGN KEY ( reg_danio_falt_fec_rep,reg_dan_fal_sol_sai_solicitud )
    REFERENCES registro_danio_faltante ( fec_rep,solicitud_sai_solicitud )
NOT DEFERRABLE;

ALTER TABLE transaccion ADD CONSTRAINT transaccion_aumento_fk FOREIGN KEY ( aumento_fec_aumento,aum_solicitud_sai_solicitud )
    REFERENCES aumento ( fec_aumento,solicitud_sai_solicitud )
NOT DEFERRABLE;

ALTER TABLE transaccion ADD CONSTRAINT transaccion_desistimiento_fk FOREIGN KEY ( desistimiento_fec_reg,desis_sol_sai_solicitud )
    REFERENCES desistimiento ( fec_reg,solicitud_sai_solicitud )
NOT DEFERRABLE;

ALTER TABLE transaccion ADD CONSTRAINT transaccion_desocupacion_fk FOREIGN KEY ( desocupacion_fec_regi,deso_solicitud_sai_solicitud )
    REFERENCES desocupacion ( fec_regi,solicitud_sai_solicitud )
NOT DEFERRABLE;

ALTER TABLE transaccion ADD CONSTRAINT transaccion_ingreso_fk FOREIGN KEY ( ingreso_fec_registro_ing,ing_solicitud_sai_solicitud )
    REFERENCES ingreso ( fec_registro_ing,solicitud_sai_solicitud )
NOT DEFERRABLE;

ALTER TABLE transaccion ADD CONSTRAINT transaccion_retiro_fk FOREIGN KEY ( retiro_fecha_retiro,reti_solicitud_sai_solicitud )
    REFERENCES retiro ( fecha_retiro,solicitud_sai_solicitud )
NOT DEFERRABLE;

ALTER TABLE transaccion ADD CONSTRAINT transaccion_siniestro_fk FOREIGN KEY ( siniestro_fec_rep,siniestro_sol_sai_solicitud )
    REFERENCES siniestro ( fec_rep,solicitud_sai_solicitud )
NOT DEFERRABLE;

ALTER TABLE usuario_perfil ADD CONSTRAINT usuario_perfil_perfil_fk FOREIGN KEY ( perfil_cod_perf )
    REFERENCES perfil ( cod_perf )
NOT DEFERRABLE;

ALTER TABLE val_dominio ADD CONSTRAINT val_dominio_dominio_fk FOREIGN KEY ( dominio_cod_dominio )
    REFERENCES dominio ( cod_dominio )
NOT DEFERRABLE;

ALTER TABLE valor_reportado ADD CONSTRAINT valor_reportado_siniestro_fk FOREIGN KEY ( siniestro_fec_rep,sini_sol_sai_solicitud )
    REFERENCES siniestro ( fec_rep,solicitud_sai_solicitud )
NOT DEFERRABLE;

CREATE SEQUENCE sec_alerta START WITH 1 MINVALUE 1 MAXVALUE 999999999999999 NOCACHE ORDER;

CREATE SEQUENCE sec_auto_desocu START WITH 1 MINVALUE 1 MAXVALUE 999999999999999 NOCACHE ORDER;

CREATE SEQUENCE autorizacion_indemnizacion_cod START WITH 1 MINVALUE 1 MAXVALUE 999999999999999 NOCACHE ORDER;

CREATE SEQUENCE sec_auto_inden START WITH 1 MINVALUE 1 MAXVALUE 999999999999999 NOCACHE ORDER;

CREATE SEQUENCE sec_doc_notificacion START WITH 1 MINVALUE 1 MAXVALUE 999999999999999 NOCACHE ORDER;

CREATE SEQUENCE sec_doc_soporte START WITH 1 MINVALUE 1 MAXVALUE 999999999999999 NOCACHE ORDER;

CREATE SEQUENCE sec_dominio START WITH 1 MINVALUE 1 MAXVALUE 999999999999999 NOCACHE ORDER;

CREATE SEQUENCE sec_lis_documento START WITH 1 MINVALUE 1 MAXVALUE 999999999999999 NOCACHE ORDER;

CREATE SEQUENCE sec_not_correo START WITH 1 MINVALUE 1 MAXVALUE 999999999999999 NOCACHE ORDER;

CREATE SEQUENCE sec_parametro START WITH 1 MINVALUE 1 MAXVALUE 999999999999999 NOCACHE ORDER;

CREATE SEQUENCE sec_perfil START WITH 1 MINVALUE 1 MAXVALUE 999999999999999 NOCACHE ORDER;

CREATE SEQUENCE sec_serv_publico START WITH 1 MINVALUE 1 MAXVALUE 999999999999999 NOCACHE ORDER;

CREATE SEQUENCE sec_transaccion START WITH 1 MINVALUE 1 MAXVALUE 999999999999999 NOCACHE ORDER;

CREATE SEQUENCE sec_val_dominio START WITH 1 MINVALUE 1 MAXVALUE 999999999999999 NOCACHE ORDER;

CREATE SEQUENCE sec_val_reportado START WITH 1 MINVALUE 1 MAXVALUE 999999999999999 NOCACHE ORDER;



-- Informe de Resumen de Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                            35
-- CREATE INDEX                            48
-- ALTER TABLE                             85
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                         15
-- CREATE MATERIALIZED VIEW                 0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
