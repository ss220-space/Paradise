/datum/martial_art/throwing
	name = "Knife techniques"
	combos = list(/datum/martial_combo/throwing/remove_embended)
	block_chance = 50	//if holding knife in hand
	has_explaination_verb = TRUE
	var/knife_embed_chance = 100
	var/knife_bonus_damage = 5

/datum/martial_art/throwing/attack_reaction(mob/living/carbon/human/defender, mob/living/carbon/human/attacker, obj/item/I, visible_message, self_message)
	if(can_use(defender)	\
	&& !defender.incapacitated(FALSE, TRUE)	\
	&& (istype(defender.get_active_hand(), /obj/item/kitchen/knife/combat) || istype(defender.get_inactive_hand(), /obj/item/kitchen/knife/combat))	\
	&& prob(block_chance))
		if(visible_message || self_message)
			defender.visible_message(visible_message, self_message)
		else
			defender.visible_message(span_warning("[defender] blocks [I]!"))
		return TRUE

/datum/martial_art/throwing/user_hit_by(atom/movable/AM, mob/living/carbon/human/H)
	if(istype(AM, /obj/item/kitchen/knife/combat))
		H.put_in_hands(AM)
		H.visible_message(span_warning("[H] catches [AM]!"))
		return TRUE
	return FALSE

/datum/martial_art/throwing/proc/neck_cut(mob/living/carbon/human/defender, mob/living/carbon/human/attacker)
	var/obj/item/grab/grab = attacker.get_inactive_hand()
	if(istype(grab) && grab.state >= GRAB_NECK && grab.affecting == defender && defender.dna && !(NO_BLOOD in defender.dna.species.species_traits))
		attacker.visible_message(span_danger("[attacker] прикладывает нож к горлу [defender]!"), span_danger("Вы прикладываете нож к горлу [defender]!."))
		if(do_after(attacker, 20, target = defender))
			if(defender.blood_volume > BLOOD_VOLUME_SURVIVE)
				defender.blood_volume -= BLOOD_VOLUME_NORMAL - BLOOD_VOLUME_SURVIVE
				for(var/i in 1 to 2)
					var/obj/effect/decal/cleanable/blood/B = new(defender.loc)
					step(B, pick(GLOB.alldirs))
			if(istype(attacker.l_hand, /obj/item/grab))
				attacker.drop_l_hand()
			else if(istype(attacker.r_hand, /obj/item/grab))
				attacker.drop_r_hand()
			var/sound = pick('sound/weapons/knife_holster/throat_slice.ogg','sound/weapons/knife_holster/throat_slice2.ogg')
			playsound(defender.loc, sound, 25, 1)
			attacker.visible_message(span_danger("[attacker] перерезает глотку [defender]!"), span_danger("Вы перерезаете глотку [defender]!"))

/datum/martial_art/throwing/explaination_footer(user)
	to_chat(user, "[span_notice("Работает с ножами")]: Боевой, шахтёрский, костяной, метательный")
	to_chat(user, "[span_notice("Урон")]: +5 урона от бросков и ударов ножей")
	to_chat(user, "[span_notice("Застревание")]: ножи застревают в жертве со 100% вероятностью")
	to_chat(user, "[span_notice("Блок")]: 50% блока мили атак, пока в руках есть нож")
	to_chat(user, "[span_notice("Поймать нож")]: Вы ловите все кинутые в вас ножи")
	to_chat(user, "[span_notice("Перерезать глотку")]: Атака ножом в харме цели, которая находится в красном грабе уменьшит уровень крови жертвы на 70%")
