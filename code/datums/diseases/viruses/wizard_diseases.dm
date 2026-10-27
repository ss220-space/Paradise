/datum/disease/virus/beesease/wizard_variant
	spread_flags = NON_CONTAGIOUS
	show_in_records = FALSE

/datum/disease/virus/fluspanish/wizard_variant
	spread_flags = NON_CONTAGIOUS
	show_in_records = FALSE

/datum/disease/virus/kingstons_advanced/wizard_variant
	spread_flags = NON_CONTAGIOUS
	show_in_records = FALSE

/datum/disease/virus/dna_retrovirus/wizard_variant
	spread_flags = NON_CONTAGIOUS
	show_in_records = FALSE

/datum/disease/virus/tuberculosis/wizard_variant
	spread_flags = NON_CONTAGIOUS
	show_in_records = FALSE

/datum/disease/virus/wizarditis/wizard_variant
	spread_flags = NON_CONTAGIOUS
	show_in_records = FALSE

/datum/disease/virus/anxiety/wizard_variant
	spread_flags = NON_CONTAGIOUS
	show_in_records = FALSE

/datum/disease/virus/grut_gut
	name = "Желудочная гниль"
	stage_prob = 5
	cure_text = "Пиротехнические стабилизирующий агент"
	agent = "Eruca Stomachum"
	cures = list("stabilizing_agent")
	infectable_mobtypes = list(/mob/living/carbon/human)
	desc = "Магически насыщенная болезнь, которая вызывает опасно высокое давление желчи в желудке."
	severity = DISEASE_SEVERITY_DANGEROUS
	virus_heal_resistant = TRUE

/datum/disease/virus/grut_gut/wizard_variant
	show_in_records = FALSE

/datum/disease/virus/grut_gut/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(1)
			if(prob(3))
				to_chat(affected_mob, span_danger("С вашим желудком что-то не то."))
		if(2)
			if(prob(3))
				to_chat(affected_mob, span_danger("Вы чувствуете вздутие."))
			if(prob(2))
				to_chat(affected_mob, span_danger("Вы чувствуете неприятное давление в животе."))
		if(3)
			if(prob(3))
				to_chat(affected_mob, span_danger("Вы чувствуете неприятное давление в животе."))
			if(prob(2))
				affected_mob.emote("burp")
			if(prob(1))
				affected_mob.emote("groan")
		if(4)
			if(prob(1))
				affected_mob.fakevomit(no_text = 1)
				affected_mob.adjust_nutrition(-rand(3,5))
			if(prob(2))
				affected_mob.emote("burp")
			if(prob(3))
				to_chat(affected_mob, span_danger("Вы чувствуете ужасное вздутие."))
			if(prob(2))
				to_chat(affected_mob, span_danger("Глубокое бурление отдаётся эхом в груди."))
		if(5)
			if(prob(2))
				affected_mob.start_custom_emote(EMOTE_AUDIBLE, "отрыгива%(ет,ют)%. громко!")
			if(prob(1))
				affected_mob.emote("burp")
			if(prob(1))
				affected_mob.emote("groan")
			if(prob(3))
				to_chat(affected_mob, span_danger("Желудок разрывается от боли!"))
			if(prob(3))
				to_chat(affected_mob, span_danger("Живот урчит и бурлит с неистовой силой!"))
			if(prob(2) && affected_mob.nutrition >= 100)
				affected_mob.adjustBruteLoss(5)
				affected_mob.vomit(6, 0, TRUE, 7, 0)
				affected_mob.visible_message(
					span_danger("[DECLENT_RU_CAP(affected_mob, NOMINATIVE)] с такой силой рвёт, что [affected_mob.declent_ru(ACCUSATIVE)] отбрасывает назад!"),
					span_userdanger("Вас вырывает потоком магической желчи с такой силой, что вас отбрасывает назад!"),
					span_warning("Вы слышите, как кого-то обильно вырывает.")
				)
				do_fling(affected_mob)

/datum/disease/virus/grut_gut/proc/do_fling()
	var/fling_dir = REVERSE_DIR(affected_mob.dir)
	var/turf/general_direction = get_edge_target_turf(affected_mob, fling_dir)
	affected_mob.throw_at(general_direction, 200, 3) // YEET them til they hit something!!

/datum/disease/virus/wand_rot
	name = "Гниль жезла"
	stage_prob = 5
	cure_text = "Ацетальдегид"
	agent = "nasum magicum"
	cures = list("acetaldehyde")
	infectable_mobtypes = list(/mob/living/carbon/human)
	desc = "Магически насыщенная болезнь, которая заменяет волоски в носу крошечными жезлами. Избегайте раздражителей носа."
	severity = DISEASE_SEVERITY_DANGEROUS
	virus_heal_resistant = TRUE

/datum/disease/virus/wand_rot/wizard_variant
	show_in_records = FALSE

/datum/disease/virus/wand_rot/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(1)
			if(prob(2))
				affected_mob.emote("sniff")
		if(2)
			if(prob(3))
				affected_mob.emote("sniff")
			if(prob(3))
				to_chat(affected_mob, span_danger("Ваш нос и горло ощущаются неприятно сухими."))
		if(3)
			if(prob(2))
				affected_mob.emote("cough")
			if(prob(3))
				affected_mob.emote("sniff")
			if(prob(3))
				to_chat(affected_mob, span_danger("Ваш нос и горло ощущаются неприятно сухими."))
		if(4)
			if(prob(2))
				affected_mob.emote("cough")
			if(prob(3))
				affected_mob.emote("sneeze")
			if(prob(3))
				to_chat(affected_mob, span_danger("Ваше горло горит и чешется!"))

		if(5)
			if(prob(2))
				affected_mob.emote("cough")
			if(prob(2))
				to_chat(affected_mob, span_danger("Ваш нос словно сейчас сгорит прямо на вашем лице!"))
				affected_mob.adjustFireLoss(5)
			if(prob(3))
				affected_mob.emote("sniff")
			if(prob(1))
				affected_mob.emote("sneeze")
				addtimer(CALLBACK(src, PROC_REF(sneeze_fireballs)), 0.2 SECONDS)

//sneeze a fireball in a random direction
/datum/disease/virus/wand_rot/proc/sneeze_fireballs()
	var/fuck_you_dir = pick(GLOB.alldirs)
	var/turf/target_tile = get_edge_target_turf(affected_mob, fuck_you_dir)
	var/obj/projectile/magic/fireball/fireball = new (affected_mob.loc)
	fireball.current = get_turf(affected_mob)
	fireball.original = target_tile
	fireball.firer = affected_mob
	fireball.preparePixelProjectile(target_tile, affected_mob)
	fireball.fire()
	playsound(affected_mob, 'sound/magic/fireball.ogg', 50, 1)

/datum/disease/virus/mystic_malaise
	name = "Мистический недуг"
	stage_prob = 5
	cure_text = "жидкая тёмная материя"
	agent = "Spatio Ventrem"
	cures = list("liquid_dark_matter")
	infectable_mobtypes = list(/mob/living/carbon/human)
	desc = "Магически насыщенная болезнь, обитающая в кишечнике и превращающая желудочные соки в космическую материю."
	severity = DISEASE_SEVERITY_DANGEROUS
	virus_heal_resistant = TRUE

/datum/disease/virus/mystic_malaise/wizard_variant
	show_in_records = FALSE

/datum/disease/virus/mystic_malaise/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(1)
			if(prob(2))
				to_chat(affected_mob, span_danger("Вас тошнит."))
		if(2)
			if(prob(3))
				to_chat(affected_mob, span_danger("У вас болит живот."))
		if(3)
			if(prob(3))
				to_chat(affected_mob, span_danger("Вы чувствуете растущую пустоту внутри."))
			if(prob(2))
				affected_mob.emote("cough")
		if(4)
			if(prob(3))
				to_chat(affected_mob, span_danger("Кажется, будто ваша грудь сейчас провалится!"))
			if(prob(2))
				affected_mob.emote("cough")
			if(prob(2))
				affected_mob.emote("groan")
		if(5)
			if(prob(2))
				affected_mob.AdjustConfused(5 SECONDS)
				playsound(get_turf(affected_mob), 'sound/effects/splat.ogg', 50, 1)
				var/turf/location = get_turf(affected_mob)
				location.add_vomit_floor(FALSE, FALSE, /obj/effect/decal/cleanable/vomit/spacematter)

/obj/effect/decal/cleanable/vomit/spacematter
	name = "spacematter vomit"
	desc = "Несмотря на опасность, она ослепительно красива. Впрочем, вам, наверное, стоит отойти от неё подальше."
	icon_state = "vomitnebula_1"
	random_icon_states = list("vomitnebula_1", "vomitnebula_2", "vomitnebula_3", "vomitnebula_4")
	no_scoop = TRUE

/obj/effect/decal/cleanable/vomit/spacematter/get_ru_names()
	return alist(
		NOMINATIVE = "космоматериальная рвота",
		GENITIVE = "космоматериальной рвоты",
		DATIVE = "космоматериальной рвоте",
		ACCUSATIVE = "космоматериальную рвоту",
		INSTRUMENTAL = "космоматериальной рвотой",
		PREPOSITIONAL = "космоматериальной рвоте",
	)

/obj/effect/decal/cleanable/vomit/spacematter/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprocessing, src)
	QDEL_IN(src, 15 SECONDS)

/obj/effect/decal/cleanable/vomit/spacematter/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/effect/decal/cleanable/vomit/spacematter/process()
	var/datum/milla_safe/spacematter_vomit_process/milla = new()
	milla.invoke_async(src)

/datum/milla_safe/spacematter_vomit_process

/datum/milla_safe/spacematter_vomit_process/on_run(obj/effect/decal/cleanable/vomit/spacematter/splatter)
	var/turf/tile = get_turf(splatter)
	var/datum/gas_mixture/environment = get_turf_air(tile)
	var/removed_moles = environment.total_moles() * (1500 / environment.volume)
	environment.remove(removed_moles)
