/datum/action/cooldown/spell/summon_friend
	name = "Призвать друга"
	desc = "Ваша награда за продажу души."
	invocation_type = INVOCATION_WHISPER
	invocation = "Amicus meus fidelis infernalis, suus ' vicis"

	button_icon_state = "sacredflame"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_MIND
	cooldown_time = 5 SECONDS
	var/mob/living/friend
	var/obj/effect/mob_spawn/human/demonic_friend/friendShell

/datum/action/cooldown/spell/summon_friend/cast(atom/cast_on)
	. = ..()
	if(!ismob(cast_on))
		return
	var/mob/living/caster = cast_on
	if(!QDELETED(friend))
		to_chat(friend, span_userdanger("Твой хозяин посчитал тебя плохим другом. Тебе пора обратно в ад."))
		to_chat(caster, span_notice("Вы изгоняете вашего друга туда, откуда [GEND_HE_SHE(friend)] при[GEND_SHEL(friend)]."))
		friend.dust()
		QDEL_NULL(friendShell)
		return
	if(!QDELETED(friendShell))
		QDEL_NULL(friendShell)
		return
	friendShell = new /obj/effect/mob_spawn/human/demonic_friend(caster.loc, caster.mind, src)
