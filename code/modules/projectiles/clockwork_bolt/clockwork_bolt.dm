/obj/item/clockwork_bolt
	name = "clockwork bolt"
	desc = "Древний механизм из часового металла, пульсирующий тусклым оранжевым светом. При установке на оружие позволяет использовать его только слугам Ратвара."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clock_pointer"
	w_class = WEIGHT_CLASS_TINY

	var/obj/item/gun/weapon = null
	var/state = CLOCKWORK_BOLT_STATE_UNINSTALLED

/obj/item/clockwork_bolt/Initialize(mapload)
	. = ..()
	enchants = GLOB.gun_and_heart_spells

/obj/item/clockwork_bolt/get_ru_names()
	return list(
		NOMINATIVE = "часовой затвор",
		GENITIVE = "часового затвора",
		DATIVE = "часовому затвору",
		ACCUSATIVE = "часовой затвор",
		INSTRUMENTAL = "часовым затвором",
		PREPOSITIONAL = "часовом затворе"
	)

/obj/item/clockwork_bolt/examine(mob/user)
	. = ..()
	if(state == CLOCKWORK_BOLT_STATE_INSTALLED && weapon)
		. += span_clock("Затвор синхронизирован с оружием. Слышен тихий тикающий звук.")
		. += span_clock("Только избранные Ратваром могут использовать это оружие.")

/obj/item/clockwork_bolt/proc/install(obj/item/gun/W, mob/user = null)
	if(!W)
		return FALSE

	if(istype(W, /obj/item/gun/energy))
		var/obj/item/gun/energy/E = W
		if(E.sibyl_mod)
			var/obj/item/sibyl_system_mod/sibyl = E.sibyl_mod
			sibyl.uninstall(W)
			qdel(sibyl)

	if(user)
		if(!user.drop_transfer_item_to_loc(src, W))
			return FALSE
	else
		forceMove(W)

	weapon = W
	W.clockwork_bolt = src
	state = CLOCKWORK_BOLT_STATE_INSTALLED

	W.needs_permit = FALSE

	if(istype(W, /obj/item/gun/energy))
		var/obj/item/gun/energy/E = W
		E.isclockwork = TRUE

	W.update_icon()

	if(user)
		to_chat(user, span_clock("Вы установили [DECLENT_RU_CAP(src, ACCUSATIVE)] на [DECLENT_RU_CAP(W, ACCUSATIVE)]. Теперь только слуги Ратвара могут использовать это оружие."))

	return TRUE

/obj/item/clockwork_bolt/proc/uninstall(obj/item/gun/W, mob/user = null)
	if(!weapon)
		return 0

	forceMove(get_turf(src))

	state = 0
	W.clockwork_bolt = null

	if(istype(W, /obj/item/gun/energy))
		var/obj/item/gun/energy/E = W
		E.isclockwork = FALSE

	W.update_icon()
	weapon = null

	if(user)
		to_chat(user, span_notice("Вы сняли [DECLENT_RU_CAP(src, ACCUSATIVE)] с [DECLENT_RU_CAP(W, GENITIVE)]."))

	return state

/obj/item/clockwork_bolt/screwdriver_act(mob/living/user, obj/item/I)
	if(!weapon)
		return

	if(state == CLOCKWORK_BOLT_STATE_SCREWDRIVER_ACT)
		state = CLOCKWORK_BOLT_STATE_INSTALLED
		to_chat(user, span_notice("Вы закрутили винты [DECLENT_RU_CAP(src, GENITIVE)] в [DECLENT_RU_CAP(weapon, PREPOSITIONAL)]."))
		return

	if(state == CLOCKWORK_BOLT_STATE_INSTALLED)
		to_chat(user, span_notice("Вы начинаете откручивать винты [DECLENT_RU_CAP(src, GENITIVE)] от [DECLENT_RU_CAP(weapon, GENITIVE)]..."))
		if(I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume))
			if(prob(90))
				state = CLOCKWORK_BOLT_STATE_SCREWDRIVER_ACT
				to_chat(user, span_notice("Вы открутили винты [DECLENT_RU_CAP(src, GENITIVE)]."))
			else
				var/mob/living/carbon/human/H = user
				var/obj/item/organ/external/affecting = H.get_organ(user.r_hand == I ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
				user.apply_damage(5, BRUTE, affecting)
				user.emote("scream")
				to_chat(user, span_warning("Проклятье! [capitalize(DECLENT_RU_CAP(I, NOMINATIVE))] сорвалась и повредила [affecting.name]!"))
		return

/obj/item/clockwork_bolt/welder_act(mob/living/user, obj/item/I)
	if(!weapon || state != CLOCKWORK_BOLT_STATE_SCREWDRIVER_ACT)
		return

	to_chat(user, span_notice("Вы начинаете заваривать болты [DECLENT_RU_CAP(src, GENITIVE)] в [DECLENT_RU_CAP(weapon, PREPOSITIONAL)]..."))
	if(I.use_tool(src, user, 4 SECONDS, volume = I.tool_volume))
		state = CLOCKWORK_BOLT_STATE_INSTALLED
		to_chat(user, span_notice("Болты [DECLENT_RU_CAP(src, GENITIVE)] заварены. Теперь только слуги Ратвара могут использовать это оружие."))

/obj/item/clockwork_bolt/crowbar_act(mob/living/user, obj/item/I)
	if(!weapon || state != CLOCKWORK_BOLT_STATE_INSTALLED)
		return

	to_chat(user, span_notice("Вы начинаете поддевать [DECLENT_RU_CAP(src, ACCUSATIVE)] из [DECLENT_RU_CAP(weapon, GENITIVE)]..."))
	if(!I.use_tool(src, user, 4 SECONDS, volume = I.tool_volume))
		return

	if(prob(95))
		uninstall(weapon, user)
		to_chat(user, span_notice("Вы успешно сняли [DECLENT_RU_CAP(src, ACCUSATIVE)]."))
	else
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/affecting = H.get_organ(user.r_hand == I ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
		user.apply_damage(5, BRUTE, affecting)
		user.emote("scream")
		to_chat(user, span_warning("Проклятье! [capitalize(DECLENT_RU_CAP(I, NOMINATIVE))] соскользнула и повредила [affecting.name]!"))

/obj/item/clockwork_bolt/Destroy()
	if(weapon)
		uninstall(weapon)
	weapon = null
	return ..()
