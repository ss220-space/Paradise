#define PHOBIA_SCAN_DELAY 6 SECONDS
#define PHOBIA_SCARE_COOLDOWN 12 SECONDS

/datum/brain_trauma/mild/phobia
	name = "Phobia"
	desc = "Пациент беспричинно и панически боится чего-то конкретного."
	scan_desc = "фобия"
	var/phobia_type
	var/regex/trigger_regex
	var/list/trigger_mobs
	var/list/trigger_objs
	var/list/trigger_turfs
	var/list/trigger_species
	COOLDOWN_DECLARE(scan_cooldown)
	COOLDOWN_DECLARE(scare_cooldown)

/datum/brain_trauma/mild/phobia/New(new_phobia_type)
	if(new_phobia_type)
		phobia_type = new_phobia_type
	if(!phobia_type)
		phobia_type = pick(GLOB.phobia_random_types)

	var/fear = GLOB.phobia_types[phobia_type]
	gain_text = span_warning("Вы начинаете панически бояться [fear]...")
	lose_text = span_notice("Вы больше не боитесь [fear].")
	scan_desc = "фобия [fear]"
	return ..()

/datum/brain_trauma/mild/phobia/on_gain()
	trigger_regex = GLOB.phobia_regexes[phobia_type]
	trigger_mobs = GLOB.phobia_mobs[phobia_type]
	trigger_objs = GLOB.phobia_objs[phobia_type]
	trigger_turfs = GLOB.phobia_turfs[phobia_type]
	trigger_species = GLOB.phobia_species[phobia_type]
	return ..()

/datum/brain_trauma/mild/phobia/on_life()
	if(owner.stat >= UNCONSCIOUS || owner.is_blind())
		return

	if(!COOLDOWN_FINISHED(src, scare_cooldown) || !COOLDOWN_FINISHED(src, scan_cooldown))
		return

	COOLDOWN_START(src, scan_cooldown, PHOBIA_SCAN_DELAY)
	var/atom/scary_thing = find_scary_thing()
	if(scary_thing)
		freak_out(scary_thing)

/datum/brain_trauma/mild/phobia/proc/find_scary_thing()
	for(var/atom/candidate as anything in view(world.view, owner))
		if(candidate == owner)
			continue

		if(isobj(candidate))
			if(is_scary_obj(candidate))
				return candidate
			continue

		if(isturf(candidate))
			if(length(trigger_turfs) && is_type_in_typecache(candidate, trigger_turfs))
				return candidate
			continue

		if(isliving(candidate) && is_scary_mob(candidate))
			return candidate

/datum/brain_trauma/mild/phobia/proc/is_scary_obj(obj/candidate)
	if(!length(trigger_objs) || candidate.invisibility > owner.see_invisible)
		return FALSE
	return is_type_in_typecache(candidate, trigger_objs)

/datum/brain_trauma/mild/phobia/proc/is_scary_mob(mob/living/candidate)
	if(candidate.invisibility > owner.see_invisible || !candidate.alpha)
		return FALSE

	if(length(trigger_mobs) && is_type_in_typecache(candidate, trigger_mobs))
		return TRUE

	if(!ishuman(candidate))
		return FALSE

	var/mob/living/carbon/human/scary_human = candidate
	if(length(trigger_species) && is_type_in_typecache(scary_human.dna?.species, trigger_species))
		return TRUE

	for(var/obj/item/equipped as anything in scary_human.get_visible_items())
		if(is_scary_obj(equipped))
			return TRUE

	return FALSE

/datum/brain_trauma/mild/phobia/handle_hearing(datum/source, mob/speaker, list/message_pieces)
	if(speaker == owner || owner.stat >= UNCONSCIOUS || HAS_TRAIT(owner, TRAIT_DEAF))
		return

	for(var/datum/multilingual_say_piece/piece as anything in message_pieces)
		if(!owner.say_understands(speaker, piece.speaking) || !trigger_regex.Find(piece.message))
			continue

		var/scary_word = "[trigger_regex.group[2]][trigger_regex.group[3]]"
		piece.message = trigger_regex.Replace(piece.message, "$1[span_phobia("$2$3")]")
		if(COOLDOWN_FINISHED(src, scare_cooldown))
			addtimer(CALLBACK(src, PROC_REF(freak_out), scary_word), 1 SECONDS, TIMER_DELETE_ME)
		return

/datum/brain_trauma/mild/phobia/handle_speech(datum/source, list/speech_args)
	if(owner.stat >= UNCONSCIOUS || !prob(50))
		return

	if(!trigger_regex.Find(speech_args[SPEECH_MESSAGE]))
		return

	owner.AdjustStuttering(4 SECONDS)
	to_chat(owner, span_warning("Вам тяжело выговорить слово «[span_phobia("[trigger_regex.group[2]][trigger_regex.group[3]]")]»!"))

/datum/brain_trauma/mild/phobia/proc/freak_out(reason)
	if(!COOLDOWN_FINISHED(src, scare_cooldown))
		return

	COOLDOWN_START(src, scare_cooldown, PHOBIA_SCARE_COOLDOWN)
	var/reaction = pick(
		"пробирает вас до костей",
		"выбивает вас из колеи",
		"приводит вас в ужас",
		"вгоняет вас в панику",
		"заставляет мурашки бежать по спине",
	)

	if(istext(reason))
		to_chat(owner, span_bolddanger("Слово «[span_phobia(reason)]» [reaction]!"))
	else
		var/atom/scary_thing = reason
		to_chat(owner, span_bolddanger("[span_phobia(DECLENT_RU_CAP(scary_thing, NOMINATIVE))] [reaction]!"))

	owner.AdjustJitter(15 SECONDS)
	owner.AdjustStuttering(8 SECONDS)
	owner.AdjustHallucinate(20 SECONDS, bound_upper = 60 SECONDS)
	if(prob(20))
		owner.AdjustDizzy(10 SECONDS)
		owner.adjustStaminaLoss(20)
		owner.emote("gasp")

/datum/brain_trauma/mild/phobia/aliens
	phobia_type = "aliens"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/anime
	phobia_type = "anime"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/authority
	phobia_type = "authority"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/birds
	phobia_type = "birds"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/blood
	phobia_type = "blood"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/blood/is_scary_obj(obj/candidate)
	if(length(candidate.blood_DNA))
		return TRUE
	return ..()

/datum/brain_trauma/mild/phobia/blood/is_scary_mob(mob/living/candidate)
	if(length(candidate.blood_DNA))
		return TRUE
	return ..()

/datum/brain_trauma/mild/phobia/clowns
	phobia_type = "clowns"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/conspiracies
	phobia_type = "conspiracies"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/doctors
	phobia_type = "doctors"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/falling
	phobia_type = "falling"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/fish
	phobia_type = "fish"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/greytide
	phobia_type = "greytide"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/guns
	phobia_type = "guns"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/insects
	phobia_type = "insects"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/lizards
	phobia_type = "lizards"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/ocky_icky
	phobia_type = "ocky icky"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/robots
	phobia_type = "robots"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/security
	phobia_type = "security"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/skeletons
	phobia_type = "skeletons"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/snakes
	phobia_type = "snakes"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/space
	phobia_type = "space"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/spiders
	phobia_type = "spiders"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/strangers
	phobia_type = "strangers"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/supernatural
	phobia_type = "the supernatural"
	random_gain = FALSE

#undef PHOBIA_SCAN_DELAY
#undef PHOBIA_SCARE_COOLDOWN
