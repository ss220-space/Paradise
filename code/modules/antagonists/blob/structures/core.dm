/obj/structure/blob/special/core
	name = "blob core"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blank_blob"
	desc = "Огромная пульсирующая желтая масса."
	max_integrity = BLOB_CORE_MAX_HP
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 90)
	explosion_block = 6
	explosion_vertical_block = 5
	point_return = BLOB_REFUND_CORE_COST
	fire_resist = BLOB_CORE_FIRE_RESIST
	health_regen = BLOB_CORE_HP_REGEN
	resistance_flags = LAVA_PROOF
	strong_reinforce_range = BLOB_CORE_STRONG_REINFORCE_RANGE
	reflector_reinforce_range = BLOB_CORE_REFLECTOR_REINFORCE_RANGE
	claim_range = BLOB_CORE_CLAIM_RANGE
	pulse_range = BLOB_CORE_PULSE_RANGE
	expand_range = BLOB_CORE_EXPAND_RANGE
	ignore_syncmesh_share = TRUE
	COOLDOWN
	var/overmind_get_delay = 0 // we don't want to constantly try to find an overmind, do it every 5 minutes
	var/is_offspring = null
	var/selecting = 0


/obj/structure/blob/special/core/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/stationloving, FALSE, TRUE)


/obj/structure/blob/special/core/Initialize(mapload, client/new_overmind = null, offspring)
	GLOB.blob_cores += src
	START_PROCESSING(SSobj, src)
	GLOB.poi_list |= src
	update_blob() //so it atleast appears
	if(!overmind)
		create_overmind(new_overmind)
	is_offspring = offspring
	if(overmind)
		overmind.blobstrain.on_gain()
		update_blob()
	return ..()


/obj/structure/blob/special/core/Destroy()
	GLOB.blob_cores -= src
	if(overmind)
		overmind.blob_core = null
		overmind = null
	SSticker?.mode?.blob_died()
	STOP_PROCESSING(SSobj, src)
	GLOB.poi_list.Remove(src)
	for(var/atom/movable/atom as anything in contents)
		if(atom && !QDELETED(atom) && istype(atom))
			atom.forceMove(get_turf(src))
			atom.throw_at(get_edge_target_turf(src, pick(GLOB.alldirs)), 6, 5, src, TRUE, FALSE, null, 3)
	return ..()

/obj/structure/blob/special/core/scannerreport()
	return "Управляет расширением блоба, постепенно расширяется и поддерживает близлежащие споры и блобернаутов."

/obj/structure/blob/special/core/update_overlays()
	. = ..()
	var/mutable_appearance/blob_overlay = mutable_appearance('icons/mob/blob.dmi', "blob")
	if(overmind)
		blob_overlay.color = overmind.blobstrain.color
	. += blob_overlay
	. += mutable_appearance('icons/mob/blob.dmi', "blob_core_overlay")
	if(blocks_emissive)
		add_overlay(get_emissive_block())

/obj/structure/blob/special/core/update_icon()
	. = ..()
	color = null

/obj/structure/blob/special/core/ex_act(severity, target)
	var/damage = 10 * (severity + 1) //remember, the core takes half brute damage, so this is 20/15/10 damage based on severity
	take_damage(damage, BRUTE, BOMB, 0)
	return TRUE


/obj/structure/blob/special/core/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, overmind_reagent_trigger = 1)
	. = ..()
	if(obj_integrity > 0)
		if(overmind) //we should have an overmind, but...
			overmind.update_health_hud()

/obj/structure/blob/special/core/RegenHealth()
	return // Don't regen, we handle it in Life()

/obj/structure/blob/special/core/process(seconds_per_tick)
	if(QDELETED(src))
		return
	if(!overmind)
		create_overmind()
	if(overmind)
		overmind.blobstrain.core_process()
		overmind.update_health_hud()
	pulse_area(overmind, claim_range, pulse_range, expand_range)
	reinforce_area(seconds_per_tick)
	..()


/obj/structure/blob/special/core/proc/create_overmind(client/new_overmind, override_delay)
	if(overmind_get_delay > world.time && !override_delay)
		return

	overmind_get_delay = world.time + 5 MINUTES

	if(overmind)
		qdel(overmind)
	if(new_overmind)
		get_new_overmind(new_overmind)
	else
		INVOKE_ASYNC(src, PROC_REF(get_new_overmind))


/obj/structure/blob/special/core/proc/get_new_overmind(client/new_overmind)
	var/mob/C = null
	var/list/candidates = list()
	if(!new_overmind)
		// sendit
		if(is_offspring)
			candidates = SSghost_spawns.poll_candidates("Вы хотите поиграть за потомка блоба?", ROLE_BLOB, TRUE, source = src)
		else
			candidates = SSghost_spawns.poll_candidates("Вы хотите поиграть за блоба?", ROLE_BLOB, TRUE, source = src)

		if(length(candidates))
			C = pick(candidates)
	else
		C = new_overmind

	if(C && !QDELETED(src))
		var/mob/camera/blob/B = new(loc, src)
		B.blob_core = src
		B.mind_initialize()
		B.key = C.key
		overmind = B
		B.is_offspring = is_offspring
		addtimer(CALLBACK(src, PROC_REF(add_datum_if_not_exist)), TIME_TO_ADD_OM_DATUM)
		log_game("[B.key] has become Blob [is_offspring ? "offspring" : ""]")


/obj/structure/blob/special/core/proc/add_datum_if_not_exist()
	if(!overmind.mind.has_antag_datum(/datum/antagonist/blob_overmind))
		var/datum/antagonist/blob_overmind/overmind_datum = new
		overmind_datum.add_to_mode = TRUE
		overmind_datum.is_offspring = is_offspring
		if(overmind.blobstrain)
			overmind_datum.strain = overmind.blobstrain
		overmind.mind.add_antag_datum(overmind_datum)

/obj/structure/blob/special/core/proc/lateblobtimer()
	addtimer(CALLBACK(src, PROC_REF(lateblobcheck)), 50)

/obj/structure/blob/special/core/proc/lateblobcheck()
	if(overmind)
		overmind.add_points(BLOB_BONUS_POINTS)
		if(!overmind.mind)
			log_debug("/obj/structure/blob/core/proc/lateblobcheck: Blob core lacks a overmind.mind.")
	else
		log_debug("/obj/structure/blob/core/proc/lateblobcheck: Blob core lacks an overmind.")

/obj/structure/blob/special/core/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer)
	if(overmind && is_station_level(new_turf?.z))
		overmind.forceMove(get_turf(src))
	return ..()
