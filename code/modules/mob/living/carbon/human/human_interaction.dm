/mob/living/carbon/human/Topic(href, href_list)
	///////Interactions!!///////
	if(!href_list["interaction"])
		return ..()

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	//CONDITIONS
	var/mob/living/carbon/human/H = usr
	var/mob/living/carbon/human/P = H.partner
	if(!(P in view(H.loc)))
		return

	if(world.time <= H.last_interract + 1 SECONDS)
		return

	H.last_interract = world.time

	switch(href_list["interaction"])
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
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

		if("cheer")
			if(HAS_TRAIT(H, TRAIT_HANDS_BLOCKED) || !P.Adjacent(H.loc))
				return

			H.custom_emote(message = "похлопыва[PLUR_ET_YUT(H)] [P] по плечу.")

		if("five")
			if(HAS_TRAIT(H, TRAIT_HANDS_BLOCKED) || !P.Adjacent(H.loc))
				return

			H.custom_emote(message = "да[PLUR_YOT_YUT(H)] [P] пять.")
			playsound(loc, 'sound/effects/snap.ogg', 25, TRUE, -1)

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

			playsound(loc, 'sound/effects/snap.ogg', 50, TRUE, -1)
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
			playsound(loc, 'sound/weapons/throwtap.ogg', 50, TRUE, -1)
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
