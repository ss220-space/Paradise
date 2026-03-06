/obj/structure/closet/bluespace
	name = "bluespace closet"
	desc = "A storage unit that moves and stores through the fourth dimension."
	density = FALSE
	icon_state = "bluespace"
	storage_capacity = 60
	ignore_density_closed = TRUE
	pass_flags = PASSDOOR|PASSTABLE|PASSGRILLE|PASSBLOB|PASSMOB|PASSMACHINE|PASSSTRUCTURE|PASSFLAPS|PASSFENCE|PASSVEHICLE|PASSITEM
	var/materials = list(MAT_METAL = 5000, MAT_PLASMA = 2500, MAT_TITANIUM = 500, MAT_BLUESPACE = 500)
	var/transparent = FALSE

/obj/structure/closet/bluespace/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXITED = PROC_REF(on_exited),
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/closet/bluespace/proc/update_transparency()
	var/transparency = FALSE
	for(var/atom/check as anything in loc)
		if(check.density && check != src)
			transparency = TRUE
			break
	transparent = transparency
	update_icon()

/obj/structure/closet/bluespace/update_icon_state()
	icon_state = "[initial(icon_state)][transparent ? "_trans" : ""]"

/obj/structure/closet/bluespace/update_overlays()
	. = list()
	if(!opened)
		if(transparent)
			. += mutable_appearance(icon, "[initial(icon_state)]_door_trans", CLOSET_OLAY_LAYER_DOOR)
		else
			. += mutable_appearance(icon, "[initial(icon_state)]_door", CLOSET_OLAY_LAYER_DOOR)
		if(welded)
			. += mutable_appearance(icon, "welded", CLOSET_OLAY_LAYER_WELDED)
	else
		if(transparent)
			. += mutable_appearance(icon, "[initial(icon_state)]_open_trans", CLOSET_OLAY_LAYER_DOOR)
		else
			. += mutable_appearance(icon, "[initial(icon_state)]_open", CLOSET_OLAY_LAYER_DOOR)

/obj/structure/closet/bluespace/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!transparent && arrived.density && arrived != src)
		transparent = TRUE
		update_icon()

/obj/structure/closet/bluespace/proc/on_exited(datum/source, atom/movable/departed, atom/newLoc)
	SIGNAL_HANDLER

	update_transparency()

/obj/structure/closet/bluespace/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(loc)
		update_transparency()
