/*****************Pickaxes & Drills & Shovels****************/
/obj/item/pickaxe
	name = "pickaxe"
	desc = "Стандартная кирка, предназначенная для разрушения камней."
	ru_names = list(
		NOMINATIVE = "кирка",
		GENITIVE = "кирки",
		DATIVE = "кирке",
		ACCUSATIVE = "кирку",
		INSTRUMENTAL = "киркой",
		PREPOSITIONAL = "кирке"
	)
	gender = FEMALE
	icon = 'icons/obj/items.dmi'
	icon_state = "pickaxe"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 15
	throwforce = 10
	item_state = "pickaxe"
	w_class = WEIGHT_CLASS_BULKY
	materials = list(MAT_METAL=2000) //one sheet, but where can you make them?
	origin_tech = "materials=2;engineering=3"
	attack_verb = list("ударил", "уколол", "атаковал")
	var/drill_verb = "picking"
	sharp = 1
	embed_chance = 15
	embedded_ignore_throwspeed_threshold = TRUE
	var/excavation_amount = 100
	usesound = 'sound/effects/picaxe1.ogg'
	toolspeed = 0.8


/obj/item/pickaxe/emergency
	name = "emergency disembarkation tool"
	desc = "Кирка, предназначенная для спасения из затруднительных ситуаций."
	ru_names = list(
		NOMINATIVE = "инструмент для экстренной раскопки",
		GENITIVE = "инструмента для экстренной раскопки",
		DATIVE = "инструменту для экстренной раскопки",
		ACCUSATIVE = "инструмент для экстренной раскопки",
		INSTRUMENTAL = "инструментом для экстренной раскопки",
		PREPOSITIONAL = "инструменте для экстренной раскопки"
	)
	gender = MALE
	icon_state = "emergency_disembarkation_tool"
	item_state = "emergency_disembarkation_tool"

/obj/item/pickaxe/safety
	name = "safety pickaxe"
	desc = "Кирка, специально спроектированная исключительно для добычи ресурсов. Крайне неэффективна в качестве оружия."
	ru_names = list(
		NOMINATIVE = "безопасная кирка",
		GENITIVE = "безопасной кирки",
		DATIVE = "безопасной кирке",
		ACCUSATIVE = "безопасную кирку",
		INSTRUMENTAL = "безопасной киркой",
		PREPOSITIONAL = "безопасной кирке"
	)
	icon_state = "safety_pickaxe"
	item_state = "safety_pickaxe"
	force = 1
	throwforce = 1
	attack_verb = list("неэффективно ударил")

/obj/item/pickaxe/mini
	name = "compact pickaxe"
	desc = "Сильно уменьшенная версия стандартной кирки."
	ru_names = list(
		NOMINATIVE = "компактная кирка",
		GENITIVE = "компактной кирки",
		DATIVE = "компактной кирке",
		ACCUSATIVE = "компактую кирку",
		INSTRUMENTAL = "компактной киркой",
		PREPOSITIONAL = "компактной кирке"
	)
	icon_state = "compact_pickaxe"
	item_state = "compact_pickaxe"
	force = 10
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL = 1000)

/obj/item/pickaxe/silver
	name = "silver-plated pickaxe"
	desc = "Кирка, сделанная из серебра. Она показывает себя слегка лучше в добыче ресурсов, чем стандартная."
	ru_names = list(
		NOMINATIVE = "кирка с серебрянным наконечником",
		GENITIVE = "кирки с серебрянным наконечником",
		DATIVE = "кирке с серебрянным наконечником",
		ACCUSATIVE = "кирку с серебрянным наконечником",
		INSTRUMENTAL = "киркой с серебрянным наконечником",
		PREPOSITIONAL = "кирке с серебрянным наконечником"
	)
	icon_state = "spickaxe"
	item_state = "spickaxe"
	belt_icon = "silver-plated pickaxe"
	origin_tech = "materials=3;engineering=4"
	toolspeed = 0.4 //mines faster than a normal pickaxe, bought from mining vendor
	force = 17

/obj/item/pickaxe/gold
	name = "gold-tipped pickaxe"
	desc = "Кирка, сделанная из золота. Она показывает себя значительно лучше в добыче ресурсов, чем стандартная."
	ru_names = list(
		NOMINATIVE = "кирка с золотым наконечником",
		GENITIVE = "кирки с золотым наконечником",
		DATIVE = "кирке с золотым наконечником",
		ACCUSATIVE = "кирку с золотым наконечником",
		INSTRUMENTAL = "киркой с золотым наконечником",
		PREPOSITIONAL = "кирке с золотым наконечником"
	)
	icon_state = "gpickaxe"
	item_state = "gpickaxe"
	belt_icon = "golden pickaxe"
	origin_tech = "materials=4;engineering=4"
	toolspeed = 0.3
	force = 18

/obj/item/pickaxe/diamond
	name = "diamond-tipped pickaxe"
	desc = "Кирка с алмазным наконечником. Крайне эффективна в добыче камня и вскапывании земли."
	ru_names = list(
		NOMINATIVE = "кирка с алмазным наконечником",
		GENITIVE = "кирки с алмазным наконечником",
		DATIVE = "кирке с алмазным наконечником",
		ACCUSATIVE = "кирку с алмазным наконечником",
		INSTRUMENTAL = "киркой с алмазным наконечником",
		PREPOSITIONAL = "кирке с алмазным наконечником"
	)
	icon_state = "dpickaxe"
	item_state = "dpickaxe"
	belt_icon = "diamond-tipped pickaxe"
	origin_tech = "materials=5;engineering=4"
	toolspeed = 0.2
	force = 19

/obj/item/pickaxe/drill
	name = "mining drill"
	desc = "Электрическая буровая дрелль, используемая теми, для кого кирка слишком тяжела в обращении."
	ru_names = list(
		NOMINATIVE = "шахтёрская дрель",
		GENITIVE = "шахтёрской дрели",
		DATIVE = "шахтёрской дрели",
		ACCUSATIVE = "шахтёрскую дрель",
		INSTRUMENTAL = "шахтёрской дрелью",
		PREPOSITIONAL = "шахтёрской дрели"
	)
	icon_state = "handdrill"
	item_state = "jackhammer"
	toolspeed = 0.4 //available from roundstart, faster than a pickaxe.
	hitsound = 'sound/weapons/drill.ogg'
	usesound = 'sound/weapons/drill.ogg'
	origin_tech = "materials=2;powerstorage=2;engineering=3"

/obj/item/pickaxe/drill/cyborg
	name = "cyborg mining drill"
	desc = "Встроенная электрическая буровая дрелль."
	ru_names = list(
		NOMINATIVE = "шахтёрская дрель робота",
		GENITIVE = "шахтёрской дрели робота",
		DATIVE = "шахтёрской дрели робота",
		ACCUSATIVE = "шахтёрскую дрель робота",
		INSTRUMENTAL = "шахтёрской дрелью робота",
		PREPOSITIONAL = "шахтёрской дрели робота"
	)


/obj/item/pickaxe/drill/cyborg/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CYBORG_ITEM_TRAIT)


/obj/item/pickaxe/drill/diamonddrill
	name = "diamond-tipped mining drill"
	desc = "У тебя есть дрель, которая пронзит небеса!"
	ru_names = list(
		NOMINATIVE = "алмазная шахтёрская дрель",
		GENITIVE = "алмазной шахтёрской дрели",
		DATIVE = "алмазной шахтёрской дрели",
		ACCUSATIVE = "алмазную шахтёрскую дрель",
		INSTRUMENTAL = "алмазной шахтёрской дрелью",
		PREPOSITIONAL = "алмазной шахтёрской дрели"
	)
	icon_state = "diamonddrill"
	origin_tech = "materials=6;powerstorage=4;engineering=4"
	toolspeed = 0.1

/obj/item/pickaxe/drill/cyborg/diamond //This is the BORG version!
	name = "diamond-tipped cyborg mining drill" //To inherit the NODROP trait, and easier to change borg specific drill mechanics.
	ru_names = list(
		NOMINATIVE = "алмазная шахтёрская дрель робота",
		GENITIVE = "алмазной шахтёрской дрели робота",
		DATIVE = "алмазной шахтёрской дрели робота",
		ACCUSATIVE = "алмазную шахтёрскую дрель робота",
		INSTRUMENTAL = "алмазной шахтёрской дрелью робота",
		PREPOSITIONAL = "алмазной шахтёрской дрели робота"
	)
	icon_state = "diamonddrill"
	toolspeed = 0.1

/obj/item/pickaxe/drill/jackhammer
	name = "sonic jackhammer"
	desc = "Уничтожает камни с использованием звука, может использоваться как инструмент для сноса стен."
	ru_names = list(
		NOMINATIVE = "звуковой отбойный молот",
		GENITIVE = "звукового отбойного молота",
		DATIVE = "звуковому отбойному молоту",
		ACCUSATIVE = "звуковой отбойный молот",
		INSTRUMENTAL = "звуковым отбойным молотом",
		PREPOSITIONAL = "звуковом отбойным молоте"
	)
	icon_state = "jackhammer"
	item_state = "jackhammer"
	origin_tech = "materials=6;powerstorage=4;engineering=5;magnets=4"
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	usesound = 'sound/weapons/sonic_jackhammer.ogg'
	toolspeed = 0.0 //the epitome of powertools, literally instant
	var/wall_toolspeed = 0.1 //instant wall breaking is bad.

/obj/item/shovel
	name = "shovel"
	desc = "Массивный инструмент для вскапывания и перемещения земли."
	ru_names = list(
		NOMINATIVE = "лопата",
		GENITIVE = "лопаты",
		DATIVE = "лопате",
		ACCUSATIVE = "лопату",
		INSTRUMENTAL = "лопатой",
		PREPOSITIONAL = "лопате"
	)
	gender = FEMALE
	icon = 'icons/obj/items.dmi'
	icon_state = "shovel"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 8
	throwforce = 4
	item_state = "shovel"
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=50)
	origin_tech = "materials=2;engineering=2"
	attack_verb = list("ударил", "огрел")
	hitsound = 'sound/effects/Shovel_hitting_sound.ogg'
	usesound = 'sound/effects/shovel_dig.ogg'
	toolspeed = 0.8

/obj/item/shovel/spade
	name = "spade"
	desc = "Маленький инструмент для вскапывания и перемещения земли."
	ru_names = list(
		NOMINATIVE = "лопатка",
		GENITIVE = "лопатки",
		DATIVE = "лопатке",
		ACCUSATIVE = "лопатку",
		INSTRUMENTAL = "лопаткой",
		PREPOSITIONAL = "лопатке"
	)
	icon_state = "spade"
	item_state = "spade"
	belt_icon = "spade"
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL

/obj/item/shovel/spade/wooden
	name = "wooden spade"
	desc = "Маленький инструмент для вскапывания и перемещения земли. Эта модель сделана из древесины."
	ru_names = list(
		NOMINATIVE = "деревянная лопатка",
		GENITIVE = "деревянной лопатки",
		DATIVE = "деревянной лопатке",
		ACCUSATIVE = "деревянную лопатку",
		INSTRUMENTAL = "деревянной лопаткой",
		PREPOSITIONAL = "деревянной лопатке"
	)
	icon_state = "wooden_spade"
	lefthand_file = 'icons/mob/inhands/lavaland/misc_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/misc_righthand.dmi'
	item_state = "small_shovel"

/obj/item/shovel/safety
	name = "safety shovel"
	desc = "Массивный инструмент для вскапывания и перемещения земли. Данная версия была модифицирована для большей безопасности и крайне неэффективна в качестве оружия."
	ru_names = list(
		NOMINATIVE = "безопасная лопата",
		GENITIVE = "безопасной лопаты",
		DATIVE = "безопасной лопате",
		ACCUSATIVE = "безопасную лопату",
		INSTRUMENTAL = "безопасной лопатой",
		PREPOSITIONAL = "безопасной лопате"
	)
	icon_state = "safety_shovel"
	item_state = "safety_shovel"
	force = 1
	throwforce = 1
	attack_verb = list("неэффективно ударил")
