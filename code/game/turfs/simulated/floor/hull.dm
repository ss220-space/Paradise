/turf/simulated/floor/engine/hull
	name = "exterior hull plating"
	desc = "Sturdy exterior hull plating that separates you from the uncaring vacuum of space."
	explosion_vertical_block = 2
	icon_state = "regular_hull"
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/engine/hull/rcd_deconstruct_act(mob/user, obj/item/rcd/our_rcd)
	to_chat(user, "<span class='warning'>The flooring is too thick to be regularly deconstructed!</span>")
	return RCD_ACT_FAILED

/// RCD-immune plating generated only by shuttle code for shuttle ceilings on multi-z maps, should not be mapped in or creatable in any other way
/turf/simulated/floor/engine/hull/ceiling
	name = "shuttle ceiling plating"
	var/old_turf_type = /turf/simulated/openspace // set to this one, if getting oldtype got ruined somehow

/turf/simulated/floor/engine/hull/ceiling/AfterChange(ignore_air, keep_cabling, oldType)
	. = ..()
	old_turf_type = oldType

/turf/simulated/floor/engine/hull/reinforced
	name = "exterior reinforced hull plating"
	desc = "Extremely sturdy exterior hull plating that separates you from the uncaring vacuum of space."
	explosion_vertical_block = 3
	icon_state = "reinforced_hull"
	heat_capacity = INFINITY
