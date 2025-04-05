/obj/item/clothing/mask/gas
	name = "gas mask"
	desc = "Полностью закрывающая лицо маска, которую можно подключить к системе подачи воздуха."
	ru_names = list(
		NOMINATIVE = "противогаз",
		GENITIVE = "противогаза",
		DATIVE = "противогазу",
		ACCUSATIVE = "противогаз",
		INSTRUMENTAL = "противогазом",
		PREPOSITIONAL = "противогазе"
	)
	gender = MALE
	icon_state = "gas_alt"
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT|AIRTIGHT
	flags_inv = HIDEGLASSES|HIDENAME
	flags_cover = MASKCOVERSMOUTH|MASKCOVERSEYES
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "gas_alt"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	resistance_flags = NONE
	undyeable = TRUE
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/mask.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/mask.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/mask.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/mask.dmi',
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/mask.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_WRYN = 'icons/mob/clothing/species/wryn/mask.dmi'
	)

// **** Welding gas mask ****

/obj/item/clothing/mask/gas/welding
	name = "welding gas mask"
	desc = "Противогаз, со встроенным лицевым щитком и сварочными очками. Был спроектирован ботанами, поэтому выглядит как череп."
	ru_names = list(
		NOMINATIVE = "сварочный протовогаз",
		GENITIVE = "сварочного протовогаза",
		DATIVE = "сварочному протовогазу",
		ACCUSATIVE = "сварочный протовогаз",
		INSTRUMENTAL = "сварочным протовогазом",
		PREPOSITIONAL = "сварочном протовогазе"
	)
	icon_state = "weldingmask"
	item_state = "weldingmask"
	materials = list(MAT_METAL=4000, MAT_GLASS=2000)
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	can_toggle = TRUE
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 55)
	origin_tech = "materials=2;engineering=3"
	actions_types = list(/datum/action/item_action/toggle)
	flags_cover = MASKCOVERSEYES|MASKCOVERSMOUTH
	visor_flags_inv = HIDEGLASSES
	resistance_flags = FIRE_PROOF


/obj/item/clothing/mask/gas/welding/attack_self(mob/user)
	weldingvisortoggle(user)


/obj/item/clothing/mask/gas/welding/adjustmask(mob/living/carbon/human/user)
	return


/obj/item/clothing/mask/gas/explorer
	name = "explorer gas mask"
	desc = "Противогаз военного качества, который можно подключить к системе подачи воздуха."
	ru_names = list(
		NOMINATIVE = "противогаз исследователя",
		GENITIVE = "противогаза исследователя",
		DATIVE = "противогазу исследователя",
		ACCUSATIVE = "противогаз исследователя",
		INSTRUMENTAL = "противогазом исследователя",
		PREPOSITIONAL = "противогазе исследователя"
	)
	icon_state = "gas_mining"
	actions_types = list(/datum/action/item_action/adjust)
	armor = list("melee" = 10, "bullet" = 5, "laser" = 5, "energy" = 5, "bomb" = 0, "bio" = 50, "rad" = 0, "fire" = 20, "acid" = 40)
	resistance_flags = FIRE_PROOF
	can_toggle = TRUE

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/mask.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/mask.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/mask.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/mask.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_WRYN = 'icons/mob/clothing/species/wryn/mask.dmi'
	)


/obj/item/clothing/mask/gas/explorer/attack_self(mob/user)
	adjustmask(user)


/obj/item/clothing/mask/gas/explorer/adjustmask(mob/living/carbon/human/user)
	. = ..()
	if(.)
		w_class = up ? WEIGHT_CLASS_SMALL : WEIGHT_CLASS_NORMAL


/obj/item/clothing/mask/gas/explorer/force_adjust_mask()
	. = ..()
	w_class = WEIGHT_CLASS_SMALL


/obj/item/clothing/mask/gas/explorer/folded/Initialize(mapload)
	. = ..()
	force_adjust_mask()

//Bane gas mask
/obj/item/clothing/mask/banemask
	name = "bane mask"
	desc = "Никому не было до меня дела, пока я не надел маску."
	ru_names = list(
		NOMINATIVE = "маска Бейна",
		GENITIVE = "маски Бейна",
		DATIVE = "маске Бейна",
		ACCUSATIVE = "маску Бейна",
		INSTRUMENTAL = "маской Бейна",
		PREPOSITIONAL = "маске Бейна"
	)
	icon_state = "bane_mask"
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT|AIRTIGHT
	flags_inv = HIDEHEADSETS|HIDEGLASSES|HIDENAME
	flags_cover = MASKCOVERSMOUTH | MASKCOVERSEYES
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "bane_mask"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01


//Plague Dr suit can be found in clothing/suits/bio.dm
/obj/item/clothing/mask/gas/plaguedoctor
	name = "plague doctor mask"
	desc = "Обновленная версия классической маски, которую можно подключить к системе подачи воздуха."
	ru_names = list(
		NOMINATIVE = "маска чумного доктора",
		GENITIVE = "маски чумного доктора",
		DATIVE = "маске чумного доктора",
		ACCUSATIVE = "маску чумного доктора",
		INSTRUMENTAL = "маской чумного доктора",
		PREPOSITIONAL = "маске чумного доктора"
	)
	gender = FEMALE
	icon_state = "plaguedoctor"
	item_state = "gas_mask"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 2, "energy" = 2, "bomb" = 0, "bio" = 75, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/clothing/mask/gas/swat
	name = "\improper SWAT mask"
	desc = "Плотно прилегающая к коже тактическая маска, которую можно подключить к системе подачи воздуха."
	ru_names = list(
		NOMINATIVE = "маска спецназа",
		GENITIVE = "маски спецназа",
		DATIVE = "маске спецназа",
		ACCUSATIVE = "маску спецназа",
		INSTRUMENTAL = "маской спецназа",
		PREPOSITIONAL = "маске спецназа"
	)
	gender = FEMALE
	icon_state = "swat"
	armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = 15, "bio" = 50, "rad" = 0, "fire" = 100, "acid" = 50)

/obj/item/clothing/mask/gas/syndicate
	name = "syndicate mask"
	desc = "Плотно прилегающая к коже тактическая маска, которую можно подключить к системе подачи воздуха."
	ru_names = list(
		NOMINATIVE = "маска Синдиката",
		GENITIVE = "маски Синдиката",
		DATIVE = "маске Синдиката",
		ACCUSATIVE = "маску Синдиката",
		INSTRUMENTAL = "маской Синдиката",
		PREPOSITIONAL = "маске Синдиката"
	)
	gender = FEMALE
	icon_state = "swat"
	armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = 15, "bio" = 50, "rad" = 0, "fire" = 100, "acid" = 50)
	strip_delay = 60

/obj/item/clothing/mask/gas/clown_hat
	name = "clown wig and mask"
	desc = "Маскарадный набор настоящего проказника. Клоун никогда не будет полноценным без своего парика и маски. Вы можете изменить её внешний вид в руках."
	ru_names = list(
		NOMINATIVE = "клоунский парик с маской",
		GENITIVE = "клоунского парика с маской",
		DATIVE = "клоунскому парику с маской",
		ACCUSATIVE = "клоунский парик с маской",
		INSTRUMENTAL = "клоунским париком с маской",
		PREPOSITIONAL = "клоунском парике с маской"
	)
	icon_state = "clown"
	item_state = "clown_hat"
	flags_inv = parent_type::flags_inv|HIDEHAIR
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE
	dog_fashion = /datum/dog_fashion/head/clown

/obj/item/clothing/mask/gas/clown_hat/attack_self(mob/living/user)
	var/list/mask_type = list("Истинная Форма" = /obj/item/clothing/mask/gas/clown_hat,
							"Женственная Форма" = /obj/item/clothing/mask/gas/clown_hat/sexy,
							"Безумная Форма" = /obj/item/clothing/mask/gas/clown_hat/joker,
							"Радужная Форма" = /obj/item/clothing/mask/gas/clown_hat/rainbow)
	var/list/mask_icons = list("Истинная Форма" = image(icon = 'icons/obj/clothing/masks.dmi', icon_state = "clown"),
							"Женственная Форма" = image(icon = 'icons/obj/clothing/masks.dmi', icon_state = "sexyclown"),
							"Безумная Форма" = image(icon = 'icons/obj/clothing/masks.dmi', icon_state = "joker"),
							"Радужная Форма" = image(icon = 'icons/obj/clothing/masks.dmi', icon_state = "rainbow"))
	var/mask_choice = show_radial_menu(user, src, mask_icons)
	var/picked_mask = mask_type[mask_choice]

	if(QDELETED(src) || !picked_mask)
		return
	if(user.stat || !in_range(user, src))
		return
	var/obj/item/clothing/mask/gas/clown_hat/new_mask = new picked_mask(get_turf(user))
	qdel(src)
	user.put_in_active_hand(new_mask)
	balloon_alert(user, "внешний вид изменён!")
	return TRUE

/obj/item/clothing/mask/gas/clown_hat/sexy
	name = "sexy-clown wig and mask"
	desc = "Женственная клоунская маска для начинающих кроссдрессеров или женщин - артисток. Вы можете изменить её внешний вид в руках."
	ru_names = list(
		NOMINATIVE = "сексуальный клоунский парик с маской",
		GENITIVE = "сексуального клоунского парика с маской",
		DATIVE = "сексуальному клоунскому парику с маской",
		ACCUSATIVE = "сексуальный клоунский парик с маской",
		INSTRUMENTAL = "сексуальным клоунским париком с маской",
		PREPOSITIONAL = "сексуальном клоунском парике с маской"
	)
	icon_state = "sexyclown"
	item_state = "sexyclown"

/obj/item/clothing/mask/gas/clown_hat/joker
	name = "deranged clown wig and mask"
	desc = "Дурацкая клоунская маска, вызывающее безумное веселье. Вы можете изменить её внешний вид в руках."
	ru_names = list(
		NOMINATIVE = "клоунский парик с маской настоящего безумца",
		GENITIVE = "клоунского парика с маской настоящего безумца",
		DATIVE = "клоунскому парику с маской настоящего безумца",
		ACCUSATIVE = "клоунский парик с маской настоящего безумца",
		INSTRUMENTAL = "клоунским париком с маской настоящего безумца",
		PREPOSITIONAL = "клоунском парике с маской настоящего безумца"
	)
	icon_state = "joker"
	item_state = "joker"

/obj/item/clothing/mask/gas/clown_hat/rainbow
	name = "rainbow clown wig and mask"
	desc = "Разноцветная клоунская маска для тех, кто любит ослеплять и впечатлять публику. Вы можете изменить её внешний вид в руках."
	ru_names = list(
		NOMINATIVE = "радужный клоунский парик с маской",
		GENITIVE = "радужного клоунского парика с маской",
		DATIVE = "радужному клоунскому парику с маской",
		ACCUSATIVE = "радужный клоунский парик с маской",
		INSTRUMENTAL = "радужным клоунским париком с маской",
		PREPOSITIONAL = "радужном клоунском парике с маской"
	)
	icon_state = "rainbow"
	item_state = "rainbow"
	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/head.dmi',
		SPECIES_WRYN = 'icons/mob/clothing/species/wryn/mask.dmi'
	)

/obj/item/clothing/mask/gas/clownwiz
	name = "wizard clown wig and mask"
	desc = "Некоторые приколы невозможно провернуть без крупицы магии."
	ru_names = list(
		NOMINATIVE = "магический клоунский парик с маской",
		GENITIVE = "магического клоунского парика с маской",
		DATIVE = "магическому клоунскому парику с маской",
		ACCUSATIVE = "магический клоунский парик с маской",
		INSTRUMENTAL = "магическим клоунским париком с маской",
		PREPOSITIONAL = "магическом клоунском парике с маской"
	)
	icon_state = "wizzclown"
	item_state = "wizzclown"
	flags_cover = MASKCOVERSEYES
	flags_inv = HIDEHEADSETS|HIDEGLASSES|HIDEHAIR
	magical = TRUE


/obj/item/clothing/mask/gas/clown_hat/nodrop


/obj/item/clothing/mask/gas/clown_hat/nodrop/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)


/obj/item/clothing/mask/gas/mime
	name = "mime mask"
	desc = "Классическая маска мима. У неё жутковатое выражение лица."
	ru_names = list(
		NOMINATIVE = "маска мима",
		GENITIVE = "маски мима",
		DATIVE = "маске мима",
		ACCUSATIVE = "маску мима",
		INSTRUMENTAL = "маской мима",
		PREPOSITIONAL = "маске мима"
	)
	gender = FEMALE
	icon_state = "mime"
	item_state = "mime"
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE


/obj/item/clothing/mask/gas/mime/equipped(mob/user, slot, initial)
	. = ..()

	if(!user?.mind || slot != ITEM_SLOT_MASK)
		return

	var/obj/effect/proc_holder/spell/mime/speak/mask/mask_spell = null
	for(var/obj/effect/proc_holder/spell/mime/speak/spell in user.mind.spell_list)
		if(istype(spell, /obj/effect/proc_holder/spell/mime/speak/mask))
			mask_spell = spell
			continue
		if(spell)
			return

	if(mask_spell)
		mask_spell.action.enable_invisibility(FALSE)
		return

	user.mind.AddSpell(new /obj/effect/proc_holder/spell/mime/speak/mask)


/obj/item/clothing/mask/gas/mime/dropped(mob/user, slot, silent = FALSE)
	. = ..()

	if(!user?.mind || slot != ITEM_SLOT_MASK)
		return

	var/obj/effect/proc_holder/spell/mime/speak/mask/spell = locate() in user.mind.spell_list
	if(!spell)
		return

	if(spell.cooldown_handler.is_on_cooldown())
		spell.action.enable_invisibility(TRUE)
		return

	if(user.mind.miming)
		spell.cast(list(user))
	user.mind.RemoveSpell(spell)


/obj/item/clothing/mask/gas/mime/wizard
	name = "magical mime mask"
	desc = "Маска мима, которая сверкает от наполняющей её силы. Её глаза смотрят вам в душу."
	ru_names = list(
		NOMINATIVE = "магическая маска мима",
		GENITIVE = "магической маски мима",
		DATIVE = "магической маске мима",
		ACCUSATIVE = "магическую маску мима",
		INSTRUMENTAL = "магической маской мима",
		PREPOSITIONAL = "магической маске мима"
	)
	flags_inv = HIDEHEADSETS|HIDEGLASSES
	magical = TRUE


/obj/item/clothing/mask/gas/mime/nodrop


/obj/item/clothing/mask/gas/mime/nodrop/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)


/obj/item/clothing/mask/gas/monkeymask
	name = "monkey mask"
	desc = "Маска, которую надевают, когда ведут себя как макаки."
	ru_names = list(
		NOMINATIVE = "маска обезьяны",
		GENITIVE = "маски обезьяны",
		DATIVE = "маске обезьяны",
		ACCUSATIVE = "маску обезьяны",
		INSTRUMENTAL = "маской обезьяны",
		PREPOSITIONAL = "маске обезьяны"
	)
	gender = FEMALE
	icon_state = "monkeymask"
	item_state = "monkeymask"
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/gas/mime/sexy
	name = "sexy mime mask"
	desc = "Классическая женская маска мима."
	ru_names = list(
		NOMINATIVE = "сексуальная маска мима",
		GENITIVE = "сексуальной маски мима",
		DATIVE = "сексуальной маске мима",
		ACCUSATIVE = "сексуальную маску мима",
		INSTRUMENTAL = "сексуальной маской мима",
		PREPOSITIONAL = "сексуальной маске мима"
	)
	gender = FEMALE
	icon_state = "sexymime"
	item_state = "sexymime"

/obj/item/clothing/mask/gas/cyborg
	name = "cyborg visor"
	desc = "Бип буп."
	ru_names = list(
		NOMINATIVE = "визор робота",
		GENITIVE = "визора робота",
		DATIVE = "визору робота",
		ACCUSATIVE = "визор робота",
		INSTRUMENTAL = "визором робота",
		PREPOSITIONAL = "визоре робота"
	)
	icon_state = "death"
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/gas/owl_mask
	name = "owl mask"
	desc = "У-у-у-у!"
	ru_names = list(
		NOMINATIVE = "маска совы",
		GENITIVE = "маски совы",
		DATIVE = "маске совы",
		ACCUSATIVE = "маску совы",
		INSTRUMENTAL = "маской совы",
		PREPOSITIONAL = "маске совы"
	)
	gender = FEMALE
	icon_state = "owl"
	resistance_flags = FLAMMABLE
	actions_types = list(/datum/action/item_action/hoot)


/obj/item/clothing/mask/gas/owl_mask/super_hero


/obj/item/clothing/mask/gas/owl_mask/super_hero/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)


/obj/item/clothing/mask/gas/owl_mask/attack_self()
	hoot()

/obj/item/clothing/mask/gas/owl_mask/proc/hoot()
	if(cooldown < world.time - 35) // A cooldown, to stop people being jerks
		playsound(src.loc, 'sound/creatures/hoot.ogg', 50, 1)
		cooldown = world.time

// ********************************************************************

// **** Security gas mask ****

/obj/item/clothing/mask/gas/sechailer
	name = "security gas mask"
	desc = "Стандартный противогаз, выдаваемый службе безопасности. Внутри установлен \"Подчи-о-натор 3000\", который проигрывает с дюжину фраз, требующих всякое отребье прекратить всякое сопротивление."
	ru_names = list(
		NOMINATIVE = "противогаз службы безопасности",
		GENITIVE = "противогаза службы безопасности",
		DATIVE = "противогазу службы безопасности",
		ACCUSATIVE = "противогаз службы безопасности",
		INSTRUMENTAL = "противогазом службы безопасности",
		PREPOSITIONAL = "противогазе службы безопасности"
	)
	icon_state = "sechailer"
	item_state = "sechailer"
	armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 5, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 10)
	flags_inv = HIDENAME
	flags_cover = MASKCOVERSMOUTH
	clothing_traits = list(TRAIT_SECDEATH)
	var/phrase = 1
	var/aggressiveness = 1
	var/safety = 1
	can_toggle = TRUE
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/adjust, /datum/action/item_action/selectphrase)
	var/phrase_list = list(

								"halt" 			= "HALT! HALT! HALT! HALT!",
								"bobby" 		= "Stop in the name of the Law.",
								"compliance"	= "Compliance is in your best interest.",
								"justice"		= "Prepare for justice!",
								"running"		= "Running will only increase your sentence.",
								"dontmove"		= "Don't move, Creep!",
								"floor"			= "Down on the floor, Creep!",
								"robocop"		= "Dead or alive you're coming with me.",
								"god"			= "God made today for the crooks we could not catch yesterday.",
								"freeze"		= "Freeze, Scum Bag!",
								"imperial"		= "Stop right there, criminal scum!",
								"bash"			= "Stop or I'll bash you.",
								"harry"			= "Go ahead, make my day.",
								"asshole"		= "Stop breaking the law, asshole.",
								"stfu"			= "You have the right to shut the fuck up",
								"shutup"		= "Shut up crime!",
								"super"			= "Face the wrath of the golden bolt.",
								"dredd"			= "I am, the LAW!"
								)


/obj/item/clothing/mask/gas/sechailer/adjustmask(user)
	. = ..()
	if(.)
		w_class = up ? WEIGHT_CLASS_SMALL : WEIGHT_CLASS_NORMAL


/obj/item/clothing/mask/gas/sechailer/force_adjust_mask()
	. = ..()
	w_class = WEIGHT_CLASS_SMALL


/obj/item/clothing/mask/gas/sechailer/folded/Initialize(mapload)
	. = ..()
	force_adjust_mask()

/obj/item/clothing/mask/gas/sechailer/tactical
	name = "\improper Security gas mask FCO-26"
	desc = "Тактический противогаз чёрного цвета с красными обзорными стёклами. Разработан компанией N&R специально для сотрудников станционной службы безопасности НаноТрейзен. Обеспечивает защиту лица, глаз и органов дыхания от неблагоприятных условий внешней среды."
	ru_names = list(
		NOMINATIVE = "тактический противогаз СБ",
		GENITIVE = "тактического противогаза СБ",
		DATIVE = "тактическому противогазу СБ",
		ACCUSATIVE = "тактический противогаз СБ",
		INSTRUMENTAL = "тактическим противогазом СБ",
		PREPOSITIONAL = "тактическом противогазе СБ"
	)
	icon_state = "tactical_mask"
	armor = list("melee" = 10, "bullet" = 5, "laser" = 5, "energy" = 5, "bomb" = 0, "bio" = 50, "rad" = 0, "fire" = 10, "acid" = 30)
	aggressiveness = 3
	phrase = 12
	can_toggle = FALSE
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/hos
	name = "\improper HOS SWAT mask"
	desc = "Тактический противогаз чёрного цвета с более агрессивным Подчи-о-натором 3000."
	ru_names = list(
		NOMINATIVE = "тактический противогаз ГСБ",
		GENITIVE = "тактического противогаза ГСБ",
		DATIVE = "тактическому противогазу ГСБ",
		ACCUSATIVE = "тактический противогаз ГСБ",
		INSTRUMENTAL = "тактическим противогазом ГСБ",
		PREPOSITIONAL = "тактическом противогазе ГСБ"
	)
	icon_state = "hosmask"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 50, "rad" = 0, "fire" = 100, "acid" = 50)
	aggressiveness = 3
	phrase = 12
	can_toggle = FALSE
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/warden
	name = "\improper Warden SWAT mask"
	desc = "Тактический противогаз синего цвета с более агрессивным Подчи-о-натором 3000."
	ru_names = list(
		NOMINATIVE = "тактический противогаз смотрителя",
		GENITIVE = "тактического противогаза смотрителя",
		DATIVE = "тактическому противогазу смотрителя",
		ACCUSATIVE = "тактический противогаз смотрителя",
		INSTRUMENTAL = "тактическим противогазом смотрителя",
		PREPOSITIONAL = "тактическом противогазе смотрителя"
	)
	icon_state = "wardenmask"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 50, "rad" = 0, "fire" = 100, "acid" = 50)
	aggressiveness = 3
	phrase = 12
	can_toggle = FALSE
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/swat
	name = "\improper SWAT mask"
	desc = "Тактический противогаз с более агрессивным Подчи-о-натором 3000."
	ru_names = list(
		NOMINATIVE = "тактический противогаз",
		GENITIVE = "тактического противогаза",
		DATIVE = "тактическому противогазу",
		ACCUSATIVE = "тактический противогаз",
		INSTRUMENTAL = "тактическим противогазом",
		PREPOSITIONAL = "тактическом противогазе"
	)
	icon_state = "officermask"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 50, "rad" = 0, "fire" = 100, "acid" = 50)
	aggressiveness = 3
	phrase = 12
	can_toggle = FALSE
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/blue
	name = "\improper blue SWAT mask"
	desc = "Тактический противогаз, окрашенный в неоново-синие цвета. Используется для деморализации Грейтадеров."
	ru_names = list(
		NOMINATIVE = "синий тактический противогаз",
		GENITIVE = "синего тактического противогаза",
		DATIVE = "синему тактическому противогазу",
		ACCUSATIVE = "синий тактический противогаз",
		INSTRUMENTAL = "синимтактическим противогазом",
		PREPOSITIONAL = "синем тактическом противогазе"
	)
	icon_state = "blue_sechailer"
	item_state = "blue_sechailer"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 50, "rad" = 0, "fire" = 100, "acid" = 50)
	aggressiveness = 3
	phrase = 12
	can_toggle = FALSE
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/cyborg
	name = "security hailer"
	desc = "Набор предзаписанных сообщений, которые киборги используют при преследовании преступников."
	ru_names = list(
		NOMINATIVE = "мегафон службы безопасности",
		GENITIVE = "мегафона службы безопасности",
		DATIVE = "мегафону службы безопасности",
		ACCUSATIVE = "мегафон службы безопасности",
		INSTRUMENTAL = "мегафоном службы безопасности",
		PREPOSITIONAL = "мегафоне службы безопасности"
	)
	icon = 'icons/obj/device.dmi'
	icon_state = "taperecorder_idle"
	can_toggle = FALSE
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/ui_action_click(mob/user, datum/action/action, leftclick)
	if(istype(action, /datum/action/item_action/halt))
		halt()
	else if(istype(action, /datum/action/item_action/adjust))
		adjustmask(user)
	else if(istype(action, /datum/action/item_action/selectphrase))
		var/key = phrase_list[phrase]
		var/message = phrase_list[key]

		if (!safety)
			to_chat(user, "<span class='notice'>You set the restrictor to: FUCK YOUR CUNT YOU SHIT EATING COCKSUCKER MAN EAT A DONG FUCKING ASS RAMMING SHIT FUCK EAT PENISES IN YOUR FUCK FACE AND SHIT OUT ABORTIONS OF FUCK AND DO SHIT IN YOUR ASS YOU COCK FUCK SHIT MONKEY FUCK ASS WANKER FROM THE DEPTHS OF SHIT.</span>")
			return

		switch(aggressiveness)
			if(1)
				phrase = (phrase < 6) ? (phrase + 1) : 1
				key = phrase_list[phrase]
				message = phrase_list[key]
				to_chat(user,"<span class='notice'>You set the restrictor to: [message]</span>")
			if(2)
				phrase = (phrase < 11 && phrase >= 7) ? (phrase + 1) : 7
				key = phrase_list[phrase]
				message = phrase_list[key]
				to_chat(user,"<span class='notice'>You set the restrictor to: [message]</span>")
			if(3)
				phrase = (phrase < 18 && phrase >= 12 ) ? (phrase + 1) : 12
				key = phrase_list[phrase]
				message = phrase_list[key]
				to_chat(user,"<span class='notice'>You set the restrictor to: [message]</span>")
			if(4)
				phrase = (phrase < 18 && phrase >= 1 ) ? (phrase + 1) : 1
				key = phrase_list[phrase]
				message = phrase_list[key]
				to_chat(user,"<span class='notice'>You set the restrictor to: [message]</span>")
			else
				to_chat(user, "<span class='notice'>It's broken.</span>")

		var/datum/action/item_action/halt/halt_action = locate() in actions
		if(halt_action)
			halt_action.name = "[uppertext(key)]!"
			halt_action.UpdateButtonIcon()


/obj/item/clothing/mask/gas/sechailer/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	switch(aggressiveness)
		if(1)
			to_chat(user, span_notice("You set the aggressiveness restrictor to the second position."))
			aggressiveness = 2
			phrase = 7
		if(2)
			to_chat(user, span_notice("You set the aggressiveness restrictor to the third position."))
			aggressiveness = 3
			phrase = 13
		if(3)
			to_chat(user, span_notice("You set the aggressiveness restrictor to the fourth position."))
			aggressiveness = 4
			phrase = 1
		if(4)
			to_chat(user, span_notice("You set the aggressiveness restrictor to the first position."))
			aggressiveness = 1
			phrase = 1
		if(5)
			to_chat(user, span_warning("You adjust the restrictor but nothing happens, probably because its broken."))


/obj/item/clothing/mask/gas/sechailer/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE
	if(aggressiveness == 5)
		to_chat(user, span_warning("The [name] is already broken."))
		return .
	var/confirm = tgui_alert(user, "Do you want to cut off the voice modulator? Warning: It will destroy mask's functionality.", "Cut voice modulator?", list("Yes", "No"))
	if(confirm != "Yes" || aggressiveness == 5 || !Adjacent(user) || user.incapacitated())
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	aggressiveness = 5
	to_chat(user, span_warning("You have cut off the voice modulator, the mask is broken now."))


/obj/item/clothing/mask/gas/sechailer/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/gas/sechailer/emag_act(mob/user)
	if(safety)
		safety = 0
		if(user)
			to_chat(user, "<span class='warning'>You silently fry [src]'s vocal circuit with the cryptographic sequencer.")

/obj/item/clothing/mask/gas/sechailer/proc/halt()
	var/key = phrase_list[phrase]
	var/message = phrase_list[key]


	if(cooldown < world.time - 35) // A cooldown, to stop people being jerks
		if(!safety)
			message = "FUCK YOUR CUNT YOU SHIT EATING COCKSUCKER MAN EAT A DONG FUCKING ASS RAMMING SHIT FUCK EAT PENISES IN YOUR FUCK FACE AND SHIT OUT ABORTIONS OF FUCK AND DO SHIT IN YOUR ASS YOU COCK FUCK SHIT MONKEY FUCK ASS WANKER FROM THE DEPTHS OF SHIT."
			usr.visible_message("[usr]'s Compli-o-Nator: <font color='red' size='4'><b>[message]</b></font>")
			playsound(src.loc, 'sound/voice/binsult.ogg', 100, 0, 4)
			cooldown = world.time
			return

		usr.visible_message("[usr]'s Compli-o-Nator: <font color='red' size='4'><b>[message]</b></font>")
		playsound(src.loc, "sound/voice/complionator/[key].ogg", 100, 0, 4)
		cooldown = world.time



// ********************************************************************

/obj/item/clothing/mask/gas/ghostface
	name = "Ghostface mask"
	desc = "Вытянутая белая маска, рот которой открыт в немом крике. Но вот в чём вопрос - ужаса, или ярости?"
	ru_names = list(
		NOMINATIVE = "кричащая маска",
		GENITIVE = "кричащей маски",
		DATIVE = "кричащей маске",
		ACCUSATIVE = "кричащую маску",
		INSTRUMENTAL = "кричащей маской",
		PREPOSITIONAL = "кричащей маске"
	)
	icon_state = "ghostface_mask"
	item_state = "mime"
	flags_inv = HIDEGLASSES
	flags_cover = HIDENAME|MASKCOVERSMOUTH|MASKCOVERSEYES
	species_restricted = list(SPECIES_HUMAN, SPECIES_MACNINEPERSON, SPECIES_SKRELL, SPECIES_SLIMEPERSON, SPECIES_DIONA, SPECIES_NUCLEATION)

/obj/item/clothing/mask/gas/ghostface/equipped(mob/user, slot, initial)
	if(ishuman(user))
		if(slot == ITEM_SLOT_MASK)
			var/mob/living/carbon/human/H = user
			H.name_override = "Ghostface"
	. = ..()

/obj/item/clothing/mask/gas/ghostface/dropped(mob/user, slot, silent = FALSE)
	if(ishuman(user))
		if(slot == ITEM_SLOT_MASK)
			var/mob/living/carbon/human/H = user
			if(H.name_override == "Ghostface")
				H.name_override = FALSE
	. = ..()

/obj/item/clothing/mask/gas/ghostface/true
	armor = list(melee = 30, bullet = 10, laser = 5, energy = 5, bomb = 0, bio = 0, rad = 0, fire = 10, acid = 10)
	var/obj/item/voice_changer/ghostface/voice_changer

/obj/item/clothing/mask/gas/ghostface/true/devil
	icon_state = "devil_ghostface_mask"

/obj/item/clothing/mask/gas/ghostface/true/Initialize(mapload)
	. = ..()
	voice_changer = new(src)

/obj/item/clothing/mask/gas/ghostface/true/Destroy()
	QDEL_NULL(voice_changer)
	return ..()

/obj/item/clothing/mask/gas/ghostface/devil
	icon_state = "devil_ghostface_mask"

/obj/item/clothing/mask/gas/mining_medic
	name = "mining respirator"
	desc = "Небольшой респиратор без защитного стекла и с несъёмными фильтрами, который можно подключить к системе подачи воздуха. Защищает лёгкие от попадания пепла."
	ru_names = list(
		NOMINATIVE = "шахтёрский респиратор",
		GENITIVE = "шахтёрского респиратора",
		DATIVE = "шахтёрскому респиратору",
		ACCUSATIVE = "шахтёрский респиратор",
		INSTRUMENTAL = "шахтёрским респиратоом",
		PREPOSITIONAL = "шахтёрском распираторе"
	)
	flags_inv = HIDENAME
	flags_cover = MASKCOVERSMOUTH
	icon_state = "mining_gas"
	item_state = "mining_gas"
