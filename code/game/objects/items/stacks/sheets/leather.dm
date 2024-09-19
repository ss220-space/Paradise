/obj/item/stack/sheet/animalhide
	name = "hide"
	desc = "Something went wrong."
	origin_tech = "biotech=3"

/obj/item/stack/sheet/animalhide/human
	name = "human skin"
	desc = "The by-product of human farming."
	singular_name = "human skin piece"
	icon_state = "sheet-hide"

GLOBAL_LIST_INIT(human_recipes, list( \
	new/datum/stack_recipe("bloated human costume", /obj/item/clothing/suit/bloated_human, 5, on_floor = TRUE), \
	new/datum/stack_recipe("bloated human costume head", /obj/item/clothing/head/human_head, 5, on_floor = TRUE), \
	))

/obj/item/stack/sheet/animalhide/human/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.human_recipes

/obj/item/stack/sheet/animalhide/generic
	name = "generic skin"
	desc = "A piece of generic skin."
	singular_name = "generic skin piece"
	icon_state = "sheet-hide"

/obj/item/stack/sheet/animalhide/corgi
	name = "corgi hide"
	desc = "The by-product of corgi farming."
	singular_name = "corgi hide piece"
	icon_state = "sheet-corgi"

/obj/item/stack/sheet/animalhide/cat
	name = "cat hide"
	desc = "The by-product of cat farming."
	singular_name = "cat hide piece"
	icon_state = "sheet-cat"

/obj/item/stack/sheet/animalhide/monkey
	name = "monkey hide"
	desc = "The by-product of monkey farming."
	singular_name = "monkey hide piece"
	icon_state = "sheet-monkey"

/obj/item/stack/sheet/animalhide/wolpin
	name = "wolpin hide"
	desc = "The by-product of wolpin farming."
	singular_name = "wolpin hide piece"
	icon_state = "sheet-wolpin"

/obj/item/stack/sheet/animalhide/stok
	name = "stok hide"
	desc = "The by-product of stok farming."
	singular_name = "stok hide piece"
	icon_state = "sheet-lizzard"

/obj/item/stack/sheet/animalhide/neara
	name = "neara hide"
	desc = "The by-product of neara farming."
	singular_name = "neara hide piece"
	icon_state = "sheet-neara"

/obj/item/stack/sheet/animalhide/farwa
	name = "farwa hide"
	desc = "The by-product of farwa farming."
	singular_name = "farwa hide piece"
	icon_state = "sheet-farwa"

/obj/item/stack/sheet/animalhide/lizard
	name = "lizard skin"
	desc = "Sssssss..."
	singular_name = "lizard skin piece"
	icon_state = "sheet-lizard"

GLOBAL_LIST_INIT(lizard_recipes, list(new/datum/stack_recipe("lizard skin handbag", /obj/item/storage/backpack/satchel_lizard, 5, on_floor = TRUE), new/datum/stack_recipe("lizard skin backpack",  /obj/item/storage/backpack/lizard, 5, on_floor = TRUE)))

/obj/item/stack/sheet/animalhide/lizard/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.lizard_recipes

/obj/item/stack/sheet/animalhide/xeno
	name = "alien hide"
	desc = "The skin of a terrible creature."
	singular_name = "alien hide piece"
	icon_state = "sheet-xeno"

GLOBAL_LIST_INIT(xeno_recipes, list (
	new/datum/stack_recipe("alien helmet", /obj/item/clothing/head/xenos, 1),
	new/datum/stack_recipe("alien suit", /obj/item/clothing/suit/xenos, 2)))

/obj/item/stack/sheet/animalhide/xeno/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.xeno_recipes

//don't see anywhere else to put these, maybe together they could be used to make the xenos suit?
/obj/item/stack/sheet/xenochitin
	name = "alien chitin"
	desc = "A piece of the hide of a terrible creature."
	singular_name = "alien hide piece"
	icon = 'icons/mob/alien.dmi'
	icon_state = "chitin"
	origin_tech = ""

/obj/item/xenos_claw
	name = "alien claw"
	desc = "The claw of a terrible creature."
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"
	origin_tech = ""

/obj/item/weed_extract
	name = "weed extract"
	desc = "A piece of slimy, purplish weed."
	icon = 'icons/mob/alien.dmi'
	icon_state = "weed_extract"
	origin_tech = ""

/obj/item/stack/sheet/hairlesshide
	name = "hairless hide"
	desc = "This hide was stripped of it's hair, but still needs tanning."
	singular_name = "hairless hide piece"
	icon_state = "sheet-hairlesshide"
	origin_tech = ""

/obj/item/stack/sheet/wetleather
	name = "wet leather"
	desc = "This leather has been cleaned but still needs to be dried."
	singular_name = "wet leather piece"
	icon_state = "sheet-wetleather"
	origin_tech = ""
	var/wetness = 30 //Reduced when exposed to high temperautres
	var/drying_threshold_temperature = 500 //Kelvin to start drying

/obj/item/stack/sheet/leather
	name = "leather"
	desc = "The by-product of mob grinding."
	singular_name = "leather piece"
	icon_state = "sheet-leather"
	origin_tech = "materials=2"

GLOBAL_LIST_INIT(leather_recipes, list (
	new/datum/stack_recipe("wallet", /obj/item/storage/wallet, 1),
	new/datum/stack_recipe("muzzle", /obj/item/clothing/mask/muzzle, 2),
	new/datum/stack_recipe("botany gloves", /obj/item/clothing/gloves/botanic_leather, 3),
	new/datum/stack_recipe("toolbelt", /obj/item/storage/belt/utility, 4),
	new/datum/stack_recipe("leather satchel", /obj/item/storage/backpack/satchel, 5),
	new/datum/stack_recipe("bandolier", /obj/item/storage/belt/bandolier, 5),
	new/datum/stack_recipe("leather jacket", /obj/item/clothing/suit/jacket/leather, 7),
	new/datum/stack_recipe("leather shoes", /obj/item/clothing/shoes/leather, 2),
	new/datum/stack_recipe("leather overcoat", /obj/item/clothing/suit/jacket/leather/overcoat, 10),
	new/datum/stack_recipe("FireSuit", /obj/item/clothing/suit/fire/firefighter, 15),
	new/datum/stack_recipe("hide mantle", /obj/item/clothing/neck/mantle/unathi, 4),
	new/datum/stack_recipe("gem satchel", /obj/item/storage/bag/gem, 1)))

/obj/item/stack/sheet/leather/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.leather_recipes

/obj/item/stack/sheet/sinew
	name = "watcher sinew"
	icon = 'icons/obj/mining.dmi'
	desc = "Long stringy filaments which presumably came from a watcher's wings."
	singular_name = "watcher sinew"
	icon_state = "sinew"
	origin_tech = "biotech=4"

GLOBAL_LIST_INIT(sinew_recipes, list ( \
	new/datum/stack_recipe("sinew restraints", /obj/item/restraints/handcuffs/sinew, 1, on_floor = 1), \
	))

/obj/item/stack/sheet/sinew/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.sinew_recipes

/obj/item/stack/sheet/animalhide/goliath_hide
	name = "goliath hide plates"
	desc = "Pieces of a goliath's rocky hide, these might be able to make your suit a bit more durable to attack from the local fauna."
	icon = 'icons/obj/mining.dmi'
	icon_state = "goliath_hide"
	singular_name = "hide plate"
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_NORMAL
	layer = MOB_LAYER
	var/static/list/goliath_platable_armor_typecache = typecacheof(list(
			/obj/item/clothing/suit/hooded/pathfinder,
			/obj/item/clothing/head/hooded/pathfinder,
	))
	var/static/list/goliath_platable_armor_with_icon_typecache = typecacheof(list(
			/obj/item/clothing/suit/space/hardsuit/mining,
			/obj/item/clothing/head/helmet/space/hardsuit/mining,
			/obj/item/clothing/suit/hooded/explorer,
			/obj/item/clothing/head/hooded/explorer,
			/obj/item/clothing/head/helmet/space/plasmaman/mining,
	))

/obj/item/stack/sheet/animalhide/goliath_hide/afterattack(atom/target, mob/user, proximity_flag, params)
	if(!proximity_flag)
		return
	var/platable_armor_with_icon = is_type_in_typecache(target, goliath_platable_armor_with_icon_typecache)
	if(is_type_in_typecache(target, goliath_platable_armor_typecache) || platable_armor_with_icon)
		var/obj/item/clothing/C = target
		var/datum/armor/current_armor = C.armor
		if(current_armor.getRating(MELEE) < 60)
			C.armor = current_armor.setRating(melee_value = min(current_armor.getRating(MELEE) + 10, 60))
			if(platable_armor_with_icon)
				switch(C.armor.getRating(MELEE))
					if(40, 50)
						C.icon_state = "[initial(C.icon_state)]_reinf"
						C.item_color = "[initial(C.item_color)]_reinf"
					if(60)
						C.icon_state = "[initial(C.icon_state)]_reinf_full"
						C.item_color = "[initial(C.item_color)]_reinf_full"

				if(ishuman(C.loc))
					var/mob/living/carbon/human/H = C.loc
					H.update_inv_head()
					H.update_inv_wear_suit()

			to_chat(user, "<span class='info'>You strengthen [target], improving its resistance against melee attacks.</span>")
			use(1)
		else
			to_chat(user, "<span class='warning'>You can't improve [C] any further!</span>")

	else if(istype(target, /obj/mecha/working/ripley))
		var/obj/mecha/working/ripley/D = target
		if(D.hides < 3)
			D.hides++
			D.armor = D.armor.setRating(melee_value = min(D.armor.getRating(MELEE) + 10, 70))
			D.armor = D.armor.setRating(bullet_value = min(D.armor.getRating(BULLET) + 5, 50))
			D.armor = D.armor.setRating(laser_value = min(D.armor.getRating(LASER) + 5, 50))
			to_chat(user, "<span class='info'>You strengthen [target], improving its resistance against melee attacks.</span>")
			D.update_appearance(UPDATE_DESC|UPDATE_OVERLAYS)
			use(1)
		else
			to_chat(user, "<span class='warning'>You can't improve [D] any further!</span>")

/obj/item/stack/sheet/armour_plate
	name = "укрепленная броневая плита" // тут по причине того же механа что и шкура голиафа
	desc = "Сделанный на коленке из плит брони для мехов, этот кусок металла можно налепить на сам мех, усиливая его защитные характеристики. К сожалению, выемки под такую броню есть только у мехов рабочего класса."
	icon = 'icons/obj/mining.dmi'
	icon_state = "armour_plate"
	singular_name = "armour plate"
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_NORMAL
	layer = MOB_LAYER

/obj/item/stack/sheet/armour_plate/afterattack(atom/target, mob/user, proximity_flag, params)
	if(!proximity_flag)
		return
	if(istype(target, /obj/mecha/working/ripley))
		var/obj/mecha/working/ripley/D = target
		if(D.plates < 3)
			D.plates++
			D.armor = D.armor.setRating(melee_value = min(D.armor.getRating("melee") + 10, 70))
			D.armor = D.armor.setRating(bullet_value = min(D.armor.getRating("bullet") + 5, 50))
			D.armor = D.armor.setRating(laser_value = min(D.armor.getRating("laser") + 5, 50))
			to_chat(user, "<span class='info'>Вы нашли куда суется [name] и пихнули её на экзокостюм, усиливая защиту против атак.</span>")
			D.update_appearance(UPDATE_DESC|UPDATE_OVERLAYS)
			use(1)
		else
			to_chat(user, "<span class='warning'>Вы больше не можете найти куда [name] пристраивается!</span>")


/obj/item/stack/sheet/animalhide/ashdrake
	name = "ash drake hide"
	desc = "The strong, scaled hide of an ash drake."
	icon = 'icons/obj/mining.dmi'
	icon_state = "dragon_hide"
	singular_name = "drake plate"
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_NORMAL
	layer = MOB_LAYER

//Step one - dehairing.

/obj/item/stack/sheet/animalhide/attackby(obj/item/I, mob/user, params)
	if(is_sharp(I))
		add_fingerprint(user)
		if(loc == user && !user.can_unEquip(src))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] starts cutting hair off [src]."),
			span_notice("You start cutting the hair off [src]..."),
			span_italics("You hear the sound of a knife rubbing against flesh."),
		)
		if(!do_after(user, 5 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You cut the hair from [src]."))
		var/obj/item/stack/sheet/hairlesshide/hide = new(drop_location(), amount)
		hide.add_fingerprint(user)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


//Step two - washing (also handled by water reagent code and washing machine code)
/obj/item/stack/sheet/hairlesshide/water_act(volume, temperature, source, method = REAGENT_TOUCH)
	. = ..()
	if(volume >= 10)
		new /obj/item/stack/sheet/wetleather(get_turf(src), amount)
		qdel(src)

//Step three - drying
/obj/item/stack/sheet/wetleather/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature >= drying_threshold_temperature)
		wetness--
		if(wetness == 0)
			//Try locating an exisitng stack on the tile and add to there if possible
			for(var/obj/item/stack/sheet/leather/HS in src.loc)
				if(HS.amount < 50)
					HS.amount++
					src.use(1)
					wetness = initial(wetness)
					return
			//If it gets to here it means it did not find a suitable stack on the tile.
			new /obj/item/stack/sheet/leather(src.loc, 1)
			wetness = initial(wetness)
			src.use(1)
