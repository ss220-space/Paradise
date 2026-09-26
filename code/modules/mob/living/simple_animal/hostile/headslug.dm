/mob/living/simple_animal/hostile/headslug
	name = "headslug"
	desc = "Абсолютно точно без клюва и безвреден. Держите подальше от трупов."
	icon_state = "headslug"
	icon_living = "headslug"
	icon_dead = "headslug_dead"
	icon = 'icons/mob/mob.dmi'
	health = 50
	maxHealth = 50
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "грызёт"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = list("creature")
	robust_searching = TRUE
	stat_attack = DEAD
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	speak_emote = list("попискивает")
	pass_flags = PASSTABLE | PASSMOB
	density = FALSE
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	can_hide = TRUE
	pass_door_while_hidden = TRUE
	var/evented
	var/datum/mind/origin
	var/egg_layed = FALSE
	sentience_type = SENTIENCE_OTHER
	holder_type = /obj/item/holder/headslug
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

/mob/living/simple_animal/hostile/headslug/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		maxbodytemp = 1500, \
		minbodytemp = 0, \
	)

/mob/living/simple_animal/hostile/headslug/proc/Infect(mob/living/carbon/victim)
	var/obj/item/organ/internal/body_egg/changeling_egg/egg = new(victim)
	egg_layed = TRUE
	egg.evented = evented
	egg.insert(victim, ORGAN_MANIPULATION_NOEFFECT)
	if(origin)
		egg.origin = origin
	else if(mind) // Let's make this a feature
		egg.origin = mind

	balloon_alert_to_viewers("впивается в [victim]", "мы ввели яйцо")

/mob/living/simple_animal/hostile/headslug/AltClickOn(mob/living/carbon/carbon_target)
	if(egg_layed || !istype(carbon_target) || carbon_target.stat != DEAD || !Adjacent(carbon_target))
		return ..()

	changeNext_move(CLICK_CD_MELEE)

	if(carbon_target.stat != DEAD)
		balloon_alert(src, "нужен мертвый сосуд")
		return

	if(!do_after(src, 5 SECONDS, carbon_target, NONE))
		return

	if(QDELETED(carbon_target) || egg_layed)
		return

	if(carbon_target.stat != DEAD)
		balloon_alert(src, "сосуд ожил")
		return

	if(HAS_TRAIT(carbon_target, TRAIT_XENO_HOST) || HAS_TRAIT(carbon_target, TRAIT_LEGION_TUMOUR))
		balloon_alert(src, "сосуд уже занят")
		return

	face_atom(carbon_target)
	do_attack_animation(carbon_target)
	playsound(src.loc, 'sound/creatures/terrorspiders/spit2.ogg', 30, TRUE)
	Infect(carbon_target)
	to_chat(src, span_userdanger("Отложив яйцо, мы стремительно приближаемся к смерти..."))
	addtimer(CALLBACK(src, PROC_REF(death)), 30 SECONDS)

/obj/item/organ/internal/body_egg/changeling_egg
	name = "changeling egg"
	desc = "Twitching and disgusting."
	origin_tech = "biotech=7" // You need to be really lucky to obtain it.
	var/datum/mind/origin
	var/time = 0
	var/evented

/obj/item/organ/internal/body_egg/changeling_egg/egg_process()
	// Changeling eggs grow in everyone
	time++
	if(time >= 30 && prob(30))
		owner.bleed(5)

	if(time >= 60 && prob(5))
		to_chat(owner, pick(span_danger("Вы чувствуете себя прекрасно"), span_danger("Вы почуствовали боль, но она уже прошла."), \
							span_danger("Вы неожиданно захотели в тёмную комнату."), span_danger("Вы почувствовали себя очень усташвим.")))

	if(time >= 90 && prob(5))
		to_chat(owner, pick(span_danger("Что-то опять заболело."), span_danger("Какие-то голоса в голове, но это не ты."), \
							span_danger("Вы чувствуете покой."), span_danger("Вы захотели закрыть глаза.")))
		owner.adjustToxLoss(5)

	if((time >= CLING_EGG_INCUBATION_DEAD_TIME && owner.stat == DEAD) || time >= CLING_EGG_INCUBATION_LIVING_TIME)
		STOP_PROCESSING(SSobj, src)
		Pop()
		qdel(src)

/obj/item/organ/internal/body_egg/changeling_egg/proc/Pop()
	var/mob/living/carbon/human/lesser/monkey/monka = new(owner)
	LAZYADD(owner.stomach_contents, monka)

	if(origin?.current)
		origin.transfer_to(monka)
		if(evented && !(monka.mind.has_antag_datum(/datum/antagonist/changeling)))
			monka.mind.add_antag_datum(/datum/antagonist/changeling/evented)
		SSticker.mode.headslugs -= origin
		var/datum/antagonist/changeling/cling = monka.mind.has_antag_datum(/datum/antagonist/changeling)
		if(evented && !(cling.oncepoped))
			owner.real_name = owner.dna.species.get_random_name(owner.gender) // part of technical task, name must be random
			cling.absorbed_count = 0 // clear dna from player's carbon
			cling.oncepoped = TRUE
		if(cling.can_absorb_dna(owner))
			cling.absorb_dna(owner)
		cling.give_power(new /datum/action/changeling/humanform)
		monka.possess_by_player(origin.key)
		monka.revive() // better make sure some weird shit doesn't happen, because it has in the past P.S. some weird shit still happen
		if(cling.absorbed_count == 0)
			var/mob/living/carbon/human/rand_dna = new
			cling.absorb_dna(rand_dna)
	owner.gib()
