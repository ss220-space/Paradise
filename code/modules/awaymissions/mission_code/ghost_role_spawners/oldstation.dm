//Ancient cryogenic sleepers. Players become NT crewmen from a hundred year old space station, now on the verge of collapse.

/obj/effect/mob_spawn/human/oldstation
	name = "old cryogenics pod"
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "sleeper"
	description = "Работайте в команде с другими выжившими на борту древней разрушенной космической станции."
	roundstart = FALSE
	death = FALSE
	allow_species_pick = TRUE
	allow_prefs_prompt = TRUE
	allow_gender_pick = TRUE
	allow_name_pick = TRUE
	pickable_species = list(SPECIES_HUMAN)
	mob_species = /datum/species/human
	assignedrole = "Ancient Crew"

/obj/effect/mob_spawn/human/oldstation/get_ru_names()
	return list(
		NOMINATIVE = "старая криогенная капсула",
		GENITIVE = "старой криогенной капсулы",
		DATIVE = "старой криогенной капсуле",
		ACCUSATIVE = "старую криогенную капсулу",
		INSTRUMENTAL = "старой криогенной капсулой",
		PREPOSITIONAL = "старой криогенной капсуле"
	)

/obj/effect/mob_spawn/human/oldstation/oldsec
	desc = "Гудящая криокапсула. Вы едва можете разглядеть форму службы безопасности под слоем намерзшего льда. Машина пытается разбудить своего пассажира."
	mob_name = "a security officer"
	outfit = /datum/outfit/oldstation/officer
	important_info = ""
	flavour_text = "Вы – офицер службы безопасности, работающий на НаноТрейзен, и находитесь на борту передовой исследовательской станции.\nВы смутно помните, \
	как бросились в криогенную капсулу из-за надвигающейся радиационной бури. Последнее, что вы помните, – это слова Искусственного Интеллекта станции о том, что вы \
	проспите всего восемь часов.\nКогда вы открываете глаза, всё вокруг кажется ржавым и разрушенным, а в животе нарастает тёмное предчувствие, пока вы выбираетесь из капсулы."

/obj/effect/mob_spawn/human/oldstation/oldmed
	desc = "Гудящая криокапсула. Вы едва можете разглядеть медицинскую форму под слоем намерзшего льда. Машина пытается разбудить своего пассажира."
	mob_name = "a medical doctor"
	outfit = /datum/outfit/oldstation/medic
	important_info = ""
	flavour_text = "Вы – врач, работающий на НаноТрейзен, и находитесь на борту передовой исследовательской станции.\nВы смутно помните, \
	как бросились в криогенную капсулу из-за надвигающейся радиационной бури. Последнее, что вы помните, – это слова Искусственного Интеллекта станции о том, что вы \
	проспите всего восемь часов.\nКогда вы открываете глаза, всё вокруг кажется ржавым и разрушенным, а в животе нарастает тёмное предчувствие, пока вы выбираетесь из капсулы."

/obj/effect/mob_spawn/human/oldstation/oldeng
	desc = "Гудящая криокапсула. Вы едва можете разглядеть инженерную форму под слоем намерзшего льда. Машина пытается разбудить своего пассажира."
	mob_name = "an engineer"
	outfit = /datum/outfit/oldstation/engineer
	important_info = ""
	flavour_text = "Вы – инженер, работающий на НаноТрейзен, и находитесь на борту передовой исследовательской станции.\nВы смутно помните, \
	как бросились в криогенную капсулу из-за надвигающейся радиационной бури. Последнее, что вы помните, – это слова Искусственного Интеллекта станции о том, что вы \
	проспите всего восемь часов.\nКогда вы открываете глаза, всё вокруг кажется ржавым и разрушенным, а в животе нарастает тёмное предчувствие, пока вы выбираетесь из капсулы."

/obj/effect/mob_spawn/human/oldstation/oldsci
	desc = "Гудящая криокапсула. Вы едва можете разглядеть форму учёного под слоем намерзшего льда. Машина пытается разбудить своего пассажира."
	mob_name = "a scientist"
	outfit = /datum/outfit/oldstation/scientist
	important_info = ""
	flavour_text = "Вы – учёный, работающий на НаноТрейзен, и находитесь на борту передовой исследовательской станции.\nВы смутно помните, \
	как бросились в криогенную капсулу из-за надвигающейся радиационной бури. Последнее, что вы помните, – это слова Искусственного Интеллекта станции о том, что вы \
	проспите всего восемь часов.\nКогда вы открываете глаза, всё вокруг кажется ржавым и разрушенным, а в животе нарастает тёмное предчувствие, пока вы выбираетесь из капсулы."

/obj/structure/showcase/machinery/oldpod
	name = "damaged cryogenic pod"
	desc = "Повреждённая криогенная капсула, давно забытая временем, как и её бывший пассажир..."
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "sleeper-open"

/obj/structure/showcase/machinery/oldpod/get_ru_names()
	return list(
		NOMINATIVE = "повреждённая криогенная капсула",
		GENITIVE = "повреждённой криогенной капсулы",
		DATIVE = "повреждённой криогенной капсуле",
		ACCUSATIVE = "повреждённую криогенную капсулу",
		INSTRUMENTAL = "повреждённой криогенной капсулой",
		PREPOSITIONAL = "повреждённой криогенной капсуле"
	)

/obj/structure/showcase/machinery/oldpod/used
	name = "Открытая криогенная капсула"
	desc = "Криогенная капсула, которая недавно выпустила своего пассажира. Капсула кажется неработоспособной."

/obj/structure/showcase/machinery/oldpod/used/get_ru_names()
	return list(
		NOMINATIVE = "открытая криогенная капсула",
		GENITIVE = "открытой криогенной капсулы",
		DATIVE = "открытой криогенной капсуле",
		ACCUSATIVE = "открытую криогенную капсулу",
		INSTRUMENTAL = "открытой криогенной капсулой",
		PREPOSITIONAL = "открытой криогенной капсуле"
	)

/datum/outfit/oldstation/post_equip(mob/living/carbon/human/H)
	. = ..()
	H.remove_language(LANGUAGE_GALACTIC_COMMON)
	H.set_default_language(GLOB.all_languages[LANGUAGE_SOL_COMMON])
	H.dna.species.default_language = LANGUAGE_SOL_COMMON

/datum/outfit/oldstation/officer
	name = "Old station officer"
	uniform = /obj/item/clothing/under/retro/security
	shoes = /obj/item/clothing/shoes/jackboots
	id = /obj/item/card/id/away/old/sec
	r_pocket = /obj/item/restraints/handcuffs
	l_pocket = /obj/item/flash

/datum/outfit/oldstation/medic
	name = "Old station medic"
	uniform = /obj/item/clothing/under/retro/medical
	shoes = /obj/item/clothing/shoes/black
	id = /obj/item/card/id/away/old/med
	l_pocket = /obj/item/stack/medical/ointment
	r_pocket = /obj/item/stack/medical/ointment

/datum/outfit/oldstation/engineer
	name = "Old station engineer"
	uniform = /obj/item/clothing/under/retro/engineering
	shoes = /obj/item/clothing/shoes/workboots
	id = /obj/item/card/id/away/old/eng
	gloves = /obj/item/clothing/gloves/color/fyellow/old
	l_pocket = /obj/item/tank/internals/emergency_oxygen

/datum/outfit/oldstation/scientist
	name = "Old station scientist"
	uniform = /obj/item/clothing/under/retro/science
	shoes = /obj/item/clothing/shoes/laceup
	id = /obj/item/card/id/away/old/sci
	l_pocket = /obj/item/stack/medical/bruise_pack

/obj/effect/mob_spawn/human/oldstation/special(mob/living/carbon/human/H)
	GLOB.human_names_list += H.real_name
	return ..()

/obj/effect/mob_spawn/human/oldstation/Destroy()
	new /obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()
