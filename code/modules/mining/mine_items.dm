/**********************Light************************/

//this item is intended to give the effect of entering the mine, so that light gradually fades
/obj/effect/light_emitter
	name = "Light emitter"
	icon_state = "at_shield1"
	anchored = TRUE
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/light_emitter/Initialize(mapload)
	. = ..()
	icon_state = null

/obj/effect/light_emitter/singularity_pull()
	return

/obj/effect/light_emitter/singularity_act()
	return

/**********************Miner Lockers**************************/

/obj/structure/closet/wardrobe/miner
	name = "mining wardrobe"
	icon_state = "mine_ward"

/obj/structure/closet/wardrobe/miner/populate_contents()
	new /obj/item/storage/backpack/duffel(src)
	new /obj/item/storage/backpack/explorer(src)
	new /obj/item/storage/backpack/satchel_explorer(src)
	new /obj/item/clothing/under/rank/miner/lavaland(src)
	new /obj/item/clothing/under/rank/miner/lavaland(src)
	new /obj/item/clothing/under/rank/miner/lavaland(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/gloves/color/black(src)

/obj/structure/closet/secure_closet/miner
	name = "miner's equipment"
	icon_state = "mining"
	req_access = list(ACCESS_MINING)

/obj/structure/closet/secure_closet/miner/populate_contents()
	new /obj/item/stack/sheet/mineral/sandbags(src, 5)
	new /obj/item/storage/box/emptysandbags(src)
	new /obj/item/shovel(src)
	new /obj/item/pickaxe/mini(src)
	new /obj/item/radio/headset/headset_cargo/mining(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/storage/bag/plants(src)
	new /obj/item/storage/bag/gem(src)
	new /obj/item/storage/bag/ore(src)
	new /obj/item/mining_scanner(src)
	new /obj/item/gun/energy/kinetic_accelerator(src)
	new /obj/item/clothing/glasses/meson(src)

/**********************Shuttle Computer**************************/

/obj/machinery/computer/shuttle/mining
	name = "Mining Shuttle Console"
	desc = "Используется для вызова и отправки шахтёрского шаттла."
	circuit = /obj/item/circuitboard/mining_shuttle
	shuttleId = "mining"
	possible_destinations = "mining_home;mining_away"
	lockdown_affected = TRUE

/******************************Lantern*******************************/

/obj/item/flashlight/lantern
	name = "lantern"
	desc = "Шахтёрская лампа."
	ru_names = list(
		NOMINATIVE = "лампа",
		GENITIVE = "лампы",
		DATIVE = "лампе",
		ACCUSATIVE = "лампу",
		INSTRUMENTAL = "лампой",
		PREPOSITIONAL = "лампе"
	)
	gender = FEMALE
	icon_state = "lantern"
	item_state = "lantern"
	belt_icon = "lantern"
	light_range = 6		// luminosity when on
	light_color = LIGHT_COLOR_YELLOW
	light_system = MOVABLE_LIGHT
	var/obj/item/gem/inserted_gem = null
	var/mutable_appearance/lantern_light_overlay

/obj/item/flashlight/lantern/Initialize(mapload)
	. = ..()
	lantern_light_overlay = mutable_appearance('icons/obj/lighting.dmi',"lantern_light", color = light_color)

/obj/item/flashlight/lantern/examine(mob/user)
	. = ..()
	if(!inserted_gem)
		. += span_notice("Внутри лампы есть небольшое отверстие под самоцвет.")
	else
		. += span_notice("Внутри лампы находится [inserted_gem.declent_ru(NOMINATIVE)]. Его можно извлечь с помощью лома.")

/obj/item/flashlight/lantern/update_icon_state()
	cut_overlay(lantern_light_overlay)
	if(on)
		add_overlay(lantern_light_overlay)

/obj/item/flashlight/lantern/crowbar_act(mob/living/user, obj/item/I)
	if(on)
		balloon_alert(user, "лампа включена!")
		return
	if(!inserted_gem)
		balloon_alert(user, "самоцвет отсутствует!")
		return
	to_chat(user, span_notice("Вы осторожно вынимаете [inserted_gem.declent_ru(ACCUSATIVE)] из лампы."))
	inserted_gem.set_light_on(TRUE)
	inserted_gem.forceMove(get_turf(user))
	inserted_gem = null
	refresh_lantern_lights()
	return TRUE

/obj/item/flashlight/lantern/proc/refresh_lantern_lights()
	if(on)
		on = !on
	cut_overlay(lantern_light_overlay)
	if(!inserted_gem)
		set_light_color(LIGHT_COLOR_YELLOW)
		lantern_light_overlay = mutable_appearance('icons/obj/lighting.dmi',"lantern_light", color = light_color)
	else
		set_light_color(inserted_gem.light_color)
		lantern_light_overlay = mutable_appearance('icons/obj/lighting.dmi',"lantern_light", color = light_color)

/obj/item/flashlight/lantern/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !istype(I, /obj/item/gem))
		return .

	if(on)
		balloon_alert(user, "лампа включена!")
		return .

	add_fingerprint(user)
	var/obj/item/gem/new_gem = I
	if(inserted_gem)
		balloon_alert(user, "уже вставлено!")
		return .
	if(!user.drop_transfer_item_to_loc(new_gem, src))
		return .
	. |= ATTACK_CHAIN_BLOCKED_ALL
	to_chat(user, span_notice("вы осторожно устанавливаете [new_gem.declent_ru(NOMINATIVE)] в лампу."))
	inserted_gem = new_gem
	inserted_gem.set_light_on(FALSE)
	refresh_lantern_lights()

/**********************Mining car (Crate like thing, not the rail car)**************************/

/obj/structure/closet/crate/miningcar
	name = "mining car"
	desc = "Шахтёрская вагонетка. К сожалению, рельсов на Лазисе нет. Зато её можно тащить."
	ru_names = list(
		NOMINATIVE = "вагонетка",
		GENITIVE = "вагонетки",
		DATIVE = "вагонетке",
		ACCUSATIVE = "вагонетку",
		INSTRUMENTAL = "вагонеткой",
		PREPOSITIONAL = "вагонетке"
	)
	gender = FEMALE
	icon_state = "miningcar"
