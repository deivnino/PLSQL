alter table admsisa.vlres_snstros add vsn_fcha_dsde date;
alter table admsisa.vlres_snstros add vsn_fcha_hsta date;
COMMENT ON COLUMN admsisa.vlres_snstros.vsn_fcha_dsde IS 'Indica la fecha inicial';
COMMENT ON COLUMN admsisa.vlres_snstros.vsn_fcha_hsta IS 'Indica la fecha final';