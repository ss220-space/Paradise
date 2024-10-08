/mob/living/carbon/Initialize(mapload)
	. = ..()
	GLOB.carbon_list += src


/mob/living/carbon/Destroy()
	// This clause is here due to items falling off from limb deletion
	for(var/obj/item in get_all_slots())
		temporarily_remove_item_from_inventory(item)
		qdel(item)
	QDEL_LIST(internal_organs)
	QDEL_LIST(stomach_contents)
	QDEL_LIST(processing_patches)
	var/mob/living/simple_animal/borer/B = has_brain_worms()
	if(B)
		B.leave_host()
		qdel(B)
	GLOB.carbon_list -= src
	return ..()


/mob/living/carbon/handle_atom_del(atom/A)
	LAZYREMOVE(processing_patches, A)
	return ..()


/mob/living/carbon/blob_act(obj/structure/blob/B)
	if(stat == DEAD)
		return
	else
		show_message("<span class='userdanger'>Блоб атакует!</span>")
		adjustBruteLoss(10)


/mob/living/carbon/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	. = ..()
	if(.)
		if(HAS_TRAIT(src, TRAIT_FAT) && m_intent == MOVE_INTENT_RUN && bodytemperature <= 360)
			adjust_bodytemperature(2)

		// Moving around increases germ_level faster
		if(germ_level < GERM_LEVEL_MOVE_CAP && prob(8))
			germ_level++

#define STOMACH_ATTACK_DELAY 4

/mob/living/carbon/relaymove(mob/user, direction)
	if(LAZYLEN(stomach_contents))
		if(user in stomach_contents)
			if(last_stomach_attack + STOMACH_ATTACK_DELAY > world.time)
				return

			last_stomach_attack = world.time
			for(var/mob/M in hearers(4, src))
				if(M.client)
					M.show_message(text("<span class='warning'>Вы слышите как что-то урчит в животе [src.name]...</span>"), 2)

			var/obj/item/I = user.get_active_hand()
			if(I && I.force)
				apply_damage(rand(round(I.force / 4), I.force), def_zone = BODY_ZONE_CHEST)

				for(var/mob/M in viewers(user, null))
					if(M.client)
						M.show_message(text("<span class='warning'><B>[user] атаку[pluralize_ru(user.gender,"ет","ют")] стенку желудка [src.name], используя [I.name]!</span>"), 2)
				playsound(user.loc, 'sound/effects/attackblob.ogg', 50, 1)

				if(prob(getBruteLoss() - 50))
					gib()

#undef STOMACH_ATTACK_DELAY


/mob/living/carbon/proc/has_mutated_organs()
	return FALSE


/mob/living/carbon/proc/vomit(
	lost_nutrition = VOMIT_NUTRITION_LOSS,
	mode = NONE,
	stun = VOMIT_STUN_TIME,
	distance = VOMIT_DISTANCE,
	message = TRUE
)
	if(ismachineperson(src)) // IPCs do not vomit particulates.
		return FALSE

	if(is_muzzled())
		if(message)
			to_chat(src, span_warning("Намордник препятствует рвоте!"))

		return FALSE

	if(stun)
		Stun(stun)

	if((nutrition - VOMIT_SAFE_NUTRITION) < lost_nutrition && (!(mode & VOMIT_BLOOD)))
		if(message)
			visible_message(span_warning("[name] сухо кашля[pluralize_ru(gender,"ет","ют")]!"), \
							span_userdanger("Вы пытаетесь проблеваться, но в вашем желудке пусто!"))

		if(stun)
			Weaken(stun * 2.5)

		return FALSE

	if(message)
		visible_message(span_danger("[name] блю[pluralize_ru(gender,"ет","ют")]!"), \
						span_userdanger("Вас вырвало!"))

	playsound(get_turf(src), 'sound/effects/splat.ogg', 50, TRUE)
	var/turf/turf = get_turf(src)

	if(!turf)
		return FALSE

	var/max_nutriment_vomit_dist = 0
	if(lost_nutrition)
		max_nutriment_vomit_dist = floor((nutrition - VOMIT_SAFE_NUTRITION) / lost_nutrition)

	for(var/i = 1 to distance)
		if(max_nutriment_vomit_dist >= i)
			turf.add_vomit_floor()
			adjust_nutrition(-lost_nutrition)

			if(stun)
				adjustToxLoss(-3)

		if(mode & VOMIT_BLOOD)
			add_splatter_floor(turf)

			if(stun)
				adjustBruteLoss(3)

		turf = get_step(turf, dir)

		if(turf.is_blocked_turf())
			break

	return FALSE


/mob/living/carbon/gib()
	. = death(TRUE)
	if(!.)
		return
	var/drop_loc = drop_location()
	for(var/obj/item/organ/internal/organ as anything in internal_organs)
		var/atom/movable/thing = organ.remove(src)
		if(!QDELETED(thing))
			thing.forceMove(drop_loc)
			if(isturf(thing.loc))
				thing.throw_at(get_edge_target_turf(src, pick(GLOB.alldirs)), rand(1, 3), 5)

	for(var/mob/M in src)
		LAZYREMOVE(stomach_contents, M)
		M.forceMove(drop_loc)
		visible_message("<span class='danger'>[M] вырыва[pluralize_ru(M.gender,"ет","ют")]ся из [src.name]!</span>")


/mob/living/carbon/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE, jitter_time = 10 SECONDS, stutter_time = 6 SECONDS, stun_duration = 4 SECONDS)
	. = ..()
	if(!.)
		return .

	//Propagation through pulling
	if(!(flags & SHOCK_ILLUSION))
		shock_internal_organs(shock_damage)
		var/list/shocking_queue = list()
		if(iscarbon(pulling) && source != pulling)
			shocking_queue += pulling
		if(iscarbon(pulledby) && source != pulledby)
			shocking_queue += pulledby
		if(iscarbon(buckled) && source != buckled)
			shocking_queue += buckled
		for(var/mob/living/carbon/carried in buckled_mobs)
			if(source != carried)
				shocking_queue += carried
		//Found our victims, now lets shock them all
		for(var/mob/living/carbon/victim as anything in shocking_queue)
			victim.electrocute_act(shock_damage * 0.75, name, 1, flags, jitter_time, stutter_time, stun_duration)

	//Stun
	var/should_stun = (!(flags & SHOCK_TESLA) || siemens_coeff > 0.5) && !(flags & SHOCK_NOSTUN)
	var/knockdown = (flags & SHOCK_KNOCKDOWN)
	var/immediately_stun = should_stun && !(flags & SHOCK_DELAY_STUN)
	if(immediately_stun)
		if(knockdown)
			Knockdown(stun_duration)
		else
			Stun(stun_duration)

	//Jitter and other fluff.
	AdjustJitter(jitter_time)
	AdjustStuttering(stutter_time)
	if(should_stun)
		addtimer(CALLBACK(src, PROC_REF(secondary_shock), knockdown, stun_duration), 2 SECONDS)

	return shock_damage


///Called slightly after electrocute act to apply a secondary stun.
/mob/living/carbon/proc/secondary_shock(knockdown, stun_duration)
	if(knockdown)
		Knockdown(stun_duration)
	else
		Weaken(stun_duration)


/mob/living/carbon/proc/help_shake_act(mob/living/carbon/M)
	if(health >= HEALTH_THRESHOLD_CRIT)
		if(src == M && ishuman(src))
			check_self_for_injuries()
		else
			if(player_logged)
				M.visible_message("<span class='notice'>[M] встряхива[pluralize_ru(M.gender,"ет","ют")] [src.name], но он[genderize_ru(src.gender,"","а","о","и")] не отвечает. Вероятно у [genderize_ru(src.gender,"него","неё","этого","них")] SSD.", \
				"<span class='notice'>Вы трясете [src.name], но он[genderize_ru(src.gender,"","а","о","и")] не отвечает. Вероятно у [genderize_ru(src.gender,"него","неё","этого","них")] SSD.</span>")
			if(body_position == LYING_DOWN) // /vg/: For hugs. This is how update_icon figgers it out, anyway.  - N3X15
				if(buckled)
					to_chat(M, span_warning("You need to unbuckle [src] first to do that!"))
					return
				add_attack_logs(M, src, "Shaked", ATKLOG_ALL)
				if(ishuman(src))
					var/mob/living/carbon/human/H = src
					if(H.w_uniform)
						H.w_uniform.add_fingerprint(M)
				set_resting(FALSE, instant = TRUE)
				AdjustSleeping(-10 SECONDS)
				AdjustParalysis(-6 SECONDS)
				AdjustStunned(-6 SECONDS)
				AdjustWeakened(-6 SECONDS)
				adjustStaminaLoss(-10)
				if(body_position != STANDING_UP && !resting && !buckled)
					get_up(instant = TRUE)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				if(!player_logged)
					M.visible_message( \
						"<span class='notice'>[M] трясет [src.name] пытаясь разбудить [genderize_ru(src.gender,"его","её","это","их")]!</span>",\
						"<span class='notice'>Вы трясете [src.name] пытаясь разбудить [genderize_ru(src.gender,"его","её","это","их")]!</span>",\
						)

			else if(on_fire)
				var/self_message = "<span class='warning'>Вы пытаетесь потушить [src.name]!</span>"
				if(prob(30) && ishuman(M)) // 30% chance of burning your hands
					var/mob/living/carbon/human/H = M
					var/protected = FALSE // Protected from the fire
					if((H.gloves?.max_heat_protection_temperature > 360) || HAS_TRAIT(H, TRAIT_RESIST_HEAT))
						protected = TRUE
					if(!protected)
						H.apply_damage(5, BURN, def_zone = H.hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
						self_message = "<span class='danger'>Вы обжигаете ваши руки пытаясь потушить [src.name]!</span>"
						H.update_icons()

				M.visible_message("<span class='warning'>[M] пыта[pluralize_ru(M.gender,"ет","ют")]ся потушить [src.name]!</span>", self_message)
				playsound(get_turf(src), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				adjust_fire_stacks(-0.5)

			// BEGIN HUGCODE - N3X
			else
				playsound(get_turf(src), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				if(M.zone_selected == BODY_ZONE_HEAD)
					M.visible_message(\
					"<span class='notice'>[M] глад[pluralize_ru(M.gender,"ит","ят")] [src.name] по голове.</span>",\
					"<span class='notice'>Вы погладили [src.name] по голове.</span>",\
					)
				else

					M.visible_message(\
					"<span class='notice'>[M] [pick("обнима[pluralize_ru(M.gender,"ет","ют")]","тепло обнима[pluralize_ru(M.gender,"ет","ют")]", "прижима[pluralize_ru(M.gender,"ет","ют")] к груди", "приобнима[pluralize_ru(M.gender,"ет","ют")]", "прижима[pluralize_ru(M.gender,"ет","ют")] к груди голову", "приобнял[genderize_ru(M.gender,"","а","о","и")] плечи")] [src.name].</span>",\
					"<span class='notice'>Вы обняли [src.name].</span>",\
					)
					if(ishuman(src))
						var/mob/living/carbon/human/H = src
						if(H.wear_suit)
							H.wear_suit.add_fingerprint(M)
						else if(H.w_uniform)
							H.w_uniform.add_fingerprint(M)


/mob/living/carbon/proc/check_self_for_injuries()
	var/mob/living/carbon/human/H = src
	visible_message( \
		text("<span class='notice'>[src.name] осматрива[pluralize_ru(src.gender,"ет","ют")] себя.</span>"),\
		"<span class='notice'>Вы осмотрели себя на наличие травм.</span>", \
		)

	var/list/missing = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_PRECISE_L_FOOT,
		BODY_ZONE_PRECISE_R_FOOT,
	)
	for(var/obj/item/organ/external/bodypart as anything in H.bodyparts)
		missing -= bodypart.limb_zone
		var/status = ""
		var/brutedamage = bodypart.brute_dam
		var/burndamage = bodypart.burn_dam

		if(brutedamage > 0)
			status = "bruised"
		if(brutedamage > 20)
			status = "battered"
		if(brutedamage > 40)
			status = "mangled"
		if(brutedamage > 0 && burndamage > 0)
			status += " and "
		if(burndamage > 40)
			status += "peeling away"

		else if(burndamage > 10)
			status += "blistered"
		else if(burndamage > 0)
			status += "numb"
		if(bodypart.is_mutated())
			status = "weirdly shapen."
		if(status == "")
			status = "OK"
		to_chat(src, "\t <span class='[status == "OK" ? "notice" : "warning"]'>Your [bodypart.name] is [status].</span>")

		for(var/obj/item/embedded as anything in bodypart.embedded_objects)
			to_chat(src, "\t <a href='byond://?src=[UID()];embedded_object=[embedded.UID()];embedded_limb=[bodypart.UID()]' class='warning'>В твоем [bodypart.name] застрял [embedded]!</a>")

	for(var/t in missing)
		to_chat(src, span_boldannounceic("У вас отсутствует [parse_zone(t)]!"))

	if(H.bleed_rate)
		to_chat(src, "<span class='danger'>У вас кровотечение!</span>")
	if(staminaloss)
		if(staminaloss > 30)
			to_chat(src, "<span class='info'>Вы полностью истощены.</span>")
		else
			to_chat(src, "<span class='info'>Вы чувствуете усталость.</span>")
	if((isskeleton(H) || HAS_TRAIT(H, TRAIT_SKELETON)) && (!H.w_uniform) && (!H.wear_suit))
		H.play_xylophone()


/mob/living/carbon/flash_eyes(intensity = 1, override_blindness_check, affect_silicon, visual, type = /atom/movable/screen/fullscreen/flash)
	. = ..()
	var/damage = intensity - check_eye_prot()
	var/extra_damage = 0
	if(.)
		if(visual)
			return

		var/obj/item/organ/internal/eyes/E = get_int_organ(/obj/item/organ/internal/eyes)
		if(!E || (E && E.weld_proof))
			return

		if(weakeyes)
			Stun(4 SECONDS)

		var/extra_darkview = 0
		if(E.see_in_dark)
			extra_darkview = max(E.see_in_dark - 2, 0)
			extra_damage = extra_darkview

		var/light_amount = 10 // assume full brightness
		if(isturf(loc))
			var/turf/T = loc
			light_amount = round(T.get_lumcount() * 10)

		// a dark view of 8, in full darkness, will result in maximum 1st tier damage
		var/extra_prob = (10 - light_amount) * extra_darkview

		switch(damage)
			if(1)
				to_chat(src, span_warning("Ваши глаза немного щиплет."))
				var/minor_damage_multiplier = min(40 + extra_prob, 100) / 100
				var/minor_damage = minor_damage_multiplier * (1 + extra_damage)
				E.internal_receive_damage(minor_damage, silent = TRUE)
			if(2)
				to_chat(src, span_warning("Ваши глаза пылают."))
				E.internal_receive_damage(rand(2, 4) + extra_damage, silent = TRUE)

			else
				to_chat(src, span_warning("Глаза сильно чешутся и пылают!"))
				E.internal_receive_damage(rand(12, 16) + extra_damage, silent = TRUE)

		if(E.damage > E.min_bruised_damage)
			AdjustEyeBlind(damage STATUS_EFFECT_CONSTANT)
			AdjustEyeBlurry(damage * rand(6 SECONDS, 12 SECONDS))

			if(E.damage > (E.min_bruised_damage + E.min_broken_damage) / 2)
				if(!E.is_robotic())
					to_chat(src, span_warning("Ваши глаза начинают сильно пылать!"))
				else //snowflake conditions piss me off for the record
					to_chat(src, span_warning("Вас ослепила вспышка!"))

			else if(E.damage >= E.min_broken_damage)
				to_chat(src, span_warning("Вы ничего не видите!"))

			else
				to_chat(src, span_warning("Ваши глаза начинают изрядно болеть. Это определенно не очень хорошо!"))
		if(mind && has_bane(BANE_LIGHT))
			mind.disrupt_spells(-500)
		return TRUE

	else if(damage == 0) // just enough protection
		if(prob(20))
			to_chat(src, span_notice("Что-то яркое вспыхнуло на периферии вашего зрения!"))
			if(mind && has_bane(BANE_LIGHT))
				mind.disrupt_spells(0)


/mob/living/carbon/proc/create_dna()
	if(!dna)
		dna = new()


/mob/living/carbon/proc/getDNA()
	return dna


/mob/living/carbon/proc/setDNA(var/datum/dna/newDNA)
	dna = newDNA


/mob/living/carbon/can_ventcrawl(obj/machinery/atmospherics/ventcrawl_target, provide_feedback = TRUE, entering = FALSE)
	. = ..()
	if(!. || !entering)
		return .

	var/alien_trait = HAS_TRAIT(src, TRAIT_VENTCRAWLER_ALIEN)
	if(alien_trait && length(get_equipped_items(include_hands = TRUE)))
		if(provide_feedback)
			to_chat(src, span_warning("Вы не можете ползать по вентиляции c предметами в руках!"))
		return FALSE

	if(!alien_trait && !HAS_TRAIT(src, TRAIT_VENTCRAWLER_ITEM_BASED) && HAS_TRAIT(src, TRAIT_VENTCRAWLER_NUDE) && \
		!HAS_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS) && length(get_equipped_items(include_pockets = TRUE, include_hands = TRUE)))
		if(provide_feedback)
			to_chat(src, span_warning("Вы не можете ползать по вентиляции c предметами!"))
		return FALSE


//Throwing stuff

/mob/living/carbon/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum, speed)
	. = ..()

	if(has_status_effect(STATUS_EFFECT_CHARGING))
		var/hit_something = FALSE
		if(ismovable(hit_atom))
			var/atom/movable/AM = hit_atom
			var/atom/throw_target = get_edge_target_turf(AM, dir)
			if(!AM.anchored || ismecha(AM))
				AM.throw_at(throw_target, 5, 12, src)
				hit_something = TRUE

		if(isobj(hit_atom))
			var/obj/O = hit_atom
			O.take_damage(150, BRUTE)
			hit_something = TRUE

		if(isliving(hit_atom))
			var/mob/living/L = hit_atom
			L.adjustBruteLoss(60)
			L.Weaken(4 SECONDS)
			L.Confused(10 SECONDS)
			shake_camera(L, 4, 3)
			hit_something = TRUE

		if(isturf(hit_atom))
			var/turf/T = hit_atom
			if(iswallturf(T))
				T.dismantle_wall(TRUE)
				hit_something = TRUE

		if(hit_something)
			visible_message(span_danger("[src] slams into [hit_atom]!"),
							span_userdanger("You slam into [hit_atom]!"))
			playsound(get_turf(src), 'sound/effects/meteorimpact.ogg', 100, TRUE)

		return

	var/damage = 10 + 1.5 * speed // speed while thrower is standing still is 2, while walking with an aggressive grab is 2.4, highest speed is 14
	hit_atom.hit_by_thrown_carbon(src, throwingdatum, damage, FALSE, FALSE)


/mob/living/carbon/hit_by_thrown_carbon(mob/living/carbon/human/C, datum/thrownthing/throwingdatum, damage, mob_hurt, self_hurt)
	/*
	for(var/obj/item/twohanded/dualsaber/D in contents)
		if(D.wielded && D.force)
			visible_message(span_danger("[src] impales [C] with [D], before dropping them on the ground!"))
			C.apply_damage(100, BRUTE, BODY_ZONE_CHEST, sharp = TRUE, used_weapon = "Impaled on [D].")
			C.Stun(2 SECONDS) //Punishment. This could also be used by a traitor to throw someone into a dsword to kill them, but hey, teamwork!
			C.Weaken(2 SECONDS)
			D.melee_attack_chain(src, C) //attack animation / jedi spin
			C.emote("scream")
			return
	*/
	. = ..()
	Weaken(3 SECONDS)


/mob/living/carbon/proc/toggle_throw_mode()
	if(in_throw_mode)
		throw_mode_off()
	else
		throw_mode_on()
	var/obj/item/I = get_active_hand()
	if(I)
		SEND_SIGNAL(I, COMSIG_CARBON_TOGGLE_THROW, in_throw_mode)


#define THROW_MODE_ICON 'icons/effects/cult_target.dmi'

/mob/living/carbon/proc/throw_mode_off()
	in_throw_mode = FALSE
	if(throw_icon) //in case we don't have the HUD and we use the hotkey
		throw_icon.icon_state = "act_throw_off"
	if(client?.mouse_pointer_icon == THROW_MODE_ICON)
		client.mouse_pointer_icon = initial(client.mouse_pointer_icon)


/mob/living/carbon/proc/throw_mode_on()
	SIGNAL_HANDLER //This signal is here so we can turn throw mode back on via carp when an object is caught
	in_throw_mode = TRUE
	if(throw_icon)
		throw_icon.icon_state = "act_throw_on"
	if(client?.mouse_pointer_icon == initial(client.mouse_pointer_icon))
		client.mouse_pointer_icon = THROW_MODE_ICON
	// we nullify click cd when someone tries to throw a grabbed mob
	// improves combat robustness a lot
	if(pulling && grab_state > GRAB_PASSIVE)
		changeNext_move(0)

#undef THROW_MODE_ICON


/mob/proc/throw_item(atom/target)
	return TRUE


/mob/living/carbon/throw_item(atom/target)
	. = ..()

	throw_mode_off()

	if(!target || !isturf(loc) || is_screen_atom(target))
		return FALSE

	var/atom/movable/thrown_thing
	var/obj/item/held_item = get_active_hand()
	// we can't check for if it's a neckgrab throw when totaling up power_throw
	// since we've already stopped pulling them by then, so get it early
	var/neckgrab_throw = FALSE
	if(!held_item)
		if(isliving(pulling) && grab_state >= GRAB_AGGRESSIVE && (pull_hand == PULL_WITHOUT_HANDS || pull_hand == hand))
			var/mob/living/throwable_mob = pulling
			if(!throwable_mob.buckled)
				thrown_thing = throwable_mob
				if(grab_state >= GRAB_NECK)
					neckgrab_throw = TRUE
				stop_pulling()
				if(HAS_TRAIT(src, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
					to_chat(src, span_notice("Вы осторожно отпускаете [throwable_mob.declent_ru(ACCUSATIVE)]."))
					return FALSE
	else
		if(held_item.override_throw(src, target) || (held_item.item_flags & ABSTRACT))	//can't throw abstract items
			return FALSE
		if(!drop_item_ground(held_item, silent = TRUE))
			return FALSE
		if(held_item.throwforce && (GLOB.pacifism_after_gt || HAS_TRAIT(src, TRAIT_PACIFISM)))
			to_chat(src, span_notice("Вы осторожно опускаете [held_item.declent_ru(ACCUSATIVE)] на землю."))
			return FALSE
		thrown_thing = held_item

	if(!thrown_thing)
		return FALSE

	var/mob/living/throwing_mob
	if(isliving(thrown_thing))
		throwing_mob = thrown_thing
		var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
		var/turf/end_T = get_turf(target)
		if(start_T && end_T)
			var/start_T_descriptor = "<font color='#6b5d00'>tile at [start_T.x], [start_T.y], [start_T.z] in area [get_area(start_T)]</font>"
			var/end_T_descriptor = "<font color='#6b4400'>tile at [end_T.x], [end_T.y], [end_T.z] in area [get_area(end_T)]</font>"
			add_attack_logs(src, throwing_mob, "Thrown from [start_T_descriptor] with the target [end_T_descriptor]")

	//We assign a default frequency number for the sound of the throw.
	var/frequency_number = 1
	if(!throwing_mob)
		var/obj/item/thrown_item = thrown_thing	// always item otherwise
		//At normal weight, the frequency is at 1. For tiny, it is 1.25. For huge, it is 0.75.
		frequency_number = 1 - (thrown_item.w_class - 3) / 8

	var/power_throw = 0
	if(HAS_TRAIT(src, TRAIT_HULK))
		power_throw++
	if(HAS_TRAIT(src, TRAIT_DWARF))
		power_throw--
	if(throwing_mob && HAS_TRAIT(throwing_mob, TRAIT_DWARF))
		power_throw++
	if(neckgrab_throw)
		power_throw++

	do_attack_animation(target, no_effect = TRUE)
	var/sound/throwsound = 'sound/weapons/throw.ogg'
	var/power_throw_text = ""
	if(power_throw > 0) //If we have anything that boosts our throw power like hulk, we use the rougher heavier variant.
		throwsound = 'sound/weapons/throwhard.ogg'
		power_throw_text = " мощно"
	if(power_throw < 0) //if we have anything that weakens our throw power like dward, we use a slower variant.
		throwsound = 'sound/weapons/throwsoft.ogg'
		power_throw_text = " немощно"

	// Adds a bit of randomness in the frequency to not sound exactly the same.
	// The volume of the sound takes the minimum between the distance thrown or the max range an item,
	// but no more than 50. Short throws are quieter. A fast throwing speed also makes the noise sharper.
	frequency_number = frequency_number + (rand(-5, 5) / 100)

	playsound(src, throwsound, min(8 * min(get_dist(loc, target), thrown_thing.throw_range), 50), vary = TRUE, extrarange = -1, frequency = frequency_number)

	visible_message(
		span_danger("[declent_ru(NOMINATIVE)][power_throw_text] броса[pluralize_ru(gender,"ет","ют")] [thrown_thing.declent_ru(ACCUSATIVE)]."),
		span_danger("Вы[power_throw_text] бросаете [thrown_thing.declent_ru(ACCUSATIVE)]."),
	)
	newtonian_move(get_dir(target, src))
	thrown_thing.throw_at(target, thrown_thing.throw_range, max(1, thrown_thing.throw_speed + power_throw), src, null, null, null, move_force)


//generates realistic-ish pulse output based on preset levels
/mob/living/carbon/proc/get_pulse(var/method)	//method 0 is for hands, 1 is for machines, more accurate
	var/temp = 0								//see setup.dm:694
	switch(src.pulse)
		if(PULSE_NONE)
			return "0"
		if(PULSE_SLOW)
			temp = rand(40, 60)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_NORM)
			temp = rand(60, 90)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_FAST)
			temp = rand(90, 120)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_2FAST)
			temp = rand(120, 160)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_THREADY)
			return method ? ">250" : "extremely weak and fast, patient's artery feels like a thread"
//			output for machines^	^^^^^^^output for people^^^^^^^^^


/mob/living/carbon/on_fall()
	. = ..()
	loc?.handle_fall(src)//it's loc so it doesn't call the mob's handle_fall which does nothing


/mob/living/carbon/resist_buckle()
	INVOKE_ASYNC(src, PROC_REF(resist_muzzle))
	if(HAS_TRAIT(src, TRAIT_RESTRAINED))
		var/breakouttime = 60 SECONDS
		var/obj/item/restraints = handcuffed
		if(wear_suit?.breakouttime)
			restraints = wear_suit
		if(restraints)
			breakouttime = restraints.breakouttime
		visible_message(
			span_warning("[name] пыта[pluralize_ru(gender,"ет","ют")]ся себя отстегнуть!"),
			span_notice("Вы пытаетесь себя отстегнуть... (Это займет [breakouttime / 10] секунд и Вам нельзя двигаться."),
		)
		if(do_after(src, breakouttime, src, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM))
			if(!buckled)
				return
			buckled.user_unbuckle_mob(src, src)
		else
			if(src && buckled)
				to_chat(src, span_warning("Вам не удалось себя отстегнуть!"))
	else
		buckled.user_unbuckle_mob(src, src)


/mob/living/carbon/resist_fire()
	return !!apply_status_effect(STATUS_EFFECT_DROPNROLL)


/mob/living/carbon/emp_act(severity)
	..()
	for(var/obj/item/organ/internal/organ as anything in internal_organs)
		organ.emp_act(severity)

/mob/living/carbon/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	var/obj/item/organ/internal/xenos/plasmavessel/vessel = get_int_organ(/obj/item/organ/internal/xenos/plasmavessel)
	if(vessel)
		status_tab_data[++status_tab_data.len] = list("Plasma Stored:", "[vessel.stored_plasma]/[vessel.max_plasma]")
	var/obj/item/organ/internal/wryn/glands/glands = get_int_organ(/obj/item/organ/internal/wryn/glands)
	if(glands)
		status_tab_data[++status_tab_data.len] = list("Wax: [glands.wax]")

/mob/living/carbon/slip(weaken, obj/slipped_on, lube_flags, tilesSlipped)
	if(movement_type & MOVETYPES_NOT_TOUCHING_GROUND)
		return FALSE

	..()
	return loc.handle_slip(src, weaken, slipped_on, lube_flags, tilesSlipped)


/mob/living/carbon/proc/eat(obj/item/reagent_containers/food/toEat, mob/user, bitesize_override)
	if(!istype(toEat))
		return FALSE
	var/fullness = nutrition + 10
	if(istype(toEat, /obj/item/reagent_containers/food/snacks))
		for(var/datum/reagent/consumable/C in reagents.reagent_list) //we add the nutrition value of what we're currently digesting
			fullness += C.nutriment_factor * C.volume / (C.metabolization_rate * metabolism_efficiency * digestion_ratio)
	if(user == src)
		if(istype(toEat, /obj/item/reagent_containers/food/drinks))
			if(!selfDrink(toEat))
				return FALSE
		else
			if(!selfFeed(toEat, fullness))
				return FALSE
		if(toEat.log_eating)
			var/this_bite = bitesize_override ? bitesize_override : toEat.bitesize
			add_game_logs("Ate [toEat](bite volume: [this_bite*toEat.transfer_efficiency]) containing [toEat.reagents.log_list()]", src)
	else
		if(!forceFed(toEat, user, fullness))
			return FALSE
		var/this_bite = bitesize_override ? bitesize_override : toEat.bitesize
		add_attack_logs(user, src, "Force Fed [toEat](bite volume: [this_bite*toEat.transfer_efficiency]u) containing [toEat.reagents.log_list()]")
	consume(toEat, bitesize_override, can_taste_container = toEat.can_taste)
	SSticker.score.score_food_eaten++
	return TRUE


/mob/living/carbon/proc/selfFeed(obj/item/reagent_containers/food/toEat, fullness)
	if(ispill(toEat))
		to_chat(src, "<span class='notify'>You [toEat.apply_method] [toEat].</span>")
	else
		if(toEat.junkiness && satiety < -150 && nutrition > NUTRITION_LEVEL_STARVING + 50 )
			to_chat(src, "<span class='notice'>You don't feel like eating any more junk food at the moment.</span>")
			return FALSE
		if(fullness <= 50)
			to_chat(src, "<span class='warning'>You hungrily chew out a piece of [toEat] and gobble it!</span>")
		else if(fullness > 50 && fullness < 150)
			to_chat(src, "<span class='notice'>You hungrily begin to eat [toEat].</span>")
		else if(fullness > 150 && fullness < 500)
			to_chat(src, "<span class='notice'>You take a bite of [toEat].</span>")
		else if(fullness > 500 && fullness < 600)
			to_chat(src, "<span class='notice'>You unwillingly chew a bit of [toEat].</span>")
		else if(fullness > (600 * (1 + overeatduration / 2000)))	// The more you eat - the more you can eat
			to_chat(src, "<span class='warning'>You cannot force any more of [toEat] to go down your throat.</span>")
			return FALSE
	return TRUE


/mob/living/carbon/proc/selfDrink(obj/item/reagent_containers/food/drinks/toDrink, mob/user)
	return TRUE


/mob/living/carbon/proc/forceFed(obj/item/reagent_containers/food/toEat, mob/user, fullness)
	if(ispill(toEat) || fullness <= (600 * (1 + overeatduration / 1000)))
		if(!toEat.instant_application)
			visible_message("<span class='warning'>[user] attempts to force [src] to [toEat.apply_method] [toEat].</span>")
	else
		visible_message("<span class='warning'>[user] cannot force anymore of [toEat] down [src]'s throat.</span>")
		return FALSE
	if(!toEat.instant_application)
		if(!do_after(user, 3 SECONDS, src, NONE))
			return FALSE
	visible_message("<span class='warning'>[user] forces [src] to [toEat.apply_method] [toEat].</span>")
	return TRUE


/*TO DO - If/when stomach organs are introduced, override this at the human level sending the item to the stomach
so that different stomachs can handle things in different ways VB*/
/mob/living/carbon/proc/consume(var/obj/item/reagent_containers/food/toEat, var/bitesize_override, var/can_taste_container = TRUE)
	var/this_bite = bitesize_override ? bitesize_override : toEat.bitesize
	if(!toEat.reagents)
		return
	if(satiety > -200)
		satiety -= toEat.junkiness
	if(toEat.consume_sound)
		playsound(loc, toEat.consume_sound, rand(10,50), 1)
	if(toEat.reagents.total_volume)
		var/fraction = min(this_bite/toEat.reagents.total_volume, 1)
		if(fraction)
			if(can_taste_container)
				taste(toEat.reagents)
				toEat.check_liked(fraction, src)
			toEat.reagents.reaction(src, toEat.apply_type, fraction)
			toEat.reagents.trans_to(src, this_bite*toEat.transfer_efficiency)


/mob/living/carbon/proc/can_breathe_gas()
	if(HAS_TRAIT(src, TRAIT_NO_BREATH))
		return FALSE

	if(!wear_mask && !head)
		return TRUE

	var/obj/item/clothing/our_mask = wear_mask
	var/obj/item/clothing/our_helmet = head
	if(!internal \
		&& !(isclothing(our_mask) && (our_mask.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)) \
		&& !(isclothing(our_helmet) && (our_helmet.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)))
		return TRUE

	return FALSE


//to recalculate and update the mob's total tint from tinted equipment it's wearing.
/mob/living/carbon/proc/update_tint()
	if(!GLOB.tinted_weldhelh)
		return
	var/tinttotal = get_total_tint()
	if(tinttotal >= TINT_BLIND)
		overlay_fullscreen("tint", /atom/movable/screen/fullscreen/blind)
	else if(tinttotal >= TINT_IMPAIR)
		overlay_fullscreen("tint", /atom/movable/screen/fullscreen/impaired, 2)
	else
		clear_fullscreen("tint", 0)


/// Checks eye covering items for visually impairing tinting, such as welding masks. 0 & 1 = no impairment, 2 = welding mask overlay, 3 = casual blindness.
/mob/living/proc/get_total_tint()
	. = 0


/mob/living/carbon/get_total_tint()
	. = ..()
	if(istype(head, /obj/item/clothing/head))
		var/obj/item/clothing/head/HT = head
		. += HT.tint
	if(wear_mask)
		. += wear_mask.tint


/mob/living/carbon/human/get_total_tint()
	. = ..()
	if(glasses)
		var/obj/item/clothing/glasses/G = glasses
		. += G.tint


/mob/living/carbon/proc/shock_internal_organs(intensity)
	for(var/obj/item/organ/internal/organ as anything in internal_organs)
		organ.shock_organ(intensity)


/mob/living/carbon/update_sight()
	if(!client)
		return

	if(stat == DEAD)
		grant_death_vision()
		return

	set_invis_see(initial(see_invisible))
	set_sight(initial(sight))
	lighting_alpha = initial(lighting_alpha)
	nightvision = initial(nightvision)

	for(var/obj/item/organ/internal/cyberimp/eyes/cyber_eyes in internal_organs)
		add_sight(cyber_eyes.vision_flags)
		if(cyber_eyes.see_in_dark)
			nightvision = max(nightvision, cyber_eyes.see_in_dark)
		if(cyber_eyes.see_invisible)
			set_invis_see(min(see_invisible, cyber_eyes.see_invisible))
		if(!isnull(cyber_eyes.lighting_alpha))
			lighting_alpha = min(lighting_alpha, cyber_eyes.lighting_alpha)

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

	if(HAS_TRAIT(src, TRAIT_XRAY))
		add_sight(SEE_TURFS|SEE_MOBS|SEE_OBJS)
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

	..()


/mob/living/carbon/ExtinguishMob()
	for(var/X in get_equipped_items())
		var/obj/item/I = X
		I.acid_level = 0 //washes off the acid on our clothes
		I.extinguish() //extinguishes our clothes
	..()


/mob/living/carbon/clean_blood(clean_hands = TRUE, clean_mask = TRUE, clean_feet = TRUE)
	if(head)
		if(head.clean_blood())
			update_inv_head()
		if(head.flags_inv & HIDEMASK)
			clean_mask = FALSE
	if(wear_suit)
		if(wear_suit.clean_blood())
			update_inv_wear_suit()
		if(wear_suit.flags_inv & HIDESHOES)
			clean_feet = FALSE
		if(wear_suit.flags_inv & HIDEGLOVES)
			clean_hands = FALSE
	..(clean_hands, clean_mask, clean_feet)


/mob/living/carbon/proc/shock_reduction()
	var/shock_reduction = 0
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.shock_reduction)
				shock_reduction += R.shock_reduction
	return shock_reduction


/mob/living/carbon/can_change_move_intent(silent = FALSE)
	if(m_intent == MOVE_INTENT_WALK && legcuffed)
		if(!silent)
			to_chat(src, span_notice("Ваши ноги скованы! Вы не можете бежать, пока не снимете [legcuffed.name]!"))
		return FALSE
	return ..()


/mob/living/carbon/lying_angle_on_lying_down(new_lying_angle)
	if(!new_lying_angle)
		set_lying_angle(pick(90, 270))
	else
		set_lying_angle(new_lying_angle)


/mob/living/carbon/set_body_position(new_value)
	. = ..()
	if(isnull(.))
		return .
	if(new_value == LYING_DOWN)
		add_movespeed_modifier(/datum/movespeed_modifier/carbon_crawling)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/carbon_crawling)

/mob/living/carbon/proc/remove_all_parasites(vomit_organs = FALSE)
	var/static/list/parasite_organs = typecacheof(list(
		/obj/item/organ/internal/body_egg,
		/obj/item/organ/internal/legion_tumour,
	))

	var/should_vomit = FALSE
	var/turf/current_turf = get_turf(src)
	for(var/obj/item/organ/internal/organ as anything in internal_organs)
		if(!is_type_in_typecache(organ, parasite_organs))
			continue
		organ.remove(src)
		if(QDELETED(organ))
			continue
		if(vomit_organs)
			should_vomit = TRUE
			organ.forceMove(current_turf)
		else
			qdel(organ)

	if(should_vomit)
		fakevomit()


/mob/living/carbon/on_no_breath_trait_gain(datum/source)
	. = ..()

	co2overloadtime = 0

