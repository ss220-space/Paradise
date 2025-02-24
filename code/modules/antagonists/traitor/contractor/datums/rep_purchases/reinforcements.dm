/**
	*Rep Purchase - Contractor partner
*/
/datum/rep_purchase/item/contractor_partner
	name = "Вызов напарника"
	desc = "Устройство, позволяющее связаться с ближайшими отделениями Синдиката в вашем регионе. \
			Если в вашем районе есть свободный агент, его незамедлительно отправят к вам на помощь. \
			В случае отсутствия свободных агентов, сердства будут возвращены."
	stock = 1
	cost = 2
	item_type = /obj/item/antag_spawner/contractor_partner
	refundable = TRUE



/obj/item/antag_spawner/contractor_partner
	name = "Устройство связи с Контрактором"
	desc = "Позволяет вам получить поддержку в выполнении контрактов."
	icon = 'icons/obj/device.dmi'
	icon_state = "contractor_tool"
	var/checking = FALSE
	var/datum/mind/partner_mind = null

/obj/item/antag_spawner/contractor_partner/proc/before_candidate_search(user)
	return TRUE

/obj/item/antag_spawner/contractor_partner/proc/check_usability(mob/user)
	if(used)
		to_chat(user, span_warning("[src.declent_ru(NOMINATIVE)] не имеет энергии!"))
		return FALSE
	if(!(user.mind.special_role))
		to_chat(user, span_danger("СБОЙ АВТОРИЗАЦИИ. ДОСТУП ЗАПРЕЩЕН."))
		return FALSE
	if(checking)
		to_chat(user, span_danger("Устройство уже подключается к ближайшим агентам за пределами станции. Пожалуйста, подождите."))
		return FALSE
	return TRUE

/obj/item/antag_spawner/contractor_partner/attack_self(mob/user)
	if(!(check_usability(user)))
		return

	var/continue_proc = before_candidate_search(user)
	if(!continue_proc)
		return

	checking = TRUE

	to_chat(user, span_notice("Аплинк тихо вибрирует, соединяясь с ближайшими агентами..."))
	var/image/source = image('icons/obj/cardboard_cutout.dmi', "cutout_sit")
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Хотите сыграть за Агента поддержки Контрактора [user.real_name]?", ROLE_TRAITOR, FALSE, 150, source = source)
	if(length(candidates))
		checking = FALSE
		if(QDELETED(src) || !check_usability(user))
			return
		used = TRUE
		var/mob/C = pick(candidates)
		spawn_contractor_partner(user, get_turf(src), C.key)
		do_sparks(4, TRUE, src)
		qdel(src)
	else
		checking = FALSE
		to_chat(user, span_notice("В данный момент нет доступных агентов, пожалуйста, повторите попытку позже или выполните возврат средств за устройство."))

/obj/item/antag_spawner/contractor_partner/proc/spawn_contractor_partner(mob/living/user, turf/T, key)
	var/mob/living/carbon/human/partner = new(T)
	var/datum/outfit/contractor_partner/partner_outfit = new()
	//randomizing appearance
	var/datum/preferences/A = new()
	A.copy_to(partner)
	partner.dna.ready_dna(partner)

	partner_outfit.equip(partner)
	partner.ckey = key
	partner_mind = partner.mind
	partner_mind.make_contractor_support()
	to_chat(partner_mind.current, span_warning("<font size=4>[user.real_name] - Ваш начальник. Выполняйте любые приказы, отданные им. Вы здесь только для того, чтобы помочь ему с его задачами."))
	to_chat(partner_mind.current, span_warning("Если он погибнет или будет недоступен по другим причинам, вы должны помогать другим агентам в меру своих возможностей."))

	var/datum/objective/protect/contractor/CT = new
	CT.owner = partner.mind
	CT.target = user.mind
	CT.explanation_text = "[user.real_name] - Ваш начальник. Его задачи являются первоочередными."
	partner.mind.objectives += CT
	partner.change_voice()

/obj/item/antag_spawner/contractor_partner/check_uplink_validity()
	if(checking)
		to_chat(src.loc, span_notice("Пытаться вернуть деньги за подержанное устройство — довольно глупая затея."))
		return FALSE
	return TRUE

/datum/mind/proc/make_contractor_support()
	if(has_antag_datum(/datum/antagonist/contractor_support))
		return
	add_antag_datum(/datum/antagonist/contractor_support)

