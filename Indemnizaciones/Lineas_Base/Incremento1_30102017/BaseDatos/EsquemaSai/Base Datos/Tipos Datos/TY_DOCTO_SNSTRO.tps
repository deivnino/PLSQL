   -- definicion de registro para documentos asociados al siniestro 
   CREATE OR REPLACE TYPE admsisa.ty_docto_snstro FORCE AS OBJECT(
        Nro_solicitud       number(10),
        cod_docto           number(5)
   );
   /