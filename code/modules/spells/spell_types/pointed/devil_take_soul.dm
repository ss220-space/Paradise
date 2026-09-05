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
	cast_range = 5
	background_icon_state = "bg_demon"

/datum/action/cooldown/spell/pointed/take_soul/is_valid_target(atom/cast_on)
	if(!ishuman(cast_on))
		return FALSE
	var/mob/living/carbon/human/target = cast_on
	return target.mind && target.mind.hasSoul && (target.mind.soulOwner == target.mind)

/datum/action/cooldown/spell/pointed/take_soul/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/human = cast_on
	var/datum/antagonist/devil/devil = owner.mind?.has_antag_datum(/datum/antagonist/devil)
	devil.add_soul(human?.mind)
