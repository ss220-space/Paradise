/mob/living/carbon
	/// Used for wishgranter see wildwest.dm
	var/revival_in_progress = FALSE
	/// Just a timer stamp for [/mob/living/carbon/relaymove]
	var/last_stomach_attack


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


/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(.)
		if(nutrition && stat != DEAD && !isvampire(src))
			adjust_nutrition(-(hunger_drain * 0.1))
			if(m_intent == MOVE_INTENT_RUN)
				adjust_nutrition(-(hunger_drain * 0.1))
		if((FAT in mutations) && m_intent == MOVE_INTENT_RUN && bodytemperature <= 360)
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
				var/d = rand(round(I.force / 4), I.force)

				if(istype(src, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = src
					var/obj/item/organ/external/organ = H.get_organ(BODY_ZONE_CHEST)
					if(istype(organ))
						if(organ.receive_damage(d, 0))
							H.UpdateDamageIcon()

					H.updatehealth("stomach attack")

				else
					take_organ_damage(d)

				for(var/mob/M in viewers(user, null))
					if(M.client)
						M.show_message(text("<span class='warning'><B>[user] атаку[pluralize_ru(user.gender,"ет","ют")] стенку желудка [src.name], используя [I.name]!</span>"), 2)
				playsound(user.loc, 'sound/effects/attackblob.ogg', 50, 1)

				if(prob(getBruteLoss() - 50))
					gib()

#undef STOMACH_ATTACK_DELAY


/mob/living/carbon/proc/has_mutated_organs()
	return FALSE


/mob/living/carbon/proc/vomit(lost_nutrition = 10, blood = 0, stun = 8 SECONDS, distance = 0, message = 1)
	if(ismachineperson(src)) //IPCs do not vomit particulates
		return FALSE
	if(is_muzzled())
		if(message)
			to_chat(src, "<span class='warning'>Намордник препятствует рвоте!</span>")
		return FALSE
	if(stun)
		Stun(stun)
	if(nutrition < 100 && !blood)
		if(message)
			visible_message("<span class='warning'>[src.name] сухо кашля[pluralize_ru(src.gender,"ет","ют")]!</span>", \
							"<span class='userdanger'>Вы пытаетесь проблеваться, но в вашем желудке пусто!</span>")
		if(stun)
			Weaken(stun * 2.5)
	else
		if(message)
			visible_message("<span class='danger'>[src.name] блю[pluralize_ru(src.gender,"ет","ют")]!</span>", \
							"<span class='userdanger'>Вас вырвало!</span>")
		playsound(get_turf(src), 'sound/effects/splat.ogg', 50, 1)
		var/turf/T = get_turf(src)
		for(var/i=0 to distance)
			if(blood)
				if(T)
					add_splatter_floor(T)
				if(stun)
					adjustBruteLoss(3)
			else
				if(T)
					T.add_vomit_floor()
				adjust_nutrition(-lost_nutrition)
				if(stun)
					adjustToxLoss(-3)
			T = get_step(T, dir)
			if(T.is_blocked_turf())
				break
	return TRUE

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

/mob/living/carbon/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, safety = FALSE, override = FALSE, tesla_shock = FALSE, illusion = FALSE, stun = TRUE)
	SEND_SIGNAL(src, COMSIG_LIVING_ELECTROCUTE_ACT, shock_damage)
	if(status_flags & GODMODE)	//godmode
		return FALSE
	if(HAS_TRAIT(src, TRAIT_SHOCKIMMUNE)) //shockproof
		return FALSE
	if(tesla_shock && tesla_ignore)
		return FALSE
	shock_damage *= siemens_coeff
	if(dna && dna.species)
		shock_damage *= dna.species.siemens_coeff
	if(shock_damage < 1 && !override)
		return FALSE
	if(reagents.has_reagent("teslium"))
		shock_damage *= 1.5 //If the mob has teslium in their body, shocks are 50% more damaging!
	if(illusion)
		adjustStaminaLoss(shock_damage)
	else
		take_overall_damage(0, shock_damage, TRUE, used_weapon = "Electrocution")
		shock_internal_organs(shock_damage)
	visible_message(
		"<span class='danger'>[src.name] получил[genderize_ru(src.gender,"","а","о","и")] разряд током [source]!</span>",
		"<span class='userdanger'>Вы чувствуете электрический разряд проходящий через ваше тело!</span>",
		"<span class='italics'>Вы слышите сильный электрический треск.</span>")
	AdjustJitter(2000 SECONDS) //High numbers for violent convulsions
	AdjustStuttering(4 SECONDS)
	if((!tesla_shock || (tesla_shock && siemens_coeff > 0.5)) && stun)
		Stun(4 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(secondary_shock), tesla_shock, siemens_coeff, stun), 2 SECONDS)
	if(shock_damage > 200)
		visible_message(
			"<span class='danger'>[src.name] был[genderize_ru(src.gender,"","а","о","и")] прожжен[genderize_ru(src.gender,"","а","о","ы")] дугой [source]!</span>",
			"<span class='userdanger'>Дуга [source] вспыхивает и ударяет вас электрическим током!</span>",
			"<span class='italics'>Вы слышите треск похожий на молнию!</span>")
		playsound(loc, 'sound/effects/eleczap.ogg', 50, 1, -1)
		explosion(loc, -1, 0, 2, 2, cause = "[source] over electrocuted [name]")

	if(override)
		return override
	else
		return shock_damage

///Called slightly after electrocute act to reduce jittering and apply a secondary stun.
/mob/living/carbon/proc/secondary_shock(tesla_shock, siemens_coeff, stun)
	AdjustJitter(-2000 SECONDS, bound_lower = 20 SECONDS) //Still jittery, but vastly less
	if((!tesla_shock || (tesla_shock && siemens_coeff > 0.5)) && stun)
		Weaken(4 SECONDS)


/mob/living/carbon/proc/help_shake_act(mob/living/carbon/M)
	if(health >= HEALTH_THRESHOLD_CRIT)
		if(src == M && ishuman(src))
			check_self_for_injuries()
		else
			if(player_logged)
				M.visible_message("<span class='notice'>[M] встряхива[pluralize_ru(M.gender,"ет","ют")] [src.name], но он[genderize_ru(src.gender,"","а","о","и")] не отвечает. Вероятно у [genderize_ru(src.gender,"него","неё","этого","них")] SSD.", \
				"<span class='notice'>Вы трясете [src.name], но он[genderize_ru(src.gender,"","а","о","и")] не отвечает. Вероятно у [genderize_ru(src.gender,"него","неё","этого","них")] SSD.</span>")
			if(lying_angle) // /vg/: For hugs. This is how update_icon figgers it out, anyway.  - N3X15
				add_attack_logs(M, src, "Shaked", ATKLOG_ALL)
				if(ishuman(src))
					var/mob/living/carbon/human/H = src
					if(H.w_uniform)
						H.w_uniform.add_fingerprint(M)
				AdjustSleeping(-10 SECONDS)
				if(!AmountSleeping())
					StopResting()
				AdjustParalysis(-6 SECONDS)
				AdjustStunned(-6 SECONDS)
				AdjustWeakened(-6 SECONDS)
				adjustStaminaLoss(-10)
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
					if((H.gloves?.max_heat_protection_temperature > 360) || (HEATRES in H.mutations))
						protected = TRUE

					var/obj/item/organ/external/active_hand = H.get_organ(H.hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
					if(active_hand && !protected) // Wouldn't really work without a hand
						active_hand.receive_damage(0, 5)
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
		to_chat(src, "<span class='boldannounce'>У вас отсутствует [parse_zone(t)]!</span>")

	if(H.bleed_rate)
		to_chat(src, "<span class='danger'>У вас кровотечение!</span>")
	if(staminaloss)
		if(staminaloss > 30)
			to_chat(src, "<span class='info'>Вы полностью истощены.</span>")
		else
			to_chat(src, "<span class='info'>Вы чувствуете усталость.</span>")
	if((isskeleton(H) || (SKELETON in H.mutations)) && (!H.w_uniform) && (!H.wear_suit))
		H.play_xylophone()


/mob/living/carbon/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0)
	. = ..()
	var/damage = intensity - check_eye_prot()
	var/extra_damage = 0
	if(.)
		if(visual)
			return
		if(weakeyes)
			Stun(4 SECONDS)

		var/obj/item/organ/internal/eyes/E = get_int_organ(/obj/item/organ/internal/eyes)
		if(!E || (E && E.weld_proof))
			return

		var/extra_darkview = 0
		if(E.see_in_dark)
			extra_darkview = max(E.see_in_dark - 2, 0)
			extra_damage = extra_darkview

		var/light_amount = 10 // assume full brightness
		if(isturf(src.loc))
			var/turf/T = src.loc
			light_amount = round(T.get_lumcount() * 10)

		// a dark view of 8, in full darkness, will result in maximum 1st tier damage
		var/extra_prob = (10 - light_amount) * extra_darkview

		switch(damage)
			if(1)
				to_chat(src, "<span class='warning'>Ваши глаза немного щиплет.</span>")
				var/minor_damage_multiplier = min(40 + extra_prob, 100) / 100
				var/minor_damage = minor_damage_multiplier * (1 + extra_damage)
				E.receive_damage(minor_damage, 1)
			if(2)
				to_chat(src, "<span class='warning'>Ваши глаза пылают.</span>")
				E.receive_damage(rand(2, 4) + extra_damage, 1)

			else
				to_chat(src, "Глаза сильно чешутся и пылают!</span>")
				E.receive_damage(rand(12, 16) + extra_damage, 1)

		if(E.damage > E.min_bruised_damage)
			AdjustEyeBlind(damage STATUS_EFFECT_CONSTANT)
			AdjustEyeBlurry(damage * rand(6 SECONDS, 12 SECONDS))

			if(E.damage > (E.min_bruised_damage + E.min_broken_damage) / 2)
				if(!E.is_robotic())
					to_chat(src, "<span class='warning'>Ваши глаза начинают сильно пылать!</span>")
				else //snowflake conditions piss me off for the record
					to_chat(src, "<span class='warning'>Вас ослепила вспышка!</span>")

			else if(E.damage >= E.min_broken_damage)
				to_chat(src, "<span class='warning'>Вы ничего не видите!</span>")

			else
				to_chat(src, "<span class='warning'>Ваши глаза начинают изрядно болеть. Это определенно не очень хорошо!</span>")
		if(mind && has_bane(BANE_LIGHT))
			mind.disrupt_spells(-500)
		return 1

	else if(damage == 0) // just enough protection
		if(prob(20))
			to_chat(src, "<span class='notice'>Что-то яркое вспыхнуло на периферии вашего зрения!</span>")
			if(mind && has_bane(BANE_LIGHT))
				mind.disrupt_spells(0)


/mob/living/carbon/proc/create_dna()
	if(!dna)
		dna = new()


/mob/living/carbon/proc/getDNA()
	return dna


/mob/living/carbon/proc/setDNA(var/datum/dna/newDNA)
	dna = newDNA


/mob/living/carbon/can_ventcrawl(atom/clicked_on, override = FALSE)
	if(!override && ventcrawler == 1)
		var/list/weared_items = get_all_slots()
		for(var/obj/item/item in weared_items)
			if(item)
				to_chat(src, span_warning("Вы не можете ползать по вентиляции с [item.name]."))
				return FALSE

	return ..()


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

#undef THROW_MODE_ICON


/mob/proc/throw_item(atom/target)
	return


/mob/living/carbon/throw_item(atom/target)
	if(!target || !isturf(loc) || istype(target, /obj/screen))
		throw_mode_off()
		return

	var/obj/item/I = get_active_hand()

	if(!I || I.override_throw(src, target) || (I.flags & NODROP))
		throw_mode_off()
		return

	throw_mode_off()
	var/atom/movable/thrown_thing

	if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		var/mob/throwable_mob = G.get_mob_if_throwable() //throw the person instead of the grab
		qdel(G)	//We delete the grab.
		if(throwable_mob)
			thrown_thing = throwable_mob
			if(HAS_TRAIT(src, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
				to_chat(src, span_notice("[pluralize_ru(src.gender,"Ты","Вы")] осторожно отпускае[pluralize_ru(src.gender,"шь","те")] [throwable_mob.declent_ru(ACCUSATIVE)]."))
				return
			var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
			var/turf/end_T = get_turf(target)
			throwable_mob.forceMove(start_T)
			if(start_T && end_T)
				var/start_T_descriptor = "<font color='#6b5d00'>tile at [start_T.x], [start_T.y], [start_T.z] in area [get_area(start_T)]</font>"
				var/end_T_descriptor = "<font color='#6b4400'>tile at [end_T.x], [end_T.y], [end_T.z] in area [get_area(end_T)]</font>"

				add_attack_logs(src, throwable_mob, "Thrown from [start_T_descriptor] with the target [end_T_descriptor]")

	else if(!(I.flags & ABSTRACT)) //can't throw abstract items
		thrown_thing = I
		drop_item_ground(I, silent = TRUE)

		if(GLOB.pacifism_after_gt || (HAS_TRAIT(src, TRAIT_PACIFISM) && I.throwforce))
			to_chat(src, span_notice("[pluralize_ru(src.gender,"Ты","Вы")] осторожно опускае[pluralize_ru(src.gender,"шь","те")] [I.declent_ru(ACCUSATIVE)] на землю."))
			return

	if(thrown_thing)
		visible_message(span_danger("[src.declent_ru(NOMINATIVE)] броса[pluralize_ru(src.gender,"ет","ют")] [thrown_thing.declent_ru(ACCUSATIVE)]."))
		newtonian_move(get_dir(target, src))
		thrown_thing.throw_at(target, thrown_thing.throw_range, thrown_thing.throw_speed, src, null, null, null, move_force)


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


/mob/living/carbon/fall(forced)
    loc?.handle_fall(src, forced)//it's loc so it doesn't call the mob's handle_fall which does nothing


/mob/living/carbon/resist_buckle()
	spawn(0)
		resist_muzzle()
	var/obj/item/I
	if((I = get_restraining_item())) // If there is nothing to restrain him then he is not restrained
		var/breakouttime = I.breakouttime
		var/displaytime = breakouttime / 10
		visible_message("<span class='warning'>[src.name] пыта[pluralize_ru(src.gender,"ет","ют")]ся себя отстегнуть!</span>", \
					"<span class='notice'>Вы пытаетесь себя отстегнуть... (Это займет около [displaytime] секунд и вам не нужно двигаться.)</span>")
		if(do_after(src, breakouttime, 0, target = src))
			if(!buckled)
				return
			buckled.user_unbuckle_mob(src,src)
		else
			if(src && buckled)
				to_chat(src, "<span class='warning'>Вам не удалось себя отстегнуть!</span>")
	else
		buckled.user_unbuckle_mob(src,src)


/mob/living/carbon/resist_fire()
	fire_stacks -= 5
	Weaken(6 SECONDS, TRUE) //We dont check for CANWEAKEN, I don't care how immune to weakening you are, if you're rolling on the ground, you're busy.
	update_canmove()
	spin(32,2)
	visible_message("<span class='danger'>[src.name] ката[pluralize_ru(src.gender,"ет","ют")]ся по полу, пытаясь потушиться!</span>", \
		"<span class='notice'>Вы остановились, упали и катаетесь!</span>")
	sleep(30)
	if(fire_stacks <= 0)
		visible_message("<span class='danger'>[src.name] успешно потушился!</span>", \
			"<span class='notice'>Вы потушились.</span>")
		ExtinguishMob()


/mob/living/carbon/get_standard_pixel_y_offset(lying = 0)
	if(lying)
		if(buckled)
			return buckled.buckle_offset //tg just has this whole block removed, always returning -6. Paradise is special.
		else
			return -6
	else
		return initial(pixel_y)

/mob/living/carbon/emp_act(severity)
	..()
	for(var/obj/item/organ/internal/organ as anything in internal_organs)
		organ.emp_act(severity)

/mob/living/carbon/Stat()
	..()
	if(statpanel("Status"))
		var/obj/item/organ/internal/xenos/plasmavessel/vessel = get_int_organ(/obj/item/organ/internal/xenos/plasmavessel)
		if(vessel)
			stat(null, "Plasma Stored: [vessel.stored_plasma]/[vessel.max_plasma]")
		var/obj/item/organ/internal/wryn/glands/glands = get_int_organ(/obj/item/organ/internal/wryn/glands)
		if(glands)
			stat(null, "Wax: [glands.wax]")


/mob/living/carbon/proc/slip(description, weaken, tilesSlipped, walkSafely, slipAny, grav_ignore = FALSE, slipVerb = "поскользнулись")
	if((movement_type & MOVETYPES_NOT_TOUCHING_GROUND) || buckled || (walkSafely && m_intent == MOVE_INTENT_WALK))
		return FALSE

	if(lying_angle && !tilesSlipped)
		return FALSE

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		var/turf/simulated/T = get_turf(H)
		if(!(slipAny) && isobj(H.shoes) && (H.shoes.flags & NOSLIP))
			return FALSE
		if(istype(H.shoes, /obj/item/clothing/shoes/magboots)) //Only for lubeprotection magboots and lube slip
			var/obj/item/clothing/shoes/magboots/humanmagboots = H.shoes
			if((T.wet == TURF_WET_LUBE||TURF_WET_PERMAFROST) && humanmagboots.magpulse && humanmagboots.lubeprotection)
				return FALSE
		if(!H.has_gravity() && !grav_ignore)
			if(istype(H.shoes, /obj/item/clothing/shoes/magboots)) //Only for magboots and lube slip (no grav && no lubeprotection)
				var/obj/item/clothing/shoes/magboots/humanmagboots = H.shoes
				if(!((T.wet == TURF_WET_LUBE||TURF_WET_PERMAFROST) && humanmagboots.magpulse))
					return FALSE
			else
				return FALSE

	if(tilesSlipped)
		for(var/i in 1 to tilesSlipped)
			spawn(i)
				step(src, dir)

	stop_pulling()
	to_chat(src, "<span class='notice'>Вы [slipVerb] на [description]!</span>")
	playsound(loc, 'sound/misc/slip.ogg', 50, 1, -3)
	// Something something don't run with scissors
	moving_diagonally = NONE //If this was part of diagonal move slipping will stop it.
	Weaken(weaken)
	return TRUE


/mob/living/carbon/proc/eat(var/obj/item/reagent_containers/food/toEat, mob/user, var/bitesize_override)
	if(!istype(toEat))
		return 0
	var/fullness = nutrition + 10
	if(istype(toEat, /obj/item/reagent_containers/food/snacks))
		for(var/datum/reagent/consumable/C in reagents.reagent_list) //we add the nutrition value of what we're currently digesting
			fullness += C.nutriment_factor * C.volume / (C.metabolization_rate * metabolism_efficiency * digestion_ratio)
	if(user == src)
		if(istype(toEat, /obj/item/reagent_containers/food/drinks))
			if(!selfDrink(toEat))
				return 0
		else
			if(!selfFeed(toEat, fullness))
				return 0
		if(toEat.log_eating)
			var/this_bite = bitesize_override ? bitesize_override : toEat.bitesize
			add_game_logs("Ate [toEat](bite volume: [this_bite*toEat.transfer_efficiency]) containing [toEat.reagents.log_list()]", src)
	else
		if(!forceFed(toEat, user, fullness))
			return 0
		var/this_bite = bitesize_override ? bitesize_override : toEat.bitesize
		add_attack_logs(user, src, "Force Fed [toEat](bite volume: [this_bite*toEat.transfer_efficiency]u) containing [toEat.reagents.log_list()]")
	consume(toEat, bitesize_override, can_taste_container = toEat.can_taste)
	SSticker.score.score_food_eaten++
	return 1


/mob/living/carbon/proc/selfFeed(var/obj/item/reagent_containers/food/toEat, fullness)
	if(ispill(toEat))
		to_chat(src, "<span class='notify'>You [toEat.apply_method] [toEat].</span>")
	else
		if(toEat.junkiness && satiety < -150 && nutrition > NUTRITION_LEVEL_STARVING + 50 )
			to_chat(src, "<span class='notice'>You don't feel like eating any more junk food at the moment.</span>")
			return 0
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
			return 0
	return 1


/mob/living/carbon/proc/selfDrink(var/obj/item/reagent_containers/food/drinks/toDrink, mob/user)
	return 1


/mob/living/carbon/proc/forceFed(var/obj/item/reagent_containers/food/toEat, mob/user, fullness)
	if(ispill(toEat) || fullness <= (600 * (1 + overeatduration / 1000)))
		if(!toEat.instant_application)
			visible_message("<span class='warning'>[user] attempts to force [src] to [toEat.apply_method] [toEat].</span>")
	else
		visible_message("<span class='warning'>[user] cannot force anymore of [toEat] down [src]'s throat.</span>")
		return 0
	if(!toEat.instant_application)
		if(!do_mob(user, src))
			return 0
	visible_message("<span class='warning'>[user] forces [src] to [toEat.apply_method] [toEat].</span>")
	return 1


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
	if(!iscarbon(src))
		return FALSE

	if(NO_BREATHE in dna?.species?.species_traits)
		return FALSE

	if(stat == DEAD)
		return FALSE

	if(!wear_mask)
		return TRUE

	if(!(wear_mask.flags & BLOCK_GAS_SMOKE_EFFECT) && internal == null)
		return TRUE

	return FALSE

//to recalculate and update the mob's total tint from tinted equipment it's wearing.
/mob/living/carbon/proc/update_tint()
	if(!GLOB.tinted_weldhelh)
		return
	var/tinttotal = get_total_tint()
	if(tinttotal >= TINT_BLIND)
		overlay_fullscreen("tint", /obj/screen/fullscreen/blind)
	else if(tinttotal >= TINT_IMPAIR)
		overlay_fullscreen("tint", /obj/screen/fullscreen/impaired, 2)
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

	see_invisible = initial(see_invisible)
	sight = initial(sight)
	lighting_alpha = initial(lighting_alpha)
	nightvision = initial(nightvision)

	for(var/obj/item/organ/internal/cyberimp/eyes/cyber_eyes in internal_organs)
		sight |= cyber_eyes.vision_flags
		if(cyber_eyes.see_in_dark)
			nightvision = max(nightvision, cyber_eyes.see_in_dark)
		if(cyber_eyes.see_invisible)
			see_invisible = min(see_invisible, cyber_eyes.see_invisible)
		if(!isnull(cyber_eyes.lighting_alpha))
			lighting_alpha = min(lighting_alpha, cyber_eyes.lighting_alpha)

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

	if(XRAY in mutations)
		sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_SIGHT)
	sync_lighting_plane_alpha()


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


/mob/living/carbon/get_pull_push_speed_modifier(current_delay)
	if(!canmove)
		return pull_push_speed_modifier * 1.2
	var/average_delay = (cached_multiplicative_slowdown + current_delay) / 2
	return current_delay > average_delay ? pull_push_speed_modifier : (average_delay / current_delay)


/mob/living/carbon/proc/shock_reduction()
	var/shock_reduction = 0
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.shock_reduction)
				shock_reduction += R.shock_reduction
	return shock_reduction


/mob/living/carbon/toggle_move_intent()
	if(legcuffed)
		to_chat(src, span_notice("Ваши ноги скованы! Вы не можете бежать, пока не снимете [legcuffed]!"))
		m_intent = MOVE_INTENT_WALK	//Just incase
		hud_used?.move_intent.icon_state = "walking"
		update_move_intent_slowdown()
		return
	return ..()

