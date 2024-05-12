/datum/emote/living/carbon/brain
	mob_type_allowed_typecache = list(/mob/living/carbon/brain)
	mob_type_blacklist_typecache = null
	/// The message that will be displayed to themselves, since brains can't really see their own emotes
	var/self_message


/datum/emote/living/carbon/brain/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return FALSE
	if(self_message)
		to_chat(user, span_notice(self_message))


/datum/emote/living/carbon/brain/can_run_emote(mob/living/carbon/brain/user, status_check, intentional)
	. = ..()
	if(!.)
		return FALSE
	if(!user.container || !istype(user.container, /obj/item/mmi))  // No MMI, no emotes
		return FALSE


/datum/emote/living/carbon/brain/alarm
	key = "alarm"
	key_third_person = "alarms"
	message = "изда%(ёт,ют)% аварийный сигнал."
	self_message = "You sound an alarm."
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/brain/alert
	key = "alert"
	key_third_person = "alerts"
	message = "изда%(ёт,ют)% тревожный шум."
	self_message = "You let out a distressed noise."
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/brain/notice
	key = "notice"
	key_third_person = "notices"
	message = "игра%(ет,ют)% громкий мотив."
	self_message = "You play a loud tone."
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/brain/flash
	key = "flash"
	key_third_person = "flashes"
	message = "начина%(ет,ют)% быстро моргать лампочками!"
	self_message = "You starts flashing your lights!"


/datum/emote/living/carbon/brain/whistle
	key = "whistle"
	key_third_person = "whistles"
	message = "свист%(ит,ят)%."
	self_message = "You whistle."
	emote_type = EMOTE_AUDIBLE
	audio_cooldown = 5 SECONDS
	sound = 'sound/voice/whistle.ogg'


/datum/emote/living/carbon/brain/beep
	key = "beep"
	key_third_person = "beeps"
	message = "изда%(ёт,ют)% длинный гудок."
	self_message = "You beep."
	emote_type = EMOTE_AUDIBLE
	sound = 'sound/machines/twobeep.ogg'


/datum/emote/living/carbon/brain/boop
	key = "boop"
	key_third_person = "boops"
	message = "изда%(ёт,ют)% короткий гудок."
	self_message = "You boop."
	emote_type = EMOTE_AUDIBLE
	sound = 'sound/machines/boop.ogg'

