/*
 * Science
 */
/obj/item/clothing/under/rank/science
	icon = 'icons/obj/clothing/uniforms/rnd.dmi'
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 10, BIO = 0, FIRE = 0, ACID = 0)
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

/obj/item/clothing/under/rank/science/research_director
	name = "research director's jumpsuit"
	desc = "Это комбинезон, который носят люди, которые достаточно умны, чтобы получить должность научного руководителя. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "director"
	item_state = "g_suit"
	item_color = "director"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 10, BIO = 10, FIRE = 0, ACID = 35)

/obj/item/clothing/under/rank/science/research_director/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон научного руководителя",
		GENITIVE = "комбинезона научного руководителя",
		DATIVE = "комбинезону научного руководителя",
		ACCUSATIVE = "комбинезон научного руководителя",
		INSTRUMENTAL = "комбинезоном научного руководителя",
		PREPOSITIONAL = "комбинезоне научного руководителя",
	)

/obj/item/clothing/under/rank/science/dress/research_director
	name = "research director dress uniform"
	desc = "Женственная мода для стильного ДИ."
	icon_state = "dress_rd"
	item_color = "dress_rd"

/obj/item/clothing/under/rank/science/dress/research_director/get_ru_names()
	return alist(
		NOMINATIVE = "платье-униформа директора исследований",
		GENITIVE = "платья-униформы директора исследований",
		DATIVE = "платью-униформе директора исследований",
		ACCUSATIVE = "платье-униформу директора исследований",
		INSTRUMENTAL = "платьем-униформой директора исследований",
		PREPOSITIONAL = "платье-униформе директора исследований",
	)

/obj/item/clothing/under/rank/science/scientist
	name = "scientist's jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец — учёный. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "science"
	item_state = "w_suit"

/obj/item/clothing/under/rank/science/scientist/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон учёного",
		GENITIVE = "комбинезона учёного",
		DATIVE = "комбинезону учёного",
		ACCUSATIVE = "комбинезон учёного",
		INSTRUMENTAL = "комбинезоном учёного",
		PREPOSITIONAL = "комбинезоне учёного",
	)

/obj/item/clothing/under/rank/science/scientist/skirt
	name = "scientist's jumpskirt"
	desc = "Эта юбка обладает специальными знаками, которые обозначают то, что её владелец — учёный. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "sciencef"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/science/scientist/skirt/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон-юбка учёного",
		GENITIVE = "комбинезона-юбки учёного",
		DATIVE = "комбинезону-юбке учёного",
		ACCUSATIVE = "комбинезон-юбку учёного",
		INSTRUMENTAL = "комбинезоном-юбкой учёного",
		PREPOSITIONAL = "комбинезоне-юбке учёного",
	)

/obj/item/clothing/under/rank/science/student
	name = "scientist student jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец — учёный-практикант. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "student"
	item_color = "student"

/obj/item/clothing/under/rank/science/student/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон учёного-практиканта",
		GENITIVE = "комбинезона учёного-практиканта",
		DATIVE = "комбинезону учёного-практиканта",
		ACCUSATIVE = "комбинезон учёного-практиканта",
		INSTRUMENTAL = "комбинезоном учёного-практиканта",
		PREPOSITIONAL = "комбинезоне учёного-практиканта",
	)

/obj/item/clothing/under/rank/science/student/skirt
	name = "scientist student jumpskirt"
	desc = "Эта юбка обладает специальными знаками, которые обозначают то, что её владелец — учёный-практикант. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "studentf"
	item_color = "studentf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/science/student/skirt/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон-юбка учёного-практиканта",
		GENITIVE = "комбинезона-юбки учёного-практиканта",
		DATIVE = "комбинезону-юбке учёного-практиканта",
		ACCUSATIVE = "комбинезон-юбку учёного-практиканта",
		INSTRUMENTAL = "комбинезоном-юбкой учёного-практиканта",
		PREPOSITIONAL = "комбинезоне-юбке учёного-практиканта",
	)

/obj/item/clothing/under/rank/science/student/assistant
	name = "scientist assistant jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец — научный ассистент. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "sci_ass"
	item_color = "sci_ass"

/obj/item/clothing/under/rank/science/student/assistant/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон научного ассистента",
		GENITIVE = "комбинезона научного ассистента",
		DATIVE = "комбинезону научного ассистента",
		ACCUSATIVE = "комбинезон научного ассистента",
		INSTRUMENTAL = "комбинезоном научного ассистента",
		PREPOSITIONAL = "комбинезоне научного ассистента",
	)

/obj/item/clothing/under/rank/science/student/assistant/skirt
	name = "scientist assistant jumpskirt"
	desc = "Эта юбка обладает специальными знаками, которые обозначают то, что её владелец — научный ассистент. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "sci_ass_f"
	item_color = "sci_ass_f"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/science/student/assistant/skirt/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон-юбка научного ассистента",
		GENITIVE = "комбинезона-юбки научного ассистента",
		DATIVE = "комбинезону-юбке научного ассистента",
		ACCUSATIVE = "комбинезон-юбку научного ассистента",
		INSTRUMENTAL = "комбинезоном-юбкой научного ассистента",
		PREPOSITIONAL = "комбинезоне-юбке научного ассистента",
	)

/obj/item/clothing/under/rank/science/roboticist
	desc = "It's a slimming black with reinforced seams; great for industrial work."
	name = "roboticist's jumpsuit"
	icon_state = "robotics"
	item_state = "robotics"
	item_color = "robotics"

/obj/item/clothing/under/rank/science/roboticist/student
	name = "student robotist jumpsuit"	//What a good time to add a cute sprite here.

/obj/item/clothing/under/rank/science/roboticist/skirt
	desc = "It's a slimming black jumpskirt with reinforced seams; great for industrial work."
	name = "roboticist's jumpskirt"
	icon_state = "roboticsf"
	item_color = "roboticsf"

/obj/item/clothing/under/rank/science/roboticist/skirt/student
	name = "student robotist jumpskirt"	//And here too.

/obj/item/clothing/under/rank/science/mechanic
	desc = "It's a pair of overalls worn by mechanics."
	name = "mechanic's overalls"
	icon_state = "mechanic"
	item_state = "mechanic"
	item_color = "mechanic"

/*
 * Sci, unused (i think) stuff
 */
/obj/item/clothing/under/rank/science/scientist_new
	name = "scientist's jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец — учёный. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения и взрывов."
	icon_state = "scientist_new"
	item_state = "w_suit"

/obj/item/clothing/under/rank/science/scientist_new/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон учёного",
		GENITIVE = "комбинезона учёного",
		DATIVE = "комбинезону учёного",
		ACCUSATIVE = "комбинезон учёного",
		INSTRUMENTAL = "комбинезоном учёного",
		PREPOSITIONAL = "комбинезоне учёного",
	)
