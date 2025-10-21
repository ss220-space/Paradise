/obj/item/mod/skin_applier
	name = "MOD skin applier"
	desc = "Этот одноразовый комплект для покраски позволяет изменить цвет модульного экзокостюма. Этот комплект можно применить только к гражданским костюмам."
	icon = 'icons/obj/clothing/modsuit/mod_construction.dmi'
	icon_state = "skinapplier"
	var/skin = "civilian"
	/// Used on the miner asteroid skin to make the suit spaceproof when upgrading.
	var/make_spaceproof = FALSE
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
		balloon_alert(user, "выключите костюм!")
		return ATTACK_CHAIN_BLOCKED
	if(!istype(mod.theme, compatible_theme))
		balloon_alert(user, "несовместимый костюм!")
		return ATTACK_CHAIN_BLOCKED
	mod.theme.set_skin(mod, skin)
	if(make_spaceproof)
		mod.min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
		for(var/obj/item/clothing/C in mod.get_parts())
			C.min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	balloon_alert(user, "перекрашено")
	qdel(src)
	return ATTACK_CHAIN_BLOCKED

/obj/item/mod/skin_applier/asteroid
	skin = "asteroid"
	compatible_theme = /datum/mod_theme/mining
	desc = "Этот одноразовый комплект для покраски позволяет изменить цвет модульного костюма. Этот тип подходит исключительно для шахтёрских \
			костюмов и делает их пригодными для космоса."
	make_spaceproof = TRUE

/obj/item/mod/skin_applier/corpsman
	skin = "corpsman"
	compatible_theme = /datum/mod_theme/medical
	desc = "Этот одноразовый комплект для покраски позволяет изменить цвет модульного костюма. Этот тип подходит исключительно для \
			медицинских костюмов."

/obj/item/mod/universal_modkit
	name = "MOD universal skin applier"
	desc = "Этот одноразовый комплект для покраски позволяет сменить внешний вид МЭК. В отличие от других вариаций, данный комплект можно применить к любому МЭК."
	icon = 'icons/obj/clothing/modsuit/mod_construction.dmi'
	icon_state = "paintkit"
	/// If our kit should be destroyed on use
	var/del_on_use = TRUE

/obj/item/mod/universal_modkit/get_ru_names()
	return list(
		NOMINATIVE = "универсальный комплект покраски МЭК",
		GENITIVE = "универсального комплекта покраски МЭК",
		DATIVE = "универсальному комплекту покраски МЭК",
		ACCUSATIVE = "универсальный комплект покраски МЭК",
		INSTRUMENTAL = "универсальным комплектом покраски МЭК",
		PREPOSITIONAL = "универсальном комплекте покраски МЭК"
	)

/obj/item/mod/universal_modkit/pre_attackby(atom/attacked_atom, mob/living/user, params)
	if(!ismodcontrol(attacked_atom))
		return ..()
	var/obj/item/mod/control/mod = attacked_atom
	if(mod.active || mod.activating)
		balloon_alert(user, "выключите костюм!")
		return ATTACK_CHAIN_BLOCKED

	var/list/possibilities = list()
	for(var/variant in mod.theme.variants)
		if(mod.skin == variant)
			continue
		possibilities += variant

	if(isemptylist(possibilities))
		balloon_alert(user, "нет раскрасок!")
		return ATTACK_CHAIN_PROCEED

	INVOKE_ASYNC(src, PROC_REF(choose_skin), user, mod, possibilities)
	return ATTACK_CHAIN_BLOCKED_ALL

/obj/item/mod/universal_modkit/proc/choose_skin(mob/living/user, obj/item/mod/control/mod, list/possibilities)
	var/choice = tgui_input_list(user, "Выберите подходящую раскраску", "раскраски", possibilities)
	if(!choice || user.incapacitated() || !user.is_in_hands(src) || !user.Adjacent(mod))
		return

	balloon_alert(user, "применение раскраски...")
	if(!do_after(user, 3 SECONDS, mod))
		return

	mod.theme.set_skin(mod, choice)
	balloon_alert(user, "перекрашено")
	if(del_on_use)
		qdel(src)
	return ATTACK_CHAIN_BLOCKED

/obj/item/mod/universal_modkit/infinite
	desc = "Этот многоразовый комплект для покраски позволяет сменить внешний вид МЭК. В отличие от других вариаций, данный комплект можно применить к любому МЭК."
	del_on_use = FALSE
