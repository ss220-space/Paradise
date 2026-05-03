
/obj/item/chrono_eraser
	name = "Timestream Eradication Device"
	desc = "The result of outlawed time-bluespace research, this device is capable of wiping a being from the timestream. They never are, they never were, they never will be."
	icon = 'icons/obj/chronos.dmi'
	icon_state = "chronobackpack"
	item_state = "backpack"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	slowdown = 1
	actions_types = list(/datum/action/item_action/equip_unequip_TED_Gun)
	var/obj/item/gun/energy/chrono_gun/PA = null
	var/list/erased_minds = list() //a collection of minds from the dead

/obj/item/chrono_eraser/proc/pass_mind(datum/mind/M)
	erased_minds += M

/obj/item/chrono_eraser/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	QDEL_NULL(PA)

/obj/item/chrono_eraser/Destroy()
	QDEL_NULL(PA)
	return ..()

/obj/item/chrono_eraser/ui_action_click(mob/user, datum/action/action, leftclick)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.back == src)
			QDEL_NULL(PA)
			PA = new(user, src)
			user.put_in_hands(PA)

/obj/item/chrono_eraser/item_action_slot_check(slot, mob/user, datum/action/action)
	if(slot == ITEM_SLOT_BACK)
		return TRUE

/obj/structure/chrono_field
	name = "eradication field"
	desc = "An aura of time-bluespace energy."
	icon = 'icons/effects/effects.dmi'
	icon_state = "chronofield"
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	move_resist = INFINITY
	blend_mode = BLEND_ADD
	var/mob/living/captured = null
	var/obj/item/gun/energy/chrono_gun/gun = null
	var/tickstokill = 15
	var/mutable_appearance/mob_underlay
	var/preloaded = 0
	var/RPpos = null

/obj/structure/chrono_field/New(loc, mob/living/target, obj/item/gun/energy/chrono_gun/G)
	if(target && isliving(target) && G)
		target.forceMove(src)
		captured = target
		var/icon/mob_snapshot = getFlatIcon(target)
		var/icon/cached_icon = new()

		for(var/i=1, i<=CHRONO_FRAME_COUNT, i++)
			var/icon/removing_frame = icon('icons/obj/chronos.dmi', "erasing", SOUTH, i)
			var/icon/mob_icon = icon(mob_snapshot)
			mob_icon.Blend(removing_frame, ICON_MULTIPLY)
			cached_icon.Insert(mob_icon, "frame[i]")

		mob_underlay = mutable_appearance(cached_icon, "frame1")
		update_icon(UPDATE_ICON_STATE)

		desc = initial(desc) + span_notice("<br>It appears to contain [target.name].")
	START_PROCESSING(SSobj, src)
	return ..()

/obj/structure/chrono_field/Destroy()
	if(gun && gun.field_check(src))
		gun.field_disconnect(src)
	return ..()

/obj/structure/chrono_field/has_prints()
	return FALSE

/obj/structure/chrono_field/update_icon_state()
	var/ttk_frame = 1 - (tickstokill / initial(tickstokill))
	ttk_frame = clamp(ceil(ttk_frame * CHRONO_FRAME_COUNT), 1, CHRONO_FRAME_COUNT)
	if(ttk_frame != RPpos)
		RPpos = ttk_frame
		mob_underlay.icon_state = "frame[RPpos]"
		underlays = list() //hack: BYOND refuses to update the underlay to match the icon_state otherwise
		underlays += mob_underlay

/obj/structure/chrono_field/process()
	if(captured)
		if(tickstokill > initial(tickstokill))
			for(var/atom/movable/AM in contents)
				AM.forceMove(drop_location())
			qdel(src)
		else if(tickstokill <= 0)
			to_chat(captured, span_boldnotice("As the last essence of your being is erased from time, you begin to re-experience your most enjoyable memory. You feel happy..."))
			var/mob/dead/observer/ghost = captured.ghostize(1)
			if(captured.mind)
				if(ghost)
					ghost.mind = null
				if(gun)
					gun.pass_mind(captured.mind)
			qdel(captured)
			qdel(src)
		else
			captured.Paralyse(8 SECONDS)
			if(captured.loc != src)
				captured.forceMove(src)
			update_icon(UPDATE_ICON_STATE)
			if(gun)
				if(gun.field_check(src))
					tickstokill--
				else
					gun = null
					return .()
			else
				tickstokill++
	else
		qdel(src)

/obj/structure/chrono_field/bullet_act(obj/projectile/P)
	if(istype(P, /obj/projectile/energy/chrono_beam))
		var/obj/projectile/energy/chrono_beam/beam = P
		var/obj/item/gun/energy/chrono_gun/Pgun = beam.gun
		if(Pgun && istype(Pgun))
			Pgun.field_connect(src)
	else
		return 0

/obj/structure/chrono_field/return_obj_air()
	//we always have nominal air and temperature
	RETURN_TYPE(/datum/gas_mixture)
	var/datum/gas_mixture/gas_mixture = new
	gas_mixture.set_oxygen(MOLES_O2STANDARD)
	gas_mixture.set_nitrogen(MOLES_N2STANDARD)
	gas_mixture.set_temperature(T20C)
	return gas_mixture

/obj/structure/chrono_field/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	return FALSE

/obj/structure/chrono_field/singularity_act()
	return

/obj/structure/chrono_field/ex_act()
	return

/obj/structure/chrono_field/blob_act(obj/structure/blob/B)
	return
