#define CHAPLAIN_BLESS_TIME (5 SECONDS)

/obj/effect/proc_holder/spell/chaplain_bless
	name = "Bless"
	desc = "Посвящает человека в вашу веру."

	school = "transmutation"
	base_cooldown = 6 SECONDS
	clothes_req = FALSE
	selection_activated_message = span_notice_alt("Вы готовите благословение. Нажмите на цель, чтобы начать посвящение.")
	selection_deactivated_message = span_notice_alt("Паства подождёт другого часа.")
	cooldown_min = 2 SECONDS
	action_icon_state = "shield"
	need_active_overlay = TRUE

/obj/effect/proc_holder/spell/chaplain_bless/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.range = 1
	T.click_radius = -1
	return T

/obj/effect/proc_holder/spell/chaplain_bless/valid_target(mob/living/carbon/human/target, mob/user)
	return target.mind && target.ckey && !target.stat && target != user

/obj/effect/proc_holder/spell/chaplain_bless/cast(list/targets, mob/living/user = usr)
	if(!istype(user))
		to_chat(user, span_warning("Вы не можете провести благословение в таком состоянии."))
		revert_cast()
		return

	if(!user.mind)
		to_chat(user, span_warning("Ваш разум не может удержать благословение."))
		revert_cast()
		return

	if(!user.mind.isholy)
		to_chat(user, span_warning("Вам не хватает святости для благословения."))
		revert_cast()
		return

	var/datum/religion_sect/sect = user.mind.holy_sect
	if(!sect || QDELETED(sect))
		to_chat(user, span_warning("Сначала выберите секту на алтаре."))
		revert_cast()
		return

	var/mob/living/carbon/human/target = targets[1]
	if(!sect.can_initiate(target, silent = TRUE))
		to_chat(user, span_warning("[target] не может принять вашу веру."))
		revert_cast()
		return

	addtimer(CALLBACK(src, PROC_REF(try_bless_target), user, target, sect), 0)

/obj/effect/proc_holder/spell/chaplain_bless/proc/try_bless_target(mob/living/user, mob/living/carbon/human/target, datum/religion_sect/sect)
	if(QDELETED(user) || QDELETED(target) || QDELETED(sect))
		return
	if(!user.mind?.isholy || user.mind.holy_sect != sect)
		return
	if(!sect.can_initiate(target, silent = TRUE))
		to_chat(user, span_warning("[target] не может принять вашу веру."))
		return

	var/choice = tgui_alert(target, "[user] предлагает принять веру \"[sect.name]\" во имя [sect.deity_name]. Принять?", "Принять благословение?", list("Да", "Нет"), timeout = 15 SECONDS)
	if(choice != "Да")
		to_chat(user, span_warning("[target] отказыва[PLUR_ET_YUT(target)]ся от благословения."))
		return

	user.visible_message(
		span_notice("[user] начина[PLUR_ET_YUT(user)] посвящать [target] в веру [sect.deity_name]."),
		span_notice("Вы начинаете посвящать [target] в веру [sect.deity_name]."),
	)
	if(!do_after(user, CHAPLAIN_BLESS_TIME, target))
		to_chat(user, span_warning("Благословение было прервано."))
		return
	if(QDELETED(user) || QDELETED(target) || QDELETED(sect) || !user.mind || user.mind.holy_sect != sect)
		return
	if(!sect.can_initiate(target, silent = TRUE))
		to_chat(user, span_warning("[target] больше не может принять вашу веру."))
		return

	var/already_devoted = target.mind.devoted_sect == sect
	if(!sect.initiate(target))
		to_chat(user, span_warning("Благословение не находит отклика."))
		return
	user.visible_message(
		span_notice("[user] посвяща[PLUR_ET_YUT(user)] [target] в веру [sect.deity_name]."),
		span_notice("Вы посвящаете [target] в веру [sect.deity_name]."),
	)
	if(!already_devoted)
		user.mind.num_blessed++

#undef CHAPLAIN_BLESS_TIME
