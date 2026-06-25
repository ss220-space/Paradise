// Имплант: "Stamina Boost"
/obj/item/implant/stamina_boost
	name = "stamina boost bio-chip"
	desc = "Мгновенно восстанавливает запас выносливости, но временно ограничивает её максимальное значение. Эффект может накладываться несколько раз."
	icon_state = "adrenal"
	implant_state = "implant-syndicate"
	origin_tech = "materials=2;biotech=3;combat=2"
	implant_data = /datum/implant_fluff/stamina_boost
	actions_types = null
	base_cooldown = 3 SECONDS

/obj/item/implant/stamina_boost/Initialize(mapload)
	. = ..()
	if(!action)
		action = new(src)

/obj/item/implant/stamina_boost/Destroy()
	QDEL_NULL(action)
	return ..()

/obj/item/implant/stamina_boost/implant(mob/living/carbon/human/source, mob/user, force)
	. = ..()
	if(!.)
		return
	add_item_action(action)


/obj/item/implant/stamina_boost/can_implant(mob/source, mob/user)
	if(!ishuman(source))
		return FALSE
	return ..()

/obj/item/implant/stamina_boost/activate()
	if(cooldown_system?.is_on_cooldown())
		return FALSE

	if(imp_in.max_stamina <= STAMINA_PENALTY)
		balloon_alert(imp_in, "организм истощён")
		return FALSE

	balloon_alert(imp_in, "резкий прилив сил")

	imp_in.SetStunned(0)
	imp_in.SetWeakened(0)
	imp_in.SetKnockdown(0)
	imp_in.SetImmobilized(0)
	imp_in.SetParalysis(0)
	imp_in.setStaminaLoss(0)
	imp_in.set_resting(FALSE, instant = TRUE)
	imp_in.get_up(instant = TRUE)

	var/datum/status_effect/stamina_boost_restriction/effect = imp_in.has_status_effect(/datum/status_effect/stamina_boost_restriction)
	if(effect)
		effect.add_stack()
	else
		imp_in.apply_status_effect(/datum/status_effect/stamina_boost_restriction)

	cooldown_system.start_recharge()
	return ..()

// Имплантер и кейс остаются без изменений
/obj/item/implanter/stamina_boost
	name = "bio-chip implanter (stamina boost)"
	imp = /obj/item/implant/stamina_boost

/obj/item/implantcase/stamina_boost
	name = "bio-chip case - 'Stamina Boost'"
	desc = "A glass case containing a stamina boost bio-chip."
	imp = /obj/item/implant/stamina_boost
