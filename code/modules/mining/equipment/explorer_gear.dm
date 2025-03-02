/****************Explorer's Suit and Mask****************/
/obj/item/clothing/suit/hooded/explorer
	name = "explorer suit"
	desc = "Бронированный костюм, созданный для исследования и работы в суровых условиях."
	ru_names = list(
		NOMINATIVE = "костюм исследователя",
		GENITIVE = "костюма исследователя",
		DATIVE = "костюму исследователя",
		ACCUSATIVE = "костюм исследователя",
		INSTRUMENTAL = "костюмом исследователя",
		PREPOSITIONAL = "костюме исследователя"
	)
	icon_state = "explorer"
	item_state = "explorer"
	item_color = "explorer"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	hoodtype = /obj/item/clothing/head/hooded/explorer
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 50)
	allowed = list(/obj/item/flashlight, /obj/item/tank, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/pickaxe, /obj/item/twohanded/kinetic_crusher, /obj/item/hierophant_club, /obj/item/twohanded/fireaxe/boneaxe)
	resistance_flags = FIRE_PROOF
	hide_tail_by_species = list(SPECIES_VOX , SPECIES_VULPKANIN , SPECIES_UNATHI, SPECIES_ASHWALKER_BASIC, SPECIES_ASHWALKER_SHAMAN, SPECIES_DRACONOID, SPECIES_TAJARAN)

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/suit.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/suit.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
	)

/obj/item/clothing/head/hooded/explorer
	name = "explorer hood"
	desc = "Бронированный капюшон, созданный для исследования и работы в суровых условиях."
	ru_names = list(
		NOMINATIVE = "капюшон исследователя",
		GENITIVE = "капюшона исследователя",
		DATIVE = "капюшону исследователя",
		ACCUSATIVE = "капюшон исследователя",
		INSTRUMENTAL = "капюшоном исследователя",
		PREPOSITIONAL = "капюшоне исследователя"
	)
	icon_state = "explorer"
	item_state = "explorer"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR
	flags_cover = HEADCOVERSEYES
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 50)
	resistance_flags = FIRE_PROOF

	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/head.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/head.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/head.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/head.dmi',
		SPECIES_SKRELL = 'icons/mob/clothing/species/skrell/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi'
	)

/obj/item/clothing/suit/space/hostile_environment
	name = "H.E.C.K. suit"
	desc = "Экспериментальный Кинетический Защитный Обшитый Костюм: костюм, специально созданный для защиты от широкого спектра опасностей Лаваленда. Прошлому его владельцу этого, видимо, не хватило."
	ru_names = list(
		NOMINATIVE = "Э.К.З.О. костюм",
		GENITIVE = "Э.К.З.О. костюма ",
		DATIVE = "Э.К.З.О. костюму",
		ACCUSATIVE = "Э.К.З.О. костюм",
		INSTRUMENTAL = "Э.К.З.О. костюмом",
		PREPOSITIONAL = "Э.К.З.О. костюме"
	)
	icon_state = "hostile_env"
	item_state = "hostile_env"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | LAVA_PROOF | ACID_PROOF
	slowdown = 0
	armor = list("melee" = 70, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
	allowed = list(/obj/item/flashlight, /obj/item/tank, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/pickaxe, /obj/item/twohanded/kinetic_crusher, /obj/item/hierophant_club, /obj/item/twohanded/fireaxe/boneaxe)
	jetpack = /obj/item/tank/jetpack/suit
	jetpack_upgradable = TRUE

	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/suit.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/suit.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi',
	)


/obj/item/clothing/suit/space/hostile_environment/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spraycan_paintable)
	START_PROCESSING(SSobj, src)


/obj/item/clothing/suit/space/hostile_environment/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/clothing/suit/space/hostile_environment/process()
	var/mob/living/carbon/C = loc
	if(istype(C) && prob(2)) //cursed by bubblegum
		if(prob(15))
			new /obj/effect/hallucination/delusion(C.loc, C, force_kind = "demon", duration = 100, skip_nearby = 0)
			to_chat(C, span_colossus("<b>[pick("МЕНЯ НЕ УБИТЬ.", "НАЧНИ ТУТ РЕЗНЮ!", "Я ТЕБЯ ВИЖУ.", "МЫ ОДНО ЦЕЛОЕ!", "СМЕРТИ МЕНЯ НЕ СДЕРЖАТЬ.", "УСТРОЙ КРОВАВУЮ БАНЮ!")]</b>"))
		else
			to_chat(C, span_warning("[pick("Вы слышите тихий шепот.", "Вы чуете пепел.", "Вам жарко.", "Вы слышите рёв вдали.")]"))

/obj/item/clothing/head/helmet/space/hostile_environment
	name = "H.E.C.K. helmet"
	desc = "Экспериментальный Кинетический Защитный Обшитый Шлем: шлем, специально созданный для защиты от широкого спектра опасностей Лаваленда. Прошлому его владельцу этого, видимо, не хватило."
	ru_names = list(
		NOMINATIVE = "Э.К.З.О. шлем",
		GENITIVE = "Э.К.З.О. шлема ",
		DATIVE = "Э.К.З.О. шлему",
		ACCUSATIVE = "Э.К.З.О. шлем",
		INSTRUMENTAL = "Э.К.З.О. шлемом",
		PREPOSITIONAL = "Э.К.З.О. шлеме"
	)
	icon_state = "hostile_env"
	item_state = "hostile_env"
	w_class = WEIGHT_CLASS_NORMAL
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	armor = list("melee" = 70, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
	resistance_flags = FIRE_PROOF | LAVA_PROOF | ACID_PROOF

	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/helmet.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/helmet.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/helmet.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/helmet.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/helmet.dmi',
	)


/obj/item/clothing/head/helmet/space/hostile_environment/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spraycan_paintable)
	update_icon(UPDATE_OVERLAYS)


/obj/item/clothing/head/helmet/space/hostile_environment/update_overlays()
	. = ..()
	. += mutable_appearance(icon, "hostile_env_glass", appearance_flags = RESET_COLOR)


/obj/item/clothing/head/helmet/space/hardsuit/champion
	name = "champion's helmet"
	desc = "Лишь одного взгляда в глаза этого шлема хватит, чтобы посеять ужас."
	ru_names = list(
        NOMINATIVE = "чемпионский шлем",
        GENITIVE = "чемпионского шлема",
        DATIVE = "чемпионскому шлему",
        ACCUSATIVE = "чемпионский шлем",
        INSTRUMENTAL = "чемпионским шлемом",
        PREPOSITIONAL = "чемпионском шлеме"
	)
	icon_state = "hardsuit0-berserker"
	item_color = "berserker"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	heat_protection = HEAD
	armor = list(melee = 65, bullet = 50, laser = 50, energy = 50, bomb = 50, bio = 100, rad = 100, fire = 80, acid = 80)
	sprite_sheets = list(
		SPECIES_GREY = 'icons/mob/clothing/species/grey/helmet.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/helmet.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/helmet.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/helmet.dmi'
		)

/obj/item/clothing/suit/space/hardsuit/champion
	name = "champion's hardsuit"
	desc = "Изнутри этой брони эхом проносятся голоса, медленно сводя с ума своего носителя."
	ru_names = list(
        NOMINATIVE = "чемпионская броня",
        GENITIVE = "чемпионской брони",
        DATIVE = "чемпионской броне",
        ACCUSATIVE = "чемпионскую броню",
        INSTRUMENTAL = "чемпионской бронёй",
        PREPOSITIONAL = "чемпионской броне"
	)
	icon_state = "hardsuit-berserker"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	slowdown = 0.25 // you are wearing a POWERFUL energy suit, after all
	clothing_flags = FIXED_SLOWDOWN // no heretic magic
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/champion
	allowed = list(/obj/item/flashlight, /obj/item/tank, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/pickaxe, /obj/item/twohanded/kinetic_crusher, /obj/item/hierophant_club, /obj/item/twohanded/fireaxe/boneaxe)
	armor = list(melee = 65, bullet = 50, laser = 50, energy = 50, bomb = 50, bio = 100, rad = 100, fire = 80, acid = 80)
	sprite_sheets = list(
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/suit.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/suit.dmi'
		)

/obj/item/clothing/head/helmet/space/hardsuit/champion/templar
	name = "dark templar's helmet"
	desc = "Сквозь тьму мы видим свет."
	ru_names = list(
        NOMINATIVE = "шлем Чёрного Храмовника",
        GENITIVE = "шлема Чёрного Храмовника",
        DATIVE = "шлему Чёрного Храмовника",
        ACCUSATIVE = "шлем Чёрного Храмовника",
        INSTRUMENTAL = "шлемом Чёрного Храмовника",
        PREPOSITIONAL = "шлеме Чёрного Храмовника"
	)
	icon_state = "hardsuit0-templar"
	item_color = "templar"

/obj/item/clothing/suit/space/hardsuit/champion/templar
	name = "dark templar's hardsuit"
	desc = "Без жалости! Без сожалений! Без страха!"
	ru_names = list(
        NOMINATIVE = "доспехи Чёрного Храмовника",
        GENITIVE = "доспехов Чёрного Храмовника",
        DATIVE = "доспехам Чёрного Храмовника",
        ACCUSATIVE = "доспехи Чёрного Храмовника",
        INSTRUMENTAL = "доспехами Чёрного Храмовника",
        PREPOSITIONAL = "доспехах Чёрного Храмовника"
	)
	icon_state = "darktemplar-follower0"
	item_color = "darktemplar-follower0"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/champion/templar
	species_restricted = list(SPECIES_HUMAN, SPECIES_SLIMEPERSON, SPECIES_SKELETON, SPECIES_NUCLEATION, SPECIES_MACNINEPERSON, SPECIES_PLASMAMAN, SPECIES_DIONA, SPECIES_KIDAN, SPECIES_SHADOW_BASIC) // only humanoids. And we don't have animal sprites.

/obj/item/clothing/head/helmet/space/hardsuit/champion/templar/premium
	name = "high dark templar's helmet"
	desc = "Галактика принадлежит Императору..."
	ru_names = list(
        NOMINATIVE = "шлем высшего Чёрного Храмовника",
        GENITIVE = "шлема высшего Чёрного Храмовника",
        DATIVE = "шлему высшего Чёрного Храмовника",
        ACCUSATIVE = "шлем высшего Чёрного Храмовника",
        INSTRUMENTAL = "шлемом высшего Чёрного Храмовника",
        PREPOSITIONAL = "шлеме высшего Чёрного Храмовника"
	)
	icon_state = "hardsuit0-hightemplar"
	item_color = "hightemplar"

/obj/item/clothing/suit/space/hardsuit/champion/templar/premium
	name = "high dark templar's hardsuit"
	desc = "...и любой, кто оспаривает это — враг, которого необходимо уничтожить."
	ru_names = list(
        NOMINATIVE = "доспехи высшего Чёрного Храмовника",
        GENITIVE = "доспехов высшего Чёрного Храмовника",
        DATIVE = "доспехам высшего Чёрного Храмовника",
        ACCUSATIVE = "доспехи высшего Чёрного Храмовника",
        INSTRUMENTAL = "доспехами высшего Чёрного Храмовника",
        PREPOSITIONAL = "доспехах высшего Чёрного Храмовника"
	)
	icon_state = "darktemplar-chaplain0"
	item_color = "darktemplar-chaplain0"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/champion/templar/premium

/obj/item/clothing/head/helmet/space/hardsuit/champion/inquisitor
	name = "inquisitor's helmet"
	desc = "Шлем, носимый теми, кто зарабатывает на хлеб борьбой с паранормальным."
	ru_names = list(
        NOMINATIVE = "шлем инквизитора",
        GENITIVE = "шлема инквизитора",
        DATIVE = "шлему инквизитора",
        ACCUSATIVE = "шлем инквизитора",
        INSTRUMENTAL = "шлемом инквизитора",
        PREPOSITIONAL = "шлеме инквизитора"
	)
	icon_state = "hardsuit0-inquisitor"
	item_color = "inquisitor"

/obj/item/clothing/suit/space/hardsuit/champion/inquisitor
	name = "inquisitor's hardsuit"
	desc = "На этот скафандр наложены мощные охранные чары, защищающие владельца от паранормальных угроз любого характера."
	ru_names = list(
        NOMINATIVE = "скафандр инквизитора",
        GENITIVE = "скафандра инквизитора",
        DATIVE = "скафандру инквизитора",
        ACCUSATIVE = "скафандр инквизитора",
        INSTRUMENTAL = "скафандром инквизитора",
        PREPOSITIONAL = "скафандре инквизитора"
  )
	icon_state = "hardsuit-inquisitor"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/champion/inquisitor

/obj/item/clothing/suit/hooded/pathfinder
	name = "pathfinder cloak"
	desc = "Тяжёлая мантия, сшитая из сухожилий и шкур, предназначенная для защиты носителя от опасной погоды."
	ru_names = list(
        NOMINATIVE = "мантия первопроходца",
        GENITIVE = "мантии первопроходца",
        DATIVE = "мантии первопроходца",
        ACCUSATIVE = "мантию первопроходца",
        INSTRUMENTAL = "мантией первопроходца",
        PREPOSITIONAL = "мантии первопроходца"
	)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/pickaxe, /obj/item/twohanded/spear, /obj/item/organ/internal/regenerative_core/legion, /obj/item/kitchen/knife/combat/survival, /obj/item/twohanded/kinetic_crusher, /obj/item/hierophant_club, /obj/item/twohanded/fireaxe/boneaxe)
	icon_state = "pathcloak"
	item_state = "pathcloak"
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 40, "bomb" = 60, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 50)
	resistance_flags = FIRE_PROOF
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	hide_tail_by_species = list(SPECIES_VOX , SPECIES_VULPKANIN , SPECIES_UNATHI, SPECIES_ASHWALKER_BASIC, SPECIES_ASHWALKER_SHAMAN, SPECIES_DRACONOID, SPECIES_TAJARAN)
	hoodtype = /obj/item/clothing/head/hooded/pathfinder
	species_restricted = list("exclude", "lesser form")

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/suit.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/suit.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/suit.dmi',
	)

/obj/item/clothing/head/hooded/pathfinder
	name = "pathfinder kasa"
	desc = "Головной убор, созданный из костей и связок, предназначенный для защиты носителя от опасной погоды."
	ru_names = list(
        NOMINATIVE = "каса первопроходца",
        GENITIVE = "касы первопроходца",
        DATIVE = "касе первопроходца",
        ACCUSATIVE = "касу первопроходца",
        INSTRUMENTAL = "касой первопроходца",
        PREPOSITIONAL = "касе первопроходца"
	)
	icon_state = "pathhead"
	item_state = "pathhead"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR
	flags_cover = HEADCOVERSEYES
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 40, "bomb" = 60, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 50)
	resistance_flags = FIRE_PROOF
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/helmet.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/helmet.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/head.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/head.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/helmet.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/helmet.dmi',
	)
