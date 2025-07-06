/* Kitchen tools
 * Contains:
 *		Utensils
 *		Spoons
 *		Forks
 *		Knives
 *		Kitchen knives
 *		Butcher's cleaver
 *		Rolling Pins
 *		Candy Moulds
 *		Sushi Mat
 *		Circular cutter
 */

/obj/item/kitchen
	icon = 'icons/obj/kitchen.dmi'
	origin_tech = "materials=1"




/*
 * Utensils
 */
/obj/item/kitchen/utensil
	force = 5.0
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0.0
	throw_speed = 3
	throw_range = 5
	flags = CONDUCT
	attack_verb = list("атаковал", "уколол", "ткнул")
	hitsound = 'sound/weapons/bladeslice.ogg'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30)
	sharp = 0
	var/max_contents = 1


/obj/item/kitchen/utensil/Initialize(mapload)
	. = ..()

	if(prob(60))
		set_base_pixel_y(rand(0, 4))

	create_reagents(5)


/obj/item/kitchen/utensil/update_overlays()
	. = ..()
	var/obj/item/reagent_containers/food/snack = locate() in src
	if(snack)
		var/mutable_appearance/food_olay = mutable_appearance('icons/obj/kitchen.dmi', "loadedfood", color = snack.filling_color)
		food_olay.pixel_w = pixel_x
		food_olay.pixel_z = pixel_y
		. += food_olay


/obj/item/kitchen/utensil/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!iscarbon(target))
		return ..()

	if(user.a_intent != INTENT_HELP)
		if(user.zone_selected == BODY_ZONE_HEAD || user.zone_selected == BODY_ZONE_PRECISE_EYES)
			if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
				target = user
			return eyestab(target, user)
		return ..()

	. = ATTACK_CHAIN_PROCEED
	if(!length(contents))
		return .

	var/obj/item/reagent_containers/food/snacks/toEat = contents[1]
	if(!istype(toEat))
		return .

	if(!get_location_accessible(target, BODY_ZONE_PRECISE_MOUTH))
		if(target == user)
			balloon_alert(user, span_warning("лицо скрыто"))
		else
			balloon_alert(user, span_warning("мешает скрытое лицо"))
		return .

	if(target.eat(toEat, user))
		toEat.On_Consume(target, user)
		update_icon(UPDATE_OVERLAYS)
		return .|ATTACK_CHAIN_SUCCESS


/obj/item/kitchen/utensil/fork
	name = "fork"
	desc = "Обычная вилка. Довольно острая."
	ru_names = list(
		NOMINATIVE = "вилка",
		GENITIVE = "вилки",
		DATIVE = "вилке",
		ACCUSATIVE = "вилку",
		INSTRUMENTAL = "вилкой",
		PREPOSITIONAL = "вилке"
	)
	icon_state = "fork"

/obj/item/kitchen/utensil/pfork
	name = "plastic fork"
	desc = "Ура, не нужно мыть посуду."
	ru_names = list(
		NOMINATIVE = "пластиковая вилка",
		GENITIVE = "пластиковой вилки",
		DATIVE = "пластиковой вилке",
		ACCUSATIVE = "пластиковую вилку",
		INSTRUMENTAL = "пластиковой вилкой",
		PREPOSITIONAL = "пластиковой вилке"
	)
	icon_state = "pfork"

/obj/item/kitchen/utensil/spoon
	name = "spoon"
	desc = "Обычная ложка. В ней можно увидеть своё перевёрнутое отражение."
	ru_names = list(
		NOMINATIVE = "ложка",
		GENITIVE = "ложки",
		DATIVE = "ложке",
		ACCUSATIVE = "ложку",
		INSTRUMENTAL = "ложкой",
		PREPOSITIONAL = "ложке"
	)
	icon_state = "spoon"
	attack_verb = list("атаковал", "ткнул")

/obj/item/kitchen/utensil/pspoon
	name = "plastic spoon"
	desc = "Пластиковая ложка. Как банально."
	ru_names = list(
		NOMINATIVE = "пластиковая ложка",
		GENITIVE = "пластиковой ложки",
		DATIVE = "пластиковой ложке",
		ACCUSATIVE = "пластиковую ложку",
		INSTRUMENTAL = "пластиковой ложкой",
		PREPOSITIONAL = "пластиковой ложке"
	)
	icon_state = "pspoon"
	attack_verb = list("атаковал", "ткнул")

/obj/item/kitchen/utensil/spork
	name = "spork"
	desc = "Гибрид ложки и вилки. Восхититесь его инновационным дизайном."
	ru_names = list(
		NOMINATIVE = "ловилка",
		GENITIVE = "ловилки",
		DATIVE = "ловилке",
		ACCUSATIVE = "ловилку",
		INSTRUMENTAL = "ловилкой",
		PREPOSITIONAL = "ловилке"
	)
	icon_state = "spork"
	attack_verb = list("атаковал", "ткнул")

/obj/item/kitchen/utensil/pspork
	name = "plastic spork"
	desc = "Пластиковая виложка, или ловилка..."
	ru_names = list(
		NOMINATIVE = "пластиковая ловилка",
		GENITIVE = "пластиковой ловилки",
		DATIVE = "пластиковой ловилке",
		ACCUSATIVE = "пластиковую ловилку",
		INSTRUMENTAL = "пластиковой ловилкой",
		PREPOSITIONAL = "пластиковой ловилке"
	)
	icon_state = "pspork"
	attack_verb = list("атаковал", "ткнул")

/*
 * Knives
 */
/obj/item/kitchen/knife
	name = "kitchen knife"
	desc = "Универсальный поварской нож от знаменитого повара Мамут Рахала. Гарантированно остаётся острым годами."
	ru_names = list(
		NOMINATIVE = "кухонный нож",
		GENITIVE = "кухонного ножа",
		DATIVE = "кухонному ножу",
		ACCUSATIVE = "кухонный нож",
		INSTRUMENTAL = "кухонным ножом",
		PREPOSITIONAL = "кухонном ноже"
	)
	icon_state = "knife"
	flags = CONDUCT
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	pickup_sound = 'sound/items/handling/pickup/knife_pickup.ogg'
	drop_sound = 'sound/items/handling/drop/knife_drop.ogg'
	throw_speed = 3
	throw_range = 6
	materials = list(MAT_METAL=12000)
	attack_verb = list("полоснул", "уколол", "поранил", "порезал")
	sharp = TRUE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	embed_chance = 45
	embedded_ignore_throwspeed_threshold = TRUE
	/// Can this item be attached as a bayonet to the gun?
	var/bayonet_suitable = FALSE
	/// Used in combination with throwing martial art, to avoid sharpening checks overhead
	var/default_force
	/// Same as above
	var/default_throwforce


/obj/item/kitchen/knife/Initialize(mapload)
	. = ..()
	default_force = force
	default_throwforce = throwforce


/obj/item/kitchen/knife/sharpen_act(obj/item/whetstone/whetstone, mob/user)
	. = ..()
	default_force = force
	default_throwforce = throwforce


/obj/item/kitchen/knife/suicide_act(mob/user)
	user.visible_message(pick(
		span_suicide("[user] реж[pluralize_ru(user.gender,"ет","ут")] свои запястья [declent_ru(INSTRUMENTAL)]! Похоже, [genderize_ru(user.gender,"он","она","оно","они")] пыта[pluralize_ru(user.gender,"ет","ют")]ся покончить с жизнью."),
		span_suicide("[user] перереза[pluralize_ru(user.gender,"ет","ют")] себе горло [declent_ru(INSTRUMENTAL)]! Похоже, [genderize_ru(user.gender,"он","она","оно","они")] пыта[pluralize_ru(user.gender,"ет","ют")]ся покончить с жизнью."),
		span_suicide("[user] вспарыва[pluralize_ru(user.gender,"ет","ют")] себе живот [declent_ru(INSTRUMENTAL)]! Похоже, [genderize_ru(user.gender,"он","она","оно","они")] пыта[pluralize_ru(user.gender,"ет","ют")]ся совершить сэппуку."))
	)
	return BRUTELOSS

/obj/item/kitchen/knife/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = INFINITY, dodgeable = TRUE)
	. = ..()
	playsound(src, 'sound/weapons/knife_holster/knife_throw.ogg', 30, 1)


/obj/item/kitchen/knife/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/datum/martial_art/throwing/MA = throwingdatum?.thrower?.mind?.martial_art
	if(istype(MA) && is_type_in_list(src, MA.knife_types, FALSE))
		embed_chance = MA.knife_embed_chance
		throwforce = default_throwforce + MA.knife_bonus_damage
		shields_penetration = initial(shields_penetration) + MA.shields_penetration_bonus
	return ..()


/obj/item/kitchen/knife/after_throw(datum/callback/callback)
	embed_chance = initial(embed_chance)
	throwforce = default_throwforce
	shields_penetration = initial(shields_penetration)
	return ..()


/obj/item/kitchen/knife/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	var/datum/martial_art/throwing/MA = user?.mind?.martial_art
	if(istype(MA) && is_type_in_list(src, MA.knife_types, FALSE))
		force = default_force + MA.knife_bonus_damage
		if(user.zone_selected == BODY_ZONE_HEAD && user.a_intent == INTENT_HARM)
			if(MA.neck_cut(target, user))
				return ATTACK_CHAIN_PROCEED_SUCCESS
	. = ..()
	force = default_force


/obj/item/kitchen/knife/attack_obj(obj/object, mob/living/user, params)
	var/datum/martial_art/throwing/MA = user?.mind?.martial_art
	if(istype(MA) && is_type_in_list(src, MA.knife_types, FALSE))
		force = default_force + MA.knife_bonus_damage
	. = ..()
	force = default_force


/obj/item/kitchen/knife/plastic
	name = "plastic knife"
	desc = "Самый тупой из всех клинков."
	ru_names = list(
		NOMINATIVE = "пластиковый нож",
		GENITIVE = "пластикового ножа",
		DATIVE = "пластиковому ножу",
		ACCUSATIVE = "пластиковый нож",
		INSTRUMENTAL = "пластиковым ножом",
		PREPOSITIONAL = "пластиковом ноже"
	)
	icon_state = "pknife"
	item_state = "knife"
	sharp = 0
	pickup_sound = 'sound/items/handling/pickup/bone_pickup.ogg'
	drop_sound = 'sound/items/handling/drop/bone_drop.ogg'

/obj/item/kitchen/knife/ritual
	name = "ritual knife"
	desc = "Потусторонние энергии, когда-то питавшие этот клинок, теперь дремлют."
	ru_names = list(
		NOMINATIVE = "ритуальный кинжал",
		GENITIVE = "ритуального кинжала",
		DATIVE = "ритуальному кинжалу",
		ACCUSATIVE = "ритуальный кинжал",
		INSTRUMENTAL = "ритуальным кинжалом",
		PREPOSITIONAL = "ритуальном кинжале"
	)
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/kitchen/knife/butcher
	name = "butcher's cleaver"
	desc = "Огромный мясницкий тесак, предназначенный для измельчения мяса. В том числе и клоунов и их субпродуктов."
	ru_names = list(
		NOMINATIVE = "мясницкий тесак",
		GENITIVE = "мясницкого тесака",
		DATIVE = "мясницкому тесаку",
		ACCUSATIVE = "мясницкий тесак",
		INSTRUMENTAL = "мясницким тесаком",
		PREPOSITIONAL = "мясницком тесаке"
	)
	icon_state = "butch"
	flags = CONDUCT
	force = 15
	throwforce = 8
	attack_verb = list("полоснул", "уколол", "поранил", "порезал")
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/kitchen/knife/butcher/sharped
	desc = "Огромный мясницкий тесак, предназначенный для измельчения мяса. В том числе и клоунов и их субпродуктов. Блестит от заточки."

/obj/item/kitchen/knife/butcher/sharped/Initialize(mapload)
	. = ..()
	SEND_SIGNAL(src, COMSIG_ITEM_SHARPEN_ACT, 4, 30)

/obj/item/kitchen/knife/butcher/meatcleaver
	name = "meat cleaver"
	ru_names = list(
		NOMINATIVE = "тесак для мяса",
		GENITIVE = "тесака для мяса",
		DATIVE = "тесаку для мяса",
		ACCUSATIVE = "тесак для мяса",
		INSTRUMENTAL = "тесаком для мяса",
		PREPOSITIONAL = "тесаке для мяса"
	)
	icon_state = "mcleaver"
	item_state = "mcleaver"
	force = 25
	throwforce = 15

/obj/item/kitchen/knife/combat
	name = "combat knife"
	desc = "Армейский тактический нож для выживания."
	ru_names = list(
		NOMINATIVE = "боевой нож",
		GENITIVE = "боевого ножа",
		DATIVE = "боевому ножу",
		ACCUSATIVE = "боевой нож",
		INSTRUMENTAL = "боевым ножом",
		PREPOSITIONAL = "боевом ноже"
	)
	icon_state = "combatknife"
	item_state = "knife"
	belt_icon = "combat_knife"
	force = 20
	throwforce = 20
	origin_tech = "materials=3;combat=4"
	attack_verb = list("полоснул", "уколол", "поранил", "порезал")
	bayonet_suitable = TRUE
	embed_chance = 90

/obj/item/kitchen/knife/combat/survival
	name = "survival knife"
	desc = "Охотничий нож повышенной прочности."
	ru_names = list(
		NOMINATIVE = "нож для выживания",
		GENITIVE = "ножа для выживания",
		DATIVE = "ножу для выживания",
		ACCUSATIVE = "нож для выживания",
		INSTRUMENTAL = "ножом для выживания",
		PREPOSITIONAL = "ноже для выживания"
	)
	icon_state = "survivalknife"
	belt_icon = "survival_knife"
	force = 15
	throwforce = 15

/obj/item/kitchen/knife/combat/throwing
	name = "throwing knife"
	desc = "Отточенный чёрный нож. Создан для метания. Цельная металлическая конструкция. На поверхности царапины.\nОтличное решение как для живых проблем, так и для нарезки торта."
	ru_names = list(
		NOMINATIVE = "метательный нож",
		GENITIVE = "метательного ножа",
		DATIVE = "метательному ножу",
		ACCUSATIVE = "метательный нож",
		INSTRUMENTAL = "метательным ножом",
		PREPOSITIONAL = "метательном ноже"
	)
	icon_state = "throwingknife"
	item_state = "throwingknife"
	belt_icon = "survival_knife"
	force = 15
	throwforce = 15

/obj/item/kitchen/knife/combat/survival/bone
	name = "bone dagger"
	desc = "Острая кость – минимум для выживания."
	ru_names = list(
		NOMINATIVE = "костяной кинжал",
		GENITIVE = "костяного кинжала",
		DATIVE = "костяному кинжалу",
		ACCUSATIVE = "костяной кинжал",
		INSTRUMENTAL = "костяным кинжалом",
		PREPOSITIONAL = "костяном кинжале"
	)
	item_state = "bone_dagger"
	icon_state = "bone_dagger"
	belt_icon = "bone_dagger"
	desc = "Острая кость – минимум для выживания."
	ru_names = list(
		NOMINATIVE = "костяной кинжал",
		GENITIVE = "костяного кинжала",
		DATIVE = "костяному кинжалу",
		ACCUSATIVE = "костяной кинжал",
		INSTRUMENTAL = "костяным кинжалом",
		PREPOSITIONAL = "костяном кинжале"
	)
	materials = list()
	pickup_sound = 'sound/items/handling/pickup/bone_pickup.ogg'
	drop_sound = 'sound/items/handling/drop/bone_drop.ogg'

/obj/item/kitchen/knife/combat/survival/bone/eel
	name = "eel sharpened tail"
	desc = "Бритвенно-острый хвост донного угля, аккуратно отделённый от основного тела рыбы. Из такого выйдет отличный нож или наконечник для копья."
	ru_names = list(
		NOMINATIVE = "хвост донного угря",
		GENITIVE = "хвоста донного угря",
		DATIVE = "хвосту донного угря",
		ACCUSATIVE = "хвост донного угря",
		INSTRUMENTAL = "хвостом донного угря",
		PREPOSITIONAL = "хвосте донного угря"
	)
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "eel_sharpened_tail"
	lefthand_file = 'icons/mob/inhands/lavaland/fish_items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/fish_items_righthand.dmi'
	item_state = "eel_sharpened_tail"

/obj/item/kitchen/knife/combat/cyborg
	name = "cyborg knife"
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "knife"
	desc = "A cyborg-mounted plasteel knife. Extremely sharp and durable."
	origin_tech = null

/obj/item/kitchen/knife/combat/cyborg/mecha
	force = 25
	armour_penetration = 20
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	slot_flags = null
	w_class = WEIGHT_CLASS_HUGE
	materials = null

/obj/item/kitchen/knife/carrotshiv
	name = "carrot shiv"
	desc = "В отличие от обычной морковки, эту лучше держать подальше от глаз."
	ru_names = list(
		NOMINATIVE = "морковная заточка",
		GENITIVE = "морковной заточки",
		DATIVE = "морковной заточке",
		ACCUSATIVE = "морковную заточку",
		INSTRUMENTAL = "морковной заточкой",
		PREPOSITIONAL = "морковной заточке"
	)
	icon_state = "carrotshiv"
	item_state = "carrotshiv"
	force = 8
	throwforce = 12 //fuck git
	materials = list()
	origin_tech = "biotech=3;combat=2"
	attack_verb = list("порезал", "уколол")
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	pickup_sound = 'sound/items/handling/pickup/bone_pickup.ogg'
	drop_sound = 'sound/items/handling/drop/bone_drop.ogg'

/obj/item/kitchen/knife/glassshiv
	name = "glass shiv"
	desc = "Осколок стекла, обмотанный тряпкой."
	ru_names = list(
		NOMINATIVE = "стеклянная заточка",
		GENITIVE = "стеклянной заточки",
		DATIVE = "стеклянной заточке",
		ACCUSATIVE = "стеклянную заточку",
		INSTRUMENTAL = "стеклянной заточкой",
		PREPOSITIONAL = "стеклянной заточке"
	)
	icon_state = "glass_shiv"
	item_state = "knife"
	force = 7
	throwforce = 8
	materials = list(MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	attack_verb = list("порезал", "уколол")
	armor = list("melee" = 100, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 100)
	pickup_sound = 'sound/items/handling/pickup/bone_pickup.ogg'
	drop_sound = 'sound/items/handling/drop/bone_drop.ogg'
	var/size


/obj/item/kitchen/knife/glassshiv/Initialize(mapload, obj/item/shard/sh)
	. = ..()
	if(sh)
		size = sh.icon_state
	if(!size)
		size = pick("large", "medium", "small")
	update_icon(UPDATE_ICON_STATE)


/obj/item/kitchen/knife/glassshiv/update_icon_state()
	icon_state = "[size]_[initial(icon_state)]"


/obj/item/kitchen/knife/glassshiv/plasma
	name = "plasma glass shiv"
	desc = "Осколок плазменного стекла, обмотанный тряпкой."
	ru_names = list(
		NOMINATIVE = "заточка из плазма-стекла",
		GENITIVE = "заточки из плазма-стекла",
		DATIVE = "заточке из плазма-стекла",
		ACCUSATIVE = "заточку из плазма-стекла",
		INSTRUMENTAL = "заточкой из плазма-стекла",
		PREPOSITIONAL = "заточке из плазма-стекла"
	)
	force = 9
	throwforce = 11
	materials = list(MAT_PLASMA = MINERAL_MATERIAL_AMOUNT * 0.5, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)

/*
 * Rolling Pins
 */

/obj/item/kitchen/rollingpin
	name = "rolling pin"
	desc = "Идеально подходит для того, чтобы вырубить бармена."
	ru_names = list(
		NOMINATIVE = "скалка",
		GENITIVE = "скалки",
		DATIVE = "скалке",
		ACCUSATIVE = "скалку",
		INSTRUMENTAL = "скалкой",
		PREPOSITIONAL = "скалке"
	)
	icon_state = "rolling_pin"
	force = 8.0
	throwforce = 10.0
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("ударил", "огрел")

/* Trays moved to /obj/item/storage/bag */

/*
 * Candy Moulds
 */

/obj/item/kitchen/mould
	name = "generic candy mould"
	desc = "Не совсем понятно, что должно получиться."
	ru_names = list(
		NOMINATIVE = "универсальная форма для конфет",
		GENITIVE = "универсальной формы для конфет",
		DATIVE = "универсальной форме для конфет",
		ACCUSATIVE = "универсальную форму для конфет",
		INSTRUMENTAL = "универсальной формой для конфет",
		PREPOSITIONAL = "универсальной форме для конфет"
	)
	icon_state = "mould"
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 3
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("ударил")

/obj/item/kitchen/mould/bear
	name = "bear-shaped candy mould"
	desc = "Имеет оттиск в форме маленького медведя."
	ru_names = list(
		NOMINATIVE = "форма для конфет \"медвежонок\"",
		GENITIVE = "формы для конфет \"медвежонок\"",
		DATIVE = "форме для конфет \"медвежонок\"",
		ACCUSATIVE = "форму для конфет \"медвежонок\"",
		INSTRUMENTAL = "формой для конфет \"медвежонок\"",
		PREPOSITIONAL = "форме для конфет \"медвежонок\""
	)
	icon_state = "mould_bear"

/obj/item/kitchen/mould/worm
	name = "worm-shaped candy mould"
	desc = "Имеет оттиск в форме червячка."
	ru_names = list(
		NOMINATIVE = "форма для конфет \"червячок\"",
		GENITIVE = "формы для конфет \"червячок\"",
		DATIVE = "форме для конфет \"червячок\"",
		ACCUSATIVE = "форму для конфет \"червячок\"",
		INSTRUMENTAL = "формой для конфет \"червячок\"",
		PREPOSITIONAL = "форме для конфет \"червячок\""
	)
	icon_state = "mould_worm"

/obj/item/kitchen/mould/bean
	name = "bean-shaped candy mould"
	desc = "Имеет оттиск в форме боба."
	ru_names = list(
		NOMINATIVE = "форма для конфет \"боб\"",
		GENITIVE = "формы для конфет \"боб\"",
		DATIVE = "форме для конфет \"боб\"",
		ACCUSATIVE = "форму для конфет \"боб\"",
		INSTRUMENTAL = "формой для конфет \"боб\"",
		PREPOSITIONAL = "форме для конфет \"боб\""
	)
	icon_state = "mould_bean"

/obj/item/kitchen/mould/ball
	name = "ball-shaped candy mould"
	desc = "Имеет оттиск в форме маленькой сферы."
	ru_names = list(
		NOMINATIVE = "форма для конфет \"шарик\"",
		GENITIVE = "формы для конфет \"шарик\"",
		DATIVE = "форме для конфет \"шарик\"",
		ACCUSATIVE = "форму для конфет \"шарик\"",
		INSTRUMENTAL = "формой для конфет \"шарик\"",
		PREPOSITIONAL = "форме для конфет \"шарик\""
	)
	icon_state = "mould_ball"

/obj/item/kitchen/mould/cane
	name = "cane-shaped candy mould"
	desc = "Имеет оттиск в форме трости."
	ru_names = list(
		NOMINATIVE = "форма для конфет \"трость\"",
		GENITIVE = "формы для конфет \"трость\"",
		DATIVE = "форме для конфет \"трость\"",
		ACCUSATIVE = "форму для конфет \"трость\"",
		INSTRUMENTAL = "формой для конфет \"трость\"",
		PREPOSITIONAL = "форме для конфет \"трость\""
	)
	icon_state = "mould_cane"

/obj/item/kitchen/mould/cash
	name = "cash-shaped candy mould"
	desc = "Имеет оттиск в форме и дизайне фальшивых купюр."
	ru_names = list(
		NOMINATIVE = "форма для конфет \"деньги\"",
		GENITIVE = "формы для конфет \"деньги\"",
		DATIVE = "форме для конфет \"деньги\"",
		ACCUSATIVE = "форму для конфет \"деньги\"",
		INSTRUMENTAL = "формой для конфет \"деньги\"",
		PREPOSITIONAL = "форме для конфет \"деньги\""
	)
	icon_state = "mould_cash"

/obj/item/kitchen/mould/coin
	name = "coin-shaped candy mould"
	desc = "Имеет оттиск в форме монеты."
	ru_names = list(
		NOMINATIVE = "форма для конфет \"монета\"",
		GENITIVE = "формы для конфет \"монета\"",
		DATIVE = "форме для конфет \"монета\"",
		ACCUSATIVE = "форму для конфет \"монета\"",
		INSTRUMENTAL = "формой для конфет \"монета\"",
		PREPOSITIONAL = "форме для конфет \"монета\""
	)
	icon_state = "mould_coin"

/obj/item/kitchen/mould/loli
	name = "sucker mould"
	desc = "Имеет оттиск в форме леденца на палочке."
	ru_names = list(
		NOMINATIVE = "форма для леденцов",
		GENITIVE = "формы для леденцов",
		DATIVE = "форме для леденцов",
		ACCUSATIVE = "форму для леденцов",
		INSTRUMENTAL = "формой для леденцов",
		PREPOSITIONAL = "форме для леденцов"
	)
	icon_state = "mould_loli"

/*
 * Sushi Mat
 */
/obj/item/kitchen/sushimat
	name = "Sushi Mat"
	desc = "Бамбуковый коврик для эффективного приготовления суши."
	ru_names = list(
		NOMINATIVE = "циновка для суши",
		GENITIVE = "циновки для суши",
		DATIVE = "циновке для суши",
		ACCUSATIVE = "циновку для суши",
		INSTRUMENTAL = "циновкой для суши",
		PREPOSITIONAL = "циновке для суши"
	)
	icon_state = "sushi_mat"
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 3
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("закатил", "треснул")



/// circular cutter by Ume

/obj/item/kitchen/cutter
	name = "generic circular cutter"
	desc = "Универсальный круглый резак для печенья и других вещей."
	ru_names = list(
		NOMINATIVE = "универсальный круглый резак",
		GENITIVE = "универсального круглого резака",
		DATIVE = "универсальному круглому резаку",
		ACCUSATIVE = "универсальный круглый резак",
		INSTRUMENTAL = "универсальным круглым резаком",
		PREPOSITIONAL = "универсальном круглом резаке"
	)
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "circular_cutter"
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 3
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("ударил", "полоснул", "уколол")
