/datum/species/resomi
	name = SPECIES_RESOMI
	name_plural = "Resomi"
	icobase = 'icons/mob/human_races/r_resomi.dmi'
	deform = 'icons/mob/human_races/r_def_resomi.dmi'
	primitive_form = null
	greater_form = null
	language = LANGUAGE_RESOMI
	damage_overlays = 'icons/mob/human_races/masks/dam_human.dmi'
	damage_mask = 'icons/mob/human_races/masks/dam_mask_human.dmi'
	blood_mask = 'icons/mob/human_races/masks/blood_human.dmi'
	unarmed_type = /datum/unarmed_attack/claws
	eyes = "eyes_s"
	tail = "tajtail"

	blurb = "Резоми — это небольшие пернатые рапторы, приспособленные к жизни в холоде. \
	Они быстро передвигаются, обладают ускоренным метаболизмом и настолько легки, что их можно переносить в руках как обычный предмет."

	speed_mod = -0.2
	toolspeedmod = -0.2
	hunger_drain_mod = 2
	max_blood = 330
	blood_regen_mod = 2.5
	inhand_sprite_offset_x = 0
	inhand_sprite_offset_y = -4
	inhand_sprite_scale = 0.8

	cold_level_1 = 180
	cold_level_2 = 130
	cold_level_3 = 70

	heat_level_1 = 320
	heat_level_2 = 370
	heat_level_3 = 600

	body_temperature = 314.15
	taste_sensitivity = TASTE_SENSITIVITY_SHARP

	total_health = 75

	clothing_flags = 0
	bodyflags = HAS_SKIN_COLOR | HAS_BODY_MARKINGS | HAS_BODY_ACCESSORY
	default_hair = "Resomi Ears"
	default_bodyacc = "Spiky tail"
	optional_body_accessory = FALSE
	inherent_traits = list(
		TRAIT_HAS_LIPS,
		TRAIT_HAS_REGENERATION,
		TRAIT_DWARF,
		TRAIT_NO_ROBOPARTS,
		TRAIT_SMALL_MOB,
	)

	blood_species = "Resomi"
	blood_color = "#d514f7"
	flesh_color = "#5f7bb0"
	base_color = "#001144"
	reagent_tag = ORGANIC
	scream_verb = "визж%(ит,ат)%"
	male_scream_sound = list('sound/voice/resomiscream.ogg')
	female_scream_sound = list('sound/voice/resomiscream.ogg')
	male_laugh_sound = list('sound/voice/resomilaugh.ogg')
	female_laugh_sound = list('sound/voice/resomilaugh.ogg')
	male_cough_sounds = list('sound/voice/resomicough.ogg')
	female_cough_sounds = list('sound/voice/resomicough.ogg')
	male_sneeze_sound = list('sound/voice/resomisneeze.ogg')
	female_sneeze_sound = list('sound/voice/resomisneeze.ogg')
	female_giggle_sound = list('sound/voice/cackle.ogg')
	male_giggle_sound = list('sound/voice/cackle.ogg')
	butt_sprite = "resomi"

	disliked_food = VEGETABLES | FRUIT | GRAIN
	liked_food = MEAT | RAW | EGG

	has_organ = list(
		INTERNAL_ORGAN_HEART = /obj/item/organ/internal/heart/resomi,
		INTERNAL_ORGAN_LUNGS = /obj/item/organ/internal/lungs/resomi,
		INTERNAL_ORGAN_LIVER = /obj/item/organ/internal/liver/resomi,
		INTERNAL_ORGAN_KIDNEYS = /obj/item/organ/internal/kidneys/resomi,
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain/resomi,
		INTERNAL_ORGAN_APPENDIX = /obj/item/organ/internal/appendix/resomi,
		INTERNAL_ORGAN_EYES = /obj/item/organ/internal/eyes/resomi,
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears/resomi,
	)
	has_limbs = list(
		BODY_ZONE_CHEST = list("path" = /obj/item/organ/external/chest),
		BODY_ZONE_PRECISE_GROIN = list("path" = /obj/item/organ/external/groin),
		BODY_ZONE_HEAD = list("path" = /obj/item/organ/external/head),
		BODY_ZONE_L_ARM = list("path" = /obj/item/organ/external/arm),
		BODY_ZONE_R_ARM = list("path" = /obj/item/organ/external/arm/right),
		BODY_ZONE_L_LEG = list("path" = /obj/item/organ/external/leg),
		BODY_ZONE_R_LEG = list("path" = /obj/item/organ/external/leg/right),
		BODY_ZONE_PRECISE_L_HAND = list("path" = /obj/item/organ/external/hand),
		BODY_ZONE_PRECISE_R_HAND = list("path" = /obj/item/organ/external/hand/right),
		BODY_ZONE_PRECISE_L_FOOT = list("path" = /obj/item/organ/external/foot),
		BODY_ZONE_PRECISE_R_FOOT = list("path" = /obj/item/organ/external/foot/right),
		BODY_ZONE_TAIL = list("path" = /obj/item/organ/external/tail),
	)

/**
 * Handles Resomi-specific setup when a mob gains this species.
 *
 * Arguments:
 * * target - The human whose species was set to Resomi.
 */
/datum/species/resomi/on_species_gain(mob/living/carbon/human/target)
	. = ..()
	target.holder_type = /obj/item/holder/humanoid
	target.pass_flags |= PASSTABLE
	target.restrict_clothing_to_species_sprites = TRUE

/**
 * Reverts Resomi-specific setup when a mob loses this species.
 *
 * Arguments:
 * * target - The human that is losing the Resomi species.
 */
/datum/species/resomi/on_species_loss(mob/living/carbon/human/target)
	. = ..()
	target.mob_size = initial(target.mob_size)
	target.holder_type = initial(target.holder_type)
	target.pass_flags &= ~PASSTABLE
	target.restrict_clothing_to_species_sprites = initial(target.restrict_clothing_to_species_sprites)

/obj/item/organ/internal/liver/resomi
	species_type = /datum/species/resomi
	name = "resomi liver"
	desc = "Печень резоми. Крошечная, но эффективно перерабатывает питательные вещества для поддержания их бешеного метаболизма."

/obj/item/organ/internal/liver/resomi/get_ru_names()
	return list(
		NOMINATIVE = "печень резоми",
		GENITIVE = "печени резоми",
		DATIVE = "печени резоми",
		ACCUSATIVE = "печень резоми",
		INSTRUMENTAL = "печенью резоми",
		PREPOSITIONAL = "печени резоми",
	)

/obj/item/organ/internal/eyes/resomi
	species_type = /datum/species/resomi
	name = "resomi eyes"
	desc = "Пара глаз резоми. Они устроены так, чтобы улавливать мельчайшие движения на высокой скорости."

/**
 * Generates the Resomi eyes icon, blended using the human's eye colour.
 *
 * Arguments:
 * * HA - The human mob providing the `eye_colour` value.
 */
/obj/item/organ/internal/eyes/resomi/generate_icon(mob/living/carbon/human/HA)
	var/icon/eyes_icon = new /icon('icons/mob/sprite_accessories/resomi/resomi_eyes.dmi', "resomi_eyes_s")
	eyes_icon.Blend(eye_colour, ICON_ADD)
	return eyes_icon

/obj/item/organ/internal/eyes/resomi/get_ru_names()
	return list(
		NOMINATIVE = "глаза резоми",
		GENITIVE = "глаз резоми",
		DATIVE = "глазам резоми",
		ACCUSATIVE = "глаза резоми",
		INSTRUMENTAL = "глазами резоми",
		PREPOSITIONAL = "глазах резоми",
	)

/obj/item/organ/internal/ears/resomi
	species_type = /datum/species/resomi
	name = "resomi ears"
	desc = "Слуховой аппарат резоми. Включает в себя структуры для управления всеми четырьмя внешними ушными раковинами."

/obj/item/organ/internal/ears/resomi/get_ru_names()
	return list(
		NOMINATIVE = "уши резоми",
		GENITIVE = "ушей резоми",
		DATIVE = "ушам резоми",
		ACCUSATIVE = "уши резоми",
		INSTRUMENTAL = "ушами резоми",
		PREPOSITIONAL = "ушах резоми",
	)

/obj/item/organ/internal/heart/resomi
	species_type = /datum/species/resomi
	name = "resomi heart"
	desc = "Сердце резоми. Бьется невероятно часто, обеспечивая циркуляцию крови в их хрупком теле."

/obj/item/organ/internal/heart/resomi/get_ru_names()
	return list(
		NOMINATIVE = "сердце резоми",
		GENITIVE = "сердца резоми",
		DATIVE = "сердцу резоми",
		ACCUSATIVE = "сердце резоми",
		INSTRUMENTAL = "сердцем резоми",
		PREPOSITIONAL = "сердце резоми",
	)

/obj/item/organ/internal/brain/resomi
	species_type = /datum/species/resomi
	name = "resomi brain"
	desc = "Мозг резоми. Крайне плотная нейронная структура, позволяющая этим существам обрабатывать информацию на огромной скорости."

/obj/item/organ/internal/brain/resomi/get_ru_names()
	return list(
		NOMINATIVE = "мозг резоми",
		GENITIVE = "мозга резоми",
		DATIVE = "мозгу резоми",
		ACCUSATIVE = "мозг резоми",
		INSTRUMENTAL = "мозгом резоми",
		PREPOSITIONAL = "мозге резоми",
	)

/obj/item/organ/internal/lungs/resomi
	species_type = /datum/species/resomi
	name = "resomi lungs"
	desc = "Пара легких резоми. Адаптированы для эффективного поглощения кислорода даже в разреженной и холодной атмосфере."

/obj/item/organ/internal/lungs/resomi/get_ru_names()
	return list(
		NOMINATIVE = "легкие резоми",
		GENITIVE = "легких резоми",
		DATIVE = "легким резоми",
		ACCUSATIVE = "легкие резоми",
		INSTRUMENTAL = "легкими резоми",
		PREPOSITIONAL = "легких резоми",
	)

/obj/item/organ/internal/kidneys/resomi
	species_type = /datum/species/resomi
	name = "resomi kidneys"
	desc = "Пара почек резоми. Очень маленькие и уязвимые для токсинов."

/obj/item/organ/internal/kidneys/resomi/get_ru_names()
	return list(
		NOMINATIVE = "почки резоми",
		GENITIVE = "почек резоми",
		DATIVE = "почкам резоми",
		ACCUSATIVE = "почки резоми",
		INSTRUMENTAL = "почками резоми",
		PREPOSITIONAL = "почках резоми",
	)

/obj/item/organ/internal/appendix/resomi
	species_type = /datum/species/resomi
	name = "resomi appendix"
	desc = "Аппендикс резоми. Рудиментарный орган, сохранившийся с тех времен, когда их предки ели более грубую пищу."

/obj/item/organ/internal/appendix/resomi/get_ru_names()
	return list(
		NOMINATIVE = "аппендикс резоми",
		GENITIVE = "аппендикса резоми",
		DATIVE = "аппендиксу резоми",
		ACCUSATIVE = "аппендикс резоми",
		INSTRUMENTAL = "аппендиксом резоми",
		PREPOSITIONAL = "аппендиксе резоми",
	)

/obj/item/organ/external/chest/resomi
	species_type = /datum/species/resomi
	name = "resomi upper body"
	desc = "Верхняя часть тела резоми. Кости здесь легкие и пористые, а кожа покрыта густыми перьями."

/obj/item/organ/external/chest/resomi/get_ru_names()
	return list(
		NOMINATIVE = "верхняя часть тела резоми",
		GENITIVE = "верхней части тела резоми",
		DATIVE = "верхней части тела резоми",
		ACCUSATIVE = "верхнюю часть тела резоми",
		INSTRUMENTAL = "верхней частью тела резоми",
		PREPOSITIONAL = "верхней части тела резоми",
	)

/obj/item/organ/external/groin/resomi
	species_type = /datum/species/resomi
	name = "resomi lower body"
	desc = "Нижняя часть тела резоми. Достаточно компактная, чтобы они могли сворачиваться в маленький комочек."

/obj/item/organ/external/groin/resomi/get_ru_names()
	return list(
		NOMINATIVE = "нижняя часть тела резоми",
		GENITIVE = "нижней части тела резоми",
		DATIVE = "нижней части тела резоми",
		ACCUSATIVE = "нижнюю часть тела резоми",
		INSTRUMENTAL = "нижней частью тела резоми",
		PREPOSITIONAL = "нижней части тела резоми",
	)

/obj/item/organ/external/head/resomi
	species_type = /datum/species/resomi
	name = "resomi head"
	desc = "Голова резоми. Выделяется своими четырьмя чуткими ушами и небольшим клювом."

/obj/item/organ/external/head/resomi/get_ru_names()
	return list(
		NOMINATIVE = "голова резоми",
		GENITIVE = "головы резоми",
		DATIVE = "голове резоми",
		ACCUSATIVE = "голову резоми",
		INSTRUMENTAL = "головой резоми",
		PREPOSITIONAL = "голове резоми",
	)

/obj/item/organ/external/arm/resomi
	species_type = /datum/species/resomi
	name = "left resomi arm"
	desc = "Левая рука резоми. Тонкая и гибкая, покрытая пухом."

/obj/item/organ/external/arm/resomi/get_ru_names()
	return list(
		NOMINATIVE = "левая рука резоми",
		GENITIVE = "левой руки резоми",
		DATIVE = "левой руке резоми",
		ACCUSATIVE = "левую руку резоми",
		INSTRUMENTAL = "левой рукой резоми",
		PREPOSITIONAL = "левой руке резоми",
	)

/obj/item/organ/external/arm/right/resomi
	species_type = /datum/species/resomi
	name = "right resomi arm"
	desc = "Правая рука резоми. Тонкая и гибкая, покрытая пухом."

/obj/item/organ/external/arm/right/resomi/get_ru_names()
	return list(
		NOMINATIVE = "правая рука резоми",
		GENITIVE = "правой руки резоми",
		DATIVE = "правой руке резоми",
		ACCUSATIVE = "правую руку резоми",
		INSTRUMENTAL = "правой рукой резоми",
		PREPOSITIONAL = "правой руке резоми",
	)

/obj/item/organ/external/leg/resomi
	species_type = /datum/species/resomi
	name = "left resomi leg"
	desc = "Левая нога резоми. Очень сильные сухожилия позволяют им совершать резкие рывки и прыжки."

/obj/item/organ/external/leg/resomi/get_ru_names()
	return list(
		NOMINATIVE = "левая нога резоми",
		GENITIVE = "левой ноги резоми",
		DATIVE = "левой ноге резоми",
		ACCUSATIVE = "левую ногу резоми",
		INSTRUMENTAL = "левой ногой резоми",
		PREPOSITIONAL = "левой ноге резоми",
	)

/obj/item/organ/external/leg/right/resomi
	species_type = /datum/species/resomi
	name = "right resomi leg"
	desc = "Правая нога резоми. Очень сильные сухожилия позволяют им совершать резкие рывки и прыжки."

/obj/item/organ/external/leg/right/resomi/get_ru_names()
	return list(
		NOMINATIVE = "правая нога резоми",
		GENITIVE = "правой ноги резоми",
		DATIVE = "правой ноге резоми",
		ACCUSATIVE = "правую ногу резоми",
		INSTRUMENTAL = "правой ногой резоми",
		PREPOSITIONAL = "правой ноге резоми",
	)

/obj/item/organ/external/hand/resomi
	species_type = /datum/species/resomi
	name = "left resomi hand"
	desc = "Левая кисть резоми. Заканчивается острыми когтями, способными к тонким манипуляциям."

/obj/item/organ/external/hand/resomi/get_ru_names()
	return list(
		NOMINATIVE = "левая кисть резоми",
		GENITIVE = "левой кисти резоми",
		DATIVE = "левой кисти резоми",
		ACCUSATIVE = "левую кисть резоми",
		INSTRUMENTAL = "левой кистью резоми",
		PREPOSITIONAL = "левой кисти резоми",
	)

/obj/item/organ/external/hand/right/resomi
	species_type = /datum/species/resomi
	name = "right resomi hand"
	desc = "Правая кисть резоми. Заканчивается острыми когтями, способными к тонким манипуляциям."

/obj/item/organ/external/hand/right/resomi/get_ru_names()
	return list(
		NOMINATIVE = "правая кисть резоми",
		GENITIVE = "правой кисти резоми",
		DATIVE = "правой кисти резоми",
		ACCUSATIVE = "правую кисть резоми",
		INSTRUMENTAL = "правой кистью резоми",
		PREPOSITIONAL = "правой кисти резоми",
	)

/obj/item/organ/external/foot/resomi
	species_type = /datum/species/resomi
	name = "left resomi foot"
	desc = "Левая стопа резоми. Имеет трехпалое строение для лучшего баланса."

/obj/item/organ/external/foot/resomi/get_ru_names()
	return list(
		NOMINATIVE = "левая стопа резоми",
		GENITIVE = "левой стопы резоми",
		DATIVE = "левой стопе резоми",
		ACCUSATIVE = "левую стопу резоми",
		INSTRUMENTAL = "левой стопой резоми",
		PREPOSITIONAL = "левой стопе резоми",
	)

/obj/item/organ/external/foot/right/resomi
	species_type = /datum/species/resomi
	name = "right resomi foot"
	desc = "Правая стопа резоми. Имеет трехпалое строение для лучшего баланса."

/obj/item/organ/external/foot/right/resomi/get_ru_names()
	return list(
		NOMINATIVE = "правая стопа резоми",
		GENITIVE = "правой стопы резоми",
		DATIVE = "правой стопе резоми",
		ACCUSATIVE = "правую стопу резоми",
		INSTRUMENTAL = "правой стопой резоми",
		PREPOSITIONAL = "правой стопе резоми",
	)
