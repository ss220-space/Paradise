/// Dynamic asset for gun with all overlays
/datum/asset/simple/gun_modification
	abstract_type = /datum/asset/simple/gun_modification //Abstract - asset subsystem try to instantiate it without arguments on startup
	var/asset_name

/datum/asset/simple/gun_modification/New(icon/gun_icon, asset_name)
	if(!gun_icon || !asset_name)
		return ..()

	src.asset_name = asset_name
	assets = list()
	assets[asset_name] = gun_icon
	return ..()
