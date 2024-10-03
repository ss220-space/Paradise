#define NITROGEN_RETARDATION_FACTOR 0.15	//Higher == N2 slows reaction more
#define THERMAL_RELEASE_MODIFIER 10000		//Higher == more heat released during reaction
#define PLASMA_RELEASE_MODIFIER 1500		//Higher == less phor.. plasma released by reaction
#define OXYGEN_RELEASE_MODIFIER 15000		//Higher == less oxygen released at high temperature/power
#define REACTION_POWER_MODIFIER 1.1			//Higher == more overall power
#define SHARD_CUT_COEF 7

/*
	How to tweak the SM
	POWER_FACTOR		directly controls how much power the SM puts out at a given level of excitation (power var). Making this lower means you have to work the SM harder to get the same amount of power.
	CRITICAL_TEMPERATURE	The temperature at which the SM starts taking damage.
	CHARGING_FACTOR		Controls how much emitter shots excite the SM.
	DAMAGE_RATE_LIMIT	Controls the maximum rate at which the SM will take damage due to high temperatures.
*/

//Controls how much power is produced by each collector in range - this is the main parameter for tweaking SM balance, as it basically controls how the power variable relates to the rest of the game.
#define POWER_FACTOR 1.0
#define DECAY_FACTOR 700			//Affects how fast the supermatter power decays
#define CRITICAL_TEMPERATURE 10000	//K
#define CHARGING_FACTOR 0.05
#define DAMAGE_RATE_LIMIT 4.5		//damage rate cap at power = 300, scales linearly with power


// Base variants are applied to everyone on the same Z level
// Range variants are applied on per-range basis: numbers here are on point blank, it scales with the map size (assumes square shaped Z levels)
#define DETONATION_RADS 200
#define DETONATION_HALLUCINATION 600


#define WARNING_DELAY 20			//seconds between warnings.
/obj/machinery/power/supermatter_shard
	name = "supermatter shard"
	desc = "A strangely translucent and iridescent crystal that looks like it used to be part of a larger structure. <span class='danger'>You get headaches just from looking at it.</span>"
	icon = 'icons/obj/engines_and_power/supermatter.dmi'
	icon_state = "darkmatter_shard"
	density = TRUE
	anchored = FALSE
	light_range = 4
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF | NO_MALF_EFFECT


	var/gasefficency = 0.125

	base_icon_state = "darkmatter_shard"
	var/zap_sound_extrarange = 5

	var/damage = 0
	var/damage_archived = 0
	var/safe_alert = "Гиперструктура кристалла возвращается к безопасному эксплуатационному уровню."
	var/warning_point = 50
	var/warning_alert = "ОПАСНОСТЬ! Дестабилизация гиперструктуры кристалла!"
	var/emergency_point = 400
	var/emergency_alert = "РАСЩЕПЛЕНИЕ КРИСТАЛЛА НЕМИНУЕМО."
	var/explosion_point = 600

	var/emergency_issued = 0

	var/explosion_power = 8

	var/lastwarning = 0				// Time in 1/10th of seconds since the last sent warning
	var/last_zap = 0				// Time in 1/10th of seconds since the last tesla zap
	var/power = 0

	var/oxygen = 0					// Moving this up here for easier debugging.

	//Temporary values so that we can optimize this
	//How much the bullets damage should be multiplied by when it is added to the internal variables
	var/config_bullet_energy = 2
	//How much hallucination should it produce per unit of power?
	var/config_hallucination_power = 0.1

	var/debug = 0

	var/disable_adminwarn = FALSE

	var/aw_normal = FALSE
	var/aw_notify = FALSE
	var/aw_warning = FALSE
	var/aw_danger = FALSE
	var/aw_emerg = FALSE
	var/aw_delam = FALSE

	var/obj/item/radio/radio

	//for logging
	var/has_been_powered = 0
	var/has_reached_emergency = 0

	var/datum/supermatter_explosive_effects/supermatter_explosive_effects

/obj/machinery/power/supermatter_shard/crystal
	name = "supermatter crystal"
	desc = "A strangely translucent and iridescent crystal."
	base_icon_state = "darkmatter"
	icon_state = "darkmatter"
	anchored = TRUE
	warning_point = 200
	emergency_point = 2000
	explosion_point = 3600
	gasefficency = 0.25
	explosion_power = 24


/obj/machinery/power/supermatter_shard/New()
	. = ..()
	GLOB.poi_list |= src
	//Added to the atmos_machine process as the SM is highly coupled with the atmospherics system.
	//Having the SM run at a different rate then atmospherics causes odd behavior.
	SSair.atmos_machinery += src
	radio = new(src)
	radio.listening = 0
	investigate_log("has been created.", INVESTIGATE_ENGINE)
	supermatter_explosive_effects = new()
	supermatter_explosive_effects.z = src.z


/obj/machinery/power/supermatter_shard/proc/handle_admin_warnings()
	if(disable_adminwarn)
		return

	// Generic checks, similar to checks done by supermatter monitor program.
	aw_normal = status_adminwarn_check(SUPERMATTER_NORMAL, aw_normal, "INFO: Supermatter crystal has been energised.<a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>(JMP)</a>.", FALSE)
	aw_notify = status_adminwarn_check(SUPERMATTER_NOTIFY, aw_notify, "INFO: Supermatter crystal is approaching unsafe operating temperature.<a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>(JMP)</a>.", FALSE)
	aw_warning = status_adminwarn_check(SUPERMATTER_WARNING, aw_warning, "WARN: Supermatter crystal is taking integrity damage!<a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>(JMP)</a>.", FALSE)
	aw_danger = status_adminwarn_check(SUPERMATTER_DANGER, aw_danger, "WARN: Supermatter integrity is below 75%!<a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>(JMP)</a>.", TRUE)
	aw_emerg = status_adminwarn_check(SUPERMATTER_EMERGENCY, aw_emerg, "CRIT: Supermatter integrity is below 50%!<a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>(JMP)</a>.", FALSE)
	aw_delam = status_adminwarn_check(SUPERMATTER_DELAMINATING, aw_delam, "CRIT: Supermatter is delaminating!<a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>(JMP)</a>.", TRUE)

/obj/machinery/power/supermatter_shard/proc/status_adminwarn_check(min_status, current_state, message)
	var/status = get_status()
	if(status >= min_status)
		if(!current_state)
			log_and_message_admins(message)
			investigate_log(message, INVESTIGATE_ENGINE)
			// SSdiscord.send2discord_simple_noadmins(message)
		return TRUE
	else
		return FALSE


/obj/machinery/power/supermatter_shard/Destroy()
	investigate_log("has been destroyed.", INVESTIGATE_ENGINE)
	if(damage > emergency_point)
		emergency_lighting(0)
	QDEL_NULL(radio)
	GLOB.poi_list.Remove(src)
	SSair.atmos_machinery -= src
	return ..()

/obj/machinery/power/supermatter_shard/proc/explode()
	investigate_log("has exploded.", INVESTIGATE_ENGINE)
	supermatter_explosive_effects.z = src.z
	supermatter_explosive_effects.handle_special_effects()
	explosion(get_turf(src), explosion_power, explosion_power * 1.2, explosion_power * 1.5, explosion_power * 2, 1, 1, cause = src)
	qdel(src)
	return

/obj/machinery/power/supermatter_shard/process_atmos()
	var/turf/L = loc

	if(isnull(L))		// We have a null turf...something is wrong, stop processing this entity.
		return PROCESS_KILL

	if(!istype(L)) 	//We are in a crate or somewhere that isn't turf, if we return to turf resume processing but for now.
		return  //Yeah just stop.

	if(damage > warning_point) // while the core is still damaged and it's still worth noting its status
		if((world.timeofday - lastwarning) / 10 >= WARNING_DELAY)
			alarm()
			emergency_lighting(1)
			var/stability = num2text(round((damage / explosion_point) * 100))

			if(damage > emergency_point)
				radio.autosay("[emergency_alert] Дестабилизация: [stability]%", src.name)
				lastwarning = world.timeofday
				if(!has_reached_emergency)
					investigate_log("has reached the emergency point for the first time.", INVESTIGATE_ENGINE)
					message_admins("[src] has reached the emergency point [ADMIN_COORDJMP(src)].")
					has_reached_emergency = 1

			else if(damage >= damage_archived) // The damage is still going up
				radio.autosay("[warning_alert] Дестабилизация: [stability]%", src.name)
				lastwarning = world.timeofday - 150

			else                                                 // Phew, we're safe
				radio.autosay("[safe_alert]", src.name)
				emergency_lighting(0)
				lastwarning = world.timeofday

		if(damage > explosion_point)
			if(get_turf(src))
				var/turf/position = get_turf(src)
				for(var/mob/living/mob in GLOB.alive_mob_list)
					var/turf/mob_pos = get_turf(mob)
					if(mob_pos && mob_pos.z == position.z)
						if(ishuman(mob))
							//Hilariously enough, running into a closet should make you get hit the hardest.
							var/mob/living/carbon/human/H = mob
							H.AdjustHallucinate(max(100 SECONDS, min(300 SECONDS, DETONATION_HALLUCINATION * sqrt(1 / (get_dist(mob, src) + 1)))))
							H.last_hallucinator_log = "Supermatter explosion"
						var/rads = DETONATION_RADS * sqrt( 1 / (get_dist(mob, src) + 1) )
						mob.apply_effect(rads, IRRADIATE)
			explode()
			emergency_lighting(0)
			//It's kinda pointless to process atmos on destroyed (qdel'ed) crystal
			return

	if(damage > warning_point && world.timeofday > last_zap)
		last_zap = world.timeofday + rand(80,200)
		supermatter_zap()

	//Ok, get the air from the turf
	var/datum/gas_mixture/env = L.return_air()
	//And, get part of that air
	var/datum/gas_mixture/removed = env.remove(gasefficency * env.total_moles())

	//ensure that damage doesn't increase too quickly due to super high temperatures resulting from no coolant, for example. We dont want the SM exploding before anyone can react.
	//We want the cap to scale linearly with power (and explosion_point). Let's aim for a cap of 5 at power = 300 (based on testing, equals roughly 5% per SM alert announcement).
	var/damage_inc_limit = (power/300)*(explosion_point/1000)*DAMAGE_RATE_LIMIT

	if(!env || !removed || !removed.total_moles())
		damage += max((power - 15*POWER_FACTOR)/10, 0)
	else
		damage_archived = damage

	if(!removed)
		//Placeholder, which representates vacuum
		removed = new

	damage = max(0, damage + between(-DAMAGE_RATE_LIMIT, (removed.temperature - CRITICAL_TEMPERATURE) / 150, damage_inc_limit))

	//Maxes out at 100% oxygen pressure
	if(!removed.total_moles())
		oxygen = 0
	else
		//Result of this formula is undefined if we (total moles of removed) -> 0. So, let's roll with zero if no gas was removed.
		oxygen = clamp((removed.oxygen - (removed.nitrogen * NITROGEN_RETARDATION_FACTOR)) / removed.total_moles(), 0, 1)

	var/temp_factor
	var/equilibrium_power
	if(oxygen > 0.8)
		//If chain reacting at oxygen > 0.8, we want the power at 800 K to stabilize at a power level of 400
		equilibrium_power = 400
		icon_state = "[base_icon_state]_glow"
	else
		//Otherwise, we want the power at 800 K to stabilize at a power level of 250
		equilibrium_power = 250
		icon_state = base_icon_state

	temp_factor = ((equilibrium_power / DECAY_FACTOR) ** 3) / 800
	power = round(max((removed.temperature * temp_factor) * oxygen + power, 0), 0.01)

	var/device_energy = round(power * REACTION_POWER_MODIFIER, 0.01)

	var/old_heat_capacity = removed.heat_capacity()

	if(device_energy)
		removed.toxins += max(device_energy / PLASMA_RELEASE_MODIFIER, 0)
		removed.oxygen += max((device_energy + removed.temperature - T0C) / OXYGEN_RELEASE_MODIFIER, 0)

	var/heat_capacity = removed.heat_capacity()

	var/thermal_power = THERMAL_RELEASE_MODIFIER * device_energy
	if(debug)
		visible_message("[src]: Releasing [round(thermal_power)] W.")
		visible_message("[src]: Releasing additional [round((heat_capacity - old_heat_capacity)*removed.temperature)] W with exhaust gasses.")

	//deltaT = deltaQ / heat_capacity (deltaQ equals thermal_power)
	//We are assuming here, that volume does not change here
	removed.temperature += (thermal_power / heat_capacity)

	removed.temperature = max(0, removed.temperature)

	env.merge(removed)

	air_update_turf()
	transfer_energy()

	for(var/mob/living/carbon/human/l in view(src, min(7, round(sqrt(power/6)))))
		// No more hallucinate for ded pipol.
		if(!l.stat)
			continue
		// Where we're going, we don't need eyes.
		var/obj/item/organ/internal/eyes/eyes = l.get_int_organ(/obj/item/organ/internal/eyes)
		if(!istype(eyes))
			continue
		// If they can see it without mesons on or can see objects through mesons. Bad on them.
		if((l.sight >= SEE_TURFS) && !(l.sight >= (SEE_TURFS|SEE_OBJS)))
			continue
		l.Hallucinate(min(200 SECONDS, l.AmountHallucinate() + power * config_hallucination_power * sqrt( 1 / max(1,get_dist(l, src)))))
		l.last_hallucinator_log = "seeing SM without mesons"

	for(var/mob/living/l in range(src, round((power / 100) ** 0.25)))
		var/rads = (power / 10) * sqrt( 1 / max(get_dist(l, src),1) )
		l.apply_effect(rads, IRRADIATE)

	power -= (power/DECAY_FACTOR)**3

	handle_admin_warnings()

	return 1

/obj/machinery/power/supermatter_shard

/obj/machinery/power/supermatter_shard/bullet_act(var/obj/item/projectile/Proj)
	var/turf/L = loc
	if(!istype(L))		// We don't run process() when we are in space
		return 0	// This stops people from being able to really power up the supermatter
				// Then bring it inside to explode instantly upon landing on a valid turf.


	if(Proj.flag != "bullet")
		power += Proj.damage * config_bullet_energy
		if(!has_been_powered)
			investigate_log("has been powered for the first time.", INVESTIGATE_ENGINE)
			message_admins("[src] has been powered for the first time [ADMIN_COORDJMP(src)].")
			has_been_powered = 1
	else
		damage += Proj.damage * config_bullet_energy
	supermatter_zap()
	return 0

/obj/machinery/power/supermatter_shard/singularity_act()
	var/gain = 100
	investigate_log("consumed by singularity.", INVESTIGATE_ENGINE)
	message_admins("<span class='danger'>Singularity has consumed a supermatter shard and can now become stage six</span> [ADMIN_COORDJMP(src)].")
	visible_message("<span class='userdanger'>[src] is consumed by the singularity!</span>")
	for(var/mob/M in GLOB.mob_list)
		M << 'sound/effects/supermatter.ogg' //everyone gunna know bout this
		to_chat(M, span_boldannounceic("A horrible screeching fills your ears, and a wave of dread washes over you..."))
	qdel(src)
	return(gain)

/obj/machinery/power/supermatter_shard/attack_robot(mob/user as mob)
	if(Adjacent(user))
		return attack_hand(user)

/obj/machinery/power/supermatter_shard/attack_hand(mob/user as mob)
	if(isAI(user))
		return
	if(isnucleation(user))
		nuclear_touch(user)
		new /obj/effect/temp_visual/heart(loc)
		var/touch_sm = pick(list("poke", "pet", "hug", "cuddle"))
		user.visible_message(span_notice("[user] [touch_sm]s the supermatter!"), \
								span_notice("You [touch_sm] the supermatter!"))
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		return

	user.visible_message("<span class=\"warning\">\The [user] reaches out and touches \the [src], inducing a resonance... [user.p_their(TRUE)] body starts to glow and bursts into flames before flashing into ash.</span>",\
		"<span class=\"danger\">You reach out and touch \the [src]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"</span>",\
		"<span class=\"warning\">You hear an uneartly ringing, then what sounds like a shrilling kettle as you are washed with a wave of heat.</span>")

	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, 1)

	consume(user)

/obj/machinery/power/supermatter_shard/proc/get_integrity()
	var/integrity = damage / explosion_point
	integrity = round(100 - integrity * 100)
	integrity = integrity < 0 ? 0 : integrity
	return integrity

/obj/machinery/power/supermatter_shard/proc/transfer_energy()
	for(var/obj/machinery/power/rad_collector/R in GLOB.rad_collectors)
		if(get_dist(R, src) <= 15) // Better than using orange() every process
			R.receive_pulse(power/10)
	return


/obj/machinery/power/supermatter_shard/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/scalpel/supermatter))
		add_fingerprint(user)
		var/obj/item/scalpel/supermatter/scalpel = I
		if(!scalpel.uses_left)
			to_chat(user, span_warning("The [scalpel.name] isn't sharp enough anymore."))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] starts to carefully scrape [src] with [I]."),
			span_notice("You start to carefully scrape [src]..."),
		)
		if(!I.use_tool(src, user, 10 SECONDS, volume = 100) || !scalpel.uses_left)
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] has extracted a sliver from [src], and it begins to react violently."),
			span_notice("You have extracted a sliver from [src], and it begins to react violently."),
		)
		power += 200 //well...
		var/turf/shard_loc = get_turf(src)
		var/datum/gas_mixture/shard_env = shard_loc.return_air()
		var/datum/gas_mixture/new_mixture = new
		new_mixture.toxins = 10000
		new_mixture.temperature += power * SHARD_CUT_COEF
		shard_env.merge(new_mixture)
		scalpel.uses_left--
		if(!scalpel.uses_left)
			to_chat(user, span_boldwarning("A tiny piece of [I] falls off, rendering it useless!"))
		var/obj/item/nuke_core/supermatter_sliver/sliver = new(drop_location())
		var/obj/item/retractor/supermatter/tongs = user.get_inactive_hand()
		if(!istype(tongs) || tongs.sliver)
			return ATTACK_CHAIN_PROCEED_SUCCESS
		tongs.sliver = sliver
		sliver.forceMove(tongs)
		tongs.update_icon(UPDATE_ICON_STATE)
		to_chat(user, span_notice("You have picked up [sliver] with [tongs]."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/retractor/supermatter))
		to_chat(user, span_warning("The [I.name] bounces off [src], you need to cut off a sliver first."))
		return ATTACK_CHAIN_PROCEED

	if((I.item_flags & ABSTRACT) || !isliving(user))
		return ATTACK_CHAIN_PROCEED

	. = ATTACK_CHAIN_BLOCKED_ALL
	user.drop_item_ground(I, force = TRUE)
	I.do_pickup_animation(src)
	consume(I)
	user.visible_message(
		span_danger("As [user] touches [src] with [I], silence fills the room..."),
		"[span_danger("You touch [src] with [I], and everything suddenly goes silent.")]\n[span_notice("The [I.name] flashes into dust as you flinch away from [src].")]",
		span_italics("Everything suddenly goes silent."),
	)
	playsound(loc, 'sound/effects/supermatter.ogg', 50, TRUE)
	user.apply_effect(150, IRRADIATE)


/obj/machinery/power/supermatter_shard/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	set_anchored(!anchored)
	if(anchored)
		user.visible_message(
			span_warning("As [user] tightens bolts of [src] with [I], the tool disappears."),
			span_warning("As you tighten bolts of [src], the tool disappears."),
			span_italics("You hear a ratchet"),
		)
	else
		user.visible_message(
			span_warning("As [user] loosens bolts of [src] with [I], the tool disappears."),
			span_warning("As you loosens bolts of [src], the tool disappears."),
			span_italics("You hear a ratchet"),
		)
	if(isrobot(user))
		var/mob/living/silicon/robot/robot = user
		var/datum/robot_component/armor = robot.get_armour()
		if(armor)
			audible_message(span_warning("[robot] sounds an alarm! \"CRITICAL ERROR: Armour plate was broken.\""))
			playsound(loc, 'sound/machines/warning-buzzer.ogg', 75, TRUE)
			armor.destroy()
		else
			consume(robot)
	else
		consume_wrench(I)


/obj/machinery/power/supermatter_shard/Bumped(atom/movable/moving_atom)
	. = ..()
	if(isprojectile(moving_atom))	// we update this in bullet_act()
		return .
	if(isnucleation(moving_atom))
		nuclear_touch(moving_atom)
		return .
	if(isliving(moving_atom))
		moving_atom.visible_message("<span class='danger'>\The [moving_atom] slams into \the [src] inducing a resonance... [moving_atom.p_their(TRUE)] body starts to glow and catch flame before flashing into ash.</span>",\
		"<span class='userdanger'>You slam into \the [src] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\"</span>",\
		"<span class='italics'>You hear an unearthly noise as a wave of heat washes over you.</span>")
	else if(isobj(moving_atom) && !iseffect(moving_atom))
		moving_atom.visible_message("<span class='danger'>\The [moving_atom] smacks into \the [src] and rapidly flashes to ash.</span>",\
		"<span class='italics'>You hear a loud crack as you are washed with a wave of heat.</span>")
	else
		return

	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, 1)

	consume(moving_atom)

/obj/machinery/power/supermatter_shard/intercept_zImpact(list/falling_movables, levels)
	. = ..()
	for(var/atom/movable/hit_object as anything in falling_movables)
		if(hit_object == src)
			return
		Bumped(hit_object)
	. |= FALL_STOP_INTERCEPTING | FALL_INTERCEPTED

/obj/machinery/power/supermatter_shard/onZImpact(turf/impacted_turf, levels, impact_flags)

	for(var/mob/living/poor_target in impacted_turf)
		consume(poor_target)
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)
		poor_target.visible_message(span_danger("\The [src] slams into \the [poor_target] out of nowhere inducing a resonance... [poor_target.p_their()] body starts to glow and burst into flames before flashing into dust!"),
			span_userdanger("\The [src] slams into you out of nowhere as your ears are filled with unearthly ringing. Your last thought is \"The fuck.\""),
			span_hear("You hear an unearthly noise as a wave of heat washes over you."))
	for(var/atom/movable/hit_object as anything in impacted_turf)
		if(src == hit_object)
			return
		if(iseffect(hit_object))
			continue

		consume(hit_object)
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)
		visible_message(span_danger("\The [src], smacks into the plating out of nowhere, reducing everything below to ash."), null,
			span_hear("You hear a loud crack as you are washed with a wave of heat."))
	return ..()


/obj/machinery/power/supermatter_shard/proc/consume(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/user = AM
		user.gib()
		power += 200
		message_admins("[src] has consumed [key_name_admin(user)] [ADMIN_COORDJMP(src)].")
		investigate_log("has consumed [key_name_log(user)].", INVESTIGATE_ENGINE)
	else if(isobj(AM) && !iseffect(AM))
		investigate_log("has consumed [AM].", INVESTIGATE_ENGINE)
		qdel(AM)

	power += 200
	supermatter_zap()

/obj/machinery/power/supermatter_shard/proc/consume_wrench(atom/movable/AM)
	qdel(AM) //destroys wrench when anchored\unanchored supermatter

	//Some poor sod got eaten, go ahead and irradiate people nearby.
	for(var/mob/living/L in range(10))
		var/rads = 500 * sqrt( 1 / (get_dist(L, src) + 1) )
		L.apply_effect(rads, IRRADIATE)
		investigate_log("has irradiated [L] after consuming [AM].", INVESTIGATE_ENGINE)
		if(src in view(L.client.maxview()))
			L.show_message("<span class='danger'>As \the [src] slowly stops resonating, you find your skin covered in new radiation burns.</span>", 1,\
				"<span class='danger'>The unearthly ringing subsides and you notice you have new radiation burns.</span>", 2)
		else
			L.show_message("<span class='italics'>You hear an uneartly ringing and notice your skin is covered in fresh radiation burns.</span>", 2)

/obj/machinery/power/supermatter_shard/proc/get_status()
	var/turf/T = get_turf(src)
	if(!T)
		return SUPERMATTER_ERROR
	var/datum/gas_mixture/air = T.return_air()
	if(!air)
		return SUPERMATTER_ERROR

	if(get_integrity() < 25)
		return SUPERMATTER_DELAMINATING

	if(get_integrity() < 50)
		return SUPERMATTER_EMERGENCY

	if(get_integrity() < 75)
		return SUPERMATTER_DANGER

	if((get_integrity() < 100) || (air.temperature > CRITICAL_TEMPERATURE))
		return SUPERMATTER_WARNING

	if(air.temperature > (CRITICAL_TEMPERATURE * 0.8))
		return SUPERMATTER_NOTIFY

	if(power > 5)
		return SUPERMATTER_NORMAL
	return SUPERMATTER_INACTIVE

/obj/machinery/power/supermatter_shard/proc/alarm()
	switch(get_status())
		if(SUPERMATTER_DELAMINATING)
			playsound(src, 'sound/misc/bloblarm.ogg', 100, FALSE, 40, 30, falloff_distance = 10)
		if(SUPERMATTER_EMERGENCY)
			playsound(src, 'sound/machines/engine_alert1.ogg', 100, FALSE, 30, 30, falloff_distance = 10)
		if(SUPERMATTER_DANGER)
			playsound(src, 'sound/machines/engine_alert2.ogg', 100, FALSE, 30, 30, falloff_distance = 10)
		if(SUPERMATTER_WARNING)
			playsound(src, 'sound/machines/terminal_alert.ogg', 75)

/obj/machinery/power/supermatter_shard/proc/emergency_lighting(active)
    if(active)
        post_status(STATUS_DISPLAY_ALERT, "radiation")
    else
        post_status(STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME)

/obj/machinery/power/supermatter_shard/proc/supermatter_zap()
	playsound(src.loc, 'sound/magic/lightningshock.ogg', 100, 1, extrarange = zap_sound_extrarange)
	tesla_zap(src, 10, max(1000,power * damage / explosion_point))

// SM shard that can't be moved for ruins and gates
/obj/machinery/power/supermatter_shard/anchored
	name = "Well anchored supermatter shard"
	desc = "A strangely translucent and iridescent crystal that looks like it used to be part of a larger structure. Apparently the structure is attached to the surface with industrial equipment, it cannot be unanchored with simple equipment. <span class='danger'>You get headaches just from looking at it.</span>"
	anchored = TRUE


/obj/machinery/power/supermatter_shard/anchored/attackby(obj/item/I, mob/living/user, params)
	consume_wrench(I)
	user.apply_effect(150, IRRADIATE)
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/machinery/power/supermatter_shard/anchored/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	user.visible_message(
		span_warning("As [user] tries to loose bolts of [src] with [I], the tool disappears."),
		span_warning("As you try to loose bolts of [src], the tool disappears."),
	)
	consume_wrench(I)
	user.apply_effect(150, IRRADIATE)


/obj/machinery/power/supermatter_shard/proc/nuclear_touch(var/mob/living/user)
	var/datum/species/nucleation/nuclear = user.dna.species
	if(nuclear.touched_supermatter == FALSE)
		user.revive()
		nuclear.touched_supermatter = TRUE
		to_chat(user, span_userdanger("The wave of warm energy is overwhelming you. You feel calm."))
