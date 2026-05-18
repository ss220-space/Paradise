#define DEVIL_HANDS_LAYER 1
#define DEVIL_HEAD_LAYER 2
#define DEVIL_TOTAL_LAYERS 2
// This is used primarily for having hands.
/mob/living/carbon/true_devil
	name = "True Devil"
	desc = "Сгусток адской энергии, смутно напоминающий гуманоида."
	icon = 'icons/mob/32x64.dmi'
	icon_state = "true_devil"
	gender = NEUTER
	health = 400
	maxHealth = 400
	ventcrawler_trait = NONE
	sight = SEE_TURFS|SEE_OBJS
	status_flags = CANPUSH
	mob_size = MOB_SIZE_LARGE
	pixel_y_lying_offset = -20
	hud_type = /datum/hud/devil
	tts_seed = "Mannoroth"
	var/datum/antagonist/devil/devilinfo
	var/ascended = FALSE
	var/list/devil_overlays[DEVIL_TOTAL_LAYERS]

/mob/living/carbon/true_devil/get_ru_names()
	return list(
		NOMINATIVE = "истинный Дьявол",
		GENITIVE = "истинного Дьявола",
		DATIVE = "истинному Дьяволу",
		ACCUSATIVE = "истинного Дьявола",
		INSTRUMENTAL = "истинным Дьяволом",
		PREPOSITIONAL = "истинном Дьяволе",
	)

/mob/living/carbon/true_devil/ascended
	name = "Arch Devil"
	desc = "Сгусток адской энергии, смутно напоминающий гуманоида. Кажется оно достигло пика своего могущества"
	maxHealth = 1000 // not an IMPOSSIBLE amount, but still near impossible.
	ascended = TRUE
	health = 1000
	icon_state = "arch_devil"
	tts_seed = "Dread_bm"

/mob/living/carbon/true_devil/ascended/ex_act(severity, ex_target)
	return FALSE

/mob/living/carbon/true_devil/Initialize(mapload, mob/living/carbon/dna_source)
	if(dna_source)
		dna = dna_source.dna.Clone()
	else
		dna = new
	grant_all_babel_languages()
	prepare_huds()
	new /obj/item/organ/internal/brain(src)
	new /obj/item/organ/internal/eyes(src)
	new /obj/item/organ/internal/ears/invincible(src)
	create_reagents(300)
	add_traits(list(TRAIT_HEALS_FROM_HELL_RIFTS, TRAIT_HAS_CARBON_REGENERATION), INNATE_TRAIT)
	. = ..()

// Determines if mob has and can use his hands like a human
/mob/living/carbon/true_devil/real_human_being()
	return TRUE

/mob/living/carbon/true_devil/set_name()
	if(!devilinfo)
		devilinfo = mind?.has_antag_datum(/datum/antagonist/devil)
	name = devilinfo.info.truename
	real_name = name

/mob/living/carbon/true_devil/death(gibbed)
	. = ..(gibbed)
	drop_all_held_items()

/mob/living/carbon/true_devil/examine(mob/user)
	var/msg = span_notice("Это [get_examine_icon(user)] <b>[declent_ru(NOMINATIVE)]</b>!\n")

	//left hand
	if(l_hand && !(l_hand.item_flags & ABSTRACT))
		if(l_hand.blood_DNA)
			msg += span_warning("[GEND_HE_SHE_CAP(src)] держ[PLUR_IT_AT(src)] [icon2html(l_hand, user)] [l_hand.declent_ru(ACCUSATIVE)] [l_hand.blood_color != "#030303" ? "со следами крови":"со следами масла"] в левой руке!\n")
		else
			msg += "[GEND_HE_SHE_CAP(src)] держ[PLUR_IT_AT(src)] [icon2html(l_hand, user)] [l_hand.declent_ru(ACCUSATIVE)] в левой руке.\n"

	//right hand
	if(r_hand && !(r_hand.item_flags & ABSTRACT))
		if(r_hand.blood_DNA)
			msg += span_warning("[GEND_HE_SHE_CAP(src)] держ[PLUR_IT_AT(src)] [icon2html(r_hand, user)] [r_hand.declent_ru(ACCUSATIVE)] [r_hand.blood_color != "#030303" ? "со следами крови":"со следами масла"] в правой руке!\n")
		else
			msg += "[GEND_HE_SHE_CAP(src)] держ[PLUR_IT_AT(src)] [icon2html(r_hand, user)] [r_hand.declent_ru(ACCUSATIVE)] в правой руке.\n"

	//Braindead
	if(!client && stat != DEAD)
		msg += span_deadsay("Кажется, этот дьявол пребывает в глубоком раздумье\n")

	//Damaged
	if(stat == DEAD)
		msg += span_deadsay("Похоже, адское пламя в нем потухло, по крайней мере на данный момент.\n")
	else if(health < (maxHealth/10))
		msg += span_warning("Внутри его зияющих ран можно увидеть адское пламя\n")
	else if(health < (maxHealth/2))
		msg += span_warning("Внутри его ран можно разглядеть адское пламя.\n")

	. = list(msg)

/mob/living/carbon/true_devil/r_arm_broken()
	return FALSE

/mob/living/carbon/true_devil/l_arm_broken()
	return FALSE

/mob/living/carbon/true_devil/IsAdvancedToolUser()
	return TRUE

/mob/living/carbon/true_devil/assess_threat()
	return 666

/mob/living/carbon/true_devil/OnUnarmedAttack(atom/atom, proximity_flag, list/modifiers)
	if(!ishuman(atom))
		// `attack_hand` on mobs assumes the attacker is a human
		// I am the worst
		return atom.attack_hand(src)
		// If the devil wants to actually attack, they have the pitchfork.

/mob/living/carbon/true_devil/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE

/mob/living/carbon/true_devil/resist_fire()
	return

/mob/living/carbon/true_devil/check_ear_prot()
	return HEARING_PROTECTION_TOTAL

/mob/living/carbon/true_devil/singularity_act()
	if(ascended)
		return FALSE
	return ..()

/mob/living/carbon/true_devil/attack_hand(mob/living/carbon/human/M)
	. = ..()
	if(!.)
		return .

	switch(M.a_intent)
		if(INTENT_HARM)
			var/damage = rand(1, 5)
			playsound(loc, SFX_PUNCH, 25, TRUE, -1)
			visible_message(span_danger("[DECLENT_RU_CAP(M, NOMINATIVE)] ударил[GEND_A_O_I(M)] [declent_ru(ACCUSATIVE)]!"), \
					span_userdanger("[DECLENT_RU_CAP(M, NOMINATIVE)] ударил[GEND_A_O_I(M)] [declent_ru(ACCUSATIVE)]!"))
			adjustBruteLoss(damage)
			add_attack_logs(M, src, "attacked")

		if(INTENT_DISARM)

			if(body_position != STANDING_UP) //No stealing the arch devil's pitchfork.
				return FALSE

			if(prob(5))
				// Weaken knocks people over
				// Paralyse knocks people out
				// It's Paralyse for parity though
				// Weaken(4 SECONDS)
				Paralyse(4 SECONDS)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
				add_attack_logs(M, src, "pushed")
				visible_message(span_danger("[DECLENT_RU_CAP(M, NOMINATIVE)] повалил[GEND_A_O_I(M)] [declent_ru(ACCUSATIVE)]!"), \
						span_userdanger("[DECLENT_RU_CAP(M, NOMINATIVE)] повалил[GEND_A_O_I(M)] [declent_ru(ACCUSATIVE)]!"))
				return FALSE

			if(!prob(25))
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
				visible_message(span_danger("[DECLENT_RU_CAP(M, NOMINATIVE)] попытал[GEND_SYA_AS_OS_IS(M)] обезоружить [declent_ru(ACCUSATIVE)]!"))
				return FALSE

			drop_from_active_hand()
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
			visible_message(span_danger("[DECLENT_RU_CAP(M, NOMINATIVE)] обезоружил[GEND_A_O_I(M)] [declent_ru(ACCUSATIVE)]!"), \
			span_userdanger("[DECLENT_RU_CAP(M, NOMINATIVE)] обезоружил[GEND_A_O_I(M)] [declent_ru(ACCUSATIVE)]!"))

/mob/living/carbon/true_devil/handle_breathing()
	return
	// devils do not need to breathe

/mob/living/carbon/true_devil/is_literate()
	return TRUE

/mob/living/carbon/true_devil/ex_act(severity, ex_target)
	if(!ascended)
		var/b_loss
		switch(severity)
			if(EXPLODE_DEVASTATE)
				b_loss = 500
			if(EXPLODE_HEAVY)
				b_loss = 150
			if(EXPLODE_LIGHT)
				b_loss = 30
		adjustBruteLoss(b_loss)
	return ..()

/mob/living/carbon/true_devil/fire_act(exposed_temperature, exposed_volume)
	return FALSE

/mob/living/carbon/true_devil/flamer_fire_act(damage)
	return FALSE

/mob/living/carbon/true_devil/handle_flamer_fire(obj/flamer_fire/fire, damage, delta_time)
	return FALSE

/mob/living/carbon/true_devil/handle_flamer_fire_crossed(obj/flamer_fire/fire)
	return FALSE

/mob/living/carbon/true_devil/handle_critical_condition()
	if(health > 0)
		return
	adjustOxyLoss(10)

/mob/living/carbon/true_devil/krampus
	name = "Krampus"
	desc = "Он пришел тебя наказать. Лучше беги."
	icon_state = "arch_krampus"
	health = 800
	maxHealth = 800
	var/list/bag_content
	var/static/list/spell_list = list(
		/obj/effect/proc_holder/spell/conjure_item/krampus_bag,
		/obj/effect/proc_holder/spell/conjure_item/pitchfork/krampus,
		/obj/effect/proc_holder/spell/fireball/hellish,
		/obj/effect/proc_holder/spell/aoe/devil_fire,
		/obj/effect/proc_holder/spell/infernal_jaunt,
	)

/mob/living/carbon/true_devil/krampus/get_ru_names()
	return list(
		NOMINATIVE = "Крампус",
		GENITIVE = "Крампуса",
		DATIVE = "Крампусу",
		ACCUSATIVE = "Крампуса",
		INSTRUMENTAL = "Крампусом",
		PREPOSITIONAL = "Крампусе",
	)

/mob/living/carbon/true_devil/krampus/Initialize(mapload, mob/living/carbon/dna_source)
	. = ..()
	ADD_TRAIT(src, TRAIT_SNOWSTORM_IMMUNE, INNATE_TRAIT)
	for(var/spell in spell_list)
		AddSpell(new spell)

/mob/living/carbon/true_devil/krampus/Destroy()
	var/turf/drop_loc = get_turf(src)

	for(var/atom/movable/atom as anything in bag_content)
		atom.forceMove(drop_loc)

		if(!isliving(atom))
			continue

		var/mob/living/mob = atom
		mob.revive()

	. = ..()

/mob/living/carbon/true_devil/krampus/Login()
	. = ..()
	mind.add_antag_datum(/datum/antagonist/krampus)

/mob/living/carbon/true_devil/krampus/death(gibbed)
	if(!gibbed)
		dust()
		return
	. = ..()

/mob/living/carbon/true_devil/krampus/gib()
	dust()

/mob/living/carbon/true_devil/krampus/melt()
	dust()

