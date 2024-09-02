//Shared Bag

//Internal
/obj/item/storage/backpack/shared
	name = "paradox bag"
	desc = "Somehow, it's in two places at once."
	max_combined_w_class = 60
	max_w_class = WEIGHT_CLASS_NORMAL
	cant_hold = list(/obj/item/storage/backpack/shared)


/obj/item/storage/backpack/shared/can_be_inserted(obj/item/shared_storage/I, stop_messages = FALSE)
	// basically we cannot put one bag in the storage if another one is already there
	if(istype(I) && I.bag && I.bag == src && I.twin_storage && I.twin_storage.loc == src)
		if(!stop_messages)
			to_chat(usr, span_warning("Yo dawg, and how are you going to do it?"))
		return FALSE
	return ..()


//External
/obj/item/shared_storage
	name = "paradox bag"
	desc = "Somehow, it's in two places at once."
	icon = 'icons/obj/storage.dmi'
	icon_state = "cultpack"
	slot_flags = ITEM_SLOT_BACK
	resistance_flags = INDESTRUCTIBLE
	/// Our shared inventory space
	var/obj/item/storage/backpack/shared/bag
	/// Our evil clone
	var/obj/item/shared_storage/twin_storage


/obj/item/shared_storage/Initialize(mapload, twin_storage_init = FALSE)
	. = ..()
	if(twin_storage_init)
		return .
	bag = new(src)
	twin_storage = new(loc, TRUE)
	twin_storage.bag = bag
	twin_storage.twin_storage = src	// ~Xzibit


/obj/item/shared_storage/Destroy()
	if(!QDELETED(twin_storage))
		bag = null
		twin_storage.twin_storage = null
	else
		QDEL_NULL(bag)
	twin_storage = null
	return ..()


/obj/item/shared_storage/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(!bag)
		return ATTACK_CHAIN_PROCEED
	if(loc != user)
		if(user.s_active == bag)
			user.s_active.close(user)
		return ATTACK_CHAIN_PROCEED
	if(bag.loc != user)
		bag.forceMove(user)
	bag.attackby(I, user, params)
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/item/shared_storage/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	if(user.s_active == bag)
		user.s_active.close(user)


/obj/item/shared_storage/proc/open_bag(mob/user)
	add_fingerprint(user)
	if(!bag)
		return
	if(loc != user || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		if(user.s_active == bag)
			user.s_active.close(user)
		return
	if(bag.loc != user)
		bag.forceMove(user)
	bag.attack_hand(user)


/obj/item/shared_storage/attack_self(mob/living/carbon/user)
	if(!bag || !iscarbon(user) || !user.is_in_hands(src))
		return ..()

	open_bag(user)


/obj/item/shared_storage/AltClick(mob/user)
	if(!bag || !iscarbon(user) || loc != user)
		return ..()

	open_bag(user)



/obj/item/shared_storage/attack_hand(mob/living/carbon/user)
	if(!iscarbon(user) || !bag || loc != user)
		return ..()

	open_bag(user)


//Book of Babel

/obj/item/book_of_babel
	name = "Book of Babel"
	desc = "An ancient tome written in countless tongues."
	icon = 'icons/obj/library.dmi'
	icon_state = "book1"
	w_class = 2

/obj/item/book_of_babel/attack_self(mob/user)
	to_chat(user, "You flip through the pages of the book, quickly and conveniently learning every language in existence. Somewhat less conveniently, the aging book crumbles to dust in the process. Whoops.")
	user.grant_all_babel_languages()
	new /obj/effect/decal/cleanable/ash(get_turf(user))
	qdel(src)

//Potion of Flight: as we do not have the "Angel" species this currently does not work.

/obj/item/reagent_containers/glass/bottle/potion
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "potionflask"

/obj/item/reagent_containers/glass/bottle/potion/flight
	name = "strange elixir"
	desc = "A flask with an almost-holy aura emitting from it. The label on the bottle says: 'erqo'hyy tvi'rf lbh jv'atf'."
	list_reagents = list("flightpotion" = 5)

/obj/item/reagent_containers/glass/bottle/potion/update_icon_state()
	if(reagents.total_volume)
		icon_state = "potionflask"
	else
		icon_state = "potionflask_empty"

/datum/reagent/flightpotion
	name = "Flight Potion"
	id = "flightpotion"
	description = "Strange mutagenic compound of unknown origins."
	reagent_state = LIQUID
	color = "#FFEBEB"

/datum/reagent/flightpotion/reaction_mob(mob/living/M, method = REAGENT_TOUCH, reac_volume, show_message = 1)
	to_chat(M, "<span class='warning'>This item is currently non-functional.</span>")
	/*if(ishuman(M) && M.stat != DEAD)
		var/mob/living/carbon/human/H = M
		if(!ishumanbasic(H) || reac_volume < 5) // implying xenohumans are holy
			if(method == INGEST && show_message)
				to_chat(H, "<span class='notice'><i>You feel nothing but a terrible aftertaste.</i></span>")
			return ..()

		to_chat(H, "<span class='userdanger'>A terrible pain travels down your back as wings burst out!</span>")
		H.set_species(/datum/species/angel)
		playsound(H.loc, 'sound/items/poster_ripped.ogg', 50, 1, -1)
		H.adjustBruteLoss(20)
		H.emote("scream")
	..()*/

/obj/item/jacobs_ladder
	name = "jacob's ladder"
	desc = "A celestial ladder that violates the laws of physics."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder"

/obj/item/jacobs_ladder/attack_self(mob/user)
	var/turf/T = get_turf(src)
	var/ladder_x = T.x
	var/ladder_y = T.y
	to_chat(user, "<span class='notice'>You unfold the ladder. It extends much farther than you were expecting.</span>")
	var/last_ladder = null
	for(var/i in 1 to world.maxz)
		if(is_admin_level(i) || is_away_level(i) || is_taipan(i))
			continue
		var/turf/T2 = locate(ladder_x, ladder_y, i)
		var/area/new_area = get_area(T2)
		if(new_area.tele_proof)
			continue
		last_ladder = new /obj/structure/ladder/unbreakable/jacob(T2, null, last_ladder)
	qdel(src)

// Inherit from unbreakable but don't set ID, to suppress the default Z linkage
/obj/structure/ladder/unbreakable/jacob
	name = "jacob's ladder"
	desc = "An indestructible celestial ladder that violates the laws of physics."

//Boat

/obj/vehicle/lavaboat
	name = "lava boat"
	desc = "A boat used for traversing lava."
	icon_state = "goliath_boat"
	icon = 'icons/obj/lavaland/dragonboat.dmi'
	layer = ABOVE_MOB_LAYER
	key_type = /obj/item/oar
	key_in_hands = TRUE
	resistance_flags = LAVA_PROOF | FIRE_PROOF


/obj/vehicle/lavaboat/relaymove(mob/user, direction)
	if(!COOLDOWN_FINISHED(src, vehicle_move_cooldown))
		return FALSE
	//We can move from land to lava, or lava to land, but not from land to land
	if(!istype(get_step(src, direction), /turf/simulated/floor/lava) && !istype(get_turf(src), /turf/simulated/floor/lava))
		to_chat(user, span_warning("You cannot traverse futher!"))
		COOLDOWN_START(src, vehicle_move_cooldown, 0.5 SECONDS)
		return FALSE
	return ..()


/obj/vehicle/lavaboat/handle_vehicle_layer()
	return


/obj/item/oar
	name = "oar"
	icon = 'icons/obj/vehicles/vehicles.dmi'
	icon_state = "oar"
	item_state = "rods"
	desc = "Not to be confused with the kind Research hassles you for."
	force = 12
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = LAVA_PROOF | FIRE_PROOF

/datum/crafting_recipe/oar
	name = "goliath bone oar"
	result = /obj/item/oar
	reqs = list(/obj/item/stack/sheet/bone = 2)
	time = 15
	category = CAT_PRIMAL

/datum/crafting_recipe/boat
	name = "goliath hide boat"
	result = /obj/vehicle/lavaboat
	reqs = list(/obj/item/stack/sheet/animalhide/goliath_hide = 3)
	time = 50
	category = CAT_PRIMAL

//Dragon Boat

/obj/item/ship_in_a_bottle
	name = "ship in a bottle"
	desc = "A tiny ship inside a bottle."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "ship_bottle"

/obj/item/ship_in_a_bottle/attack_self(mob/user)
	to_chat(user, "You're not sure how they get the ships in these things, but you're pretty sure you know how to get it out.")
	playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, 1)
	new /obj/vehicle/lavaboat/dragon(get_turf(src))
	qdel(src)

/obj/vehicle/lavaboat/dragon
	name = "mysterious boat"
	desc = "This boat moves where you will it, without the need for an oar."
	key_type = null
	key_in_hands = FALSE
	icon_state = "dragon_boat"
	generic_pixel_y = 2
	generic_pixel_x = 1
	vehicle_move_delay = 0.25 SECONDS

//Wisp Lantern
/obj/item/wisp_lantern
	name = "spooky lantern"
	desc = "This lantern gives off no light, but is home to a friendly wisp."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "lantern-blue"
	item_state = "lantern"
	light_range = 7
	var/obj/effect/wisp/wisp
	var/sight_flags = SEE_MOBS
	var/lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	light_system = MOVABLE_LIGHT
	light_on = FALSE



/obj/item/wisp_lantern/update_icon_state()
	if(!wisp)
		icon_state = "lantern"
		return
	icon_state = "lantern[wisp.loc == src ? "-blue" : ""]"


/obj/item/wisp_lantern/attack_self(mob/user)
	if(!wisp)
		to_chat(user, "<span class='warning'>The wisp has gone missing!</span>")
		update_icon(UPDATE_ICON_STATE)
		return

	if(wisp.loc == src)
		RegisterSignal(user, COMSIG_MOB_UPDATE_SIGHT, PROC_REF(update_user_sight))

		to_chat(user, "<span class='notice'>You release the wisp. It begins to bob around your head.</span>")
		wisp.forceMove(user)
		update_icon(UPDATE_ICON_STATE)
		INVOKE_ASYNC(wisp, TYPE_PROC_REF(/atom/movable, orbit), user, 20)
		set_light_on(FALSE)

		user.update_sight()
		to_chat(user, "<span class='notice'>The wisp enhances your vision.</span>")

		SSblackbox.record_feedback("tally", "wisp_lantern", 1, "Freed") // freed
	else
		UnregisterSignal(user, COMSIG_MOB_UPDATE_SIGHT)

		to_chat(user, "<span class='notice'>You return the wisp to the lantern.</span>")
		wisp.stop_orbit()
		wisp.forceMove(src)
		set_light_on(TRUE)

		user.update_sight()
		to_chat(user, "<span class='notice'>Your vision returns to normal.</span>")

		update_icon(UPDATE_ICON_STATE)
		SSblackbox.record_feedback("tally", "wisp_lantern", 1, "Returned") // returned

/obj/item/wisp_lantern/Initialize(mapload)
	. = ..()
	wisp = new(src)
	update_icon(UPDATE_ICON_STATE)

/obj/item/wisp_lantern/Destroy()
	if(wisp)
		if(wisp.loc == src)
			qdel(wisp)
		else
			wisp.visible_message("<span class='notice'>[wisp] has a sad feeling for a moment, then it passes.</span>")
	return ..()

/obj/item/wisp_lantern/proc/update_user_sight(mob/user)
	user.add_sight(sight_flags)
	if(!isnull(lighting_alpha))
		user.lighting_alpha = min(user.lighting_alpha, lighting_alpha)

/obj/effect/wisp
	name = "friendly wisp"
	desc = "Happy to light your way."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "orb"
	light_range = 7
	layer = ABOVE_ALL_MOB_LAYER

//Red/Blue Cubes
/obj/item/warp_cube
	name = "blue cube"
	desc = "A mysterious blue cube."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "blue_cube"
	var/obj/item/warp_cube/linked

/obj/item/warp_cube/Destroy()
	if(linked)
		linked.linked = null
		linked = null
	return ..()

/obj/item/warp_cube/attack_self(mob/user)
	if(!linked)
		to_chat(user, "[src] fizzles uselessly.")
		return

	if(is_in_teleport_proof_area(user) || is_in_teleport_proof_area(linked))
		to_chat(user, "<span class='warning'>[src] sparks and fizzles.</span>")
		return
	if(do_after(user, 1.5 SECONDS, user))
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(1, 0, user.loc)
		smoke.start()

		user.forceMove(get_turf(linked))
		SSblackbox.record_feedback("tally", "warp_cube", 1, type)

		var/datum/effect_system/smoke_spread/smoke2 = new
		smoke2.set_up(1, 0, user.loc)
		smoke2.start()
	else
		to_chat(user, "<span class='notice'>You need to hold still to use [src].</span>")


/obj/item/warp_cube/red
	name = "red cube"
	desc = "A mysterious red cube."
	icon_state = "red_cube"

/obj/item/warp_cube/red/New()
	..()
	if(!linked)
		var/obj/item/warp_cube/blue = new(src.loc)
		linked = blue
		blue.linked = src

//Meat Hook

/obj/item/gun/magic/hook
	name = "meat hook"
	desc = "Mid or feed."
	ammo_type = /obj/item/ammo_casing/magic/hook
	icon_state = "hook"
	item_state = "chain"
	fire_sound = 'sound/weapons/batonextend.ogg'
	max_charges = 1
	item_flags = NOBLUDGEON
	force = 18

/obj/item/ammo_casing/magic/hook
	name = "hook"
	desc = "a hook."
	projectile_type = /obj/item/projectile/hook
	caliber = "hook"
	icon_state = "hook"
	muzzle_flash_effect = null

/obj/item/projectile/hook
	name = "hook"
	icon_state = "hook"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	pass_flags = PASSTABLE
	damage = 25
	armour_penetration = 100
	damage_type = BRUTE
	hitsound = 'sound/effects/splat.ogg'
	weaken = 2 SECONDS

/obj/item/projectile/hook/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "chain", time = INFINITY, maxdistance = INFINITY, beam_sleep_time = 1)
	..()
	//TODO: root the firer until the chain returns

/obj/item/projectile/hook/on_hit(atom/target)
	. = ..()
	if(isliving(target))
		var/turf/firer_turf = get_turf(firer)
		var/mob/living/L = target
		if(!L.anchored && L.loc)
			L.visible_message("<span class='danger'>[L] is snagged by [firer]'s hook!</span>")
			ADD_TRAIT(L, TRAIT_UNDENSE, UNIQUE_TRAIT_SOURCE(src)) // Ensures the hook does not hit the target multiple times
			L.forceMove(firer_turf)
			REMOVE_TRAIT(L, TRAIT_UNDENSE, UNIQUE_TRAIT_SOURCE(src))

/obj/item/projectile/hook/Destroy()
	QDEL_NULL(chain)
	return ..()


//Immortality Talisman
/obj/item/immortality_talisman
	name = "Immortality Talisman"
	desc = "A dread talisman that can render you completely invulnerable."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "talisman"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	actions_types = list(/datum/action/item_action/immortality)
	COOLDOWN_DECLARE(last_used_immortality_talisman)


/datum/action/item_action/immortality
	name = "Immortality"


/obj/item/immortality_talisman/Destroy(force)
	if(force)
		. = ..()
	else
		return QDEL_HINT_LETMELIVE


/obj/item/immortality_talisman/attack_self(mob/user)
	if(!COOLDOWN_FINISHED(src, last_used_immortality_talisman))
		to_chat(user, span_warning("[src] is still recharging."))
		return

	var/turf/source_turf = get_turf(src)
	if(!source_turf)
		return

	COOLDOWN_START(src, last_used_immortality_talisman, 60 SECONDS)
	SSblackbox.record_feedback("amount", "immortality_talisman_uses", 1)
	user.visible_message(span_danger("[user] vanishes from reality, leaving a a hole in [user.p_their()] place!"))

	var/obj/effect/immortality_talisman/effect = new(source_turf)
	effect.name = "hole in reality"
	effect.desc = "It's shaped an awful lot like [user.name]."
	effect.setDir(user.dir)
	user.forceMove(effect)
	ADD_TRAIT(user, TRAIT_NO_TRANSFORM, UNIQUE_TRAIT_SOURCE(src))
	user.status_flags |= GODMODE

	addtimer(CALLBACK(src, PROC_REF(reappear), user, effect), 10 SECONDS)


/obj/item/immortality_talisman/proc/reappear(mob/user, obj/effect/immortality_talisman/effect)
	if(QDELETED(src) || QDELETED(user) || QDELETED(effect))
		return

	var/turf/effect_turf = get_turf(effect)
	if(!effect_turf)
		stack_trace("[effect] is outside of the turf contents")
		return

	user.status_flags &= ~GODMODE
	REMOVE_TRAIT(user, TRAIT_NO_TRANSFORM, UNIQUE_TRAIT_SOURCE(src))
	user.forceMove(effect_turf)
	user.visible_message(span_danger("[user] pops back into reality!"))
	effect.can_destroy = TRUE

	if(length(effect.contents))
		for(var/obj/atom as anything in effect.contents)	// Since we are using `as anything` this loop will pickup every atom in contents
			if(QDELETED(atom))
				continue
			atom.loc = effect_turf

	qdel(effect)


/obj/effect/immortality_talisman
	icon_state = "blank"
	icon = 'icons/effects/effects.dmi'
	var/can_destroy = FALSE


/obj/effect/immortality_talisman/attackby(obj/item/I, mob/user, params)
	return ATTACK_CHAIN_PROCEED


/obj/effect/immortality_talisman/ex_act()
	return


/obj/effect/immortality_talisman/singularity_act()
	return


/obj/effect/immortality_talisman/singularity_pull()
	return 0


/obj/effect/immortality_talisman/Destroy(force)
	if(!can_destroy && !force)
		return QDEL_HINT_LETMELIVE
	else
		. = ..()
