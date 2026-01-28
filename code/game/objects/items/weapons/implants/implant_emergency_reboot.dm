/obj/item/implant/emergency_reboot
	name = "экстренная перезагрузка био-чип"
	desc = "Помогает владельцу быстро поднятся на ноги после оглушения"
	icon_state = "adrenal"
	implant_state = "implant-syndicate"
	origin_tech = "materials=2;biotech=4;combat=3;syndicate=2"
	implant_data = /datum/implant_fluff/emergency_reboot
	actions_types = null
	base_cooldown = 80 SECONDS

/obj/item/implant/emergency_reboot/get_ru_names()
	return list(
		NOMINATIVE = "имплант экстренной перезагрузки",
		GENITIVE = "импланта экстренной перезагрузки",
		DATIVE = "импланту экстренной перезагрузки",
		ACCUSATIVE = "имплант экстренной перезагрузки",
		INSTRUMENTAL = "имплантом экстренной перезагрузки",
		PREPOSITIONAL = "импланте экстренной перезагрузки",
	)
/obj/item/implant/emergency_reboot/Initialize(mapload)
	. = ..()
	if(!action)
		action = new /datum/action/item_action/hands_free/activate(src)

/obj/item/implant/emergency_reboot/Destroy()
	. = ..()
	QDEL_NULL(action)

/obj/item/implant/emergency_reboot/implant(mob/living/carbon/human/source, mob/user, force)
	add_item_action(action)
	. = ..()

/obj/item/implant/emergency_reboot/create_new_cooldown()
	var/datum/implant_cooldown/charges/charges = new
	charges.max_charges = 3
	charges.recharge_duration = base_cooldown
	charges.charge_duration = 1 SECONDS
	return charges

/obj/item/implant/emergency_reboot/activate()
	var/datum/implant_cooldown/charges/charges_cooldown = cooldown_system

	if(charges_cooldown.is_on_cooldown())
		return FALSE

	if(charges_cooldown.current_charges <= 0)
		balloon_alert(imp_in, "нет зарядов!")
		return FALSE

	if(uses != -1 && uses <= 0)
		return FALSE

	charges_cooldown.start_recharge()
	balloon_alert(imp_in, "активировано!")
	to_chat(imp_in, "Вы чувствуете резкий прилив сил")

	imp_in.SetStunned(0)
	imp_in.SetWeakened(0)
	imp_in.SetKnockdown(0)
	imp_in.SetImmobilized(0)
	imp_in.SetParalysis(0)
	imp_in.setStaminaLoss(0)
	imp_in.SetConfused(0)
	imp_in.set_resting(FALSE, instant = TRUE)
	imp_in.get_up(instant = TRUE)

	imp_in.adjust_nutrition(-20)

	return TRUE

/obj/item/implanter/emergency_reboot
	name = "био-чип имплантер (экстренная перезагрузка)"
	imp = /obj/item/implant/emergency_reboot

/obj/item/implantcase/emergency_reboot
	name = "био-чип кейс - экстренная перезагрузка"
	desc = "стеклянный кейс с имплантом экстренной перезагрузки."
	imp = /obj/item/implant/emergency_reboot
