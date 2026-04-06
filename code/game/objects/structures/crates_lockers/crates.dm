// MARK: Basic crate
/obj/structure/closet/crate
	name = "crate"
	desc = "Прямоугольный стальной ящик."
	icon = 'icons/obj/crates.dmi'
	icon_state = "crate"
	climbable = TRUE
	open_sound = 'sound/machines/crate_open.ogg'
	close_sound = 'sound/machines/crate_close.ogg'
	pass_flags_self = PASSSTRUCTURE|LETPASSTHROW
	var/rigged = FALSE
	var/obj/item/paper/manifest/manifest
	// A list of beacon names that the crate will announce the arrival of, when delivered.
	var/list/announce_beacons = list()
	/// Overlay for lightmask of our crate
	var/overlay_lightmask
	/// Can our crate make emissive light?
	var/can_be_emissive = FALSE

/obj/structure/closet/crate/get_ru_names()
    return list(
        NOMINATIVE = "ящик",
        GENITIVE = "ящика",
        DATIVE = "ящику",
        ACCUSATIVE = "ящик",
        INSTRUMENTAL = "ящиком",
        PREPOSITIONAL = "ящике",
    )

/obj/structure/closet/crate/update_icon_state()
	icon_state = "[initial(icon_state)][opened ? "_open" : ""]"

/obj/structure/closet/crate/update_overlays()
	// . = ..() is not needed here because of different overlay handling logic for crates
	underlays.Cut()
	. = list()
	if(manifest)
		. += "manifest"
	if(can_be_emissive)
		underlays += emissive_appearance(icon, overlay_lightmask, src)

/obj/structure/closet/crate/can_open()
	return TRUE

/obj/structure/closet/crate/can_close()
	return TRUE

/obj/structure/closet/crate/open(by_hand = FALSE)
	if(opened || !can_open())
		return FALSE

	if(by_hand)
		for(var/obj/O in src)
			if(O.density)
				var/response = tgui_alert(usr, "Этот ящик упакован очень плотно, ни один предмет из него не поместится обратно. Вы уверены, что хотите его открыть?", "Предупреждение о сжатых материалах", list("Да", "Нет"))
				if(response != "Да" || !Adjacent(usr))
					return FALSE
				break

	if(rigged && locate(/obj/item/radio/electropack) in src)
		if(isliving(usr))
			var/mob/living/L = usr
			if(L.electrocute_act(17, src))
				do_sparks(5, TRUE, src)
				return 2

	playsound(loc, open_sound, open_sound_volume, TRUE, -3)
	for(var/obj/O in src) //Objects
		O.forceMove(loc)
	for(var/mob/M in src) //Mobs
		M.forceMove(loc)

	opened = TRUE
	update_icon()

	if(climbable)
		structure_shaken()

	return TRUE

/obj/structure/closet/crate/close()
	if(!opened || !can_close())
		return FALSE

	playsound(loc, close_sound, close_sound_volume, TRUE, -3)
	var/itemcount = 0
	for(var/atom/movable/O in get_turf(src))
		if(itemcount >= storage_capacity)
			break
		if(O.density || O.anchored || iscloset(O) || isobserver(O) || O.has_buckled_mobs())
			continue
		O.forceMove(src)
		itemcount++

	opened = FALSE
	update_icon()
	return TRUE

/obj/structure/closet/crate/attackby(obj/item/I, mob/user, params)
	if(!opened && try_rig(I, user))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/structure/closet/crate/proc/try_rig(obj/item/W, mob/user)
	if(iscoil(W))
		var/obj/item/stack/cable_coil/C = W
		if(rigged)
			to_chat(user, span_notice("[src] is already rigged!"))
			return TRUE
		if(C.use(15))
			to_chat(user, span_notice("You rig [src]."))
			rigged = TRUE
		else
			to_chat(user, span_warning("You need atleast 15 wires to rig [src]!"))
		return TRUE
	if(istype(W, /obj/item/radio/electropack))
		if(rigged)
			if(!user.drop_transfer_item_to_loc(W, src))
				to_chat(user, span_warning("[W] seems to be stuck to your hand!"))
				return TRUE
			to_chat(user, span_notice("You attach [W] to [src]."))
		return TRUE

/obj/structure/closet/crate/wirecutter_act(mob/living/user, obj/item/I)
	if(opened)
		return
	if(!rigged)
		return

	if(I.use_tool(src, user))
		to_chat(user, span_notice("Вы обрезали проводку."))
		playsound(loc, I.usesound, 100, TRUE)
		rigged = FALSE
		return TRUE

/obj/structure/closet/crate/welder_act()
	return

/// Removes the supply manifest from the closet
/obj/structure/closet/crate/proc/tear_manifest(mob/user)
	add_fingerprint(user)
	to_chat(user, span_notice("You tear the manifest off of [src]."))
	playsound(loc, 'sound/items/poster_ripped.ogg', 75, TRUE)
	manifest.forceMove_turf(drop_location(src))
	if(ishuman(user))
		user.put_in_hands(manifest, ignore_anim = FALSE)
	manifest = null
	update_appearance()

/obj/structure/closet/crate/attack_hand(mob/user)
	if(manifest)
		tear_manifest(user)
	else
		var/obj/item/radio/electropack = locate() in src
		if(rigged && electropack)
			if(isliving(user))
				var/mob/living/L = user
				if(L.electrocute_act(17, electropack))
					do_sparks(5, TRUE, src)
					return
		add_fingerprint(user)
		toggle(user, by_hand = TRUE)

// Called when a crate is delivered by MULE at a location, for notifying purposes
/obj/structure/closet/crate/proc/notifyRecipient(destination)
	var/msg = "[capitalize(name)] has arrived at [destination]."
	if(destination in announce_beacons)
		for(var/obj/machinery/requests_console/D in GLOB.allRequestConsoles)
			if(D.department in src.announce_beacons[destination])
				D.createMessage(name, "Your Crate has Arrived!", msg, 1)

// MARK: Specific crates

/obj/structure/closet/crate/plastic
	name = "plastic crate"
	desc = "Прямоугольный пластиковый ящик."
	icon_state = "plasticcrate"

/obj/structure/closet/crate/plastic/get_ru_names()
    return list(
        NOMINATIVE = "пластиковый ящик",
        GENITIVE = "пластикового ящика",
        DATIVE = "пластиковому ящику",
        ACCUSATIVE = "пластиковый ящик",
        INSTRUMENTAL = "пластиковым ящиком",
        PREPOSITIONAL = "пластиковом ящике",
    )


/obj/structure/closet/crate/internals
	desc = "Ящик для хранения респираторов и кислородных баллонов."
	name = "internals crate"
	icon_state = "o2crate"

/obj/structure/closet/crate/internals/get_ru_names()
    return list(
        NOMINATIVE = "ящик для респираторов и кислородных баллонов",
        GENITIVE = "ящика для респираторов и кислородных баллонов",
        DATIVE = "ящику для респираторов и кислородных баллонов",
        ACCUSATIVE = "ящик для респираторов и кислородных баллонов",
        INSTRUMENTAL = "ящиком для респираторов и кислородных баллонов",
        PREPOSITIONAL = "ящике для респираторов и кислородных баллонов",
    )

/obj/structure/closet/crate/trashcart
	desc = "Тяжелый металлический мусорный контейнер на колесах."
	name = "trash Cart"
	icon_state = "trashcart"

/obj/structure/closet/crate/trashcart/get_ru_names()
    return list(
        NOMINATIVE = "мусорный контейнер",
        GENITIVE = "мусорного контейнера",
        DATIVE = "мусорному контейнеру",
        ACCUSATIVE = "мусорный контейнер",
        INSTRUMENTAL = "мусорным контейнером",
        PREPOSITIONAL = "мусорном контейнере",
    )

/obj/structure/closet/crate/trashcart/NTdelivery
	name = "Special Delivery from Central Command"

/obj/structure/closet/crate/trashcart/NTdelivery/get_ru_names()
    return list(
        NOMINATIVE = "спецдоставка от Центрального Командования.",
        GENITIVE = "спецдоставки от Центрального Командования.",
        DATIVE = "спецдоставке от Центрального Командования",
        ACCUSATIVE = "спецдоставку от Центрального Командования",
        INSTRUMENTAL = "спецдоставкой от Центрального Командования",
        PREPOSITIONAL = "спецдоставке от Центрального Командования",
    )

/obj/structure/closet/crate/trashcart/gibs
	desc = "Тяжелый металлический мусорный контейнер на колесах. Лучше не спрашивай."
	name = "trash cart with gibs"
	icon_state = "trashcartgib"

/obj/structure/closet/crate/trashcart/gibs/get_ru_names()
    return list(
        NOMINATIVE = "мусорный контейнер с ошмётками",
        GENITIVE = "мусорного контейнера с ошмётками",
        DATIVE = "мусорному контейнеру с ошмётками",
        ACCUSATIVE = "мусорный контейнер с ошмётками",
        INSTRUMENTAL = "мусорным контейнером с ошмётками",
        PREPOSITIONAL = "мусорном контейнере с ошмётками",
    )

/obj/structure/closet/crate/medical
	desc = "Медицинский ящик."
	name = "medical crate"
	icon_state = "medicalcrate"

/obj/structure/closet/crate/medical/get_ru_names()
    return list(
        NOMINATIVE = "медицинский ящик",
        GENITIVE = "медицинского ящика",
        DATIVE = "медицинскому ящику",
        ACCUSATIVE = "медицинский ящик",
        INSTRUMENTAL = "медицинским ящиком",
        PREPOSITIONAL = "медицинском ящике",
    )

/obj/structure/closet/crate/rcd
	desc = "Ящик для хранения УБС."
	name = "RCD crate"

/obj/structure/closet/crate/rcd/get_ru_names()
    return list(
        NOMINATIVE = "ящик для УБС",
        GENITIVE = "ящика для УБС",
        DATIVE = "ящику для УБС",
        ACCUSATIVE = "ящик для УБС",
        INSTRUMENTAL = "ящиком для УБС",
        PREPOSITIONAL = "ящике для УБС",
    )

/obj/structure/closet/crate/rcd/populate_contents()
	new /obj/item/rcd_ammo(src)
	new /obj/item/rcd_ammo(src)
	new /obj/item/rcd_ammo(src)
	new /obj/item/rcd(src)

/obj/structure/closet/crate/freezer
	desc = "Морозильная камера."
	name = "Freezer"
	icon_state = "freezer"
	var/target_temp = T0C - 40
	var/cooling_power = 40

/obj/structure/closet/crate/freezer/get_ru_names()
    return list(
        NOMINATIVE = "морозильная камера",
        GENITIVE = "морозильной камере",
        DATIVE = "морозильной камере",
        ACCUSATIVE = "морозильную камеру",
        INSTRUMENTAL = "морозильной камерой",
        PREPOSITIONAL = "морозильной камере",
    )

/obj/structure/closet/crate/freezer/return_obj_air()
	RETURN_TYPE(/datum/gas_mixture)
	var/datum/gas_mixture/gas = ..()
	if(!gas)
		var/turf/location = get_turf(src)
		gas = location.get_readonly_air()
	var/datum/gas_mixture/newgas = new/datum/gas_mixture()
	newgas.set_oxygen(gas.oxygen())
	newgas.set_carbon_dioxide(gas.carbon_dioxide())
	newgas.set_nitrogen(gas.nitrogen())
	newgas.set_toxins(gas.toxins())
	newgas.volume = gas.volume
	newgas.set_temperature(gas.temperature())
	if(newgas.temperature() <= target_temp)
		return

	if((newgas.temperature() - cooling_power) > target_temp)
		newgas.set_temperature(newgas.temperature() - cooling_power)
	else
		newgas.set_temperature(target_temp)
	return newgas

/obj/structure/closet/crate/can
	desc = "Большая банка... Кажется, это мусорное ведро."
	name = "garbage can"
	icon_state = "largebin"
	anchored = TRUE

/obj/structure/closet/crate/can/get_ru_names()
    return list(
        NOMINATIVE = "мусорное ведро",
        GENITIVE = "мусорного ведра",
        DATIVE = "мусорному ведру",
        ACCUSATIVE = "мусорное ведро",
        INSTRUMENTAL = "мусорным ведром",
        PREPOSITIONAL = "мусорном ведре",
    )

/obj/structure/closet/crate/can/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_unfasten_wrench(user, I, 40)

/obj/structure/closet/crate/radiation
	desc = "Ящик со знаком радиации."
	name = "radioactive gear crate"
	icon_state = "radiation"

/obj/structure/closet/crate/radiation/get_ru_names()
    return list(
        NOMINATIVE = "ящик для радзащитного снаряжения",
        GENITIVE = "ящика для радзащитного снаряжения",
        DATIVE = "ящику для радзащитного снаряжения",
        ACCUSATIVE = "ящик для радзащитного снаряжения",
        INSTRUMENTAL = "ящиком для радзащитного снаряжения",
        PREPOSITIONAL = "ящике для радзащитного снаряжения",
    )

/obj/structure/closet/crate/radiation/populate_contents()
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)

/obj/structure/closet/crate/vault
	desc = "Ящик для ценностей."
	name = "vault crate"
	icon_state = "vaultcrate"

/obj/structure/closet/crate/vault/get_ru_names()
	return list(
		NOMINATIVE = "ящик для ценностей",
		GENITIVE = "ящика для ценностей",
		DATIVE = "ящику для ценностей",
		ACCUSATIVE = "ящик для ценностей",
		INSTRUMENTAL = "ящиком для ценностей",
		PREPOSITIONAL = "ящике для ценностей",
	)

/obj/structure/closet/crate/wooden //i'm sure hope this won't be used as cheese strat to obtain cargo points
	name = "wooden crate"
	desc = "Ящик, сделанный из дерева."
	icon_state = "wooden_crate"

/obj/structure/closet/crate/wooden/get_ru_names()
	return list(
		NOMINATIVE = "деревянный ящик",
		GENITIVE = "деревянного ящика",
		DATIVE = "деревянному ящику",
		ACCUSATIVE = "деревянный ящик",
		INSTRUMENTAL = "деревянным ящиком",
		PREPOSITIONAL = "деревянном ящике",
	)

/obj/structure/closet/crate/hydroponics
	name = "hydroponics crate"
	desc = "Всё, что вам нужно, чтобы уничтожить эти надоедливые сорняки и вредителей."
	icon_state = "hydrocrate"

/obj/structure/closet/crate/hydroponics/get_ru_names()
	return list(
		NOMINATIVE = "ботанический ящик",
		GENITIVE = "ботанического ящика",
		DATIVE = "ботаническому ящику",
		ACCUSATIVE = "ботанический ящик",
		INSTRUMENTAL = "ботаническим ящиком",
		PREPOSITIONAL = "ботаническом ящике",
	)

/obj/structure/closet/crate/hydroponics/prespawned
	//This exists so the prespawned hydro crates spawn with their contents.

// Do I need the definition above? Who knows!
/obj/structure/closet/crate/hydroponics/prespawned/populate_contents()
	new /obj/item/reagent_containers/glass/bucket(src)
	new /obj/item/reagent_containers/glass/bucket(src)
	new /obj/item/screwdriver(src)
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/wrench(src)
	new /obj/item/wirecutters(src)
	new /obj/item/wirecutters(src)
	new /obj/item/shovel/spade(src)
	new /obj/item/shovel/spade(src)
	new /obj/item/storage/box/beakers(src)
	new /obj/item/storage/box/beakers(src)
	new /obj/item/hand_labeler(src)
	new /obj/item/hand_labeler(src)

/obj/structure/closet/crate/sci
	name = "science crate"
	desc = "A science crate."
	icon_state = "scicrate"

/obj/structure/closet/crate/sci/get_ru_names()
    return list(
        NOMINATIVE = "исследовательский ящик",
        GENITIVE = "исследовательского ящика",
        DATIVE = "исследовательскому ящику",
        ACCUSATIVE = "исследовательский ящик",
        INSTRUMENTAL = "исследовательским ящиком",
        PREPOSITIONAL = "исследовательском ящике",
    )

/obj/structure/closet/crate/engineering/electrical
	name = "electrical engineering crate"
	desc = "An electrical engineering crate."
	icon_state = "electricalcrate"

/obj/structure/closet/crate/engineering/electrical/get_ru_names()
    return list(
        NOMINATIVE = "инженерный ящик для электроники",
        GENITIVE = "инженерного ящика для электроники",
        DATIVE = "инженерному ящику для электроники",
        ACCUSATIVE = "инженерный ящик для электроники",
        INSTRUMENTAL = "инженерным ящиком для электроники",
        PREPOSITIONAL = "инженерном ящике для электроники",
    )

/obj/structure/closet/crate/tape/populate_contents()
	if(prob(10))
		new /obj/item/bikehorn/rubberducky(src)

//crates of gear in the free golem ship
/obj/structure/closet/crate/golemgear/populate_contents()
	new /obj/item/storage/backpack/industrial(src)
	new /obj/item/shovel(src)
	new /obj/item/pickaxe(src)
	new /obj/item/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/storage/bag/ore(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/card/id/golem(src)
	new /obj/item/flashlight/lantern(src)

//syndie crates by Furukai
/obj/structure/closet/crate/syndicate
	desc = "Несомненно, это собственность злой корпорации!"
	icon_state = "syndiecrate"
	material_drop = /obj/item/stack/sheet/mineral/plastitanium
