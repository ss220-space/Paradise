/datum/vampire_subclass
	/// The subclass' name. Used for blackbox logging.
	var/name = "yell at coderbus"
	/// A list of powers that a vampire unlocks. The value of the list entry is equal to the blood total required for the vampire to unlock it.
	var/list/standard_powers
	/// A list of the powers a vampire unlocks when it reaches full power.
	var/list/fully_powered_abilities
	/// Whether or not a vampire heals more based on damage taken.
	var/improved_rejuv_healing = FALSE
	/// maximun number of thralls a vampire may have at a time. incremented as they grow stronger, up to a cap at full power.
	var/thrall_cap = 1
	/// If true, lets the vampire have access to their full power abilities without meeting the blood requirement, or needing a certain number of drained humans.
	var/full_power_override = FALSE
	/// Maximum number of dissections vampire can proceed from one target.
	var/dissect_cap = 1
	/// Maximum number of critical organs vampire can dissect.
	var/crit_organ_cap = 2
	/// Link to a spell with TGUI.
	var/datum/action/cooldown/spell/dissect_info/spell_TGUI
	/// Name addition for antag menu
	var/antag_menu_addition
	/// Associated list of all trophies bestia subclass got via round.
	var/list/trophies = list(
		INTERNAL_ORGAN_HEART = 0,
		INTERNAL_ORGAN_LUNGS = 0,
		INTERNAL_ORGAN_LIVER = 0,
		INTERNAL_ORGAN_KIDNEYS = 0,
		INTERNAL_ORGAN_EYES = 0,
		INTERNAL_ORGAN_EARS = 0,
	)

/datum/vampire_subclass/proc/on_blood_sucking(mob/living/carbon/human/H)
	return

/datum/vampire_subclass/proc/add_subclass_ability(datum/antagonist/vampire/vamp)
	for(var/thing in standard_powers)
		if(vamp.bloodtotal >= standard_powers[thing])
			vamp.add_ability(thing)

/datum/vampire_subclass/proc/on_remove(datum/antagonist/vampire/vamp)
	return

/datum/vampire_subclass/proc/add_full_power_abilities(datum/antagonist/vampire/vamp)
	for(var/thing in fully_powered_abilities)
		vamp.add_ability(thing)

/datum/vampire_subclass/umbrae
	name = "umbrae"
	antag_menu_addition = "умбра"
	standard_powers = list(
		/datum/action/cooldown/spell/umbrae_cloak = 100,
		/datum/action/cooldown/spell/pointed/shadow_snare = 200,
		/datum/action/cooldown/spell/soul_anchor = 200,
		/datum/action/cooldown/spell/pointed/dark_passage = 300,
		/datum/vampire_passive/xray = 300,
		/datum/action/cooldown/spell/aoe/vamp_extinguish = 400,
		/datum/action/cooldown/spell/pointed/shadow_boxing = 600,
	)
	fully_powered_abilities = list(
		/datum/vampire_passive/full,
		/datum/action/cooldown/spell/eternal_darkness,
	)

/datum/vampire_subclass/umbrae/on_blood_sucking(mob/living/carbon/human/H)
	var/list/lights = list()
	for(var/obj/machinery/light/L in SSmachines.get_by_type(/obj/machinery/light))
		if(L.status && L.z == H.z)
			lights += L

	var/obj/machinery/light/L = pick(lights)
	L.break_light_tube()

/datum/vampire_subclass/hemomancer
	name = "hemomancer"
	antag_menu_addition = "гемомансер"
	standard_powers = list(
		/datum/action/cooldown/spell/vamp_claws = 100,
		/datum/action/cooldown/spell/pointed/blood_tendrils = 200,
		/datum/action/cooldown/spell/pointed/blood_barrier = 200,
		/datum/action/cooldown/spell/jaunt/ethereal_jaunt/blood_pool = 300,
		/datum/action/cooldown/spell/list_target/predator_senses = 400,
		/datum/action/cooldown/spell/aoe/blood_eruption = 600,
	)
	fully_powered_abilities = list(
		/datum/vampire_passive/full,
		/datum/action/cooldown/spell/blood_spill,
	)

/datum/vampire_subclass/hemomancer/on_blood_sucking(mob/living/carbon/human/H)
	H.setBlood(min(H.blood_volume + 5, BLOOD_VOLUME_NORMAL))

/datum/vampire_subclass/gargantua
	name = "gargantua"
	antag_menu_addition = "гаргантюа"
	standard_powers = list(
		/datum/action/cooldown/spell/blood_swell = 100,
		/datum/action/cooldown/spell/blood_rush = 200,
		/datum/action/cooldown/spell/stomp = 200,
		/datum/vampire_passive/blood_swell_upgrade = 300,
		/datum/action/cooldown/spell/overwhelming_force = 400,
		/datum/action/cooldown/spell/pointed/projectile/demonic_grasp = 600,
	)
	fully_powered_abilities = list(
		/datum/vampire_passive/full,
		/datum/action/cooldown/spell/pointed/garg_charge,
	)
	improved_rejuv_healing = TRUE

/datum/vampire_subclass/gargantua/on_blood_sucking(mob/living/carbon/human/H)
	H.adjustBruteLoss(-2)
	H.adjustFireLoss(-2)

/datum/vampire_subclass/dantalion
	name = "dantalion"
	antag_menu_addition = "данталион"
	standard_powers = list(
		/datum/action/cooldown/spell/pointed/dantalion_enthrall = 100,
		/datum/action/cooldown/spell/dantalion_thrall_commune = 100,
		/datum/action/cooldown/spell/pointed/pacify = 200,
		/datum/action/cooldown/spell/pointed/switch_places = 200,
		/datum/action/cooldown/spell/dantalion_decoy = 300,
		/datum/vampire_passive/increment_thrall_cap = 300,
		/datum/action/cooldown/spell/aoe/rally_thralls = 400,
		/datum/vampire_passive/increment_thrall_cap/two = 400,
		/datum/action/cooldown/spell/share_damage = 600,
	)
	fully_powered_abilities = list(
		/datum/vampire_passive/full,
		/datum/action/cooldown/spell/aoe/hysteria,
		/datum/vampire_passive/increment_thrall_cap/three,
	)

/datum/vampire_subclass/dantalion/on_blood_sucking(mob/living/carbon/human/H)
	for(var/datum/mind/thrall in H?.mind?.som?.serv)
		thrall.current?.adjustBruteLoss(-3)
		thrall.current?.adjustFireLoss(-3)
		thrall.current?.adjustOxyLoss(-5)

/datum/vampire_subclass/gargantua/add_subclass_ability(datum/antagonist/vampire/vamp)
	. = ..()
	ADD_TRAIT(vamp.owner.current, TRAIT_STRONG_MUSCLES, VAMPIRE_TRAIT)
	SEND_SIGNAL(vamp.owner.current, COMSIG_STRENGTH_LEVEL_UP, 5)

/datum/vampire_subclass/gargantua/on_remove(datum/antagonist/vampire/vamp)
	REMOVE_TRAIT(vamp.owner.current, TRAIT_STRONG_MUSCLES, VAMPIRE_TRAIT)

/datum/vampire_subclass/bestia
	name = "bestia"
	antag_menu_addition = "бестия"
	standard_powers = list(
		/datum/action/cooldown/spell/dissect_info = 100,
		/datum/action/cooldown/spell/dissect = 100,
		/datum/action/cooldown/spell/infected_trophy = 100,
		/datum/action/cooldown/spell/pointed/bestia_lunge = 200,
		/datum/action/cooldown/spell/pointed/bestia_mark= 200,
		/datum/action/cooldown/spell/shapeshift/vampire/bats = 300,
		/datum/action/cooldown/spell/anabiosis = 400,
		/datum/vampire_passive/dissection_cap = 400,
		/datum/action/cooldown/spell/conjure/bestia_bats = 600,
		/datum/vampire_passive/upgraded_grab = 600,
	)
	fully_powered_abilities = list(
		/datum/vampire_passive/full,
		/datum/action/cooldown/spell/shapeshift/vampire/hound,
		/datum/vampire_passive/dissection_cap/two,
	)
	improved_rejuv_healing = TRUE

/datum/vampire_subclass/bestia/on_blood_sucking(mob/living/carbon/human/H)
	H.adjustBruteLoss(-2)
	H.adjustFireLoss(-2)

/datum/vampire_subclass/ancient
	name = "ancient"
	standard_powers = list(
		/datum/action/cooldown/spell/dissect_info,
		/datum/action/cooldown/spell/dissect,
		/datum/action/cooldown/spell/infected_trophy,
		/datum/action/cooldown/spell/vamp_claws,
		/datum/action/cooldown/spell/blood_swell,
		/datum/action/cooldown/spell/umbrae_cloak,
		/datum/action/cooldown/spell/pointed/dantalion_enthrall,
		/datum/action/cooldown/spell/dantalion_thrall_commune,
		/datum/action/cooldown/spell/pointed/bestia_lunge,
		/datum/action/cooldown/spell/pointed/bestia_mark,
		/datum/action/cooldown/spell/pointed/blood_tendrils,
		/datum/action/cooldown/spell/pointed/blood_barrier,
		/datum/action/cooldown/spell/blood_rush,
		/datum/action/cooldown/spell/stomp,
		/datum/action/cooldown/spell/pointed/shadow_snare,
		/datum/action/cooldown/spell/soul_anchor,
		/datum/action/cooldown/spell/pointed/pacify,
		/datum/action/cooldown/spell/pointed/switch_places,
		/datum/action/cooldown/spell/jaunt/ethereal_jaunt/blood_pool,
		/datum/action/cooldown/spell/shapeshift/vampire/bats,
		/datum/vampire_passive/blood_swell_upgrade,
		/datum/action/cooldown/spell/pointed/dark_passage,
		/datum/action/cooldown/spell/dantalion_decoy,
		/datum/action/cooldown/spell/aoe/blood_eruption,
		/datum/action/cooldown/spell/anabiosis,
		/datum/action/cooldown/spell/list_target/predator_senses,
		/datum/action/cooldown/spell/overwhelming_force,
		/datum/action/cooldown/spell/aoe/vamp_extinguish,
		/datum/action/cooldown/spell/aoe/rally_thralls,
		/datum/action/cooldown/spell/share_damage,
		/datum/action/cooldown/spell/pointed/projectile/demonic_grasp,
		/datum/action/cooldown/spell/pointed/shadow_boxing,
		/datum/action/cooldown/spell/conjure/bestia_bats,
		/datum/vampire_passive/upgraded_grab,
		/datum/vampire_passive/full,
		/datum/action/cooldown/spell/shapeshift/vampire/hound,
		/datum/action/cooldown/spell/blood_spill,
		/datum/action/cooldown/spell/pointed/garg_charge,
		/datum/action/cooldown/spell/eternal_darkness,
		/datum/action/cooldown/spell/aoe/hysteria,
		/datum/action/cooldown/spell/aoe/raise_vampires,
		/datum/vampire_passive/xray,
	)
	improved_rejuv_healing = TRUE
	thrall_cap = 150 // can thrall high pop
	dissect_cap = 6
	crit_organ_cap = 6
