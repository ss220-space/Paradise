/datum/clockwork_bolt_module
	var/obj/item/clockwork_bolt/owner_item
	var/obj/item/gun/weapon
	var/state = CLOCKWORK_BOLT_STATE_UNINSTALLED

/datum/clockwork_bolt_module/New(obj/item/clockwork_bolt/item)
	owner_item = item

/datum/clockwork_bolt_module/proc/deplete_spell()
	if(weapon)
		weapon.clockwork_enchant = NO_SPELL

/datum/clockwork_bolt_module/proc/install(obj/item/gun/W, mob/user = null)
	if(!W)
		return FALSE

	if(istype(W, /obj/item/gun/energy/clockwork))
		return FALSE

	if(istype(W, /obj/item/gun/energy))
		var/obj/item/gun/energy/E = W
		if(E.sibyl_mod)
			var/obj/item/sibyl_system_mod/sibyl = E.sibyl_mod
			sibyl.uninstall(W)
			qdel(sibyl)

	if(user)
		if(!user.drop_transfer_item_to_loc(owner_item, W))
			return FALSE
	else
		owner_item.forceMove(W)

	weapon = W
	W.clockwork_bolt = owner_item
	state = CLOCKWORK_BOLT_STATE_INSTALLED

	W.needs_permit = FALSE

	if(istype(W, /obj/item/gun/energy))
		var/obj/item/gun/energy/E = W
		E.isclockwork = TRUE

	if(user)
		to_chat(user, span_clock("Вы установили [DECLENT_RU_CAP(owner_item, ACCUSATIVE)] на [DECLENT_RU_CAP(W, ACCUSATIVE)]. Теперь только слуги Ратвара могут использовать это оружие."))

	return TRUE

/datum/clockwork_bolt_module/proc/uninstall(obj/item/gun/W, mob/user = null)
	if(!weapon)
		return 0

	if(W.clockwork_enchant && W.clockwork_enchant != NO_SPELL)
		W.clockwork_enchant = NO_SPELL

	owner_item.forceMove(get_turf(owner_item))

	state = CLOCKWORK_BOLT_STATE_UNINSTALLED
	W.clockwork_bolt = null

	if(istype(W, /obj/item/gun/energy))
		var/obj/item/gun/energy/E = W
		E.isclockwork = FALSE

	W.update_icon()
	weapon = null

	if(user)
		to_chat(user, span_notice("Вы сняли [DECLENT_RU_CAP(owner_item, ACCUSATIVE)] с [DECLENT_RU_CAP(W, GENITIVE)]."))

	return state

/datum/clockwork_bolt_module/proc/bible_removal(mob/living/user)
	to_chat(user, span_notice("Вы начинаете изгонять скверну из [DECLENT_RU_CAP(weapon, GENITIVE)]..."))
	if(!do_after(user, 5 SECONDS, weapon))
		return

	if(!weapon || !weapon.clockwork_bolt)
		to_chat(user, span_warning("Затвор уже снят!"))
		return

	uninstall(weapon, user)
	to_chat(user, span_notice("Скверна изгнана! [DECLENT_RU_CAP(owner_item, NOMINATIVE)] падает на пол."))

	if(prob(2))
		playsound(user.loc, 'sound/magic/cult_spell.ogg', 100, TRUE)
	else
		playsound(user.loc, 'sound/weapons/magic.ogg', 50, TRUE)

/datum/clockwork_bolt_module/proc/handle_attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/storage/bible) && weapon)
		if(user.mind && user.mind.isholy)
			bible_removal(user)
			return ATTACK_CHAIN_BLOCKED_ALL
	return ATTACK_CHAIN_PROCEED

/datum/clockwork_bolt_module/proc/handle_screwdriver(mob/living/user, obj/item/I)
	if(!weapon)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(state == CLOCKWORK_BOLT_STATE_WELDER_ACT)
		to_chat(user, span_warning("Здесь всё в кашу — невозможно закрутить винты."))
		return ATTACK_CHAIN_BLOCKED_ALL

	if(state == CLOCKWORK_BOLT_STATE_SCREWDRIVER_ACT)
		to_chat(user, span_notice("Вы начинаете закручивать винты [DECLENT_RU_CAP(owner_item, GENITIVE)] обратно в [DECLENT_RU_CAP(weapon, PREPOSITIONAL)]..."))
		playsound(user.loc, 'sound/items/screwdriver.ogg', 50, TRUE)
		if(!do_after(user, 2 SECONDS, weapon))
			return ATTACK_CHAIN_BLOCKED_ALL
		playsound(user.loc, 'sound/items/screwdriver.ogg', 50, TRUE)
		state = CLOCKWORK_BOLT_STATE_INSTALLED
		to_chat(user, span_notice("Вы закрутили винты [DECLENT_RU_CAP(owner_item, GENITIVE)] обратно в [DECLENT_RU_CAP(weapon, PREPOSITIONAL)]."))
		return ATTACK_CHAIN_BLOCKED_ALL

	if(state == CLOCKWORK_BOLT_STATE_INSTALLED)
		to_chat(user, span_notice("Вы начинаете откручивать винты [DECLENT_RU_CAP(owner_item, GENITIVE)] от [DECLENT_RU_CAP(weapon, GENITIVE)]..."))
		playsound(user.loc, 'sound/items/screwdriver.ogg', 50, TRUE)
		if(!do_after(user, 2 SECONDS, weapon))
			return ATTACK_CHAIN_BLOCKED_ALL
		playsound(user.loc, 'sound/items/screwdriver.ogg', 50, TRUE)
		if(prob(90))
			state = CLOCKWORK_BOLT_STATE_SCREWDRIVER_ACT
			to_chat(user, span_notice("Вы открутили винты [DECLENT_RU_CAP(owner_item, GENITIVE)]."))
		else
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				var/obj/item/organ/external/affecting = H.get_organ(user.r_hand == I ? BODY_ZONE_PRECISE_R_HAND : BODY_ZONE_PRECISE_L_HAND)
				user.apply_damage(5, BRUTE, affecting)
				user.emote("scream")
				to_chat(user, span_warning("Проклятье! [capitalize(DECLENT_RU_CAP(I, NOMINATIVE))] сорвалась и повредила [affecting.name]!"))
			else
				user.apply_damage(5, BRUTE)
				user.emote("scream")
				to_chat(user, span_warning("Проклятье! [capitalize(DECLENT_RU_CAP(I, NOMINATIVE))] сорвалась и повредила вам руку!"))
		return ATTACK_CHAIN_BLOCKED_ALL

/datum/clockwork_bolt_module/proc/handle_welder(mob/living/user, obj/item/I)
	if(!weapon)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(state == CLOCKWORK_BOLT_STATE_WELDER_ACT)
		to_chat(user, span_warning("Здесь всё в кашу — невозможно заварить."))
		return ATTACK_CHAIN_BLOCKED_ALL

	if(state != CLOCKWORK_BOLT_STATE_SCREWDRIVER_ACT)
		return ATTACK_CHAIN_BLOCKED_ALL

	to_chat(user, span_notice("Вы начинаете расплавлять защиту [DECLENT_RU_CAP(owner_item, GENITIVE)] в [DECLENT_RU_CAP(weapon, PREPOSITIONAL)]..."))
	playsound(user.loc, 'sound/items/welder.ogg', 100, TRUE)
	if(!do_after(user, 4 SECONDS, weapon))
		return ATTACK_CHAIN_BLOCKED_ALL
	playsound(user.loc, 'sound/items/welder.ogg', 100, TRUE)
	state = CLOCKWORK_BOLT_STATE_WELDER_ACT
	to_chat(user, span_notice("Защита расплавлена! Теперь можно извлечь [DECLENT_RU_CAP(owner_item, ACCUSATIVE)]."))
	return ATTACK_CHAIN_BLOCKED_ALL

/datum/clockwork_bolt_module/proc/handle_crowbar(mob/living/user, obj/item/I)
	if(!weapon || state != CLOCKWORK_BOLT_STATE_WELDER_ACT)
		return ATTACK_CHAIN_BLOCKED_ALL

	to_chat(user, span_notice("Вы начинаете поддевать [DECLENT_RU_CAP(owner_item, ACCUSATIVE)] из [DECLENT_RU_CAP(weapon, GENITIVE)]..."))
	playsound(user.loc, 'sound/items/crowbar.ogg', 50, TRUE)
	if(!do_after(user, 4 SECONDS, weapon))
		return ATTACK_CHAIN_BLOCKED_ALL
	playsound(user.loc, 'sound/items/crowbar.ogg', 50, TRUE)

	if(prob(95))
		uninstall(weapon, user)
		to_chat(user, span_notice("Вы успешно сняли [DECLENT_RU_CAP(owner_item, ACCUSATIVE)]."))
	else
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			var/obj/item/organ/external/affecting = H.get_organ(user.r_hand == I ? BODY_ZONE_PRECISE_R_HAND : BODY_ZONE_PRECISE_L_HAND)
			user.apply_damage(5, BRUTE, affecting)
			user.emote("scream")
			to_chat(user, span_warning("Проклятье! [capitalize(DECLENT_RU_CAP(I, NOMINATIVE))] соскользнула и повредила [affecting.name]!"))
		else
			user.apply_damage(5, BRUTE)
			user.emote("scream")
			to_chat(user, span_warning("Проклятье! [capitalize(DECLENT_RU_CAP(I, NOMINATIVE))] соскользнула и повредила вам руку!"))
	return ATTACK_CHAIN_BLOCKED_ALL

/datum/clockwork_bolt_module/Destroy()
	if(weapon && !QDELETED(weapon))
		weapon.clockwork_bolt = null
	weapon = null
	owner_item = null
	return ..()
