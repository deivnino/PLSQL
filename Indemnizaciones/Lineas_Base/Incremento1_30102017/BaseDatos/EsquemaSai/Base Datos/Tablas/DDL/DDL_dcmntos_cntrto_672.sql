ALTER TABLE admsisa.dcmntos_cntrto ADD dcc_tpo_dcmnto VARCHAR(1);
COMMENT ON COLUMN admsisa.dcmntos_cntrto.dcc_tpo_dcmnto IS 'Indica si el documento es principal o anexo';
ALTER TABLE admsisa.dcmntos_cntrto ADD CONSTRAINT ch_tpo_dcmnto CHECK (dcc_tpo_dcmnto IN ('P','A'));



