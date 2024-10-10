/datum/species
	var/name                     // Species name.
	var/name_plural 			 // Pluralized name (since "[name]s" is not always valid)
	var/a = "a"					 // the "a" or "an" in "a Vulpkanin" or "an Abductor", use with singular version

	var/icobase = 'icons/mob/human_races/r_human.dmi'    // Normal icon set.
	var/deform = 'icons/mob/human_races/r_def_human.dmi' // Mutated icon set.

	// Damage overlay and masks.
	var/damage_overlays = 'icons/mob/human_races/masks/dam_human.dmi'
	var/damage_mask = 'icons/mob/human_races/masks/dam_mask_human.dmi'
	var/blood_mask = 'icons/mob/human_races/masks/blood_human.dmi'

	var/blood_species // Species blood's name
	var/can_be_pale = FALSE

	var/eyes = "eyes_s"                                  // Icon for eyes.
	var/blurb = "A completely nondescript species."      // A brief lore summary for use in the chargen screen.
	var/butt_sprite = "human"

	var/datum/species/primitive_form = null          // Lesser form, if any (ie. monkey for humans)
	var/datum/species/greater_form = null             // Greater form, if any, ie. human for monkeys.

	var/roundstart = TRUE
	var/id = null


	/// Name of tail image in species effects icon file.
	var/tail

	/// like tail but wings
	var/wing
	var/datum/unarmed_attack/unarmed                  //For empty hand harm-intent attack
	var/unarmed_type = /datum/unarmed_attack
	var/silent_steps = 0          // Stops step noises

	var/cold_level_1 = 260  // Cold damage level 1 below this point.
	var/cold_level_2 = 200  // Cold damage level 2 below this point.
	var/cold_level_3 = 120  // Cold damage level 3 below this point.

	var/heat_level_1 = 360  // Heat damage level 1 above this point.
	var/heat_level_2 = 400  // Heat damage level 2 above this point.
	var/heat_level_3 = 460 // Heat damage level 3 above this point; used for body temperature

	var/body_temperature = BODYTEMP_NORMAL	//non-IS_SYNTHETIC species will try to stabilize at this temperature. (also affects temperature processing)
	var/reagent_tag                 //Used for metabolizing reagents.

	var/digestion_ratio = 1 //How quickly the species digests/absorbs reagents.
	var/taste_sensitivity = TASTE_SENSITIVITY_NORMAL //the most widely used factor; humans use a different one

	var/hunger_icon = 'icons/mob/screen_hunger.dmi'
	var/hunger_type
	var/hunger_level

	var/hazard_high_pressure = HAZARD_HIGH_PRESSURE   // Dangerously high pressure.
	var/warning_high_pressure = WARNING_HIGH_PRESSURE // High pressure warning.
	var/warning_low_pressure = WARNING_LOW_PRESSURE   // Low pressure warning.
	var/hazard_low_pressure = HAZARD_LOW_PRESSURE     // Dangerously low pressure.

	// DO NOT CHANGE THESE VARS OUTSIDE OF OVERRIDING BY OTHER SPECIES, USE PHYSIOLOGY DATUM, OR I WILL FIND YOU .\_/.
	// [/code/mob/living/carbon/human/physiology.dm]

	/// Flat modifier on all damage taken from any source.
	/// IE: 10 = 10% less damage taken.
	var/damage_resistance = 0
	/// Physical damage reduction/amplification
	var/brute_mod = 1
	/// Burn damage reduction/amplification
	var/burn_mod = 1
	/// Toxin damage reduction/amplification
	var/tox_mod = 1
	/// Oxy damage reduction/amplification
	var/oxy_mod = 1
	/// Clone damage reduction/amplification
	var/clone_mod = 1
	/// Brain damage reduction/amplification
	var/brain_mod = 1
	/// Stamina damage reduction/amplification
	var/stamina_mod = 1
	/// If a species is more/less impacated by incapacitated effects (stun/weaken/knockdown/paralysis/sleeping)
	var/stun_mod = 1
	/// Hunder drain reduction/amplification
	var/hunger_drain_mod = 1
	/// Lowest possible punch damage
	var/punchdamagelow = 0
	/// Highest possible punch damage
	var/punchdamagehigh = 9
	/// Damage at which punches from this race will stun
	var/punchstunthreshold = 9
	/// Damage for punching objects
	var/obj_damage = 0
	/// Fractures chance reduction/amplification
	var/bonefragility = 1
	/// Damage multiplier for being in a hot environment
	var/heatmod = 1
	/// Damage multiplier for being in a cold environment
	var/coldmod = 1
	/// Base electrocution coefficient
	var/siemens_coeff = 1
	/// How quickly germs are growing
	var/germs_growth_mod = 1
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/// Maximum health of this species
	var/total_health = 100
	/// What type of damage does this species take if it's low on blood?
	var/blood_damage_type = OXY
	/// Species default genes
	var/list/default_genes
	/// Species movement speed. Positive numbers make it move slower, negative numbers make it move faster
	var/speed_mod = 0

	var/has_fine_manipulation = 1 // Can use small items.
	var/fingers_count = 10

	///Sounds to override barefeet walking
	var/list/special_step_sounds

	var/list/allowed_consumed_mobs = list() //If a species can consume mobs, put the type of mobs it can consume here.

	/// Generic traits tied to having the species.
	var/list/inherent_traits

	/// Bitflags of all the disabilities blacklisted for this species in character creation screen
	var/blacklisted_disabilities = DISABILITY_FLAG_WINGDINGS

	var/breathid = "o2"

	var/clothing_flags = 0 // Underwear and socks.
	var/exotic_blood
	var/skinned_type
	var/list/no_equip = list()	// slots the race can't equip stuff to
	var/nojumpsuit = 0	// this is sorta... weird. it basically lets you equip stuff that usually needs jumpsuits without one, like belts and pockets and ids
	var/can_craft = TRUE // Can this mob using crafting or not?

	var/bodyflags = 0

	var/blood_color = COLOR_BLOOD_BASE //Red.
	var/flesh_color = "#d1aa2e" //Gold.
	var/single_gib_type = /obj/effect/decal/cleanable/blood/gibs
	var/remains_type = /obj/effect/decal/remains/human //What sort of remains is left behind when the species dusts
	var/base_color      //Used when setting species.
	var/list/inherent_factions

	//Used in icon caching.
	var/race_key = 0
	var/icon/icon_template

	/// Indicates that this species belongs to lesser human forms.
	var/is_monkeybasic = FALSE
	var/show_ssd = 1
	var/forced_heartattack = FALSE //Some species have blood, but we still want them to have heart attacks
	var/dies_at_threshold = FALSE // Do they die or get knocked out at specific thresholds, or do they go through complex crit?
	var/can_revive_by_healing				// Determines whether or not this species can be revived by simply healing them
	var/has_gender = TRUE
	var/blacklisted = FALSE
	var/dangerous_existence = FALSE

	/// Death vars. See [/proc/genderize_decode] for more info.
	var/death_message = "цепене%(ет,ют)% и расслабля%(ет,ют)%ся, %(его,её,его,их)% взгляд становится пустым и безжизненным..."
	var/list/suicide_messages = list(
		"пытается откусить себе язык!",
		"выдавливает свои глазницы большими пальцами!",
		"сворачивает себе шею!",
		"задерживает дыхание!")

	// Language/culture vars.
	var/default_language = LANGUAGE_GALACTIC_COMMON	// Default language is used when 'say' is used without modifiers.
	var/language = LANGUAGE_GALACTIC_COMMON			// Default racial language, if any.
	var/secondary_langs = list()					// The keys of secondary languages that are available to this species.
	var/list/speech_sounds							// A list of sounds to potentially play when speaking.
	var/list/speech_chance							// The likelihood of a speech sound playing.
	var/scream_verb = "крич%(ит,ат)%"				// Special symbols used to apply correct gender. See [/proc/genderize_decode] for more info.
	var/female_giggle_sound = list('sound/voice/giggle_female_1.ogg','sound/voice/giggle_female_2.ogg','sound/voice/giggle_female_3.ogg')
	var/male_giggle_sound = list('sound/voice/giggle_male_1.ogg','sound/voice/giggle_male_2.ogg')
	var/male_scream_sound = list('sound/goonstation/voice/male_scream.ogg')
	var/female_scream_sound = list('sound/goonstation/voice/female_scream.ogg')
	var/female_laugh_sound = list('sound/voice/laugh_female_1.ogg','sound/voice/laugh_female_2.ogg','sound/voice/laugh_female_3.ogg')
	var/male_laugh_sound = list('sound/voice/laugh_male_1.ogg','sound/voice/laugh_male_2.ogg','sound/voice/laugh_male_3.ogg')
	var/list/death_sounds = list('sound/goonstation/voice/deathgasp_1.ogg', 'sound/goonstation/voice/deathgasp_2.ogg')
	var/list/male_dying_gasp_sounds = list('sound/goonstation/voice/male_dying_gasp_1.ogg', 'sound/goonstation/voice/male_dying_gasp_2.ogg', 'sound/goonstation/voice/male_dying_gasp_3.ogg', 'sound/goonstation/voice/male_dying_gasp_4.ogg', 'sound/goonstation/voice/male_dying_gasp_5.ogg', 'sound/voice/gasp_male1.ogg','sound/voice/gasp_male2.ogg','sound/voice/gasp_male3.ogg','sound/voice/gasp_male4.ogg','sound/voice/gasp_male5.ogg','sound/voice/gasp_male6.ogg','sound/voice/gasp_male7.ogg')
	var/list/female_dying_gasp_sounds = list('sound/goonstation/voice/female_dying_gasp_1.ogg', 'sound/goonstation/voice/female_dying_gasp_2.ogg', 'sound/goonstation/voice/female_dying_gasp_3.ogg', 'sound/goonstation/voice/female_dying_gasp_4.ogg', 'sound/goonstation/voice/female_dying_gasp_5.ogg', 'sound/voice/gasp_female1.ogg','sound/voice/gasp_female2.ogg','sound/voice/gasp_female3.ogg','sound/voice/gasp_female4.ogg','sound/voice/gasp_female5.ogg','sound/voice/gasp_female6.ogg','sound/voice/gasp_female7.ogg')
	var/gasp_sound = list('sound/goonstation/voice/gasp.ogg')
	var/male_cough_sounds = list('sound/effects/mob_effects/m_cougha.ogg','sound/effects/mob_effects/m_coughb.ogg', 'sound/effects/mob_effects/m_coughc.ogg')
	var/female_cough_sounds = list('sound/effects/mob_effects/f_cougha.ogg','sound/effects/mob_effects/f_coughb.ogg')
	var/male_sneeze_sound = list('sound/effects/mob_effects/sneeze.ogg')
	var/female_sneeze_sound = list('sound/effects/mob_effects/f_sneeze.ogg')
	var/female_cry_sound = list('sound/voice/cry_female_1.ogg','sound/voice/cry_female_2.ogg','sound/voice/cry_female_3.ogg')
	var/male_cry_sound = list('sound/voice/cry_male_1.ogg','sound/voice/cry_male_2.ogg')
	var/female_grumble_sound = list()
	var/male_grumble_sound = list()
	var/female_moan_sound = list('sound/voice/moan_female_1.ogg','sound/voice/moan_female_2.ogg','sound/voice/moan_female_3.ogg')
	var/male_moan_sound = list('sound/voice/moan_male_1.ogg','sound/voice/moan_male_2.ogg','sound/voice/moan_male_3.ogg')
	var/female_sigh_sound = list('sound/voice/sigh_female.ogg')
	var/male_sigh_sound = list('sound/voice/sigh_male.ogg')
	var/female_choke_sound = list('sound/voice/gasp_female1.ogg','sound/voice/gasp_female2.ogg','sound/voice/gasp_female3.ogg','sound/voice/gasp_female4.ogg','sound/voice/gasp_female5.ogg','sound/voice/gasp_female6.ogg','sound/voice/gasp_female7.ogg')
	var/male_choke_sound = list('sound/voice/gasp_male1.ogg','sound/voice/gasp_male2.ogg','sound/voice/gasp_male3.ogg','sound/voice/gasp_male4.ogg','sound/voice/gasp_male5.ogg','sound/voice/gasp_male6.ogg','sound/voice/gasp_male7.ogg')
	var/female_snore_sound = list('sound/voice/snore_1.ogg', 'sound/voice/snore_2.ogg','sound/voice/snore_3.ogg', 'sound/voice/snore_4.ogg','sound/voice/snore_5.ogg', 'sound/voice/snore_6.ogg','sound/voice/snore_7.ogg')
	var/male_snore_sound = list('sound/voice/snore_1.ogg', 'sound/voice/snore_2.ogg','sound/voice/snore_3.ogg', 'sound/voice/snore_4.ogg','sound/voice/snore_5.ogg', 'sound/voice/snore_6.ogg','sound/voice/snore_7.ogg')
	var/whistle_sound = list('sound/voice/whistle.ogg')

	//Default hair/headacc style vars.
	var/default_hair				//Default hair style for newly created humans unless otherwise set.
	var/default_hair_colour
	var/default_fhair				//Default facial hair style for newly created humans unless otherwise set.
	var/default_fhair_colour
	var/default_headacc				//Default head accessory style for newly created humans unless otherwise set.
	var/default_headacc_colour
	/// Name of default body accessory if any.
	var/default_bodyacc
	//Defining lists of icon skin tones for species that have them.
	var/list/icon_skin_tones = list()

	/// Determines internal organs that the species spawns with and which required-organ checks are conducted.
	var/list/has_organ = list(
		INTERNAL_ORGAN_HEART = /obj/item/organ/internal/heart,
		INTERNAL_ORGAN_LUNGS = /obj/item/organ/internal/lungs,
		INTERNAL_ORGAN_LIVER = /obj/item/organ/internal/liver,
		INTERNAL_ORGAN_KIDNEYS = /obj/item/organ/internal/kidneys,
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain,
		INTERNAL_ORGAN_APPENDIX = /obj/item/organ/internal/appendix,
		INTERNAL_ORGAN_EYES = /obj/item/organ/internal/eyes,
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears,
	)

	var/meat_type = /obj/item/reagent_containers/food/snacks/meat/humanoid

	var/list/has_limbs = list(
		BODY_ZONE_CHEST = list("path" = /obj/item/organ/external/chest),
		BODY_ZONE_PRECISE_GROIN = list("path" = /obj/item/organ/external/groin),
		BODY_ZONE_HEAD = list("path" = /obj/item/organ/external/head),
		BODY_ZONE_L_ARM = list("path" = /obj/item/organ/external/arm),
		BODY_ZONE_R_ARM = list("path" = /obj/item/organ/external/arm/right),
		BODY_ZONE_L_LEG = list("path" = /obj/item/organ/external/leg),
		BODY_ZONE_R_LEG = list("path" = /obj/item/organ/external/leg/right),
		BODY_ZONE_PRECISE_L_HAND = list("path" = /obj/item/organ/external/hand),
		BODY_ZONE_PRECISE_R_HAND = list("path" = /obj/item/organ/external/hand/right),
		BODY_ZONE_PRECISE_L_FOOT = list("path" = /obj/item/organ/external/foot),
		BODY_ZONE_PRECISE_R_FOOT = list("path" = /obj/item/organ/external/foot/right),
	)

	// Species specific boxes
	var/speciesbox
	/// Whether the presence of a body accessory on this species is optional or not.
	var/optional_body_accessory = TRUE

	/// Flat bonus to various tool handling
	/// Value of 0.1 adds 10% time delay to all performed actions in tool's category, -0.1 vice versa
	/// READ ONLY!
	var/toolspeedmod = 0
	/// Same as above, used for surgery modifiers
	var/surgeryspeedmod = 0

	var/toxic_food = TOXIC
	var/disliked_food = GROSS
	var/liked_food = FRIED | JUNKFOOD | SUGAR
	/// Here are going material types. If material type in your diet, and item has eatable component - you will eat it.
	var/special_diet = NONE

	var/list/autohiss_basic_map = null
	var/list/autohiss_extra_map = null
	var/list/autohiss_exempt = null

/datum/species/New()
	unarmed = new unarmed_type()

/datum/species/proc/get_random_name(gender)
	var/datum/language/species_language = GLOB.all_languages[language]
	return species_language.get_random_name(gender)


/**
 * Handles creation of mob organs.
 *
 * Arguments:
 * * target - The human to create organs inside of
 * * bodyparts_to_omit - Any bodyparts in this list (and organs within them) should not be added.
 * * additional_organs - List of organ paths, used to generate additional organs.
 */
/datum/species/proc/create_organs(mob/living/carbon/human/target, list/bodyparts_to_omit, list/additional_organs)
	QDEL_LIST(target.internal_organs)
	QDEL_LIST(target.bodyparts)

	LAZYREINITLIST(target.bodyparts)
	LAZYREINITLIST(target.bodyparts_by_name)
	LAZYREINITLIST(target.internal_organs)
	LAZYREINITLIST(target.internal_organs_slot)

	for(var/limb_zone in has_limbs)
		if(limb_zone in bodyparts_to_omit)
			target.bodyparts_by_name[limb_zone] = null  // Null it out, but leave the name here so it's still "there"
			continue

		var/list/organ_data = has_limbs[limb_zone]
		var/limb_path = organ_data["path"]
		var/obj/item/organ/new_organ = new limb_path(target)
		organ_data["descriptor"] = new_organ.name

	for(var/organ_slot in has_organ)
		var/obj/item/organ/internal/organ_path = has_organ[organ_slot]
		if((initial(organ_path.parent_organ_zone) in bodyparts_to_omit) || (organ_slot in bodyparts_to_omit))
			target.internal_organs_slot[organ_slot] = null
			continue

		// heads up for any brave future coders:
		// it's essential that a species' internal organs are intialized with the mob, instead of just creating them and calling insert() separately.
		// not doing so (as of now) causes weird issues for some organs like posibrains, which need a mob on init or they'll qdel themselves.
		// for the record: this caused every single IPC's brain to be deleted randomly throughout a round, killing them instantly.

		new organ_path(target)

	for(var/obj/item/organ/internal/organ_path as anything in additional_organs)
		var/organ_slot = initial(organ_path.slot)
		if((initial(organ_path.parent_organ_zone) in bodyparts_to_omit) || (organ_slot in bodyparts_to_omit))
			target.internal_organs_slot[organ_slot] = null
			continue

		new organ_path(target)

	// and now we need to recheck our limbs conditions
	target.recalculate_limbs_status()
	// also we need to recheck for no scan trait, if the brain was changed
	target.on_no_scan()


/datum/species/proc/breathe(mob/living/carbon/human/user)
	if(HAS_TRAIT(user, TRAIT_NO_BREATH))
		return TRUE
	return FALSE


/datum/species/proc/on_species_gain(mob/living/carbon/human/H) //Handles anything not already covered by basic species assignment.
	SHOULD_CALL_PARENT(TRUE)

	if(speed_mod)
		H.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/species_speedmod, multiplicative_slowdown = speed_mod)

	if(toolspeedmod)
		H.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/species_tool_mod, multiplicative_slowdown = toolspeedmod)

	if(surgeryspeedmod)
		H.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/species_surgery_mod, multiplicative_slowdown = surgeryspeedmod)

	if(length(inherent_traits))
		H.add_traits(inherent_traits, SPECIES_TRAIT)

	if(inherent_factions)
		for(var/i in inherent_factions)
			H.faction += i //Using +=/-= for this in case you also gain the faction from a different source.

	for(var/obj/item/item as anything in H.get_equipped_items())
		if(QDELETED(item) || item.loc != H)	// was deleted or dropped already
			continue
		var/item_slot = H.get_slot_by_item(item)
		if(item_slot in no_equip)
			H.drop_item_ground(item, force = TRUE)
			continue

		if(isclothing(item) && !H.is_general_slot(item_slot))
			var/obj/item/clothing/cloth_item = item
			// faction based cloth
			if(cloth_item.faction_restricted && faction_check(cloth_item.faction_restricted, H.faction))
				H.drop_item_ground(cloth_item, force = TRUE)
				continue

			// species restricted cloth
			var/list/rectricted = cloth_item.species_restricted
			if(!rectricted)
				continue

			var/wearable = ("exclude" in rectricted) ? !(name in rectricted) : (name in rectricted)

			if(wearable && ("lesser form" in rectricted) && is_monkeybasic)
				wearable = FALSE

			if(!wearable)
				H.drop_item_ground(cloth_item, force = TRUE)

	if(!H.w_uniform)
		H.drop_item_ground(H.r_store, force = TRUE)
		H.drop_item_ground(H.l_store, force = TRUE)
		H.drop_item_ground(H.wear_id, force = TRUE)
		H.drop_item_ground(H.belt, force = TRUE)
		H.drop_item_ground(H.wear_pda, force = TRUE)

	if(!H.wear_suit)
		H.drop_item_ground(H.s_store, force = TRUE)

	H.hud_used?.update_locked_slots()


/datum/species/proc/on_species_loss(mob/living/carbon/human/H)
	SHOULD_CALL_PARENT(TRUE)

	if(speed_mod)
		H.remove_movespeed_modifier(/datum/movespeed_modifier/species_speedmod)

	if(toolspeedmod)
		H.remove_actionspeed_modifier(/datum/actionspeed_modifier/species_tool_mod)

	if(surgeryspeedmod)
		H.remove_actionspeed_modifier(/datum/actionspeed_modifier/species_surgery_mod)

	if(length(inherent_traits))
		H.remove_traits(inherent_traits, SPECIES_TRAIT)

	H.meatleft = initial(H.meatleft)

	H.hud_used?.update_locked_slots()

	if(inherent_factions)
		for(var/i in inherent_factions)
			H.faction -= i


/datum/species/proc/updatespeciescolor(mob/living/carbon/human/H) //Handles changing icobase for species that have multiple skin colors.
	return

/**
 * Do species-specific reagent handling here
 * Return 1 if it should do normal processing too
 * Return the parent value if processing does not explicitly stop
 * Return 0 if it shouldn't deplete and do its normal effect
 * Other return values will cause weird badness
 */
/datum/species/proc/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	return TRUE

// For special snowflake species effects
// (Slime People changing color based on the reagents they consume)
/datum/species/proc/handle_life(mob/living/carbon/human/H)
	var/regenerate = TRUE
	if(HAS_TRAIT(H, TRAIT_NO_BREATH) && H.health <= HEALTH_THRESHOLD_CRIT)
		regenerate = FALSE
		H.adjustBruteLoss(1)

	if(regenerate && (H.blood_volume > BLOOD_VOLUME_REGENERATION) && HAS_TRAIT(H, TRAIT_HAS_REGENERATION) && (H.getBruteLoss() || H.getFireLoss()))
		H.heal_overall_damage(0.1, 0.1)

/**
 * Handles DNA mutations, as that doesn't work at init.
 */
/datum/species/proc/handle_dna(mob/living/carbon/human/H, remove)
	return

/datum/species/proc/handle_death(gibbed, mob/living/carbon/human/H) //Handles any species-specific death events (such as dionaea nymph spawns).
	return


/datum/species/proc/spec_stun(mob/living/carbon/human/user, duration)
	. = duration
	if(!user.frozen) //admin freeze has no breaks
		. = duration * stun_mod * user.physiology.stun_mod



/datum/species/proc/spec_electrocute_act(mob/living/carbon/human/affected, shock_damage, source, siemens_coeff, flags, jitter_time, stutter_time, stun_duration)
	return


/datum/species/proc/help(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(attacker_style && attacker_style.help_act(user, target) == TRUE)//adminfu only...
		return TRUE
	if(target.health >= HEALTH_THRESHOLD_CRIT && !HAS_TRAIT(target, TRAIT_FAKEDEATH))
		target.help_shake_act(user)
		return TRUE
	else
		user.do_cpr(target)

/datum/species/proc/grab(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	var/message = "<span class='warning'>[target.declent_ru(NOMINATIVE)] блокиру[pluralize_ru(target.gender,"ет","ют")] попытку захвата [user.declent_ru(GENITIVE)]!</span>"
	if(target.check_martial_art_defense(target, user, null, message))
		return FALSE

	var/datum/antagonist/vampire/vampire = user.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(vampire?.get_ability(/datum/vampire_passive/upgraded_grab) && vampire.grab_act(user, target))
		return TRUE

	if(attacker_style && attacker_style.grab_act(user, target) == TRUE)
		return TRUE
	else
		target.grabbedby(user)
		return TRUE

/datum/species/proc/harm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(HAS_TRAIT(user, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
		to_chat(user, "<span class='warning'>[pluralize_ru(user.gender,"Ты не хочешь","Вы не хотите")] навредить [target.declent_ru(DATIVE)]!</span>")
		return FALSE

	//Vampire code
	var/datum/antagonist/vampire/vamp = user?.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(vamp && !vamp.draining && user.zone_selected == BODY_ZONE_HEAD && target != user)
		if(HAS_TRAIT(target, TRAIT_NO_BLOOD) || HAS_TRAIT(target, TRAIT_EXOTIC_BLOOD) || !target.blood_volume)
			to_chat(user, span_warning("Отсутствует кровь!"))
			return
		if(target.mind && (target.mind.has_antag_datum(/datum/antagonist/vampire) || target.mind.has_antag_datum(/datum/antagonist/mindslave/thrall)))
			to_chat(user, span_warning("[pluralize_ru(user.gender,"Твои","Ваши")] клыки не могут пронзить холодную плоть [target.declent_ru(GENITIVE)]."))
			return
		if(HAS_TRAIT(target, TRAIT_SKELETON))
			to_chat(user, span_warning("В скелете нет ни капли крови!"))
			return
		//we're good to suck the blood, blaah
		vamp.handle_bloodsucking(target)
		add_attack_logs(user, target, "vampirebit")
		return

	var/message = "<span class='warning'>[target.declent_ru(NOMINATIVE)] блокиру[pluralize_ru(target.gender,"ет","ют")] атаку [user.declent_ru(GENITIVE)]!</span>"
	if(target.check_martial_art_defense(target, user, null, message))
		return FALSE
	if(attacker_style && attacker_style.harm_act(user, target) == TRUE)
		return TRUE
	else
		var/datum/unarmed_attack/attack = user.dna.species.unarmed
		var/attack_species = pick(attack.attack_verb)

		//вносим проверку что это не диона, ведь у дионы свои атаки
		//вносим проверку на тип атаки, иначе рвущие атаки будут рвать кулаками, а дионы хлестать кулаками.
		switch (user.dna.species.unarmed_type)
			if (/datum/unarmed_attack/diona) attack_species += ""
			if (/datum/unarmed_attack/claws) attack_species += "[genderize_ru(user.gender,"","а","о","и")] когтями"
			if (/datum/unarmed_attack) attack_species += "[genderize_ru(user.gender,"","а","о","и")] кулаком"

		user.do_attack_animation(target, attack.animation_type)
		if(attack.harmless)
			playsound(target.loc, attack.attack_sound, 25, 1, -1)
			target.visible_message("<span class='danger'>[user.declent_ru(NOMINATIVE)] [attack_species] [target.declent_ru(ACCUSATIVE)]!</span>")
			return FALSE
		add_attack_logs(user, target, "Melee attacked with fists")

		if(!iscarbon(user))
			target.LAssailant = null
		else
			target.LAssailant = user

		target.lastattacker = user.real_name
		target.lastattackerckey = user.ckey

		var/damage_type = BRUTE
		var/damage = rand(user.dna.species.punchdamagelow + user.physiology.punch_damage_low, user.dna.species.punchdamagehigh + user.physiology.punch_damage_high)
		damage += attack.damage
		if(!damage)
			playsound(target.loc, attack.miss_sound, 25, 1, -1)
			target.visible_message("<span class='danger'>[user.declent_ru(NOMINATIVE)] [attack_species] [target.declent_ru(ACCUSATIVE)], но промахива[pluralize_ru(user.gender,"ется","ются")]!</span>")
			return FALSE

		var/obj/item/organ/external/affecting = target.get_organ(ran_zone(user.zone_selected))
		var/armor_block = target.run_armor_check(affecting, "melee")

		// Contract diseases

		//user beats target, check target's defense in selected zone
		for(var/datum/disease/virus/V in user.diseases)
			var/is_infected = FALSE
			if(attack.is_bite && (V.spread_flags & BITES))
				is_infected = V.Contract(target, act_type = BITES|CONTACT, need_protection_check = TRUE, zone = affecting)
			if(!is_infected && (V.spread_flags & CONTACT))
				V.Contract(target, act_type = CONTACT, need_protection_check = TRUE, zone = affecting)

		//check user's defense in attacking zone (hands or mouth)
		for(var/datum/disease/virus/V in target.diseases)
			var/is_infected = FALSE
			if(attack.is_bite  && (V.spread_flags > NON_CONTAGIOUS))
				//infected blood contacts with mouth, ignore protection & spread_flags
				is_infected = V.Contract(user, need_protection_check = FALSE)
			if(!is_infected && (V.spread_flags & CONTACT))
				V.Contract(user, act_type = CONTACT, need_protection_check = TRUE, zone = user.hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)

		playsound(target.loc, attack.attack_sound, 25, 1, -1)

		target.visible_message("<span class='danger'>[user.declent_ru(NOMINATIVE)] [attack_species] [target.declent_ru(ACCUSATIVE)]!</span>")

		var/all_objectives = user?.mind?.get_all_objectives()
		if(target.mind && all_objectives)
			for(var/datum/objective/pain_hunter/objective in all_objectives)
				if(target.mind == objective.target)
					objective.take_damage(damage, damage_type)

		target.apply_damage(damage, damage_type, affecting, armor_block, sharp = attack.sharp) //moving this back here means Armalis are going to knock you down  70% of the time, but they're pure adminbus anyway.
		if((target.stat != DEAD) && damage >= (user.dna.species.punchstunthreshold + user.physiology.punch_stun_threshold))
			target.visible_message("<span class='danger'>[user.declent_ru(NOMINATIVE)] ослабля[pluralize_ru(user.gender,"ет","ют")] [target.declent_ru(ACCUSATIVE)]!</span>", \
							"<span class='userdanger'>[user.declent_ru(NOMINATIVE)] ослабля[pluralize_ru(user.gender,"ет","ют")] [target.declent_ru(ACCUSATIVE)]!</span>")
			target.apply_effect(4 SECONDS, WEAKEN, armor_block)
			target.forcesay(GLOB.hit_appends)
		else if(target.body_position == LYING_DOWN)
			target.forcesay(GLOB.hit_appends)


/datum/species/proc/disarm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(user == target)
		return FALSE
	var/message = "<span class='warning'>[target.declent_ru(NOMINATIVE)] блокиру[pluralize_ru(target.gender,"ет","ют")] попытку обезоруживания [user.declent_ru(GENITIVE)]!</span>"
	if(target.check_martial_art_defense(target, user, null, message))
		return FALSE
	if(attacker_style && attacker_style.disarm_act(user, target) == TRUE)
		return TRUE
	else
		add_attack_logs(user, target, "Disarmed", ATKLOG_ALL)
		user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
		if(target.w_uniform)
			target.w_uniform.add_fingerprint(user)
		var/obj/item/organ/external/affecting = target.get_organ(ran_zone(user.zone_selected))
		var/randn = rand(1, 100)
		var/extra_knock_chance = 0
		if(user.gloves)
			if(istype(user.gloves, /obj/item/clothing/gloves))
				var/obj/item/clothing/gloves/gloves = user.gloves
				extra_knock_chance = gloves.extra_knock_chance
		if(randn <= 10 + extra_knock_chance)
			target.apply_effect(4 SECONDS, KNOCKDOWN, target.run_armor_check(affecting, "melee"))
			playsound(target.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			target.visible_message("<span class='danger'>[user.declent_ru(NOMINATIVE)] толка[pluralize_ru(user.gender,"ет","ют")] [target.declent_ru(ACCUSATIVE)]!</span>")
			add_attack_logs(user, target, "Pushed over", ATKLOG_ALL)
			if(!iscarbon(user))
				target.LAssailant = null
			else
				target.LAssailant = user
			return

		user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
		if(target.move_resist > user.pull_force)
			return FALSE
		if(!(target.status_flags & CANPUSH))
			return FALSE
		if(target.anchored)
			return FALSE
		if(target.buckled)
			target.buckled.unbuckle_mob(target)

	var/shove_dir = get_dir(user.loc, target.loc)
	var/turf/shove_to = get_step(target.loc, shove_dir)
	playsound(shove_to, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

	if(shove_to == user.loc)
		return FALSE

	//Directional checks to make sure that we're not shoving through a windoor or something like that
	var/directional_blocked = FALSE
	var/target_turf = get_turf(target)
	if(shove_dir in list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)) // if we are moving diagonially, we need to check if there are dense walls either side of us
		var/turf/T = get_step(target.loc, turn(shove_dir, 45)) // check to the left for a dense turf
		if(T.density)
			directional_blocked = TRUE
		else
			T = get_step(target.loc, turn(shove_dir, -45)) // check to the right for a dense turf
			if(T.density)
				directional_blocked = TRUE

	if(!directional_blocked)
		for(var/obj/obj_content in target_turf) // check the tile we are on for border
			if(obj_content.flags & ON_BORDER && obj_content.dir & shove_dir && obj_content.density)
				directional_blocked = TRUE
				break
	if(!directional_blocked)
		for(var/obj/obj_content in shove_to) // check tile we are moving to for borders
			if(obj_content.flags & ON_BORDER && obj_content.dir & turn(shove_dir, 180) && obj_content.density)
				directional_blocked = TRUE
				break

	if(!directional_blocked)
		for(var/atom/movable/AM in shove_to)
			if(AM.shove_impact(target, user)) // check for special interactions EG. tabling someone
				return TRUE

	var/moved = target.Move(shove_to, shove_dir)
	if(!moved) //they got pushed into a dense object
		add_attack_logs(user, target, "Disarmed into a dense object", ATKLOG_ALL)
		target.visible_message(span_warning("[user] slams [target]"), \
								span_userdanger("You get slammed into the obstacle by [user]!"), \
								"You hear a loud thud.")
		if(!HAS_TRAIT(target, TRAIT_FLOORED))
			target.Knockdown(3 SECONDS)
			addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living/carbon, SetKnockdown), 0), 3 SECONDS) // so you cannot chain stun someone
		else if(!user.IsStunned())
			target.Stun(0.5 SECONDS)
	else
		var/obj/item/I = target.get_active_hand()
		if(I && prob(60))
			target.drop_from_active_hand()
			add_attack_logs(user, target, "Disarmed object out of hand", ATKLOG_ALL)
		else
			if(I)
				to_chat(target, span_warning("Your grip on [I] loosens!"))
			add_attack_logs(user, target, "Disarmed, shoved back", ATKLOG_ALL)
	target.stop_pulling()

/datum/species/proc/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style) //Handles any species-specific attackhand events.
	if(!istype(M))
		return

	if(istype(M))
		var/obj/item/organ/external/temp = M.bodyparts_by_name[BODY_ZONE_PRECISE_R_HAND]
		if(M.hand)
			temp = M.bodyparts_by_name[BODY_ZONE_PRECISE_L_HAND]
		if(!temp || !temp.is_usable())
			to_chat(M, "<span class='warning'>[pluralize_ru(M.gender,"Ты не можешь","Вы не можете")] пользоваться своей рукой.</span>")
			return

	if(M.mind)
		attacker_style = M.mind.martial_art

	if((M != H) && M.a_intent != INTENT_HELP && H.check_shields(M, 0, M.name, attack_type = UNARMED_ATTACK))
		add_attack_logs(M, H, "Melee attacked with fists (miss/block)")
		H.visible_message("<span class='warning'>[M.declent_ru(NOMINATIVE)] пыта[pluralize_ru(M.gender,"ется","ются")] коснуться [H.declent_ru(ACCUSATIVE)]!</span>")
		return FALSE

	switch(M.a_intent)
		if(INTENT_HELP)
			help(M, H, attacker_style)

		if(INTENT_GRAB)
			grab(M, H, attacker_style)

		if(INTENT_HARM)
			harm(M, H, attacker_style)

		if(INTENT_DISARM)
			disarm(M, H, attacker_style)

/datum/species/proc/say_filter(mob/M, message, datum/language/speaking)
	return message

/datum/species/proc/before_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE)
	return

/datum/species/proc/after_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE)
	return

/datum/species/proc/can_understand(mob/other)
	return

// Called in life() when the mob has no client.
/datum/species/proc/handle_npc(mob/living/carbon/human/H)
	return

//Species unarmed attacks

/datum/unarmed_attack
	var/attack_verb = list("ударил", "вмазал", "стукнул", "вдарил", "влепил")	// Empty hand hurt intent verb.
	var/damage = 0						// How much flat bonus damage an attack will do. This is a *bonus* guaranteed damage amount on top of the random damage attacks do.
	var/attack_sound = "punch"
	var/miss_sound = 'sound/weapons/punchmiss.ogg'
	var/sharp = FALSE
	var/animation_type = ATTACK_EFFECT_PUNCH
	var/harmless = FALSE //if set to true, attacks won't be admin logged and punches will "hit" for no damage
	var/is_bite = FALSE

/datum/unarmed_attack/diona
	attack_verb = list("охлестал", "тяжело стукнул", "лозой хлестанул", "ветвью щелкнул")

/datum/unarmed_attack/claws
	attack_verb = list("царапнул", "разорвал", "искромсал", "надорвал", "порвал", "полоснул") //, "полоснул когтями", "искромсал когтями", "царапнул когтями", "разорвал когтями", "надорвал когтями", "порвал когтями"
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	sharp = TRUE
	animation_type = ATTACK_EFFECT_CLAW

/datum/unarmed_attack/bite
	attack_verb = list("грызет", "кусает", "вгрызается", "трепает")
	attack_sound = 'sound/weapons/bite.ogg'
	sharp = TRUE
	animation_type = ATTACK_EFFECT_BITE
	is_bite = TRUE

/datum/unarmed_attack/claws/armalis
	attack_verb = list("хлестает", "хлестанул", "искромсал", "разорвал") //армалисами почти никто не пользуется. Зачем вносить пол вырезаной расе которой никогда не будет в игре?
	damage = 6


/datum/species/proc/can_equip(obj/item/I, slot, mob/living/carbon/human/user, disable_warning = FALSE, bypass_equip_delay_self = FALSE, bypass_obscured = FALSE, bypass_incapacitated = FALSE)
	if(slot in no_equip)
		return FALSE

	if(!user.has_organ_for_slot(slot))
		return FALSE

	if(!bypass_obscured && (slot & user.check_obscured_slots()))
		if(!disable_warning)
			to_chat(user, span_warning("Вы не можете надеть [I.name], слот закрыт другой одеждой."))
		return FALSE

	// this check prevents us from equipping something to a slot it doesn't support,
	// WITH the exceptions of hands and storage slots (pockets, suit storage, and backpack)
	// we don't require having those slots defined in the item's slot_flags,
	// so we'll rely on their own checks further down
	if(!(I.slot_flags & slot))
		var/excused = FALSE
		if((slot & ITEM_SLOT_POCKETS) && !(I.slot_flags_2 & ITEM_FLAG_POCKET_DENY) && (I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags_2 & ITEM_FLAG_POCKET_LARGE)))
			excused = TRUE
		else if(slot & (ITEM_SLOT_HANDS|ITEM_SLOT_SUITSTORE|ITEM_SLOT_BACKPACK))
			excused = TRUE
		if(!excused)
			return FALSE

	if(isclothing(I) && !user.is_general_slot(slot))
		var/obj/item/clothing/cloth = I
		var/list/rectricted = cloth.species_restricted

		if(rectricted)
			var/wearable = ("exclude" in rectricted) ? !(name in rectricted) : (name in rectricted)

			if(wearable && is_monkeybasic && ("lesser form" in rectricted))
				wearable = FALSE

			if(!wearable)
				if(!disable_warning)
					to_chat(user, span_warning("Вы [name] и не можете использовать [I.name]."))
				return FALSE

	switch(slot)
		// HANDS
		if(ITEM_SLOT_HAND_LEFT)
			if(user.l_hand)
				return FALSE
			if(!bypass_incapacitated && user.incapacitated())
				return FALSE
			return TRUE

		if(ITEM_SLOT_HAND_RIGHT)
			if(user.r_hand)
				return FALSE
			if(!bypass_incapacitated && user.incapacitated())
				return FALSE
			return TRUE

		// MASK SLOT
		if(ITEM_SLOT_MASK)
			if(user.wear_mask)
				return FALSE
			return bypass_equip_delay_self || I.equip_delay_self <= 0 || equip_delay_self_check(I, slot, user)

		// BACK SLOT
		if(ITEM_SLOT_BACK)
			if(user.back)
				return FALSE
			return bypass_equip_delay_self || I.equip_delay_self <= 0 || equip_delay_self_check(I, slot, user)

		// SUIT SLOT
		if(ITEM_SLOT_CLOTH_OUTER)
			if(user.wear_suit)
				return FALSE
			return bypass_equip_delay_self || I.equip_delay_self <= 0 || equip_delay_self_check(I, slot, user)

		// GLOVES SLOT
		if(ITEM_SLOT_GLOVES)
			if(user.gloves)
				return FALSE
			return bypass_equip_delay_self || I.equip_delay_self <= 0 || equip_delay_self_check(I, slot, user)

		// SHOES SLOT
		if(ITEM_SLOT_FEET)
			if(user.shoes)
				return FALSE
			return bypass_equip_delay_self || I.equip_delay_self <= 0 || equip_delay_self_check(I, slot, user)

		// NECK SLOT
		if(ITEM_SLOT_NECK)
			if(user.neck)
				return FALSE
			return bypass_equip_delay_self || I.equip_delay_self <= 0 || equip_delay_self_check(I, slot, user)

		// BELT SLOT
		if(ITEM_SLOT_BELT)
			if(user.belt)
				return FALSE

			var/obj/item/organ/external/chest = user.get_organ(BODY_ZONE_CHEST)
			if(!user.w_uniform && !nojumpsuit && (!chest || !chest.is_robotic()))
				if(!disable_warning)
					to_chat(user, span_warning("Вам нужен комбинезон перед тем как вы сможете прикрепить [I.name]."))
				return FALSE

			return bypass_equip_delay_self || I.equip_delay_self <= 0 || equip_delay_self_check(I, slot, user)

		// GLASSES SLOT
		if(ITEM_SLOT_EYES)
			if(user.glasses)
				return FALSE
			return bypass_equip_delay_self || I.equip_delay_self <= 0 || equip_delay_self_check(I, slot, user)

		// HEAD SLOT
		if(ITEM_SLOT_HEAD)
			if(user.head)
				return FALSE
			return bypass_equip_delay_self || I.equip_delay_self <= 0 || equip_delay_self_check(I, slot, user)

		// EARS SLOTS
		if(ITEM_SLOT_EAR_LEFT)
			if(user.l_ear)
				return FALSE
			if((I.slot_flags_2 & ITEM_FLAG_TWOEARS) && user.r_ear)
				return FALSE
			return bypass_equip_delay_self || I.equip_delay_self <= 0 || equip_delay_self_check(I, slot, user)

		if(ITEM_SLOT_EAR_RIGHT)
			if(user.r_ear)
				return FALSE
			if((I.slot_flags_2 & ITEM_FLAG_TWOEARS) && user.l_ear)
				return FALSE
			return bypass_equip_delay_self || I.equip_delay_self <= 0 || equip_delay_self_check(I, slot, user)

		// UNIFORM SLOT
		if(ITEM_SLOT_CLOTH_INNER)
			if(user.w_uniform)
				return FALSE
			return bypass_equip_delay_self || I.equip_delay_self <= 0 || equip_delay_self_check(I, slot, user)

		// ID CARD SLOT
		if(ITEM_SLOT_ID)
			if(user.wear_id)
				return FALSE

			var/obj/item/organ/external/chest = user.get_organ(BODY_ZONE_CHEST)
			if(!user.w_uniform && !nojumpsuit && (!chest || !chest.is_robotic()))
				if(!disable_warning)
					to_chat(user, span_warning("Вам нужен комбинезон перед тем как вы сможете прикрепить [I.name]."))
				return FALSE

			return bypass_equip_delay_self || I.equip_delay_self <= 0 || equip_delay_self_check(I, slot, user)

		// PDA SLOT
		if(ITEM_SLOT_PDA)
			if(user.wear_pda)
				return FALSE

			var/obj/item/organ/external/chest = user.get_organ(BODY_ZONE_CHEST)
			if(!user.w_uniform && !nojumpsuit && (!chest || !chest.is_robotic()))
				if(!disable_warning)
					to_chat(user, span_warning("Вам нужен комбинезон перед тем как вы сможете прикрепить [I.name]."))
				return FALSE

			return bypass_equip_delay_self || I.equip_delay_self <= 0 || equip_delay_self_check(I, slot, user)

		// POCKETS
		if(ITEM_SLOT_POCKET_LEFT)
			if(user.l_store)
				return FALSE

			var/obj/item/organ/external/limb = user.get_organ(BODY_ZONE_L_LEG)
			if(!user.w_uniform && !nojumpsuit && (!limb || !limb.is_robotic()))
				if(!disable_warning)
					to_chat(user, span_warning("Вам нужен комбинезон перед тем как вы сможете прикрепить [I.name]."))
				return FALSE

			return TRUE

		if(ITEM_SLOT_POCKET_RIGHT)
			if(user.r_store)
				return FALSE

			var/obj/item/organ/external/limb = user.get_organ(BODY_ZONE_R_LEG)
			if(!user.w_uniform && !nojumpsuit && (!limb || !limb.is_robotic()))
				if(!disable_warning)
					to_chat(user, span_warning("Вам нужен комбинезон перед тем как вы сможете прикрепить [I.name]."))
				return FALSE

			return TRUE

		// SUIT STORE SLOT
		if(ITEM_SLOT_SUITSTORE)
			if(user.s_store)
				return FALSE
			if(!user.wear_suit)
				if(!disable_warning)
					to_chat(user, span_warning("Вам нужен костюм перед тем как вы сможете прикрепить [I.name]."))
				return FALSE
			if(!user.wear_suit.can_store_weighted(I))
				if(!disable_warning)
					to_chat(user, span_warning("Размер [I] слишком большой, чтобы прикрепить."))
				return FALSE

			if(is_pda(I) || is_pen(I) || is_type_in_list(I, user.wear_suit.allowed))
				return TRUE

			if(!user.wear_suit.allowed)
				if(!disable_warning)
					user << 'sound/machines/chime.ogg'
					to_chat(user, span_danger("Откуда у Вас этот костюм? Срочно сообщите о находке в высшие инстанции!"))
				return FALSE

			return FALSE

		// HANDCUFFS SLOT
		if(ITEM_SLOT_HANDCUFFED)
			return !user.handcuffed

		// LEGCUFFS SLOT
		if(ITEM_SLOT_LEGCUFFED)
			return !user.legcuffed

		// PLACING ITEM IN BACKPACK
		if(ITEM_SLOT_BACKPACK)
			if(user.back && istype(user.back, /obj/item/storage/backpack))
				var/obj/item/storage/backpack/backpack = user.back
				if(length(backpack.contents) < backpack.storage_slots && I.w_class <= backpack.max_w_class)
					return TRUE
			return FALSE

		// UNIFORM ACCESORIES
		if(ITEM_SLOT_ACCESSORY)
			if(!user.w_uniform)
				if(!disable_warning)
					to_chat(user, span_warning("Вам нужен комбинезон перед тем как вы сможете прикрепить [I.name]."))
				return FALSE

			var/obj/item/clothing/under/uniform = user.w_uniform
			if(!uniform.can_attach_accessory(I))
				if(!disable_warning)
					to_chat(user, span_warning("У вас уже есть аксессуар этого типа на [uniform.name]."))
				return FALSE

			return TRUE

	return FALSE //Unsupported slot


/**
 * Proc that provide delayed item equip. Returns `TRUE` on success.
 */
/datum/species/proc/equip_delay_self_check(obj/item/I, slot, mob/living/carbon/human/user)
	user.visible_message(span_notice("[user] начинает надевать [I.name]..."), span_notice("Вы начинаете надевать [I.name]..."))
	return do_after(user, I.equip_delay_self, user)


/datum/species/proc/update_health_hud(mob/living/carbon/human/H)
	return FALSE

/*
Returns the path corresponding to the corresponding organ
It'll return null if the organ doesn't correspond, so include null checks when using this!
*/
//Fethas Todo:Do i need to redo this?
/datum/species/proc/return_organ(organ_slot)
	if(!(organ_slot in has_organ))
		return null
	return has_organ[organ_slot]

/datum/species/proc/update_sight(mob/living/carbon/human/H)
	H.set_sight(initial(H.sight))

	var/obj/item/organ/internal/eyes/eyes = H.get_int_organ(/obj/item/organ/internal/eyes)
	if(eyes)
		H.add_sight(eyes.vision_flags)
		H.nightvision = eyes.see_in_dark
		H.set_invis_see(eyes.see_invisible)
		H.lighting_alpha = eyes.lighting_alpha
	else
		H.nightvision = initial(H.nightvision)
		H.set_invis_see(initial(H.see_invisible))
		H.lighting_alpha = initial(H.lighting_alpha)

	if(H.client && H.client.eye != H)
		var/atom/A = H.client.eye
		if(A && A.update_remote_sight(H)) //returns 1 if we override all other sight updates.
			return

	var/datum/antagonist/vampire/vamp = H.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(vamp)
		if(vamp.get_ability(/datum/vampire_passive/xray))
			H.add_sight(SEE_TURFS|SEE_MOBS|SEE_OBJS)
			H.nightvision += 8
			H.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		else if(vamp.get_ability(/datum/vampire_passive/full))
			H.add_sight(SEE_MOBS)
			H.nightvision += 8
			H.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		else if(vamp.get_ability(/datum/vampire_passive/vision))
			H.add_sight(SEE_MOBS)
			H.nightvision += 1 // base of 2, 2+1 is 3
			H.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE


	for(var/obj/item/organ/internal/cyberimp/eyes/cyber_eyes in H.internal_organs)
		H.add_sight(cyber_eyes.vision_flags)
		if(cyber_eyes.see_in_dark)
			H.nightvision = max(H.nightvision, cyber_eyes.see_in_dark)
		if(cyber_eyes.see_invisible)
			H.set_invis_see(min(H.see_invisible, cyber_eyes.see_invisible))
		if(cyber_eyes.lighting_alpha)
			H.lighting_alpha = min(H.lighting_alpha, cyber_eyes.lighting_alpha)

	// my glasses, I can't see without my glasses
	if(H.glasses)
		var/obj/item/clothing/glasses/G = H.glasses
		H.add_sight(G.vision_flags)
		H.nightvision = max(G.see_in_dark, H.nightvision)

		if(G.invis_override)
			H.set_invis_see(G.invis_override)
		else
			H.set_invis_see(min(G.invis_view, H.see_invisible))

		if(!isnull(G.lighting_alpha))
			H.lighting_alpha = min(G.lighting_alpha, H.lighting_alpha)

	// better living through hat trading
	if(H.head)
		if(istype(H.head, /obj/item/clothing/head))
			var/obj/item/clothing/head/hat = H.head
			H.add_sight(hat.vision_flags)
			H.nightvision = max(hat.see_in_dark, H.nightvision)

			if(!isnull(hat.lighting_alpha))
				H.lighting_alpha = min(hat.lighting_alpha, H.lighting_alpha)

	if(H.vision_type)
		H.add_sight(H.vision_type.sight_flags)
		H.nightvision = max(H.nightvision, H.vision_type.see_in_dark)

		if(!isnull(H.vision_type.lighting_alpha))
			H.lighting_alpha = min(H.vision_type.lighting_alpha, H.lighting_alpha)

		if(H.vision_type.light_sensitive)
			H.weakeyes = TRUE

	if(HAS_TRAIT(H, TRAIT_XRAY))
		H.add_sight((SEE_TURFS|SEE_MOBS|SEE_OBJS))

	if(H.has_status_effect(STATUS_EFFECT_SUMMONEDGHOST))
		H.set_invis_see(SEE_INVISIBLE_OBSERVER)

	H.sync_lighting_plane_alpha()

/datum/species/proc/water_act(mob/living/carbon/human/M, volume, temperature, source, method = REAGENT_TOUCH)
	if(abs(temperature - M.bodytemperature) > 10) // If our water and mob temperature varies by more than 10K, cool or/ heat them appropriately.
		M.adjust_bodytemperature((temperature - M.bodytemperature) * 0.5)	// Approximation for gradual heating or cooling.

/datum/species/proc/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H) //return TRUE if hit, FALSE if stopped/reflected/etc
	return TRUE

/datum/species/proc/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	return


/datum/species/proc/spec_proceed_attack_results(obj/item/I, mob/living/carbon/human/defender, mob/living/attacker, obj/item/organ/external/affecting)
	return ATTACK_CHAIN_PROCEED


/proc/get_random_species(species_name = FALSE)	// Returns a random non black-listed or hazardous species, either as a string or datum
	var/static/list/random_species = list()
	if(!random_species.len)
		for(var/thing  in subtypesof(/datum/species))
			var/datum/species/S = thing
			if(!initial(S.dangerous_existence) && !initial(S.blacklisted))
				random_species += initial(S.name)
	var/picked_species = pick(random_species)
	var/datum/species/selected_species = GLOB.all_species[picked_species]
	return species_name ? picked_species : selected_species.type


/datum/species/proc/can_hear(mob/living/carbon/human/user)
	var/obj/item/organ/internal/ears/ears = user.get_organ_slot(INTERNAL_ORGAN_EARS)
	return ears && !HAS_TRAIT(user, TRAIT_DEAF)


/datum/species/proc/has_vision(mob/living/carbon/human/user, information_only = FALSE)
	if(information_only && user.stat == DEAD)
		return TRUE
	if(user.AmountBlinded() || HAS_TRAIT(user, TRAIT_BLIND) || user.stat)
		return FALSE
	var/obj/item/organ/vision = get_vision_organ(user)
	return vision && (vision == NO_VISION_ORGAN || !vision.is_traumatized())


/datum/species/proc/get_vision_organ(mob/living/carbon/human/user)
	return user.get_organ_slot(INTERNAL_ORGAN_EYES)


/datum/species/proc/spec_Process_Spacemove(mob/living/carbon/human/user, movement_dir, continuous_move = FALSE)
	return FALSE


/datum/species/proc/spec_thunk(mob/living/carbon/human/H)
	return FALSE


/**
  * Species-specific runechat colour handler
  *
  * Checks the species datum flags and returns the appropriate colour
  * Can be overridden on subtypes to short-circuit these checks (Example: Grey colour is eye colour)
  * Arguments:
  * * H - The human who this DNA belongs to
  */
/datum/species/proc/get_species_runechat_color(mob/living/carbon/human/H)
	if(bodyflags & HAS_SKIN_COLOR)
		return H.skin_colour
	else
		var/obj/item/organ/external/head/HD = H.get_organ(BODY_ZONE_HEAD)
		return HD.hair_colour

