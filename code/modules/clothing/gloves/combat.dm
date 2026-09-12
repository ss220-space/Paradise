/obj/item/clothing/gloves/combat
	name = "combat gloves"
	desc = "These tactical gloves are both insulated and offer melee protection."
	icon_state = "combat"
	item_state = "swat_gl"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	strip_delay = 80
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list(MELEE = 25, BULLET = 5, LASER = 5, ENERGY = 10, BOMB = 10, BIO = 0, FIRE = 70, ACID = 70)

/obj/item/clothing/gloves/combat/riot
	name = "riot gloves"
	desc = "These riot gloves are both insulated and offer melee protection."
	icon_state = "riotgloves"
	item_state = "riotgloves"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/gloves.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/gloves.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/gloves.dmi',
	)

/obj/item/clothing/gloves/combat/swat
	desc = "A pair of gloves made of the best reinforced materials. Protects against the effects of electricity, as well as partially acid and fire. Such gloves cost a fortune, you can say that wearing them, you literally have golden hands!"
	name = "SWAT gloves"
	icon_state = "swat_gloves"
	item_state = "nt_swat_gl"
	armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 15, BIO = 0, FIRE = 75, ACID = 75)
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/gloves.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/gloves.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/gloves.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/gloves.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/gloves.dmi',
	)

/obj/item/clothing/gloves/combat/swat/syndicate
	desc = "A pair of gloves made of the best reinforced materials. Protects against the effects of electricity, as well as partially acid and fire. Show these NT pigs on your fingers who's the boss here!"
	name = "syndicate armored gloves"
	icon_state = "syndicate_swat"
	item_state = "syndicate_swat_gl"

/obj/item/clothing/gloves/color/black/razorgloves
	name = "Razor gloves"
	desc = "These are razorgloves! You gotta show these tajarans who are the real deal on this station!"
	icon_state = "razor"
	item_state = "razorgloves"
	can_be_cut = FALSE
	resistance_flags = FLAMMABLE
	sharp = TRUE
	extra_knock_chance = 5
	var/razor_damage_low = 8
	var/razor_damage_high = 9

/obj/item/clothing/gloves/color/black/razorgloves/sharpen_act(obj/item/whetstone/whetstone, mob/user)
	if(razor_damage_low > initial(razor_damage_low))
		to_chat(user, span_warning("[src] has already been refined before. It cannot be sharpened further!"))
		return FALSE
	razor_damage_low = clamp(razor_damage_low + whetstone.increment, 0, whetstone.max)
	razor_damage_high = clamp(razor_damage_high + whetstone.increment, 0, whetstone.max)
	return TRUE

/obj/item/clothing/gloves/color/black/razorgloves/Touch(atom/A, proximity)
	. = FALSE
	if(!ishuman(loc))
		return FALSE

	var/mob/living/carbon/human/user = loc
	if(!user.mind || user.mind.martial_art)
		return FALSE

	if(!(user.a_intent == INTENT_HARM) || !proximity || isturf(A))
		return FALSE

	var/damage = rand(razor_damage_low, razor_damage_high)
	if(ishuman(A))
		user.do_attack_animation(A, "claw")
		var/mob/living/carbon/human/target = A
		add_attack_logs(user, target, "Melee attacked with razor gloves")
		var/obj/item/organ/external/affecting = target.get_organ(ran_zone(user.zone_selected))
		var/armor_block = target.run_armor_check(affecting, MELEE)
		playsound(target.loc, 'sound/weapons/slice.ogg', 25, TRUE, -1)

		target.visible_message(span_danger("[user] cuts [target] with razor gloves!"))

		var/all_objectives = user?.mind?.get_all_objectives()
		if(target.mind && all_objectives)
			for(var/datum/objective/pain_hunter/objective in all_objectives)
				if(target.mind == objective.target)
					objective.take_damage(damage, BRUTE)

		target.apply_damage(damage, BRUTE, affecting, armor_block, sharp = TRUE)
		return TRUE

	if(isliving(A))
		user.do_attack_animation(A, "claw")
		var/mob/living/living = A
		playsound(living.loc, 'sound/weapons/slice.ogg', 25, TRUE, -1)
		living.visible_message(span_danger("[user] cuts [living] with razor gloves!"))
		living.apply_damage(damage, BRUTE)
		return TRUE

	if(isobj(A) && !isitem(A))
		var/obj/obj = A
		user.do_attack_animation(A, "claw")
		user.changeNext_move(CLICK_CD_MELEE)
		user.visible_message(span_danger("[user] has hit [obj] with razor gloves!"), span_danger("You hit [obj] with razor gloves!"))
		obj.take_damage(damage, BRUTE, MELEE, 1, get_dir(src, user))
		return TRUE

/obj/item/clothing/gloves/knuckles
	name = "knuckles"
	desc = "The choice of the professional to beat the shit out of some jerk!"
	icon_state = "knuckles"
	item_state = "knuckles"
	extra_knock_chance = 15 //20% overall
	var/knuckle_damage = 5 //additional fists damage
	var/knock_damage_low = 5 // stamina damage
	var/knock_damage_high = 10 // min and max
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 100, ACID = 0)
	sprite_sheets = list(
		SPECIES_GREY = 'icons/mob/clothing/species/grey/gloves.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/gloves.dmi')

/obj/item/clothing/gloves/knuckles/Touch(atom/A, proximity)
	. = FALSE
	if(!ishuman(loc))
		return FALSE

	var/mob/living/carbon/human/user = loc
	if(!user.mind || user.mind.martial_art)
		return FALSE

	if(!(user.a_intent == INTENT_HARM) || !proximity || isturf(A))
		return FALSE

	var/damage = knuckle_damage + rand(user.dna.species.punchdamagelow + user.physiology.punch_damage_low, user.dna.species.punchdamagehigh + user.physiology.punch_damage_high)
	var/staminadamage = rand(knock_damage_low, knock_damage_high)
	var/knobj_damage = knuckle_damage + user.dna.species.obj_damage + user.physiology.punch_obj_damage
	if(ishuman(A))
		user.do_attack_animation(A, "kick")
		playsound(get_turf(user), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
		var/mob/living/carbon/human/target = A
		add_attack_logs(user, target, "Melee attacked with knuckles")
		var/obj/item/organ/external/affecting = target.get_organ(ran_zone(user.zone_selected))

		target.visible_message(span_danger("[user] smash [target] with knuckles!"))

		var/all_objectives = user?.mind?.get_all_objectives()
		if(target.mind && all_objectives)
			for(var/datum/objective/pain_hunter/objective in all_objectives)
				if(target.mind == objective.target)
					objective.take_damage(damage, BRUTE)

		target.apply_damage(damage, BRUTE, affecting)
		target.apply_damage(staminadamage, STAMINA, affecting)
		return TRUE

	if(isliving(A))
		var/mob/living/living = A
		user.do_attack_animation(A, "kick")
		playsound(get_turf(user), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
		living.visible_message(span_danger("[user] smash [living] with knuckles!"))
		living.apply_damage(damage, BRUTE)
		return TRUE

	if(isobj(A) && !isitem(A))
		var/obj/obj = A
		user.do_attack_animation(A, "kick")
		user.changeNext_move(CLICK_CD_MELEE)
		user.visible_message(span_danger("[user] has hit [obj] with knuckles!"), span_danger("You hit [obj] with knuckles!"))
		obj.take_damage(knobj_damage, BRUTE, MELEE, 1, get_dir(src, user))
		return TRUE
