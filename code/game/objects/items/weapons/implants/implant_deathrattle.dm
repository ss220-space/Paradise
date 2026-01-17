/datum/deathrattle_group
	var/name
	var/list/implants = list()

/datum/deathrattle_group/New(name)
	if(name)
		src.name = name
	else
		// Give the group a unique name for debugging, and possible future
		// use for making custom linked groups.
		src.name = "[rand(100,999)] [pick(GLOB.phonetic_alphabet)]"

/*
 * Proc called by new implant being added to the group. Listens for the
 * implant being implanted, removed and destroyed.
 *
 * If implant is already implanted in a person, then trigger the implantation
 * code.
 */
/datum/deathrattle_group/proc/register(obj/item/implant/deathrattle/implant)
	if(implant in implants)
		return
	RegisterSignal(implant, COMSIG_IMPLANT_ACTIVATED, PROC_REF(on_user_statchange))
	RegisterSignal(implant, COMSIG_QDELETING, PROC_REF(on_implant_destruction))

	implants += implant

/datum/deathrattle_group/proc/on_implant_destruction(obj/item/implant/implant)
	SIGNAL_HANDLER

	implants -= implant

/datum/deathrattle_group/proc/on_user_statchange(obj/item/implant/implant, source, mob/owner)
	SIGNAL_HANDLER

	var/name = owner.mind ? owner.mind.name : owner.real_name
	var/area = get_area_name(get_turf(owner))
	// All "hearers" hear the same sound.
	var/sound = pick(
		'sound/items/knell/knell1.ogg',
		'sound/items/knell/knell2.ogg',
		'sound/items/knell/knell3.ogg',
		'sound/items/knell/knell4.ogg',
	)

	for(var/obj/item/implant/deathrattle/other_implant as anything in implants)

		// Skip the unfortunate soul, and any unimplanted implants
		if(implant == other_implant)
			continue

		// Deliberately the same message framing as ghost deathrattle
		var/mob/living/recipient = other_implant.imp_in
		if(!recipient)
			continue

		to_chat(recipient, "<i>Вы слышите странный роботизированный голос в голове...</i> \"[span_robot("<b>[name]</b> погиб в зоне: <b>[area]</b>.")]\"")
		recipient.playsound_local(get_turf(recipient), sound, vol = 75, vary = FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	qdel(implant)

/obj/item/implant/deathrattle
	name = "deathrattle implant"
	desc = "Надеюсь, что никто из ваших товарищей не погибнет! Но если погибнет, то вы об этом узнаете."
	activated = BIOCHIP_ACTIVATED_PASSIVE
	trigger_causes = BIOCHIP_TRIGGER_DEATH_ANY
	implant_state = "implant-nanotrasen"
	actions_types = null

/obj/item/implant/deathrattle/death_trigger(mob/source, gibbed)
	activate("death")

/obj/item/implant/deathrattle/get_ru_names()
	return list(
		NOMINATIVE = "имплант предсмертного отзвука",
		GENITIVE = "импланта предсмертного отзвука",
		DATIVE = "импланту предсмертного отзвука",
		ACCUSATIVE = "имплант предсмертного отзвука",
		INSTRUMENTAL = "имплантом предсмертного отзвука",
		PREPOSITIONAL = "импланте предсмертного отзвука",
	)

/obj/item/implantcase/deathrattle
	name = "implant case - 'Deathrattle'"
	desc = "Стеклянный кейс, хранящий имплант предсмертного отзвука."
	imp = /obj/item/implant/deathrattle

/obj/item/implantcase/deathrattle/get_ru_names()
	return list(
		NOMINATIVE = "кейс с имплантом предсмертного отзвука",
		GENITIVE = "кейса с имплантом предсмертного отзвука",
		DATIVE = "кейсу с имплантом предсмертного отзвука",
		ACCUSATIVE = "кейс с имплантом предсмертного отзвука",
		INSTRUMENTAL = "кейсом с имплантом предсмертного отзвука",
		PREPOSITIONAL = "кейсе с имплантом предсмертного отзвука",
	)
