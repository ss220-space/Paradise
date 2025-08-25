/proc/mapmanip_read_dmm(mapname)
	return RUSTLIB_CALL(mapmanip_read_dmm_file, mapname)

/proc/map_first_manipulated(cfg_path)
	WRITE_LOG(GLOB.submap_log, file2text(cfg_path))
