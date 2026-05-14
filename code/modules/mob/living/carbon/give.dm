/mob/living/carbon/verb/give(mob/living/carbon/target in oview(1))
	set category = VERB_CATEGORY_IC
	set name = "Передать"

	if(!iscarbon(target)) //something is bypassing the give arguments, no clue what, adding a sanity check JIC
		to_chat(usr, span_danger("Погодите-ка... у [target.declent_ru(ACCUSATIVE)] НЕТ РУК! ААА!"))
		return

	if(target.incapacitated() || HAS_TRAIT(target, TRAIT_HANDS_BLOCKED) || usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || target.client == null)
		return

	var/obj/item/item = get_active_hand()

	if(!item)
		to_chat(usr, span_warning("У вас ничего нет в руке, чтобы передать [target.declent_ru(ACCUSATIVE)]."))
		return
	if(HAS_TRAIT(item, TRAIT_NODROP) || (item.item_flags & ABSTRACT))
		to_chat(usr, span_warning("Это нельзя просто так взять и передать."))
		return
	if(target.r_hand == null || target.l_hand == null)
		var/ans = tgui_alert(target,"[usr] хо[PLUR_CHET_TYAT(usr)] передать вам [item.declent_ru(ACCUSATIVE)]?", "Передача предмета", list("Взять","Не брать"))
		if(!item || !target)
			return
		switch(ans)
			if("Взять")
				if(target.incapacitated() || HAS_TRAIT(target, TRAIT_HANDS_BLOCKED) || usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
					return
				if(!Adjacent(target))
					to_chat(usr, span_warning("Нужно оставаться в пределах досягаемости!"))
					to_chat(target, span_warning("[usr.name] ото[GEND_SHEL(usr)] слишком далеко."))
					return
				if(HAS_TRAIT(item, TRAIT_NODROP) || (item.item_flags & ABSTRACT))
					to_chat(usr, span_warning("[DECLENT_RU_CAP(item, NOMINATIVE)] прилип[GEND_LA_LO_LI(item)]  к вашей руке и не отдаётся!"))
					to_chat(target, span_warning("[DECLENT_RU_CAP(item, NOMINATIVE)] прилип[GEND_LA_LO_LI(item)] к руке [usr.name], когда вы попытались взять!"))
					return
				if(item != get_active_hand())
					to_chat(usr, span_warning("Нужно держать предмет в активной руке."))
					to_chat(target, span_warning("[usr.name] передумал[GEND_A_O_I(usr)] передавать вам [item.declent_ru(NOMINATIVE)]."))
					return
				if(target.r_hand != null && target.l_hand != null)
					to_chat(target, span_warning("Ваши руки заняты."))
					to_chat(usr, span_warning("[GEND_HIS_HER_CAP(usr)] руки заняты."))
					return
				usr.drop_item_ground(item)
				target.put_in_hands(item, ignore_anim = FALSE)
				item.add_fingerprint(target)
				target.visible_message(span_notice("[usr.name] передаёт [item.declent_ru(ACCUSATIVE)] [target.name]."))
				item.on_give(usr, target)
			if("Не брать")
				target.visible_message(span_warning("[usr.name] пытался передать [item.declent_ru(ACCUSATIVE)] [target.name], но [GEND_HE_SHE(usr)] отказал[GEND_SYA_AS_OS_IS(usr)]."))
	else
		to_chat(usr, span_warning("Руки [target.name] заняты."))

/**
 * Toggles the [/datum/click_intercept/give] on or off for the src mob.
 */
/mob/living/carbon/verb/toggle_give()
	set name = "Передать предмет"
	set category = VERB_CATEGORY_IC

	if(incapacitated() || HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	if(has_status_effect(STATUS_EFFECT_OFFERING_ITEM))
		to_chat(src, span_warning("Вы уже предлагаете предмет другому игроку!"))
		return
	if(istype(client.click_intercept, /datum/click_intercept/give))
		QDEL_NULL(client.click_intercept)
		return
	var/obj/item/item = get_active_hand()
	if(!item)
		to_chat(src, span_warning("У вас нет предмета в руке для передачи!"))
		return
	if(HAS_TRAIT(item, TRAIT_NODROP))
		to_chat(src, span_warning("[DECLENT_RU_CAP(item, NOMINATIVE)] прилип[GEND_A_O_I(item)] к вашей руке и не отда[PLUR_YOT_YUT(item)]ся!"))
		return
	if(item.item_flags & ABSTRACT)
		to_chat(src, span_warning("Такой предмет нельзя просто взять и передать."))
		return

	new /datum/click_intercept/give(client)

/**
 * # Offering Item status effect
 *
 * Status effect given to mobs after they've offered an item to another player using the Give Item action ([/datum/click_intercept/give]).
 */
/datum/status_effect/offering_item
	id = "offering item"
	duration = 10 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/offering_item

/datum/status_effect/offering_item/on_creation(mob/living/new_owner, receiver_UID, item_UID)
	. = ..()
	var/atom/movable/screen/alert/status_effect/offering_item/offer = linked_alert
	offer.item_UID = item_UID
	offer.receiver_UID = receiver_UID

/atom/movable/screen/alert/status_effect/offering_item
	name = "Предложение предмета"
	desc = "Вы предлагаете предмет игроку. Держите предмет в руке, чтобы он мог принять его! Нажмите чтобы отменить."
	icon_state = "offering_item"
	clickable_glow = TRUE
	/// UID of the mob who's being offered the item.
	var/receiver_UID
	/// UID of the item being given.
	var/item_UID

/atom/movable/screen/alert/status_effect/offering_item/Click(location, control, params)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/carbon/giver = owner
	var/mob/living/carbon/receiver = locateUID(receiver_UID)
	var/obj/item/item = locateUID(item_UID)
	if(!istype(receiver) || !item)
		return FALSE

	to_chat(giver, span_notice("Вы передумали передавать [item.declent_ru(ACCUSATIVE)] [receiver]."))
	to_chat(receiver, span_warning("[giver] передумал[PLUR_I(giver)] передавать вам [item.declent_ru(ACCUSATIVE)]."))
	receiver.clear_alert("take item [item_UID]") // This cancels *everything* related to the giving/item offering.
	return TRUE

/**
 * # Give click intercept
 *
 * While a mob has this intercept, left clicking on a carbon mob will attempt to offer their currently held item to that mob.
 */
/datum/click_intercept/give
	/// If the intercept user has succesfully offered the item to another player.
	var/item_offered = FALSE
	/// The mob offering the receiver an item.
	var/mob/living/giver
	/// The item being given.
	var/obj/item/giving_item

/datum/click_intercept/give/New(client/C)
	..()
	if(!holder.mouse_override_icon)
		holder.mouse_override_icon = 'icons/misc/mouse_icons/give_item.dmi'
		holder.mouse_pointer_icon = holder.mouse_override_icon

	giver = holder.mob
	giving_item = giver.get_active_hand()
	to_chat(giver, span_notice("ЛКМ по игроку — предложить предмет в руке."))
	ADD_TRAIT(giving_item, TRAIT_GIVE_READY, GIVE_TRAIT)
	RegisterSignals(giving_item, list(COMSIG_QDELETING, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), PROC_REF(signal_qdel))
	RegisterSignals(giver, list(COMSIG_QDELETING, COMSIG_MOB_SWAP_HANDS, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED)), PROC_REF(signal_qdel))

/datum/click_intercept/give/Destroy(force = FALSE)
	if(holder.mouse_override_icon == 'icons/misc/mouse_icons/give_item.dmi')
		holder.mouse_override_icon = null
		holder.mouse_pointer_icon = initial(holder.mouse_pointer_icon)
	if(!item_offered)
		to_chat(giver, span_notice("Вы прекратили попытку передачи предмета."))
	if(giving_item)
		UnregisterSignal(giving_item, list(COMSIG_QDELETING, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
		REMOVE_TRAIT(giving_item, TRAIT_GIVE_READY, GIVE_TRAIT)
		giving_item = null
	if(giver)
		UnregisterSignal(giver, list(COMSIG_QDELETING, COMSIG_MOB_SWAP_HANDS, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED)))
		giver = null
	return ..()

/datum/click_intercept/give/InterceptClickOn(mob/user, params, atom/object)
	. = TRUE
	if(user == object || !iscarbon(object))
		return
	var/mob/living/carbon/receiver = object
	if(receiver.stat != CONSCIOUS)
		to_chat(user, span_warning("[receiver] без сознания и не мо[PLUR_JET_GUT(user)] принять предмет!"))
		return
	if(!receiver.IsAdvancedToolUser())
		to_chat(user, span_warning("[receiver] недостаточно ловк[GEND_II_AYA_II_IE(receiver)] для передачи!"))
		return
	var/obj/item/item = giving_item
	if(!user.Adjacent(receiver))
		to_chat(user, span_warning("Подойдите ближе к [receiver] для передачи [item.declent_ru(GENITIVE)]."))
		return
	if(!receiver.client)
		to_chat(user, span_warning("Вы предлагаете [item.declent_ru(ACCUSATIVE)] [receiver], но реакции нет..."))
		return
	// We use UID() here so that the receiver can have more then one give request at one time.
	// Otherwise, throwing a new "take item" alert would override any current one also named "take item".
	receiver.throw_alert("take item [item.UID()]", /atom/movable/screen/alert/take_item, alert_args = list(user, receiver, item))
	item_offered = TRUE // TRUE so we don't give them the default chat message in Destroy.
	to_chat(user, span_notice("Вы предлагаете [item.declent_ru(ACCUSATIVE)] [receiver]."))
	qdel(src)

/**
 * # Take Item alert
 *
 * Alert which appears for a user when another player is attempting to offer them an item.
 * The user can click the alert to accept, or simply do nothing to not take the item.
 */
/atom/movable/screen/alert/take_item
	name = "Взять предмет"
	desc = "Вам хотят передать предмет!"
	timeout = 10 SECONDS
	clickable_glow = TRUE
	/// UID of the mob offering the receiver an item.
	var/giver_UID
	/// UID of the mob who has this alert.
	var/receiver_UID
	/// UID of the item being given.
	var/item_UID

/atom/movable/screen/alert/take_item/Initialize(mapload, mob/living/giver, mob/living/receiver, obj/item/item)
	. = ..()
	desc = "[giver] хо[PLUR_CHET_TYAT(giver)] передать вам [item.declent_ru(ACCUSATIVE)]. Нажмите чтобы принять!"
	giver_UID = giver.UID()
	receiver_UID = receiver.UID()
	item_UID = item.UID()
	giver.apply_status_effect(STATUS_EFFECT_OFFERING_ITEM, receiver_UID, item_UID)
	add_overlay(icon(item.icon, item.icon_state, SOUTH))
	add_overlay("alert_flash")
	// If either of these atoms are deleted, we need to cancel everything. Also saves having to do null checks before interacting with these atoms.
	// So there is no more COMSIG_QDELETING for giver, because it overrides the same registration
	// in /atom/movable/screen/proc/set_new_hud, which is probably worse then not having it here, because alert will be cleared
	// anyway in alert_timeout()
	RegisterSignals(item, list(COMSIG_QDELETING, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), PROC_REF(cancel_give))
	RegisterSignals(giver, list(COMSIG_MOB_SWAP_HANDS, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED)), PROC_REF(cancel_give))

/atom/movable/screen/alert/take_item/Destroy()
	var/mob/living/giver = locateUID(giver_UID)
	var/obj/item/giving_item = locateUID(item_UID)
	if(giver)
		giver.remove_status_effect(STATUS_EFFECT_OFFERING_ITEM)
		UnregisterSignal(giver, list(COMSIG_MOB_SWAP_HANDS, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED)))
	if(giving_item)
		UnregisterSignal(giving_item, list(COMSIG_QDELETING, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

	return ..()

/atom/movable/screen/alert/take_item/proc/cancel_give()
	SIGNAL_HANDLER

	var/mob/living/giver = locateUID(giver_UID)
	var/mob/living/receiver = locateUID(receiver_UID)

	to_chat(giver, span_warning("Держите предмет в активной руке для передачи!"))
	to_chat(receiver, span_warning("[giver] передумал[GEND_A_O_I(giver)] передавать вам [locateUID(item_UID)]."))

	receiver.clear_alert("take item [item_UID]")

/atom/movable/screen/alert/take_item/Click(location, control, params)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/receiver = owner
	var/mob/living/giver = locateUID(giver_UID)
	// hopefully this will do instead of COMSIG_QDELETING
	if(!giver)
		to_chat(receiver, span_warning("Что-то пошло не так при передаче предмета, сообщите об этом в баг-репорты!"))
		return FALSE

	if(receiver.stat != CONSCIOUS)
		return FALSE

	var/obj/item/item = locateUID(item_UID)
	if(!item)
		return FALSE

	if(receiver.r_hand && receiver.l_hand)
		to_chat(receiver, span_warning("Освободите руки для принятия [item.declent_ru(ACCUSATIVE)]!"))
		return FALSE

	if(!giver.Adjacent(receiver))
		to_chat(receiver, span_warning("Подойдите ближе к [giver] чтобы взять [item.declent_ru(ACCUSATIVE)]!"))
		return FALSE

	if(HAS_TRAIT(item, TRAIT_NODROP))
		to_chat(giver, span_warning("[DECLENT_RU_CAP(item, NOMINATIVE)] прилип к вашей руке при попытке передачи!"))
		to_chat(receiver, span_warning("[DECLENT_RU_CAP(item, NOMINATIVE)] прилип к руке [giver] когда вы пытались взять!"))
		return FALSE

	UnregisterSignal(item, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED)) // We don't want these triggering `cancel_give` at this point, since the give is successful.

	giver.drop_item_ground(item)
	receiver.put_in_hands(item, ignore_anim = FALSE)

	item.add_fingerprint(receiver)
	item.on_give(giver, receiver)

	receiver.visible_message(span_notice("[giver] переда[PLUR_YOT_YUT(giver)] [item.declent_ru(ACCUSATIVE)] [receiver]."))
	receiver.clear_alert("take item [item_UID]")
	return TRUE

/mob/living/carbon/alert_timeout(atom/movable/screen/alert/alert, category)
	if(istype(alert, /atom/movable/screen/alert/take_item))
		var/atom/movable/screen/alert/take_item/take_alert = alert
		var/mob/living/giver = locateUID(take_alert.giver_UID)
		// Make sure we're still nearby. We don't want to show a message if the giver not near us.
		if(giver in view(3, src))
			var/obj/item/item = locateUID(take_alert.item_UID)
			to_chat(giver, span_warning("Вы пытались передать [item.declent_ru(ACCUSATIVE)] [src], но [GEND_HE_SHE(src)] отказал[GEND_SYA_AS_OS_IS(src)]."))
			to_chat(src, span_warning("[giver] прекратил[GEND_A_O_I(giver)] попытку передать вам [item.declent_ru(ACCUSATIVE)]."))
	return ..()
