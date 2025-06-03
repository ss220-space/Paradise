/datum/contractor_pending
	/// world.time at which the offer will expire.
	var/offer_deadline = -1
	/// indicates whether the offer to become a contractor was given to the player by the admin
	var/is_admin_forced = FALSE
	/// Show if the offer was accepted.
	var/offer_accepted = FALSE

/datum/contractor_pending/New(datum/mind/mind, is_admin_forced)
	. = ..()
	offer_deadline = world.time + CONRACTOR_OFFER_DURATION
	src.is_admin_forced = is_admin_forced
	if(!is_admin_forced)
		return
	var/list/messages = greet()
	to_chat(mind.current, chat_box_red(messages.Join("<br>")))


/datum/contractor_pending/proc/greet()
	// Greet them with the unique message
	var/list/messages = list()
	var/greet_text = "Контрактники отдают [CONTRACTOR_COST] телекристалл[declension_ru(CONTRACTOR_COST, "", "а", "ов")] за возможность выполнять контракты на похищение, получая за это выплаты в виде ТК и кредитов. Это позволяет заработать гораздо больше, чем они имели раньше.<br>" \
					+ "Если вы заинтересованы, просто зайдите в аплинк и выберите вкладку \"Заключение контракта\" для получения дополнительной информации.<br>"
	messages.Add(span_fontsize3(span_fontcolor_red("<b>Вам предложили стать Контрактником.</b><br>")))
	messages.Add(span_fontcolor_red("[greet_text]"))
	if(!is_admin_forced)
		messages.Add(span_fontcolor_red("<b><i>Не упустите возможность! Вы не единственный, кто получил это предложение. \
					Количество доступных предложений ограничено, и если другие агенты примут их раньше вас, то у вас не останется возможности принять участие.</i></b>"))
	messages.Add(span_fontcolor_red("<b><i>Срок действия этого предложения истекает через 10 минут, начиная с этого момента (время истечения: <u>[station_time_timestamp(time = offer_deadline)]</u>).</i></b>"))
	return messages

/**
  * Accepts the offer to be a contractor if possible.
  */
/datum/contractor_pending/proc/become_contractor(mob/living/carbon/human/user, obj/item/uplink/uplink)
	if(!istype(user))
		return

	var/offers_availability_check = !(SSticker?.mode?.contractor_accepted < CONTRACTOR_MAX_ACCEPTED || is_admin_forced)
	if(uplink.uses < CONTRACTOR_COST || world.time >= offer_deadline || offers_availability_check)
		var/reason = (uplink.uses < CONTRACTOR_COST) ? \
			"у вас недостаточно телекристаллов (всего требуется [CONTRACTOR_COST])" : \
			(offers_availability_check) ? \
			"все предложения уже приняты другими агентами": \
			"срок предложения истёк"
		to_chat(user, span_warning("Вы больше не можете стать Контрактником, потому что [reason]."))
		return
	var/datum/antagonist/contractor/contractor = user.mind.add_antag_datum(/datum/antagonist/contractor)
	// Give the kit
	var/obj/item/storage/box/syndie_kit/contractor/contractor_kit = new(user)
	user.put_in_hands(contractor_kit)
	var/obj/item/contractor_uplink/contractor_uplink = locate(/obj/item/contractor_uplink, contractor_kit)
	contractor.contractor_uplink = contractor_uplink
	contractor_uplink.hub = new(user.mind, contractor_uplink)

	// Remove the TC
	uplink.uses -= CONTRACTOR_COST

	offer_accepted = TRUE

	if(!is_admin_forced)
		SSticker?.mode?.contractor_accepted++
