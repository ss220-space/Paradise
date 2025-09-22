/obj/item/mod/skin_applier
	name = "MOD skin applier"
	desc = "Этот одноразовый комплект для покраски позволяет перекрасить модульный экзо-костюм. Этот комплект можно применить только к гражданским костюмам."
	icon = 'icons/obj/clothing/modsuit/mod_construction.dmi'
	icon_state = "skinapplier"
	var/skin = "civilian"
	var/make_spaceproof = FALSE //Used on the miner asteroid skin to make the suit spaceproof when upgrading.
	var/compatible_theme = /datum/mod_theme

/obj/item/mod/skin_applier/get_ru_names()
	return list(
		NOMINATIVE = "комплект покраски для МЭК",
		GENITIVE = "комплекта покраски для МЭК",
		DATIVE = "комплекту покраски для МЭК",
		ACCUSATIVE = "комплект покраски для МЭК",
		INSTRUMENTAL = "комплектом покраски для МЭК",
		PREPOSITIONAL = "комплекте покраски для МЭК"
	)

/obj/item/mod/skin_applier/pre_attackby(atom/attacked_atom, mob/living/user, params)
	if(!ismodcontrol(attacked_atom))
		return ..()
	var/obj/item/mod/control/mod = attacked_atom
	if(mod.active || mod.activating)
		balloon_alert(user, "сначала выключите костюм!")
		return TRUE
	if(!istype(mod.theme, compatible_theme))
		balloon_alert(user, "несовместимый тип костюма!")
		return TRUE
	mod.theme.set_skin(mod, skin)
	if(make_spaceproof)
		mod.min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
		for(var/obj/item/clothing/C in mod.mod.get_parts())
			C.min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	balloon_alert(user, "успешно перекрашено!")
	qdel(src)
	return TRUE

/obj/item/mod/skin_applier/asteroid
	skin = "asteroid"
	compatible_theme = /datum/mod_theme/mining
	desc = "Этот одноразовый комплект для покраски позволяет перекрасить модульный костюм. Этот тип подходит исключительно для шахтерских костюмов и делает их пригодными для космоса."
	make_spaceproof = TRUE

/obj/item/mod/skin_applier/corpsman
	skin = "corpsman"
	compatible_theme = /datum/mod_theme/medical
	desc = "Этот одноразовый комплект для покраски позволяет перекрасить модульный костюм. Этот тип подходит исключительно для медицинских костюмов."
