/datum/emote/living/carbon/human
	mob_type_allowed_typecache = list(/mob/living/carbon/human)
	/// Custom messages that should be applied based on species
	/// Should be an associative list of species name: message
	var/species_custom_messages = list()
	/// Custom messages applied to mimes of a particular species
	var/species_custom_mime_messages = list()
	var/tail_required = FALSE


/datum/emote/living/carbon/human/can_run_emote(mob/living/carbon/human/user, status_check, intentional)
	. = ..()
	if(. && tail_required && !user.get_organ(BODY_ZONE_TAIL))
		to_chat(user, span_warning("You have no tail!"))
		return FALSE


/datum/emote/living/carbon/human/select_message_type(mob/living/carbon/human/user, msg, intentional)
	. = ..()

	if(!species_custom_messages || (user.mind?.miming && !species_custom_mime_messages))
		return .

	var/custom_message
	if(user.mind?.miming)
		custom_message = species_custom_mime_messages[user.dna.species?.name]
	else
		custom_message = species_custom_messages[user.dna.species?.name]

	if(custom_message)
		return custom_message


/datum/emote/living/carbon/human/run_emote(mob/living/carbon/human/user, params, type_override, intentional)
	if((emote_type & EMOTE_MOUTH) && !user.mind?.miming)
		if(user.getOxyLoss() > 35 || user.AmountLoseBreath() >= 8 SECONDS)	// no screaming if you don't have enough breath to scream
			user.emote("gasp")
			return TRUE
	return ..()


/datum/emote/living/carbon/human/airguitar
	key = "airguitar"
	message = "дела%(ет,ют)% невероятный запил на воображаемой гитаре!"
	hands_use_check = TRUE


/datum/emote/living/carbon/human/clap
	key = "clap"
	key_third_person = "claps"
	message = "хлопа%(ет,ют)%."
	message_mime = "бесшумно хлопа%(ет,ют)%."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = list(
		'sound/misc/clap1.ogg',
		'sound/misc/clap2.ogg',
		'sound/misc/clap3.ogg',
		'sound/misc/clap4.ogg',
	)


/datum/emote/living/carbon/human/clap/run_emote(mob/living/carbon/human/user, params, type_override, intentional)
	var/obj/item/organ/external/left_arm = user.bodyparts_by_name[BODY_ZONE_L_ARM]
	var/obj/item/organ/external/right_arm = user.bodyparts_by_name[BODY_ZONE_R_ARM]
	var/left_hand_good = FALSE
	var/right_hand_good = FALSE
	if(!left_arm?.has_fracture_or_splint())
		left_hand_good = TRUE
	if(!right_arm?.has_fracture_or_splint())
		right_hand_good = TRUE

	if(!left_hand_good || !right_hand_good)
		if(!left_hand_good && !right_hand_good)
			// no arms...
			to_chat(user, span_warning("You need arms to be able to clap."))
		else
			// well, we've got at least one
			user.visible_message("[user] makes the sound of one hand clapping.")
		return TRUE

	return ..()


/datum/emote/living/carbon/human/crack
	key = "crack"
	key_third_person = "cracks"
	message = "хруст%(ит,ят)% костяшками пальцев."
	message_mime = "перебира%(ет,ют)% пальцами."
	emote_type = EMOTE_AUDIBLE
	// knuckles.ogg by CGEffex. Shortened and cut.
	// https://freesound.org/people/CGEffex/sounds/93981/
	sound = 'sound/effects/mob_effects/knuckles.ogg'
	// These species all have overrides, see below
	species_type_blacklist_typecache = list(
		/datum/species/slime,
		/datum/species/machine,
		/datum/species/plasmaman,
		/datum/species/skeleton,
		/datum/species/diona,
	)


/datum/emote/living/carbon/human/cry
	key = "cry"
	key_third_person = "cries"
	message = "плач%(ет,ут)%."
	message_mime = "бесшумно плач%(ет,ут)%."
	muzzled_noises = list("слабые", "жалкие", "грустные")
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	age_based = TRUE
	volume = 70


/datum/emote/living/carbon/human/cry/get_sound(mob/living/carbon/human/user)
	if(user.dna?.species)
		if(user.gender == FEMALE)
			. = safepick(user.dna.species.female_cry_sound)
		else
			. = safepick(user.dna.species.male_cry_sound)
	if(!.)
		return ..()


/datum/emote/living/carbon/human/eyebrow
	key = "eyebrow"
	message = "приподнима%(ет,ют)% бровь."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX


/datum/emote/living/carbon/human/wince
	key = "wince"
	key_third_person = "winces"
	message = "морщ%(ит,ат)%ся."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX


/datum/emote/living/carbon/human/squint
	key = "squint"
	key_third_person = "squints"
	message = "прищурива%(ет,ют)%ся."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX


/datum/emote/living/carbon/human/facepalm
	key = "facepalm"
	key_third_person = "facepalms"
	message = "хлопа%(ет,ют)% себя по лбу."
	message_mime = "бесшумно поднос%(ит,ят)% ладонь ко лбу."
	hands_use_check = TRUE
	sound = 'sound/weapons/slap.ogg'
	emote_type = EMOTE_AUDIBLE
	volume = 50


/datum/emote/living/carbon/human/palm
	key = "palm"
	message = "выжидающе протягива%(ет,ют)% руку."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX


/datum/emote/living/carbon/human/grumble
	key = "grumble"
	key_third_person = "grumbles"
	message = "ворч%(ит,ат)%!"
	message_mime = "как будто ворч%(ит,ат)%!"
	message_postfix = " на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	muzzled_noises = list("беспокойные")
	age_based = TRUE
	volume = 70


/datum/emote/living/carbon/grumble/get_sound(mob/living/carbon/human/user)
	if(user.dna?.species)
		if(user.gender == FEMALE)
			. = safepick(user.dna.species.female_grumble_sound)
		else
			. = safepick(user.dna.species.male_grumble_sound)
	if(!.)
		return ..()


/datum/emote/living/carbon/human/hug
	key = "hug"
	key_third_person = "hugs"
	message = "обнима%(ет,ют)% себя."
	message_param = "обнима%(ет,ют)% %t."
	hands_use_check = TRUE


/datum/emote/living/carbon/human/mumble
	key = "mumble"
	key_third_person = "mumbles"
	message = "бормоч%(ет,ут)%."
	message_mime = "дела%(ет,ют)% странные движения губами."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH


/datum/emote/living/carbon/human/nod
	key = "nod"
	key_third_person = "nods"
	message = "кива%(ет,ют)%."
	message_postfix = " %t!"
	message_param = EMOTE_PARAM_USE_POSTFIX


/datum/emote/living/carbon/human/scream
	key = "scream"
	key_third_person = "screams"
	message = "крич%(ит,ат)%!"
	message_mime = "дела%(ет,ют)% вид, что крич%(ит,ат)%!"
	message_postfix = " на %t!"
	message_param = EMOTE_PARAM_USE_POSTFIX
	muzzled_noises = list("очень громкие")
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	age_based = TRUE
	cooldown = 5 SECONDS
	unintentional_audio_cooldown = 3.5 SECONDS
	volume = 80
	species_type_blacklist_typecache = list(
		/datum/species/machine,	// has silicon scream
		/datum/species/monkey,	// screech instead
	)


/datum/emote/living/carbon/human/scream/select_message_type(mob/living/carbon/human/user, msg, intentional)
	var/scream_verb = user.dna?.species?.scream_verb
	if(scream_verb)
		if(user.mind?.miming)
			. = "делает вид, что [scream_verb]!"
		else
			. = "[scream_verb]!"
	if(!.)
		return ..()


/datum/emote/living/carbon/human/scream/get_sound(mob/living/carbon/human/user)
	if(user.dna?.species)
		if(user.gender == FEMALE)
			. = safepick(user.dna.species.female_scream_sound)
		else
			. = safepick(user.dna.species.male_scream_sound)
	if(!.)
		return ..()


/datum/emote/living/carbon/human/gasp
	key = "gasp"
	key_third_person = "gasps"
	message = "задыха%(ет,ют)%ся!"
	message_mime = "будто бы задыха%(ет,ют)%ся!"
	emote_type = EMOTE_AUDIBLE  // Don't make this one a mouth emote since we don't want it to be caught by nobreath
	unintentional_stat_allowed = UNCONSCIOUS
	volume = 100


/datum/emote/living/carbon/human/gasp/get_sound(mob/living/carbon/human/user)
	if(user.is_muzzled())	// If you're muzzled you're not making noise
		return

	if(!user.dna?.species)
		return

	if(user.health > 0)
		return safepick(user.dna.species.gasp_sound)

	if(user.gender == FEMALE)
		return safepick(user.dna.species.female_dying_gasp_sounds)

	return safepick(user.dna.species.male_dying_gasp_sounds)


/datum/emote/living/carbon/human/gasp/play_sound_effect(mob/living/carbon/human/user, intentional, sound_path, sound_volume)
	var/volume_decrease = 0
	switch(user.getOxyLoss())
		if(0 to 50)
			volume_decrease = 0
		if(51 to 100)
			volume_decrease = 50
		if(101 to 150)
			volume_decrease = 65
		if(151 to 200)
			volume_decrease = 80
		else
			volume_decrease = 95
	sound_volume -= volume_decrease
	// special handling here: we don't want monkeys' gasps to sound through walls so you can actually walk past xenobio
	playsound(user.loc, sound_path, sound_volume, TRUE, -10, frequency = user.get_age_pitch(), ignore_walls = !isnull(user.mind))


/datum/emote/living/carbon/human/shake
	key = "shake"
	key_third_person = "shakes"
	message = "тряс%(ёт,ут)% головой."
	message_postfix = ", смотря на %t!"
	message_param = EMOTE_PARAM_USE_POSTFIX


/datum/emote/living/carbon/human/pale
	key = "pale"
	key_third_person = "pales"
	message = "на секунду бледне%(ет,ют)%."


/datum/emote/living/carbon/human/raise
	key = "raise"
	key_third_person = "raises"
	message = "поднима%(ет,ют)% руку."
	hands_use_check = TRUE


/datum/emote/living/carbon/human/salute
	key = "salute"
	key_third_person = "salutes"
	message = "салюту%(ет,ют)%."
	message_postfix = " %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	hands_use_check = TRUE
	audio_cooldown = 3 SECONDS
	var/list/serious_shoes = list(
		/obj/item/clothing/shoes/jackboots,
		/obj/item/clothing/shoes/combat,
		/obj/item/clothing/shoes/centcom,
		/obj/item/clothing/shoes/laceup,
	)
	var/list/funny_shoes = list(
		/obj/item/clothing/shoes/magboots/clown,
		/obj/item/clothing/shoes/clown_shoes,
		/obj/item/clothing/shoes/cursedclown,
		/obj/item/clothing/shoes/ducky,
	)


/datum/emote/living/carbon/human/salute/get_sound(mob/living/carbon/human/user)
	if(is_type_in_list(user.shoes, serious_shoes))
		return 'sound/effects/salute.ogg'
	if(is_type_in_list(user.shoes, funny_shoes))
		return 'sound/items/toysqueak1.ogg'


/datum/emote/living/carbon/human/shrug
	key = "shrug"
	key_third_person = "shrugs"
	message = "пожима%(ет,ют)% плечами."


/datum/emote/living/carbon/human/johnny
	key = "johnny"
	message = "затягива%(ет,ют)%ся сигаретой и выдыха%(ет,ют)% дым в форме %(своего,их)% имени."
	message_param = "dummy"  // Gets handled in select_param
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	target_behavior = EMOTE_TARGET_BHVR_DEFAULT_TO_BASE
	emote_target_type = EMOTE_TARGET_MOB
	cooldown = 8 SECONDS


/datum/emote/living/carbon/human/johnny/select_param(mob/living/carbon/human/user, params, substitution, base_message)
	if(!params)
		return message
	var/mob/target = find_target(user, params, EMOTE_TARGET_MOB)
	if(!target)
		return message
	var/msg = message
	if(user.mind?.miming)
		msg = "затягива%(ет,ют)%ся сигаретой и выдыха%(ет,ют)% дым в форме имени \"[target.name]\"."
	else
		msg = "говор%(ит,ят)%, \"[target.name], пожалуйста. У них была семья.\" <b>[user.name]</b> затягивается сигаретой и выдыха%(ет,ют)% дым в форме %(своего,их)% имени."
	return msg


/datum/emote/living/carbon/human/johnny/run_emote(mob/living/carbon/human/user, params, type_override, intentional)
	if(!istype(user.wear_mask, /obj/item/clothing/mask/cigarette))
		to_chat(user, span_warning("You can't be that cool without a cigarette between your lips."))
		return TRUE

	var/obj/item/clothing/mask/cigarette/cig = user.wear_mask

	if(!cig.lit)
		to_chat(user, span_warning("You have to light that [cig.name] first, cool cat."))
		return TRUE

	if(user.getOxyLoss() > 30)
		user.visible_message(span_warning("[user.name] gasps for air and swallows their cigarette!"),
							span_warning("You gasp for air and accidentally swallow your [cig.name]!"))
		if(cig.lit)
			to_chat(user, span_userdanger("The lit [cig.name] burns on the way down!"))
			user.drop_item_ground(cig, force = TRUE)
			qdel(cig)
			user.adjustFireLoss(5)
		return TRUE
	return ..()


/datum/emote/living/carbon/human/sneeze
	key = "sneeze"
	key_third_person = "sneezes"
	message = "чиха%(ет,ют)%."
	message_mime = "беззвучно чиха%(ет,ют)%."
	message_postfix = " на %t!"
	message_param = EMOTE_PARAM_USE_POSTFIX
	muzzled_noises = list("странные", "резкие")
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	age_based = TRUE
	volume = 70


/datum/emote/living/carbon/human/sneeze/get_sound(mob/living/carbon/human/user)
	if(user.dna?.species)
		if(user.gender == FEMALE)
			. = safepick(user.dna.species.female_sneeze_sound)
		else
			. = safepick(user.dna.species.male_sneeze_sound)
	if(!.)
		return ..()


/datum/emote/living/carbon/human/slap
	key = "slap"
	key_third_person = "slaps"
	hands_use_check = TRUE
	cooldown = 3 SECONDS // to prevent endless table slamming


/datum/emote/living/carbon/human/slap/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return FALSE
	if(user.put_in_hands(new /obj/item/slapper(user)))
		to_chat(user, span_notice("You ready your slapping hand."))
	else
		to_chat(user, span_warning("You're incapable of slapping in your current state."))


/datum/emote/living/carbon/human/wink
	key = "wink"
	key_third_person = "winks"
	message = "подмигива%(ет,ют)%."
	message_postfix = " %t."
	message_param = EMOTE_PARAM_USE_POSTFIX


/datum/emote/living/carbon/human/highfive
	key = "highfive"
	key_third_person = "highfives"
	hands_use_check = TRUE
	cooldown = 5 SECONDS
	/// Status effect to apply when this emote is used. Should be a subtype
	var/status = STATUS_EFFECT_HIGHFIVE


/datum/emote/living/carbon/human/highfive/can_run_emote(mob/living/carbon/user, status_check, intentional)
	. = ..()
	if(!. || user.restrained())
		return FALSE


/datum/emote/living/carbon/human/highfive/run_emote(mob/user, params, type_override, intentional)
	var/mob/living/carbon/user_carbon = user
	if(user_carbon.has_status_effect(status))
		user.visible_message("[user.name] shakes [user.p_their()] hand around slightly, impatiently waiting for someone to [key].")
		return TRUE
	user_carbon.apply_status_effect(status)
	return ..()


/datum/emote/living/carbon/human/highfive/dap
	key = "dap"
	key_third_person = "daps"
	status = STATUS_EFFECT_DAP


/datum/emote/living/carbon/human/highfive/handshake
	key = "handshake"
	key_third_person = "handshakes"
	status = STATUS_EFFECT_HANDSHAKE


/datum/emote/living/carbon/human/snap
	key = "snap"
	key_third_person = "snaps"
	message = "щелка%(ет,ют)% пальцами."
	message_mime = "бесшумно двига%(ет,ют)% пальцами."
	message_postfix = " в сторону %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	sound = 'sound/effects/fingersnap.ogg'
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/snap/run_emote(mob/living/carbon/human/user, params, type_override, intentional)
	var/obj/item/organ/external/left_arm = user.bodyparts_by_name[BODY_ZONE_L_ARM]
	var/obj/item/organ/external/right_arm = user.bodyparts_by_name[BODY_ZONE_R_ARM]
	var/left_hand_good = FALSE
	var/right_hand_good = FALSE
	if(!left_arm?.has_fracture_or_splint())
		left_hand_good = TRUE
	if(!right_arm?.has_fracture_or_splint())
		right_hand_good = TRUE

	if(!left_hand_good && !right_hand_good)
		to_chat(user, span_warning("You need at least one hand in good working order to snap your fingers."))
		return TRUE

	if(prob(5))
		user.visible_message(span_danger("<b>[user]</b> snaps [user.p_their()] fingers right off!"))
		playsound(user.loc, 'sound/effects/snap.ogg', 50, TRUE)
		return TRUE

	return ..()


/datum/emote/living/carbon/human/fart
	key = "fart"
	key_third_person = "farts"
	message = list("перд%(ит,ят)%.", "пуска%(ет,ют)% газы.")
	message_mime = "туж%(ит,ат)%ся, а затем довольно расслабля%(ет,ют)%ся."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	species_type_blacklist_typecache = list(/datum/species/machine)
	// Credits: Ultimate Fart Series
	// https://freesound.org/people/Jagadamba
	sound = list(
		'sound/effects/mob_effects/fart1.ogg',
		'sound/effects/mob_effects/fart2.ogg',
		'sound/effects/mob_effects/fart3.ogg',
		'sound/effects/mob_effects/fart4.ogg',
		'sound/effects/mob_effects/fart5.ogg',
		'sound/effects/mob_effects/fart6.ogg',
	)


/datum/emote/living/carbon/human/fart/run_emote(mob/user, params, type_override, intentional)
	var/farted_on_something = FALSE
	for(var/atom/check in get_turf(user))
		var/fart_act = check.fart_act(user)
		if(fart_act)
			farted_on_something = TRUE
	if(!farted_on_something)
		if(user.mind?.assigned_role == "Clown" && prob(30))
			confettigibs(user)
		return ..()


/datum/emote/living/carbon/human/fart/get_volume(mob/living/user)
	if(prob(5))	// critical success!
		return rand(150, 250)
	return rand(30, 100)


/datum/emote/living/carbon/human/fart/machine
	message = "изда%(ёт,ют)% звук пердежа."
	message_mime = "беззвучно выпуска%(ет,ют)% облачко пара."
	species_type_whitelist_typecache = list(/datum/species/machine)
	species_type_blacklist_typecache = null
	sound = 'sound/effects/mob_effects/fart_IPC.ogg'


/datum/emote/living/carbon/sign/signal
	key = "signal"
	key_third_person = "signals"
	message_param = "показыва%(ет,ют)% %t."
	number_postfix = list("палец", "пальца", "пальцев")
	param_desc = "number(0-10)"
	mob_type_allowed_typecache = list(/mob/living/carbon/human)
	mob_type_blacklist_typecache = null


/datum/emote/living/carbon/human/whistle
	key = "whistle"
	key_third_person = "whistles"
	message = "свист%(ит,ят)%."
	message_mime = "напряженно выдува%(ет,ют)% воздух."
	message_postfix = " в сторону %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	muzzled_noises = list("свистящие", "громкие")
	cooldown = 5 SECONDS


/datum/emote/living/carbon/human/whistle/get_sound(mob/living/carbon/human/user)
	if(user.dna?.species)
		return safepick(user.dna.species.whistle_sound)
	return ..()


/datum/emote/living/carbon/human/snuffle
	key = "snuffle"
	key_third_person = "snuffles"
	message = "шмыга%(ет,ют)% носом."
	message_mime = "беззвучно шмыга%(ет,ют)% носом."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/hem
	key = "hem"
	key_third_person = "hems"
	message = "хмыка%(ет,ют)%."
	message_mime = "как будто хмыка%(ет,ют)%."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/scratch
	key = "scratch"
	key_third_person = "scratch"
	message = "чеш%(ет,ут)%ся."
	message_param = "чеш%(ет,ут)% %t."
	hands_use_check = TRUE


/////////
// Species-specific emotes

/datum/emote/living/carbon/human/rattle
	key = "rattle"
	key_third_person = "rattles"
	message = "грем%(ит,ят)% костями."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	volume = 80
	sound = 'sound/voice/plas_rattle.ogg'
	species_type_whitelist_typecache = list(/datum/species/skeleton, /datum/species/plasmaman)


/datum/emote/living/carbon/human/wag
	key = "wag"
	key_third_person = "wags"
	message = "начина%(ет,ют)% махать хвостом."
	emote_type = EMOTE_VISIBLE|EMOTE_FORCE_NO_RUNECHAT
	tail_required = TRUE
	species_type_whitelist_typecache = list(
		/datum/species/unathi,
		/datum/species/vulpkanin,
		/datum/species/tajaran,
		/datum/species/vox
	)


/datum/emote/living/carbon/human/wag/can_run_emote(mob/user, status_check = TRUE, intentional)
	. = ..()
	if(. && !can_wag(user))
		return FALSE


/datum/emote/living/carbon/human/wag/run_emote(mob/living/carbon/human/user, params, type_override, intentional)
	. = ..()
	if(.)
		user.start_tail_wagging()


/datum/emote/living/carbon/human/proc/can_wag(mob/living/carbon/human/user)
	var/datum/species/species = user.dna?.species
	if(!species)
		return FALSE
	var/wagging_allowed = (species.bodyflags & TAIL_WAGGING)
	var/tail_obscured = user.wear_suit && (user.wear_suit.flags_inv & HIDETAIL)
	if(!wagging_allowed || (wagging_allowed && tail_obscured))
		return FALSE
	if(istype(user.body_accessory, /datum/body_accessory/tail) && !user.body_accessory.try_restrictions(user))
		return FALSE
	return TRUE


/datum/emote/living/carbon/human/wag/stop
	key = "swag"  // B)
	key_third_person = "swags"
	message = "прекраща%(ет,ют)% махать хвостом."


/datum/emote/living/carbon/human/wag/stop/run_emote(mob/living/carbon/human/user, params, type_override, intentional)
	. = ..()
	if(.)
		user.stop_tail_wagging()


/**
 * Snowflake emotes only for le epic chimp
 */
/datum/emote/living/carbon/human/monkey
	species_type_whitelist_typecache = list(/datum/species/monkey)


// Note: subtype of human scream, not monkey, so we need the overrides.
/datum/emote/living/carbon/human/scream/screech
	key = "screech"
	key_third_person = "screeches"
	message = "визж%(ит,ат)%!"
	species_type_whitelist_typecache = list(/datum/species/monkey)
	species_type_blacklist_typecache = null


/datum/emote/living/carbon/human/scream/screech/roar
	key = "roar"
	key_third_person = "roars"
	message = "рев%(ёт,ут)%!"


/datum/emote/living/carbon/human/monkey/gnarl
	key = "gnarl"
	key_third_person = "gnarls"
	message = "рыч%(ит,ат)% и показыва%(ет,ют)% зубы!"
	message_mime = "тихо цед%(ит,ят)% воздух сквозь зубы!"
	message_postfix = ", смотря на %t!"
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH


/datum/emote/living/carbon/human/monkey/roll
	key = "roll"
	key_third_person = "rolls"
	message = "крут%(ит,ят)%ся."
	hands_use_check = TRUE


/datum/emote/living/carbon/human/monkey/roll/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(.)
		user.SpinAnimation(10, 1)


/datum/emote/living/carbon/human/monkey/tail
	key = "tail"
	message = "маш%(ет,ут)% хвостом."
	tail_required = TRUE


///////
// More specific human species emotes

/**
 * Moth
 */
/datum/emote/living/carbon/human/moth
	species_type_whitelist_typecache = list(/datum/species/moth)
	var/wings_required = FALSE


/datum/emote/living/carbon/human/moth/can_run_emote(mob/living/carbon/human/user, status_check, intentional)
	. = ..()
	if(. && wings_required && !user.get_organ(BODY_ZONE_WING))
		to_chat(user, span_warning("You have no wings!"))
		return FALSE


/datum/emote/living/carbon/human/moth/flap
	key = "flap"
	key_third_person = "flaps"
	message = "маш%(ет,ут)% крыльями."
	wings_required = TRUE


/datum/emote/living/carbon/human/moth/flap/angry
	key = "aflap"
	key_third_person = "aflaps"
	message = "агрессивно маш%(ет,ут)% крыльями!"
	wings_required = TRUE


/datum/emote/living/carbon/human/moth/flutter
	key = "flutter"
	key_third_person = "flutters"
	message = "расправля%(ет,ют)% крылья."
	wings_required = TRUE


/**
 * Vox
 */
/datum/emote/living/carbon/human/vox
	species_type_whitelist_typecache = list(/datum/species/vox)


/datum/emote/living/carbon/human/vox/quill
	key = "quill"
	key_third_person = "quills"
	message = "шурш%(ит,ат)% перьями."
	message_mime = "бесшумно перебира%(ет,ют)% перьями."
	message_postfix = ", смотря на %t!"
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE
	age_based = TRUE
	// Credit to sound-ideas (freesfx.co.uk) for the sound.
	sound = 'sound/effects/voxrustle.ogg'


/**
 * Skrell
 */
/datum/emote/living/carbon/human/skrell
	species_type_whitelist_typecache = list(/datum/species/skrell)
	age_based = TRUE


/datum/emote/living/carbon/human/skrell/warble
	key = "warble"
	key_third_person = "warbles"
	message = "изда%(ёт,ют)% трель."
	message_mime = "искажа%(ет,ют)% губы в странную форму."
	message_postfix = ", смотря на %t!"
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	muzzled_noises = list("громкие")
	// Copyright CC BY 3.0 alienistcog (freesound.org) for the sound.
	sound = 'sound/effects/warble.ogg'


/datum/emote/living/carbon/human/skrell/warble/sad
	key = "warble_sad"
	message = "изда%(ёт,ют)% грустную трель."
	sound = list(
		'sound/voice/skrell/sad_trill1.ogg',
		'sound/voice/skrell/sad_trill2.ogg',
		'sound/voice/skrell/sad_trill3.ogg',
	)


/datum/emote/living/carbon/human/skrell/warble/joyfull
	key = "warble_joyfull"
	message = "изда%(ёт,ют)% радостную трель."
	sound = list(
		'sound/voice/skrell/joyfull_trill1.ogg',
		'sound/voice/skrell/joyfull_trill2.ogg',
		'sound/voice/skrell/joyfull_trill3.ogg',
	)


/datum/emote/living/carbon/human/skrell/croak
	key = "croak"
	key_third_person = "croaks"
	message = "квака%(ет,ют)%."
	message_mime = "надува%(ет,ют)% щёки."
	message_postfix = " на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	muzzled_noises = list("очень странные")
	sound = list(
		'sound/voice/skrell/croaking1.ogg',
		'sound/voice/skrell/croaking2.ogg',
	)


/datum/emote/living/carbon/human/skrell/discontent
	key = "discontent"
	message = "клад%(ёт,ут)% два пальца на подбородок."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	hands_use_check = TRUE


/datum/emote/living/carbon/human/skrell/relax
	key = "relax"
	message = "раслабля%(ет,ют)% хвосты на голове."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX


/datum/emote/living/carbon/human/skrell/excitement
	key = "excitement"
	message = "приподнима%(ет,ют)% кончики боковых хвостов."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX


/datum/emote/living/carbon/human/skrell/confusion
	key = "confusion"
	message = "чеш%(ет,ут)% шею."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	hands_use_check = TRUE


/datum/emote/living/carbon/human/skrell/understand
	key = "understand"
	message = "клад%(ёт,ут)% руку на шею."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	hands_use_check = TRUE


/datum/emote/living/carbon/human/skrell/smile
	key = "smile"
	key_third_person = "smiles"
	message = "клад%(ёт,ут)% руку на щеку."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	hands_use_check = TRUE


/**
 * Kidan
 */
/datum/emote/living/carbon/human/kidan
	species_type_whitelist_typecache = list(/datum/species/kidan)
	vary = TRUE
	var/head_required = TRUE


/datum/emote/living/carbon/human/kidan/can_run_emote(mob/living/carbon/human/user, status_check = TRUE, intentional = FALSE)
	. = ..()
	if(. && head_required && !user.get_organ(BODY_ZONE_HEAD))
		user.custom_emote(EMOTE_VISIBLE, "отчаянно дёрга[pluralize_ru(user.gender, "ет", "ют")]ся!")
		return FALSE


/datum/emote/living/carbon/human/kidan/clack
	key = "clack"
	key_third_person = "clacks"
	message = "щёлка%(ет,ют)% мандибулами."
	message_mime = "перебира%(ет,ют)% мандибулами."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	muzzled_noises = list("тихие")
	audio_cooldown = 3 SECONDS
	// Credit to DrMinky (freesound.org) for the sound.
	sound = 'sound/effects/Kidanclack.ogg'


/datum/emote/living/carbon/human/kidan/clack/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(.)
		var/view = user.client ? user.client.view : world.view
		mineral_scan_pulse(get_turf(user), view)


/datum/emote/living/carbon/human/kidan/clack/click
	key = "click"
	key_third_person = "clicks"
	message = "клаца%(ет,ют)% мандибулами."
	message_mime = "дёрга%(ет,ют)% мандибулами."
	// Credit to DrMinky (freesound.org) for the sound.
	sound = 'sound/effects/kidanclack2.ogg'


/datum/emote/living/carbon/human/kidan/wiggle
	key = "wiggle"
	key_third_person = "wiggles"
	message = "шевел%(ит,ят)% усиками."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE
	audio_cooldown = 3 SECONDS
	sound = list(
		'sound/voice/kidan/wiggles_antennae1.ogg',
		'sound/voice/kidan/wiggles_antennae2.ogg',
		'sound/voice/kidan/wiggles_antennae3.ogg',
	)


/datum/emote/living/carbon/human/kidan/waves_k
	key = "wave_k"
	message = "резко взмахива%(ет,ют)% усиками."
	message_mime = "поднима%(ет,ют)% усики."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE
	audio_cooldown = 2 SECONDS
	sound = list(
		'sound/voice/kidan/waves_antennae_sharply1.ogg',
		'sound/voice/kidan/waves_antennae_sharply2.ogg',
	)


/**
 * Drask
 */
/datum/emote/living/carbon/human/drask
	species_type_whitelist_typecache = list(/datum/species/drask)


/datum/emote/living/carbon/human/drask/drask_talk
	emote_type = EMOTE_SOUND
	age_based = TRUE
	message_postfix = " на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	sound = 'sound/voice/drasktalk.ogg'


/datum/emote/living/carbon/human/drask/drask_talk/drone
	key = "drone"
	key_third_person = "drones"
	message = "гуд%(ит,ят)%."
	message_mime = "дела%(ет,ют)% вид, что гуд%(ит,ят)%."


/datum/emote/living/carbon/human/drask/drask_talk/hum
	key = "hum"
	key_third_person = "hums"
	message = "грохоч%(ет,ут)%."
	message_mime = "дела%(ет,ют)% вид, что грохоч%(ет,ут)%."


/datum/emote/living/carbon/human/drask/drask_talk/rumble
	key = "rumble"
	key_third_person = "rumbles"
	message = "урч%(ит,ат)%."
	message_mime = "дела%(ет,ют)% вид, что урч%(ит,ат)%."


/**
 * Unathi
 */
/datum/emote/living/carbon/human/unathi
	species_type_whitelist_typecache = list(/datum/species/unathi)


/datum/emote/living/carbon/human/unathi/hiss
	key = "hiss"
	key_third_person = "hisses"
	message = "шип%(ит,ят)%!"
	message_mime = "тихо шип%(ит,ят)%!"
	message_postfix = " на %t!"
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	muzzled_noises = list("раздражённые", "свистящие", "шипящие")
	age_based = TRUE
	audio_cooldown = 3 SECONDS
	// Credit to Jamius (freesound.org) for the sound.
	sound = 'sound/effects/unathihiss.ogg'


/datum/emote/living/carbon/human/unathi/rumble
	key = "rumble"
	key_third_person = "rumble"
	message = "урч%(ит,ат)%."
	message_mime = "тихо урч%(ит,ат)%."
	message_postfix = " на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	muzzled_noises = list("урчащие", "гортанные")
	audio_cooldown = 6 SECONDS
	age_based = TRUE
	volume = 65
	sound = list(
		'sound/voice/unathi/rumble.ogg',
		'sound/voice/unathi/rumble2.ogg',
	)


/datum/emote/living/carbon/human/unathi/roar
	key = "roar"
	key_third_person = "roar"
	message = "рыч%(ит,ат)%!"
	message_mime = "бесшумно рыч%(ит,ат)%!"
	message_postfix = " на %t!"
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	muzzled_noises = list("раздражённые", "утробные", "громкие")
	audio_cooldown = 6 SECONDS
	age_based = TRUE
	sound = list(
		'sound/voice/unathi/roar.ogg',
		'sound/voice/unathi/roar2.ogg',
		'sound/voice/unathi/roar3.ogg',
	)


/datum/emote/living/carbon/human/unathi/threat
	key = "threat"
	key_third_person = "threat"
	message = "угрожающе рыч%(ит,ат)%!"
	message_mime = "угрожающе раскрыва%(ет,ют)% пасть!"
	message_postfix = " на %t!"
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	muzzled_noises = list("очень раздражённые", "громкие")
	audio_cooldown = 6 SECONDS
	age_based = TRUE
	volume = 80
	sound = list(
		'sound/voice/unathi/threat.ogg',
		'sound/voice/unathi/threat2.ogg',
	)


/datum/emote/living/carbon/human/unathi/whip
	key = "whip"
	key_third_person = "whips"
	message = "ударя%(ет,ют)% хвостом."
	message_mime = "взмахива%(ет,ют)% хвостом и бесшумно опуска%(ет,ют)% его на пол."
	message_postfix = ", грозно смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE
	tail_required = TRUE
	volume = 100
	audio_cooldown = 3 SECONDS
	sound = 'sound/voice/unathi/whip_short.ogg'


/datum/emote/living/carbon/human/unathi/whip/whip_l
	key = "whip_l"
	key_third_person = ""
	message = "хлещ%(ет,ут)% хвостом."
	audio_cooldown = 6 SECONDS
	sound = 'sound/voice/unathi/whip.ogg'


/**
 * Diona
 */
/datum/emote/living/carbon/human/diona
	species_type_whitelist_typecache = list(/datum/species/diona)


/datum/emote/living/carbon/human/diona/creak
	key = "creak"
	key_third_person = "creaks"
	message = "скрип%(ит,ят)% ветками."
	message_mime = "шевел%(ит,ят)% ветками."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE
	age_based = TRUE
	//Credit https://www.youtube.com/watch?v=ufnvlRjsOTI [0:13 - 0:16]
	sound = 'sound/voice/dionatalk1.ogg'


/**
 * Slimepeople
 */
/datum/emote/living/carbon/human/slime
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE
	age_based = TRUE
	audio_cooldown = 3 SECONDS


/datum/emote/living/carbon/human/slime/can_run_emote(mob/living/carbon/human/user, status_check, intentional)
	. = ..()
	if(!.)
		return FALSE
	if(isslimeperson(user))
		return TRUE
	for(var/obj/item/organ/external/bodypart as anything in user.bodyparts) // if your limbs are squishy you can squish too!
		if(bodypart.dna && istype(bodypart.dna.species, /datum/species/slime))
			return TRUE
	return FALSE


/datum/emote/living/carbon/human/slime/squish
	key = "squish"
	key_third_person = "squishes"
	message = "хлюпа%(ет,ют)%."
	message_mime = "дела%(ет,ют)% вид, что хлюпа%(ет,ют)%."
	// Credit to DrMinky (freesound.org) for the sound.
	sound = 'sound/effects/mob_effects/slime_squish.ogg'


/datum/emote/living/carbon/human/slime/bubble
	key = "bubble"
	key_third_person = "bubbles"
	message = "громко пузыр%(ит,ят)%ся."
	message_mime = "покрыва%(ет,ют)%ся пузырями."
	// Sound is CC-4.0 by Audiolarx
	// Effect is cut out of original clip
	// https://freesound.org/people/audiolarx/sounds/263945/
	sound = 'sound/effects/mob_effects/slime_bubble.ogg'
	volume = 100


/datum/emote/living/carbon/human/slime/pop
	key = "pop"
	key_third_person = "pops"
	message = "изда%(ёт,ют)% хлопок."
	message_mime = "изда%(ёт,ют)% тихий хлопок."
	// CC0
	// https://freesound.org/people/greenvwbeetle/sounds/244653/
	sound = 'sound/effects/mob_effects/slime_pop.ogg'


/**
 * Vulpkanin
 */
/datum/emote/living/carbon/human/vulpkanin
	species_type_whitelist_typecache = list(/datum/species/vulpkanin)


/datum/emote/living/carbon/human/vulpkanin/howl
	key = "howl"
	key_third_person = "howls"
	message = "во%(ет,ют)%!"
	message_mime = "делает вид, что во%(ет,ют)%!"
	message_postfix = " на %t!"
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	muzzled_noises = list("очень громкие")
	age_based = TRUE
	volume = 100
	cooldown = 10 SECONDS
	unintentional_cooldown = 10 SECONDS
	sound = 'sound/goonstation/voice/howl.ogg'

/datum/emote/living/carbon/human/vulpkanin/howl/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(.)
		var/turf/turf_user = get_turf(user)
		var/datum/gas_mixture/source_env = turf_user.return_air()
		if(!source_env)
			return
		for(var/mob/living/carbon/human/H in range(4, user))
			if(!isvulpkanin(H) || !H.can_hear() || H.stat != CONSCIOUS)
				continue
			var/turf/T = get_turf(H)
			var/datum/gas_mixture/hearer_env = T.return_air()
			if(!hearer_env)
				continue
			var/distance = 4
			var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())
			if(pressure < ONE_ATMOSPHERE)
				distance = FLOOR(distance * max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0), 1)
				if(get_dist(turf_user, get_turf(H)) > distance)
					continue
			addtimer(CALLBACK(H, TYPE_PROC_REF(/mob, emote), "howl"), rand(10,30))

/datum/emote/living/carbon/human/vulpkanin/growl
	key = "growl"
	key_third_person = "growls"
	message = "рыч%(ит,ат)%!"
	message_mime = "тихо рыч%(ит,ат)%!"
	message_postfix = " на %t!"
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	muzzled_noises = list("раздражённые", "утробные")
	age_based = TRUE
	volume = 80
	sound = "growls"	// exists predefined in [/proc/get_sfx()]


/**
 * Tajaran
 */
/datum/emote/living/carbon/human/tajaran
	species_type_whitelist_typecache = list(/datum/species/tajaran)


/datum/emote/living/carbon/human/tajaran/hiss
	key = "hiss"
	key_third_person = "hisses"
	message = "шип%(ит,ят)%!"
	message_mime = "тихо шип%(ит,ят)%!"
	message_postfix = " на %t!"
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	muzzled_noises = list("раздражённые", "свистящие", "шипящие")
	age_based = TRUE
	// Credit to Jamius (freesound.org) for the sound.
	sound = 'sound/voice/tajarahiss.mp3'
	volume = 100


/datum/emote/living/carbon/human/tajaran/purr
	key = "purr"
	key_third_person = "purrs"
	message = "мурч%(ит,ат)%."
	message_mime = "тихо мурч%(ит,ат)%."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE
	age_based = TRUE
	volume = 80
	sound = 'sound/voice/cat_purr.ogg'


/datum/emote/living/carbon/human/tajaran/purr/purrl
	key = "purrl"
	key_third_person = ""
	message = "утробно мурч%(ит,ат)%."
	message_mime = "тихо утробно мурч%(ит,ат)%."
	cooldown = 6 SECONDS
	sound = 'sound/voice/cat_purr_long.ogg'


/**
 * Cracking subtypes
 */
/datum/emote/living/carbon/human/crack/slime
	message = "хлюпа%(ет,ют)% кистями рук!"
	sound = 'sound/effects/mob_effects/slime_squish.ogg'
	species_type_whitelist_typecache = list(/datum/species/slime)
	species_type_blacklist_typecache = null


/datum/emote/living/carbon/human/crack/machine
	message = "хруст%(ит,ят)% своими приводами!"
	sound = 'sound/effects/mob_effects/ipc_crunch.ogg'
	species_type_whitelist_typecache = list(/datum/species/machine)
	species_type_blacklist_typecache = null


/datum/emote/living/carbon/human/crack/diona
	message = "хруст%(ит,ят)% веткой!"
	sound = 'sound/effects/mob_effects/diona_crunch.ogg'
	species_type_whitelist_typecache = list(/datum/species/diona)
	species_type_blacklist_typecache = null
	volume = 80  // the sound effect is a bit quiet


/datum/emote/living/carbon/human/crack/skelly
	message = "хруст%(ит,ят)% костями!"
	species_type_whitelist_typecache = list(/datum/species/skeleton, /datum/species/plasmaman)
	species_type_blacklist_typecache = null


/datum/emote/living/carbon/human/crack/skelly/run_emote(mob/living/carbon/human/user, params, type_override, intentional)
	var/obj/item/organ/external/bodypart = safepick(user.bodyparts)
	if(!bodypart)
		message = initial(message)
		return ..()

	var/translated = bodypart.limb_zone
	switch(bodypart.limb_zone)
		if(BODY_ZONE_HEAD)
			translated = "костями черепа"
		if(BODY_ZONE_CHEST)
			translated = "рёбрами"
		if(BODY_ZONE_PRECISE_GROIN)
			translated = "тазовыми костями"
		if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
			translated = "суставами локтя"
		if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			translated = "коленными чашечками"
		if(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)
			translated = "фалангами пальцев"
		if(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
			translated = "суставами стопы"
		else
			translated = "костями"

	message = "хруст%(ит,ят)% [translated]!"
	return ..()

