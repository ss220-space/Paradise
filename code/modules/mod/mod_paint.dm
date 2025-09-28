/obj/item/mod/skin_applier
	name = "MOD skin applier"
	desc = "Этот одноразовый комплект для покраски позволяет перекрасить модульный экзо-костюм. Этот комплект можно применить только к гражданским костюмам."
	icon = 'icons/obj/clothing/modsuit/mod_construction.dmi'
	icon_state = "skinapplier"
	var/skin = "civilian"
	var/make_spaceproof = FALSE //Used on the miner asteroid skin to make the suit spaceproof when upgrading.
	var/compatible_theme = /datum/mod_theme/civilian

/obj/item/mod/skin_applier/get_ru_names()
	return list(
		NOMINATIVE = "комплект покраски МЭК",
		GENITIVE = "комплекта покраски МЭК",
		DATIVE = "комплекту покраски МЭК",
		ACCUSATIVE = "комплект покраски МЭК",
		INSTRUMENTAL = "комплектом покраски МЭК",
		PREPOSITIONAL = "комплекте покраски МЭК"
	)

/obj/item/mod/skin_applier/pre_attackby(atom/attacked_atom, mob/living/user, params)
	if(!ismodcontrol(attacked_atom))
		return ..()
	var/obj/item/mod/control/mod = attacked_atom
	if(mod.active || mod.activating)
		balloon_alert(user, "сначала выключите костюм!")
		return ATTACK_CHAIN_BLOCKED
	if(!istype(mod.theme, compatible_theme))
		balloon_alert(user, "несовместимый тип костюма!")
		return ATTACK_CHAIN_BLOCKED
	mod.theme.set_skin(mod, skin)
	if(make_spaceproof)
		mod.min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
		for(var/obj/item/clothing/C in mod.get_parts())
			C.min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	balloon_alert(user, "успешно перекрашено!")
	qdel(src)
	return ATTACK_CHAIN_BLOCKED

/obj/item/mod/skin_applier/asteroid
	skin = "asteroid"
	compatible_theme = /datum/mod_theme/mining
	desc = "Этот одноразовый комплект для покраски позволяет перекрасить модульный костюм. Этот тип подходит исключительно для шахтерских костюмов и делает их пригодными для космоса."
	make_spaceproof = TRUE

/obj/item/mod/skin_applier/corpsman
	skin = "corpsman"
	compatible_theme = /datum/mod_theme/medical
	desc = "Этот одноразовый комплект для покраски позволяет перекрасить модульный костюм. Этот тип подходит исключительно для медицинских костюмов."
