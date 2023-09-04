/datum/disability/hemophage
	name = "Hemophage"
	var/bloodtotal = 0
	var/bloodusable = 0
	/// Who the vampire is draining of blood.
	var/mob/living/carbon/human/draining
	/// List of the peoples UIDs that we have drained, and how much blood from each one.
	var/list/drained_humans = list()

/datum/disability/hemophage/proc/adjust_blood(mob/living/carbon/user, blood_amount = 0)
	if(user)
		var/unique_suck_id = user.UID()
		if(!(unique_suck_id in drained_humans))
			drained_humans[unique_suck_id] = 0

		if(drained_humans[unique_suck_id] >= BLOOD_DRAIN_LIMIT)
			return

		drained_humans[unique_suck_id] += blood_amount

	bloodtotal += blood_amount
	bloodusable += blood_amount

#define BLOOD_GAINED_MODIFIER 0.5

/datum/disability/hemophage/proc/handle_bloodsucking(mob/living/carbon/human/target, suck_rate = 5 SECONDS)
	draining = target
	var/unique_suck_id = target.UID()
	var/blood = 0
	var/blood_volume_warning = 9999 //Blood volume threshold for warnings

	if(owner.current.is_muzzled())
		to_chat(owner.current, span_warning("[owner.current.wear_mask] prevents you from biting [target]!"))
		draining = null
		return

	add_attack_logs(owner.current, target, "vampirebit & is draining their blood.", ATKLOG_ALMOSTALL)
	owner.current.visible_message(span_danger("[owner.current] grabs [target]'s neck harshly and sinks in [owner.current.p_their()] fangs!"), \
								span_danger("You sink your fangs into [target] and begin to drain [target.p_their()] blood."), \
								span_italics("You hear a soft puncture and a wet sucking noise."))

	if(!iscarbon(owner.current))
		target.LAssailant = null
	else
		target.LAssailant = owner.current

	while(do_mob(owner.current, target, suck_rate))
		owner.current.face_atom(target)
		owner.current.do_attack_animation(target, ATTACK_EFFECT_BITE)
		if(unique_suck_id in drained_humans)
			if(drained_humans[unique_suck_id] >= BLOOD_DRAIN_LIMIT)
				to_chat(owner.current, span_warning("You have drained most of the life force from [target]'s blood, and you will get no more useable blood from them!"))
				target.blood_volume = max(target.blood_volume - 25, 0)
				owner.current.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, owner.current.nutrition + 5))
				continue


		if(target.stat < DEAD)
			if(target.ckey || target.player_ghosted) //Requires ckey regardless if monkey or humanoid, or the body has been ghosted before it died
				blood = min(20, target.blood_volume)
				adjust_blood(target, blood * BLOOD_GAINED_MODIFIER)
				to_chat(owner.current, span_boldnotice("You have accumulated [bloodtotal] unit\s of blood, and have [bloodusable] left to use."))

		target.blood_volume = max(target.blood_volume - 25, 0)

		//Blood level warnings (Code 'borrowed' from Fulp)
		if(target.blood_volume)
			if(target.blood_volume <= BLOOD_VOLUME_BAD && blood_volume_warning > BLOOD_VOLUME_BAD)
				to_chat(owner.current, span_danger("Your victim's blood volume is dangerously low."))

			else if(target.blood_volume <= BLOOD_VOLUME_OKAY && blood_volume_warning > BLOOD_VOLUME_OKAY)
				to_chat(owner.current, span_warning("Your victim's blood is at an unsafe level."))
			blood_volume_warning = target.blood_volume //Set to blood volume, so that you only get the message once

		else
			to_chat(owner.current, span_warning("You have bled your victim dry!"))
			break

		if(!target.ckey && !target.player_ghosted)//Only runs if there is no ckey and the body has not being ghosted while alive
			to_chat(owner.current, span_boldnotice("Feeding on [target] reduces your thirst, but you get no usable blood from them."))
			owner.current.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, owner.current.nutrition + 5))

		else
			owner.current.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, owner.current.nutrition + (blood / 2)))

	draining = null
	to_chat(owner.current, span_notice("You stop draining [target.name] of blood."))

#undef BLOOD_GAINED_MODIFIER

/datum/disability/hemophage/apply_disability(mob/current_mob)
	current_mob.dna.species.hunger_type = "vampire"
	current_mob.dna.species.hunger_icon = 'icons/mob/screen_hunger_vampire.dmi'
	return

/datum/disability/hemophage/proc/check_sun()
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
		to_chat(owner.current, span_warning("The starlight saps your strength!"))
		bloodusable -= 10
		hemophage_burn(10)

	else		//You're in trouble, get out of the sun NOW
		to_chat(owner.current, span_userdanger("Your body is turning to ash, get out of the light now!"))
		owner.current.adjustCloneLoss(10)	//I'm melting!
		hemophage_burn(85)
		if(owner.current.cloneloss >= 100)
			owner.current.dust()


/datum/disability/hemophage/proc/hemophage_burn(burn_chance)
	if(prob(burn_chance) && owner.current.health >= 50)
		switch(owner.current.health)
			if(75 to 100)
				to_chat(owner.current, span_warning("Your skin flakes away..."))
			if(50 to 75)
				to_chat(owner.current, span_warning("Your skin sizzles!"))
		owner.current.adjustFireLoss(3)

	else if(owner.current.health < 50)
		if(!owner.current.on_fire)
			to_chat(owner.current, span_danger("Your skin catches fire!"))
			owner.current.emote("scream")
		else
			to_chat(owner.current, span_danger("You continue to burn!"))
		owner.current.adjust_fire_stacks(5)
		owner.current.IgniteMob()

/datum/disability/hemophage/proc/handle_hemophage()
	if(owner.current.hud_used)
		var/datum/hud/hud = owner.current.hud_used
		if(!hud.vampire_blood_display)
			hud.vampire_blood_display = new /obj/screen()
			hud.vampire_blood_display.name = "Usable Blood"
			hud.vampire_blood_display.icon_state = "blood_display"
			hud.vampire_blood_display.screen_loc = "WEST:6,CENTER-1:15"
			hud.static_inventory += hud.vampire_blood_display
			hud.show_hud(hud.hud_version)
		hud.vampire_blood_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font face='Small Fonts' color='#ce0202'>[bloodusable]</font></div>"

	if(isspaceturf(get_turf(owner.current)))
		check_sun()

	if(is_type_in_typecache(get_area(owner.current), GLOB.holy_areas) && bloodtotal > 0)
		hemophage_burn(7)

/proc/ishemophage(datum/source)
	if(!source)
		return FALSE

	if(!has_variable(source, "mind"))
		if(has_variable(source, "disability_datums"))
			var/datum/mind/our_mind = source
			return our_mind.has_disability_datum(/datum/disability/hemophage)

		return FALSE

	if(!ismob(source))
		return FALSE

	var/mob/mind_holder = source
	if(!mind_holder.mind)
		return FALSE

	return mind_holder.mind.has_disability_datum(/datum/disability/hemophage)


