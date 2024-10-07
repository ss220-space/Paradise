
/*
	run_armor_check(a,b)
	args
	a:def_zone - What part is getting hit, if null will check entire body
	b:attack_flag - What type of attack, bullet, laser, energy, melee

	Returns
	0 - no block
	1 - halfblock
	2 - fullblock
*/
/mob/living/proc/run_armor_check(def_zone, attack_flag = MELEE, absorb_text, soften_text, armour_penetration, penetrated_text)
	var/armor = getarmor(def_zone, attack_flag)

	//the if "armor" check is because this is used for everything on /living, including humans
	if(armor && armor < 100 && armour_penetration) // Armor with 100+ protection can not be penetrated for admin items
		armor = max(0, armor - armour_penetration)
		if(penetrated_text)
			to_chat(src, "<span class='userdanger'>[penetrated_text]</span>")
		else
			to_chat(src, "<span class='userdanger'>[pluralize_ru(src.gender,"Твоя","Ваша")] броня пробита!</span>")

	if(armor >= 100)
		if(absorb_text)
			to_chat(src, "<span class='userdanger'>[absorb_text]</span>")
		else
			to_chat(src, "<span class='userdanger'>[pluralize_ru(src.gender,"Твоя","Ваша")] броня поглощает удар!</span>")
	else if(armor > 0)
		if(soften_text)
			to_chat(src, "<span class='userdanger'>[soften_text]</span>")
		else
			to_chat(src, "<span class='userdanger'>[pluralize_ru(src.gender,"Твоя","Ваша")] броня смягчает удар!</span>")
	return armor

//if null is passed for def_zone, then this should return something appropriate for all zones (e.g. area effect damage)
/mob/living/proc/getarmor(def_zone, attack_flag)
	return 0

/mob/living/proc/is_mouth_covered(head_only = FALSE, mask_only = FALSE)
	return FALSE

/mob/living/proc/is_eyes_covered(check_glasses = TRUE, check_head = TRUE, check_mask = TRUE)
	return FALSE

/mob/living/bullet_act(var/obj/item/projectile/P, var/def_zone)
	//Armor
	var/armor = run_armor_check(def_zone, P.flag, armour_penetration = P.armour_penetration)
	if(!P.nodamage)
		apply_damage(P.damage, P.damage_type, def_zone, armor)
		if(P.dismemberment)
			check_projectile_dismemberment(P, def_zone)
	return P.on_hit(src, armor, def_zone)

/mob/living/proc/check_projectile_dismemberment(obj/item/projectile/P, def_zone)
	return 0


///As the name suggests, this should be called to apply electric shocks.
/mob/living/proc/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE, jitter_time = 10 SECONDS, stutter_time = 6 SECONDS, stun_duration = 4 SECONDS)
	if(SEND_SIGNAL(src, COMSIG_LIVING_ELECTROCUTE_ACT, shock_damage, source, siemens_coeff, flags) & COMPONENT_LIVING_BLOCK_SHOCK)
		return FALSE
	if(HAS_TRAIT(src, TRAIT_GODMODE))	//godmode
		return FALSE
	shock_damage *= siemens_coeff
	if(!(flags & SHOCK_IGNORE_IMMUNITY))
		if((flags & SHOCK_TESLA) && HAS_TRAIT(src, TRAIT_TESLA_SHOCKIMMUNE))
			return FALSE
		if(HAS_TRAIT(src, TRAIT_SHOCKIMMUNE))
			return FALSE
	if(shock_damage < 1)
		return FALSE
	if(!(flags & SHOCK_ILLUSION))
		apply_damage(shock_damage, BURN, spread_damage = TRUE)
		if(shock_damage > 200)
			playsound(loc, 'sound/effects/eleczap.ogg', 50, 1, -1)
			explosion(loc, -1, 0, 2, 2, cause = "[source] over electrocuted [name]")
	else
		apply_damage(shock_damage, STAMINA)
	if(!(flags & SHOCK_SUPPRESS_MESSAGE))
		visible_message(
			span_danger("[name] получа[pluralize_ru(gender,"ет","ют")] удар током от [source]!"),
			span_userdanger("Вы чувствуете как через Ваше тело проходит электрический разряд!"),
			span_hear("Вы слышите громкий электрический треск."),
		)
	return shock_damage


/mob/living/emp_act(severity)
	..()
	for(var/obj/O in contents)
		O.emp_act(severity)


/obj/item/proc/get_volume_by_throwforce_and_or_w_class()
	if(throwforce && w_class)
		return clamp((throwforce + w_class) * 5, 30, 100)// Add the item's throwforce to its weight class and multiply by 5, then clamp the value between 30 and 100
	else if(w_class)
		return clamp(w_class * 8, 20, 100) // Multiply the item's weight class by 8, then clamp the value between 20 and 100
	else
		return 0


/**
 * This proc handles being hit by a thrown atom.
 */
/mob/living/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(!isitem(AM))
		playsound(loc, 'sound/weapons/genhit.ogg', 50, TRUE, -1) //Item sounds are handled in the item itself
		return ..()

	var/obj/item/thrown_item = AM
	var/zone = ran_zone(BODY_ZONE_CHEST, 65)//Hits a random part of the body, geared towards the chest
	var/nosell_hit = SEND_SIGNAL(thrown_item, COMSIG_MOVABLE_IMPACT_ZONE, src, zone, throwingdatum) // TODO: find a better way to handle hitpush and skipcatch for humans
	if(nosell_hit)
		skipcatch = TRUE
		hitpush = FALSE

	if(blocked)
		return TRUE

	var/mob/thrower = locateUID(thrown_item.thrownby)
	if(thrower)
		add_attack_logs(thrower, src, "Hit with thrown [thrown_item]", !thrown_item.throwforce ? ATKLOG_ALMOSTALL : null) // Only message if the person gets damages
	if(nosell_hit)
		return ..()

	visible_message(span_danger("[capitalize(src.declent_ru(NOMINATIVE))] получа[pluralize_ru(src.gender,"ет","ют")] удар [thrown_item.declent_ru(INSTRUMENTAL)]."),
					span_userdanger("[capitalize(src.declent_ru(NOMINATIVE))] получа[pluralize_ru(src.gender,"ет","ют")] удар [thrown_item.declent_ru(INSTRUMENTAL)]."))

	if(!thrown_item.throwforce)
		return

	var/armor = run_armor_check(zone, MELEE, "Броня защитила [parse_zone(zone)].", "[pluralize_ru(src.gender,"Твоя","Ваша")] броня смягчила удар по [parse_zone(zone)].", thrown_item.armour_penetration) // TODO: перевод зон
	apply_damage(thrown_item.throwforce, thrown_item.damtype, zone, armor, is_sharp(thrown_item), thrown_item)

	if(QDELETED(src)) //Damage can delete the mob.
		return

	return ..()


/**
 * Proc that checks if our mob is strong enough to prevent mecha melee attacks from pushing and paralyzing
 */
/mob/living/proc/is_strong()
	return FALSE


/mob/living/mech_melee_attack(obj/mecha/M)
	if(M.occupant.a_intent == INTENT_HARM)
		if(HAS_TRAIT(M.occupant, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
			to_chat(M.occupant, "<span class='warning'>[pluralize_ru(M.occupant.gender,"Ты не хочешь","Вы не хотите")] навредить живым существам!</span>")
			return
		M.do_attack_animation(src)
		if(M.damtype == "brute" && !is_strong())
			step_away(src,M,15)
		switch(M.damtype)
			if("brute")
				if(!is_strong())
					Paralyse(2 SECONDS)
				take_overall_damage(rand(M.force/2, M.force))
				playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
			if("fire")
				take_overall_damage(0, rand(M.force/2, M.force))
				playsound(src, 'sound/items/welder.ogg', 50, TRUE)
			if("tox")
				M.mech_toxin_damage(src)
			else
				return
		M.occupant_message("<span class='danger'>[pluralize_ru(M.occupant.gender,"Ты","Вы")] ударяе[pluralize_ru(M.occupant.gender,"шь","те")] [src.declent_ru(ACCUSATIVE)].</span>")
		visible_message("<span class='danger'>[capitalize(M.declent_ru(NOMINATIVE))] ударя[pluralize_ru(M.gender,"ет","ют")] [src.declent_ru(ACCUSATIVE)]!</span>", "<span class='userdanger'>[capitalize(M.declent_ru(NOMINATIVE))] ударя[pluralize_ru(M.gender,"ет","ют")] [pluralize_ru(src.gender,"тебя","вас")]!</span>")
		add_attack_logs(M.occupant, src, "Mecha-meleed with [M]")
	else
		if(!is_strong())
			step_away(src,M)
			add_attack_logs(M.occupant, src, "Mecha-pushed with [M]", ATKLOG_ALL)
			M.occupant_message("<span class='warning'>[pluralize_ru(M.occupant.gender,"Ты толкаешь","Вы толкаете")] [src.declent_ru(ACCUSATIVE)] в сторону.</span>")
			visible_message("<span class='warning'>[capitalize(M.declent_ru(NOMINATIVE))] отталкива[pluralize_ru(M.gender,"ет","ют")] [src.declent_ru(ACCUSATIVE)] в сторону.</span>")
		else
			M.occupant_message("<span class='warning'>[pluralize_ru(M.occupant.gender,"Ты пытаешься оттолкнуть","Вы пытаетесь оттолкнуть")] [src.declent_ru(ACCUSATIVE)] в сторону, но это не срабатывает.</span>")
			visible_message("<span class='warning'>[capitalize(M.declent_ru(NOMINATIVE))] безуспешно пытается оттолкнуть [src.declent_ru(ACCUSATIVE)] в сторону.</span>")

//Mobs on Fire
/mob/living/proc/IgniteMob()
	if(fire_stacks > 0 && !on_fire)
		on_fire = TRUE
		visible_message("<span class='warning'>[src.declent_ru(NOMINATIVE)] загора[pluralize_ru(src.gender,"ется","ются")]!</span>", \
						"<span class='userdanger'>[pluralize_ru(src.gender,"Ты загораешься","Вы загораетесь")]!</span>")
		set_light_range(light_range + 3)
		set_light_color("#ED9200")
		throw_alert("fire", /atom/movable/screen/alert/fire)
		update_fire()
		SEND_SIGNAL(src, COMSIG_LIVING_IGNITED)
		return TRUE
	return FALSE


/mob/living/proc/ExtinguishMob()
	if(on_fire)
		on_fire = FALSE
		fire_stacks = 0
		set_light_range(max(0,light_range - 3))
		set_light_color(initial(light_color))
		clear_alert("fire")
		update_fire()


/mob/living/proc/update_fire()
	return

/mob/living/proc/adjust_fire_stacks(add_fire_stacks) //Adjusting the amount of fire_stacks we have on person
	SEND_SIGNAL(src, COMSIG_MOB_ADJUST_FIRE)
	fire_stacks = clamp(fire_stacks + add_fire_stacks, -20, 20)
	if(on_fire && fire_stacks <= 0)
		ExtinguishMob()

/**
 * Burns a mob and slowly puts the fires out. Returns TRUE if the mob is on fire
 */
/mob/living/proc/handle_fire()
	if(fire_stacks < 0) //If we've doused ourselves in water to avoid fire, dry off slowly
		fire_stacks = min(0, fire_stacks + 1)//So we dry ourselves back to default, nonflammable.
	if(!on_fire)
		return FALSE
	if(fire_stacks > 0)
		adjust_fire_stacks(-0.1) //the fire is slowly consumed
		for(var/obj/item/clothing/C in contents)
			C.catch_fire()
	else
		ExtinguishMob()
		return FALSE
	var/datum/gas_mixture/G = loc.return_air() // Check if we're standing in an oxygenless environment
	if(G.oxygen < 1)
		ExtinguishMob() //If there's no oxygen in the tile we're on, put out the fire
		return FALSE
	var/turf/location = get_turf(src)
	location.hotspot_expose(700, 50, 1)
	SEND_SIGNAL(src, COMSIG_LIVING_FIRE_TICK)
	return TRUE

/mob/living/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	adjust_fire_stacks(3)
	IgniteMob()

//Share fire evenly between the two mobs
//Called in MobBump() and Crossed()
/mob/living/proc/spreadFire(mob/living/L)
	if(!istype(L))
		return
	var/L_old_on_fire = L.on_fire

	if(on_fire) //Only spread fire stacks if we're on fire
		fire_stacks /= 2
		L.fire_stacks += fire_stacks
		if(L.IgniteMob())
			add_attack_logs(src, L, "bumped and set on fire")

	if(L_old_on_fire) //Only ignite us and gain their stacks if they were onfire before we bumped them
		L.fire_stacks /= 2
		fire_stacks += L.fire_stacks
		IgniteMob()


/mob/living/water_act(volume, temperature, source, method = REAGENT_TOUCH)
	. = ..()
	adjust_fire_stacks(-(volume * 0.2))

//This is called when the mob is thrown into a dense turf
/mob/living/proc/turf_collision(var/turf/T, var/speed)
	src.take_organ_damage(speed*5)

/mob/living/proc/near_wall(var/direction,var/distance=1)
	var/turf/T = get_step(get_turf(src),direction)
	var/turf/last_turf = src.loc
	var/i = 1

	while(i>0 && i<=distance)
		if(T.density) //Turf is a wall!
			return last_turf
		i++
		last_turf = T
		T = get_step(T,direction)

	return 0


/**
 * Called when a mob is grabbing another mob.
 */
/mob/living/proc/grab(mob/living/target)
	if(!istype(target))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_LIVING_GRAB, target) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return FALSE
	//if(target.check_block(src, 0, "[src]'s grab"))
	//	return FALSE
	target.grabbedby(src)
	return TRUE


/**
 * Called when this mob is grabbed by another mob.
 */
/mob/living/proc/grabbedby(mob/living/grabber, supress_message = FALSE)
	if(grabber == src || anchored || !isturf(grabber.loc) || !(grabber.mobility_flags & MOBILITY_PULL))
		return FALSE

	if(!grabber.pulling || grabber.pulling != src)
		return grabber.start_pulling(src, supress_message = supress_message)

	if(!isnull(grabber.pull_hand) && grabber.pull_hand != PULL_WITHOUT_HANDS && grabber.pull_hand != grabber.hand)
		var/previous_grab_state = grabber.grab_state
		. = grabber.start_pulling(src, supress_message = previous_grab_state)
		if(. && previous_grab_state)	// swapping hand with grab results in the same grab state for another hand
			return grippedby(grabber, grab_state_override = previous_grab_state)
		return .

	if(!(status_flags & CANPUSH) || HAS_TRAIT(src, TRAIT_PUSHIMMUNE))
		if(!supress_message)
			to_chat(grabber, span_warning("Вы не можете усилить хватку над [name]!"))
		return FALSE

	if(grabber.grab_state >= GRAB_AGGRESSIVE && (HAS_TRAIT(grabber, TRAIT_PACIFISM) || GLOB.pacifism_after_gt))
		if(!supress_message)
			to_chat(grabber, span_warning("Вы не хотите навредить [name]!"))
		return FALSE

	return grippedby(grabber)


/// Proc to upgrade a simple pull into a more aggressive grab.
/mob/living/proc/grippedby(mob/living/grabber, grab_state_override)
	if(isnull(grab_state_override) && grabber.grab_state >= grabber.max_grab)
		return FALSE
	if(!isnull(grab_state_override) && grab_state_override > grabber.max_grab)
		return FALSE
	grabber.changeNext_move(CLICK_CD_GRABBING)
	var/sound_to_play = 'sound/weapons/thudswoosh.ogg'
	//if(ishuman(grabber))
	//	var/mob/living/carbon/human/human_grabber = grabber
	//	if(grabber.dna.species.grab_sound)
	//		sound_to_play = grabber.dna.species.grab_sound
	playsound(loc, sound_to_play, 50, TRUE, -1)

	if(isnull(grab_state_override) && grabber.grab_state) //only the first upgrade is instantaneous
		var/old_grab_state = grabber.grab_state
		visible_message(
			span_danger("[grabber.name] начина[pluralize_ru(grabber.gender,"ет","ют")] усиливать хватку над [name]!"),
			span_userdanger("[grabber.name] начина[pluralize_ru(grabber.gender,"ет","ют")] усиливать хватку над Вами!"),
			span_italics("Вы слышите агрессивную возню!"),
			ignored_mobs = grabber,
		)
		to_chat(grabber, span_danger("Вы усиливаете хватку над [name]!"))
		switch(grabber.grab_state)
			if(GRAB_AGGRESSIVE)
				add_attack_logs(grabber, src, "attempted to neck grab", ATKLOG_ALL)
			if(GRAB_NECK)
				add_attack_logs(grabber, src, "attempted to strangle", ATKLOG_ALL)
		if(!do_after(grabber, get_grab_upgrade_time(grabber), src, DA_IGNORE_USER_LOC_CHANGE|DA_IGNORE_TARGET_LOC_CHANGE|DA_IGNORE_HELD_ITEM, extra_checks = CALLBACK(src, PROC_REF(grab_checks_callback), grabber, old_grab_state), max_interact_count = 1, cancel_on_max = TRUE, cancel_message = span_notice("Вы перестали усиливать захват.")))
			return FALSE
		if(!grab_checks_callback(grabber, old_grab_state))
			return FALSE

	grabber.setGrabState(isnull(grab_state_override) ? grabber.grab_state + 1 : grab_state_override)

	switch(grabber.grab_state)
		if(GRAB_AGGRESSIVE)
			var/add_log = ""
			if(HAS_TRAIT(grabber, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
				visible_message(
					span_danger("[grabber.name] крепко сжима[pluralize_ru(grabber.gender,"ет","ют")] [name]!"),
					span_danger("[grabber.name] крепко сжима[pluralize_ru(grabber.gender,"ет","ют")] Вас!"),
					span_italics("Вы слышите агрессивную возню!"),
					ignored_mobs = grabber,
				)
				to_chat(grabber, span_danger("Вы крепко сжимаете [name]!"))
				add_log = " (pacifist)"
			else
				visible_message(
					span_danger("[grabber.name] агрессивно хвата[pluralize_ru(grabber.gender,"ет","ют")] [name]!"),
					span_danger("[grabber.name] агрессивно хвата[pluralize_ru(grabber.gender,"ет","ют")] Вас!"),
					span_italics("Вы слышите агрессивную возню!"),
					ignored_mobs = grabber,
				)
				to_chat(grabber, span_danger("Вы агрессивно хватаете [name]!"))
			add_attack_logs(grabber, src, "grabbed aggressively[add_log]", ATKLOG_ALL)
		if(GRAB_NECK)
			add_attack_logs(grabber, src, "grabbed (neck grab)", ATKLOG_ALL)
			visible_message(
				span_danger("[grabber.name] хвата[pluralize_ru(grabber.gender,"ет","ют")] [name] за шею!"),
				span_userdanger("[grabber.name] хвата[pluralize_ru(grabber.gender,"ет","ют")] Вас за шею!"),
				span_italics("Вы слышите агрессивную возню!"),
				ignored_mobs = grabber,
			)
			to_chat(grabber, span_danger("Вы хватаете [name] за шею!"))
			if(!buckled)
				Move(grabber.loc)
		if(GRAB_KILL)
			add_attack_logs(grabber, src, "strangled (kill grab)", ATKLOG_ALL)
			visible_message(
				span_danger("[grabber.name] душ[pluralize_ru(grabber.gender,"ит","ат")] [name]!"),
				span_userdanger("[grabber.name] душ[pluralize_ru(grabber.gender,"ит","ат")] Вас!"),
				span_italics("Вы слышите агрессивную возню!"),
				ignored_mobs = grabber,
			)
			to_chat(grabber, span_danger("Вы душите [name]!"))
			if(!buckled)
				Move(grabber.loc)
	grabber.set_pull_offsets(src, grabber.grab_state)
	return TRUE


/// Addtitional checks for do_after.
/mob/living/proc/grab_checks_callback(mob/living/grabber, old_grab_state)
	return grabber.pulling && grabber.pulling == src && grabber.grab_state == old_grab_state && isturf(grabber.loc) && isturf(loc)


/// Used to override grab upgrade speed.
/mob/living/proc/get_grab_upgrade_time(mob/living/grabber)
	if(!grabber.mind)
		return GRAB_UPGRADE_TIME
	var/datum/antagonist/vampire/vampire = grabber.mind.has_antag_datum(/datum/antagonist/vampire)
	var/datum/vampire_passive/upgraded_grab/vampire_grab = vampire?.get_ability(/datum/vampire_passive/upgraded_grab)
	if(vampire_grab)
		return vampire_grab.grab_speed
	return isnull(grabber.mind?.martial_art?.grab_speed) ? GRAB_UPGRADE_TIME : grabber.mind.martial_art.grab_speed


/mob/living/attack_slime(mob/living/simple_animal/slime/M)
	if(!SSticker)
		to_chat(M, "[pluralize_ru(M.gender,"Ты не можешь","Вы не можете")] нападать на людей, пока игра не началась.")
		return

	if(M.buckled)
		if(M in buckled_mobs)
			M.Feedstop()
		return // can't attack while eating!

	if(HAS_TRAIT(src, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
		to_chat(M, "<span class='warning'>[pluralize_ru(M.gender,"Ты не хочешь","Вы не хотите")] никому навредить!</span>")
		return FALSE

	if(stat != DEAD)
		add_attack_logs(M, src, "Slime'd")
		M.do_attack_animation(src)
		visible_message("<span class='danger'>[capitalize(M.declent_ru(NOMINATIVE))] поглоща[pluralize_ru(M.gender,"ет","ют")] [src.declent_ru(ACCUSATIVE)]!</span>", "<span class='userdanger'>[M.declent_ru(NOMINATIVE)] поглоща[pluralize_ru(M.gender,"ет","ют")] [pluralize_ru(src.gender,"тебя","вас")]!</span>")
		return TRUE

/mob/living/attack_animal(mob/living/simple_animal/M)
	M.face_atom(src)
	if((M.a_intent == INTENT_HELP && M.ckey) || M.melee_damage_upper == 0)
		if(!M.friendly)
			return FALSE
		M.custom_emote(EMOTE_VISIBLE, "[M.friendly] [src.declent_ru(ACCUSATIVE)].")
		return FALSE
	if(HAS_TRAIT(M, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
		to_chat(M, "<span class='warning'>[pluralize_ru(M.gender,"Ты не хочешь","Вы не хотите")] никому навредить!</span>")
		return FALSE

	if(M.attack_sound)
		playsound(loc, M.attack_sound, 50, 1, 1)
	M.do_attack_animation(src)
	visible_message("<span class='danger'>[capitalize(M.declent_ru(NOMINATIVE))] [M.attacktext] [src.declent_ru(ACCUSATIVE)]!</span>", \
					"<span class='userdanger'>[capitalize(M.declent_ru(NOMINATIVE))] [M.attacktext] [src.declent_ru(ACCUSATIVE)]!</span>")
	add_attack_logs(M, src, "Animal attacked")
	SEND_SIGNAL(src, COMSIG_SIMPLE_ANIMAL_ATTACKEDBY, M)
	return TRUE

/mob/living/attack_larva(mob/living/carbon/alien/larva/L)
	switch(L.a_intent)
		if(INTENT_HELP)
			visible_message("<span class='notice'>[L.declent_ru(NOMINATIVE)] [pluralize_ru(L.gender,"трётся","трутся")] головой о [src.declent_ru(ACCUSATIVE)].</span>")
			return FALSE

		else
			if(HAS_TRAIT(L, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
				to_chat(L, "<span class='warning'>[pluralize_ru(L.gender,"Ты не хочешь","Вы не хотите")] никому навредить!</span>")
				return FALSE

			L.do_attack_animation(src)
			if(prob(90))
				add_attack_logs(L, src, "Larva attacked")
				visible_message("<span class='danger'>[capitalize(L.declent_ru(NOMINATIVE))] куса[pluralize_ru(L.gender,"ет","ют")] [src.declent_ru(ACCUSATIVE)]!</span>", \
						"<span class='userdanger'>[capitalize(L.declent_ru(NOMINATIVE))] куса[pluralize_ru(L.gender,"ет","ют")] [src.declent_ru(ACCUSATIVE)]!</span>")
				playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
				return TRUE
			else
				visible_message("<span class='danger'>[capitalize(L.declent_ru(NOMINATIVE))] пыта[pluralize_ru(L.gender,"ет","ют")]ся укусить [src.declent_ru(ACCUSATIVE)]!</span>", \
					"<span class='userdanger'>[capitalize(L.declent_ru(NOMINATIVE))] пыта[pluralize_ru(L.gender,"ет","ют")]ся укусить [src.declent_ru(ACCUSATIVE)]!</span>")
	return FALSE

/mob/living/attack_alien(mob/living/carbon/alien/humanoid/M)
	switch(M.a_intent)
		if(INTENT_HELP)
			visible_message("<span class='notice'>[M.declent_ru(NOMINATIVE)] глад[pluralize_ru(M.gender,"ит","ят")] [src.declent_ru(ACCUSATIVE)] своей серповидной рукой.</span>")
			return FALSE
		if(INTENT_GRAB)
			grabbedby(M)
			return FALSE
		if(INTENT_HARM)
			if(HAS_TRAIT(M, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
				to_chat(M, "<span class='warning'>[pluralize_ru(M.gender,"Ты","Вы")] не [pluralize_ru(M.gender,"хочешь","хотите")] никому навредить!</span>")
				return FALSE
			M.do_attack_animation(src)
			return TRUE
		if(INTENT_DISARM)
			M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
			return TRUE

/mob/living/proc/cult_self_harm(damage)
	return FALSE

/mob/living/RangedAttack(atom/A, params) //Player firing
	if(HAS_TRAIT(src, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
		return
	if(dirslash_enabled && a_intent != INTENT_HELP)
		var/turf/turf_attacking = get_step(src, get_compass_dir(src, A))
		if(turf_attacking)
			var/mob/living/target = locate() in turf_attacking
			if(target && Adjacent(target))
				changeNext_move(CLICK_CD_MELEE)
				return UnarmedAttack(target, TRUE)
	return ..()

/mob/living/shove_impact(mob/living/target, mob/living/attacker)
	if(body_position == LYING_DOWN)
		return FALSE
	add_attack_logs(attacker, target, "pushed into [src]", ATKLOG_ALL)
	playsound(src, 'sound/weapons/punch1.ogg', 50, 1)
	target.Knockdown(1 SECONDS) // knock them both down
	Knockdown(1 SECONDS)
	return TRUE

