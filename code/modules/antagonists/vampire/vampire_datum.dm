/datum/antagonist/vampire
	name = "Vampire"
	antag_hud_type = ANTAG_HUD_VAMPIRE
	antag_hud_name = "hudvampire"
	job_rank = ROLE_VAMPIRE
	special_role = SPECIAL_ROLE_VAMPIRE
	wiki_page_name = "Vampire"
	russian_wiki_name = "Вампир"
	/// Total blood drained by vampire over round.
	var/bloodtotal = 0
	/// Current amount of blood.
	var/bloodusable = 0
	/// What vampire subclass the vampire is.
	var/datum/vampire_subclass/subclass
	/// Handles the vampire cloak toggle.
	var/iscloaking = FALSE
	/// Handles the goon vampire cloak toggle.
	var/is_goon_cloak = FALSE
	/// List of available powers and passives.
	var/list/powers = list()
	/// Who the vampire is draining of blood.
	var/mob/living/carbon/human/draining
	/// Nullrods and holywater make their abilities cost more.
	var/nullified = 0
	/// Time between each suck iteration.
	var/suck_rate = 5 SECONDS
	/// Indicates the type of nullification (old or new)
	var/nullification = NEW_NULLIFICATION
	/// Does garlic affect vampire?
	var/is_garlic_affected = FALSE
	/// Does a vampire turn to dust after dying from space?
	var/dust_in_space = FALSE
	/// List of powers that all vampires unlock and at what blood level they unlock them, the rest of their powers are found in the vampire_subclass datum.
	var/list/upgrade_tiers = list()

	/// List of the peoples UIDs that we have drained, and how much blood from each one.
	var/list/drained_humans = list()
	/// List of the peoples UIDs that we have dissected, and how many times for each one.
	var/list/dissected_humans = list()
	/// Associated list of all damage modifiers human vampire has.
	var/list/damage_modifiers = list(
		BRUTE = 1,
		BURN = 1,
		TOX = 1,
		OXY = 1,
		CLONE = 1,
		BRAIN = 1,
		STAMINA = 1,
	)


/datum/antagonist/vampire/Destroy(force)
	owner.current.create_log(CONVERSION_LOG, "De-vampired")
	draining = null
	QDEL_NULL(subclass)
	return ..()


/datum/antagonist/vampire/greet()
	var/list/messages = list()
	SEND_SOUND(owner.current, sound('sound/ambience/antag/vampalert.ogg'))
	messages.Add("<span class='danger'>Вы — вампир!</span><br>")
	messages.Add("Чтобы укусить кого-то, нацельтесь в голову, выберите намерение вреда (4) и ударьте пустой рукой. Пейте кровь, чтобы получать новые силы. \
		Вы уязвимы перед святостью, огнем и звёздным светом. Не выходите в космос, избегайте священника, церкви и, особенно, святой воды.")
	return messages


/datum/antagonist/vampire/farewell()
	if(issilicon(owner.current))
		to_chat(owner.current, span_userdanger("Вы превратились в робота! Вы чувствуете как вампирские силы исчезают…"))
	else
		to_chat(owner.current, span_userdanger("Ваш разум очищен! Вы больше не вампир."))

/datum/antagonist/vampire/give_objectives()
	add_objective(/datum/objective/blood)
	add_objective(/datum/objective/maroon)
	add_objective(/datum/objective/steal)

	if(prob(20)) // 20% chance of getting survive. 80% chance of getting escape.
		add_objective(/datum/objective/survive)
	else
		add_objective(/datum/objective/escape)


/datum/antagonist/vampire/on_body_transfer(mob/living/old_body, mob/living/new_body)
	if(isvampireanimal(new_body))
		remove_innate_effects(old_body, transformation = TRUE)
		apply_innate_effects(new_body, transformation = TRUE)
	else
		remove_innate_effects(old_body)
		apply_innate_effects(new_body)


/datum/antagonist/vampire/apply_innate_effects(mob/living/mob_override, transformation = FALSE)
	var/mob/living/user = ..()

	if(!owner.som) //thralls and mindslaves
		owner.som = new()
		owner.som.masters += owner

	if(!transformation)
		check_vampire_upgrade(announce = FALSE)
		user.faction |= ROLE_VAMPIRE
		user.dna?.species?.hunger_type = "vampire"
		user.dna?.species?.hunger_icon = 'icons/mob/screen_hunger_vampire.dmi'
		//goon vampire slaves code
		//if(mob_override.mind.som)
			//var/datum/mindslaves/slaved = mob_override.mind.som
			//slaved.masters -= mob_override.mind
			//slaved.serv -= mob_override.mind
			//slaved.leave_serv_hud(mob_override.mind)
			//.mind.som = null


/datum/antagonist/vampire/remove_innate_effects(mob/living/mob_override, transformation = FALSE)
	var/mob/living/user = ..()

	if(!mob_override)	// mob override means body transfer
		remove_all_powers()

	if(!transformation)
		user.faction -= ROLE_VAMPIRE

		var/datum/hud/hud = user.hud_used
		if(hud?.vampire_blood_display)
			hud.remove_vampire_hud()

		user.dna?.species?.hunger_type = initial(user.dna.species.hunger_type)
		user.dna?.species?.hunger_icon = initial(user.dna.species.hunger_icon)

	animate(user, alpha = 255)
	REMOVE_TRAITS_IN(user, VAMPIRE_TRAIT)


/**
 * Remove the vampire's current subclass and add the specified one.
 *
 * Arguments:
 * * new_subclass_type - a [/datum/vampire_subclass] typepath
 */
/datum/antagonist/vampire/proc/change_subclass(new_subclass_type)
	if(isnull(new_subclass_type))
		return

	clear_subclass(FALSE)
	add_subclass(new_subclass_type, log_choice = FALSE)


/**
 * Remove and delete the vampire's current subclass and all associated abilities.
 *
 * Arguments:
 * * give_specialize_power - if the [specialize][/obj/effect/proc_holder/spell/vampire/self/specialize] power should be given back or not
 */
/datum/antagonist/vampire/proc/clear_subclass(give_specialize_power = TRUE)
	if(give_specialize_power)
		// Choosing a subclass in the first place removes this from `upgrade_tiers`, so add it back if needed.
		upgrade_tiers[/obj/effect/proc_holder/spell/vampire/self/specialize] = 150

	suck_rate = initial(suck_rate)
	remove_all_powers()
	QDEL_NULL(subclass)
	check_vampire_upgrade()


/datum/antagonist/vampire/proc/adjust_blood(mob/living/carbon/user, blood_amount = 0)
	if(user)
		var/unique_suck_id = user.UID()
		if(!(unique_suck_id in drained_humans))
			drained_humans[unique_suck_id] = 0

		if(drained_humans[unique_suck_id] >= BLOOD_DRAIN_LIMIT)
			return

		drained_humans[unique_suck_id] += blood_amount

	bloodtotal += blood_amount
	bloodusable += blood_amount
	check_vampire_upgrade(TRUE)

	for(var/obj/effect/proc_holder/spell/power in powers)
		if(power.action)
			power.action.UpdateButtonIcon()


#define BLOOD_GAINED_MODIFIER 0.5

#define CLOSING_IN_TIME_MOD 0.2
#define GRABBING_TIME_MOD 0.3
#define BITE_TIME_MOD 0.15

#define STATE_CLOSING_IN 1
#define STATE_GRABBING 2
#define STATE_BITE 3
#define STATE_SUCKING 4

/datum/antagonist/vampire/proc/handle_bloodsucking(mob/living/carbon/human/target, suck_rate_override)
	draining = target
	var/unique_suck_id = target.UID()
	var/blood = 0
	var/blood_volume_warning = 9999 //Blood volume threshold for warnings
	var/cycle_counter = 0
	var/time_per_action
	var/vampire_dir = get_dir(owner.current, target)

	var/old_bloodusable = 0 //used to see if we increased our blood usable

	var/suck_rate_final
	if(suck_rate_override)
		suck_rate_final = suck_rate_override
	else
		suck_rate_final = suck_rate

	if(owner.current.is_muzzled())
		to_chat(owner.current, span_warning("[owner.current.wear_mask] мешает вам укусить [target]!"))
		draining = null
		return

	add_attack_logs(owner.current, target, "vampirebit & is draining their blood.", ATKLOG_ALMOSTALL)

	if(!iscarbon(owner.current))
		target.LAssailant = null
	else
		target.LAssailant = owner.current

	var/is_target_grabbed = FALSE
	if(target.pulledby == owner.current && owner.current.grab_state > GRAB_PASSIVE)
		is_target_grabbed = TRUE

	if(!is_target_grabbed || vampire_dir == NORTHEAST || vampire_dir == NORTHWEST || \
		vampire_dir ==  SOUTHEAST || vampire_dir ==  SOUTHWEST)
		//first, the vampire gets closer to the victim, its quick
		time_per_action = suck_rate_final*CLOSING_IN_TIME_MOD
	else
		//skip getting_closer_animation(), if we are already close enough
		cycle_counter = STATE_GRABBING
		time_per_action = suck_rate_final*BITE_TIME_MOD

	while(do_after(owner.current, time_per_action, target, NONE, interaction_key = DOAFTER_SOURCE_VAMPIRE_SUCKING, max_interact_count = 1))
		cycle_counter++
		owner.current.face_atom(target)
		old_bloodusable = bloodusable
		switch(cycle_counter)
			if(STATE_CLOSING_IN)
				owner.current.visible_message(span_danger("[owner.current] приближается к [target]"), \
					span_danger("Вы приближаетесь к [target]"))
				getting_closer_animation(target, STATE_CLOSING_IN, vampire_dir)
				time_per_action = suck_rate_final*GRABBING_TIME_MOD
				continue
			if(STATE_GRABBING)
				owner.current.visible_message(span_danger("[owner.current] грубо хватает шею [target]"), \
					span_danger("Вы грубо хватает шею [target]"))
				getting_closer_animation(target, STATE_GRABBING, vampire_dir)
				time_per_action = suck_rate_final*BITE_TIME_MOD
				continue
			if(STATE_BITE)
				owner.current.visible_message(span_danger("[owner.current] вонзает [genderize_ru(owner.current.gender, "его", "её", "его", "их")] клыки!"), \
					span_danger("Вы вонзаете клыки в шею [target] и начинаете высасывать [genderize_ru(target.gender, "его", "её", "его", "их")] кровь."), \
					span_italics("Вы слышите тихий звук прокола и влажные хлюпающие звуки."))
				bite_animation(target, vampire_dir)
				time_per_action = suck_rate_final
				continue

		if(unique_suck_id in drained_humans)
			if(drained_humans[unique_suck_id] >= BLOOD_DRAIN_LIMIT)
				to_chat(owner.current, span_warning("Вы поглотили всю жизненную эссенцию [target], дальнейшее питьё крови будет только утолять голод!"))
				target.blood_volume = max(target.blood_volume - 25, 0)
				owner.current.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, owner.current.nutrition + 5))
				continue


		if(target.stat < DEAD || target.has_status_effect(STATUS_EFFECT_RECENTLY_SUCCUMBED))
			if(target.ckey || target.player_ghosted) //Requires ckey regardless if monkey or humanoid, or the body has been ghosted before it died
				blood = min(20, target.blood_volume)
				adjust_blood(target, blood * BLOOD_GAINED_MODIFIER)
				to_chat(owner.current, span_boldnotice("Вы накопили [bloodtotal] единиц[declension_ru(bloodtotal, "у", "ы", "")] крови[bloodusable != old_bloodusable ? ", и теперь вам доступно [bloodusable] единиц[declension_ru(bloodusable, "а", "ы", "")] крови" : ""]."))

		target.blood_volume = max(target.blood_volume - 25, 0)

		//Blood level warnings (Code 'borrowed' from Fulp)
		if(target.blood_volume)
			if(target.blood_volume <= BLOOD_VOLUME_BAD && blood_volume_warning > BLOOD_VOLUME_BAD)
				to_chat(owner.current, span_danger("У вашей жертвы остаётся опасно мало крови!"))

			else if(target.blood_volume <= BLOOD_VOLUME_OKAY && blood_volume_warning > BLOOD_VOLUME_OKAY)
				to_chat(owner.current, span_warning("У вашей жертвы остаётся тревожно мало крови!"))
			blood_volume_warning = target.blood_volume //Set to blood volume, so that you only get the message once

		else
			to_chat(owner.current, span_warning("Вы выпили свою жертву досуха!"))
			break

		if(!target.ckey && !target.player_ghosted)//Only runs if there is no ckey and the body has not being ghosted while alive
			to_chat(owner.current, span_boldnotice("Питьё крови у [target] насыщает вас, но доступной крови от этого вы не получаете."))
			owner.current.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, owner.current.nutrition + 5))

		else
			owner.current.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, owner.current.nutrition + (blood / 2)))

	stop_sucking()


/datum/antagonist/vampire/proc/getting_closer_animation(mob/living/carbon/human/target, stage, vampire_dir)
	var/shift = 0
	owner.current.layer = MOB_LAYER
	switch(stage)
		if(STATE_CLOSING_IN)
			shift = 8
		if(STATE_GRABBING)
			shift = 20

	var/pixel_x_diff = 0
	var/pixel_y_diff = 0

	if(vampire_dir & NORTH)
		pixel_y_diff = shift
	else if(vampire_dir & SOUTH)
		pixel_y_diff = -shift
		//If vampire is standing north of the target and facing south, the target should be displayed on top of the vampire
		owner.current.layer = BEHIND_MOB_LAYER

	if(vampire_dir & EAST)
		pixel_x_diff = shift
	else if(vampire_dir & WEST)
		pixel_x_diff = -shift

	animate(owner.current, pixel_x = pixel_x_diff, pixel_y = pixel_y_diff, 5, 1, LINEAR_EASING)

/datum/antagonist/vampire/proc/bite_animation(mob/living/carbon/human/target, vampire_dir)
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0

	if(vampire_dir & NORTH)
		pixel_y_diff = 8
	else if(vampire_dir & SOUTH)
		pixel_y_diff = -8

	if(vampire_dir & EAST)
		pixel_x_diff = 8
	else if(vampire_dir & WEST)
		pixel_x_diff = -8
	animate(owner.current, pixel_x = owner.current.pixel_x + pixel_x_diff, pixel_y = owner.current.pixel_y + pixel_y_diff, time = 0.5)
	animate(pixel_x = owner.current.pixel_x - pixel_x_diff, pixel_y = owner.current.pixel_y - pixel_y_diff, time = 7)
	owner.current.do_item_attack_animation(target, ATTACK_EFFECT_BITE)


/datum/antagonist/vampire/proc/stop_sucking()
	if(draining)
		to_chat(owner.current, span_notice("Вы прекращаете пить кровь [draining.name]."))
		draining = null
		owner.current.pixel_x = owner.current.base_pixel_x + owner.current.body_position_pixel_x_offset
		owner.current.pixel_y = owner.current.base_pixel_y + owner.current.body_position_pixel_y_offset
		owner.current.layer = initial(owner.current.layer)

#undef BLOOD_GAINED_MODIFIER
#undef CLOSING_IN_TIME_MOD
#undef GRABBING_TIME_MOD
#undef BITE_TIME_MOD
#undef STATE_CLOSING_IN
#undef STATE_GRABBING
#undef STATE_BITE
#undef STATE_SUCKING

/datum/antagonist/vampire/proc/force_add_ability(path)
	var/spell = new path(owner)
	if(istype(spell, /obj/effect/proc_holder/spell))
		owner.AddSpell(spell)
		if(istype(spell, /obj/effect/proc_holder/spell/vampire) && subclass)
			var/obj/effect/proc_holder/spell/vampire/v_spell = spell
			v_spell.on_trophie_update(src, force = TRUE)
		if(istype(spell, /obj/effect/proc_holder/spell/vampire/self/dissect_info) && subclass)
			subclass.spell_TGUI = spell

	else if(istype(spell, /datum/vampire_passive))
		var/datum/vampire_passive/passive = spell
		passive.owner = owner.current
		passive.on_apply(src)
	powers += spell
	owner.current.update_sight() // Life updates conditionally, so we need to update sight here in case the vamp gets new vision based on his powers. Maybe one day refactor to be more OOP and on the vampire's ability datum.
	return spell


/datum/antagonist/vampire/proc/get_ability(path)
	for(var/datum/power as anything in powers)
		if(power.type == path)
			return power
	return null


/datum/antagonist/vampire/proc/add_ability(path)
	if(!get_ability(path))
		force_add_ability(path)


/datum/antagonist/vampire/proc/remove_ability(ability)
	if(ability && (ability in powers))
		powers -= ability
		if(istype(ability, /obj/effect/proc_holder/spell/vampire/self/dissect_info) && subclass)
			subclass.spell_TGUI = null
		if(istype(ability, /obj/effect/proc_holder/spell))
			owner.RemoveSpell(ability)
		else if(istype(ability, /datum/vampire_passive))
			qdel(ability)
		owner.current.update_sight() // Life updates conditionally, so we need to update sight here in case the vamp loses his vision based powers. Maybe one day refactor to be more OOP and on the vampire's ability datum.


/**
 * Removes all of the vampire's current powers.
 */
/datum/antagonist/vampire/proc/remove_all_powers()
	for(var/power in powers)
		remove_ability(power)


/datum/antagonist/vampire/proc/check_vampire_upgrade(announce = TRUE)
	var/list/old_powers = powers.Copy()

	for(var/ptype in upgrade_tiers)
		var/level = upgrade_tiers[ptype]
		if(bloodtotal >= level)
			add_ability(ptype)

	if(!subclass)
		if(announce)
			announce_new_power(old_powers)
		return

	subclass.add_subclass_ability(src)

	if(subclass.spell_TGUI)
		SStgui.update_uis(subclass.spell_TGUI, TRUE)

	check_full_power_upgrade()
	check_trophies_passives()

	if(announce)
		announce_new_power(old_powers)


/datum/antagonist/vampire/proc/check_full_power_upgrade()
	if(subclass.full_power_override || (length(drained_humans) >= FULLPOWER_DRAINED_REQUIREMENT && bloodtotal >= FULLPOWER_BLOODTOTAL_REQUIREMENT))
		subclass.add_full_power_abilities(src)


/datum/antagonist/vampire/proc/announce_new_power(list/old_powers)
	for(var/p in powers)
		if(!(p in old_powers))
			if(istype(p, /obj/effect/proc_holder/spell))
				var/obj/effect/proc_holder/spell/power = p
				to_chat(owner.current, span_boldnotice("[power.gain_desc]"))

			else if(istype(p, /datum/vampire_passive))
				var/datum/vampire_passive/power = p
				to_chat(owner.current, span_boldnotice("[power.gain_desc]"))


/datum/antagonist/vampire/proc/check_sun()
	var/ax = owner.current.x
	var/ay = owner.current.y

	for(var/i = 1 to 20)
		ax += SSsun.dx
		ay += SSsun.dy

		var/turf/T = locate(round(ax, 0.5), round(ay, 0.5), owner.current.z)

		if(!T)
			return

		if(T.x == 1 || T.x == world.maxx || T.y == 1 || T.y == world.maxy)
			break

		if(T.density)
			return

	if(bloodusable >= 10)	//burn through your blood to tank the light for a little while
		to_chat(owner.current, span_warning("Свет звёзд жжётся и истощает ваши силы!"))
		bloodusable -= 10
		vamp_burn(10)

	else		//You're in trouble, get out of the sun NOW
		to_chat(owner.current, span_userdanger("Ваше тело обугливается, превращаясь в пепел! Укройтесь от звёздного света!"))
		owner.current.adjustCloneLoss(10)	//I'm melting!
		vamp_burn(85)
		if(owner.current.cloneloss >= 100 && dust_in_space)
			owner.current.dust()


/datum/antagonist/vampire/proc/vamp_burn(burn_chance)

	if(isvampireanimal(owner.current))
		var/half_health = round(owner.current.maxHealth / 2)

		if(prob(burn_chance) && owner.current.health >= half_health)
			to_chat(owner.current, span_warning("Вы чувствуете нестерпимый жар!"))
			owner.current.adjustFireLoss(3)

		else if(owner.current.health < half_health)
			to_chat(owner.current, span_warning("Вы плавитесь!"))
			owner.current.adjustFireLoss(8)

		return

	if(prob(burn_chance) && owner.current.health >= 50)
		switch(owner.current.health)
			if(75 to 100)
				to_chat(owner.current, span_warning("Ваша кожа дымится…"))
			if(50 to 75)
				to_chat(owner.current, span_warning("Ваша кожа шипит!"))
		owner.current.adjustFireLoss(3)

	else if(owner.current.health < 50)
		if(!owner.current.on_fire)
			to_chat(owner.current, span_danger("Ваша кожа загорается!"))
			owner.current.emote("scream")
		else
			to_chat(owner.current, span_danger("Вы продолжаете гореть!"))
		owner.current.adjust_fire_stacks(5)
		owner.current.IgniteMob()


/datum/antagonist/vampire/proc/handle_vampire()
	draw_HUD()

	handle_vampire_cloak()
	if(isspaceturf(get_turf(owner.current)))
		check_sun()

	if(is_type_in_typecache(get_area(owner.current), GLOB.holy_areas) && !get_ability(/datum/vampire_passive/full) && bloodtotal > 0)
		vamp_burn(7)
	switch(nullification)
		if(OLD_NULLIFICATION)
			nullified = max(0, nullified - 1)

		if(NEW_NULLIFICATION)
			nullified = max(0, nullified - 2)


/datum/antagonist/vampire/proc/draw_HUD()
	var/datum/hud/hud = owner?.current?.hud_used
	if(!hud)
		return

	if(!hud.vampire_blood_display)
		hud.vampire_blood_display = new /atom/movable/screen()
		hud.vampire_blood_display.name = "Доступная кровь"
		hud.vampire_blood_display.icon_state = "blood_display"
		hud.vampire_blood_display.screen_loc = "WEST:6,CENTER-1:15"
		hud.static_inventory += hud.vampire_blood_display
		hud.show_hud(hud.hud_version)
	hud.vampire_blood_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font face='Small Fonts' color='#ce0202'>[bloodusable]</font></div>"


/datum/antagonist/vampire/proc/handle_vampire_cloak()
	if(!ishuman(owner.current))
		animate(owner.current, time = 5, alpha = 255)
		return
	var/turf/simulated/owner_turf = get_turf(owner.current)
	var/light_available = ((iscloaking)?owner_turf.get_lumcount():owner_turf.get_lumcount(0.5)) * 10

	if(!istype(owner_turf))
		return

	if(!iscloaking && !is_goon_cloak || owner.current.on_fire)
		animate(owner.current, time = 5, alpha = 255)
		owner.current.remove_movespeed_modifier(/datum/movespeed_modifier/vampire_cloak)
		return

	if(light_available <= 2)
		animate(owner.current, time = 5, alpha = 38)
		if(iscloaking)
			owner.current.add_movespeed_modifier(/datum/movespeed_modifier/vampire_cloak)
		return
	owner.current.remove_movespeed_modifier(/datum/movespeed_modifier/vampire_cloak)
	animate(owner.current, time = 5, alpha = 204) // 255 * 0.80


/datum/antagonist/vampire/vv_edit_var(var_name, var_value)
	. = ..()
	check_vampire_upgrade(TRUE)


/datum/hud/proc/remove_vampire_hud()
	static_inventory -= vampire_blood_display
	QDEL_NULL(vampire_blood_display)


/datum/antagonist/vampire/proc/adjust_nullification(base, extra)
	// First hit should give full nullification, while subsequent hits increase the value slower
	switch(nullification)
		if(OLD_NULLIFICATION)
			nullified = max(base, nullified + extra)

		if(NEW_NULLIFICATION)
			nullified = clamp(nullified + extra, base, VAMPIRE_NULLIFICATION_CAP)


/datum/antagonist/vampire/proc/base_nullification()
	switch(nullification)
		if(OLD_NULLIFICATION)
			adjust_nullification(5, 2)

		if(NEW_NULLIFICATION)
			adjust_nullification(20, 4)


/**
 * Takes any datum `source` and checks it for vampire datum.
 */
/proc/isvampire(datum/source)
	if(!source)
		return FALSE

	if(istype(source, /datum/mind))
		var/datum/mind/our_mind = source
		return our_mind.has_antag_datum(/datum/antagonist/vampire)

	if(!ismob(source))
		return FALSE

	var/mob/mind_holder = source
	if(!mind_holder.mind)
		return FALSE

	return mind_holder.mind.has_antag_datum(/datum/antagonist/vampire)


/**
 * Takes any datum `source` and checks it for vampire thrall datum.
 */
/proc/isvampirethrall(datum/source)
	if(!source)
		return FALSE

	if(istype(source, /datum/mind))
		var/datum/mind/our_mind = source
		return our_mind.has_antag_datum(/datum/antagonist/mindslave/thrall)

	if(!isliving(source))
		return FALSE

	var/mob/living/mind_holder = source
	if(!mind_holder.mind)
		return FALSE

	return mind_holder.mind.has_antag_datum(/datum/antagonist/mindslave/thrall)


/datum/antagonist/mindslave/thrall
	name = "Vampire Thrall"
	antag_hud_type = ANTAG_HUD_VAMPIRE
	antag_hud_name = "vampthrall"
	master_hud_icon = "vampire"

/datum/antagonist/mindslave/thrall/greet()
	var/greet_text = "<b>Вы были очарованы [master.current.real_name]. Следуйте каждому [genderize_ru(master.current.gender, "его", "её", "его", "их")] приказу.</b>"
	return span_dangerbigger(greet_text)

/datum/antagonist/mindslave/thrall/farewell()
	if(issilicon(owner.current))
		to_chat(owner.current, span_userdanger("Вы превратились в робота! Вы больше не очарованы…"))
	else
		to_chat(owner.current, span_userdanger("Ваш разум очищен! Вы больше не очарованы."))

/datum/antagonist/mindslave/thrall/apply_innate_effects(mob/living/mob_override)
	var/mob/living/user = ..()
	user.faction |= ROLE_VAMPIRE
	return user


/datum/antagonist/mindslave/thrall/remove_innate_effects(mob/living/mob_override)
	var/mob/living/user = ..()
	user.faction -= ROLE_VAMPIRE
	return user
