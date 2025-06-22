/obj/item/clothing/mask/breath
	name = "breath mask"
	desc = "Стандартная дыхательная маска с уплотнённым ободком для герметичности. \
			Предназначена для защиты дыхательных путей от загрязнённого воздуха и обеспечения подачи дыхательной смеси через подключение к баллону с газом. \
			Обладает средней степенью проницаемости веществ и минимальным коэффициентом проницаемости газов."
	ru_names = list(
		NOMINATIVE = "дыхательная маска",
		GENITIVE = "дыхательной маски",
		DATIVE = "дыхательной маске",
		ACCUSATIVE = "дыхательную маску",
		INSTRUMENTAL = "дыхательной маской",
		PREPOSITIONAL = "дыхательной маске"
	)
	icon_state = "breath"
	item_state = "breath"
	clothing_flags = AIRTIGHT
	flags_cover = MASKCOVERSMOUTH
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.10
	permeability_coefficient = 0.50
	actions_types = list(/datum/action/item_action/adjust)
	resistance_flags = NONE
	can_toggle = TRUE
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/mask.dmi',
		SPECIES_VOX_ARMALIS = 'icons/mob/clothing/species/armalis/mask.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/mask.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/mask.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/mask.dmi',
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/mask.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_WRYN = 'icons/mob/clothing/species/wryn/mask.dmi'
	)

/obj/item/clothing/mask/breath/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/breath/click_alt(mob/living/user)
	adjustmask(user)
	return CLICK_ACTION_SUCCESS

/obj/item/clothing/mask/breath/medical
	name = "medical mask"
	desc = "Стерильная медицинская маска повышенной герметичности. \
			Обладает минимальным коэффициентом проницаемости газов и практически не пропускает вредные вещества. \
			Предназначена для анестезии при проведении хирургических операций путём ввода седативной дыхательной смеси."
	ru_names = list(
		NOMINATIVE = "медицинская маска",
		GENITIVE = "медицинской маски",
		DATIVE = "медицинской маске",
		ACCUSATIVE = "медицинскую маску",
		INSTRUMENTAL = "медицинской маской",
		PREPOSITIONAL = "медицинской маске"
	)
	icon_state = "medical"
	item_state = "medical"
	permeability_coefficient = 0.01
	put_on_delay = 10

/obj/item/clothing/mask/breath/vox
	name = "vox breath mask"
	desc = "Специализированная дыхательная маска, созданная с учётом анатомии воксов. \
			Оборудована уплотнённым ободком для герметичности. \
			Предназначена для защиты дыхательных путей от загрязнённого воздуха и обеспечения подачи дыхательной смеси через подключение к баллону с газом. \
			Обладает минимальным коэффициентом проницаемости газов и практически не пропускает вредные вещества."
	ru_names = list(
		NOMINATIVE = "дыхательная маска для воксов",
		GENITIVE = "дыхательной маски для воксов",
		DATIVE = "дыхательной маске для воксов",
		ACCUSATIVE = "дыхательную маску для воксов",
		INSTRUMENTAL = "дыхательной маской для воксов",
		PREPOSITIONAL = "дыхательной маске для воксов"
	)
	icon_state = "voxmask"
	item_state = "voxmask"
	permeability_coefficient = 0.01
	species_restricted = list(SPECIES_VOX, SPECIES_VOX_ARMALIS) //These should fit the "Mega Vox" just fine.
	actions_types = null

/obj/item/clothing/mask/breath/vox/attack_self(mob/user)
	return

/obj/item/clothing/mask/breath/vox/click_alt(mob/user)
	return NONE
