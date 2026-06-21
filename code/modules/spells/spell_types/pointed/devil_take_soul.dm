/datum/action/cooldown/spell/pointed/take_soul
	name = "Забрать душу"
	desc = "Это заклинание забирает душу у выбраной цели."

	invocation_type = "shout"
	invocation = "Ille porcus est meus!"

	active_msg = span_notice_alt("Вы готовы забрать душу. Просто клините на свою жертву.")
	deactive_msg = span_notice_alt("Вы передумали забирать чью-то душу.")

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	school = "conjuration"

	cooldown_time = 5 SECONDS

	background_icon_state = "bg_demon"

/obj/effect/proc_holder/spell/take_soul/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.try_auto_target = FALSE
	T.range = 5
	T.click_radius = -1
	T.allowed_type = /mob/living/carbon
	return T

/obj/effect/proc_holder/spell/take_soul/valid_target(mob/living/carbon/target, mob/user)
	return target.mind && target.mind.hasSoul && (target.mind.soulOwner == target.mind)

/obj/effect/proc_holder/spell/take_soul/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/human = targets[1]
	var/datum/antagonist/devil/devil = user.mind?.has_antag_datum(/datum/antagonist/devil)
	devil.add_soul(human?.mind)
