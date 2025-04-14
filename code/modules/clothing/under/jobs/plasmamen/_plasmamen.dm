/obj/item/clothing/under/plasmaman
	name = "plasma envirosuit"
	desc = "Специализированный костюм, позволяющий плазменным формам жизни существовать в обогащённой кислородом среде. Внутри установлен экстренный автоматический огнетушитель на случай возгорания. Не подходит для космоса."
	ru_names = list(
		NOMINATIVE = "защитный костюм плазмолюда",
		GENITIVE = "защитного костюма плазмолюда",
		DATIVE = "защитному костюму плазмолюда",
		ACCUSATIVE = "защитный костюм плазмолюда",
		INSTRUMENTAL = "защитным костюмом плазмолюда",
		PREPOSITIONAL = "защитном костюме плазмолюда"
	)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 95, "acid" = 95)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	strip_delay = 200
	var/next_extinguish = 0
	var/extinguish_cooldown = 100
	var/extinguishes_left = 5
	icon = 'icons/obj/clothing/species/plasmaman/uniform.dmi'
	species_restricted = list(SPECIES_PLASMAMAN)
	sprite_sheets = list(SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/uniform.dmi')
	icon_state = "plasmaman"
	item_state = "plasmaman"
	item_color = "plasmaman"
	can_adjust = FALSE

/obj/item/clothing/under/plasmaman/examine(mob/user)
	. = ..()
	. += span_notice("Встроенный огнетушитель имеет [extinguishes_left] заряд[declension_ru(extinguishes_left, "", "а", "ов")].")

/obj/item/clothing/under/plasmaman/proc/Extinguish(mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(H.on_fire)
		if(extinguishes_left)
			if(next_extinguish > world.time)
				return
			next_extinguish = world.time + extinguish_cooldown
			extinguishes_left--
			H.visible_message(
				span_warning("Защитный костюм [H] автоматически тушит [genderize_ru(H.gender, "его", "её", "его", "их")]!"),
				span_warning("Встроенный огнетушитель вашего костюма автоматически тушит вас!")
			)
			if(!extinguishes_left)
				to_chat(H, span_warning("Заряд встроенного огнетушителя израсходован."))
			playsound(H.loc, 'sound/effects/spray.ogg', 10, 1, -3)
			H.ExtinguishMob()
			new /obj/effect/particle_effect/water(get_turf(H))
	return FALSE


/obj/item/clothing/under/plasmaman/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/extinguisher_refill))
		add_fingerprint(user)
		if(extinguishes_left >= 5)
			balloon_alert(user, "заряд огнетушителя полон!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		extinguishes_left = 5
		balloon_alert(user, "заряд огнетушителя пополнен")
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/extinguisher_refill
	name = "envirosuit extinguisher cartridge"
	desc = "Картридж, заполненный противопожарной смесью. Используется для заправки встроенного огнетушителя в защитных костюмах плазмолюдов."
	ru_names = list(
		NOMINATIVE = "картридж пополнения встроенного огнетушителя",
		GENITIVE = "картриджа пополнения встроенного огнетушителя",
		DATIVE = "картриджу пополнения встроенного огнетушителя",
		ACCUSATIVE = "картридж пополнения встроенного огнетушителя",
		INSTRUMENTAL = "картриджем пополнения встроенного огнетушителя",
		PREPOSITIONAL = "картридже пополнения встроенного огнетушителя"
	)
	icon_state = "plasmarefill"
	icon = 'icons/obj/device.dmi'
