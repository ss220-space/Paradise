/mob/living/carbon/verb/give(mob/living/carbon/target in oview(1))
	set category = STATPANEL_IC
	set name = "Передать"

	if(!iscarbon(target)) //something is bypassing the give arguments, no clue what, adding a sanity check JIC
		to_chat(usr, span_danger("Погодите-ка... у [target.declent_ru(ACCUSATIVE)] НЕТ РУК! ААА!"))
		return

	if(target.incapacitated() || HAS_TRAIT(target, TRAIT_HANDS_BLOCKED) || usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || target.client == null)
		return

	var/obj/item/I = get_active_hand()

	if(!I)
		to_chat(usr, span_warning("У вас ничего нет в руке, чтобы передать [target.declent_ru(ACCUSATIVE)]."))
		return
	if(HAS_TRAIT(I, TRAIT_NODROP) || (I.item_flags & ABSTRACT))
		to_chat(usr, span_warning("Это нельзя просто так взять и передать это."))
		return
	if(target.r_hand == null || target.l_hand == null)
		var/ans = tgui_alert(target,"[usr] хоч[pluralize_ru(usr.gender,"ет","ят")] передать вам [I.declent_ru(ACCUSATIVE)]?", "Передача предмета", list("Взять","Не брать"))
		if(!I || !target)
			return
		switch(ans)
			if("Взять")
				if(target.incapacitated() || HAS_TRAIT(target, TRAIT_HANDS_BLOCKED) || usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
					return
				if(!Adjacent(target))
					to_chat(usr, span_warning("Нужно оставаться в пределах досягаемости!"))
					to_chat(target, span_warning("[usr.name] отош[genderize_ru(usr.gender,"ел","ла","ло","ли")] слишком далеко."))
					return
				if(HAS_TRAIT(I, TRAIT_NODROP) || (I.item_flags & ABSTRACT))
					to_chat(usr, span_warning("[capitalize(I.declent_ru(NOMINATIVE))] прилип[genderize_ru(I.gender,"","ла","ло","ли")]  к вашей руке и не отдаётся!"))
					to_chat(target, span_warning("[capitalize(I.declent_ru(NOMINATIVE))] прилип[genderize_ru(I.gender,"","ла","ло","ли")] к руке [usr.name], когда вы попытались взять!"))
					return
				if(I != get_active_hand())
					to_chat(usr, span_warning("Нужно держать предмет в активной руке."))
					to_chat(target, span_warning("[usr.name] передумал[genderize_ru(usr.gender,"","а","о","и")] передавать вам [I.declent_ru(NOMINATIVE)]."))
					return
				if(target.r_hand != null && target.l_hand != null)
					to_chat(target, span_warning("Ваши руки заняты."))
					to_chat(usr, span_warning("[genderize_ru(usr.gender,"Его","Её","Его","Их")] руки заняты."))
					return
				usr.drop_item_ground(I)
				target.put_in_hands(I, ignore_anim = FALSE)
				I.add_fingerprint(target)
				target.visible_message(span_notice("[usr.name] передаёт [I.declent_ru(ACCUSATIVE)] [target.name]."))
				I.on_give(usr, target)
			if("Не брать")
				target.visible_message(span_warning("[usr.name] пытался передать [I.declent_ru(ACCUSATIVE)] [target.name], но [genderize_ru(usr.gender,"он отказался","она отказалась","оно отказалось","они отказались")]."))
	else
		to_chat(usr, span_warning("Руки [target.name] заняты."))

/**
 * Toggles the [/datum/click_intercept/give] on or off for the src mob.
 */
/mob/living/carbon/verb/toggle_give()
	set name = "Передать предмет"
	set category = STATPANEL_IC

	if(incapacitated() || HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	if(has_status_effect(STATUS_EFFECT_OFFERING_ITEM))
		to_chat(src, span_warning("Вы уже предлагаете предмет другому игроку!"))
		return
	if(istype(client.click_intercept, /datum/click_intercept/give))
		QDEL_NULL(client.click_intercept)
		return
	var/obj/item/I = get_active_hand()
	if(!I)
		to_chat(src, span_warning("У вас нет предмета в руке для передачи!"))
		return
	if(HAS_TRAIT(I, TRAIT_NODROP))
		to_chat(src, span_warning("[capitalize(I.declent_ru(NOMINATIVE))] прилип[genderize_ru(I.gender,"","а","о","и")] к вашей руке и не отда[pluralize_ru(I.gender,"ёт","ют")]ся!"))
		return
	if(I.item_flags & ABSTRACT)
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
	/// UID of the mob who's being offered the item.
	var/receiver_UID
	/// UID of the item being given.
	var/item_UID

/atom/movable/screen/alert/status_effect/offering_item/Click(location, control, params)
	var/mob/living/carbon/receiver = locateUID(receiver_UID)
	var/mob/living/carbon/giver = attached_effect.owner
	var/obj/item/I = locateUID(item_UID)
	to_chat(giver, span_notice("Вы передумали передавать [I.declent_ru(ACCUSATIVE)] [receiver]."))
	to_chat(receiver, span_warning("[giver] передум[pluralize_ru(giver.gender,"ал","али")] передавать вам [I.declent_ru(ACCUSATIVE)]."))
	receiver.clear_alert("take item [item_UID]") // This cancels *everything* related to the giving/item offering.


/**
 * # Give click intercept
 *
 * While a mob has this intercept, left clicking on a carbon mob will attempt to offer their currently held item to that mob.
 */
/datum/click_intercept/give
	/// If the intercept user has succesfully offered the item to another player.
	var/item_offered = FALSE

/datum/click_intercept/give/New(client/C)
	..()
	holder.mouse_pointer_icon = 'icons/misc/mouse_icons/give_item.dmi'
	to_chat(holder, span_notice("ЛКМ по игроку – предложить предмет в руке."))
	RegisterSignal(holder.mob.get_active_hand(), list(COMSIG_QDELETING, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), PROC_REF(signal_qdel))
	RegisterSignal(holder.mob, list(COMSIG_MOB_SWAP_HANDS, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED)), PROC_REF(signal_qdel))

/datum/click_intercept/give/Destroy(force = FALSE)
	holder.mouse_pointer_icon = initial(holder.mouse_pointer_icon)
	if(!item_offered)
		to_chat(holder.mob, span_notice("Вы прекратили попытку передачи предмета."))
	return ..()


/datum/click_intercept/give/InterceptClickOn(mob/user, params, atom/object)
	if(user == object || !iscarbon(object))
		return
	var/mob/living/carbon/receiver = object
	if(receiver.stat != CONSCIOUS)
		to_chat(user, span_warning("[receiver] без сознания и не мо[pluralize_ru(user.gender, "жет", "гут")] принять предмет!"))
		return
	if(!receiver.IsAdvancedToolUser())
		to_chat(user, span_warning("[receiver] недостаточно лов[genderize_ru(receiver.gender,"ок","ка","ок","ки")] для передачи!"))
		return
	var/obj/item/I = user.get_active_hand()
	if(!user.Adjacent(receiver))
		to_chat(user, span_warning("Подойдите ближе к [receiver] для передачи [I.declent_ru(ACCUSATIVE)]."))
		return
	if(!receiver.client)
		to_chat(user, span_warning("Вы предлагаете [I.declent_ru(ACCUSATIVE)] [receiver], но реакции нет..."))
		return
	// We use UID() here so that the receiver can have more then one give request at one time.
	// Otherwise, throwing a new "take item" alert would override any current one also named "take item".
	receiver.throw_alert("Вам предлагают [I.UID()]", /atom/movable/screen/alert/take_item, alert_args = list(user, receiver, I))
	item_offered = TRUE // TRUE so we don't give them the default chat message in Destroy.
	to_chat(user, span_notice("Вы предлагаете [I.declent_ru(ACCUSATIVE)] [receiver]."))
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
	icon_state = "template"
	timeout = 10 SECONDS
	/// UID of the mob offering the receiver an item.
	var/giver_UID
	/// UID of the mob who has this alert.
	var/receiver_UID
	/// UID of the item being given.
	var/item_UID


/atom/movable/screen/alert/take_item/Initialize(mapload, mob/living/giver, mob/living/receiver, obj/item/I)
	. = ..()
	desc = "[giver] хоч[pluralize_ru(giver.gender, "ет", "ют")] передать вам [I.declent_ru(ACCUSATIVE)]. Нажмите чтобы принять!"
	giver_UID = giver.UID()
	receiver_UID = receiver.UID()
	item_UID = I.UID()
	giver.apply_status_effect(STATUS_EFFECT_OFFERING_ITEM, receiver_UID, item_UID)
	add_overlay(icon(I.icon, I.icon_state, SOUTH))
	add_overlay("alert_flash")
	// If either of these atoms are deleted, we need to cancel everything. Also saves having to do null checks before interacting with these atoms.
	RegisterSignal(I, list(COMSIG_QDELETING, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), PROC_REF(cancel_give))
	RegisterSignal(giver, list(COMSIG_QDELETING, COMSIG_MOB_SWAP_HANDS, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED)), PROC_REF(cancel_give))


/atom/movable/screen/alert/take_item/Destroy()
	var/mob/living/giver = locateUID(giver_UID)
	giver.remove_status_effect(STATUS_EFFECT_OFFERING_ITEM)

	return ..()


/atom/movable/screen/alert/take_item/proc/cancel_give()
	SIGNAL_HANDLER

	var/mob/living/giver = locateUID(giver_UID)
	var/mob/living/receiver = locateUID(receiver_UID)

	to_chat(giver, span_warning("Держите предмет в активной руке для передачи!"))
	to_chat(receiver, span_warning("[giver] передум[genderize_ru(giver.gender, "ал", "ала", "ал", "ало")] передавать вам [locateUID(item_UID)]."))

	receiver.clear_alert("take item [item_UID]")


/atom/movable/screen/alert/take_item/Click(location, control, params)
	var/mob/living/receiver = locateUID(receiver_UID)
	if(receiver.stat != CONSCIOUS)
		return

	var/obj/item/I = locateUID(item_UID)
	if(receiver.r_hand && receiver.l_hand)
		to_chat(receiver, span_warning("Освободите руки для принятия [I.declent_ru(ACCUSATIVE)]!"))
		return

	var/mob/living/giver = locateUID(giver_UID)
	if(!giver.Adjacent(receiver))
		to_chat(receiver, span_warning("Подойдите ближе к [giver] чтобы взять [I.declent_ru(ACCUSATIVE)]!"))
		return

	if(HAS_TRAIT(I, TRAIT_NODROP))
		to_chat(giver, span_warning("[capitalize(I.declent_ru(NOMINATIVE))] прилип к вашей руке при попытке передачи!"))
		to_chat(receiver, span_warning("[capitalize(I.declent_ru(NOMINATIVE))] прилип к руке [giver] когда вы пытались взять!"))
		return

	UnregisterSignal(I, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED)) // We don't want these triggering `cancel_give` at this point, since the give is successful.

	giver.drop_item_ground(I)
	receiver.put_in_hands(I, ignore_anim = FALSE)

	I.add_fingerprint(receiver)
	I.on_give(giver, receiver)

	receiver.visible_message(span_notice("[giver] переда[pluralize_ru(giver.gender, "ёт", "ют")] [I.declent_ru(ACCUSATIVE)] [receiver]."))
	receiver.clear_alert("take item [item_UID]")


/atom/movable/screen/alert/take_item/do_timeout(mob/M, category)
	var/mob/living/giver = locateUID(giver_UID)
	var/mob/living/receiver = locateUID(receiver_UID)
	// Make sure we're still nearby. We don't want to show a message if the giver not near us.
	if(giver in view(3, receiver))
		var/obj/item/I = locateUID(item_UID)
		to_chat(giver, span_warning("Вы пытались передать [I.declent_ru(ACCUSATIVE)] [receiver], но [genderize_ru(receiver.gender,"тот отказался","та отказалась","тот отказался","те отказались")]."))
		to_chat(receiver, span_warning("[giver] прекратил[genderize_ru(giver.gender, "", "а", "о", "и")] попытку передать вам [I.declent_ru(ACCUSATIVE)]."))
	..()
