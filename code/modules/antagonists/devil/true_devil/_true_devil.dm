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
	health = 350
	maxHealth = 350
	mobility_flags = MOBILITY_FLAGS_DEFAULT
	ventcrawler_trait = NONE
	density = TRUE
	pass_flags = NONE
	sight = SEE_TURFS|SEE_OBJS
	status_flags = CANPUSH
	mob_size = MOB_SIZE_LARGE
	var/mob/living/oldform
	var/datum/antagonist/devil/devilinfo
	var/ascended = FALSE
	var/list/devil_overlays[DEVIL_TOTAL_LAYERS]
	hud_type = /datum/hud/devil

/mob/living/carbon/true_devil/ascended
	name = "Arch Devil"
	desc = "Сгусток адской энергии, смутно напоминающий гуманоида. Кажется оно достигло пика своего могущества"
	maxHealth = 500 // not an IMPOSSIBLE amount, but still near impossible.
	ascended = TRUE
	health = 500
	icon_state = "arch_devil"

/mob/living/carbon/true_devil/Initialize(mapload, mob/living/carbon/dna_source)
	if(dna_source)
		dna = dna_source.dna.Clone()
	else
		dna = new
	devilinfo = mind?.has_antag_datum(/datum/antagonist/devil)
	grant_all_babel_languages()
	prepare_huds()
	new /obj/item/organ/internal/brain(src)
	new /obj/item/organ/internal/eyes(src)
	new /obj/item/organ/internal/ears/invincible(src)
	. = ..()

// Determines if mob has and can use his hands like a human
/mob/living/carbon/true_devil/real_human_being()
	return TRUE

/mob/living/carbon/true_devil/set_name()
	name = devilinfo.info.truename
	real_name = name


/mob/living/carbon/true_devil/death(gibbed)
	. = ..(gibbed)
	drop_all_held_items()


/mob/living/carbon/true_devil/examine(mob/user)
	var/msg = span_info("Это [bicon(src)] <b>[declent_ru(NOMINATIVE)]</b>!\n")

	//left hand
	if(l_hand && !(l_hand.item_flags & ABSTRACT))
		if(l_hand.blood_DNA)
			msg += span_warning("[genderize_ru(gender, "Он держит", "Она держит", "Оно держит", "Они держат")] [bicon(l_hand)] [l_hand.declent_ru(ACCUSATIVE)] [l_hand.blood_color != "#030303" ? "со следами крови":"со следами масла"] в левой руке!\n")
		else
			msg += "[genderize_ru(gender, "Он держит", "Она держит", "Оно держит", "Они держат")] [bicon(l_hand)] [l_hand.declent_ru(ACCUSATIVE)] в левой руке.\n"

	//right hand
	if(r_hand && !(r_hand.item_flags & ABSTRACT))
		if(r_hand.blood_DNA)
			msg += span_warning("[genderize_ru(gender, "Он держит", "Она держит", "Оно держит", "Они держат")] [bicon(r_hand)] [r_hand.declent_ru(ACCUSATIVE)] [r_hand.blood_color != "#030303" ? "со следами крови":"со следами масла"] в правой руке!\n")
		else
			msg += "[genderize_ru(gender, "Он держит", "Она держит", "Оно держит", "Они держат")] [bicon(r_hand)] [r_hand.declent_ru(ACCUSATIVE)] в правой руке.\n"

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

/mob/living/carbon/true_devil/proceed_attack_results(obj/item/I, mob/living/user, params, def_zone)
	. = ATTACK_CHAIN_PROCEED_SUCCESS

	send_item_attack_message(I, user, def_zone)
	if(!I.force)
		return .

	if(QDELETED(src))
		return ATTACK_CHAIN_BLOCKED_ALL


/mob/living/carbon/true_devil/OnUnarmedAttack(atom/atom, proximity)
	if(!ishuman(atom))
		// `attack_hand` on mobs assumes the attacker is a human
		// I am the worst
		return atom.attack_hand(src)
		// If the devil wants to actually attack, they have the pitchfork.


/mob/living/carbon/true_devil/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE

/mob/living/carbon/true_devil/resist_fire()
	return

/mob/living/carbon/true_devil/soundbang_act()
	return FALSE

/mob/living/carbon/true_devil/get_ear_protection()
	return 2

/mob/living/carbon/true_devil/singularity_act()
	if(ascended)
		return FALSE
	return ..()

/mob/living/carbon/true_devil/attack_hand(mob/living/carbon/human/M)
	if(..())
		switch(M.a_intent)
			if(INTENT_HARM)
				var/damage = rand(1, 5)
				playsound(loc, "punch", 25, 1, -1)
				visible_message(span_danger("[capitalize(M.declent_ru(NOMINATIVE))] [genderize_ru(M.gender, "ударил", "ударила", "ударило", "ударили")] [declent_ru(ACCUSATIVE)]!"), \
						span_userdanger("[capitalize(M.declent_ru(NOMINATIVE))] [genderize_ru(M.gender, "ударил", "ударила", "ударило", "ударили")] [declent_ru(ACCUSATIVE)]!"))
				adjustBruteLoss(damage)
				add_attack_logs(M, src, "attacked")
			if(INTENT_DISARM)
				if(body_position == STANDING_UP) //No stealing the arch devil's pitchfork.
					if(prob(5))
						// Weaken knocks people over
						// Paralyse knocks people out
						// It's Paralyse for parity though
						// Weaken(4 SECONDS)
						Paralyse(4 SECONDS)
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
						add_attack_logs(M, src, "pushed")
						visible_message(span_danger("[capitalize(M.declent_ru(NOMINATIVE))] [genderize_ru(M.gender, "повалил", "повалила", "повалило", "повалили")] [declent_ru(ACCUSATIVE)]!"), \
							span_userdanger("[capitalize(M.declent_ru(NOMINATIVE))] [genderize_ru(M.gender, "повалил", "повалила", "повалило", "повалили")] [declent_ru(ACCUSATIVE)]!"))
					else
						if(prob(25))
							drop_from_active_hand()
							playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
							visible_message(span_danger("[capitalize(M.declent_ru(NOMINATIVE))] [genderize_ru(M.gender, "обезоружил", "обезоружила", "обезоружило", "обезоружили")] [declent_ru(ACCUSATIVE)]!"), \
							span_userdanger("[capitalize(M.declent_ru(NOMINATIVE))] [genderize_ru(M.gender, "обезоружил", "обезоружила", "обезоружило", "обезоружили")] [declent_ru(ACCUSATIVE)]!"))
						else
							playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
							visible_message(span_danger("[capitalize(M.declent_ru(NOMINATIVE))] [genderize_ru(M.gender, "попытался", "попыталась", "попыталось", "попытались")] обезоружить [declent_ru(ACCUSATIVE)]!"))

/mob/living/carbon/true_devil/handle_breathing()
	return
	// devils do not need to breathe

/mob/living/carbon/true_devil/is_literate()
	return TRUE

/mob/living/carbon/true_devil/ex_act(severity, ex_target)
	if(!ascended)
		var/b_loss
		switch (severity)
			if (EXPLODE_DEVASTATE)
				b_loss = 500
			if (EXPLODE_HEAVY)
				b_loss = 150
			if (EXPLODE_LIGHT)
				b_loss = 30
		adjustBruteLoss(b_loss)
	return ..()
