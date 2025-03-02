/obj/item/hailer
	name = "hailer"
	desc = "Used by obese officers to save their breath for running."

	icon = 'icons/obj/device.dmi'
	icon_state = "voice0"
	item_state = "flashtool"	//looks exactly like a flash (and nothing like a flashbang)

	w_class = WEIGHT_CLASS_TINY
	flags = CONDUCT

	COOLDOWN_DECLARE(spamcheck)
	var/emagged = FALSE

/obj/item/hailer/attack_self(mob/living/carbon/user as mob)
	hail(user)

/obj/item/hailer/proc/hail(mob/living/carbon/user)
	if(!COOLDOWN_FINISHED(src, spamcheck))
		return

	var/sound_to_play
	var/message

	if(emagged)
		sound_to_play = 'sound/voice/binsult.ogg'
		message = span_warning("[user]'s [name] gurgles, \"FUCK YOUR CUNT YOU SHIT EATING CUNT TILL YOU ARE A MASS EATING SHIT CUNT. EAT PENISES IN YOUR FUCK FACE AND SHIT OUT ABORTIONS TO FUCK UP SHIT IN YOUR ASS YOU COCK FUCK SHIT MONKEY FROM THE DEPTHS OF SHIT\"")

	else
		sound_to_play = 'sound/voice/halt.ogg'
		message = span_warning("[user]'s [name] rasps, \"Halt! Security!\"")

	if(sound_to_play)
		playsound(get_turf(src), sound_to_play, 100, 1, vary = FALSE)
	
	if(message)
		user.visible_message(message)

	COOLDOWN_START(src, spamcheck, 2 SECONDS)

	return

/obj/item/hailer/emag_act(mob/user)
	if(!emagged)
		if(user)
			to_chat(user, span_warning("You overload \the [src]'s voice synthesizer."))

		emagged = TRUE
