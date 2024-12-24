//I will need to recode parts of this but I am way too tired atm
/obj/structure/blob
	name = "blob"
	icon = 'icons/mob/blob.dmi'
	light_range = 3
	desc = "Толстая стена извивающихся щупалец."
	density = FALSE
	opacity = TRUE
	anchored = TRUE
	pass_flags_self = PASSBLOB
	layer = BELOW_MOB_LAYER
	can_astar_pass = CANASTARPASS_ALWAYS_PROC
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 70)
	creates_cover = TRUE
	obj_flags = BLOCK_Z_OUT_DOWN | BLOCK_Z_IN_UP // stops blob mobs from falling on multiz.
	max_integrity = BLOB_REGULAR_MAX_HP
	/// Multiplies brute damage by this
	var/brute_resist = BLOB_BRUTE_RESIST
	/// Multiplies burn damage by this
	var/fire_resist = BLOB_FIRE_RESIST
	/// how much health this blob regens when pulsed
	var/health_regen = BLOB_REGULAR_HP_REGEN
	/// How many points the blob gets back when it removes a blob of that type. If less than 0, blob cannot be removed.
	var/point_return = 0
	/// If a threshold is reached, resulting in shifting variables
	var/compromised_integrity = FALSE
	/// Blob overmind
	var/mob/camera/blob/overmind
	/// We got pulsed when?
	COOLDOWN_DECLARE(pulse_timestamp)
	/// we got healed when?
	COOLDOWN_DECLARE(heal_timestamp)
	/// Only used by the synchronous mesh strain. If set to true, these blobs won't share or receive damage taken with others.
	var/ignore_syncmesh_share = FALSE
	/// If the blob blocks atmos and heat spread
	var/atmosblock = FALSE

/obj/structure/blob/ComponentInitialize()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/structure/blob/Initialize(mapload, owner_overmind)
	. = ..()
	ADD_TRAIT(src, TRAIT_CHASM_DESTROYED, INNATE_TRAIT)
	GLOB.blobs += src
	if(owner_overmind && isovermind(owner_overmind))
		link_to_overmind(owner_overmind)
	setDir(pick(GLOB.cardinal))
	if(atmosblock)
		air_update_turf(TRUE)
	ConsumeTile()
	update_blob()


/obj/structure/blob/proc/link_to_overmind(mob/camera/blob/owner_overmind)
	overmind = owner_overmind
	overmind.all_blobs += src


/obj/structure/blob/Destroy()
	if(atmosblock)
		atmosblock = FALSE
		air_update_turf(1)
	GLOB.blobs -= src
	SSticker?.mode?.legit_blobs -= src
	if(overmind)
		overmind.all_blobs -= src
		overmind.blobs_legit -= src  //if it was in the legit blobs list, it isn't now
		overmind = null
	if(isturf(loc)) //Necessary because Expand() is screwed up and spawns a blob and then deletes it
		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
	return ..()

/obj/structure/blob/obj_destruction(damage_flag)
	if(overmind)
		overmind.blobstrain.death_reaction(src, damage_flag)
	. = ..()

/obj/structure/blob/Adjacent(atom/neighbour)
	. = ..()
	if(.)
		var/result = 0
		var/direction = get_dir(src, neighbour)
		var/list/dirs = list("[NORTHWEST]" = list(NORTH, WEST), "[NORTHEAST]" = list(NORTH, EAST), "[SOUTHEAST]" = list(SOUTH, EAST), "[SOUTHWEST]" = list(SOUTH, WEST))
		for(var/A in dirs)
			if(direction == text2num(A))
				for(var/B in dirs[A])
					var/C = locate(/obj/structure/blob) in get_step(src, B)
					if(C)
						result++
		. -= result - 1


/obj/structure/blob/BlockSuperconductivity()
	return atmosblock


/obj/structure/blob/CanAtmosPass(turf/T, vertical)
	return !atmosblock


/obj/structure/blob/update_icon() //Updates color based on overmind color if we have an overmind.
	. = ..()
	if(overmind)
		add_atom_colour(overmind.blobstrain.color, FIXED_COLOUR_PRIORITY)
		var/area/A = get_area(src)
		if(!(A.area_flags & BLOBS_ALLOWED))
			add_atom_colour(BlendRGB(overmind.blobstrain.color, COLOR_WHITE, 0.5), FIXED_COLOUR_PRIORITY) //lighten it to indicate an off-station blob
	else
		remove_atom_colour(FIXED_COLOUR_PRIORITY)


/obj/structure/blob/proc/Be_Pulsed()
	if(COOLDOWN_FINISHED(src, pulse_timestamp))
		ConsumeTile()
		if(COOLDOWN_FINISHED(src, heal_timestamp))
			RegenHealth()
			COOLDOWN_START(src, heal_timestamp, 20)
		update_blob()
		COOLDOWN_START(src, pulse_timestamp, 10)
		return TRUE//we did it, we were pulsed!
	return FALSE //oh no we failed


/obj/structure/blob/proc/RegenHealth()
	obj_integrity = min(max_integrity, obj_integrity + health_regen)
	update_blob()


/obj/structure/blob/proc/ConsumeTile()
	for(var/atom/thing in loc)
		if(!thing.can_blob_attack())
			continue
		if(isliving(thing) && overmind && !HAS_TRAIT(thing, TRAIT_BLOB_ALLY)) // Make sure to inject strain-reagents with automatic attacks when needed.
			overmind.blobstrain.attack_living(thing)
			continue // Don't smack them twice though
		thing.blob_act(src)
	if(iswallturf(loc))
		loc.blob_act(src) //don't ask how a wall got on top of the core, just eat it


/obj/structure/blob/proc/blob_attack_animation(atom/A = null, controller) //visually attacks an atom
	var/obj/effect/temp_visual/blob/O = new /obj/effect/temp_visual/blob(src.loc)
	O.setDir(dir)
	var/area/my_area = get_area(src)
	if(controller)
		var/mob/camera/blob/BO = controller
		O.color = BO.blobstrain.color
		if(!(my_area.area_flags & BLOBS_ALLOWED))
			O.color = BlendRGB(O.color, COLOR_WHITE, 0.5) //lighten it to indicate an off-station blob
		O.alpha = 200
	else if(overmind)
		O.color = overmind.blobstrain.color
		if(!(my_area.area_flags & BLOBS_ALLOWED))
			O.color = BlendRGB(O.color, COLOR_WHITE, 0.5) //lighten it to indicate an off-station blob
	if(A)
		O.do_attack_animation(A) //visually attack the whatever
	return O //just in case you want to do something to the animation.


/obj/structure/blob/proc/expand(turf/T = null, controller = null, expand_reaction = 1)
	if(!T)
		var/list/dirs = (is_there_multiz())? GLOB.cardinals_multiz.Copy() : GLOB.cardinal.Copy()
		for(var/i = 1 to dirs.len)
			var/dirn = pick(dirs)
			dirs.Remove(dirn)
			T = get_step_multiz(src, dirn)
			if(!(locate(/obj/structure/blob) in T))
				break
			else
				T = null
	if(!T)
		return

	if(!is_location_within_transition_boundaries(T))
		return
	var/make_blob = TRUE //can we make a blob?

	if(isspaceturf(T) && !(locate(/obj/structure/lattice) in T))
		if(SEND_SIGNAL(T, COMSIG_TRY_CONSUME_TURF) & COMPONENT_CANT_CONSUME)
			make_blob = FALSE
			playsound(src.loc, 'sound/effects/splat.ogg', 50, TRUE) //Let's give some feedback that we DID try to spawn in space, since players are used to it

	ConsumeTile() //hit the tile we're in, making sure there are no border objects blocking us
	if(!T.CanPass(src, get_dir(T, src))) //is the target turf impassable
		if(SEND_SIGNAL(T, COMSIG_TRY_CONSUME_TURF) & COMPONENT_CANT_CONSUME)
			make_blob = FALSE
			T.blob_act(src) //hit the turf if it is
	for(var/atom/A in T)
		if(!A.CanPass(src, get_dir(T, src))) //is anything in the turf impassable
			make_blob = FALSE
		if(!A.can_blob_attack())
			continue
		if(isliving(A) && overmind && !controller) // Make sure to inject strain-reagents with automatic attacks when needed.
			var/mob/living/mob = A
			if(ROLE_BLOB in mob.faction) //no friendly fire
				continue
			overmind.blobstrain.attack_living(mob)
			continue // Don't smack them twice though
		A.blob_act(src) //also hit everything in the turf

	if(make_blob) //well, can we?
		var/obj/structure/blob/B = new /obj/structure/blob/normal(src.loc, (controller || overmind))
		B.set_density(TRUE)
		if(T.Enter(B)) //NOW we can attempt to move into the tile
			B.set_density(initial(B.density))
			B.forceMove(T)
			var/offstation = FALSE
			var/area/Ablob = get_area(B)
			if(Ablob.area_flags & BLOBS_ALLOWED) //Is this area allowed for winning as blob?
				overmind.blobs_legit |= B
				SSticker?.mode?.legit_blobs |= B
			else if(controller)
				B.balloon_alert(overmind, "вне станции, не считается!")
				offstation = TRUE
			B.update_blob()
			var/reaction_result = TRUE
			var/turf/total_turf = get_turf(src)
			if(B.overmind && expand_reaction)
				reaction_result = B.overmind.blobstrain.expand_reaction(src, B, T, controller, offstation)
			if(reaction_result && is_there_multiz() && check_level_trait(T.z, ZTRAIT_DOWN) && T.z != total_turf.z && !isopenspaceturf(T))
				T.ChangeTurf(/turf/simulated/openspace)
			if(reaction_result && is_there_multiz() && check_level_trait(total_turf.z, ZTRAIT_DOWN) && T.z != total_turf.z && !isopenspaceturf(total_turf))
				total_turf.ChangeTurf(/turf/simulated/openspace)
			return B
		else
			blob_attack_animation(T, controller)
			T.blob_act(src) //if we can't move in hit the turf again
			qdel(B) //we should never get to this point, since we checked before moving in. destroy the blob so we don't have two blobs on one tile
			return
	else
		blob_attack_animation(T, controller) //if we can't, animate that we attacked
	return


/obj/structure/blob/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	var/mob/mover_mob = mover
	return checkpass(mover, PASSBLOB) || (istype(mover_mob) && mover_mob.stat == DEAD)


/obj/structure/blob/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	return pass_info.pass_flags == PASSEVERYTHING || (pass_info.pass_flags & PASSBLOB)


/obj/structure/blob/emp_act(severity)
	. = ..()
	// tgstation emp protection
	//if(. & EMP_PROTECT_SELF)
		//return
	if(severity > 0)
		if(overmind)
			overmind.blobstrain.emp_reaction(src, severity)
		if(prob(100 - severity * 30))
			new /obj/effect/temp_visual/emp(get_turf(src))


/obj/structure/blob/tesla_act(power)
	if(overmind)
		if(overmind.blobstrain.tesla_reaction(src, power))
			take_damage(power * 1.25e-3, BURN, ENERGY)
	else
		take_damage(power * 1.25e-3, BURN, ENERGY)
	power -= power * 2.5e-3 //You don't get to do it for free
	return ..() //You don't get to do it for free


/obj/structure/blob/blob_act(obj/structure/blob/B)
	return


/obj/structure/blob/extinguish()
	. = ..()
	if(overmind)
		overmind.blobstrain.extinguish_reaction(src)


/obj/structure/blob/hit_by_thrown_carbon(mob/living/carbon/human/C, datum/thrownthing/throwingdatum, damage, mob_hurt, self_hurt)
	damage *= 0.25 // Lets not have sorium be too much of a blender / rapidly kill itself
	return ..()


/obj/structure/blob/attack_animal(mob/living/simple_animal/M)
	if(ROLE_BLOB in M.faction) //sorry, but you can't kill the blob as a blobbernaut
		to_chat(M, span_danger("Вы не можете навредить структурам блоба"))
		return
	..()


/obj/structure/blob/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = NONE)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, 'sound/effects/attackblob.ogg', 50, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)


/obj/structure/blob/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	switch(damage_type)
		if(BRUTE)
			damage_amount *= brute_resist
		if(BURN)
			damage_amount *= fire_resist
		else
			return 0
	var/armor_protection = 0
	if(damage_flag)
		armor_protection = armor.getRating(damage_flag)
	damage_amount = round(damage_amount * (100 - armor_protection)*0.01, 0.1)
	if(overmind && damage_flag)
		damage_amount = overmind.blobstrain.damage_reaction(src, damage_amount, damage_type, damage_flag)
	return damage_amount


/obj/structure/blob/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	if(QDELETED(src))
		return
	. = ..()
	if(. && obj_integrity > 0)
		update_blob()


/obj/structure/blob/has_prints()
	return FALSE

/obj/structure/blob/proc/update_state()
	return

/obj/structure/blob/proc/update_blob()
	update_state()
	update_appearance()

/obj/structure/blob/proc/Life()
	return

/obj/structure/blob/proc/run_action()
	return FALSE

/obj/structure/blob/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	arrived.blob_act(src)


/obj/structure/blob/proc/change_to(type, controller, point_return = 0)
	if(!ispath(type))
		CRASH("change_to(): invalid type for blob")
	var/obj/structure/blob/B = new type(src.loc, controller)
	B.update_blob()
	B.setDir(dir)
	B.point_return += point_return
	qdel(src)
	return B


/obj/structure/blob/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_ANALYZER)
		user.changeNext_move(CLICK_CD_MELEE)
		to_chat(user, "<b>Анализатор подает один звуковой сигнал, затем сообщает:</b><br>")
		SEND_SOUND(user, sound('sound/machines/ping.ogg'))
		if(overmind)
			to_chat(user, "<b>Прогресс Критической Массы:</b> [span_notice("[TOTAL_BLOB_MASS]/[NEEDED_BLOB_MASS].")]")
			to_chat(user, chemeffectreport(user).Join("\n"))
		else
			to_chat(user, "<b>Ядро блоба нейтрализовано. Критическая масса более не достижима.</b>")
		to_chat(user, typereport(user).Join("\n"))
		return ATTACK_CHAIN_PROCEED_SUCCESS
	else
		return ..()


/obj/structure/blob/examine(mob/user)
	. = ..()
	var/datum/atom_hud/hud_to_check = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	if(user.research_scanner || hud_to_check.hudusers[user])
		. += "<b>Ваш HUD отображает обширный отчет...</b><br>"
		if(overmind)
			. += overmind.blobstrain.examine(user)
		else
			. += "<b>Ядро блоба нейтрализовано. Критическая масса более не достижима.</b>"
		. += chemeffectreport(user)
		. += typereport(user)
	else
		if((user == overmind || isobserver(user)) && overmind)
			. += overmind.blobstrain.examine(user)
		. += "Кажется, он состоит из [get_chem_name()]."


/obj/structure/blob/proc/scannerreport()
	return "Обычная плитка. Похоже, кто-то забыл переопределить этот процесс, сообщите администратору и составьте баг-репорт."



/obj/structure/blob/proc/chemeffectreport(mob/user)
	RETURN_TYPE(/list)
	. = list()
	if(overmind)
		. += list("<b>Материал: <font color=\"[overmind.blobstrain.color]\">[overmind.blobstrain.name]</font>[span_notice(".")]</b>",
		"<b>Эффект материала:</b> [span_notice("[overmind.blobstrain.analyzerdescdamage]")]",
		"<b>Свойства материала:</b> [span_notice("[overmind.blobstrain.analyzerdesceffect || "N/A"]")]")
	else
		. += "<b>Материал не найден!</b>"

/obj/structure/blob/proc/typereport(mob/user)
	RETURN_TYPE(/list)
	return list("<b>Тип плитки:</b> [span_notice("[uppertext(initial(name))]")]",
							"<b>Здоровье:</b> [span_notice("[obj_integrity]/[max_integrity]")]",
							"<b>Эффекты:</b> [span_notice("[scannerreport()]")]")


/obj/structure/blob/proc/get_chem_name()
	if(overmind)
		return overmind.blobstrain.name
	return "какая-то органическая материя"


/obj/structure/blob/proc/get_chem_desc()
	if(overmind)
		return overmind.blobstrain.description
	return "что-то неизвестное"

