/obj/item/clothing/under/rank/captain
	desc = "It's a blue jumpsuit with some gold markings denoting the rank of \"Captain\"."
	name = "captain's jumpsuit"
	icon = 'icons/clothing/uniforms/captain.dmi'
	icon_state = "captain"
	item_state = "caparmor"
	item_color = "captain"
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

/obj/item/clothing/under/rank/captain/parade
	name = "captain's parade uniform"
	desc = "Капитанская роскошная одежда, для особых случаев."
	icon_state = "captain_parade"
	item_state = "by_suit"
	item_color = "captain_parade"

/obj/item/clothing/under/rank/captain/parade/get_ru_names()
	return alist(
		NOMINATIVE = "капитанская парадная униформа",
		GENITIVE = "капитанской парадной униформы",
		DATIVE = "капитанской парадной униформе",
		ACCUSATIVE = "капитанскую парадную униформу",
		INSTRUMENTAL = "капитанской парадной униформой",
		PREPOSITIONAL = "капитанской парадной униформе",
	)

/obj/item/clothing/under/rank/captain/parade/alt
	icon_state = "cap_parade"
	item_state = "cap_parade"
	item_color = "cap_parade"

/obj/item/clothing/under/captain/parade/office
	name = "captain's office uniform"
	desc = "Для повседневной бюрократии."
	icon_state = "cap_office"
	item_state = "cap_office"
	item_color = "cap_office"

/obj/item/clothing/under/captain/parade/office/get_ru_names()
	return alist(
		NOMINATIVE = "капитанская офисная униформа",
		GENITIVE = "капитанской офисной униформы",
		DATIVE = "капитанской офисной униформе",
		ACCUSATIVE = "капитанскую офисную униформу",
		INSTRUMENTAL = "капитанской офисной униформой",
		PREPOSITIONAL = "капитанской офисной униформе",
	)

/obj/item/clothing/under/rank/captain/dress
	name = "captain dress uniform"
	desc = "Женственная мода для стильного Капитана."
	icon_state = "dress_cap"
	item_color = "dress_cap"

/obj/item/clothing/under/rank/captain/dress/get_ru_names()
	return alist(
		NOMINATIVE = "платье-униформа капитана",
		GENITIVE = "платья-униформы капитана",
		DATIVE = "платью-униформе капитана",
		ACCUSATIVE = "платье-униформу капитана",
		INSTRUMENTAL = "платьем-униформой капитана",
		PREPOSITIONAL = "платье-униформе капитана",
	)

/obj/item/clothing/under/rank/captain/dress/parade
	name = "captain parade dress uniform"
	desc = "Женственная мода для стильного Капитана."
	icon_state = "dress_parade"
	item_state = "dress_parade"
	item_color = "dress_parade"

/obj/item/clothing/under/rank/captain/dress/parade/get_ru_names()
	return alist(
		NOMINATIVE = "парадное платье-униформа капитана",
		GENITIVE = "парадного платья-униформы капитана",
		DATIVE = "парадному платью-униформе капитана",
		ACCUSATIVE = "парадное платье-униформу капитана",
		INSTRUMENTAL = "парадным платьем-униформой капитана",
		PREPOSITIONAL = "парадном платье-униформе капитана",
	)

