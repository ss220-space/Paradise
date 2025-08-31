
//Bartender
/obj/item/clothing/head/chefhat
	name = "chef's hat"
	desc = "Этот колпак обычно носят повара для того, чтобы избежать попадания волос в еду. Судя по состоянию кухни, волосы в еде - меньшая из ваших проблем."
	icon_state = "chef"
	item_state = "chef"
	strip_delay = 10
	put_on_delay = 10
	dog_fashion = /datum/dog_fashion/head/chef

/obj/item/clothing/head/chefhat/get_ru_names()
	return list(
		NOMINATIVE = "поварской колпак",
		GENITIVE = "поварского колпака",
		DATIVE = "поварскому колпаку",
		ACCUSATIVE = "поварской колпак",
		INSTRUMENTAL = "поварским колпаком",
		PREPOSITIONAL = "поварском колпаке"
	)

//Captain
/obj/item/clothing/head/caphat
	name = "captain's hat"
	desc = "Достаточно удобная синяя шляпа, которую носят капитаны космических станции и судов НаноТрейзен. Хорошо быть королём."
	gender = FEMALE
	icon_state = "captain"
	item_state = "caphat"
	armor = list(MELEE = 25, BULLET = 15, LASER = 25, ENERGY = 10, BOMB = 25, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)
	strip_delay = 60
	dog_fashion = /datum/dog_fashion/head/captain

/obj/item/clothing/head/caphat/get_ru_names()
	return list(
		NOMINATIVE = "капитанская шляпа",
		GENITIVE = "капитанской шляпы",
		DATIVE = "капитанской шляпе",
		ACCUSATIVE = "капитанскую шляпу",
		INSTRUMENTAL = "капитанской шляпой",
		PREPOSITIONAL = "капитанской шляпе"
	)

//Captain: no longer space-worthy
/obj/item/clothing/head/caphat/parade
	name = "captain's parade cap"
	desc = "Белая капитанская фуражка с золотыми полосами. Такие фуражки носят исключительно важные персоны."
	icon_state = "capcap"
	item_state = "capcap"
	dog_fashion = null

/obj/item/clothing/head/caphat/parade/get_ru_names()
	return list(
		NOMINATIVE = "капитанская фуражка",
		GENITIVE = "капитанской фуражки",
		DATIVE = "капитанской фуражке",
		ACCUSATIVE = "капитанскую фуражку",
		INSTRUMENTAL = "капитанской фуражкой",
		PREPOSITIONAL = "капитанской фуражке"
	)

/obj/item/clothing/head/caphat/blue
	name = "captain's white parade cap"
	desc = "Белая капитанская фуражка с синими полосами. Такие фуражки носят исключительно важные персоны."
	icon_state = "cap_parade_alt"
	item_state = "cap_parade_alt"
	dog_fashion = null

/obj/item/clothing/head/caphat/blue/get_ru_names()
	return list(
		NOMINATIVE = "капитанская белая фуражка",
		GENITIVE = "капитанской белой фуражки",
		DATIVE = "капитанской белой фуражке",
		ACCUSATIVE = "капитанскую белую фуражку",
		INSTRUMENTAL = "капитанской белой фуражкой",
		PREPOSITIONAL = "капитанской белой фуражке"
	)

/obj/item/clothing/head/caphat/office
	name = "captain's blue parade cap"
	desc = "Синяя капитанская фуражка с белыми полосами. Такие фуражки носят исключительно важные персоны."
	icon_state = "cap_office"
	item_state = "cap_office"
	dog_fashion = null

/obj/item/clothing/head/caphat/office/get_ru_names()
	return list(
		NOMINATIVE = "капитанская синяя фуражка",
		GENITIVE = "капитанской синей фуражки",
		DATIVE = "капитанской синей фуражке",
		ACCUSATIVE = "капитанскую синюю фуражку",
		INSTRUMENTAL = "капитанской синей фуражкой",
		PREPOSITIONAL = "капитанской синей фуражке"
	)

/obj/item/clothing/head/caphat/beret
	name = "captain's beret"
	desc = "Синий берет, который носят капитаны космических кораблей и станций НаноТрейзен. Хорошо быть королём."
	gender = MALE
	icon_state = "cap_beret"
	item_state = "cap_beret"

/obj/item/clothing/head/caphat/beret/get_ru_names()
	return list(
		NOMINATIVE = "капитанский берет",
		GENITIVE = "капитанского берета",
		DATIVE = "капитанскому берету",
		ACCUSATIVE = "капитанский берет",
		INSTRUMENTAL = "капитанским беретом",
		PREPOSITIONAL = "капитанском берете"
	)

//Head of Personnel
/obj/item/clothing/head/hopcap
	name = "head of personnel's cap"
	desc = "Синяя фуражка, которую выдают главе персонала. Символ бюрократического контроля."
	gender = FEMALE
	icon_state = "hopcap"
	armor = list(MELEE = 25, BULLET = 15, LASER = 25, ENERGY = 10, BOMB = 25, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)
	dog_fashion = /datum/dog_fashion/head/hop

/obj/item/clothing/head/hopcap/get_ru_names()
	return list(
		NOMINATIVE = "фуражка главы персонала",
		GENITIVE = "фуражки главы персонала",
		DATIVE = "фуражке главы персонала",
		ACCUSATIVE = "фуражку главы персонала",
		INSTRUMENTAL = "фуражкой главы персонала",
		PREPOSITIONAL = "фуражке главы персонала"
	)

//Nanotrasen Representative
/obj/item/clothing/head/ntrep
	name = "Nanotrasen Representative's hat"
	desc = "Чёрная фуражкая, которую выдают представителю НаноТрейзен. Корпорация всегда начеку."
	gender = FEMALE
	icon_state = "ntrep"

/obj/item/clothing/head/ntrep/get_ru_names()
	return list(
		NOMINATIVE = "фуражка представителя НаноТрейзен",
		GENITIVE = "фуражки представителя НаноТрейзен",
		DATIVE = "фуражке представителя НаноТрейзен",
		ACCUSATIVE = "фуражку представителя НаноТрейзен",
		INSTRUMENTAL = "фуражкой представителя НаноТрейзен",
		PREPOSITIONAL = "фуражке представителя НаноТрейзен"
	)

//Research Director
/obj/item/clothing/head/beret/purple
	name = "scientist beret"
	desc = "Берет, фиолетового цвета. За науку!"
	icon_state = "beret_purple"
	item_state = "purpleberet"

/obj/item/clothing/head/beret/purple/get_ru_names()
	return list(
		NOMINATIVE = "берет учёного",
		GENITIVE = "берета учёного",
		DATIVE = "берету учёного",
		ACCUSATIVE = "берет учёного",
		INSTRUMENTAL = "беретом учёного",
		PREPOSITIONAL = "берете учёного"
	)

/obj/item/clothing/head/beret/purple/rd
	name = "research director's beret"
	desc = "Фиолетовый берет с небольшим золотым полумесяцем, прикреплённым к нему. От берета исходит запах плазмы."

/obj/item/clothing/head/beret/purple/rd/get_ru_names()
	return list(
		NOMINATIVE = "берет научного руководителя",
		GENITIVE = "берета научного руководителя",
		DATIVE = "берету научного руководителя",
		ACCUSATIVE = "берет научного руководителя",
		INSTRUMENTAL = "беретом научного руководителя",
		PREPOSITIONAL = "берете научного руководителя"
	)

//Chaplain
/obj/item/clothing/head/hooded/chaplain_hood
	name = "chaplain's hood"
	desc = "Капюшон, покрывающий голову. Позволяет сохранить тепло во время космической зимы."
	icon_state = "chaplain_hood"
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/hooded/chaplain_hood/get_ru_names()
	return list(
		NOMINATIVE = "капюшон священника",
		GENITIVE = "капюшона священника",
		DATIVE = "капюшону священника",
		ACCUSATIVE = "капюшон священника",
		INSTRUMENTAL = "капюшоном священника",
		PREPOSITIONAL = "капюшоне священника"
	)

/obj/item/clothing/head/hooded/chaplain_hood/armoured
	armor = list(MELEE = 35, BULLET = 30, LASER = 30,ENERGY = 10, BOMB = 25, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)

/obj/item/clothing/head/hooded/chaplain_hood/no_name
	name = "dark robe's hood"
	desc = "Капюшон, покрывающий голову. Позволяет сохранить тепло во время космической зимы."
	icon_state = "chaplain_hood"
	flags_inv = parent_type::flags_inv|HIDENAME

/obj/item/clothing/head/hooded/chaplain_hood/no_name/get_ru_names()
	return list(
		NOMINATIVE = "капюшон от тёмной мантии",
		GENITIVE = "капюшона от тёмной мантии",
		DATIVE = "капюшону от тёмной мантии",
		ACCUSATIVE = "капюшон от тёмной мантии",
		INSTRUMENTAL = "капюшоном от тёмной мантии",
		PREPOSITIONAL = "капюшоне от тёмной мантии"
	)

//Chaplain
/obj/item/clothing/head/hooded/nun_hood
	name = "nun hood"
	desc = "Капюшон, покрывающий голову. Повышает уровень благочестия на этой станции."
	icon_state = "nun_hood"
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/hooded/nun_hood/get_ru_names()
	return list(
		NOMINATIVE = "капюшон монахини",
		GENITIVE = "капюшона монахини",
		DATIVE = "капюшону монахини",
		ACCUSATIVE = "капюшон монахини",
		INSTRUMENTAL = "капюшоном монахини",
		PREPOSITIONAL = "капюшоне монахини"
	)

//Chaplain
/obj/item/clothing/head/hooded/monk_hood
	name = "monk hood"
	desc = "Капюшон, покрывающий голову. Деревянный посох покупается отдельно."
	icon_state = "monk_hood"
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/hooded/monk_hood/get_ru_names()
	return list(
		NOMINATIVE = "капюшон монаха",
		GENITIVE = "капюшона монаха",
		DATIVE = "капюшону монаха",
		ACCUSATIVE = "капюшон монаха",
		INSTRUMENTAL = "капюшоном монаха",
		PREPOSITIONAL = "капюшоне монаха"
	)

/obj/item/clothing/head/witchhunter_hat
	name = "witchhunter hat"
	desc = "В давние времена эта шляпа надевалась не только в качестве украшения."
	gender = FEMALE
	icon_state = "witchhunterhat"
	item_state = "witchhunterhat"
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/witchhunter_hat/get_ru_names()
	return list(
		NOMINATIVE = "шляпа охотника на ведьм",
		GENITIVE = "шляпы охотника на ведьм",
		DATIVE = "шляпе охотника на ведьм",
		ACCUSATIVE = "шляпу охотника на ведьм",
		INSTRUMENTAL = "шляпой охотника на ведьм",
		PREPOSITIONAL = "шляпе охотника на ведьм"
	)

/obj/item/clothing/head/bishopmitre
	name = "bishop mitre"
	desc = "Очень роскошная шляпа, которая служит для связи с Богом. Или как громоотвод, это у кого спросить."
	gender = FEMALE
	icon_state = "bishopmitre"
	item_state = "bishopmitre"

/obj/item/clothing/head/bishopmitre/get_ru_names()
	return list(
		NOMINATIVE = "минтра эпископа",
		GENITIVE = "минтры эпископа",
		DATIVE = "минтре эпископа",
		ACCUSATIVE = "минтру эпископа",
		INSTRUMENTAL = "минтрой эпископа",
		PREPOSITIONAL = "минтре эпископа"
	)

/obj/item/clothing/head/blackbishopmitre
	name = "black bishop mitre"
	desc = "Очень роскошная чёрная шляпа, которая служит для связи с Богом. Или как громоотвод, это у кого спросить."
	gender = FEMALE
	icon_state = "blackbishopmitre"
	item_state = "blackbishopmitre"

/obj/item/clothing/head/blackbishopmitre/get_ru_names()
	return list(
		NOMINATIVE = "чёрная минтра эпископа",
		GENITIVE = "чёрной минтры эпископа",
		DATIVE = "чёрной минтре эпископа",
		ACCUSATIVE = "чёрную минтру эпископа",
		INSTRUMENTAL = "чёрной минтрой эпископа",
		PREPOSITIONAL = "чёрной минтре эпископа"
	)

/obj/item/clothing/head/det_hat
	name = "detective's hat"
	desc = "Всякий, кто будет носить эту шляпу, будет выглядеть умнее."
	gender = FEMALE
	icon_state = "detective"
	allowed = list(/obj/item/reagent_containers/food/snacks/candy/candy_corn, /obj/item/pen)
	armor = list(MELEE = 25, BULLET = 5, LASER = 25, ENERGY = 10, BOMB = 0, BIO = 0, RAD = 0, FIRE = 30, ACID = 50)
	dog_fashion = /datum/dog_fashion/head/detective
	muhtar_fashion = /datum/muhtar_fashion/head/detective

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi'
	)

/obj/item/clothing/head/det_hat/get_ru_names()
	return list(
		NOMINATIVE = "шляпа детектива",
		GENITIVE = "шляпы детектива",
		DATIVE = "шляпе детектива",
		ACCUSATIVE = "шляпу детектива",
		INSTRUMENTAL = "шляпой детектива",
		PREPOSITIONAL = "шляпа детектива"
	)

/obj/item/clothing/head/det_hat/black
	icon_state = "detective_coolhat_black"

/obj/item/clothing/head/det_hat/brown
	icon_state = "detective_coolhat_brown"

/obj/item/clothing/head/det_hat/grey
	icon_state = "detective_coolhat_grey"

//Mime
/obj/item/clothing/head/beret
	name = "beret"
	desc = "Любимый головной убор творцов."
	icon_state = "beret"
	dog_fashion = /datum/dog_fashion/head/beret

/obj/item/clothing/head/beret/get_ru_names()
	return list(
		NOMINATIVE = "берет",
		GENITIVE = "берета",
		DATIVE = "берету",
		ACCUSATIVE = "берет",
		INSTRUMENTAL = "беретом",
		PREPOSITIONAL = "берете"
	)

/obj/item/clothing/head/beret/durathread
	name = "durathread beret"
	desc = "Берет, сделанный из дюраткани. Обеспечивает небольшую защиту головы владельцу."
	icon_state = "beretdurathread"
	item_color = null
	armor = list(MELEE = 15, BULLET = 5, LASER = 15, ENERGY = 5, BOMB = 10, BIO = 0, RAD = 0, FIRE = 30, ACID = 5)

/obj/item/clothing/head/beret/durathread/get_ru_names()
	return list(
		NOMINATIVE = "берет из дюраткани",
		GENITIVE = "берета из дюраткани",
		DATIVE = "берету из дюраткани",
		ACCUSATIVE = "берет из дюраткани",
		INSTRUMENTAL = "беретом из дюраткани",
		PREPOSITIONAL = "берете из дюраткани"
	)

//Security
/obj/item/clothing/head/HoS
	name = "head of security cap"
	desc = "Крепкая фуражка, выдаваемая главе службы безопасности. Покажите офицерам, кто тут главный."
	gender = FEMALE
	icon_state = "hoscap"
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 10, BOMB = 25, BIO = 10, RAD = 0, FIRE = 50, ACID = 60)
	strip_delay = 80

/obj/item/clothing/head/HoS/get_ru_names()
	return list(
		NOMINATIVE = "фуражка главы службы безопасности",
		GENITIVE = "фуражки главы службы безопасности",
		DATIVE = "фуражке главы службы безопасности",
		ACCUSATIVE = "фуражку главы службы безопасности",
		INSTRUMENTAL = "фуражкой главы службы безопасности",
		PREPOSITIONAL = "фуражке главы службы безопасности"
	)

/obj/item/clothing/head/HoS/beret
	name = "head of security beret"
	desc = "Крепкий берет, выдаваемый главе службы безопасности. Для тех, кто любит стиль, но при этом не хочет жертвовать защитой головы."
	gender = MALE
	icon_state = "beret_hos_black"
	snake_fashion = /datum/snake_fashion/head/beret_hos_black

/obj/item/clothing/head/HoS/beret/get_ru_names()
	return list(
		NOMINATIVE = "берет главы службы безопасности",
		GENITIVE = "берета главы службы безопасности",
		DATIVE = "берету главы службы безопасности",
		ACCUSATIVE = "берет главы службы безопасности",
		INSTRUMENTAL = "беретом главы службы безопасности",
		PREPOSITIONAL = "берете главы службы безопасности"
	)

/obj/item/clothing/head/warden
	name = "warden's police hat"
	desc = "Специализированная, укреплённая фуражкая, выдаваемая смотрителю службы безопасности. Защищает голову от ударов."
	gender = FEMALE
	icon_state = "policehelm"
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 10, BOMB = 25, BIO = 0, RAD = 0, FIRE = 30, ACID = 60)
	strip_delay = 60
	dog_fashion = /datum/dog_fashion/head/warden

/obj/item/clothing/head/warden/get_ru_names()
	return list(
		NOMINATIVE = "полицейская фуражка смотрителя",
		GENITIVE = "полицейской фуражки смотрителя",
		DATIVE = "полицейской фуражке смотрителя",
		ACCUSATIVE = "полицейскую фуражку смотрителя",
		INSTRUMENTAL = "полицейской фуражкой смотрителя",
		PREPOSITIONAL = "полицейской фуражке смотрителя"
	)

/obj/item/clothing/head/officer
	name = "officer's cap"
	desc = "Красная кепка с классическим полицейским значком, призванная продемонстрировать, что вы тут - закон."
	gender = FEMALE
	icon_state = "customshelm"
	item_state = "customshelm"
	armor = list(MELEE = 35, BULLET = 30, LASER = 30,ENERGY = 10, BOMB = 0, BIO = 0, RAD = 0, FIRE = 20, ACID = 50)
	strip_delay = 60

/obj/item/clothing/head/officer/get_ru_names()
	return list(
		NOMINATIVE = "офицерская кепка",
		GENITIVE = "офицерской кепки",
		DATIVE = "офицерской кепке",
		ACCUSATIVE = "офицерскую кепку",
		INSTRUMENTAL = "офицерской кепкой",
		PREPOSITIONAL = "офицерской кепке"
	)

/obj/item/clothing/head/beret/sec
	name = "security beret"
	desc = "Берет с вышитым на нём офицерским значком. Для тех офицеров, кто больше предпочитает стиль, чем безопасность головы."
	icon_state = "beret_officer"
	armor = list(MELEE = 35, BULLET = 30, LASER = 30,ENERGY = 10, BOMB = 0, BIO = 0, RAD = 0, FIRE = 20, ACID = 50)
	strip_delay = 60
	dog_fashion = null
	muhtar_fashion = /datum/muhtar_fashion/head/beret

/obj/item/clothing/head/beret/sec/get_ru_names()
	return list(
		NOMINATIVE = "офицерский берет",
		GENITIVE = "офицерского берета",
		DATIVE = "офицерскому берету",
		ACCUSATIVE = "офицерский берет",
		INSTRUMENTAL = "офицерским беретом",
		PREPOSITIONAL = "офицерском берете"
	)

/obj/item/clothing/head/beret/sec/black
	name = "black security beret"
	desc = "Чёрный берет с вышитым на нём офицерским значком. Для тех офицеров, кто больше предпочитает стиль, чем безопасность головы."
	icon_state = "beret_officer_black"

/obj/item/clothing/head/beret/sec/black/get_ru_names()
	return list(
		NOMINATIVE = "чёрный офицерский берет",
		GENITIVE = "чёрного офицерского берета",
		DATIVE = "чёрного офицерскому берету",
		ACCUSATIVE = "чёрный офицерский берет",
		INSTRUMENTAL = "чёрным офицерским беретом",
		PREPOSITIONAL = "чёрном офицерском берете"
	)

/obj/item/clothing/head/beret/sec/warden
	name = "warden's beret"
	desc = "Специализированный берет с вышитым на нём значком смотрителя. Для тех смотрителей, кто больше предпочитает стиль, чем безопасность головы."
	icon_state = "beret_warden"
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 10, BOMB = 25, BIO = 0, RAD = 0, FIRE = 30, ACID = 50)

/obj/item/clothing/head/beret/sec/warden/get_ru_names()
	return list(
		NOMINATIVE = "берет смотрителя",
		GENITIVE = "берета смотрителя",
		DATIVE = "берету смотрителя",
		ACCUSATIVE = "берет смотрителя",
		INSTRUMENTAL = "беретом смотрителя",
		PREPOSITIONAL = "берете смотрителя"
	)
/obj/item/clothing/head/beret/brigphys
	name = "brigphys's beret"
	desc = "Берет, принадлежащий медику службы безопасности. Не обладает какой либо защитой."
	icon_state = "brigphysberet"

/obj/item/clothing/head/beret/brigphys/get_ru_names()
	return list(
		NOMINATIVE = "берет бригмедика",
		GENITIVE = "берета бригмедика",
		DATIVE = "берету бригмедика",
		ACCUSATIVE = "берет бригмедика",
		INSTRUMENTAL = "беретом бригмедика",
		PREPOSITIONAL = "берете бригмедика"
	)

/obj/item/clothing/head/beret/eng
	name = "engineering beret"
	desc = "Специализированный берет с вышитым на нём инженерным значком. Для тех инженеров, кто больше предпочитает стиль, чем безопасность головы."
	icon_state = "beret_engineering"

/obj/item/clothing/head/beret/eng/get_ru_names()
	return list(
		NOMINATIVE = "инженерный берет",
		GENITIVE = "инженерного берета",
		DATIVE = "инженерному берету",
		ACCUSATIVE = "инженерный берет",
		INSTRUMENTAL = "инженерным беретом",
		PREPOSITIONAL = "инженерном берете"
	)

/obj/item/clothing/head/beret/atmos
	name = "atmospherics beret"
	desc = "Берет, который носят те, кто продемонстрировал безупречное владение техникой совокупления с трубами." //maybe something else here
	icon_state = "beret_atmospherics"

/obj/item/clothing/head/beret/atmos/get_ru_names()
	return list(
		NOMINATIVE = "берет атмосферника",
		GENITIVE = "берета атмосферника",
		DATIVE = "берету атмосферника",
		ACCUSATIVE = "берет атмосферника",
		INSTRUMENTAL = "беретом атмосферника",
		PREPOSITIONAL = "берете атмосферника"
	)

/obj/item/clothing/head/beret/ce
	name = "chief engineer beret"
	desc = "Белый берет с вышитым на нём инженерным значком. Его владелец является профессионалом своего дела. Наверное..."
	icon_state = "beret_ce"

/obj/item/clothing/head/beret/ce/get_ru_names()
	return list(
		NOMINATIVE = "берет старшего инженера",
		GENITIVE = "берета старшего инженера",
		DATIVE = "берету старшего инженера",
		ACCUSATIVE = "берет старшего инженера",
		INSTRUMENTAL = "беретом старшего инженера",
		PREPOSITIONAL = "берете старшего инженера"
	)

/obj/item/clothing/head/beret/sci
	name = "science beret"
	desc = "Фиолетовый берет с вышитым на нём значком исследовательского отдела. От него пахнет горящей плазмой."
	icon_state = "beret_sci"

/obj/item/clothing/head/beret/sci/get_ru_names()
	return list(
		NOMINATIVE = "берет учёного",
		GENITIVE = "берета учёного",
		DATIVE = "берету учёного",
		ACCUSATIVE = "берет учёного",
		INSTRUMENTAL = "беретом учёного",
		PREPOSITIONAL = "берете учёного"
	)

//Medical
/obj/item/clothing/head/beret/med
	name = "medical beret"
	desc = "Белый берет с аккуратно вышитым на нём зелёным крестом. От него пахнет медицинским спиртом."
	icon_state = "beret_med"

/obj/item/clothing/head/beret/med/get_ru_names()
	return list(
		NOMINATIVE = "медицинский берет",
		GENITIVE = "медицинского берета",
		DATIVE = "медицинскому берету",
		ACCUSATIVE = "медицинский берет",
		INSTRUMENTAL = "медицинским беретом",
		PREPOSITIONAL = "медицинском берете"
	)

//CMO
/obj/item/clothing/head/beret/elo
	name = "chief medical officer beret"
	desc = "Стильный берет, выдаваемый главному врачу. От него исходит легкий запах антисептика."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "elo-beret"

/obj/item/clothing/head/beret/elo/get_ru_names()
	return list(
		NOMINATIVE = "берет главного врача",
		GENITIVE = "берета главного врача",
		DATIVE = "берету главного врача",
		ACCUSATIVE = "берет главного врача",
		INSTRUMENTAL = "беретом главного врача",
		PREPOSITIONAL = "берете главного врача"
	)

/obj/item/clothing/head/surgery
	name = "surgical cap"
	desc = "Шапочка, которую носят хирурги во время операций. Защищает внутренние органы пациента от попадания на них волос."
	gender = FEMALE
	icon_state = "surgcap_blue"
	flags_inv = HIDEHEADHAIR
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi'
		)

/obj/item/clothing/head/surgery/get_ru_names()
	return list(
		NOMINATIVE = "хирургическая шапочка",
		GENITIVE = "хирургической шапочки",
		DATIVE = "хирургической шапочке",
		ACCUSATIVE = "хирургическую шапочку",
		INSTRUMENTAL = "хирургической шапочкой",
		PREPOSITIONAL = "хирургической шапочке"
	)

/obj/item/clothing/head/surgery/purple
	name = "purple surgical cap"
	desc = "Фиолетовая шапочка, которую носят хирурги во время операций. Защищает внутренние органы пациента от попадания на них волос."
	icon_state = "surgcap_purple"

/obj/item/clothing/head/surgery/purple/get_ru_names()
	return list(
		NOMINATIVE = "фиолетовая хирургическая шапочка",
		GENITIVE = "фиолетовой хирургической шапочки",
		DATIVE = "фиолетовой хирургической шапочке",
		ACCUSATIVE = "фиолетовую хирургическую шапочку",
		INSTRUMENTAL = "фиолетовой хирургической шапочкой",
		PREPOSITIONAL = "фиолетовой хирургической шапочке"
	)

/obj/item/clothing/head/surgery/blue
	name = "blue surgical cap"
	desc = "Голубая шапочка, которую носят хирурги во время операций. Защищает внутренние органы пациента от попадания на них волос."
	icon_state = "surgcap_blue"

/obj/item/clothing/head/surgery/blue/get_ru_names()	
	return list(
		NOMINATIVE = "голубая хирургическая шапочка",
		GENITIVE = "голубой хирургической шапочки",
		DATIVE = "голубой хирургической шапочке",
		ACCUSATIVE = "голубую хирургическую шапочку",
		INSTRUMENTAL = "голубой хирургической шапочкой",
		PREPOSITIONAL = "голубой хирургической шапочке"
	)

/obj/item/clothing/head/surgery/green
	name = "dark green surgical cap"
	desc = "Тёмно-зелёная шапочка, которую носят хирурги во время операций. Защищает внутренние органы пациента от попадания на них волос."
	icon_state = "surgcap_darkgreen"

/obj/item/clothing/head/surgery/green/get_ru_names()
	return list(
		NOMINATIVE = "тёмно-зелёная хирургическая шапочка",
		GENITIVE = "тёмно-зелёной хирургической шапочки",
		DATIVE = "тёмно-зелёной хирургической шапочке",
		ACCUSATIVE = "тёмно-зелёную хирургическую шапочку",
		INSTRUMENTAL = "тёмно-зелёной хирургической шапочкой",
		PREPOSITIONAL = "тёмно-зелёной хирургической шапочке"
	)

/obj/item/clothing/head/surgery/lightgreen
	name = "green surgical cap"
	desc = "Зелёная шапочка, которую носят хирурги во время операций. Защищает внутренние органы пациента от попадания на них волос."
	icon_state = "surgcap_green"

/obj/item/clothing/head/surgery/lightgreen/get_ru_names()
	return list(
		NOMINATIVE = "зелёная хирургическая шапочка",
		GENITIVE = "зелёной хирургической шапочки",
		DATIVE = "зелёной хирургической шапочке",
		ACCUSATIVE = "зелёную хирургическую шапочку",
		INSTRUMENTAL = "зелёной хирургической шапочкой",
		PREPOSITIONAL = "зелёной хирургической шапочке"
	)

/obj/item/clothing/head/surgery/black
	name = "black surgical cap"
	desc = "Чёрная шапочка, которую носят хирурги во время операций. Защищает внутренние органы пациента от попадания на них волос."
	icon_state = "surgcap_black"

/obj/item/clothing/head/surgery/black/get_ru_names()
	return list(
		NOMINATIVE = "чёрная хирургическая шапочка",
		GENITIVE = "чёрной хирургической шапочки",
		DATIVE = "чёрной хирургической шапочке",
		ACCUSATIVE = "чёрную хирургическую шапочку",
		INSTRUMENTAL = "чёрной хирургической шапочкой",
		PREPOSITIONAL = "чёрной хирургической шапочке"
	)

//SolGov
/obj/item/clothing/head/beret/solgov/command
	name = "Trans-Solar Federation Lieutenant's beret"
	desc = "Берет, который носят морпехи ТСФ. Значок на берете означает, что его носитель - лейтенант."
	icon_state = "solgov_beret"
	dog_fashion = null
	armor = list(MELEE = 35, BULLET = 30, LASER = 30,ENERGY = 10, BOMB = 0, BIO = 0, RAD = 0, FIRE = 20, ACID = 50)
	strip_delay = 80

/obj/item/clothing/head/beret/solgov/command/get_ru_names()
	return list(
		NOMINATIVE = "берет лейтенанта ТСФ",
		GENITIVE = "берета лейтенанта ТСФ",
		DATIVE = "берету лейтенанта ТСФ",
		ACCUSATIVE = "берет лейтенанта ТСФ",
		INSTRUMENTAL = "беретом лейтенанта ТСФ",
		PREPOSITIONAL = "берете лейтенанта ТСФ"
	)

/obj/item/clothing/head/beret/solgov/command/elite
	name = "Trans-Solar Federation Specops Lieutenant's beret"
	desc = "Берет, который носят морпехи ТСФ. Значок на берете означает, что его носитель принадлежит отделу специальных операций флота."
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 10, BOMB = 25, BIO = 10, RAD = 0, FIRE = 50, ACID = 60)
	icon_state = "solgov_elite_beret"

/obj/item/clothing/head/beret/solgov/command/elite/get_ru_names()
	return list(
		NOMINATIVE = "берет офицера специальных операций ТСФ",
		GENITIVE = "берета специальных операций ТСФ",
		DATIVE = "берету специальных операций ТСФ",
		ACCUSATIVE = "берет специальных операций ТСФ",
		INSTRUMENTAL = "беретом специальных операций ТСФ",
		PREPOSITIONAL = "берете специальных операций ТСФ"
	)

//Culinary Artist
/obj/item/clothing/head/chefcap
	name = "chef's red cap"
	desc = "Этот красный колпак обычно носят повара для того, чтобы избежать попадания волос в еду. Судя по состоянию кухни, волосы в еде - меньшая из ваших проблем."
	item_state = "redchefcap"
	icon_state = "redchefcap"

/obj/item/clothing/head/chefcap/get_ru_names()
	return list(
		NOMINATIVE = "красный поварской колпак",
		GENITIVE = "красного поварского колпака",
		DATIVE = "красному поварскому колпаку",
		ACCUSATIVE = "красный поварской колпак",
		INSTRUMENTAL = "красным поварским колпаком",
		PREPOSITIONAL = "красном поварском колпаке"
	)

/obj/item/clothing/head/surgery/brown
	name = "brown surgical cap"
	desc = "Коричневая шапочка, которую носят хирурги во время операций. Защищает внутренние органы пациента от попадания на них волос."
	icon_state = "surgcap_brown"

/obj/item/clothing/head/surgery/brown/get_ru_names()
	return list(
		NOMINATIVE = "коричневая хирургическая шапочка",
		GENITIVE = "коричневой хирургической шапочки",
		DATIVE = "коричневой хирургической шапочке",
		ACCUSATIVE = "коричневую хирургическую шапочку",
		INSTRUMENTAL = "коричневой хирургической шапочкой",
		PREPOSITIONAL = "коричневой хирургической шапочке"
	)

//prison
/obj/item/clothing/head/prison
	name = "prison hat"
	desc = "Тюремная шапка, которая должна предотвращать распространение космо вшей... По крайней мере так задумывалось."
	item_state = "prison_hat"
	icon_state = "prison_hat"

/obj/item/clothing/head/prison/get_ru_names()
	return list(
		NOMINATIVE = "тюремная шапка",
		GENITIVE = "тюремную шапкапу",
		DATIVE = "тюремной шапке",
		ACCUSATIVE = "тюремную шапку",
		INSTRUMENTAL = "тюремной шапкой",
		PREPOSITIONAL = "тюремной шапке"
	)

//Mining medic
/obj/item/clothing/head/beret/mining_medic
	name = "mining medic's beret"
	desc = "Коричневый берет с вышитым на нём белым крестом. Такой обычно носит шахтёрский врач."
	icon_state = "beret_minmed"

/obj/item/clothing/head/beret/mining_medic/get_ru_names()
	return list(
		NOMINATIVE = "берет шахтёрского врача",
		GENITIVE = "берета шахтёрского врача",
		DATIVE = "берету шахтёрского врача",
		ACCUSATIVE = "берет шахтёрского врача",
		INSTRUMENTAL = "беретом шахтёрского врача",
		PREPOSITIONAL = "берете шахтёрского врача"
	)

