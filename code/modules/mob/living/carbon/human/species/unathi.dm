/datum/species/unathi
	name = SPECIES_UNATHI
	name_plural = "Unathi"
	icobase = 'icons/mob/human_races/r_lizard.dmi'
	deform = 'icons/mob/human_races/r_def_lizard.dmi'
	language = LANGUAGE_UNATHI
	tail = "sogtail"
	speech_sounds = list('sound/voice/unathitalk.mp3', 'sound/voice/unathitalk2.mp3', 'sound/voice/unathitalk4.mp3')
	speech_chance = 33
	skinned_type = /obj/item/stack/sheet/animalhide/lizard
	unarmed_type = /datum/unarmed_attack/claws
	primitive_form = /datum/species/monkey/unathi

	brute_mod = 0.9
	heatmod = 0.8
	coldmod = 1.2
	hunger_drain_mod = 1.6

	blurb = "A heavily reptillian species, Unathi (or 'Sinta as they call themselves) hail from the \
	Uuosa-Eso system, which roughly translates to 'burning mother'.<br/><br/>Coming from a harsh, radioactive \
	desert planet, they mostly hold ideals of honesty, virtue, martial combat and bravery above all \
	else, frequently even their own lives. They prefer warmer temperatures than most species and \
	their native tongue is a heavy hissing laungage called Sinta'Unathi."

	inherent_traits = list(
		TRAIT_HAS_LIPS,
		TRAIT_PIERCEIMMUNE,
	)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_TAIL | HAS_HEAD_ACCESSORY | HAS_BODY_MARKINGS | HAS_HEAD_MARKINGS | HAS_SKIN_COLOR | HAS_ALT_HEADS | TAIL_WAGGING | TAIL_OVERLAPPED
	taste_sensitivity = TASTE_SENSITIVITY_SHARP

	cold_level_1 = 280 //Default 260 - Lower is better
	cold_level_2 = 220 //Default 200
	cold_level_3 = 140 //Default 120

	heat_level_1 = 380 //Default 360 - Higher is better
	heat_level_2 = 420 //Default 400
	heat_level_3 = 480 //Default 460

	blood_species = "Unathi"
	flesh_color = "#34AF10"
	reagent_tag = PROCESS_ORG
	base_color = "#066000"
	//Default styles for created mobs.
	default_headacc = "Simple"
	default_headacc_colour = "#404040"
	butt_sprite = "unathi"
	male_scream_sound = list("u_mscream")
	female_scream_sound = list("u_fscream")
	male_sneeze_sound = list('sound/voice/unathi/m_u_sneeze.ogg')
	female_sneeze_sound = list('sound/voice/unathi/f_u_sneeze.ogg')

	has_organ = list(
		INTERNAL_ORGAN_HEART = /obj/item/organ/internal/heart/unathi,
		INTERNAL_ORGAN_LUNGS = /obj/item/organ/internal/lungs/unathi,
		INTERNAL_ORGAN_LIVER = /obj/item/organ/internal/liver/unathi,
		INTERNAL_ORGAN_KIDNEYS = /obj/item/organ/internal/kidneys/unathi,
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain/unathi,
		INTERNAL_ORGAN_APPENDIX = /obj/item/organ/internal/appendix,
		INTERNAL_ORGAN_EYES = /obj/item/organ/internal/eyes/unathi,	// 3 darksight.
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears,
	)

	meat_type = /obj/item/reagent_containers/food/snacks/meat/humanoid/unathi

	has_limbs = list(
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
		BODY_ZONE_TAIL = list("path" = /obj/item/organ/external/tail/unathi),
	)

	allowed_consumed_mobs = list(/mob/living/simple_animal/mouse, /mob/living/simple_animal/lizard, /mob/living/simple_animal/chick, /mob/living/simple_animal/chicken,
								 /mob/living/simple_animal/crab, /mob/living/simple_animal/butterfly, /mob/living/simple_animal/parrot, /mob/living/simple_animal/tribble)

	suicide_messages = list(
		"пытается откусить себе язык!",
		"вонзает когти себе в глазницы!",
		"сворачивает себе шею!",
		"задерживает дыхание!")

	toxic_food = SUGAR | GRAIN | JUNKFOOD
	disliked_food = FRIED
	liked_food = MEAT | RAW | EGG | GROSS | FRUIT | VEGETABLES


/datum/species/unathi/handle_death(gibbed, mob/living/carbon/human/H)
	H.stop_tail_wagging()


/datum/species/unathi/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	add_verb(H, list(
		/mob/living/carbon/human/proc/emote_wag,
		/mob/living/carbon/human/proc/emote_swag,
		/mob/living/carbon/human/proc/emote_hiss_unathi,
		/mob/living/carbon/human/proc/emote_roar,
		/mob/living/carbon/human/proc/emote_threat,
		/mob/living/carbon/human/proc/emote_whip,
		/mob/living/carbon/human/proc/emote_whip_l,
		/mob/living/carbon/human/proc/emote_rumble))
	var/datum/action/innate/tail_cut/lash = locate() in H.actions
	if(!lash)
		lash = new
		lash.Grant(H)


/datum/species/unathi/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	remove_verb(H, list(
		/mob/living/carbon/human/proc/emote_wag,
		/mob/living/carbon/human/proc/emote_swag,
		/mob/living/carbon/human/proc/emote_hiss_unathi,
		/mob/living/carbon/human/proc/emote_roar,
		/mob/living/carbon/human/proc/emote_threat,
		/mob/living/carbon/human/proc/emote_whip,
		/mob/living/carbon/human/proc/emote_whip_l,
		/mob/living/carbon/human/proc/emote_rumble))
	var/datum/action/innate/tail_cut/lash = locate() in H.actions
	lash?.Remove(H)


/datum/species/unathi/handle_life(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return
	..()
	if(H.reagents.get_reagent_amount("zessulblood") < 5)	//unique unathi chemical, heals over time and increases shock reduction for 20
		H.reagents.add_reagent("zessulblood", 1)
	switch(H.bodytemperature)
		if(200 to 260)
			H.EyeBlurry(6 SECONDS)
			if(prob(5))
				to_chat(H, span_danger("Здесь холодно, голова раскалывается..."))
		if(0 to 200)
			H.AdjustDrowsy(6 SECONDS)
			//"anabiosis. unathi falls asleep if body temp is too low" (с) captainnelly
			//sorry Nelly, no anabiosis for ya without proper temperature regulation system
			if(prob(5) && H.bodytemperature <= 170)
				H.AdjustSleeping(4 SECONDS)
				to_chat(H, span_danger("Слишком холодно, я засыпаю..."))


/datum/species/unathi/ashwalker
	name = SPECIES_ASHWALKER_BASIC
	name_plural = "Ash Walkers"
	inherent_factions = list("ashwalker")

	blurb = "Пеплоходцы — рептильные гуманоиды, по-видимому, родственные унати. Но кажутся значительно менее развитыми. \
	Они бродят по пустошам Лаваленда, поклоняются мёртвому городу и ловят ничего не подозревающих шахтёров."

	language = LANGUAGE_UNATHI
	default_language = LANGUAGE_UNATHI

	speed_mod = -0.80

	inherent_traits = list(
		TRAIT_HAS_LIPS,
		TRAIT_NO_GUNS,
		TRAIT_PIERCEIMMUNE,
		TRAIT_HEALS_FROM_ASH_TENDRIL,
	)

	has_organ = list(
		INTERNAL_ORGAN_HEART = /obj/item/organ/internal/heart/unathi,
		INTERNAL_ORGAN_LUNGS = /obj/item/organ/internal/lungs/unathi/ash_walker,
		INTERNAL_ORGAN_LIVER = /obj/item/organ/internal/liver/unathi,
		INTERNAL_ORGAN_KIDNEYS = /obj/item/organ/internal/kidneys/unathi,
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain/unathi,
		INTERNAL_ORGAN_APPENDIX = /obj/item/organ/internal/appendix,
		INTERNAL_ORGAN_EYES = /obj/item/organ/internal/eyes/unathi/ash_walker,
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears,
	)

/datum/species/unathi/ashwalker/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	var/datum/action/innate/ignite_unathi/fire = locate() in H.actions
	if(!fire)
		fire = new
		fire.Grant(H)
	RegisterSignal(H, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(speedylegs), override = TRUE)
	speedylegs(H)


/datum/species/unathi/ashwalker/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	var/datum/action/innate/ignite_unathi/fire = locate() in H.actions
	fire?.Remove(H)
	UnregisterSignal(H, COMSIG_MOVABLE_Z_CHANGED)


/datum/species/unathi/ashwalker/proc/speedylegs(mob/living/carbon/human/H)
	SIGNAL_HANDLER

	if(is_mining_level(H.z))
		H.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/species_speedmod, multiplicative_slowdown = speed_mod)
	else
		H.remove_movespeed_modifier(/datum/movespeed_modifier/species_speedmod)


//Ash walker shaman, worse defensive stats, but better at surgery and have a healing touch ability
/datum/species/unathi/ashwalker/shaman
	name = SPECIES_ASHWALKER_SHAMAN
	inherent_traits = list(
		TRAIT_HAS_LIPS,
		TRAIT_NO_GUNS,
		TRAIT_VIRUSIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_HEALS_FROM_ASH_TENDRIL,
	)
	brute_mod = 1.15
	burn_mod = 1.15
	speed_mod = -0.60 //less fast as ash walkers
	punchdamagelow = 4
	punchdamagehigh = 7
	punchstunthreshold = 7 //still can stun people pretty often
	toolspeedmod = -0.1 //they're smart and efficient unlike other lizards
	surgeryspeedmod = -0.1	//shaman is slightly better at surgeries

	has_organ = list(
		INTERNAL_ORGAN_HEART = /obj/item/organ/internal/heart/unathi,
		INTERNAL_ORGAN_LUNGS = /obj/item/organ/internal/lungs/unathi/ash_walker,
		INTERNAL_ORGAN_LIVER = /obj/item/organ/internal/liver/unathi,
		INTERNAL_ORGAN_KIDNEYS = /obj/item/organ/internal/kidneys/unathi,
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain/unathi,
		INTERNAL_ORGAN_APPENDIX = /obj/item/organ/internal/appendix,
		INTERNAL_ORGAN_EYES = /obj/item/organ/internal/eyes/unathi/ash_walker_shaman,
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears,
	)

/datum/species/unathi/ashwalker/shaman/on_species_gain(mob/living/carbon/human/owner)
	. = ..()
	var/obj/effect/proc_holder/spell/touch/healtouch/healtouch = locate() in owner.mob_spell_list
	if(!healtouch)
		owner.AddSpell(new /obj/effect/proc_holder/spell/touch/healtouch)
	var/datum/action/innate/anvil_finder/finder = locate() in owner.actions
	if(!finder)
		finder = new
		finder.Grant(owner)
	var/datum/action/innate/ignite_unathi/fire = locate() in owner.actions
	if(!fire)
		fire = new
		fire.Grant(owner)


/datum/species/unathi/ashwalker/shaman/on_species_loss(mob/living/carbon/human/owner)
	. = ..()
	owner.RemoveSpell(/obj/effect/proc_holder/spell/touch/healtouch)
	var/datum/action/innate/anvil_finder/finder = locate() in owner.actions
	if(finder)
		finder.Remove(owner)
	var/datum/action/innate/ignite_unathi/fire = locate() in owner.actions
	if(fire)
		fire.Remove(owner)


/*
draconids
These guys only come from the dragon's blood bottle from lavaland.
They're basically just lizards with all-around marginally better stats and fire resistance.
*/
/datum/species/unathi/draconid
	name = SPECIES_DRACONOID
	name_plural = "Draconids"
	flesh_color = "#A02720"
	base_color = "#110101"
	brute_mod = 0.8 //something something dragon scales
	burn_mod = 0.9
	clothing_flags = null //no clothing.
	punchdamagelow = 9
	punchdamagehigh = 18
	punchstunthreshold = 18	//+8 claws of powergaming
	inherent_traits = list(
		TRAIT_HAS_LIPS,
		TRAIT_RESIST_HEAT,	// dragons like fire
		TRAIT_PIERCEIMMUNE,
		TRAIT_ASHSTORM_IMMUNE,
	)
	no_equip = list(ITEM_SLOT_FEET) //everyone have to pay for
	speed_mod = -0.25			//beeing slightly faster
	has_organ = list(
		INTERNAL_ORGAN_HEART = /obj/item/organ/internal/heart/unathi,
		INTERNAL_ORGAN_LUNGS = /obj/item/organ/internal/lungs/unathi/ash_walker,
		INTERNAL_ORGAN_LIVER = /obj/item/organ/internal/liver/unathi,
		INTERNAL_ORGAN_KIDNEYS = /obj/item/organ/internal/kidneys/unathi,
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain/unathi,
		INTERNAL_ORGAN_APPENDIX = /obj/item/organ/internal/appendix,
		INTERNAL_ORGAN_EYES = /obj/item/organ/internal/eyes/unathi,
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears,
	) //no need to b-r-e-a-t-h


/datum/species/unathi/draconid/on_species_gain(mob/living/carbon/human/owner)
	. = ..()
	var/obj/item/organ/external/head/head_organ = owner.get_organ(BODY_ZONE_HEAD)
	head_organ?.ha_style = "Drake"
	owner.change_eye_color("#A02720")
	owner.update_dna()
	owner.update_inv_head()
	owner.update_inv_wear_suit() //update sprites for digi legs
	var/datum/action/innate/ignite_unathi/fire = locate() in owner.actions
	if(!fire)
		fire = new
		fire.Grant(owner)


/datum/species/unathi/draconid/on_species_loss(mob/living/carbon/owner)
	. = ..()
	owner.update_inv_head()
	owner.update_inv_wear_suit()
	var/datum/action/innate/ignite_unathi/fire = locate() in owner.actions
	fire?.Remove(owner)


//igniter. only for ashwalkers and drakonids because of """lore"""
/datum/action/innate/ignite_unathi
	name = "Ignite"
	desc = "You form a fire in your mouth, fierce enough to... light a cigarette."
	icon_icon = 'icons/obj/cigarettes.dmi'
	button_icon_state = "match_unathi"
	var/cooldown = 0
	var/cooldown_duration = 40 SECONDS
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED|AB_CHECK_HANDS_BLOCKED

/datum/action/innate/ignite_unathi/Activate()
	var/mob/living/carbon/human/user = owner
	if(world.time <= cooldown)
		to_chat(user, span_warning("Your throat hurts too much to do it right now. Wait [round((cooldown - world.time) / 10)] seconds and try again."))
		return
	if((user.head?.flags_cover & HEADCOVERSMOUTH) || (user.wear_mask?.flags_cover & MASKCOVERSMOUTH) && !user.wear_mask?.up)
		to_chat(user, span_warning("Your mouth is covered."))
		return
	var/obj/item/match/unathi/fire = new(user.loc, src)
	if(user.put_in_hands(fire))
		to_chat(user, span_notice("You ignite a small flame in your mouth."))
		cooldown = world.time + cooldown_duration
	else
		qdel(fire)
		to_chat(user, span_warning("You don't have any free hands."))

/datum/action/innate/anvil_finder
	name = "Find World Anvil"
	desc = "You call the Necropolis in order to find The World Anvil."
	icon_icon = 'icons/mob/actions/actions_clockwork.dmi'
	button_icon_state = "stun" //better than nothing

/datum/action/innate/anvil_finder/Activate()
	addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, owner, \
							span_warning("Я чувствую, что Мировая Кузница [get_direction()]")), 2 SECONDS)

/datum/action/innate/anvil_finder/proc/get_direction()
	for(var/obj/structure/world_anvil/Anvil in GLOB.anvils)
		if(!Anvil)
			. = "уничтожена."
			return
		var/turf/T = get_turf(Anvil)
		if(owner.z == T.z) //"кузница находится где-то на северо-востоке" or whatever
			. = "находится где-то на "
			. += dir2rustext(get_dir(owner.loc, Anvil.loc))
			. += "e."
		else
			. = "находится где-то далеко отсюда."
