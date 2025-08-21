/*
 * Science
 */
/obj/item/clothing/under/rank/research_director
	name = "research director's jumpsuit"
	desc = "Это комбинезон, который носят люди, которые достаточно умны, чтобы получить должность научного руководителя. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "director"
	item_state = "g_suit"
	item_color = "director"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 10, BIO = 10, RAD = 0, FIRE = 0, ACID = 35)

/obj/item/clothing/under/rank/research_director/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон научного руководителя",
		GENITIVE = "комбинезона научного руководителя",
		DATIVE = "комбинезону научного руководителя",
		ACCUSATIVE = "комбинезон научного руководителя",
		INSTRUMENTAL = "комбинезоном научного руководителя",
		PREPOSITIONAL = "комбинезоне научного руководителя"
	)

/obj/item/clothing/under/rank/scientist
	name = "scientist's jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец - учёный. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "toxins"
	item_state = "w_suit"
	item_color = "toxinswhite"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 10, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/scientist/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон учёного",
		GENITIVE = "комбинезона учёного",
		DATIVE = "комбинезону учёного",
		ACCUSATIVE = "комбинезон учёного",
		INSTRUMENTAL = "комбинезоном учёного",
		PREPOSITIONAL = "комбинезоне учёного"
	)

/obj/item/clothing/under/rank/scientist/skirt
	name = "scientist's jumpskirt"
	desc = "Эта юбка обладает специальными знаками, которые обозначают то, что её владелец - учёный. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "sciencewhitef"
	item_color = "sciencewhitef"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/scientist/skirt/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон-юбка учёного",
		GENITIVE = "комбинезона-юбки учёного",
		DATIVE = "комбинезону-юбке учёного",
		ACCUSATIVE = "комбинезон-юбку учёного",
		INSTRUMENTAL = "комбинезоном-юбкой учёного",
		PREPOSITIONAL = "комбинезоне-юбке учёного"
	)

/obj/item/clothing/under/rank/scientist/student
	name = "scientist student jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец - учёный-практикант. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "student_s"
	item_color = "student"

/obj/item/clothing/under/rank/scientist/student/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон учёного-практиканта",
		GENITIVE = "комбинезона учёного-практиканта",
		DATIVE = "комбинезону учёного-практиканта",
		ACCUSATIVE = "комбинезон учёного-практиканта",
		INSTRUMENTAL = "комбинезоном учёного-практиканта",
		PREPOSITIONAL = "комбинезоне учёного-практиканта"
	)

/obj/item/clothing/under/rank/scientist/student/skirt
	name = "scientist student jumpskirt"
	desc = "Эта юбка обладает специальными знаками, которые обозначают то, что её владелец - учёный-практикант. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "studentf_s"
	item_color = "studentf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/scientist/student/skirt/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон-юбка учёного-практиканта",
		GENITIVE = "комбинезона-юбки учёного-практиканта",
		DATIVE = "комбинезону-юбке учёного-практиканта",
		ACCUSATIVE = "комбинезон-юбку учёного-практиканта",
		INSTRUMENTAL = "комбинезоном-юбкой учёного-практиканта",
		PREPOSITIONAL = "комбинезоне-юбке учёного-практиканта"
	)

/obj/item/clothing/under/rank/scientist/student/assistant
	name = "scientist assistant jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец - научный ассистент. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "sci_ass_s"
	item_color = "sci_ass"

/obj/item/clothing/under/rank/scientist/student/assistant/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон научного ассистента",
		GENITIVE = "комбинезона научного ассистента",
		DATIVE = "комбинезону научного ассистента",
		ACCUSATIVE = "комбинезон научного ассистента",
		INSTRUMENTAL = "комбинезоном научного ассистента",
		PREPOSITIONAL = "комбинезоне научного ассистента"
	)

/obj/item/clothing/under/rank/scientist/student/assistant/skirt
	name = "scientist assistant jumpskirt"
	desc = "Эта юбка обладает специальными знаками, которые обозначают то, что её владелец - научный ассистент. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "sci_ass_f_s"
	item_color = "sci_ass_f"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/scientist/student/assistant/skirt/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон-юбка научного ассистента",
		GENITIVE = "комбинезона-юбки научного ассистента",
		DATIVE = "комбинезону-юбке научного ассистента",
		ACCUSATIVE = "комбинезон-юбку научного ассистента",
		INSTRUMENTAL = "комбинезоном-юбкой научного ассистента",
		PREPOSITIONAL = "комбинезоне-юбке научного ассистента"
	)

/obj/item/clothing/under/rank/chemist
	name = "chemist's jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец - химик. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "chemistry"
	item_state = "w_suit"
	item_color = "chemistrywhite"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 50, ACID = 65)

/obj/item/clothing/under/rank/chemist/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон химика",
		GENITIVE = "комбинезона химика",
		DATIVE = "комбинезону химика",
		ACCUSATIVE = "комбинезон химика",
		INSTRUMENTAL = "комбинезоном химика",
		PREPOSITIONAL = "комбинезоне химика"
	)

/obj/item/clothing/under/rank/chemist/skirt
	name = "chemist's jumpskirt"
	desc = "Эта юбка обладает специальными знаками, которые обозначают то, что её владелец - химик. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "chemistrywhitef"
	item_color = "chemistrywhitef"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/chemist/skirt/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон-юбка химика",
		GENITIVE = "комбинезона-юбки химика",
		DATIVE = "комбинезону-юбке химика",
		ACCUSATIVE = "комбинезон-юбку химика",
		INSTRUMENTAL = "комбинезоном-юбкой химика",
		PREPOSITIONAL = "комбинезоне-юбке химика"
	)

/*
 * Medical
 */
/obj/item/clothing/under/rank/chief_medical_officer
	name = "chief medical officer's jumpsuit"
	desc = "Этот комбинезон носят те, которые обладают достаточным опытом, чтобы дослужиться до звания главного врача. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "cmo"
	item_state = "w_suit"
	item_color = "cmo"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/chief_medical_officer/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон главного врача",
		GENITIVE = "комбинезона главного врача",
		DATIVE = "комбинезону главного врача",
		ACCUSATIVE = "комбинезон главного врача",
		INSTRUMENTAL = "комбинезоном главного врача",
		PREPOSITIONAL = "комбинезоне главного врача"
	)

/obj/item/clothing/under/rank/chief_medical_officer/skirt
	name = "chief medical officer's jumpskirt"
	desc = "Эту юбку носят те, которые обладают достаточным опытом, чтобы дослужиться до звания главного врача. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "cmof"
	item_color = "cmof"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/chief_medical_officer/skirt/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон-юбка главного врача",
		GENITIVE = "комбинезона-юбки главного врача",
		DATIVE = "комбинезону-юбке главного врача",
		ACCUSATIVE = "комбинезон-юбку главного врача",
		INSTRUMENTAL = "комбинезоном-юбкой главного врача",
		PREPOSITIONAL = "комбинезоне-юбке главного врача"
	)

/obj/item/clothing/under/rank/geneticist
	name = "geneticist's jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец - генетик. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "genetics"
	item_state = "w_suit"
	item_color = "geneticswhite"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/geneticist/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон генетика",
		GENITIVE = "комбинезона генетика",
		DATIVE = "комбинезону генетика",
		ACCUSATIVE = "комбинезон генетика",
		INSTRUMENTAL = "комбинезоном генетика",
		PREPOSITIONAL = "комбинезоне генетика"
	)

/obj/item/clothing/under/rank/geneticist/skirt
	name = "geneticist's jumpskirt"
	desc = "Эта юбка обладает специальными знаками, которые обозначают то, что её владелец - генетик. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "geneticswhitef"
	item_color = "geneticswhitef"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/geneticist/skirt/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон-юбка генетика",
		GENITIVE = "комбинезона-юбки генетика",
		DATIVE = "комбинезону-юбке генетика",
		ACCUSATIVE = "комбинезон-юбку генетика",
		INSTRUMENTAL = "комбинезоном-юбкой генетика",
		PREPOSITIONAL = "комбинезоне-юбке генетика"
	)

/obj/item/clothing/under/rank/virologist
	name = "virologist's jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец - вирусолог. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "virology"
	item_state = "w_suit"
	item_color = "virologywhite"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/virologist/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон вирусолога",
		GENITIVE = "комбинезона вирусолога",
		DATIVE = "комбинезону вирусолога",
		ACCUSATIVE = "комбинезон вирусолога",
		INSTRUMENTAL = "комбинезоном вирусолога",
		PREPOSITIONAL = "комбинезоне вирусолога"
	)

/obj/item/clothing/under/rank/virologist/skirt
	name = "virologist's jumpskirt"
	desc = "Эта юбка обладает специальными знаками, которые обозначают то, что её владелец - вирусолог. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "virologywhitef"
	item_color = "virologywhitef"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/virologist/skirt/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон-юбка вирусолога",
		GENITIVE = "комбинезона-юбки вирусолога",
		DATIVE = "комбинезону-юбке вирусолога",
		ACCUSATIVE = "комбинезон-юбку вирусолога",
		INSTRUMENTAL = "комбинезоном-юбкой вирусолога",
		PREPOSITIONAL = "комбинезоне-юбке вирусолога"
	)

/obj/item/clothing/under/rank/nursesuit
	name = "nurse's suit"
	desc = "Этот костюм обычно носит сестринский персонал в медицинском отделе."
	icon_state = "nursesuit"
	item_state = "nursesuit"
	item_color = "nursesuit"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/nursesuit/get_ru_names()
	return list(
		NOMINATIVE = "костюм медсестры",
		GENITIVE = "костюма медсестры",
		DATIVE = "костюму медсестры",
		ACCUSATIVE = "костюм медсестры",
		INSTRUMENTAL = "костюмом медсестры",
		PREPOSITIONAL = "костюме медсестры"
	)

/obj/item/clothing/under/rank/nurse
	name = "nurse's dress"
	desc = "Это платье обычно носит сестринский персонал в медицинском отделе."
	gender = NEUTER
	icon_state = "nurse"
	item_state = "nurse"
	item_color = "nurse"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/nurse/get_ru_names()
	return list(
		NOMINATIVE = "платье медсестры",
		GENITIVE = "платья медсестры",
		DATIVE = "платью медсестры",
		ACCUSATIVE = "платье медсестры",
		INSTRUMENTAL = "платьем медсестры",
		PREPOSITIONAL = "платье медсестры"
	)

/obj/item/clothing/under/rank/orderly
	name = "orderly's uniform"
	desc = "Белый костюм, который обычно носят санитары, любящие, чтобы всё было упорядочено."
	gender = FEMALE
	icon_state = "orderly"
	item_state = "orderly"
	item_color = "orderly"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/orderly/get_ru_names()
	return list(
		NOMINATIVE = "униформа санитара",
		GENITIVE = "униформы санитара",
		DATIVE = "униформе санитара",
		ACCUSATIVE = "униформу санитара",
		INSTRUMENTAL = "униформе санитара",
		PREPOSITIONAL = "униформе санитара"
	)

/obj/item/clothing/under/rank/medical
	name = "medical doctor's jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец - врач. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "medical"
	item_state = "w_suit"
	item_color = "medical"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/medical/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон врача",
		GENITIVE = "комбинезона врача",
		DATIVE = "комбинезону врача",
		ACCUSATIVE = "комбинезон врача",
		INSTRUMENTAL = "комбинезоном врача",
		PREPOSITIONAL = "комбинезоне врача"
	)

/obj/item/clothing/under/rank/medical/sensor
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/medical/intern
	name = "intern jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец - интерн. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "intern_s"
	item_color = "intern"

/obj/item/clothing/under/rank/medical/intern/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон интерна",
		GENITIVE = "комбинезона интерна",
		DATIVE = "комбинезону интерна",
		ACCUSATIVE = "комбинезон интерна",
		INSTRUMENTAL = "комбинезоном интерна",
		PREPOSITIONAL = "комбинезоне интерна"
	)

/obj/item/clothing/under/rank/medical/intern/skirt
	name = "intern jumpskirt"
	desc = "Эта юбка обладает специальными знаками, которые обозначают то, что её владелец - интерн. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "internf_s"
	item_color = "internf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/intern/skirt/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон-юбка интерна",
		GENITIVE = "комбинезона-юбки интерна",
		DATIVE = "комбинезону-юбке интерна",
		ACCUSATIVE = "комбинезон-юбку интерна",
		INSTRUMENTAL = "комбинезоном-юбкой интерна",
		PREPOSITIONAL = "комбинезоне-юбке интерна"
	)

/obj/item/clothing/under/rank/medical/intern/assistant
	name = "medical assistant jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец - ассистирующий врач. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "med_ass_s"
	item_color = "med_ass"

/obj/item/clothing/under/rank/medical/intern/assistant/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон ассистирующего врача",
		GENITIVE = "комбинезона ассистирующего врача",
		DATIVE = "комбинезону ассистирующего врача",
		ACCUSATIVE = "комбинезон ассистирующего врача",
		INSTRUMENTAL = "комбинезоном ассистирующего врача",
		PREPOSITIONAL = "комбинезоне ассистирующего врача"
	)

/obj/item/clothing/under/rank/medical/intern/assistant/skirt
	name = "medical assistant jumpskirt"
	desc = "Эта юбка обладает специальными знаками, которые обозначают то, что её владелец - ассистирующий врач. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "med_ass_f_s"
	item_color = "med_ass_f"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/intern/assistant/skirt/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон-юбка ассистирующего врача",
		GENITIVE = "комбинезона-юбки ассистирующего врача",
		DATIVE = "комбинезону-юбке ассистирующего врача",
		ACCUSATIVE = "комбинезон-юбку ассистирующего врача",
		INSTRUMENTAL = "комбинезоном-юбкой ассистирующего врача",
		PREPOSITIONAL = "комбинезоне-юбке ассистирующего врача"
	)

/obj/item/clothing/under/rank/medical/skirt
	name = "medical doctor's jumpskirt"
	desc = "Эта юбка обладает специальными знаками, которые обозначают то, что её владелец - врач. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "medicalf"
	item_color = "medicalf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/skirt/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон-юбка врача",
		GENITIVE = "комбинезона-юбки врача",
		DATIVE = "комбинезону-юбке врача",
		ACCUSATIVE = "комбинезон-юбку врача",
		INSTRUMENTAL = "комбинезоном-юбкой врача",
		PREPOSITIONAL = "комбинезоне-юбке врача"
	)

/obj/item/clothing/under/rank/medical/blue
	name = "blue medical scrubs"
	desc = "Специализированная врачебная одежда, которую носят во время операций. Эта окрашена в голубой цвет. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	gender = FEMALE
	icon_state = "scrubsblue"
	item_state = "scrubsblue"
	item_color = "scrubsblue"

/obj/item/clothing/under/rank/medical/blue/get_ru_names()
	return list(
		NOMINATIVE = "голубая медицинская одежда",
		GENITIVE = "голубой медицинской одежды",
		DATIVE = "голубой медицинской одежде",
		ACCUSATIVE = "голубую медицинскую одежду",
		INSTRUMENTAL = "голубой медицинской одеждой",
		PREPOSITIONAL = "голубой медицинской одежде"
	)

/obj/item/clothing/under/rank/medical/green
	name = "dark green medical scrubs"
	desc = "Специализированная врачебная одежда, которую носят во время операций. Эта окрашена в тёмно-зелёный цвет. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	gender = FEMALE
	icon_state = "scrubsdarkgreen"
	item_state = "scrubsdarkgreen"
	item_color = "scrubsdarkgreen"

/obj/item/clothing/under/rank/medical/green/get_ru_names()
	return list(
		NOMINATIVE = "тёмно-зелёная медицинская одежда",
		GENITIVE = "тёмно-зелёной медицинской одежды",
		DATIVE = "тёмно-зелёной медицинской одежде",
		ACCUSATIVE = "тёмно-зелёную медицинскую одежду",
		INSTRUMENTAL = "тёмно-зелёной медицинской одеждой",
		PREPOSITIONAL = "тёмно-зелёной медицинской одежде"
	)

/obj/item/clothing/under/rank/medical/lightgreen
	name = "medical scrubs"
	desc = "Специализированная врачебная одежда, которую носят во время операций. Эта окрашена в зелёный цвет. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	gender = FEMALE
	icon_state = "scrubsgreen"
	item_state = "scrubsgreen"
	item_color = "scrubsgreen"

/obj/item/clothing/under/rank/medical/lightgreen/get_ru_names()
	return list(
		NOMINATIVE = "зелёная медицинская одежда",
		GENITIVE = "зелёной медицинской одежды",
		DATIVE = "зелёной медицинской одежде",
		ACCUSATIVE = "зелёную медицинскую одежду",
		INSTRUMENTAL = "зелёной медицинской одеждой",
		PREPOSITIONAL = "зелёной медицинской одежде"
	)

/obj/item/clothing/under/rank/medical/purple
	name = "purple medical scrubs"
	desc = "Специализированная врачебная одежда, которую носят во время операций. Эта окрашена в фиолетовый цвет. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	gender = FEMALE
	icon_state = "scrubspurple"
	item_state = "scrubspurple"
	item_color = "scrubspurple"

/obj/item/clothing/under/rank/medical/purple/get_ru_names()
	return list(
		NOMINATIVE = "фиолетовая медицинская одежда",
		GENITIVE = "фиолетовой медицинской одежды",
		DATIVE = "фиолетовой медицинской одежде",
		ACCUSATIVE = "фиолетовую медицинскую одежду",
		INSTRUMENTAL = "фиолетовой медицинской одеждой",
		PREPOSITIONAL = "фиолетовой медицинской одежде"
	)

/obj/item/clothing/under/rank/medical/mortician
	name = "coroner's scrubs"
	desc = "Специализированная врачебная одежда, которую носят во время операций. Эта окрашена в траурно-чёрный цвет. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	gender = FEMALE
	icon_state = "scrubsblack"
	item_state = "scrubsblack"
	item_color = "scrubsblack"

/obj/item/clothing/under/rank/medical/mortician/get_ru_names()
	return list(
		NOMINATIVE = "одежда патологоанатома",
		GENITIVE = "одежды патологоанатома",
		DATIVE = "одежде патологоанатома",
		ACCUSATIVE = "одежду патологоанатома",
		INSTRUMENTAL = "одеждой патологоанатома",
		PREPOSITIONAL = "одежде патологоанатома"
	)

//paramedic
/obj/item/clothing/under/rank/medical/paramedic
	name = "paramedic's jumpsuit"
	desc = "Этот комбинезон обладает красным крестом на груди, обозначающим, что перед вами профессиональный парамедик. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения и радиации."
	icon_state = "paramedic"
	item_state = "paramedic"
	item_color = "paramedic"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 10, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/medical/paramedic/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон парамедика",
		GENITIVE = "комбинезона парамедика",
		DATIVE = "комбинезону парамедика",
		ACCUSATIVE = "комбинезон парамедика",
		INSTRUMENTAL = "комбинезоном парамедика",
		PREPOSITIONAL = "комбинезоне парамедика"
	)

/obj/item/clothing/under/rank/medical/paramedic/skirt
	name = "paramedic's jumpskirt"
	desc = "Эта юбка обладает красным крестом на груди, обозначающим, что перед вами профессиональный парамедик. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения и радиации."
	icon_state = "paramedicf"
	item_state = "paramedicf"
	item_color = "paramedicf"

/obj/item/clothing/under/rank/medical/paramedic/skirt/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон-юбка парамедика",
		GENITIVE = "комбинезона-юбки парамедика",
		DATIVE = "комбинезону-юбке парамедика",
		ACCUSATIVE = "комбинезон-юбку парамедика",
		INSTRUMENTAL = "комбинезоном-юбкой парамедика",
		PREPOSITIONAL = "комбинезоне-юбке парамедика"
	)

/obj/item/clothing/under/rank/psych
	name = "psychiatrist's jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец - психиатр."
	icon_state = "psych"
	item_state = "w_suit"
	item_color = "psych"

/obj/item/clothing/under/rank/psych/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон психиатра",
		GENITIVE = "комбинезона психиатра",
		DATIVE = "комбинезону психиатра",
		ACCUSATIVE = "комбинезон психиатра",
		INSTRUMENTAL = "комбинезоном психиатра",
		PREPOSITIONAL = "комбинезоне психиатра"
	)

/obj/item/clothing/under/rank/psych/skirt
	name = "psychiatrist's jumpskirt"
	desc = "Эта юбка обладает специальными знаками, которые обозначают то, что её владелец - психиатр."
	icon_state = "psychf"
	item_state = "w_suit"
	item_color = "psychf"

/obj/item/clothing/under/rank/psych/skirt/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон-юбка психиатра",
		GENITIVE = "комбинезона-юбки психиатра",
		DATIVE = "комбинезону-юбке психиатра",
		ACCUSATIVE = "комбинезон-юбку психиатра",
		INSTRUMENTAL = "комбинезоном-юбкой психиатра",
		PREPOSITIONAL = "комбинезоне-юбке психиатра"
	)

/obj/item/clothing/under/rank/psych/turtleneck
	name = "psychologist's turtleneck"
	desc = "Тёмно-зелёная водолазка вместе с тёмно-синими брюками. Собственность психиатра."
	gender = FEMALE
	icon_state = "psychturtle"
	item_state = "psychturtle"
	item_color = "psychturtle"

/obj/item/clothing/under/rank/psych/turtleneck/get_ru_names()
	return list(
		NOMINATIVE = "водолазка психиатра",
		GENITIVE = "водолазки психиатра",
		DATIVE = "водолазке психиатра",
		ACCUSATIVE = "водолазку психиатра",
		INSTRUMENTAL = "водолазкой психиатра",
		PREPOSITIONAL = "водолазке психиатра"
	)

/*
 * Medsci, unused (i think) stuff
 */
/obj/item/clothing/under/rank/geneticist_new
	name = "geneticist's jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец - генетик. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "genetics_new"
	item_state = "w_suit"
	item_color = "genetics_new"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/geneticist_new/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон генетика",
		GENITIVE = "комбинезона генетика",
		DATIVE = "комбинезону генетика",
		ACCUSATIVE = "комбинезон генетика",
		INSTRUMENTAL = "комбинезоном генетика",
		PREPOSITIONAL = "комбинезоне генетика"
	)

/obj/item/clothing/under/rank/chemist_new
	name = "chemist's jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец - химик. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "chemist_new"
	item_state = "w_suit"
	item_color = "chemist_new"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 50, ACID = 65)

/obj/item/clothing/under/rank/chemist_new/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон химика",
		GENITIVE = "комбинезона химика",
		DATIVE = "комбинезону химика",
		ACCUSATIVE = "комбинезон химика",
		INSTRUMENTAL = "комбинезоном химика",
		PREPOSITIONAL = "комбинезоне химика"
	)

/obj/item/clothing/under/rank/scientist_new
	name = "scientist's jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец - учёный. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения и взрывов."
	icon_state = "scientist_new"
	item_state = "w_suit"
	item_color = "scientist_new"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 10, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/scientist_new/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон учёного",
		GENITIVE = "комбинезона учёного",
		DATIVE = "комбинезону учёного",
		ACCUSATIVE = "комбинезон учёного",
		INSTRUMENTAL = "комбинезоном учёного",
		PREPOSITIONAL = "комбинезоне учёного"
	)

/obj/item/clothing/under/rank/virologist_new
	name = "virologist's jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец - вирусолог. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "virologist_new"
	item_state = "w_suit"
	item_color = "virologist_new"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/virologist_new/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон вирусолога",
		GENITIVE = "комбинезона вирусолога",
		DATIVE = "комбинезону вирусолога",
		ACCUSATIVE = "комбинезон вирусолога",
		INSTRUMENTAL = "комбинезоном вирусолога",
		PREPOSITIONAL = "комбинезоне вирусолога"
	)

/obj/item/clothing/under/rank/medical/mining_medic
	name = "mining medic's jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец - шахтёрский врач. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	species_restricted = list("exclude", "lesser form")
	icon_state = "mining_medic"
	item_state = "mining_medic"
	item_color = "mining_medic"

/obj/item/clothing/under/rank/medical/mining_medic/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон шахтёрского врача",
		GENITIVE = "комбинезона шахтёрского врача",
		DATIVE = "комбинезону шахтёрского врача",
		ACCUSATIVE = "комбинезон шахтёрского врача",
		INSTRUMENTAL = "комбинезоном шахтёрского врача",
		PREPOSITIONAL = "комбинезоне шахтёрского врача"
	)

/obj/item/clothing/under/rank/medical/mining_medic/skirt
	name = "mining medic's jumpskirt"
	desc = "Эта юбка обладает специальными знаками, которые обозначают то, что её владелец - шахтёрский врач. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	species_restricted = list("exclude", "lesser form")
	icon_state = "mining_medic_f"
	item_state = "mining_medic_f"
	item_color = "mining_medic_f"

/obj/item/clothing/under/rank/medical/mining_medic/skirt/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон-юбка шахтёрского врача",
		GENITIVE = "комбинезона-юбки шахтёрского врача",
		DATIVE = "комбинезону-юбке шахтёрского врача",
		ACCUSATIVE = "комбинезон-юбку шахтёрского врача",
		INSTRUMENTAL = "комбинезоном-юбкой шахтёрского врача",
		PREPOSITIONAL = "комбинезоне-юбке шахтёрского врача"
	)

/obj/item/clothing/under/rank/medical/brown
	name = "brown medical scrubs"
	desc = "Специализированная врачебная одежда, которую носят во время операций. Эта окрашена в коричневый цвет. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	gender = FEMALE
	species_restricted = list("exclude", "lesser form")
	icon_state = "scrubs_brown"
	item_state = "scrubs_brown"
	item_color = "scrubs_brown"

/obj/item/clothing/under/rank/medical/brown/get_ru_names()
	return list(
		NOMINATIVE = "коричневая медицинская одежда",
		GENITIVE = "коричневой медицинской одежды",
		DATIVE = "коричневой медицинской одежде",
		ACCUSATIVE = "коричневую медицинскую одежду",
		INSTRUMENTAL = "коричневой медицинской одеждой",
		PREPOSITIONAL = "коричневой медицинской одежде"
	)

/obj/item/clothing/under/rank/medical/mining_paramedic
	name = "mining paramedic's jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец - шахтёрский врач. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	species_restricted = list("exclude", "lesser form")
	icon_state = "mining_paramedic"
	item_state = "mining_paramedic"
	item_color = "mining_paramedic"

/obj/item/clothing/under/rank/medical/mining_paramedic/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон шахтёрского парамедика",
		GENITIVE = "комбинезона шахтёрского парамедика",
		DATIVE = "комбинезону шахтёрского парамедика",
		ACCUSATIVE = "комбинезон шахтёрского парамедика",
		INSTRUMENTAL = "комбинезоном шахтёрского парамедика",
		PREPOSITIONAL = "комбинезоне шахтёрского парамедика"
	)

/obj/item/clothing/under/rank/medical/mining_paramedic/skirt
	name = "mining paramedic's jumpskirt"
	desc = "Эта юбка обладает специальными знаками, которые обозначают то, что её владелец - шахтёрский врач. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	species_restricted = list("exclude", "lesser form")
	icon_state = "mining_paramedic_f"
	item_state = "mining_paramedic_f"
	item_color = "mining_paramedic_f"

/obj/item/clothing/under/rank/medical/mining_paramedic/skirt/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон-юбка шахтёрского парамедика",
		GENITIVE = "комбинезона-юбки шахтёрского парамедика",
		DATIVE = "комбинезону-юбке шахтёрского парамедика",
		ACCUSATIVE = "комбинезон-юбку шахтёрского парамедика",
		INSTRUMENTAL = "комбинезоном-юбкой шахтёрского парамедика",
		PREPOSITIONAL = "комбинезоне-юбке шахтёрского парамедика"
	)
