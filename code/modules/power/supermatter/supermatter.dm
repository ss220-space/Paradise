//Zap constants, speeds up targeting
#define BIKE (COIL + 1)
#define COIL (ROD + 1)
#define ROD (LIVING + 1)
#define LIVING (MACHINERY + 1)
#define MACHINERY (OBJECT + 1)
#define OBJECT (LOWEST + 1)
#define LOWEST (1)

GLOBAL_DATUM(main_supermatter_engine, /obj/machinery/atmospherics/supermatter_crystal)

/obj/machinery/atmospherics/supermatter_crystal
	name = "supermatter crystal"
	desc = "Странно полупрозрачный и переливающийся кристалл."
	icon = 'icons/obj/engines_and_power/supermatter.dmi'
	icon_state = "darkmatter"
	density = TRUE
	layer = ABOVE_MOB_LAYER + 0.01
	appearance_flags = PIXEL_SCALE|LONG_GLIDE
	//flags_2 = RAD_PROTECT_CONTENTS_2 | RAD_NO_CONTAMINATE_2 | IMMUNE_TO_SHUTTLECRUSH_2 | NO_MALF_EFFECT_2 | CRITICAL_ATOM_2
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	base_icon_state = "darkmatter"

	///The id of our supermatter
	var/supermatter_id = 1
	///The amount of supermatters that have been created this round
	var/static/global_supermatter_id = 1
	///Tracks the bolt color we are using
	var/zap_icon = DEFAULT_ZAP_ICON_STATE
	///The portion of the gasmix we're on that we should remove
	var/gasefficency = 0.15

	///Are we exploding?
	var/final_countdown = FALSE

	///The amount of damage we have currently
	var/damage = 0
	///The damage we had before this cycle. Used to limit the damage we can take each cycle, and for safe_alert
	var/damage_archived = 0
	///Our "Shit is no longer fucked" message. We send it when damage is less then damage_archived
	var/safe_alert = "Кристаллическая гиперструктура возвращается к безопасным рабочим параметрам."
	///The point at which we should start sending messeges about the damage to the engi channels.
	var/warning_point = 50
	///The alert we send when we've reached warning_point
	var/warning_alert = "Опасность! Нарушена целостность кристаллической гиперструктуры!"
	///The point at which we start sending messages to the common channel
	var/emergency_point = 700
	///The alert we send when we've reached emergency_point
	var/emergency_alert = "НЕИЗБЕЖНОЕ РАССЛОЕНИЕ КРИСТАЛЛОВ."
	///The point at which we delam
	var/explosion_point = 900
	///When we pass this amount of damage we start shooting bolts
	var/damage_penalty_point = 550

	///A scaling value that affects the severity of explosions.
	var/explosion_power = 35
	///Time in 1/10th of seconds since the last sent warning
	var/lastwarning = 0
	/// Refered to as eer on the moniter. This value effects gas output, heat, and damage.
	var/power = 0
	/// This is the power between getting increased and reduced. It affects radiation.
	var/pre_reduction_power = 0
	/// A bonus to rad production equal to EER multiplied by the bonus given by each gas. The bonus gets higher the more gas there is in the chamber.
	var/gas_coefficient = 0
	///Determines the rate of positve change in gas comp values
	var/gas_change_rate = 0.05

	var/n2comp = 0 // raw composition of each gas in the chamber, ranges from 0 to 1
	var/plasmacomp = 0
	var/o2comp = 0
	var/co2comp = 0
	var/n2ocomp = 0
	var/h2comp = 0
	var/h2ocomp = 0

	///The last air sample's total molar count, will always be above or equal to 0
	var/combined_gas = 0
	///Affects the power gain the sm experiances from heat
	var/gasmix_power_ratio = 0
	///Affects the amount of o2 and plasma the sm outputs, along with the heat it makes.
	var/dynamic_heat_modifier = 1
	///Affects the amount of damage and minimum point at which the sm takes heat damage
	var/dynamic_heat_resistance = 1
	///Uses powerloss_dynamic_scaling and combined_gas to lessen the effects of our powerloss functions
	var/powerloss_inhibitor = 1
	///value plus T0C = temp at which the SM starts to take damage. Variable for event usage
	var/heat_penalty_threshold = SUPERMATTER_HEAT_PENALTY_THRESHOLD
	///Based on co2 percentage, slowly moves between 0 and 1. We use it to calc the powerloss_inhibitor
	var/powerloss_dynamic_scaling= 0
	///Affects the amount of radiation the sm makes. We multiply this with power to find the rads.
	var/power_transmission_bonus = 0
	///Used to increase or lessen the amount of damage the sm takes from heat based on molar counts.
	var/mole_heat_penalty = 0
	///Takes the energy throwing things into the sm generates and slowly turns it into actual power
	var/matter_power = 0
	///The cutoff for a bolt jumping, grows with heat, lowers with higher mol count,
	var/zap_cutoff = 1500
	///How much the bullets damage should be multiplied by when it is added to the internal variables
	var/bullet_energy = 2
	///How much hallucination should we produce per unit of power?
	var/hallucination_power = 1

	///Our internal radio
	var/obj/item/radio/radio
	///The key our internal radio uses
	var/radio_key = /obj/item/encryptionkey/headset_eng

	///Hue shift of the zaps color based on the power of the crystal
	var/hue_angle_shift = 0
	///Reference to the warp effect
	var/obj/effect/warp_effect/supermatter/warp
	///A variable to have the warp effect for singulo SM work properly
	var/pulse_stage = 0
	///This list will hold 4 supermatter darkness effects when the supermatter is delaminating to a singulo delam. This lets me darken the area to look better, as it turns out, walls make the effect look ugly as shit.
	var/list/darkness_effects = list()

	///Boolean used for logging if we've been powered
	var/has_been_powered = FALSE
	///Boolean used for logging if we've passed the emergency point
	var/has_reached_emergency = FALSE

	///An effect we show to admins and ghosts the percentage of delam we're at
	var/obj/effect/countdown/supermatter/countdown

	///Used to track if we can give out the sm sliver stealing objective
	var/is_main_engine = FALSE
	///Our soundloop
	var/datum/looping_sound/supermatter/soundloop
	///Can it be moved?
	var/moveable = FALSE

	///cooldown tracker for accent sounds
	var/last_accent_sound = 0

	//For making hugbox supermatters
	///Disables all methods of taking damage
	var/takes_damage = TRUE
	///Disables the production of gas, and pretty much any handling of it we do.
	var/produces_gas = TRUE
	///Disables power changes
	var/power_changes = TRUE
	///Disables the sm's proccessing totally.
	var/processes = TRUE

	//vars used for supermatter events (Anomalous crystal activityw)
	/// Can this crystal run supermatter events?
	var/crystal_can_run_events = TRUE
	/// Do we have an active event?
	var/datum/engi_event/supermatter_event/event_active
	///flat multiplies the amount of gas released by the SM.
	var/gas_multiplier = 1
	///flat multiplies the heat released by the SM
	var/heat_multiplier = 1
	///amount of EER to ADD
	var/power_additive = 0
	/// Time of next event
	var/next_event_time
	/// Run S-Class event? So we can only run one S-class event per round per crystal
	var/has_run_sclass = FALSE

	/// How often do we want to process the crystal?
	var/ticks_per_run = 5
	/// How long has it been since we processed the crystal?
	var/tick_counter = 0
	/// Datum, that handles all effects on station when sm explodes
	var/datum/supermatter_explosive_effects/supermatter_explosive_effects

	///Stores the time of when the last zap occurred
	var/last_power_zap = 0
	///Stores the tick of the machines subsystem of when the last zap energy accumulation occurred. Gives a passage of time in the perspective of SSmachines.
	var/last_energy_accumulation_perspective_machines = 0
	///Same as [last_energy_accumulation_perspective_machines], but based around the high energy zaps found in handle_high_power().
	var/last_high_energy_accumulation_perspective_machines = 0
	/// Accumulated energy to be transferred from supermatter zaps.
	var/list/zap_energy_accumulation = list()

	/// The zap power transmission over internal energy. W/MeV.
	var/zap_transmission_rate = BASE_POWER_TRANSMISSION_RATE

/obj/machinery/atmospherics/supermatter_crystal/get_ru_names()
	return list(
		NOMINATIVE = "кристалл суперматерии",
		GENITIVE = "кристалла суперматерии",
		DATIVE = "кристаллу суперматерии",
		ACCUSATIVE = "кристалл суперматерии",
		INSTRUMENTAL = "кристаллом суперматерии",
		PREPOSITIONAL = "кристалле суперматерии"
	)

/obj/machinery/atmospherics/supermatter_crystal/Initialize(mapload)
	. = ..()
	supermatter_id = global_supermatter_id++
	countdown = new(src)
	countdown.start()
	GLOB.poi_list |= src
	radio = new(src)
	radio.keyslot = new radio_key
	radio.set_listening(FALSE)
	radio.recalculate_channels()
	investigate_log("has been created.", INVESTIGATE_ENGINE)
	if(is_main_engine)
		GLOB.main_supermatter_engine = src
	soundloop = new(src, TRUE)

	if(!moveable)
		move_resist = MOVE_FORCE_OVERPOWERING // Avoid being moved by statues or other memes

	supermatter_explosive_effects = new()
	supermatter_explosive_effects.z = src.z

/obj/machinery/atmospherics/supermatter_crystal/Destroy()
	if(warp)
		vis_contents -= warp
		QDEL_NULL(warp)
	investigate_log("has been destroyed.", INVESTIGATE_ENGINE)
	SSair.atmos_machinery -= src
	QDEL_NULL(radio)
	GLOB.poi_list -= src
	if(!processes)
		GLOB.frozen_atom_list -= src
	QDEL_NULL(countdown)
	if(is_main_engine && GLOB.main_supermatter_engine == src)
		GLOB.main_supermatter_engine = null
	QDEL_NULL(soundloop)
	QDEL_LIST(darkness_effects)
	supermatter_explosive_effects = null
	return ..()

/obj/machinery/atmospherics/supermatter_crystal/examine(mob/user)
	. = ..()
	var/mob/living/carbon/human/human_user = user
	if(istype(human_user))
		if(!HAS_TRAIT(human_user, TRAIT_MESON_VISION) && (get_dist(user, src) < HALLUCINATION_RANGE(power)))
			. += span_danger("От одного взгляда на это начинает болеть голова.")
	. += span_notice("При столкновении с этим впечатляющим творением инженерной мысли оно испускает радиацию и тепло. В этом и заключается суть использования псевдовечного источника энергии — кристалла суперматерии.")
	. += span_notice("Любой объект, к которому прикасается [declent_ru(ACCUSATIVE)], мгновенно превращается в пыль, будь то сложный, как человек, или простой, как металлический стержень. Эти всплески энергии могут вызвать галлюцинации, если рядом с кристаллом не носить мезонные сканеры.")
	if(isAntag(user))
		. += span_warning("Хотя термоэлектрический генератор (ТЭГ) стоит дороже, есть очень веская причина, по которой синдикат использует его, а не суперматерию. Если целостность [declent_ru(GENITIVE)] упадет до 0%, возможно, из-за перегрева, суперматерия взорвётся с огромной силой, уничтожив почти все, что находится рядом, и высвободив огромное количество радиации.")
	if(moveable)
		. += span_notice("Его можно [anchored ? "отстегнуть от пола" : "закрепить к полу"] с помощью гаечного ключа.")

/obj/machinery/atmospherics/supermatter_crystal/proc/get_status()
	var/turf/T = get_turf(src)
	if(!T)
		return SUPERMATTER_ERROR
	var/datum/gas_mixture/air = T.get_readonly_air()
	if(!air)
		return SUPERMATTER_ERROR

	var/integrity = get_integrity_percent()
	if(integrity < SUPERMATTER_DELAM_PERCENT)
		return SUPERMATTER_DELAMINATING

	if(integrity < SUPERMATTER_EMERGENCY_PERCENT)
		return SUPERMATTER_EMERGENCY

	if(integrity < SUPERMATTER_DANGER_PERCENT)
		return SUPERMATTER_DANGER

	if((integrity < SUPERMATTER_WARNING_PERCENT) || (air.temperature() > CRITICAL_TEMPERATURE))
		return SUPERMATTER_WARNING

	if(air.temperature() > (CRITICAL_TEMPERATURE * 0.8))
		return SUPERMATTER_NOTIFY

	if(power > 5)
		return SUPERMATTER_NORMAL
	return SUPERMATTER_INACTIVE

/obj/machinery/atmospherics/supermatter_crystal/proc/alarm()
	switch(get_status())
		if(SUPERMATTER_DELAMINATING)
			playsound(src, 'sound/misc/bloblarm.ogg', 100, FALSE, 40, 30, falloff_distance = 10)
		if(SUPERMATTER_EMERGENCY)
			playsound(src, 'sound/machines/engine_alert1.ogg', 100, FALSE, 30, 30, falloff_distance = 10)
		if(SUPERMATTER_DANGER)
			playsound(src, 'sound/machines/engine_alert2.ogg', 100, FALSE, 30, 30, falloff_distance = 10)
		if(SUPERMATTER_WARNING)
			playsound(src, 'sound/machines/terminal_alert.ogg', 75)

/// Returns the integrity percent of the Supermatter. No rounding made yet, round it yourself.
/obj/machinery/atmospherics/supermatter_crystal/proc/get_integrity_percent()
	var/integrity = damage / explosion_point
	integrity = 100 - integrity * 100
	integrity = integrity < 0 ? 0 : integrity
	return integrity

/obj/machinery/atmospherics/supermatter_crystal/proc/count_down()
	set waitfor = FALSE

	if(final_countdown) // We're already doing it go away
		//stack_trace("[src] told to delaminate again while it's already delaminating.")
		return

	notify_ghosts(
		"[declent_ru(NOMINATIVE)] начал процесс расслаивания!",
		source = src,
		title = "Надвигается катастрофа",
	)

	final_countdown = TRUE

	var/image/causality_field = image(icon, null, "causality_field")
	add_overlay(causality_field)

	var/speaking = span_reallybig("[emergency_alert] Целостность суперматерии достигла критической точки. Активировано поле экстренной дестабилизации причинно-следственной связи.")
	for(var/mob/target as anything in GLOB.player_list) // for all players
		var/turf/target_turf = get_turf(target)
		if(istype(target_turf) && are_zs_connected(target_turf, src)) // if the player is on the same zlevel as the SM shared
			SEND_SOUND(target, sound('sound/machines/engine_alert2.ogg')) // then send them the sound file

	radio_announce(speaking, name, PUB_FREQ, radio)

	for(var/i in SUPERMATTER_COUNTDOWN_TIME to 0 step -10)
		if(!processes) // Stop exploding if you're frozen by an admin, damn you
			cut_overlay(causality_field, TRUE)
			final_countdown = FALSE
			damage = explosion_point - 1 // One point below exploding, so it will re-start the countdown once unfrozen
			return

		if(damage < explosion_point) // Cutting it a bit close there engineers
			radio_announce(span_big("[safe_alert] Система защиты от сбоев отключена."), name, PUB_FREQ, radio)
			cut_overlay(causality_field, TRUE)
			final_countdown = FALSE
			remove_filter(list("outline", "icon"))
			return

		else if((i % 50) != 0 && i > 50) // A message once every 5 seconds until the final 5 seconds which count down individualy
			sleep(1 SECONDS)
			continue

		else if(i > 50)
			speaking = "<b>[DisplayTimeText(i, TRUE)] остается до стабилизации причинно-следственной связи.</b>"

		else
			speaking = span_reallybig("[i * 0.1]...")

		radio_announce(speaking, name, PUB_FREQ, radio)
		sleep(1 SECONDS)

	explode()

/obj/machinery/atmospherics/supermatter_crystal/proc/explode(forced_combined_gas = 0, forced_power = 0, forced_gasmix_power_ratio = 0)
	SSblackbox.record_feedback("amount", "supermatter_delaminations", 1)
	for(var/mob/living/living_mob as anything in GLOB.alive_mob_list)
		if(istype(living_mob) && are_zs_connected(living_mob, src))
			if(ishuman(living_mob))
				//Hilariously enough, running into a closet should make you get hit the hardest.
				var/mob/living/carbon/human/human_mob = living_mob
				var/hallucination_amount = (max(50, min(300, DETONATION_HALLUCINATION * sqrt(1 / (get_dist(living_mob, src) + 1))))) SECONDS
				human_mob.AdjustHallucinate(hallucination_amount)

			if(get_dist(living_mob, src) <= DETONATION_RADIATION_RANGE)
				SSradiation.irradiate(living_mob)

	var/turf/source_turf = get_turf(src)
	var/super_matter_charge_sound = sound('sound/magic/charge.ogg')
	for(var/mob/player_mob as anything in GLOB.player_list)
		var/turf/mob_turf = get_turf(player_mob)
		if(are_zs_connected(source_turf, mob_turf))
			SEND_SOUND(player_mob, super_matter_charge_sound)

			if(are_zs_connected(player_mob, src))
				to_chat(player_mob, span_boldannounceic("На мгновение вы ощущаете искажение реальности..."))
			else
				to_chat(player_mob, span_boldannounceic("Вы изо всех сил держитесь за [player_mob.loc], пока реальность вокруг вас искажается. Вы чувствуете себя в безопасности."))

	if(max(combined_gas, forced_combined_gas) > MOLE_CRUNCH_THRESHOLD)
		investigate_log("has collapsed into a singularity.", INVESTIGATE_ENGINE)
		if(source_turf)
			var/obj/singularity/new_singularity = new(source_turf)
			new_singularity.energy = 800
			new_singularity.consume(src)
			return //No boom for me sir

	else if(max(power, forced_power) > POWER_PENALTY_THRESHOLD)
		investigate_log("has spawned additional energy balls.", INVESTIGATE_ENGINE)
		if(source_turf)
			var/obj/energy_ball/new_energy_ball = new(source_turf)
			new_energy_ball.energy = 200 //Gets us about 9 balls

	//Dear mappers, balance the sm max explosion radius to 17.5, 37, 39, 41
	if(forced_gasmix_power_ratio)
		gasmix_power_ratio = forced_gasmix_power_ratio

	if(supermatter_explosive_effects)
		supermatter_explosive_effects.z = z
		supermatter_explosive_effects.handle_special_effects()

	explosion(get_turf(source_turf), explosion_power * max(gasmix_power_ratio, MIN_GASMIX_POWER_RATIO_FOR_EXPLOSION) * 0.5 , explosion_power * max(gasmix_power_ratio, MIN_GASMIX_POWER_RATIO_FOR_EXPLOSION) + 2, explosion_power * max(gasmix_power_ratio, MIN_GASMIX_POWER_RATIO_FOR_EXPLOSION) + 4 , explosion_power * max(gasmix_power_ratio, MIN_GASMIX_POWER_RATIO_FOR_EXPLOSION) + 6, 1, 1, cause = "Exploding Supermatter")
	qdel(src)

/obj/machinery/atmospherics/supermatter_crystal/process_atmos()
	tick_counter += SSair.wait
	if(tick_counter >= ticks_per_run)
		var/datum/milla_safe/supermatter_process/milla = new()
		milla.invoke_async(src)
		tick_counter -= ticks_per_run

/datum/milla_safe/supermatter_process

/datum/milla_safe/supermatter_process/on_run(obj/machinery/atmospherics/supermatter_crystal/supermatter)
	var/turf/turf_location = get_turf(supermatter)
	var/datum/gas_mixture/environment_gas_mixture = get_turf_air(turf_location)
	supermatter.process_atmos_safely(turf_location, environment_gas_mixture)

/obj/machinery/atmospherics/supermatter_crystal/proc/process_atmos_safely(turf/turf_location, datum/gas_mixture/environment_gas_mixture)
	if(!processes) //Just fuck me up bro
		return

	if(isnull(turf_location))		// We have a null turf...something is wrong, stop processing this entity.
		return PROCESS_KILL

	if(!isturf(loc)) 	//We are in a crate or somewhere that isn't turf, if we return to turf resume processing but for now.
		return  //Yeah just stop.

	if(turf_location.density)
		var/turf/changed_turf = turf_location.ChangeTurf(turf_location.baseturf)
		if(!changed_turf.density) //In case some joker finds way to place these on indestructible walls
			visible_message(span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] плавится сквозь [turf_location.declent_ru(ACCUSATIVE)]!"))
		return

	try_events()
	if(power > 100)
		if(!has_been_powered)
			enable_for_the_first_time()
	//We vary volume by power, and handle OH FUCK FUSION IN COOLING LOOP noises.
	if(power)
		soundloop.volume = clamp((50 + (power / 50)), 50, 100)
	if(damage >= 300)
		soundloop.mid_sounds = list('sound/machines/sm/loops/delamming.ogg' = 1)
	else
		soundloop.mid_sounds = list('sound/machines/sm/loops/calm.ogg' = 1)

	//We play delam/neutral sounds at a rate determined by power and damage
	if(last_accent_sound < world.time && prob(20))
		var/aggression = min(((damage / 800) * (power / 2500)), 1.0) * 100
		if(damage >= 300)
			playsound(src, "smdelam", max(50, aggression), FALSE, 40, 30, falloff_distance = 10)
		else
			playsound(src, "smcalm", max(50, aggression), FALSE, 25, 25, falloff_distance = 10)
		var/next_sound = round((100 - aggression) * 5)
		last_accent_sound = world.time + max(SUPERMATTER_ACCENT_SOUND_MIN_COOLDOWN, next_sound)

	var/datum/gas_mixture/removed_gas
	if(produces_gas)
		//Remove gas from surrounding area
		removed_gas = environment_gas_mixture.remove(gasefficency * environment_gas_mixture.total_moles())
	else
		// Pass all the gas related code an empty gas container
		removed_gas = new()
	damage_archived = damage
	if(!removed_gas || removed_gas.total_moles() <= 0 || isspaceturf(turf_location)) //we're in space or there is no gas to process
		if(takes_damage)
			damage += min(((power + 2000) * 0.002) * DAMAGE_INCREASE_MULTIPLIER, DAMAGE_HARDCAP * explosion_point) // always does at least some damage
	else
		if(takes_damage)
			//causing damage
			//Due to DAMAGE_INCREASE_MULTIPLIER, we only deal one 4th of the damage the statements otherwise would cause

			// ((((some value between 0.5 and 1 * (temp - ((273.15 + 40) * some values between 1 and 10))) * some number between 0.25 and knock your socks off / 150) * 0.25
			// Heat and mols account for each other, a lot of hot mols are more damaging then a few
			// Reduced heat damage below 200 Mols
			var/heat_damage = (max(max(removed_gas.total_moles() / MOLE_PENALTY_THRESHOLD, 0.5) * (removed_gas.temperature() - ((T0C + heat_penalty_threshold) * dynamic_heat_resistance)), 0) * mole_heat_penalty / 50 ) * DAMAGE_INCREASE_MULTIPLIER
			damage = max(damage + heat_damage, 0)

			// Power only starts affecting damage when it is above 5000
			var/power_damage = (max(power - POWER_PENALTY_THRESHOLD, 0) / 500) * DAMAGE_INCREASE_MULTIPLIER
			damage = max(damage + power_damage, 0)

			// Molar count only starts affecting damage when it is above 1800
			var/mole_damage = (max(combined_gas - MOLE_PENALTY_THRESHOLD, 0) / 80) * DAMAGE_INCREASE_MULTIPLIER
			damage = max(damage + mole_damage, 0)

			//There might be a way to integrate healing and hurting via heat
			//healing damage
			if(combined_gas < MOLE_PENALTY_THRESHOLD)
				//Only has a net positive effect when the temp is below the damage point. Heals up to 2 damage without N2O, going up to 12 with full N2O
				damage = max(damage + (min(removed_gas.temperature() - (T0C + heat_penalty_threshold) * dynamic_heat_resistance, 0) / 150 ), 0)

			//Check for holes in the SM inner chamber.
			var/turf/current_turf = get_turf(src)
			for(var/turf/neighbor_turf in current_turf.GetAtmosAdjacentTurfs(alldir = TRUE))
				if(!isspaceturf(neighbor_turf))
					continue
				damage += (power + 2000) * 0.002 * DAMAGE_INCREASE_MULTIPLIER
				break
			//caps damage rate

			//Takes the lower number between archived damage + (1.8) and damage
			//This means we can only deal 1.8 damage per function call
			damage = min(damage_archived + (DAMAGE_HARDCAP * explosion_point),damage)

		//calculating gas related values
		combined_gas = max(removed_gas.total_moles(), 0)

		plasmacomp = max(removed_gas.toxins() / combined_gas, 0)
		o2comp = max(removed_gas.oxygen() / combined_gas, 0)
		co2comp = max(removed_gas.carbon_dioxide() / combined_gas, 0)
		n2ocomp = max(removed_gas.sleeping_agent() / combined_gas, 0)
		n2comp = max(removed_gas.nitrogen() / combined_gas, 0)
		h2comp = max(removed_gas.hydrogen() / combined_gas, 0)
		h2ocomp = max(removed_gas.water_vapor() / combined_gas, 0)

		gasmix_power_ratio = min(max(plasmacomp + o2comp + co2comp + h2comp + h2ocomp - n2comp, 0), 1)

		dynamic_heat_modifier = max((plasmacomp * PLASMA_HEAT_PENALTY) + (o2comp * OXYGEN_HEAT_PENALTY) + (co2comp * CO2_HEAT_PENALTY) + (n2comp * NITROGEN_HEAT_PENALTY) + (h2comp * HYDROGEN_HEAT_PENALTY) + (h2ocomp * H2O_HEAT_PENALTY), 0.5)
		dynamic_heat_resistance = max(n2ocomp * N2O_HEAT_RESISTANCE, 1)

		power_transmission_bonus = max((plasmacomp * PLASMA_TRANSMIT_MODIFIER) + (o2comp * OXYGEN_TRANSMIT_MODIFIER) + (h2comp * HYDROGEN_TRANSMIT_MODIFIER) + (h2ocomp * H2O_TRANSMIT_MODIFIER), 0)

		//more moles of gases are harder to heat than fewer, so let's scale heat damage around them
		mole_heat_penalty = max(combined_gas / MOLE_HEAT_PENALTY, 1)

		if(combined_gas > POWERLOSS_INHIBITION_MOLE_THRESHOLD && co2comp > POWERLOSS_INHIBITION_GAS_THRESHOLD)
			powerloss_dynamic_scaling = clamp(powerloss_dynamic_scaling + clamp(co2comp - powerloss_dynamic_scaling, -0.02, 0.02), 0, 1)
		else
			powerloss_dynamic_scaling = clamp(powerloss_dynamic_scaling - 0.05, 0, 1)
		//Ranges from 0 to 1(1-(value between 0 and 1 * ranges from 1 to 1.5(mol / 500)))
		//We take the mol count, and scale it to be our inhibitor
		powerloss_inhibitor = clamp(1 - (powerloss_dynamic_scaling * clamp(combined_gas / POWERLOSS_INHIBITION_MOLE_BOOST_THRESHOLD, 1 , 1.5)), 0 , 1)

		//Releases stored power into the general pool
		//We get this by consuming shit or being scalpeled
		if(matter_power && power_changes)
			//We base our removed power off one 10th of the matter_power.
			var/removed_matter = max(matter_power / MATTER_POWER_CONVERSION, 40)
			//Adds at least 40 power
			power = max(power + removed_matter, 0)
			//Removes at least 40 matter power
			matter_power = max(matter_power - removed_matter, 0)

		var/temp_factor = 50
		if(gasmix_power_ratio > 0.8)
			//with a perfect gas mix, make the power less based on heat
			icon_state = "[base_icon_state]_glow"
		else
			//in normal mode, base the produced energy around the heat
			temp_factor = 30
			icon_state = base_icon_state


		if(power_changes)
			power = max((removed_gas.temperature() * temp_factor / T0C) * gasmix_power_ratio + power, 0)

		pre_reduction_power = power

		var/crush_ratio = combined_gas / MOLE_CRUNCH_THRESHOLD

		gas_coefficient = 1 + (POW2(crush_ratio) * (crush_ratio <= 1) + (crush_ratio > 1) * 2 * crush_ratio / (crush_ratio + 1)) * (plasmacomp * PLASMA_CRUNCH + o2comp * O2_CRUNCH + co2comp * CO2_CRUNCH + n2comp * N2_CRUNCH + n2ocomp * N2O_CRUNCH + h2comp * HYDROGEN_CRUNCH + h2ocomp * H2O_CRUNCH)

		emit_radiation()

		//Power * 0.55 * a value between 1 and 0.8
		var/device_energy = power * REACTION_POWER_MODIFIER

		//Calculate how much gas to release
		//Varies based on power and gas content
		removed_gas.set_toxins(removed_gas.toxins() + max(((device_energy * dynamic_heat_modifier) / PLASMA_RELEASE_MODIFIER) * gas_multiplier, 0))
		//Varies based on power, gas content, and heat
		removed_gas.set_oxygen(removed_gas.oxygen() + max((((device_energy + removed_gas.temperature() * dynamic_heat_modifier) - T0C) / OXYGEN_RELEASE_MODIFIER) * gas_multiplier, 0))

		// Calculate temperature change in terms of thermal energy, scaled by the average specific heat of the gas.
		if(removed_gas.total_moles() >= 1)
			var/produced_joules = max(0, ((device_energy * dynamic_heat_modifier) / THERMAL_RELEASE_MODIFIER) * heat_multiplier)
			produced_joules *= (removed_gas.heat_capacity() / removed_gas.total_moles())
			removed_gas.set_temperature((removed_gas.thermal_energy() + produced_joules) / removed_gas.heat_capacity())

		if(produces_gas)
			environment_gas_mixture.merge(removed_gas)

	//Makes em go mad and accumulate rads.
	for(var/mob/living/carbon/human/human_mob in view(src, HALLUCINATION_RANGE(power))) // If they can see it without mesons on.  Bad on them.
		if(!HAS_TRAIT(human_mob, TRAIT_MESON_VISION))
			var/distance_factor = sqrt(1 / max(1, get_dist(human_mob, src)))
			var/hallucination_amount = power * hallucination_power * distance_factor
			human_mob.AdjustHallucinate(hallucination_amount, 0, 200 SECONDS)

	// POWER PROCESSING
	var/delta_time = (SSmachines.times_fired - last_energy_accumulation_perspective_machines) * SSmachines.wait / (1 SECONDS)
	var/accumulated_energy = accumulate_energy(ZAP_ENERGY_ACCUMULATION_NORMAL, energy = zap_transmission_rate * (6 * power * (gas_coefficient + max(0, ((power_transmission_bonus / 10))))) * delta_time)
	if(accumulated_energy && (last_power_zap + (4 - power * 0.001) SECONDS) < world.time)
		var/discharged_energy = discharge_energy(ZAP_ENERGY_ACCUMULATION_NORMAL)
		playsound(src, 'sound/weapons/emitter2.ogg', 70, TRUE)
		hue_angle_shift = clamp(903 * log(10, (power + 8000)) - 3590, -50, 240)
		var/zap_color = color_matrix_rotate_hue(hue_angle_shift)
		supermatter_zap(
			zapstart = src,
			range = 3,
			zap_str = discharged_energy,
			zap_flags = ZAP_SUPERMATTER_FLAGS,
			zap_cutoff = 240 KILO JOULES,
			power_level = power * 10,
			color = zap_color,
		)

		last_power_zap = world.time
	last_energy_accumulation_perspective_machines = SSmachines.times_fired

	//Transitions between one function and another, one we use for the fast inital startup, the other is used to prevent errors with fusion temperatures.
	//Use of the second function improves the power gain imparted by using co2
	if(power_changes)
		var/power_fixed = (power / 500)
		power = max((power - min(POW3(power_fixed) * powerloss_inhibitor, power * 0.83 * powerloss_inhibitor) + power_additive), 0)
	//After this point power is lowered
	//This wraps around to the begining of the function
	//Handle high power zaps/anomaly generation
	last_high_energy_accumulation_perspective_machines = SSmachines.times_fired
	if((power * gas_coefficient) > POWER_PENALTY_THRESHOLD || damage > damage_penalty_point) //If the power is above 5000, if the damage is above 550, or mole crushing
		var/zap_range = 4
		zap_cutoff = 1500
		if(removed_gas && removed_gas.return_pressure() > 0 && removed_gas.temperature() > 0)
			//You may be able to freeze the zapstate of the engine with good planning, we'll see
			zap_cutoff = clamp(3000 - (power * (removed_gas.total_moles()) / 10) / removed_gas.temperature(), 350, 3000)//If the core is cold, it's easier to jump, ditto if there are a lot of mols
			//We should always be able to zap our way out of the default enclosure
			//See supermatter_zap() for more details
			zap_range = clamp(power / removed_gas.return_pressure() * 10, 2, 7)
		var/zap_flags = ZAP_SUPERMATTER_FLAGS
		var/zap_count = 0
		//Deal with power zaps
		switch(power)
			if(POWER_PENALTY_THRESHOLD to SEVERE_POWER_PENALTY_THRESHOLD)
				zap_icon = DEFAULT_ZAP_ICON_STATE
				zap_count = 2
			if(SEVERE_POWER_PENALTY_THRESHOLD to CRITICAL_POWER_PENALTY_THRESHOLD)
				zap_icon = SLIGHTLY_CHARGED_ZAP_ICON_STATE
				//Uncaps the zap damage, it's maxed by the input power
				//Objects take damage now
				zap_flags |= (ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE)
				zap_count = 3
			if(CRITICAL_POWER_PENALTY_THRESHOLD to INFINITY)
				zap_icon = OVER_9000_ZAP_ICON_STATE
				//It'll stun more now, and damage will hit harder, gloves are no garentee.
				//Machines go boom
				zap_flags |= (ZAP_MOB_STUN | ZAP_MACHINE_EXPLOSIVE | ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE)
				zap_count = 4
		//Now we deal with damage shit
		if(damage > damage_penalty_point && prob(20))
			zap_count += 1

		if(zap_count >= 1)
			playsound(loc, 'sound/weapons/emitter2.ogg', 100, TRUE, extrarange = 10)
			var/delta_time_high = (SSmachines.times_fired - last_high_energy_accumulation_perspective_machines) * SSmachines.wait / (1 SECONDS)
			var/accumulated_energy_high = accumulate_energy(ZAP_ENERGY_ACCUMULATION_HIGH_ENERGY, energy = clamp(power * 3200, 6.4e6, 3.2e7) * delta_time_high)
			if(accumulated_energy_high)
				for(var/i in 1 to zap_count)
					var/discharged_energy = discharge_energy(ZAP_ENERGY_ACCUMULATION_HIGH_ENERGY, portion = 1 - (1 - ZAP_ENERGY_DISCHARGE_PORTION) ** INVERSE(zap_count))
					supermatter_zap(src, range = zap_range, zap_str = discharged_energy, zap_flags = flags, zap_cutoff = src.zap_cutoff, power_level = power, zap_icon = src.zap_icon)
			last_high_energy_accumulation_perspective_machines = SSmachines.times_fired

		if(prob(5))
			supermatter_anomaly_gen(src, FLUX_ANOMALY, rand(5, 10))
		if((power * gas_coefficient) > SEVERE_POWER_PENALTY_THRESHOLD && prob(5) || prob(1))
			supermatter_anomaly_gen(src, GRAVITATIONAL_ANOMALY, rand(5, 10))
		if(((power * gas_coefficient) > SEVERE_POWER_PENALTY_THRESHOLD && prob(2)) || (prob(0.3) && (power * gas_coefficient) > POWER_PENALTY_THRESHOLD))
			supermatter_anomaly_gen(src, BLUESPACE_ANOMALY, rand(5, 10))

	if(prob(15))
		supermatter_pull(loc, min(power / 850, 3)) //850, 1700, 2550
	lights()
	sm_filters()

	//Tells the engi team to get their butt in gear
	if(damage > warning_point) // while the core is still damaged and it's still worth noting its status
		if((REALTIMEOFDAY - lastwarning) / 10 >= WARNING_DELAY)
			alarm()
			if(damage < damage_archived) // We are gaining integrity. Just say that
				radio_announce(span_bold("[safe_alert] Целостность: [get_integrity_percent()]%"), name, ENG_FREQ, radio)
				lastwarning = REALTIMEOFDAY
			else // We are losing integrity, let's warn engineering.
				if(damage > emergency_point) //Oh shit it's bad, time to freak out
					radio_announce(span_big("[emergency_alert] Целостность: [get_integrity_percent()]%"), name, PUB_FREQ, radio)
					lastwarning = REALTIMEOFDAY
					if(!has_reached_emergency)
						investigate_log("has reached the emergency point for the first time.", INVESTIGATE_ENGINE)
						message_admins("[src] has reached the emergency point [ADMIN_JMP(src)].")
						has_reached_emergency = TRUE
				else // The damage is still going up but not yet super high
					radio_announce("<b>[warning_alert] Целостность: [get_integrity_percent()]%</b>", name, ENG_FREQ, radio)
					lastwarning = REALTIMEOFDAY - (WARNING_DELAY * 5)

				// Warning for other engine statuses
				// We are taking damage from power
				if(power > POWER_PENALTY_THRESHOLD)
					radio_announce("<b>Внимание! Гиперструктура достигла опасного уровня мощности.</b>", name, ENG_FREQ, radio)
					// The current gas mix allows EER to keep building up
					if(powerloss_inhibitor < 0.01)
						radio_announce("<b>ОПАСНОСТЬ! ПРОИСХОДИТ ЦЕПНАЯ РЕАКЦИЯ ЗАРЯДА ПО ИНЕРЦИИ.</b>", name, ENG_FREQ, radio)

				// We are taking mole damage
				if(combined_gas > MOLE_PENALTY_THRESHOLD)
					radio_announce("<b>Внимание! Достигнута критическая масса охлаждающего вещества.</b>", name, ENG_FREQ, radio)

			//Boom (Mind blown)
		if(damage > explosion_point)
			count_down()
	return TRUE

/obj/machinery/atmospherics/supermatter_crystal/bullet_act(obj/projectile/proj)
	var/turf/local_turf = loc
	if(!istype(local_turf))
		return FALSE
	if(!istype(proj, /obj/projectile/beam/emitter/hitscan) && power_changes)
		investigate_log("has been hit by [proj] fired by [key_name(proj.firer)]", INVESTIGATE_ENGINE)
	if(proj.flag != BULLET)
		if(power_changes) //This needs to be here I swear
			power += proj.damage * bullet_energy
			if(!has_been_powered)
				enable_for_the_first_time()
	else if(takes_damage)
		damage += proj.damage * bullet_energy
	return FALSE

/obj/machinery/atmospherics/supermatter_crystal/singularity_act()
	var/gain = 100
	investigate_log("was consumed by a singularity.", INVESTIGATE_ENGINE)
	message_admins("Singularity has consumed a supermatter shard and can now become stage six.")
	visible_message(span_userdanger("[DECLENT_RU_CAP(src, NOMINATIVE)] поглощен сингулярностью!"))
	var/turf/sm_turf = get_turf(src)
	for(var/mob/hearing_mob as anything in GLOB.player_list)
		if(!is_valid_z_level(get_turf(hearing_mob), sm_turf))
			continue
		SEND_SOUND(hearing_mob, 'sound/effects/supermatter.ogg') //everyone goan know bout this
		to_chat(hearing_mob, span_bolddanger("Ужасный визг наполняет ваши уши, и вас захлестывает волна ужаса..."))
	qdel(src)
	return gain

/obj/machinery/atmospherics/supermatter_crystal/blob_act(obj/structure/blob/blob)
	if(!blob && isspaceturf(loc)) //does nothing in space
		return

	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)
	damage += blob.obj_integrity * 0.5 //take damage equal to 50% of remaining blob health before it tried to eat us

	if(blob.obj_integrity > 100)
		blob.visible_message(
			span_danger("[capitalize(blob)] strikes at [src] and flinches away!"),
			span_hear("You hear a loud crack as you are washed with a wave of heat."),
		)
		blob.take_damage(100, BURN)
	else
		blob.visible_message(
			span_danger("[capitalize(blob)] strikes at [src] and rapidly flashes to ash."),
			span_hear("You hear a loud crack as you are washed with a wave of heat."),
		)
		Consume(blob)

/obj/machinery/atmospherics/supermatter_crystal/attack_tk(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/jedi = user
	to_chat(jedi, span_userdanger("Это была действительно гениальная идея."))
	jedi.investigate_log("has consumed the brain of [key_name(jedi)] after being touched with telekinesis", INVESTIGATE_DEATHS)
	jedi.visible_message(
		span_danger("[capitalize(jedi)] suddenly slumps over."),
		span_userdanger("As you mentally focus on the supermatter you feel the contents of your skull start melting away. That was a really dense idea.")
	)
	jedi.ghostize()
	var/obj/item/organ/internal/brain/rip_u = jedi.get_int_organ(/obj/item/organ/internal/brain)
	if(rip_u)
		rip_u.remove(jedi)
		qdel(rip_u)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/machinery/atmospherics/supermatter_crystal/attack_alien(mob/user)
	dust_mob(user, cause = "alien attack")

/obj/machinery/atmospherics/supermatter_crystal/attack_animal(mob/living/simple_animal/attacking_animal)
	var/attack_action
	if(!attacking_animal.melee_damage_upper && !attacking_animal.melee_damage_lower)
		attack_action = attacking_animal.friendly
	else
		attack_action = attacking_animal.attacktext
	dust_mob(
		attacking_animal,
		span_danger("[attacking_animal] unwisely [attack_action] [src], and [attacking_animal.p_their()] body burns brilliantly before flashing into ash!"),
		span_userdanger("You unwisely touch [src], and your vision glows brightly as your body crumbles to dust. Oops."),
		"simple animal attack",
	)

/obj/machinery/atmospherics/supermatter_crystal/attack_robot(mob/user)
	if(Adjacent(user))
		dust_mob(user, cause = "cyborg attack")

/obj/machinery/atmospherics/supermatter_crystal/attack_ai(mob/user)
	return

/obj/machinery/atmospherics/supermatter_crystal/attack_hand(mob/living/user)
	..()
	if(HAS_TRAIT(user, TRAIT_SUPERMATTER_IMMUNE))
		user.visible_message(
			span_notice("[user] reaches out and pokes [src] harmlessly...somehow."),
			span_notice("You poke [src].")
		)
		return
	dust_mob(user, cause = "hand")

/obj/machinery/atmospherics/supermatter_crystal/proc/dust_mob(mob/living/nom, vis_msg, mob_msg, cause)
	if(nom.incorporeal_move || HAS_TRAIT(nom, TRAIT_GODMODE)) //try to keep supermatter sliver's + hemostat's dust conditions in sync with this too
		return
	if(!vis_msg)
		vis_msg = span_danger("[nom] протягивает руку и касается [declent_ru(ACCUSATIVE)], вызывая резонанс... [GEND_HIS_HER_CAP(nom)] тело начинает светиться и вспыхивать пламенем, прежде чем превратиться в пыль!")
	if(!mob_msg)
		mob_msg = span_userdanger("Вы протягиваете руку и дотрагиваетесь до [declent_ru(ACCUSATIVE)]. Всё начинает гореть, и вы слышите только звон. Ваша последняя мысль: \"Это было неразумное решение...\".")
	if(!cause)
		cause = "contact"
	nom.visible_message(vis_msg, mob_msg, span_hear("Вы слышите неземной шум, когда вас накрывает волна жара."))
	investigate_log("has been attacked ([cause]) by [key_name(nom)]", INVESTIGATE_ENGINE)
	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)
	Consume(nom)

/obj/machinery/atmospherics/supermatter_crystal/attackby(obj/item/used_item, mob/living/attacking_mob, params)
	if(!istype(used_item) || (used_item.flags & ABSTRACT) || !istype(attacking_mob))
		return ATTACK_CHAIN_BLOCKED

	if(moveable && default_unfasten_wrench(attacking_mob, used_item, time = 20))
		return ATTACK_CHAIN_BLOCKED

	if(istype(used_item, /obj/item/scalpel/supermatter))
		if(!ishuman(attacking_mob))
			return ATTACK_CHAIN_BLOCKED

		var/mob/living/carbon/human/human_user = attacking_mob
		var/obj/item/scalpel/supermatter/scalpel_tool = used_item

		if(!scalpel_tool.uses_left)
			to_chat(human_user, span_warning("[DECLENT_RU_CAP(scalpel_tool, NOMINATIVE)] недостаточно острый, чтобы отрезать кусочек от [declent_ru(ACCUSATIVE)]!"))
			return ATTACK_CHAIN_BLOCKED

		var/obj/item/nuke_core/supermatter_sliver/sliver_core = carve_sliver(human_user)
		if(sliver_core)
			scalpel_tool.uses_left--
			if(!scalpel_tool.uses_left)
				to_chat(human_user, span_boldwarning("Крошечный кусочек отваливается от лезвия [scalpel_tool.declent_ru(ACCUSATIVE)], делая его бесполезным!"))

			var/obj/item/retractor/supermatter/tongs_tool = human_user.is_in_hands(/obj/item/retractor/supermatter)

			if(tongs_tool && !tongs_tool.sliver)
				tongs_tool.sliver = sliver_core
				sliver_core.forceMove(tongs_tool)
				tongs_tool.icon_state = "supermatter_tongs_loaded"
				to_chat(human_user, span_notice("Вы поднимаете [sliver_core.declent_ru(ACCUSATIVE)] [tongs_tool.declent_ru(INSTRUMENTAL)]!"))

		return ATTACK_CHAIN_PROCEED

	if(HAS_TRAIT(used_item, TRAIT_SUPERMATTER_IMMUNE))
		return ATTACK_CHAIN_BLOCKED

	if(istype(used_item, /obj/item/retractor/supermatter))
		to_chat(attacking_mob, span_notice("[DECLENT_RU_CAP(used_item, NOMINATIVE)] отскакивает от [declent_ru(ACCUSATIVE)], сначала нужно отрезать кусочек!"))

	else if(attacking_mob.drop_from_active_hand())
		attacking_mob.visible_message(
			span_danger("Когда [attacking_mob] касается [declent_ru(ACCUSATIVE)] [used_item.declent_ru(INSTRUMENTAL)], в комнате воцаряется тишина..."),
			span_userdanger("Вы нажимаете [declent_ru(INSTRUMENTAL)] на [used_item.declent_ru(ACCUSATIVE)], и всё внезапно замолкает. [used_item.declent_ru(NOMINATIVE)] превращается в пыль, когда вы отшатываетесь от [declent_ru(ACCUSATIVE)]."),
			span_hear("Внезапно все замолкает."),
		)
		investigate_log("has been attacked ([used_item]) by [key_name(attacking_mob)]", INVESTIGATE_ENGINE)
		Consume(used_item)
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)

		radiation_pulse(src, max_range = 3, threshold = 0.1, chance = 50)

/obj/machinery/atmospherics/supermatter_crystal/Bumped(atom/movable/movable_atom)
	if(HAS_TRAIT(movable_atom, TRAIT_SUPERMATTER_IMMUNE))
		return

	if(isliving(movable_atom))
		movable_atom.visible_message(
			span_danger("[DECLENT_RU_CAP(movable_atom, NOMINATIVE)] вреза[PLUR_ET_YUT(movable_atom)]ся  в [declent_ru(ACCUSATIVE)], вызывая резонанс... [GEND_HIS_HER(movable_atom)] тело начинает светиться и вспыхивает, превращаясь в пыль!"),
			span_userdanger("Вы врезаетесь в [declent_ru(ACCUSATIVE)], когда ваши уши наполняются неземным звоном. Ваша последняя мысль: \"О, чёрт!\"."),
			span_hear("Вы слышите неземной шум, когда волна тепла омывает вас."),
		)
	else if(isobj(movable_atom) && !iseffect(movable_atom))
		movable_atom.visible_message(
			span_danger("[DECLENT_RU_CAP(movable_atom, NOMINATIVE)] врезается в [declent_ru(ACCUSATIVE)] и быстро превращается в пепел."),
			null,
			span_hear("Вы слышите громкий треск, когда вас омывает волна тепла."),
		)
	else
		return

	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)
	Consume(movable_atom)

/obj/machinery/atmospherics/supermatter_crystal/Bump(atom/bumped_atom)
	..()
	if(!istype(bumped_atom, /obj/machinery/atmospherics/supermatter_crystal))
		Bumped(bumped_atom)

/obj/machinery/atmospherics/supermatter_crystal/proc/Consume(atom/movable/movable_atom)
	if(isliving(movable_atom))
		var/mob/living/user = movable_atom
		if(HAS_TRAIT(user, TRAIT_GODMODE))
			return
		//message_admins("[src] has consumed [key_name_admin(user)] [ADMIN_JMP(src)].")
		investigate_log("has consumed [key_name(user)].", INVESTIGATE_ENGINE)
		user.dust()
		if(power_changes)
			matter_power += 200

	else if(isobj(movable_atom))
		if(!iseffect(movable_atom))
			var/suspicion = ""
			if(movable_atom.fingerprintslast)
				suspicion = "last touched by [movable_atom.fingerprintslast]"
			//message_admins("[src] has consumed [movable_atom], [suspicion] [ADMIN_JMP(src)].")
			investigate_log("has consumed [movable_atom] - [suspicion].", INVESTIGATE_ENGINE)
			if(istype(movable_atom, /obj/machinery/atmospherics/supermatter_crystal))
				power += 5000//releases A LOT of power
				matter_power += 500000
				damage += 180//drops the integrety by 20%
				movable_atom.visible_message(
					span_danger("[DECLENT_RU_CAP(movable_atom, NOMINATIVE)] врезается в [declent_ru(ACCUSATIVE)], быстро испуская вспышки чистой энергии. Энергия внутри [declent_ru(ACCUSATIVE)] подвергается сверхсветовому рассеянию!"),
					null,
					span_hear("Вы слышите громкий треск, и вас накрывает волна жара."),
				)
		qdel(movable_atom)

	if(!iseffect(movable_atom) && power_changes)
		matter_power += 200

	// Some poor sod got eaten, go ahead and irradiate people nearby.
	radiation_pulse(src, max_range = 6, threshold = 0.3, chance = 30)
	for(var/mob/living/near_mob in range(10))
		investigate_log("has irradiated [key_name(near_mob)] after consuming [movable_atom].", INVESTIGATE_ENGINE)
		near_mob.visible_message(
			span_danger("Когда [declent_ru(NOMINATIVE)] медленно прекращает резонировать, кожа [near_mob.declent_ru(GENITIVE)] покрывается новыми радиационными ожогами."),
			span_danger("Неземной звон стихает, и вы замечаете, что получили новые радиационные ожоги."),
			span_hear("Вы слышите неземной звон и замечаете, что ваша кожа покрыта свежими радиационными ожогами."),
		)

/obj/machinery/atmospherics/supermatter_crystal/proc/sm_filters()
	var/new_filter = isnull(get_filter("ray"))
	ray_filter_helper(1, power ? clamp((damage/100) * power, 50, 125) : 1, (gasmix_power_ratio> 0.8 ? SUPERMATTER_RED : SUPERMATTER_COLOUR), clamp(damage/600, 1, 10), clamp(damage/10, 12, 100))
	// Filter animation persists even if the filter itself is changed externally.
	// Probably prone to breaking. Treat with suspicion.
	if(new_filter)
		animate(get_filter("ray"), offset = 10, time = 10 SECONDS, loop = -1)
		animate(offset = 0, time = 10 SECONDS)

	if(power > POWER_PENALTY_THRESHOLD)
		ray_filter_helper(1, power ? clamp((damage/100) * power, 50, 175) : 1, SUPERMATTER_TESLA_COLOUR, clamp(damage/300, 1, 20), clamp(damage/5, 12, 200))
		if(prob(25))
			new /obj/effect/warp_effect/bsg(get_turf(src)) //Some extra visual effect to the shocking sm which is a bit less interesting.
		if(final_countdown)
			add_filter(name = "icon", priority = 2, params = list(
				type = "layer",
				icon = new/icon('icons/obj/engines_and_power/tesla/energy_ball.dmi', "energy_ball", frame = rand(1,12)),
				flags = FILTER_UNDERLAY
			))
		else
			remove_filter("icon")

	if(combined_gas > MOLE_CRUNCH_THRESHOLD)
		ray_filter_helper(1, power ? clamp((damage/100) * power, 50, 125) : 1, SUPERMATTER_SINGULARITY_RAYS_COLOUR, clamp(damage / 300, 1, 30), clamp(damage / 5, 12, 300))

		add_filter(name = "outline", priority = 2, params = list(
			type = "outline",
			size = 1,
			color = SUPERMATTER_SINGULARITY_LIGHT_COLOUR
		))
		if(!warp)
			warp = new(src)
			vis_contents += warp
		if(pulse_stage == 4)
			animate(warp, time = 6, transform = matrix().Scale(0.5,0.5))
			animate(time = 14, transform = matrix())
			pulse_stage = 0
		else
			pulse_stage++
		if(final_countdown)
			add_filter(name = "icon", priority = 3, params = list(
				type = "layer",
				icon = new/icon('icons/effects/96x96.dmi', "singularity_s3", frame = rand(1,8)),
				flags = FILTER_OVERLAY
			))
		else
			remove_filter("icon")
	else
		vis_contents -= warp
		remove_filter("outline")
		QDEL_NULL(warp)

/obj/machinery/atmospherics/supermatter_crystal/proc/carve_sliver(mob/living/user)
	to_chat(user, span_notice("Вы начинаете откалывать осколок от [declent_ru(GENITIVE)]..."))
	if(do_after(user, 4 SECONDS, src))
		to_chat(user, span_danger("Вы откололи осколок от [declent_ru(GENITIVE)], и [declent_ru(NOMINATIVE)] начинает бурно реагировать!"))
		matter_power += 800

		var/obj/item/nuke_core/supermatter_sliver/S = new /obj/item/nuke_core/supermatter_sliver(drop_location())
		return S

// Change how bright the rock is
/obj/machinery/atmospherics/supermatter_crystal/proc/lights()
	set_light(
		l_range = 4 + power / 200,
		l_power = 1 + power / 1000,
		l_color = gasmix_power_ratio > 0.8 ? SUPERMATTER_RED : SUPERMATTER_COLOUR,
	)

	if(power > POWER_PENALTY_THRESHOLD)
		set_light(
			l_range = 4 + clamp(damage * power, 50, 500),
			l_power = 3,
			l_color = SUPERMATTER_TESLA_COLOUR,
		)
	if(combined_gas > MOLE_CRUNCH_THRESHOLD && get_integrity_percent() > SUPERMATTER_DANGER_PERCENT)
		set_light(
			l_range = 4 + clamp((450 - damage) / 10, 1, 50),
			l_power = 3,
			l_color = SUPERMATTER_SINGULARITY_LIGHT_COLOUR,
		)
	if(combined_gas <= MOLE_CRUNCH_THRESHOLD || get_integrity_percent() >= SUPERMATTER_DANGER_PERCENT)
		for(var/obj/D in darkness_effects)
			qdel(D)
		return

	var/darkness_strength = clamp((damage - 450) / 75, 1, 8) / 2
	var/darkness_aoe = clamp((damage - 450) / 25, 1, 25)
	set_light(
		l_range = 4 + darkness_aoe,
		l_power = -1 - darkness_strength,
		l_color = "#ddd6cf",
	)
	if(!length(darkness_effects) && !moveable) //Don't do this on movable sms oh god. Ideally don't do this at all, but hey, that's lightning for you
		darkness_effects += new /obj/effect/abstract(locate(x - 3, y + 3, z))
		darkness_effects += new /obj/effect/abstract(locate(x + 3, y + 3, z))
		darkness_effects += new /obj/effect/abstract(locate(x - 3, y - 3, z))
		darkness_effects += new /obj/effect/abstract(locate(x + 3, y - 3, z))
	else
		for(var/obj/O in darkness_effects)
			O.set_light(
				l_range = 0 + darkness_aoe,
				l_power = -1 - darkness_strength / 1.25,
				l_color = "#ddd6cf",
			)

/obj/machinery/atmospherics/supermatter_crystal/proc/supermatter_pull(turf/center, pull_range = 3)
	playsound(center, 'sound/weapons/marauder.ogg', 100, TRUE, extrarange = pull_range - world.view)
	for(var/atom/movable/movable_atom in orange(pull_range,center))
		if((movable_atom.anchored || movable_atom.move_resist >= MOVE_FORCE_EXTREMELY_STRONG)) //move resist memes.
			if(iscloset(movable_atom))
				var/obj/structure/closet/closet = movable_atom
				closet.open()
			continue
		if(ismob(movable_atom))
			var/mob/pulled_mob = movable_atom
			if(pulled_mob.mob_negates_gravity())
				continue //You can't pull someone nailed to the deck
			if(HAS_TRAIT(pulled_mob, TRAIT_SUPERMATTER_IMMUNE))
				continue
			else if(pulled_mob.buckled)
				var/atom/movable/buckler = pulled_mob.buckled
				if(buckler.unbuckle_mob(pulled_mob, TRUE))
					visible_message(span_danger("Невероятная сила [declent_ru(GENITIVE)] отрывает [pulled_mob.declent_ru(ACCUSATIVE)] от [buckler.declent_ru(GENITIVE)]!"))
		step_towards(movable_atom, center)

/obj/machinery/atmospherics/supermatter_crystal/proc/supermatter_anomaly_gen(turf/anomalycenter, type = FLUX_ANOMALY, anomalyrange = 5)
	var/turf/local_turf = pick(RANGE_TURFS(anomalyrange, anomalycenter))
	if(local_turf)
		switch(type)
			if(FLUX_ANOMALY)
				var/obj/effect/anomaly/energetic/energetic_anomaly = new(local_turf, 30 SECONDS, FALSE)
				energetic_anomaly.explosive = FALSE
			if(GRAVITATIONAL_ANOMALY)
				new /obj/effect/anomaly/gravitational(local_turf, 25 SECONDS, FALSE)
			if(BLUESPACE_ANOMALY)
				new /obj/effect/anomaly/bluespace(local_turf, 25 SECONDS, FALSE, FALSE, TRUE)

/**
 * Accumulates energy for the zap_energy_accumulation key.
 * Args:
 * * key: The zap energy accumulation key to use.
 * * energy: The amount of energy to accumulate.
 * Returns: The accumulated energy for that key.
 */
/obj/machinery/atmospherics/supermatter_crystal/proc/accumulate_energy(key, energy)
	. = (zap_energy_accumulation[key] ? zap_energy_accumulation[key] : 0) + energy
	zap_energy_accumulation[key] = .

/**
 * Depletes a portion of the accumulated energy for the given key and returns it. Used for discharging energy from the supermatter.
 * Args:
 * * key: The zap energy accumulation key to use.
 * * portion: The portion of the accumulated energy that gets discharged.
 * Returns: The discharged energy for that key.
 */
/obj/machinery/atmospherics/supermatter_crystal/proc/discharge_energy(key, portion = ZAP_ENERGY_DISCHARGE_PORTION)
	. = portion * zap_energy_accumulation[key]
	zap_energy_accumulation[key] -= .

/obj/machinery/proc/supermatter_zap(atom/zapstart = src, range = 5, zap_str = 4000, zap_flags = ZAP_SUPERMATTER_FLAGS, list/targets_hit = list(), zap_cutoff = 1500, power_level = 0, zap_icon = DEFAULT_ZAP_ICON_STATE, color = null)
	if(QDELETED(zapstart))
		return
	if(zap_cutoff <= 0)
		stack_trace("/obj/machinery/supermatter_zap() was called with a non-positive value")
		return
	if(zap_str <= 0) // Just in case something scales zap_str and zap_cutoff to 0.
		return
	. = zapstart.dir
	//If the strength of the zap decays past the cutoff, we stop
	if(zap_str < zap_cutoff)
		return
	var/atom/target
	var/target_type = LOWEST
	var/list/arc_targets = list()
	//Making a new copy so additons further down the recursion do not mess with other arcs
	//Lets put this ourself into the do not hit list, so we don't curve back to hit the same thing twice with one arc
	for(var/atom/test as anything in oview(zapstart, range))
		if(!(zap_flags & ZAP_ALLOW_DUPLICATES) && LAZYACCESS(targets_hit, test))
			continue

		if(target_type > COIL)
			continue

		if(istype(test, /obj/machinery/power/energy_accumulator/tesla_coil/))
			var/obj/machinery/power/energy_accumulator/tesla_coil/coil = test
			if(!HAS_TRAIT(coil, TRAIT_BEING_SHOCKED) && coil.anchored && !coil.panel_open && prob(70))//Diversity of death
				if(target_type != COIL)
					arc_targets = list()
				arc_targets += test
				target_type = COIL

		if(target_type > ROD)
			continue

		if(istype(test, /obj/machinery/power/energy_accumulator/grounding_rod))
			var/obj/machinery/power/energy_accumulator/grounding_rod/rod = test
			//We're adding machine damaging effects, rods need to be surefire
			if(rod.anchored && !rod.panel_open)
				if(target_type != ROD)
					arc_targets = list()
				arc_targets += test
				target_type = ROD

		if(target_type > LIVING)
			continue

		if(isliving(test))
			var/mob/living/alive = test
			if(!HAS_TRAIT(alive, TRAIT_TESLA_SHOCKIMMUNE) && !HAS_TRAIT(alive, TRAIT_BEING_SHOCKED) && alive.stat != DEAD && prob(20))//let's not hit all the engineers with every beam and/or segment of the arc
				if(target_type != LIVING)
					arc_targets = list()
				arc_targets += test
				target_type = LIVING

		if(target_type > MACHINERY)
			continue

		if(ismachinery(test))
			if(!HAS_TRAIT(test, TRAIT_BEING_SHOCKED) && prob(40))
				if(target_type != MACHINERY)
					arc_targets = list()
				arc_targets += test
				target_type = MACHINERY

		if(target_type > OBJECT)
			continue

		if(isobj(test))
			if(!HAS_TRAIT(test, TRAIT_BEING_SHOCKED))
				if(target_type != OBJECT)
					arc_targets = list()
				arc_targets += test
				target_type = OBJECT

	if(length(arc_targets)) //Pick from our pool
		target = pick(arc_targets)

	if(QDELETED(target))//If we didn't found something
		return

	//Do the animation to zap to it from here
	if(!(zap_flags & ZAP_ALLOW_DUPLICATES))
		LAZYSET(targets_hit, target, TRUE)
	zapstart.Beam(target, icon_state = zap_icon, time = 0.5 SECONDS, beam_color = color)
	var/zapdir = get_dir(zapstart, target)
	if(zapdir)
		. = zapdir

	//Going boom should be rareish
	if(prob(80))
		zap_flags &= ~ZAP_MACHINE_EXPLOSIVE
	if(target_type == COIL || target_type == ROD)
		zap_flags += ZAP_GENERATES_POWER
		//In the best situation we can expect this to grow up to 2120kw before a delam/IT'S GONE TOO FAR FRED SHUT IT DOWN
		//The formula for power gen is zap_str * zap_mod / 2 * capacitor rating, between 1 and 4
		var/multi = 10
		switch(power_level)//Between 7k and 9k it's 20, above that it's 40
			if(SEVERE_POWER_PENALTY_THRESHOLD to CRITICAL_POWER_PENALTY_THRESHOLD)
				multi = 20
			if(CRITICAL_POWER_PENALTY_THRESHOLD to INFINITY)
				multi = 40
		if(zap_flags & ZAP_SUPERMATTER_FLAGS)
			var/remaining_power = target.zap_act(zap_str * multi, zap_flags)
			zap_str = remaining_power / multi //Coils should take a lot out of the power of the zap
		else
			zap_str /= 3

	else if(isliving(target))//If we got a fleshbag on our hands
		var/mob/living/creature = target
		ADD_TRAIT(creature, TRAIT_BEING_SHOCKED, WAS_SHOCKED)
		addtimer(TRAIT_CALLBACK_REMOVE(creature, TRAIT_BEING_SHOCKED, WAS_SHOCKED), 1 SECONDS)
		//3 shots a human with no resistance. 2 to crit, one to death. This is at at least 10000 power.
		//There's no increase after that because the input power is effectivly capped at 10k
		//Does 1.5 damage at the least
		var/shock_damage = ((zap_flags & ZAP_MOB_DAMAGE) ? (power_level / 200) - 10 : rand(5,10))
		creature.electrocute_act(shock_damage, "Supermatter Discharge Bolt", 1,  ((zap_flags & ZAP_MOB_STUN) ? SHOCK_TESLA : SHOCK_NOSTUN))
		zap_str /= 1.5 //Meatsacks are conductive, makes working in pairs more destructive

	else
		zap_str = target.zap_act(zap_str, zap_flags)

	//This gotdamn variable is a boomer and keeps giving me problems
	var/turf/target_turf = get_turf(target)
	var/pressure = 1
	var/datum/gas_mixture/air_mixture = target_turf?.get_readonly_air()
	if(air_mixture)
		pressure = max(1, air_mixture.return_pressure())
		var/datum/milla_safe/supermatter_electrolyze/milla = new()
		milla.invoke_async(target, zap_str, power_level)
	//We get our range with the strength of the zap and the pressure, the higher the former and the lower the latter the better
	var/new_range = clamp(zap_str / pressure * 10, 2, 7)
	var/zap_count = 1
	if(prob(5))
		zap_str -= (zap_str/10)
		zap_count += 1
	for(var/j in 1 to zap_count)
		var/child_targets_hit = targets_hit
		if(zap_count > 1)
			child_targets_hit = targets_hit.Copy() //Pass by ref begone
		supermatter_zap(target, new_range, zap_str, zap_flags, child_targets_hit, zap_cutoff, power_level, zap_icon, color)

/datum/milla_safe/supermatter_electrolyze

/datum/milla_safe/supermatter_electrolyze/on_run(atom/target, zap_str, power_level)
	if(!target)
		return

	var/turf/location = get_turf(target)
	if(!location)
		return

	var/datum/gas_mixture/env = get_turf_air(location)
	env.electrolyze(working_power = zap_str / 200, electrolyzer_args = list(ELECTROLYSIS_ARGUMENT_SUPERMATTER_POWER = power_level))

/obj/machinery/atmospherics/supermatter_crystal/proc/manual_start(amount)
	has_been_powered = TRUE
	power += amount
	message_admins("[src] has been activated and given an increase EER of [amount] at [ADMIN_JMP(src)]")

/obj/machinery/atmospherics/supermatter_crystal/proc/make_next_event_time()
	// Some completely random bullshit to make a "bell curve"
	var/fake_time = rand(5 MINUTES, 25 MINUTES)
	if(fake_time < 15 MINUTES && prob(30))
		fake_time += rand(2 MINUTES, 10 MINUTES)
	else if(fake_time > 15 MINUTES && prob(30))
		fake_time -= rand(2 MINUTES, 10 MINUTES)
	next_event_time = fake_time + world.time

/obj/machinery/atmospherics/supermatter_crystal/proc/try_events()
	if(!has_been_powered)
		return
	if(!crystal_can_run_events)
		return
	if(!next_event_time) // for when the SM starts
		make_next_event_time()
		return
	if(world.time < next_event_time)
		return
	if(event_active)
		return
	var/static/list/events = list(
		/datum/engi_event/supermatter_event/delta_tier = 40,
		/datum/engi_event/supermatter_event/charlie_tier = 40,
		/datum/engi_event/supermatter_event/bravo_tier = 15,
		/datum/engi_event/supermatter_event/alpha_tier = 5,
		/datum/engi_event/supermatter_event/sierra_tier = 1,
	)

	var/datum/engi_event/supermatter_event/event = pick(subtypesof(pickweight(events)))
	if(ispath(event, /datum/engi_event/supermatter_event/sierra_tier) && has_run_sclass)
		make_next_event_time()
		return // We're only gonna have one s-class per round, take a break engineers
	run_event(event)
	make_next_event_time()

/obj/machinery/atmospherics/supermatter_crystal/proc/run_event(datum/engi_event/supermatter_event/event) // mostly admin testing and stuff
	if(ispath(event))
		event = new event(src)
	if(!istype(event))
		log_debug("Attempted supermatter event aborted due to incorrect path. Incorrect path type: [event.type].")
		return
	event.start_event()

/obj/machinery/atmospherics/supermatter_crystal/proc/enable_for_the_first_time()
	investigate_log("has been powered for the first time.", INVESTIGATE_ENGINE)
	message_admins("[src] has been powered for the first time [ADMIN_JMP(src)].")
	has_been_powered = TRUE
	make_next_event_time()

#undef BIKE
#undef COIL
#undef ROD
#undef LIVING
#undef MACHINERY
#undef OBJECT
#undef LOWEST
