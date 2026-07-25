/datum/export/tech_disc
	cost = CARGO_CRATE_VALUE * 0.25
	k_elasticity = 0
	sales_market = EXPORT_NONE
	unit_name = "new research point"
	export_types = list(/obj/item/disk/tech_disk)
	var/static/list/tech_levels = list()

/datum/export/tech_disc/get_base_cost(obj/item/disk/tech_disk/floppy)
	var/datum/tech/technology = floppy.stored
	if(!technology)
		return 0
	var/discovered = tech_levels[technology]
	if(technology.level < discovered)
		return 0
	return ..() * (technology.getCost(discovered))

/datum/export/tech_disc/sell_object(obj/item/disk/tech_disk/floppy, datum/export_report/report, dry_run, apply_elastic)
	. = ..()
	if(. && !dry_run)
		var/datum/tech/technology = floppy.stored
		tech_levels[technology] = technology.level


/datum/export/design_disc
	cost = CARGO_CRATE_VALUE * 0.25
	k_elasticity = 0
	sales_market = EXPORT_NONE
	unit_name = "new design"
	export_types = list(/obj/item/disk/design_disk)
	var/static/list/tech_levels = list()

/datum/export/design_disc/get_base_cost(obj/item/disk/design_disk/floppy)
	var/datum/design/technology = floppy.blueprint
	if(!technology)
		return 0
	if(technology.id in tech_levels)
		return 0

	return ..()

/datum/export/design_disc/sell_object(obj/item/disk/design_disk/floppy, datum/export_report/report, dry_run, apply_elastic)
	. = ..()
	if(. && !dry_run)
		var/datum/design/technology = floppy.blueprint
		LAZYADD(tech_levels, technology.id)

