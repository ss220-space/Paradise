/*
 * Medical
 */
/obj/item/clothing/under/rank/medical
	icon = 'icons/obj/clothing/uniforms/medical.dmi'
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 0, ACID = 0)
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

/obj/item/clothing/under/rank/medical/chief_medical_officer
	name = "chief medical officer's jumpsuit"
	desc = "Этот комбинезон носят те, которые обладают достаточным опытом, чтобы дослужиться до звания главного врача. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "cmo"
	item_state = "cmo"

/obj/item/clothing/under/rank/medical/chief_medical_officer/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон главного врача",
		GENITIVE = "комбинезона главного врача",
		DATIVE = "комбинезону главного врача",
		ACCUSATIVE = "комбинезон главного врача",
		INSTRUMENTAL = "комбинезоном главного врача",
		PREPOSITIONAL = "комбинезоне главного врача",
	)

/obj/item/clothing/under/rank/medical/chief_medical_officer/skirt
	name = "chief medical officer's jumpskirt"
	desc = "Эту юбку носят те, которые обладают достаточным опытом, чтобы дослужиться до звания главного врача. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "cmof"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/chief_medical_officer/skirt/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон-юбка главного врача",
		GENITIVE = "комбинезона-юбки главного врача",
		DATIVE = "комбинезону-юбке главного врача",
		ACCUSATIVE = "комбинезон-юбку главного врача",
		INSTRUMENTAL = "комбинезоном-юбкой главного врача",
		PREPOSITIONAL = "комбинезоне-юбке главного врача",
	)

/obj/item/clothing/under/rank/medical/chemist
	name = "chemist's jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец — химик. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "chemistry"
	item_state = "chemistry"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 50, ACID = 65)

/obj/item/clothing/under/rank/medical/chemist/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон химика",
		GENITIVE = "комбинезона химика",
		DATIVE = "комбинезону химика",
		ACCUSATIVE = "комбинезон химика",
		INSTRUMENTAL = "комбинезоном химика",
		PREPOSITIONAL = "комбинезоне химика",
	)

/obj/item/clothing/under/rank/medical/chemist/skirt
	name = "chemist's jumpskirt"
	desc = "Эта юбка обладает специальными знаками, которые обозначают то, что её владелец — химик. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "chemistryf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/chemist/skirt/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон-юбка химика",
		GENITIVE = "комбинезона-юбки химика",
		DATIVE = "комбинезону-юбке химика",
		ACCUSATIVE = "комбинезон-юбку химика",
		INSTRUMENTAL = "комбинезоном-юбкой химика",
		PREPOSITIONAL = "комбинезоне-юбке химика",
	)

/obj/item/clothing/under/rank/medical/geneticist
	name = "geneticist's jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец — генетик. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "genetics"
	item_state = "genetics"

/obj/item/clothing/under/rank/medical/geneticist/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон генетика",
		GENITIVE = "комбинезона генетика",
		DATIVE = "комбинезону генетика",
		ACCUSATIVE = "комбинезон генетика",
		INSTRUMENTAL = "комбинезоном генетика",
		PREPOSITIONAL = "комбинезоне генетика",
	)

/obj/item/clothing/under/rank/medical/geneticist/skirt
	name = "geneticist's jumpskirt"
	desc = "Эта юбка обладает специальными знаками, которые обозначают то, что её владелец — генетик. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "geneticsf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/geneticist/skirt/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон-юбка генетика",
		GENITIVE = "комбинезона-юбки генетика",
		DATIVE = "комбинезону-юбке генетика",
		ACCUSATIVE = "комбинезон-юбку генетика",
		INSTRUMENTAL = "комбинезоном-юбкой генетика",
		PREPOSITIONAL = "комбинезоне-юбке генетика",
	)

/obj/item/clothing/under/rank/medical/virologist
	name = "virologist's jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец — вирусолог. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "virology"
	item_state = "virology"

/obj/item/clothing/under/rank/medical/virologist/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон вирусолога",
		GENITIVE = "комбинезона вирусолога",
		DATIVE = "комбинезону вирусолога",
		ACCUSATIVE = "комбинезон вирусолога",
		INSTRUMENTAL = "комбинезоном вирусолога",
		PREPOSITIONAL = "комбинезоне вирусолога",
	)

/obj/item/clothing/under/rank/medical/virologist/skirt
	name = "virologist's jumpskirt"
	desc = "Эта юбка обладает специальными знаками, которые обозначают то, что её владелец — вирусолог. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "virologyf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/virologist/skirt/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон-юбка вирусолога",
		GENITIVE = "комбинезона-юбки вирусолога",
		DATIVE = "комбинезону-юбке вирусолога",
		ACCUSATIVE = "комбинезон-юбку вирусолога",
		INSTRUMENTAL = "комбинезоном-юбкой вирусолога",
		PREPOSITIONAL = "комбинезоне-юбке вирусолога",
	)

/obj/item/clothing/under/rank/medical/nursesuit
	name = "nurse's suit"
	desc = "Этот костюм обычно носит сестринский персонал в медицинском отделе."
	icon_state = "nursesuit"
	item_state = "nursesuit"

/obj/item/clothing/under/rank/medical/nursesuit/get_ru_names()
	return alist(
		NOMINATIVE = "костюм медсестры",
		GENITIVE = "костюма медсестры",
		DATIVE = "костюму медсестры",
		ACCUSATIVE = "костюм медсестры",
		INSTRUMENTAL = "костюмом медсестры",
		PREPOSITIONAL = "костюме медсестры",
	)

/obj/item/clothing/under/rank/medical/nurse
	name = "nurse's dress"
	desc = "Это платье обычно носит сестринский персонал в медицинском отделе."
	gender = NEUTER
	icon_state = "nurse"
	item_state = "nurse"

/obj/item/clothing/under/rank/medical/nurse/get_ru_names()
	return alist(
		NOMINATIVE = "платье медсестры",
		GENITIVE = "платья медсестры",
		DATIVE = "платью медсестры",
		ACCUSATIVE = "платье медсестры",
		INSTRUMENTAL = "платьем медсестры",
		PREPOSITIONAL = "платье медсестры",
	)

/obj/item/clothing/under/rank/medical/orderly
	name = "orderly's uniform"
	desc = "Белый костюм, который обычно носят санитары, любящие, чтобы всё было упорядочено."
	gender = FEMALE
	icon_state = "orderly"
	item_state = "orderly"
	permeability_coefficient = 0.50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/medical/orderly/get_ru_names()
	return alist(
		NOMINATIVE = "униформа санитара",
		GENITIVE = "униформы санитара",
		DATIVE = "униформе санитара",
		ACCUSATIVE = "униформу санитара",
		INSTRUMENTAL = "униформе санитара",
		PREPOSITIONAL = "униформе санитара",
	)

/obj/item/clothing/under/rank/medical/doctor
	name = "medical doctor's jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец — врач. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "medical"
	item_state = "medical"

/obj/item/clothing/under/rank/medical/doctor/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон врача",
		GENITIVE = "комбинезона врача",
		DATIVE = "комбинезону врача",
		ACCUSATIVE = "комбинезон врача",
		INSTRUMENTAL = "комбинезоном врача",
		PREPOSITIONAL = "комбинезоне врача",
	)

/obj/item/clothing/under/rank/medical/doctor/sensor
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/medical/intern
	name = "intern jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец — интерн. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "intern"
	item_state = "intern"

/obj/item/clothing/under/rank/medical/intern/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон интерна",
		GENITIVE = "комбинезона интерна",
		DATIVE = "комбинезону интерна",
		ACCUSATIVE = "комбинезон интерна",
		INSTRUMENTAL = "комбинезоном интерна",
		PREPOSITIONAL = "комбинезоне интерна",
	)

/obj/item/clothing/under/rank/medical/intern/skirt
	name = "intern jumpskirt"
	desc = "Эта юбка обладает специальными знаками, которые обозначают то, что её владелец — интерн. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "internf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/intern/skirt/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон-юбка интерна",
		GENITIVE = "комбинезона-юбки интерна",
		DATIVE = "комбинезону-юбке интерна",
		ACCUSATIVE = "комбинезон-юбку интерна",
		INSTRUMENTAL = "комбинезоном-юбкой интерна",
		PREPOSITIONAL = "комбинезоне-юбке интерна",
	)

/obj/item/clothing/under/rank/medical/intern/assistant
	name = "medical assistant jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец — ассистирующий врач. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "med_ass"
	item_state = "med_ass"

/obj/item/clothing/under/rank/medical/intern/assistant/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон ассистирующего врача",
		GENITIVE = "комбинезона ассистирующего врача",
		DATIVE = "комбинезону ассистирующего врача",
		ACCUSATIVE = "комбинезон ассистирующего врача",
		INSTRUMENTAL = "комбинезоном ассистирующего врача",
		PREPOSITIONAL = "комбинезоне ассистирующего врача",
	)

/obj/item/clothing/under/rank/medical/intern/assistant/skirt
	name = "medical assistant jumpskirt"
	desc = "Эта юбка обладает специальными знаками, которые обозначают то, что её владелец — ассистирующий врач. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "med_ass_f"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/intern/assistant/skirt/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон-юбка ассистирующего врача",
		GENITIVE = "комбинезона-юбки ассистирующего врача",
		DATIVE = "комбинезону-юбке ассистирующего врача",
		ACCUSATIVE = "комбинезон-юбку ассистирующего врача",
		INSTRUMENTAL = "комбинезоном-юбкой ассистирующего врача",
		PREPOSITIONAL = "комбинезоне-юбке ассистирующего врача",
	)

/obj/item/clothing/under/rank/medical/doctor/skirt
	name = "medical doctor's jumpskirt"
	desc = "Эта юбка обладает специальными знаками, которые обозначают то, что её владелец — врач. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "medicalf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/medical/doctor/skirt/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон-юбка врача",
		GENITIVE = "комбинезона-юбки врача",
		DATIVE = "комбинезону-юбке врача",
		ACCUSATIVE = "комбинезон-юбку врача",
		INSTRUMENTAL = "комбинезоном-юбкой врача",
		PREPOSITIONAL = "комбинезоне-юбке врача",
	)

/obj/item/clothing/under/rank/medical/medigown
	name = "medical gown"
	desc = "Халат, предназначенный для использования медицинским персоналом. \
			Изготовлен из лёгкой ткани с минимальной защитой от биологических загрязнений. \
			Застёжки на спине слабые и не застёгиваются должным образом, \
			что делает этот халат не самым популярным выбором среди остальной униформы."
	icon_state = "medicalgown"
	item_state = "medicalgown"
	item_color = "medicalgown"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/rank/medical/medigown/get_ru_names()
	return alist(
		NOMINATIVE = "медицинский халат",
		GENITIVE = "медицинского халата",
		DATIVE = "медицинскому халату",
		ACCUSATIVE = "медицинский халат",
		INSTRUMENTAL = "медицинским халатом",
		PREPOSITIONAL = "медицинском халате",
	)

/obj/item/clothing/under/rank/medical/scrub/blue
	name = "blue medical scrubs"
	desc = "Специализированная врачебная одежда, которую носят во время операций. Эта окрашена в голубой цвет. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	gender = FEMALE
	icon_state = "scrubsblue"
	item_state = "scrubsblue"

/obj/item/clothing/under/rank/medical/scrub/blue/get_ru_names()
	return alist(
		NOMINATIVE = "голубая медицинская одежда",
		GENITIVE = "голубой медицинской одежды",
		DATIVE = "голубой медицинской одежде",
		ACCUSATIVE = "голубую медицинскую одежду",
		INSTRUMENTAL = "голубой медицинской одеждой",
		PREPOSITIONAL = "голубой медицинской одежде",
	)

/obj/item/clothing/under/rank/medical/scrub/brown
	name = "brown medical scrubs"
	desc = "Специализированная врачебная одежда, которую носят во время операций. Эта окрашена в коричневый цвет. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	gender = FEMALE
	species_restricted = list("exclude", "lesser form")
	icon_state = "scrubs_brown"
	item_state = "scrubs_brown"

/obj/item/clothing/under/rank/medical/scrub/brown/get_ru_names()
	return alist(
		NOMINATIVE = "коричневая медицинская одежда",
		GENITIVE = "коричневой медицинской одежды",
		DATIVE = "коричневой медицинской одежде",
		ACCUSATIVE = "коричневую медицинскую одежду",
		INSTRUMENTAL = "коричневой медицинской одеждой",
		PREPOSITIONAL = "коричневой медицинской одежде",
	)

/obj/item/clothing/under/rank/medical/scrub/green
	name = "dark green medical scrubs"
	desc = "Специализированная врачебная одежда, которую носят во время операций. Эта окрашена в тёмно-зелёный цвет. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	gender = FEMALE
	icon_state = "scrubsdarkgreen"
	item_state = "scrubsdarkgreen"

/obj/item/clothing/under/rank/medical/scrub/green/get_ru_names()
	return alist(
		NOMINATIVE = "тёмно-зелёная медицинская одежда",
		GENITIVE = "тёмно-зелёной медицинской одежды",
		DATIVE = "тёмно-зелёной медицинской одежде",
		ACCUSATIVE = "тёмно-зелёную медицинскую одежду",
		INSTRUMENTAL = "тёмно-зелёной медицинской одеждой",
		PREPOSITIONAL = "тёмно-зелёной медицинской одежде",
	)

/obj/item/clothing/under/rank/medical/scrub/lightgreen
	name = "medical scrubs"
	desc = "Специализированная врачебная одежда, которую носят во время операций. Эта окрашена в зелёный цвет. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	gender = FEMALE
	icon_state = "scrubsgreen"
	item_state = "scrubsgreen"

/obj/item/clothing/under/rank/medical/scrub/lightgreen/get_ru_names()
	return alist(
		NOMINATIVE = "зелёная медицинская одежда",
		GENITIVE = "зелёной медицинской одежды",
		DATIVE = "зелёной медицинской одежде",
		ACCUSATIVE = "зелёную медицинскую одежду",
		INSTRUMENTAL = "зелёной медицинской одеждой",
		PREPOSITIONAL = "зелёной медицинской одежде",
	)

/obj/item/clothing/under/rank/medical/scrub/purple
	name = "purple medical scrubs"
	desc = "Специализированная врачебная одежда, которую носят во время операций. Эта окрашена в фиолетовый цвет. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	gender = FEMALE
	icon_state = "scrubspurple"
	item_state = "scrubspurple"

/obj/item/clothing/under/rank/medical/scrub/purple/get_ru_names()
	return alist(
		NOMINATIVE = "фиолетовая медицинская одежда",
		GENITIVE = "фиолетовой медицинской одежды",
		DATIVE = "фиолетовой медицинской одежде",
		ACCUSATIVE = "фиолетовую медицинскую одежду",
		INSTRUMENTAL = "фиолетовой медицинской одеждой",
		PREPOSITIONAL = "фиолетовой медицинской одежде",
	)

/obj/item/clothing/under/rank/medical/scrub/mortician
	name = "coroner's scrubs"
	desc = "Специализированная врачебная одежда, которую носят во время операций. Эта окрашена в траурно-чёрный цвет. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	gender = FEMALE
	icon_state = "scrubsblack"
	item_state = "scrubsblack"

/obj/item/clothing/under/rank/medical/scrub/mortician/get_ru_names()
	return alist(
		NOMINATIVE = "одежда патологоанатома",
		GENITIVE = "одежды патологоанатома",
		DATIVE = "одежде патологоанатома",
		ACCUSATIVE = "одежду патологоанатома",
		INSTRUMENTAL = "одеждой патологоанатома",
		PREPOSITIONAL = "одежде патологоанатома",
	)

//paramedic
/obj/item/clothing/under/rank/medical/paramedic
	name = "paramedic's jumpsuit"
	desc = "Этот комбинезон обладает красным крестом на груди, обозначающим, что перед вами профессиональный парамедик. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения и радиации."
	icon_state = "paramedic"
	item_state = "paramedic"

/obj/item/clothing/under/rank/medical/paramedic/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон парамедика",
		GENITIVE = "комбинезона парамедика",
		DATIVE = "комбинезону парамедика",
		ACCUSATIVE = "комбинезон парамедика",
		INSTRUMENTAL = "комбинезоном парамедика",
		PREPOSITIONAL = "комбинезоне парамедика",
	)

/obj/item/clothing/under/rank/medical/paramedic/skirt
	name = "paramedic's jumpskirt"
	desc = "Эта юбка обладает красным крестом на груди, обозначающим, что перед вами профессиональный парамедик. Она сделана из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения и радиации."
	icon_state = "paramedicf"
	item_state = "paramedicf"

/obj/item/clothing/under/rank/medical/paramedic/skirt/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон-юбка парамедика",
		GENITIVE = "комбинезона-юбки парамедика",
		DATIVE = "комбинезону-юбке парамедика",
		ACCUSATIVE = "комбинезон-юбку парамедика",
		INSTRUMENTAL = "комбинезоном-юбкой парамедика",
		PREPOSITIONAL = "комбинезоне-юбке парамедика",
	)

/obj/item/clothing/under/rank/medical/psych
	name = "psychiatrist's jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец — психиатр."
	icon_state = "psych"
	item_state = "psych"

/obj/item/clothing/under/rank/medical/psych/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон психиатра",
		GENITIVE = "комбинезона психиатра",
		DATIVE = "комбинезону психиатра",
		ACCUSATIVE = "комбинезон психиатра",
		INSTRUMENTAL = "комбинезоном психиатра",
		PREPOSITIONAL = "комбинезоне психиатра",
	)

/obj/item/clothing/under/rank/medical/psych/skirt
	name = "psychiatrist's jumpskirt"
	desc = "Эта юбка обладает специальными знаками, которые обозначают то, что её владелец — психиатр."
	icon_state = "psychf"

/obj/item/clothing/under/rank/medical/psych/skirt/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон-юбка психиатра",
		GENITIVE = "комбинезона-юбки психиатра",
		DATIVE = "комбинезону-юбке психиатра",
		ACCUSATIVE = "комбинезон-юбку психиатра",
		INSTRUMENTAL = "комбинезоном-юбкой психиатра",
		PREPOSITIONAL = "комбинезоне-юбке психиатра",
	)

/obj/item/clothing/under/rank/medical/psych/turtleneck
	name = "psychologist's turtleneck"
	desc = "Тёмно-зелёная водолазка вместе с тёмно-синими брюками. Собственность психиатра."
	gender = FEMALE
	icon_state = "psychturtle"
	item_state = "psychturtle"

/obj/item/clothing/under/rank/medical/psych/turtleneck/get_ru_names()
	return alist(
		NOMINATIVE = "водолазка психиатра",
		GENITIVE = "водолазки психиатра",
		DATIVE = "водолазке психиатра",
		ACCUSATIVE = "водолазку психиатра",
		INSTRUMENTAL = "водолазкой психиатра",
		PREPOSITIONAL = "водолазке психиатра",
	)

/*
 * Med, unused (i think) stuff
 */
/obj/item/clothing/under/rank/medical/geneticist_new
	name = "geneticist's jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец — генетик. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "genetics_new"
	item_state = "w_suit"

/obj/item/clothing/under/rank/medical/geneticist_new/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон генетика",
		GENITIVE = "комбинезона генетика",
		DATIVE = "комбинезону генетика",
		ACCUSATIVE = "комбинезон генетика",
		INSTRUMENTAL = "комбинезоном генетика",
		PREPOSITIONAL = "комбинезоне генетика",
	)

/obj/item/clothing/under/rank/medical/chemist_new
	name = "chemist's jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец — химик. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "chemist_new"
	item_state = "w_suit"

/obj/item/clothing/under/rank/medical/chemist_new/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон химика",
		GENITIVE = "комбинезона химика",
		DATIVE = "комбинезону химика",
		ACCUSATIVE = "комбинезон химика",
		INSTRUMENTAL = "комбинезоном химика",
		PREPOSITIONAL = "комбинезоне химика",
	)

/obj/item/clothing/under/rank/medical/virologist_new
	name = "virologist's jumpsuit"
	desc = "Этот комбинезон обладает специальными знаками, которые обозначают то, что его владелец — вирусолог. Он сделан из специальной ткани, предоставляющей некоторую защиту от биологического загрязнения."
	icon_state = "virologist_new"
	item_state = "w_suit"

/obj/item/clothing/under/rank/medical/virologist_new/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон вирусолога",
		GENITIVE = "комбинезона вирусолога",
		DATIVE = "комбинезону вирусолога",
		ACCUSATIVE = "комбинезон вирусолога",
		INSTRUMENTAL = "комбинезоном вирусолога",
		PREPOSITIONAL = "комбинезоне вирусолога",
	)
