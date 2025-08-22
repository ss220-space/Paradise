/obj/item/mod/skin_applier
	name = "MOD skin applier"
	desc = "Этот одноразовый комплект для покраски позволяет перекрасить модульный костюм. Этот комплект можно применить только к гражданским костюмам."
	icon = 'icons/obj/clothing/modsuit/mod_construction.dmi'
	icon_state = "skinapplier"
	var/skin = "civilian"
	var/make_spaceproof = FALSE //Used on the miner asteroid skin to make the suit spaceproof when upgrading.
	var/compatible_theme = /datum/mod_theme/standard

/obj/item/mod/skin_applier/get_ru_names()
	return list(
		NOMINATIVE = "комплект покраски для модульного костюма",
		GENITIVE = "комплекта покраски для модульного костюма",
		DATIVE = "комплекту покраски для модульного костюма",
		ACCUSATIVE = "комплект покраски для модульного костюма",
		INSTRUMENTAL = "комплектом покраски для модульного костюма",
		PREPOSITIONAL = "комплекте покраски для модульного костюма"
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
	mod.set_mod_skin(skin)
	if(make_spaceproof)
		mod.min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
		for(var/obj/item/clothing/C in mod.mod_parts)
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
