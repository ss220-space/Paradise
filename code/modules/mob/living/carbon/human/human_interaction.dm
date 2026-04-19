/mob/living/carbon/human/Topic(href, href_list)
	///////Interactions!!///////
	if(!href_list["interaction"])
		return ..()

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	//CONDITIONS
	var/mob/living/carbon/human/human_user = usr
	var/mob/living/carbon/human/human_partner = human_user.partner
	if(!(human_partner in view(human_user.loc)))
		return

	if(world.time <= human_user.last_interract + 1 SECONDS)
		return

	human_user.last_interract = world.time

	switch(href_list["interaction"])
// MARK: BOW
		if("bow")
			human_user.custom_emote(message = "кланя[PLUR_ET_YUT(human_user)]ся [human_partner].")
// MARK: PET
		if("pet")
			if(HAS_TRAIT(human_user, TRAIT_HANDS_BLOCKED) || !human_partner.Adjacent(human_user.loc))
				return

			human_user.custom_emote(message = "[pick("глад[PLUR_IT_YAT(human_user)]", "поглажива[PLUR_ET_YUT(human_user)]")] [human_partner].")
// MARK:SCRATCH
		if("scratch")
			if(HAS_TRAIT(human_user, TRAIT_HANDS_BLOCKED) || !human_partner.Adjacent(human_user.loc))
				return

			if(human_user.zone_selected != BODY_ZONE_HEAD || ismachineperson(human_partner) || isunathi(human_partner) || isgrey(human_partner))
				human_user.custom_emote(message = "[pick("чеш[PLUR_ET_UT(human_user)]")] [human_partner].")

			else
				human_user.custom_emote(message = "[pick("чеш[PLUR_ET_UT(human_user)] за ухом", "чеш[PLUR_ET_UT(human_user)] голову")] [human_partner].")
// MARK: GIVE
		if("give")
			if(!human_partner.Adjacent(human_user.loc))
				return

			human_user.give(human_partner)
// MARK: KISS
		if("kiss")
			if(!get_location_accessible(human_user, BODY_ZONE_PRECISE_MOUTH))
				return

			if(!human_partner.Adjacent(human_user.loc))
				human_user.custom_emote(message = "посыла[PLUR_ET_YUT(human_user)] [human_partner] воздушный поцелуй.")

			else if(get_location_accessible(human_partner, BODY_ZONE_PRECISE_MOUTH))
				human_user.custom_emote(message = "целу[PLUR_ET_YUT(human_user)] [human_partner].")
// MARK: LICK
		if("lick")
			if(!human_partner.Adjacent(human_user.loc) || !get_location_accessible(human_user, BODY_ZONE_PRECISE_MOUTH) || !get_location_accessible(human_partner, BODY_ZONE_PRECISE_MOUTH))
				return

			if(prob(90))
				human_user.custom_emote(message = "лизнул[GEND_A_O_I(human_user)] [human_partner] в щеку.")

			else
				human_user.custom_emote(message = "особо тщательно лизнул[GEND_A_O_I(human_user)] [human_partner].")
// MARK: HUG
		if("hug")
			if(HAS_TRAIT(human_user, TRAIT_HANDS_BLOCKED) || !human_partner.Adjacent(human_user.loc))
				return

			human_user.custom_emote(message = "обнима[PLUR_ET_YUT(human_user)] [human_partner].")
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
// MARK: CHEER
		if("cheer")
			if(HAS_TRAIT(human_user, TRAIT_HANDS_BLOCKED) || !human_partner.Adjacent(human_user.loc))
				return

			human_user.custom_emote(message = "похлопыва[PLUR_ET_YUT(human_user)] [human_partner] по плечу.")
// MARK: FIVE
		if("five")
			if(HAS_TRAIT(human_user, TRAIT_HANDS_BLOCKED) || !human_partner.Adjacent(human_user.loc))
				return

			human_user.custom_emote(message = "да[PLUR_YOT_YUT(human_user)] [human_partner] пять.")
			playsound(loc, 'sound/effects/snap.ogg', 25, TRUE, -1)
// MARK: HANDSHAKE
		if("handshake")
			if(HAS_TRAIT(human_user, TRAIT_HANDS_BLOCKED) || HAS_TRAIT(human_partner, TRAIT_HANDS_BLOCKED) || !human_partner.Adjacent(human_user.loc))
				return

			human_user.custom_emote(message = "жм[PLUR_YOT_UT(human_user)] руку [human_partner].")
// MARK: BOW AFFABLY
		if("bow_affably")
			human_user.custom_emote(message = "приветливо кивнул[GEND_A_O_I(human_user)] в сторону [human_partner].")
// MARK: WAVE
		if("wave")
			if(HAS_TRAIT(human_user, TRAIT_HANDS_BLOCKED))
				return

			human_user.custom_emote(message = "приветливо маш[PLUR_ET_UT(human_user)] в сторону [human_partner].")
// MARK: SLAP
		if("slap")
			if(HAS_TRAIT(human_user, TRAIT_HANDS_BLOCKED) || !human_partner.Adjacent(human_user.loc))
				return

			var/obj/item/organ/external/targeted_organ = human_partner.get_organ(human_user.zone_selected)
			if(!targeted_organ)
				return

			switch(human_user.zone_selected)
				if(BODY_ZONE_HEAD)
					human_user.custom_emote(message = span_danger("да[PLUR_ET_YUT(human_user)] [human_partner] пощечину!"))

				if(BODY_ZONE_PRECISE_GROIN)
					human_user.custom_emote(message = span_danger("шлёпа[PLUR_ET_YUT(human_user)] [human_partner] по заднице!"))

				if(BODY_ZONE_PRECISE_MOUTH)
					human_user.custom_emote(message = span_danger("да[PLUR_ET_YUT(human_user)] [human_partner] по губе!"))

				else
					return

			if(targeted_organ.brute_dam < 5)
				human_partner.apply_damage(1, def_zone = targeted_organ)

			playsound(loc, 'sound/effects/snap.ogg', 50, TRUE, -1)
			human_user.do_attack_animation(human_partner)
// MARK: MIDDLE FINGER
		if("fuckyou")
			if(HAS_TRAIT(human_user, TRAIT_HANDS_BLOCKED))
				return

			human_user.custom_emote(message = span_danger("показыва[PLUR_ET_YUT(human_user)] [human_partner] средний палец!"))
// MARK: KNOCK
		if("knock")
			if(HAS_TRAIT(human_user, TRAIT_HANDS_BLOCKED) || !human_partner.Adjacent(human_user.loc))
				return

			var/obj/item/organ/external/head/head = human_partner.get_organ(BODY_ZONE_HEAD)
			if(!head)
				return

			if(head.brute_dam < 5)
				human_partner.apply_damage(1, def_zone = head)

			human_user.custom_emote(message = span_danger("да[PLUR_ET_YUT(human_user)] [human_partner] подзатыльник!"))
			playsound(loc, 'sound/weapons/throwtap.ogg', 50, TRUE, -1)
			human_user.do_attack_animation(human_partner)
// MARK: SPIT
		if("spit")
			if(!human_partner.Adjacent(human_user.loc) || !get_location_accessible(human_user, BODY_ZONE_PRECISE_MOUTH))
				return

			human_user.custom_emote(message = span_danger("плю[PLUR_YOT_YUT(human_user)] в [human_partner]!"))

			if(prob(20))
				human_partner.AdjustEyeBlurry(3 SECONDS)
// MARK: THREATER
		if("threaten")
			if(HAS_TRAIT(human_user, TRAIT_HANDS_BLOCKED))
				return

			human_user.custom_emote(message = span_danger("гроз[PLUR_IT_YAT(human_user)] [human_partner] кулаком!"))
// MARK: STUCK THE TONGUE
		if("tongue")
			if(!get_location_accessible(human_user, BODY_ZONE_PRECISE_MOUTH))
				return

			human_user.custom_emote(message = span_danger("показыва[PLUR_ET_YUT(human_user)] [human_partner] язык!"))
// MARK: PULL WING
		if("pullwing")
			if(HAS_TRAIT(human_user, TRAIT_HANDS_BLOCKED) || !human_partner.Adjacent(human_user.loc))
				return

			var/obj/item/organ/external/wing/wing = human_partner.get_organ(BODY_ZONE_WING)
			if(!wing)
				human_user.custom_emote(message = "пыта[PLUR_ET_YUT(human_user)]ся поймать [human_partner] за крылья, [span_danger("КОТОРЫХ НЕТ!!!")]")
				return

			if(!prob(30))
				human_user.custom_emote(message = "пыта[PLUR_ET_YUT(human_user)]ся поймать [human_partner] за крылья!")
				return

			if((wing.is_dead() || wing.has_fracture()) && prob(20))
				human_user.custom_emote(message = span_danger("отрыва[PLUR_ET_YUT(human_user)] [human_partner] крылья!"))
				wing.droplimb()
				return

			if(wing.brute_dam < 10)
				human_partner.apply_damage(1, def_zone = wing)

			human_user.custom_emote(message = span_danger("дёрга[PLUR_ET_YUT(human_user)] [human_partner] за крылья!"))
// MARK: PULL TAIL
		if("pull")
			if(HAS_TRAIT(human_user, TRAIT_HANDS_BLOCKED) || !human_partner.Adjacent(human_user.loc))
				return

			var/obj/item/organ/external/tail/tail = human_partner.get_organ(BODY_ZONE_TAIL)
			if(!tail)
				human_user.custom_emote(message = "пыта[PLUR_ET_YUT(human_user)]ся поймать [human_partner] за хвост, [span_danger("КОТОРОГО НЕТ!!!")]")
				return

			var/obj/item/organ/internal/cyberimp/tail/blade/implant = human_partner.get_organ_slot(INTERNAL_ORGAN_TAIL_DEVICE)
			if(istype(implant) && implant.activated)  // KEEP YOUR HANDS AWAY FROM ME!
				if(human_user.has_pain())
					human_user.emote("scream")

				human_user.custom_emote(message = span_danger("пыта[PLUR_ET_YUT(human_user)]ся дёрнуть [human_partner] за хвост, но резко одёргива[PLUR_ET_YUT(human_user)] руки!"))
				human_user.apply_damage(5, implant.damage_type, BODY_ZONE_PRECISE_R_HAND)
				human_user.apply_damage(5, implant.damage_type, BODY_ZONE_PRECISE_L_HAND)
				return

			if(prob(70))
				human_user.custom_emote(message = "пыта[PLUR_ET_YUT(human_user)]ся поймать [human_partner] за хвост!")
				return

			if((tail.is_dead() || tail.has_fracture()) && prob(20))
				human_user.custom_emote(message = span_danger("отрыва[PLUR_ET_YUT(human_user)] [human_partner] хвост!"))
				tail.droplimb()
				return

			if(tail.brute_dam < 10)
				human_partner.apply_damage(1, def_zone = tail)

			human_user.custom_emote(message = span_danger("дёрга[PLUR_ET_YUT(human_user)] [human_partner] за хвост!"))
// MARK: BITE
		if("bite")
			if(!HAS_TRAIT(human_user, TRAIT_CAN_BITE))
				to_chat(human_user, span_warning("Ваши зубы не предназначены для укусов!"))
				return

			if(human_user.incapacitated())
				return

			if(!human_partner || !human_user.Adjacent(human_partner))
				return

			if(!get_location_accessible(human_user, BODY_ZONE_PRECISE_MOUTH))
				return

			var/target_zone = human_user.zone_selected
			if(target_zone == BODY_ZONE_PRECISE_GROIN)
				return

			human_user.face_atom(human_partner)
			var/armor_value = human_partner.getarmor(target_zone, MELEE)
			if(armor_value > 20)
				human_user.custom_emote(message = span_danger("удар[PLUR_ET_YUT(human_user)]ся зубами об броню [human_partner]!"))
				human_user.Confused(5 SECONDS)
				human_user.Knockdown(1 SECONDS)
				human_user.apply_damage(2, BRUTE, BODY_ZONE_HEAD)
				playsound(human_user.loc, 'sound/effects/grillehit.ogg', 50, TRUE, -1)
				var/dir_off = get_dir(human_user, human_partner)
				animate(human_user, pixel_x = human_user.pixel_x + (dir_off & EAST ? 4 : -4), time = 1)
				animate(pixel_x = human_user.base_pixel_x + human_user.body_position_pixel_x_offset, time = 2)
				return

			human_user.custom_emote(message = span_danger("куса[PLUR_ET_YUT(human_user)] [human_partner]!"))
			var/interaction_dir = get_dir(human_user, human_partner)
			var/offset_x = 0
			var/offset_y = 0
			if(interaction_dir & NORTH)
				offset_y = 12
			else if(interaction_dir & SOUTH)
				offset_y = -12

			if(interaction_dir & EAST)
				offset_x = 12
			else if(interaction_dir & WEST)
				offset_x = -12

			animate(human_user, pixel_x = human_user.pixel_x + offset_x, pixel_y = human_user.pixel_y + offset_y, time = 1, easing = BACK_EASING)
			animate(pixel_x = human_user.base_pixel_x + human_user.body_position_pixel_x_offset, pixel_y = human_user.base_pixel_y + human_user.body_position_pixel_y_offset, time = 4, easing = SINE_EASING)
			var/damage_amount = (target_zone == BODY_ZONE_HEAD) ? 8 : 5
			human_partner.apply_damage(damage_amount, BRUTE, target_zone, sharp = TRUE)
			human_user.do_item_attack_animation(human_partner, ATTACK_EFFECT_BITE)
			playsound(human_user.loc, 'sound/weapons/bite.ogg', 50, TRUE, -1)
