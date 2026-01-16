/obj/item/wirecutters
	name = "wirecutters"
	desc = "Инструмент, предназначенный для перекусывания различных материалов."
	gender = PLURAL
	icon = 'icons/map_icons/items/_item.dmi'
	icon_state = "/obj/item/wirecutters"
	post_init_icon_state = "cutters"
	item_state = "cutters"
	righthand_file = 'icons/mob/inhands/tools_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/tools_lefthand.dmi'
	belt_icon = "cutters"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 6
	throwforce = 5
	throw_speed = 3
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=80)
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("ущипнул", "тяпнул")
	hitsound = 'sound/items/wirecutter.ogg'
	usesound = 'sound/items/wirecutter.ogg'
	drop_sound = 'sound/items/handling/drop/wirecutter_drop.ogg'
	pickup_sound = 'sound/items/handling/pickup/wirecutter_pickup.ogg'
	sharp = 1
	embed_chance = 5
	embedded_ignore_throwspeed_threshold = TRUE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 30)
	tool_behaviour = TOOL_WIRECUTTER
	toolbox_radial_menu_compatibility = TRUE
	greyscale_config = /datum/greyscale_config/wirecutters
	greyscale_config_inhand_left = /datum/greyscale_config/wirecutters_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/wirecutters_inhand_right
	greyscale_config_belt = /datum/greyscale_config/wirecutters_belt
	greyscale_colors = COLOR_RED
	/// If the item should be assigned a random color
	var/random_color = TRUE
	/// List of possible random colors
	var/static/list/wirecutter_colors = list(
		"blue" = "#1861d5",
		"red" = "#951710",
		"pink" = "#d5188d",
		"brown" = "#a05212",
		"green" = "#0e7f1b",
		"cyan" = "#18a2d5",
		"yellow" = "#d58c18"
	)

/obj/item/wirecutters/get_ru_names()
	return list(
		NOMINATIVE = "кусачки",
		GENITIVE = "кусачек",
		DATIVE = "кусачкам",
		ACCUSATIVE = "кусачки",
		INSTRUMENTAL = "кусачками",
		PREPOSITIONAL = "кусачках"
	)

/obj/item/wirecutters/Initialize(mapload, param_color = null)
	if(random_color)
		var/our_color = param_color || pick(wirecutter_colors)
		set_greyscale_colors(list(wirecutter_colors[our_color]))
		item_state = null
	. = ..()
	AddElement(/datum/element/falling_hazard, damage = force, hardhat_safety = TRUE, crushes = FALSE, impact_sound = hitsound)

/obj/item/wirecutters/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(istype(target) && istype(target.handcuffed, /obj/item/restraints/handcuffs/cable))
		var/obj/item/cuffs = target.handcuffed
		target.balloon_alert_to_viewers("перекусыва[PLUR_ET_YUT(user)] стяжки", "стяжки перекусаны")
		play_tool_sound(target, 100)
		target.temporarily_remove_item_from_inventory(cuffs, force = TRUE)
		qdel(cuffs)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	var/mob/living/carbon/human/human_target = target
	if(istype(human_target) && human_target.exists_tourniquet())
		human_target.cut_all_tourniquets(user)
		human_target.balloon_alert_to_viewers("турникеты срезаны!")
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/item/wirecutters/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] перекусыва[PLUR_ET_YUT(user)] свою артерию, используя [declent_ru(ACCUSATIVE)]! Это похоже на попытку самоубийства!"))
	playsound(loc, usesound, 50, TRUE, -1)
	return BRUTELOSS

/obj/item/wirecutters/brass
	name = "brass wirecutters"
	desc = "Инструмент, предназначенный для перекусывания различных материалов. \
			Ручка на ощупь ледяная."
	icon = 'icons/obj/tools.dmi'
	icon_state = "cutters_brass"
	belt_icon = "cutters_brass"
	post_init_icon_state = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_colors = null
	greyscale_config_belt = null
	toolspeed = 0.5
	random_color = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/wirecutters/brass/get_ru_names()
	return list(
		NOMINATIVE = "латунные кусачки",
		GENITIVE = "латунных кусачек",
		DATIVE = "латунным кусачкам",
		ACCUSATIVE = "латунные кусачки",
		INSTRUMENTAL = "латунными кусачками",
		PREPOSITIONAL = "латунных кусачках"
	)

/obj/item/wirecutters/abductor
	name = "alien wirecutters"
	desc = "Инструмент, предназначенный для перекусывания различных материалов. \
			Лезвия из серебристо-зелёного металла кажутся невероятно острыми."
	icon_state = "cutters"
	icon = 'icons/obj/abductor.dmi'
	item_state = "cutters_alien"
	belt_icon = "alien_wirecutters"
	post_init_icon_state = null
	toolspeed = 0.1
	origin_tech = "materials=5;engineering=4;abductor=3"
	random_color = FALSE
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_belt = null
	greyscale_colors = null

/obj/item/wirecutters/abductor/get_ru_names()
	return list(
		NOMINATIVE = "чужеродные кусачки",
		GENITIVE = "чужеродных кусачек",
		DATIVE = "чужеродным кусачкам",
		ACCUSATIVE = "чужеродные кусачки",
		INSTRUMENTAL = "чужеродными кусачками",
		PREPOSITIONAL = "чужеродных кусачках"
	)

/obj/item/wirecutters/cyborg
	name = "alien wirecutters"
	desc = "Инструмент, предназначенный для перекусывания различных материалов. \
			Специализированная версия для установки в роботизированные системы."
	toolspeed = 0.5
	flags = parent_type::flags | NO_NEW_GAGS_PREVIEW

/obj/item/wirecutters/cyborg/get_ru_names()
	return list(
		NOMINATIVE = "автоматизированные кусачки",
		GENITIVE = "автоматизированных кусачек",
		DATIVE = "автоматизированным кусачкам",
		ACCUSATIVE = "автоматизированные кусачки",
		INSTRUMENTAL = "автоматизированными кусачками",
		PREPOSITIONAL = "автоматизированных кусачках"
	)

/obj/item/wirecutters/power
	name = "jaws of life"
	desc = "Гидравлический инструмент, предназначенный для использования в качестве рычага или для перерезания материалов. \
			Изначально использовался для спасательных работ, откуда и получил своё название, \
			но в дальнейшем получил развитие в качестве инженерного инструмента."
	icon = 'icons/obj/tools.dmi'
	icon_state = "jaws_cutter"
	item_state = "jawsoflife"
	belt_icon = "jaws_of_life"
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_belt = null
	greyscale_colors = null
	post_init_icon_state = null
	origin_tech = "materials=2;engineering=2"
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_TITANIUM=25)
	usesound = 'sound/items/jaws_cut.ogg'
	toolspeed = 0.25
	random_color = FALSE
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/wirecutters/power/get_ru_names()
	return list(
		NOMINATIVE = "челюсти жизни",
		GENITIVE = "челюстей жизни",
		DATIVE = "челюстям жизни",
		ACCUSATIVE = "челюсти жизни",
		INSTRUMENTAL = "челюстями жизни",
		PREPOSITIONAL = "челюстях жизни"
	)

/obj/item/wirecutters/power/examine(mob/user)
	. = ..()
	. += span_notice("Установлена <b>режущая</b> насадка.")

/obj/item/wirecutters/power/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_jaws.ogg', 50, TRUE)
	var/obj/item/crowbar/power/pryjaws = new /obj/item/crowbar/power
	balloon_alert(user, "установлена поддевающая насадка")
	qdel(src)
	user.put_in_active_hand(pryjaws)

/obj/item/wirecutters/power/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] помеща[PLUR_ET_YUT(user)] свою голову между лезвиями [declent_ru(GENITIVE)]. Это похоже на попытку самоубийства!"))
	playsound(loc, 'sound/items/jaws_cut.ogg', 50, TRUE, -1)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/head/head = H.bodyparts_by_name[BODY_ZONE_HEAD]
		if(head)
			head.droplimb(0, DROPLIMB_BLUNT, FALSE, TRUE)
			playsound(loc, SFX_DESECRATION, 50, TRUE, -1)
	return BRUTELOSS
