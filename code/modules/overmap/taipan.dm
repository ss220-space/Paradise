/obj/overmap/entity/taipan_site
	name = "RaMSS Taipan"
	icon_state = "station"
	movable = FALSE
	halted = TRUE
	overmap_kind = OVERMAP_KIND_STATION
	vessel_flags = OVERMAP_VESSEL_STATION
	vessel_mass = OVERMAP_MASS_STATION
	overmap_icon_preset = "station"
	status = OVERMAP_STATUS_OVERMAP
	overmap_hazard_immune = TRUE
	hidden_from_contacts = TRUE
	hidden_from_sensors = TRUE
	identity_name = "RaMSS Taipan"
	identity_icon = "station"
	identity_color = COLOR_RED
	identity_broadcasting = FALSE
	identity_locked = TRUE
	var/obj/overmap/feature/hazard/asteroid/taipan_cover/mask_cover

/obj/overmap/entity/taipan_site/Initialize(mapload)
	identity_iff_ids = list(OVERMAP_IFF_SYNDICATE = FALSE)
	. = ..()
	apply_overmap_identity(identity_name, identity_color, identity_icon, identity_distress, identity_broadcasting, identity_iff_ids, identity_locked)
	sync_mask()

/obj/overmap/entity/taipan_site/Destroy()
	if(SSovermap?.taipan_entity == src)
		SSovermap.taipan_entity = null
	if(mask_cover)
		if(mask_cover.mask_host == src)
			mask_cover.mask_host = null
		QDEL_NULL(mask_cover)
	return ..()

/obj/overmap/entity/taipan_site/add_overmap_components()
	AddComponent(/datum/component/overmap_sensors)
	AddComponent(/datum/component/overmap_dock_host, OVERMAP_DOCK_Z_TAIPAN, /area/syndicate/unpowered/syndicate_space_base)

/obj/overmap/entity/taipan_site/shows_overmap_map_signature()
	return FALSE

/obj/overmap/entity/taipan_site/sync_transponder()
	. = ..()
	sync_mask()

/obj/overmap/entity/taipan_site/proc/sync_mask()
	hidden_from_sensors = TRUE
	hidden_from_contacts = !identity_broadcasting && !identity_distress
	if(transponder?.masking)
		ensure_mask_cover()
	else if(mask_cover)
		if(mask_cover.mask_host == src)
			mask_cover.mask_host = null
		QDEL_NULL(mask_cover)

/obj/overmap/entity/taipan_site/proc/ensure_mask_cover()
	var/turf/here = get_overmap_turf()
	if(!here || !sector)
		return
	if(mask_cover && !QDELETED(mask_cover))
		if(mask_cover.loc != here)
			sector.add_object(mask_cover, here)
		return
	mask_cover = new /obj/overmap/feature/hazard/asteroid/taipan_cover(here)
	mask_cover.mask_host = src
	sector.add_object(mask_cover, here)

/obj/machinery/transponder/taipan
	name = "masked transponder"
	desc = "Транспондер с прошитой маскировкой. На сенсорах объект выглядит как пояс астероидов."
	identity_locked = TRUE
	lock_icon = TRUE
	broadcasting = FALSE
	masking = TRUE
	icon_preset = "station"
	broadcast_color = COLOR_RED

/obj/machinery/transponder/taipan/get_ru_names()
	return alist(
		NOMINATIVE = "маскированный транспондер",
		GENITIVE = "маскированного транспондера",
		DATIVE = "маскированному транспондеру",
		ACCUSATIVE = "маскированный транспондер",
		INSTRUMENTAL = "маскированным транспондером",
		PREPOSITIONAL = "маскированном транспондере",
	)

/obj/machinery/transponder/taipan/Initialize(mapload)
	broadcasting = FALSE
	identity_locked = TRUE
	lock_icon = TRUE
	masking = TRUE
	. = ..()

/obj/machinery/transponder/taipan/ensure_iff_channels()
	if(length(iff_channels))
		return
	iff_channels = list()
	iff_channels += new /datum/overmap_iff_channel(OVERMAP_IFF_GLOBAL, overmap_iff_label_for_id(OVERMAP_IFF_GLOBAL), TRUE, TRUE, broadcasting)
	iff_channels += new /datum/overmap_iff_channel(OVERMAP_IFF_SYNDICATE, overmap_iff_label_for_id(OVERMAP_IFF_SYNDICATE), TRUE, TRUE, FALSE)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/transponder/taipan, 26, 26)
