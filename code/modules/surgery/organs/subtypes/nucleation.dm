//NUCLEATION ORGAN
/obj/item/organ/internal/nucleation
	species_type = /datum/species/nucleation
	name = "nucleation organ"

/obj/item/organ/internal/nucleation/resonant_crystal
	name = "resonant crystal"
	desc = "Жёлтого цвета странно выглядящий кристалл. Судя по всему, он принадлежал нуклеату."
	icon_state = "resonant-crystal"
	parent_organ_zone = BODY_ZONE_HEAD
	slot = INTERNAL_ORGAN_RESONANT_CRYSTAL

/obj/item/organ/internal/nucleation/resonant_crystal/get_ru_names()
	return list(
		NOMINATIVE = "резонантный кристалл",
		GENITIVE = "резонантного кристалла",
		DATIVE = "резонантному кристаллу",
		ACCUSATIVE = "резонантный кристалл",
		INSTRUMENTAL = "резонантным кристаллом",
		PREPOSITIONAL = "резонантном кристалле",
	)

/obj/item/organ/internal/nucleation/strange_crystal
	name = "strange crystal"
	desc = "Жёлтого цвета странно выглядящий кристалл. Судя по всему, он принадлежал нуклеату."
	icon_state = "strange-crystal"
	slot = INTERNAL_ORGAN_STRANGE_CRYSTAL

/obj/item/organ/internal/nucleation/strange_crystal/get_ru_names()
	return list(
		NOMINATIVE = "странный кристалл",
		GENITIVE = "странного кристалла",
		DATIVE = "странному кристаллу",
		ACCUSATIVE = "странный кристалл",
		INSTRUMENTAL = "странным кристаллом",
		PREPOSITIONAL = "странном кристалле",
	)

/obj/item/organ/internal/eyes/luminescent_crystal
	species_type = /datum/species/nucleation
	name = "luminescent eyes"
	desc = "Необычного вида глаза, источающие свет. Эти принадлежали нуклеату."
	icon_state = "crystal-eyes"
	light_color = "#f7f792"
	light_range = 2

/obj/item/organ/internal/eyes/luminescent_crystal/get_ru_names()
	return list(
		NOMINATIVE = "люминесцентные глаза",
		GENITIVE = "люминесцентных глаз",
		DATIVE = "люминесцентным глазам",
		ACCUSATIVE = "люминесцентные глаза",
		INSTRUMENTAL = "люминесцентными глазами",
		PREPOSITIONAL = "люминесцентных глазах",
	)

/obj/item/organ/internal/brain/crystal
	species_type = /datum/species/nucleation
	name = "crystallized brain"
	desc = "Основной орган центральной нервной системы гуманоида. Фактически, именно здесь и находится разум. Судя по кристаллизированной структуре, этот принадлежал нуклеату."
	icon_state = "crystal-brain"

/obj/item/organ/internal/brain/crystal/get_ru_names()
	return list(
		NOMINATIVE = "кристаллизированный мозг",
		GENITIVE = "кристаллизированного мозга",
		DATIVE = "кристаллизированному мозгу",
		ACCUSATIVE = "кристаллизированный мозг",
		INSTRUMENTAL = "кристаллизированным мозгом",
		PREPOSITIONAL = "кристаллизированном мозге",
	)
/obj/item/organ/internal/brain/crystal/insert(mob/living/target, special = ORGAN_MANIPULATION_DEFAULT)
	..(target, special)
	if(isnucleation(target))
		return //no need to apply disease to nucleation
	var/datum/disease/virus/nuclefication/D = new()
	D.Contract(target, need_protection_check = FALSE)
