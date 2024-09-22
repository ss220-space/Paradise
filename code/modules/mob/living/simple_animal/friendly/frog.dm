/mob/living/simple_animal/frog
	name = "лягушка"
	real_name = "лягушка"
	desc = "Выглядит грустным не по средам и когда её не целуют."
	icon_state = "frog"
	icon_living = "frog"
	icon_dead = "frog_dead"
	icon_resting = "frog"
	speak = list("Квак!","КУААК!","Квуак!")
	speak_emote = list("квак","куак","квуак")
	emote_hear = list("квак","куак","квуак")
	emote_see = list("лежит расслабленная", "увлажнена", "издает гортанные звуки", "лупает глазками")
	var/scream_sound = list ('sound/creatures/frog_scream_1.ogg','sound/creatures/frog_scream_2.ogg','sound/creatures/frog_scream_3.ogg')
	talk_sound = list('sound/creatures/frog_talk1.ogg', 'sound/creatures/frog_talk2.ogg')
	damaged_sound = list('sound/creatures/frog_damaged.ogg')
	death_sound = 'sound/creatures/frog_death.ogg'
	tts_seed = "pantheon"
	speak_chance = 1
	turns_per_move = 5
	nightvision = 10
	maxHealth = 10
	health = 10
	blood_volume = BLOOD_VOLUME_SURVIVE
	butcher_results = list(/obj/item/reagent_containers/food/snacks/monstermeat/lizardmeat = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stamps on"
	density = FALSE
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	layer = MOB_LAYER
	atmos_requirements = list("min_oxy" = 16, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	universal_speak = 0
	can_hide = 1
	holder_type = /obj/item/holder/frog
	can_collar = 1
	gold_core_spawnable = FRIENDLY_SPAWN


/mob/living/simple_animal/frog/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/mob/living/simple_animal/frog/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		maxbodytemp = 323, \
		minbodytemp = 223, \
	)

/mob/living/simple_animal/frog/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == INTENT_HELP)
		get_scooped(M)
	..()


/mob/living/simple_animal/frog/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	frog_crossed(arrived)


/mob/living/simple_animal/frog/proc/frog_crossed(atom/movable/arrived)
	if(!stat && ishuman(arrived))
		to_chat(arrived, span_notice("[bicon(src)] квака[pluralize_ru(gender, "ет", "ют")]!"))


/mob/living/simple_animal/frog/toxic
	name = "яркая лягушка"
	real_name = "яркая лягушка"
	desc = "Уникальная токсичная раскраска. Лучше не трогать голыми руками."
	icon_state = "rare_frog"
	icon_living = "rare_frog"
	icon_dead = "rare_frog_dead"
	icon_resting = "rare_frog"
	var/toxin_per_touch = 2.5
	var/toxin_type = "toxin"
	gold_core_spawnable = HOSTILE_SPAWN
	holder_type = /obj/item/holder/frog/toxic


/mob/living/simple_animal/frog/toxic/attack_hand(mob/living/carbon/human/user)
	if(!ishuman(user) || user.gloves)
		return ..()

	var/obj/item/organ/external/left_hand = get_organ(BODY_ZONE_PRECISE_L_HAND)
	var/obj/item/organ/external/right_hand = get_organ(BODY_ZONE_PRECISE_R_HAND)
	if((left_hand && !left_hand.is_robotic()) || (right_hand && !right_hand.is_robotic()))
		to_chat(user, span_warning("Дотронувшись до [src.name], ваша кожа начинает чесаться!"))
		toxin_affect(user)

	if(user.a_intent == INTENT_DISARM || user.a_intent == INTENT_HARM)
		return ..()


/mob/living/simple_animal/frog/toxic/frog_crossed(mob/living/carbon/human/arrived)
	if(!ishuman(arrived) || arrived.shoes)
		return ..()

	var/obj/item/organ/external/left_foot = arrived.get_organ(BODY_ZONE_PRECISE_L_FOOT)
	var/obj/item/organ/external/right_foot = arrived.get_organ(BODY_ZONE_PRECISE_R_FOOT)
	if((left_foot && !left_foot.is_robotic()) || (right_foot && !right_foot.is_robotic()))
		to_chat(arrived, span_warning("Ваши ступни начинают чесаться!"))
		toxin_affect(arrived)

	return ..()


/mob/living/simple_animal/frog/toxic/proc/toxin_affect(mob/living/carbon/human/user)
	if(user.reagents && toxin_type && toxin_per_touch)
		user.reagents.add_reagent(toxin_type, toxin_per_touch)


/mob/living/simple_animal/frog/scream
	name = "орущая лягушка"
	real_name = "орущая лягушка"
	desc = "Не любит когда на неё наступают. Используется в качестве наказания за проступки"
	var/squeak_sound = list ('sound/creatures/frog_scream1.ogg','sound/creatures/frog_scream2.ogg')
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/frog/scream/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, squeak_sound, 50, extrarange = SHORT_RANGE_SOUND_EXTRARANGE, dead_check = TRUE) //as quiet as a frog or whatever

/mob/living/simple_animal/frog/toxic/scream
	var/squeak_sound = list ('sound/creatures/frog_scream1.ogg','sound/creatures/frog_scream2.ogg')
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/frog/toxic/scream/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, squeak_sound, 50, extrarange = SHORT_RANGE_SOUND_EXTRARANGE, dead_check = TRUE) //as quiet as a frog or whatever

/mob/living/simple_animal/frog/handle_automated_movement()
	. = ..()
	if(!resting && !buckled && prob(1))
		emote("warcry")

/mob/living/simple_animal/frog/scream/mapper
	name = "Лягушка"
	real_name = "Маппер"
	atmos_requirements = list("min_oxy"=0,"max_oxy"=0,"min_tox"=0,"max_tox"=0,"min_co2"=0,"max_co2"=0,"min_n2"=0,"max_n2"=0)
	butcher_results = list(/obj/item/areaeditor/blueprints=1)
	damage_coeff = list("brute"=0,"fire"=0,"tox"=0,"clone"=0,"stamina"=0,"oxy"=0)
	death_sound = 'sound/creatures/mapper_death.ogg'
	desc = "Окупировавшая один из офисов на Центральном командовании лягушка. Постоянно кричит что-то в монитор."
	emote_hear = list("МГРЛЬК","МРГЛ","УААМРГЛ")
	emote_see = list("лежит расслабленная","увлажнена","издает гортанные звуки","лупает глазками","сильно недовольна","ищет рантаймы")
	maxHealth = 1000
	scream_sound = list('sound/creatures/mapper_disappointed.ogg','sound/creatures/mapper_angry.ogg','sound/creatures/mapper_annoyed.ogg')
	speak = list("МРГЛЬК!","ТРУБА В ТРУБЕ! РАНТАЙМ! ПИЗДЕЦ!","ЧЕРЕЗ ЧАС!","ЗЕРО НА ВАЙТЛИСТЕ!","1.5.7. В РЕЛИЗЕЕЕ!","ВОТ БИ СМ НА КОРОБКУ!","ДА КТО ЭТОТ ВАШ ПР?!","МУЛЬТИЗЕТА ХОЧЕТСЯ!")
	squeak_sound = list('sound/creatures/mapper_disappointed.ogg','sound/creatures/mapper_angry.ogg','sound/creatures/mapper_annoyed.ogg')
	talk_sound = list('sound/creatures/mapper_scream.ogg')
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/frog/scream/mapper/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, squeak_sound, 50, extrarange = SILENCED_SOUND_EXTRARANGE) //as quiet as a frog or whatever

/mob/living/simple_animal/frog/scream/mapper/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		maxbodytemp = 1000, \
		cold_damage = 0, \
	)
