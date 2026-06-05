/**********************************
*******Interactions code by HONKERTRON feat TestUnit********
***********************************/

/mob/living/carbon/human/proc/interact_by_mouse_drop_dragged(mob/M)
	if(ishuman(M) && usr != M && src != M)
		partner = M
		var/datum/interactions/tgui = new /datum/interactions
		tgui.owner = src
		tgui.ui_interact(src)

/mob/living/carbon/human/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	if(src != user)
		return
	interact_by_mouse_drop_dragged(over_object)

//Distant interactions
/mob/living/carbon/human/verb/interact()
	set name = "Взаимодействовать"
	set category = VERB_CATEGORY_IC

	var/list/targets = list()
	for(var/mob/living/carbon/human/human in view(src))
		if (human != src)
			targets[human.name] = human

	if(!length(targets))
		return

	var/choice = tgui_input_list(src, "Доступные цели:", "Выберите цель для взаимодействия", targets)
	var/mob/living/carbon/human/M = targets[choice]

	if(ishuman(M) && usr != M && src != M)
		partner = M
		var/datum/interactions/tgui = new /datum/interactions
		tgui.owner = src
		tgui.ui_interact(src)

/mob/living/carbon/human/proc/is_nude()
	return (!wear_suit && !w_uniform) ? TRUE : FALSE //TODO: Nudity check for underwear

/datum/interactions
	var/mob/living/carbon/human/owner

/datum/interactions/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Interactions")
		ui.open()

/datum/interactions/ui_data(mob/user)
	var/list/data = list()

	data["interactions"] = list()

	var/mob/living/carbon/human/H = user
	var/mob/living/carbon/human/P = H.partner

	if(!P)
		data["partner"] = "Никто"
		data["interactions"] = list()
		return data

	data["partner"] = "[H.partner]"

	var/obj/item/organ/external/temp = H.bodyparts_by_name[BODY_ZONE_PRECISE_R_HAND]
	var/hashands = (temp?.is_usable())
	if(!hashands)
		temp = H.bodyparts_by_name[BODY_ZONE_PRECISE_L_HAND]
		hashands = (temp?.is_usable())
	temp = P.bodyparts_by_name[BODY_ZONE_PRECISE_R_HAND]
	var/hashands_p = (temp?.is_usable())
	if(!hashands_p)
		temp = P.bodyparts_by_name[BODY_ZONE_PRECISE_L_HAND]
		hashands_p = (temp?.is_usable())
	var/mouthfree = !((H.head && (H.head.flags_cover & HEADCOVERSMOUTH)) || (H.wear_mask && (H.wear_mask.flags_cover & MASKCOVERSMOUTH)))
	var/mouthfree_p = !((P.head && (P.head.flags_cover & HEADCOVERSMOUTH)) || (P.wear_mask && (P.wear_mask.flags_cover & MASKCOVERSMOUTH)))

	data["interactions"] += list(list(
        	"category" = "",
        	"action" = "bow",
        	"label" = "Отвесить поклон.",
        	"danger" = FALSE
   		))
	if(hashands)
		// category, action, label, is_danger
		data["interactions"] += list(list(
        	"category" = "hands",
        	"action" = "wave",
        	"label" = "Приветливо помахать.",
        	"danger" = FALSE
   		))
		data["interactions"] += list(list(
        	"category" = "hands",
        	"action" = "bow_affably",
        	"label" = "Приветливо помахать.",
        	"danger" = FALSE
   		))
		if(H.Adjacent(P))
			data["interactions"] += list(list(
        		"category" = "hands",
        		"action" = "handshake",
        		"label" = "Пожать руку.",
        		"danger" = FALSE
   			))
			data["interactions"] += list(list(
        		"category" = "hands",
        		"action" = "hug",
        		"label" = "Обнимашки!",
        		"danger" = FALSE
   			))
			data["interactions"] += list(list(
        		"category" = "hands",
        		"action" = "cheer",
        		"label" = "Похлопать по плечу",
        		"danger" = FALSE
   			))
			data["interactions"] += list(list(
        		"category" = "hands",
        		"action" = "five",
        		"label" = "Дать пять.",
        		"danger" = FALSE
   			))
			if(hashands_p)
				data["interactions"] += list(list(
        			"category" = "hands",
        			"action" = "give",
        			"label" = "Передать предмет.",
        			"danger" = FALSE
   				))
			data["interactions"] += list(list(
        		"category" = "hands",
        		"action" = "slap",
        		"label" = "Дать пощечину!",
        		"danger" = TRUE
   			))
			if(P.dna.species.name == SPECIES_MOTH)
				data["interactions"] += list(list(
        			"category" = "hands",
        			"action" = "pullwing",
        			"label" = "Дёрнуть за крылья!",
        			"danger" = TRUE
   				))
			if((P.dna.species.name == SPECIES_TAJARAN)  || (P.dna.species.name == SPECIES_VOX)|| (P.dna.species.name == SPECIES_VULPKANIN) || (P.dna.species.name == SPECIES_UNATHI))
				data["interactions"] += list(list(
        			"category" = "hands",
        			"action" = "pull",
        			"label" = "Дёрнуть за хвост!",
        			"danger" = TRUE
   				))
				if(P.can_inject(H))
					data["interactions"] += list(list(
        				"category" = "hands",
        				"action" = "pet",
        				"label" = "Погладить.",
        				"danger" = FALSE
   					))
					data["interactions"] += list(list(
        				"category" = "hands",
        				"action" = "scratch",
        				"label" = "Почесать",
        				"danger" = FALSE
   					))
			data["interactions"] += list(list(
        		"category" = "hands",
        		"action" = "knock",
        		"label" = "Дать подзатыльник.",
        		"danger" = TRUE
   			))
		data["interactions"] += list(list(
    		"category" = "hands",
    		"action" = "fuckyou",
    		"label" = "Показать средний палец.",
    		"danger" = TRUE
   		))
		data["interactions"] += list(list(
    		"category" = "hands",
    		"action" = "threaten",
    		"label" = "Погрозить кулаком.",
    		"danger" = TRUE
   		))

	if(mouthfree && H.dna.species.name != SPECIES_DIONA)
		data["interactions"] += list(list(
    		"category" = "mouth",
    		"action" = "kiss",
    		"label" = "Поцеловать.",
    		"danger" = FALSE
   		))
		if(H.Adjacent(P))
			if(mouthfree_p)
				data["interactions"] += list(list(
    				"category" = "mouth",
    				"action" = "lick",
    				"label" = "Лизнуть в щеку.",
    				"danger" = FALSE
   				))

			data["interactions"] += list(list(
    				"category" = "mouth",
    				"action" = "spit",
    				"label" = "Плюнуть.",
    				"danger" = TRUE
   				))
		data["interactions"] += list(list(
			"category" = "mouth",
			"action" = "tongue",
			"label" = "Показать язык.",
			"danger" = TRUE
   		))

	return data

/datum/interactions/ui_act(action, params, datum/tgui/ui)
	if(..())
		return

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	var/mob/living/carbon/human/H = ui.user
	var/mob/living/carbon/human/P = H.partner
	if(!(P in view(H.loc)))
		return

	if(world.time <= H.last_interract + 1 SECONDS)
		return

	H.last_interract = world.time

	switch(action)
		if("bow")
			H.custom_emote(message = "кланя[PLUR_ET_YUT(H)]ся [P].")

		if("pet")
			if(HAS_TRAIT(H, TRAIT_HANDS_BLOCKED) || !P.Adjacent(H.loc))
				return

			H.custom_emote(message = "[pick("глад[PLUR_IT_YAT(H)]", "поглажива[PLUR_ET_YUT(H)]")] [P].")

		if("scratch")
			if(HAS_TRAIT(H, TRAIT_HANDS_BLOCKED) || !P.Adjacent(H.loc))
				return

			if(H.zone_selected != BODY_ZONE_HEAD || ismachineperson(P) || isunathi(P) || isgrey(P))
				H.custom_emote(message = "[pick("чеш[PLUR_ET_UT(H)]")] [P].")

			else
				H.custom_emote(message = "[pick("чеш[PLUR_ET_UT(H)] за ухом", "чеш[PLUR_ET_UT(H)] голову")] [P].")

		if("give")
			if(!P.Adjacent(H.loc))
				return

			H.give(P)

		if("kiss")
			if(!get_location_accessible(H, BODY_ZONE_PRECISE_MOUTH))
				return

			if(!P.Adjacent(H.loc))
				H.custom_emote(message = "посыла[PLUR_ET_YUT(H)] [P] воздушный поцелуй.")

			else if(get_location_accessible(P, BODY_ZONE_PRECISE_MOUTH))
				H.custom_emote(message = "целу[PLUR_ET_YUT(H)] [P].")

		if("lick")
			if(!P.Adjacent(H.loc) || !get_location_accessible(H, BODY_ZONE_PRECISE_MOUTH) || !get_location_accessible(P, BODY_ZONE_PRECISE_MOUTH))
				return

			if(prob(90))
				H.custom_emote(message = "лизнул[GEND_A_O_I(H)] [P] в щеку.")

			else
				H.custom_emote(message = "особо тщательно лизнул[GEND_A_O_I(H)] [P].")

		if("hug")
			if(HAS_TRAIT(H, TRAIT_HANDS_BLOCKED) || !P.Adjacent(H.loc))
				return

			H.custom_emote(message = "обнима[PLUR_ET_YUT(H)] [P].")
			playsound(H.loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

		if("cheer")
			if(HAS_TRAIT(H, TRAIT_HANDS_BLOCKED) || !P.Adjacent(H.loc))
				return

			H.custom_emote(message = "похлопыва[PLUR_ET_YUT(H)] [P] по плечу.")

		if("five")
			if(HAS_TRAIT(H, TRAIT_HANDS_BLOCKED) || !P.Adjacent(H.loc))
				return

			H.custom_emote(message = "да[PLUR_YOT_YUT(H)] [P] пять.")
			playsound(H.loc, 'sound/effects/snap.ogg', 25, TRUE, -1)

		if("handshake")
			if(HAS_TRAIT(H, TRAIT_HANDS_BLOCKED) || HAS_TRAIT(P, TRAIT_HANDS_BLOCKED) || !P.Adjacent(H.loc))
				return

			H.custom_emote(message = "жм[PLUR_YOT_UT(H)] руку [P].")

		if("bow_affably")
			H.custom_emote(message = "приветливо кивнул[GEND_A_O_I(H)] в сторону [P].")

		if("wave")
			if(HAS_TRAIT(H, TRAIT_HANDS_BLOCKED))
				return

			H.custom_emote(message = "приветливо маш[PLUR_ET_UT(H)] в сторону [P].")

		if("slap")
			if(HAS_TRAIT(H, TRAIT_HANDS_BLOCKED) || !P.Adjacent(H.loc))
				return

			var/obj/item/organ/external/targeted_organ = P.get_organ(H.zone_selected)
			if(!targeted_organ)
				return

			switch(H.zone_selected)
				if(BODY_ZONE_HEAD)
					H.custom_emote(message = span_danger("да[PLUR_ET_YUT(H)] [P] пощечину!"))

				if(BODY_ZONE_PRECISE_GROIN)
					H.custom_emote(message = span_danger("шлёпа[PLUR_ET_YUT(H)] [P] по заднице!"))

				if(BODY_ZONE_PRECISE_MOUTH)
					H.custom_emote(message = span_danger("да[PLUR_ET_YUT(H)] [P] по губе!"))

				else
					return

			if(targeted_organ.brute_dam < 5)
				P.apply_damage(1, def_zone = targeted_organ)

			playsound(H.loc, 'sound/effects/snap.ogg', 50, TRUE, -1)
			H.do_attack_animation(P)

		if("fuckyou")
			if(HAS_TRAIT(H, TRAIT_HANDS_BLOCKED))
				return

			H.custom_emote(message = span_danger("показыва[PLUR_ET_YUT(H)] [P] средний палец!"))

		if("knock")
			if(HAS_TRAIT(H, TRAIT_HANDS_BLOCKED) || !P.Adjacent(H.loc))
				return

			var/obj/item/organ/external/head/head = P.get_organ(BODY_ZONE_HEAD)
			if(!head)
				return

			if(head.brute_dam < 5)
				P.apply_damage(1, def_zone = head)

			H.custom_emote(message = span_danger("да[PLUR_ET_YUT(H)] [P] подзатыльник!"))
			playsound(H.loc, 'sound/weapons/throwtap.ogg', 50, TRUE, -1)
			H.do_attack_animation(P)

		if("spit")
			if(!P.Adjacent(H.loc) || !get_location_accessible(H, BODY_ZONE_PRECISE_MOUTH))
				return

			H.custom_emote(message = span_danger("плю[PLUR_YOT_YUT(H)] в [P]!"))

			if(prob(20))
				P.AdjustEyeBlurry(3 SECONDS)

		if("threaten")
			if(HAS_TRAIT(H, TRAIT_HANDS_BLOCKED))
				return

			H.custom_emote(message = span_danger("гроз[PLUR_IT_YAT(H)] [P] кулаком!"))

		if("tongue")
			if(!get_location_accessible(H, BODY_ZONE_PRECISE_MOUTH))
				return

			H.custom_emote(message = span_danger("показыва[PLUR_ET_YUT(H)] [P] язык!"))

		if("pullwing")
			if(HAS_TRAIT(H, TRAIT_HANDS_BLOCKED) || !P.Adjacent(H.loc))
				return

			var/obj/item/organ/external/wing/wing = P.get_organ(BODY_ZONE_WING)
			if(!wing)
				H.custom_emote(message = "пыта[PLUR_ET_YUT(H)]ся поймать [P] за крылья, [span_danger("КОТОРЫХ НЕТ!!!")]")
				return

			if(!prob(30))
				H.custom_emote(message = "пыта[PLUR_ET_YUT(H)]ся поймать [P] за крылья!")
				return

			if((wing.is_dead() || wing.has_fracture()) && prob(20))
				H.custom_emote(message = span_danger("отрыва[PLUR_ET_YUT(H)] [P] крылья!"))
				wing.droplimb()
				return

			if(wing.brute_dam < 10)
				P.apply_damage(1, def_zone = wing)

			H.custom_emote(message = span_danger("дёрга[PLUR_ET_YUT(H)] [P] за крылья!"))

		if("pull")
			if(HAS_TRAIT(H, TRAIT_HANDS_BLOCKED) || !P.Adjacent(H.loc))
				return

			var/obj/item/organ/external/tail/tail = P.get_organ(BODY_ZONE_TAIL)
			if(!tail)
				H.custom_emote(message = "пыта[PLUR_ET_YUT(H)]ся поймать [P] за хвост, [span_danger("КОТОРОГО НЕТ!!!")]")
				return

			var/obj/item/organ/internal/cyberimp/tail/blade/implant = P.get_organ_slot(INTERNAL_ORGAN_TAIL_DEVICE)
			if(istype(implant) && implant.activated)  // KEEP YOUR HANDS AWAY FROM ME!
				if(H.has_pain())
					H.emote("scream")

				H.custom_emote(message = span_danger("пыта[PLUR_ET_YUT(H)]ся дёрнуть [P] за хвост, но резко одёргива[PLUR_ET_YUT(H)] руки!"))
				H.apply_damage(5, implant.damage_type, BODY_ZONE_PRECISE_R_HAND)
				H.apply_damage(5, implant.damage_type, BODY_ZONE_PRECISE_L_HAND)
				return

			if(prob(70))
				H.custom_emote(message = "пыта[PLUR_ET_YUT(H)]ся поймать [P] за хвост!")
				return

			if((tail.is_dead() || tail.has_fracture()) && prob(20))
				H.custom_emote(message = span_danger("отрыва[PLUR_ET_YUT(H)] [P] хвост!"))
				tail.droplimb()
				return

			if(tail.brute_dam < 10)
				P.apply_damage(1, def_zone = tail)

			H.custom_emote(message = span_danger("дёрга[PLUR_ET_YUT(H)] [P] за хвост!"))
	H.update_icon()
	return TRUE


/datum/ui_state/interaction_state

/datum/ui_state/interaction_state/can_use_topic(src_object, mob/user, atom/ui_source)
	var/datum/interactions/inter_datum = src_object
	if(!istype(inter_datum))
		return UI_CLOSE

	var/mob/living/carbon/human/H = user
	if(!istype(H) || H != inter_datum.owner)
		return UI_CLOSE

	. = H.shared_ui_interaction()
	if(. <= UI_CLOSE)
		return .

	var/mob/living/carbon/human/P = H.partner
	if(QDELETED(P) || !(P in view(H.loc)))   // партнёр должен быть видим
		return UI_CLOSE

	if(HAS_TRAIT(H, TRAIT_HANDS_BLOCKED))
		return UI_UPDATE

	return UI_INTERACTIVE

GLOBAL_DATUM_INIT(interaction_state, /datum/ui_state/interaction_state, new)

/datum/interactions/ui_state(mob/user)
	return GLOB.interaction_state
