/datum/hallucination/fake_sound
	random_hallucination_weight = 3
	hallucination_tier = HALLUCINATION_TIER_COMMON
	var/volume = 50
	var/sound_vary = TRUE
	var/sound_type

/datum/hallucination/fake_sound/start()
	if(HAS_TRAIT(hallucinator, TRAIT_DEAF))
		return FALSE

	var/sound_to_play = islist(sound_type) ? pick(sound_type) : sound_type
	play_fake_sound(random_far_turf(), sound_to_play)
	feedback_details += "Sound: [sound_to_play]"
	qdel(src)
	return TRUE

/datum/hallucination/fake_sound/proc/play_fake_sound(turf/source, sound_to_play = sound_type)
	hallucinator.playsound_local(source, sound_to_play, volume, sound_vary)

/datum/hallucination/fake_sound/proc/queue_fake_sound(turf/source, sound_to_play, volume_override, vary_override, delay)
	if(!delay)
		CRASH("[type] queued a fake sound without a timer.")

	addtimer(CALLBACK(hallucinator, TYPE_PROC_REF(/mob, playsound_local), source, sound_to_play, volume_override || volume, vary_override || sound_vary), delay)

/datum/hallucination/fake_sound/normal
	abstract_hallucination_parent = /datum/hallucination/fake_sound/normal
	random_hallucination_weight = 5

/datum/hallucination/fake_sound/normal/airlock
	volume = 30
	sound_type = 'sound/machines/airlock_open.ogg'

/datum/hallucination/fake_sound/normal/airlock_pry
	volume = 100
	sound_type = 'sound/machines/airlock_alien_prying.ogg'

/datum/hallucination/fake_sound/normal/airlock_pry/play_fake_sound(turf/source, sound_to_play)
	. = ..()
	queue_fake_sound(source, 'sound/machines/airlockforced.ogg', 50, TRUE, delay = 5 SECONDS)

/datum/hallucination/fake_sound/normal/console
	volume = 25
	sound_type = 'sound/machines/terminal_prompt.ogg'

/datum/hallucination/fake_sound/normal/boom
	sound_type = SFX_EXPLOSION

/datum/hallucination/fake_sound/normal/distant_boom
	sound_type = SFX_EXPLOSION_CREAKING

/datum/hallucination/fake_sound/normal/glass
	sound_type = SFX_SHATTER

/datum/hallucination/fake_sound/normal/alarm
	volume = 70
	sound_type = 'sound/machines/alarm.ogg'

/datum/hallucination/fake_sound/normal/creepyshriek
	volume = 40
	sound_type = 'sound/effects/creepyshriek.ogg'

/datum/hallucination/fake_sound/normal/beepsky
	volume = 35
	sound_type = 'sound/voice/bfreeze.ogg'

/datum/hallucination/fake_sound/normal/mech
	volume = 40
	sound_type = 'sound/mecha/mechstep.ogg'
	var/turf/mech_source
	var/mech_dir = NORTH
	var/steps_left = 0

/datum/hallucination/fake_sound/normal/mech/Destroy()
	mech_source = null
	return ..()

/datum/hallucination/fake_sound/normal/mech/start()
	mech_dir = pick(GLOB.cardinal)
	steps_left = rand(4, 9)
	mech_source = random_far_turf()

	mech_walk()
	return TRUE

/datum/hallucination/fake_sound/normal/mech/proc/mech_walk()
	if(QDELETED(src))
		return

	if(prob(75))
		play_fake_sound(mech_source)
		mech_source = get_step(mech_source, mech_dir)
	else
		play_fake_sound(mech_source)
		mech_dir = pick(GLOB.cardinal)

	steps_left--
	if(steps_left <= 0)
		qdel(src)

	else
		addtimer(CALLBACK(src, PROC_REF(mech_walk)), 1 SECONDS)

/datum/hallucination/fake_sound/normal/wall_deconstruction
	sound_type = 'sound/items/welder.ogg'

/datum/hallucination/fake_sound/normal/wall_deconstruction/play_fake_sound(turf/source, sound_to_play)
	. = ..()
	queue_fake_sound(source, 'sound/items/welder2.ogg', delay = 10.5 SECONDS)
	queue_fake_sound(source, 'sound/items/ratchet.ogg', delay = 12 SECONDS)

/datum/hallucination/fake_sound/normal/door_hacking
	sound_type = 'sound/items/screwdriver.ogg'
	volume = 30

/datum/hallucination/fake_sound/normal/door_hacking/play_fake_sound(turf/source, sound_to_play)
	. = ..()

	var/hacking_time = rand(4 SECONDS, 8 SECONDS)
	queue_fake_sound(source, 'sound/items/multitool.ogg', delay = 0.8 SECONDS)
	if(hacking_time > 4.5 SECONDS)
		queue_fake_sound(source, 'sound/items/multitool.ogg', delay = 3 SECONDS)
		if(prob(50))
			queue_fake_sound(source, 'sound/items/multitool.ogg', delay = 3.5 SECONDS)

	if(hacking_time > 5.5 SECONDS)
		queue_fake_sound(source, 'sound/items/multitool.ogg', delay = 5 SECONDS)

	queue_fake_sound(source, 'sound/machines/airlockforced.ogg', delay = hacking_time)

/datum/hallucination/fake_sound/normal/steam
	volume = 75
	sound_type = 'sound/machines/hiss.ogg'

/datum/hallucination/fake_sound/normal/flash
	random_hallucination_weight = 2 // "it's revs"
	volume = 90
	sound_type = 'sound/weapons/flash.ogg'

/datum/hallucination/fake_sound/normal/ringtone
	sound_type = 'sound/machines/twobeep_high.ogg'

/datum/hallucination/fake_sound/weird
	abstract_hallucination_parent = /datum/hallucination/fake_sound/weird
	random_hallucination_weight = 1
	hallucination_tier = HALLUCINATION_TIER_VERYSPECIAL

	var/no_source = FALSE

/datum/hallucination/fake_sound/weird/play_fake_sound(turf/source, sound_to_play)
	if(no_source)
		return ..(null, sound_to_play)

	return ..()

/datum/hallucination/fake_sound/weird/creepy
	hallucination_tier = HALLUCINATION_TIER_COMMON

/datum/hallucination/fake_sound/weird/creepy/New(mob/living/hallucinator)
	. = ..()
	sound_type = GLOB.creepy_ambience

/datum/hallucination/fake_sound/weird/game_over
	sound_vary = FALSE
	sound_type = 'sound/machines/compiler/compiler-failure.ogg'
	hallucination_tier = HALLUCINATION_TIER_RARE

/datum/hallucination/fake_sound/weird/hallelujah
	sound_vary = FALSE
	sound_type = 'sound/effects/pray_chaplain.ogg'

/datum/hallucination/fake_sound/weird/hyperspace
	sound_vary = FALSE
	no_source = TRUE
	sound_type = 'sound/effects/hyperspace_begin.ogg'
	hallucination_tier = HALLUCINATION_TIER_COMMON

/datum/hallucination/fake_sound/weird/laugher
	hallucination_tier = HALLUCINATION_TIER_COMMON
	sound_type = list(
		'sound/voice/laugh_female_2.ogg',
		'sound/voice/laugh_female_3.ogg',
		'sound/voice/laugh_male_1.ogg',
		'sound/voice/laugh_male_2.ogg',
		'sound/voice/laugh_male_3.ogg',
	)

/datum/hallucination/fake_sound/weird/fart
	hallucination_tier = HALLUCINATION_TIER_COMMON
	sound_type = SFX_FART

/datum/hallucination/fake_sound/weird/phone
	volume = 15
	sound_vary = FALSE
	sound_type = 'sound/weapons/ring.ogg'
	hallucination_tier = HALLUCINATION_TIER_RARE

/datum/hallucination/fake_sound/weird/phone/play_fake_sound(turf/source, sound_to_play)
	for(var/next_ring in 1 to 3)
		queue_fake_sound(source, sound_to_play, delay = 2.5 SECONDS * next_ring)

	return ..()

/datum/hallucination/fake_sound/weird/spell
	hallucination_tier = HALLUCINATION_TIER_RARE
	sound_type = list(
		'sound/magic/disintegrate.ogg',
		'sound/magic/ethereal_enter.ogg',
		'sound/magic/ethereal_exit.ogg',
		'sound/magic/fireball.ogg',
		'sound/magic/forcewall.ogg',
		'sound/magic/teleport_app.ogg',
		'sound/magic/teleport_diss.ogg',
		'sound/magic/narsie_attack.ogg',
		'sound/magic/staff_chaos.ogg',
		'sound/magic/staff_animation.ogg',
		'sound/magic/mutate.ogg',
	)

/datum/hallucination/fake_sound/weird/summon_sound
	volume = 75
	hallucination_tier = HALLUCINATION_TIER_RARE
	sound_type = 'sound/magic/castsummon.ogg'

/datum/hallucination/fake_sound/weird/tesloose
	volume = 35
	sound_type = 'sound/magic/lightningbolt.ogg'
	hallucination_tier = HALLUCINATION_TIER_RARE

/datum/hallucination/fake_sound/weird/tesloose/play_fake_sound(turf/source, sound_to_play)
	. = ..()
	for(var/next_shock in 1 to rand(2, 4))
		queue_fake_sound(source, sound_to_play, volume_override = volume + (15 * next_shock), delay = 3 SECONDS * next_shock)

/datum/hallucination/fake_sound/weird/xeno
	random_hallucination_weight = 2
	volume = 25
	hallucination_tier = HALLUCINATION_TIER_RARE
	sound_type = list(
		'sound/voice/lowHiss1.ogg',
		'sound/voice/lowHiss2.ogg',
		'sound/voice/lowHiss3.ogg',
		'sound/voice/lowHiss4.ogg',
		'sound/voice/hiss1.ogg',
		'sound/voice/hiss2.ogg',
		'sound/voice/hiss3.ogg',
		'sound/voice/hiss4.ogg',
	)

/datum/hallucination/fake_sound/weird/radio_static
	volume = 75
	no_source = TRUE
	sound_vary = FALSE
	sound_type = 'sound/effects/radio_chatter.ogg'
