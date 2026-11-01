/obj/item/clothing/under/rank/service
	icon = 'icons/clothing/uniforms/service.dmi'
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/uniform.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/uniform.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/uniform.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/vulpkanin/uniform.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/uniform.dmi',
	)

/obj/item/clothing/under/rank/service/head_of_personnel
	desc = "It's a jumpsuit worn by someone who works in the position of \"Head of Personnel\"."
	name = "head of personnel's jumpsuit"
	icon_state = "hop"
	item_state = "b_suit"
	item_color = "hop"

/obj/item/clothing/under/rank/service/head_of_personnel_whimsy
	desc = "A blue jacket and red tie, with matching red cuffs! Snazzy. Wearing this makes you feel more important than your job title does."
	name = "head of personnel's suit"
	icon_state = "hopwhimsy"
	item_state = "hopwhimsy"
	item_color = "hopwhimsy"

/obj/item/clothing/under/rank/service/head_of_personnel_alt
	name = "head of personnel's suit"
	desc = "It's a suit worn by someone who works in the position of \"Head of Personnel\"."
	icon_state = "hop_alt"
	item_state = "hop_alt"
	item_color = "hop_alt"

/obj/item/clothing/under/rank/service/head_of_personnel_f
	name = "head of personnel's skirt"
	desc = "It's a skirt worn by someone who works in the position of \"Head of Personnel\"."
	icon_state = "hop_skirt"
	item_state = "hop_skirt"
	item_color = "hop_skirt"

/obj/item/clothing/under/dress/dress/hop
	name = "head of personnel dress uniform"
	desc = "Женственная мода для стильного ГП."
	icon_state = "dress_hop"
	item_color = "dress_hop"

/obj/item/clothing/under/service/dress/hop/get_ru_names()
	return alist(
		NOMINATIVE = "платье-униформа главы персонала",
		GENITIVE = "платья-униформы главы персонала",
		DATIVE = "платью-униформе главы персонала",
		ACCUSATIVE = "платье-униформу главы персонала",
		INSTRUMENTAL = "платьем-униформой главы персонала",
		PREPOSITIONAL = "платье-униформе главы персонала",
	)

/obj/item/clothing/under/service/dress/hr
	name = "human resources director uniform"
	desc = "Высший класс для любопытного директора по персоналу."
	icon_state = "huresource"
	item_color = "huresource"

/obj/item/clothing/under/service/dress/hr/get_ru_names()
	return alist(
		NOMINATIVE = "платье-униформа директора персоналу",
		GENITIVE = "платья-униформы директора персоналу.",
		DATIVE = "платью-униформе директора персоналу.",
		ACCUSATIVE = "платье-униформу директора персоналу.",
		INSTRUMENTAL = "платьем-униформой директора персоналу",
		PREPOSITIONAL = "платье-униформе директора персоналу.",
	)

/obj/item/clothing/under/rank/service/bartender
	desc = "It looks like it could use some more flair."
	name = "bartender's uniform"
	icon_state = "ba_suit"
	item_state = "ba_suit"
	item_color = "ba_suit"

/obj/item/clothing/under/rank/service/bartender/service/skirt
	name = "bartender's skirt"
	icon_state = "ba_suitf"
	item_state = "ba_suitf"
	item_color = "ba_suitf"

/obj/item/clothing/under/rank/service/chaplain
	desc = "It's a black jumpsuit, often worn by religious folk."
	name = "chaplain's jumpsuit"
	icon_state = "chaplain"
	item_state = "bl_suit"

/obj/item/clothing/under/rank/service/chaplain/skirt
	desc = "It's a black jumpskirt, often worn by religious folk."
	name = "chaplain's jumpskirt"
	icon_state = "chaplain_skirt"
	over_shoes = TRUE

/obj/item/clothing/under/rank/service/chaplain/sensor
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/service/chef
	desc = "It's an apron which is given only to the most <b>hardcore</b> chefs in space."
	name = "chef's uniform"
	icon_state = "chef"
	item_color = "chef"

/obj/item/clothing/under/rank/service/clown
	name = "clown suit"
	desc = "<i>'HONK!'</i>"
	icon_state = "clown"
	item_state = "clown"
	item_color = "clown"

/obj/item/clothing/under/rank/service/clown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg'), 50, falloff_exponent = 20) //die off quick please

/obj/item/clothing/under/rank/clown/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.mind && H.mind.assigned_role == JOB_TITLE_CLOWN)
			SSticker.score.score_clown_abuse++
	return ..()

/obj/item/clothing/under/rank/service/clown/sexy
	name = "sexy-clown suit"
	desc = "It makes you look HONKable!"
	icon_state = "sexyclown"
	item_state = "sexyclown"
	item_color = "sexyclown"

/obj/item/clothing/under/rank/service/clown/clussy
	name = "pink clown suit"
	desc = "It makes you look very HONKable!"
	icon_state = "clussy_clown"
	item_state = "clussy_clown"
	item_color = "clussy_clown"

/obj/item/clothing/under/rank/service/clown/nodrop

/obj/item/clothing/under/rank/service/clown/nodrop/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/clothing/under/rank/service/hydroponics
	desc = "It's a jumpsuit designed to protect against minor plant-related hazards."
	name = "botanist's jumpsuit"
	icon_state = "hydroponics"
	item_state = "g_suit"
	item_color = "hydroponics"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/service/hydroponics/skirt
	desc = "It's a jumpskirt designed to protect against minor plant-related hazards."
	name = "botanist's jumpskirt"
	icon_state = "hydroponicsf"
	item_color = "hydroponicsf"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/uniform.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/uniform.dmi',
	)

/obj/item/clothing/under/rank/service/janitor
	desc = "It's the official uniform of the station's janitor. It has minor protection from biohazards."
	name = "janitor's jumpsuit"
	icon_state = "janitor"
	item_color = "janitor"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/service/librarian
	name = "sensible suit"
	desc = "It's very... sensible."
	icon_state = "red_suit"
	item_state = "red_suit"
	item_color = "red_suit"

/obj/item/clothing/under/rank/service/mime
	name = "mime's outfit"
	desc = "It's not very colourful."
	icon_state = "mime"
	item_state = "mime"
	item_color = "mime"
	dying_key = DYE_REGISTRY_UNDER

/obj/item/clothing/under/rank/service/mime/nodrop

/obj/item/clothing/under/mime/rank/service/nodrop/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/clothing/under/service/mime/sexy
	name = "sexy mime outfit"
	desc = "Единственный раз, когда тебе НЕ НРАВИТСЯ смотреть на чью-то задницу."
	icon_state = "sexymime"
	item_state = "sexymime"
	item_color = "sexymime"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/rank/service/mime/sexy/get_ru_names()
	return alist(
		NOMINATIVE = "сексуальная одежда мима",
		GENITIVE = "секусальной одежды мима",
		DATIVE = "сексуальной одежде мима",
		ACCUSATIVE = "сексуальную одежду мима",
		INSTRUMENTAL = "сексуальной одеждой мима",
		PREPOSITIONAL = "сексуальной одежде мима",
	)

/obj/item/clothing/under/rank/service/mime/shorts
	name = "mime shorts"
	desc = "..."
	icon_state = "mime_shorts"
	item_state = "mime_shorts"
	item_color = "mime_shorts"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/service/mime/shorts/get_ru_names()
	return alist(
		NOMINATIVE = "шорты мима",
		GENITIVE = "шорт мима",
		DATIVE = "шортам мима",
		ACCUSATIVE = "шорты мима",
		INSTRUMENTAL = "шортами мима",
		PREPOSITIONAL = "шортах мима",
	)

/obj/item/clothing/under/rank/service/mime/skirt
	name = "sexy mime skirt"
	desc = "..."
	icon_state = "mime_skirt"
	item_state = "mime_skirt"
	item_color = "mime_skirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/service/mime/skirt/get_ru_names()
	return alist(
		NOMINATIVE = "сексуальная юбка мима",
		GENITIVE = "сексуальной юбки мима",
		DATIVE = "сексуальной юбке мима",
		ACCUSATIVE = "сексуальную юбку мима",
		INSTRUMENTAL = "сексуальной юбкой мима",
		PREPOSITIONAL = "сексуальной юбке мима",
	)


/obj/item/clothing/under/rank/service/barber
	desc = "It's a barber's uniform."
	name = "barber's uniform"
	icon_state = "barber"
	item_state = "barber"
	item_color = "barber"

/obj/item/clothing/under/rank/service/barber/skirt
	desc = "It's a barber's skirt."
	name = "barber's skirt"
	icon_state = "barberf"
	item_state = "barberf"
	item_color = "barberf"
	over_shoes = TRUE

/obj/item/clothing/under/rank/service/artist
	desc = "Formal uniform with buttons on a side"
	name = "parade chef's uniform"
	icon_state = "artist"
	item_state = "artist"
	item_color = "artist"
