/datum/emote/living/silicon
	mob_type_allowed_typecache = list(
		/mob/living/silicon,
		/mob/living/simple_animal/bot,
		/mob/living/carbon/human,	// Humans are allowed for the sake of IPCs
		)
	mob_type_blacklist_typecache = null


/datum/emote/living/silicon/can_run_emote(mob/living/carbon/human/user, status_check, intentional)
	. = ..()
	if(!.)
		return FALSE
	// Let IPCs (and people with robo-heads) make beep-boop noises
	if(ishuman(user))
		var/obj/item/organ/external/head/head = user.get_organ(BODY_ZONE_HEAD)
		if(!head || !head.is_robotic())
			return FALSE


/datum/emote/living/silicon/scream
	key = "scream"
	key_third_person = "screams"
	message = "громко сигнал%(ит,ят)%!"
	message_mime = "ярко сверка%(ет,ют)% лампочками!"
	message_postfix = ", смотря на %t!"
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE
	cooldown = 5 SECONDS
	unintentional_audio_cooldown = 3.5 SECONDS
	vary = TRUE
	sound = 'sound/goonstation/voice/robot_scream.ogg'
	volume = 80


/datum/emote/living/silicon/ping
	key = "ping"
	key_third_person = "pings"
	message = "звен%(ит,ят)%."
	message_mime = "тихо звен%(ит,ят)%."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE
	sound = 'sound/machines/ping.ogg'


/datum/emote/living/silicon/buzz
	key = "buzz"
	key_third_person = "buzzes"
	message = "жужж%(ит,ат)%."
	message_mime = "тихо жужж%(ит,ат)%."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE
	sound = 'sound/machines/buzz-sigh.ogg'


/datum/emote/living/silicon/buzz2
	key = "buzz2"
	message = "изда%(ёт,ют)% раздраженный жужжащий звук."
	message_mime = "тихо раздражённо жужж%(ит,ат)%."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE
	sound = 'sound/machines/buzz-two.ogg'


/datum/emote/living/silicon/beep
	key = "beep"
	key_third_person = "beeps"
	message = "пищ%(ит,ат)%."
	message_mime = "тихо пищ%(ит,ат)%."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE
	sound = 'sound/machines/twobeep.ogg'


/datum/emote/living/silicon/boop
	key = "boop"
	key_third_person = "boops"
	message = "изда%(ёт,ют)% короткий гудок."
	message_mime = "тихо гуд%(ит,ят)%."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE
	sound = 'sound/machines/boop.ogg'


/datum/emote/living/silicon/yes
	key = "yes"
	message = "изда%(ёт,ют)% утвердительный сигнал."
	message_mime = "утвердительно сверка%(ет,ют)% лампочками."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE
	sound = 'sound/machines/synth_yes.ogg'


/datum/emote/living/silicon/no
	key = "no"
	message = "изда%(ёт,ют)% отрицательный сигнал."
	message_mime = "отрицательно сверка%(ет,ют)% лампочками."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE
	sound = 'sound/machines/synth_no.ogg'


/datum/emote/living/silicon/law
	key = "law"
	message = "указыва%(ет,ют)% на штрих-код службы безопасноти."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE
	sound = 'sound/voice/biamthelaw.ogg'


/datum/emote/living/silicon/law/can_run_emote(mob/user, status_check, intentional)
	. = ..()
	if(!. || !is_security_robot(user))
		return FALSE


/datum/emote/living/silicon/proc/is_security_robot(mob/living/silicon/robot/user)
	if(!isrobot(user) || !istype(user.module, /obj/item/robot_module/security))
		return FALSE
	return TRUE


/datum/emote/living/silicon/halt
	key = "halt"
	message = "ор%(ёт,ут)% \"СТОЯТЬ! СЛУЖБА БЕЗОПАСНОСТИ!\" через динамики!"
	emote_type = EMOTE_AUDIBLE
	sound = 'sound/voice/halt.ogg'


/datum/emote/living/silicon/halt/can_run_emote(mob/user, status_check, intentional)
	. = ..()
	if(!. || !is_security_robot(user))
		return FALSE

