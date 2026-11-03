/obj/item/clothing/under/costumes
	icon = 'icons/obj/clothing/uniforms/costumes.dmi'
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

/obj/item/clothing/under/costumes/kilt
	name = "kilt"
	desc = "Плед и обувь включены."
	icon_state = "kilt"
	item_state = "kilt"
	item_color = "kilt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|FEET

/obj/item/clothing/under/costumes/kilt/get_ru_names()
	return alist(
		NOMINATIVE = "килт",
		GENITIVE = "килта",
		DATIVE = "килту",
		ACCUSATIVE = "килт",
		INSTRUMENTAL = "килтом",
		PREPOSITIONAL = "килте",
	)

/obj/item/clothing/under/costumes/gladiator
	name = "gladiator uniform"
	desc = "Вам не нравится зрелище? Разве не ради этого вы здесь?"
	icon_state = "gladiator"
	item_state = "gladiator"
	item_color = "gladiator"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	resistance_flags = NONE

/obj/item/clothing/under/costumes/gladiator/get_ru_names()
	return alist(
		NOMINATIVE = "униформа гладиатора",
		GENITIVE = "униформы гладиатора",
		DATIVE = "униформе гладиатора",
		ACCUSATIVE = "униформу гладиатора",
		INSTRUMENTAL = "униформой гладиатора",
		PREPOSITIONAL = "униформе гладиатора",
	)

/obj/item/clothing/under/costumes/roman
	name = "roman armor"
	desc = "Древняя Римская броня. Состоит из полосок металла и кожи."
	icon_state = "roman"
	item_color = "roman"
	item_state = "armor"
	strip_delay = 100
	resistance_flags = NONE

/obj/item/clothing/under/costumes/roman/get_ru_names()
	return alist(
		NOMINATIVE = "римская броня",
		GENITIVE = "римской брони",
		DATIVE = "римской броне",
		ACCUSATIVE = "римскую броню",
		INSTRUMENTAL = "римской бронёй",
		PREPOSITIONAL = "римской броне",
	)

/obj/item/clothing/under/costumes/maid
	name = "maid costume"
	desc = "Чтобы носить это, вам потребуется очень много эстрогена."
	icon_state = "meido"
	item_state = "meido"
	item_color = "meido"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/costumes/maid/get_ru_names()
	return alist(
		NOMINATIVE = "костюм горничной",
		GENITIVE = "костюма горничной",
		DATIVE = "костюму горничной",
		ACCUSATIVE = "костюм горничной",
		INSTRUMENTAL = "костюмом горничной",
		PREPOSITIONAL = "костюме горничной",
	)

/obj/item/clothing/under/costumes/maid/short
	name = "short maid costume"
	desc = "Костюм для косплея горничной."
	over_shoes = TRUE
	icon_state = "maid"
	item_state = "maid"
	item_color = "maid"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/uniform.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/uniform.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/uniform.dmi',
	)

/obj/item/clothing/under/costumes/janimaid
	name = "maid uniform"
	desc = "Простая униформа горничной, для домохозяйства."
	icon_state = "janimaid"
	item_state = "janimaid"
	item_color = "janimaid"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/costumes/janimaid/get_ru_names()
	return alist(
		NOMINATIVE = "униформа горничной",
		GENITIVE = "униформы горничной",
		DATIVE = "униформе горничной",
		ACCUSATIVE = "униформу горничной",
		INSTRUMENTAL = "униформой горничной",
		PREPOSITIONAL = "униформе горничной",
	)

/obj/item/clothing/under/costumes/schoolgirl
	name = "schoolgirl uniform"
	desc = "Это же прям как в аниме!"
	icon_state = "schoolgirl"
	item_state = "schoolgirl"
	item_color = "schoolgirl"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/costumes/schoolgirl/get_ru_names()
	return alist(
		NOMINATIVE = "униформа школьницы",
		GENITIVE = "униформы школьницы",
		DATIVE = "униформе школьницы",
		ACCUSATIVE = "униформу школьницы",
		INSTRUMENTAL = "униформой школьницы",
		PREPOSITIONAL = "униформе школьницы",
	)

/obj/item/clothing/under/costumes/jester
	name = "jester suit"
	desc = "Весёлое платьице, чтобы развлекать твоего господина, дяденька."
	icon_state = "jester"
	item_color = "jester"

/obj/item/clothing/under/costumes/jester/get_ru_names()
	return alist(
		NOMINATIVE = "костюм шута",
		GENITIVE = "костюма шута",
		DATIVE = "костюму шута",
		ACCUSATIVE = "костюм шута",
		INSTRUMENTAL = "костюмом шута",
		PREPOSITIONAL = "костюме шута",
	)

/obj/item/clothing/under/costumes/psyjump
	name = "Psychic Amp Jumpsuit"
	desc = "Костюм из странных материалов."
	icon_state = "psyamp"
	item_state = "psyamp"
	item_color = "psyamp"

/obj/item/clothing/under/costumes/psyjump/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон с пси-усилением",
		GENITIVE = "комбинезона с пси-усилением",
		DATIVE = "комбинезону с пси-усилением",
		ACCUSATIVE = "комбинезон с пси-усилением",
		INSTRUMENTAL = "комбинезоном с пси-усилением",
		PREPOSITIONAL = "комбинезоне с пси-усилением",
	)

/obj/item/clothing/under/costumes/psysuit
	name = "dark undersuit"
	desc = "Толстое, наслоенное серое нижнее бельё, выложенное проводами. Немного похоже, что носишь электрический шторм."
	icon_state = "psysuit"
	item_state = "psysuit"
	item_color = "psysuit"

/obj/item/clothing/under/costumes/psysuit/get_ru_names()
	return alist(
		NOMINATIVE = "чёрное нижнее бельё",
		GENITIVE = "чёрного нижнего белья",
		DATIVE = "чёрному нижнему белью",
		ACCUSATIVE = "чёрное нижнее бельё",
		INSTRUMENTAL = "чёрным нижним бельём",
		PREPOSITIONAL = "чёрном нижнем белье",
	)

/obj/item/clothing/under/costumes/pennywise
	name = "Pennywise Costume"
	desc = "В нём всё, чего ты когда-либо боялся."
	icon_state = "pennywise"
	item_color = "pennywise"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/costumes/pennywise/get_ru_names()
	return alist(
		NOMINATIVE = "костюм Пеннивайза",
		GENITIVE = "костюма Пеннивайза",
		DATIVE = "костюму Пеннивайза",
		ACCUSATIVE = "костюм Пеннивайза",
		INSTRUMENTAL = "костюмом Пеннивайза",
		PREPOSITIONAL = "костюме Пеннивайза",
	)

/obj/item/clothing/under/costumes/owl
	name = "owl uniform"
	desc = "Мягкий коричневый комбинезон из синтетических перьев и твёрдой убеждённости."
	icon_state = "owl"
	item_color = "owl"

/obj/item/clothing/under/costumes/owl/get_ru_names()
	return alist(
		NOMINATIVE = "костюм совы",
		GENITIVE = "костюма совы",
		DATIVE = "костюму совы",
		ACCUSATIVE = "костюм совы",
		INSTRUMENTAL = "костюмом совы",
		PREPOSITIONAL = "костюме совы",
	)

/obj/item/clothing/under/costumes/griffin
	name = "griffon uniform"
	desc = "Мягкий коричневый комбинезон с белым воротником из синтетических перьев и жаждой хаоса."
	icon_state = "griffin"
	item_color = "griffin"

/obj/item/clothing/under/costumes/griffin/get_ru_names()
	return alist(
		NOMINATIVE = "костюм грифона",
		GENITIVE = "костюма грифона",
		DATIVE = "костюму грифона",
		ACCUSATIVE = "костюм грифона",
		INSTRUMENTAL = "костюмом грифона",
		PREPOSITIONAL = "костюме грифона",
	)

/obj/item/clothing/under/costumes/victdress
	name = "black victorian dress"
	desc = "Платье в викторианском стиле, модно!"
	icon_state = "victorianblackdress"
	item_state = "victorianblackdress"
	item_color = "victorianblackdress"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	over_shoes = TRUE

/obj/item/clothing/under/costumes/victdress/get_ru_names()
	return alist(
		NOMINATIVE = "чёрное викторианское платье",
		GENITIVE = "чёрного викторианского платья",
		DATIVE = "чёрному викторианскому платью",
		ACCUSATIVE = "чёрное викторианское платье",
		INSTRUMENTAL = "чёрным викторианским платьем",
		PREPOSITIONAL = "чёрном викторианском платье",
	)

/obj/item/clothing/under/costumes/victdress/red
	name = "red victorian dress"
	icon_state = "victorianreddress"
	item_state = "victorianreddress"
	item_color = "victorianreddress"

/obj/item/clothing/under/costumes/victdress/red/get_ru_names()
	return alist(
		NOMINATIVE = "красное викторианское платье",
		GENITIVE = "красного викторианского платья",
		DATIVE = "красному викторианскому платью",
		ACCUSATIVE = "красное викторианское платье",
		INSTRUMENTAL = "красным викторианским платьем",
		PREPOSITIONAL = "красном викторианском платье",
	)

/obj/item/clothing/under/costumes/victsuit
	name = "victorian suit"
	desc = "Костюм в викторианском стиле, модно!"
	icon_state = "victorianvest"
	item_state = "victorianvest"
	item_color = "victorianvest"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/costumes/victsuit/red/get_ru_names()
	return alist(
		NOMINATIVE = "викторианский костюм",
		GENITIVE = "викторианского костюма",
		DATIVE = "викторианскому костюму",
		ACCUSATIVE = "викторианский костюм",
		INSTRUMENTAL = "викторианским костюмом",
		PREPOSITIONAL = "викторианском костюме",
	)

/obj/item/clothing/under/costumes/victsuit/redblk
	name = "red and black victorian suit"
	icon_state = "victorianblred"
	item_state = "victorianblred"
	item_color = "victorianblred"

/obj/item/clothing/under/costumes/victsuit/redblk/get_ru_names()
	return alist(
		NOMINATIVE = "красно-чёрный викторианский костюм",
		GENITIVE = "красно-чёрного викторианского костюма",
		DATIVE = "красно-чёрному викторианскому костюму",
		ACCUSATIVE = "красно-чёрный викторианский костюм",
		INSTRUMENTAL = "красно-чёрным викторианским костюмом",
		PREPOSITIONAL = "красно-чёрном викторианском костюме",
	)

/obj/item/clothing/under/costumes/victsuit/red
	name = "red victorian suit"
	icon_state = "victorianredvest"
	item_state = "victorianredvest"
	item_color = "victorianredvest"

/obj/item/clothing/under/costumes/victsuit/red/get_ru_names()
	return alist(
		NOMINATIVE = "красный викторианский костюм",
		GENITIVE = "красного викторианского костюма",
		DATIVE = "красному викторианскому костюму",
		ACCUSATIVE = "красный викторианский костюм",
		INSTRUMENTAL = "красным викторианским костюмом",
		PREPOSITIONAL = "красном викторианском костюме",
	)

/obj/item/clothing/under/costumes/captain_fly
	name = "rogue captains uniform"
	desc = "Для человека которому всё равно, ведь он всё ещё свободен."
	icon_state = "captain_fly"
	item_state = "captain_fly"
	item_color = "captain_fly"

/obj/item/clothing/under/costumes/captain_fly/get_ru_names()
	return alist(
		NOMINATIVE = "униформа капитана-изгоя",
		GENITIVE = "униформы капитана-изгоя",
		DATIVE = "униформе капитана-изгоя",
		ACCUSATIVE = "униформу капитана-изгоя",
		INSTRUMENTAL = "униформой капитана-изгоя",
		PREPOSITIONAL = "униформе капитана-изгоя",
	)

/obj/item/clothing/under/costumes/pirate
	name = "pirate outfit"
	desc = "Аррррр."
	icon_state = "pirate"
	item_state = "pirate"
	item_color = "pirate"

/obj/item/clothing/under/costumes/pirate/get_ru_names()
	return alist(
		NOMINATIVE = "наряд пирата",
		GENITIVE = "наряда пирата",
		DATIVE = "наряду пирата",
		ACCUSATIVE = "наряд пирата",
		INSTRUMENTAL = "нарядом пирата",
		PREPOSITIONAL = "наряде пирата",
	)

/obj/item/clothing/under/costumes/pirate_rags
	name = "pirate rags"
	desc = "Старый порваный набор одежды."
	icon_state = "piraterags"
	item_state = "piraterags"
	item_color = "piraterags"

/obj/item/clothing/under/costumes/pirate_rags/get_ru_names()
	return alist(
		NOMINATIVE = "лохмотья пирата",
		GENITIVE = "лохмотей пирата",
		DATIVE = "лохмотьям пирата",
		ACCUSATIVE = "лохмотья пирата",
		INSTRUMENTAL = "лохмотьями пирата",
		PREPOSITIONAL = "лохмотьях пирата",
	)

/obj/item/clothing/under/costumes/singery
	name = "yellow performer's outfit"
	desc = "Просто смотря на это, хочется петь."
	icon_state = "ysing"
	item_state = "ysing"
	item_color = "ysing"
	over_shoes = TRUE

/obj/item/clothing/under/costumes/singery/get_ru_names()
	return alist(
		NOMINATIVE = "одежда жёлтого исполнителя",
		GENITIVE = "одежды жёлтого исполнителя",
		DATIVE = "одежде жёлтого исполнителя",
		ACCUSATIVE = "одежду жёлтого исполнителя",
		INSTRUMENTAL = "одеждой жёлтого исполнителя",
		PREPOSITIONAL = "одежде жёлтого исполнителя",
	)

/obj/item/clothing/under/costumes/singerb
	name = "blue performer's outfit"
	desc = "Просто смотря на это, хочется петь."
	icon_state = "bsing"
	item_state = "bsing"
	item_color = "bsing"

/obj/item/clothing/under/costumes/singerb/get_ru_names()
	return alist(
		NOMINATIVE = "одежда синего исполнителя",
		GENITIVE = "одежды синего исполнителя",
		DATIVE = "одежде синего исполнителя",
		ACCUSATIVE = "одежду синего исполнителя",
		INSTRUMENTAL = "одеждой синего исполнителя",
		PREPOSITIONAL = "одежде синего исполнителя",
	)

/obj/item/clothing/under/costumes/sweettooth
	name = "Sweet Tooth Costume"
	desc = "Брутально выглядящий костюм, отдалённо смахивающий на клоунский. Такой отлично подошёл бы какому-нибудь серийному убийце."
	icon_state = "sweettooth_uniform"
	item_color = "sweettooth_uniform"
	body_parts_covered = UPPER_TORSO | LOWER_TORSO
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/uniform.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/uniform.dmi',
		SPECIES_KIDAN = 'icons/mob/clothing/species/kidan/uniform.dmi',
		SPECIES_WRYN = 'icons/mob/clothing/species/wryn/uniform.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/uniform.dmi',
	)

/obj/item/clothing/under/costumes/sweettooth/get_ru_names()
	return alist(
		NOMINATIVE = "Костюм Сладкоежки",
		GENITIVE = "Костюма Сладкоежки",
		DATIVE = "Костюму Сладкоежки",
		ACCUSATIVE = "Костюм Сладкоежки",
		INSTRUMENTAL = "Костюмом Сладкоежки",
		PREPOSITIONAL = "Костюме Сладкоежки",
	)
