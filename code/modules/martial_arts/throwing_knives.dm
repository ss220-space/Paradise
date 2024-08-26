/datum/martial_art/throwing
	name = "Knife techniques"
	weight = 6
	combos = list(/datum/martial_combo/throwing/remove_embended)
	block_chance = 50	//if holding knife in hand
	has_explaination_verb = TRUE
	var/list/knife_types = list(
		/obj/item/kitchen/knife,
		/obj/item/kitchen/knife/combat,
		/obj/item/kitchen/knife/combat/survival,
		/obj/item/kitchen/knife/combat/survival/bone,
		/obj/item/kitchen/knife/combat/throwing,
		/obj/item/kitchen/knife/butcher,
		/obj/item/kitchen/knife/butcher/meatcleaver,
		/obj/item/kitchen/knife/carrotshiv,
		/obj/item/kitchen/knife/glassshiv,
		/obj/item/kitchen/knife/glassshiv/plasma
	)
	var/knife_embed_chance = 100
	var/knife_bonus_damage = 5
	var/shields_penetration_bonus = 50
	var/neck_cut_delay = 2 SECONDS
	var/neck_cut_in_progress = FALSE

/datum/martial_art/throwing/attack_reaction(mob/living/carbon/human/defender, mob/living/carbon/human/attacker, obj/item/I, visible_message, self_message)
	if(can_use(defender)	\
	&& !defender.incapacitated(INC_IGNORE_GRABBED)	\
	&& (is_type_in_list(defender.get_active_hand(), knife_types, FALSE) || is_type_in_list(defender.get_inactive_hand(), knife_types, FALSE))	\
	&& prob(block_chance))
		if(visible_message || self_message)
			defender.visible_message(visible_message, self_message)
		else
			defender.visible_message(span_warning("[defender] blocks [I]!"))
		return TRUE

/datum/martial_art/throwing/user_hit_by(atom/movable/AM, mob/living/carbon/human/H)
	if(is_type_in_list(AM, knife_types, FALSE))
		H.put_in_hands(AM)
		H.visible_message(span_warning("[H] catches [AM]!"))
		return TRUE
	return FALSE

/datum/martial_art/throwing/proc/neck_cut(mob/living/carbon/human/defender, mob/living/carbon/human/attacker)
	if(!neck_cut_in_progress && attacker.pulling && attacker.pulling == defender && attacker.grab_state >= GRAB_NECK && defender.dna && !HAS_TRAIT(defender, TRAIT_NO_BLOOD))
		attacker.visible_message(span_danger("[attacker] прикладывает нож к горлу [defender]!"), span_danger("Вы прикладываете нож к горлу [defender]!."))
		neck_cut_in_progress = TRUE
		if(do_after(attacker, neck_cut_delay, defender) && attacker.pulling == defender && attacker.grab_state >= GRAB_NECK)
			if(defender.blood_volume > BLOOD_VOLUME_SURVIVE)
				defender.blood_volume = max(0, defender.blood_volume - (BLOOD_VOLUME_NORMAL - BLOOD_VOLUME_SURVIVE)) //-70% of max blood volume
				for(var/i in 1 to 2)
					var/obj/effect/decal/cleanable/blood/B = new(defender.loc)
					B.blood_DNA[defender.dna.unique_enzymes] = defender.dna.blood_type
					step(B, pick(GLOB.alldirs))
			attacker.stop_pulling()
			var/sound = pick('sound/weapons/knife_holster/throat_slice.ogg','sound/weapons/knife_holster/throat_slice2.ogg')
			playsound(defender.loc, sound, 25, TRUE)
			attacker.visible_message(span_danger("[attacker] перерезает глотку [defender]!"), span_danger("Вы перерезаете глотку [defender]!"))
			neck_cut_in_progress = FALSE
			return TRUE
		else
			neck_cut_in_progress = FALSE
	return FALSE

/datum/martial_art/throwing/explaination_footer(user)
	to_chat(user, "[span_notice("Работает с ножами")]: Боевой, шахтёрский, костяной, метательный, кухонный, тесак, заточка из стекла, заточка из морковки")
	to_chat(user, "[span_notice("Урон")]: +5 урона от бросков и ударов ножей")
	to_chat(user, "[span_notice("Застревание")]: Ножи застревают в жертве со 100% вероятностью")
	to_chat(user, "[span_notice("Блок")]: 50% блока мили атак, пока в руках есть нож")
	to_chat(user, "[span_notice("Поймать нож")]: Вы ловите все кинутые в вас ножи")
	to_chat(user, "[span_notice("Перерезать глотку")]: Схватите жертву в красный захват и ударьте её ножом в харме в голову, чтобы перерезать ей глотку, уменьшив её уровень крови на 70%")
