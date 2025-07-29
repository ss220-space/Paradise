/obj/vehicle/ridden/lavaboat
	name = "lava boat"
	desc = "Лодка, предназначенная для передвижения по лаве."
	ru_names = list(
		NOMINATIVE = "лавовая лодка",
		GENITIVE = "лавой лодки",
		DATIVE = "лавовой лодке",
		ACCUSATIVE = "лавовую лодку",
		INSTRUMENTAL = "лавовой лодкой",
		PREPOSITIONAL = "лавовой лодке"
	)
	icon_state = "goliath_boat"
	icon = 'icons/obj/lavaland/dragonboat.dmi'
	layer = ABOVE_MOB_LAYER
	key_type = /obj/item/oar
	resistance_flags = LAVA_PROOF | FIRE_PROOF

/obj/vehicle/ridden/lavaboat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/lavaboat)

//Dragon Boat

/obj/item/ship_in_a_bottle
	name = "ship in a bottle"
	desc = "Крошечный корабль в бутылке."
	ru_names = list(
		NOMINATIVE = "корабль в бутылке",
		GENITIVE = "корабля в бутылке",
		DATIVE = "кораблю в бутылке",
		ACCUSATIVE = "корабль в бутылке",
		INSTRUMENTAL = "кораблём в бутылке",
		PREPOSITIONAL = "корабле в бутылке"
	)
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "ship_bottle"

/obj/item/ship_in_a_bottle/attack_self(mob/user)
	to_chat(user, "Вы не совсем понимаете, как они вообще загоняют корабли в эти штуки, но кажется знаете, как его оттуда достать.")
	playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, TRUE)
	new /obj/vehicle/ridden/lavaboat/dragon(get_turf(src))
	qdel(src)

/obj/vehicle/ridden/lavaboat/dragon
	name = "mysterious boat"
	desc = "Эта лодка может плыть туда, куда вы захотите, без помощи вёсел!"
	ru_names = list(
		NOMINATIVE = "таинственная лодка",
		GENITIVE = "таинственной лодки",
		DATIVE = "таинственной лодке",
		ACCUSATIVE = "таинственную лодку",
		INSTRUMENTAL = "таинственной лодкой",
		PREPOSITIONAL = "таинственной лодке"
	)
	key_type = null

/obj/vehicle/ridden/lavaboat/dragon/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/lavaboat/dragonboat)


//all other stuff

/obj/item/oar
	name = "oar"
	icon = 'icons/obj/vehicles/vehicles.dmi'
	icon_state = "oar"
	item_state = "rods"
	desc = "Гидроприводной ручной двигатель. Не требует топлива. Cертифицировано для рек, луж и лавовых озёр." // Oh no, we've lost ore-oar joke
	ru_names = list(
		NOMINATIVE = "весло",
		GENITIVE = "весла",
		DATIVE = "веслу",
		ACCUSATIVE = "весло",
		INSTRUMENTAL = "веслом",
		PREPOSITIONAL = "весле"
	)
	attack_verb = list("ударил", "огрел", "вмазал", "стукнул", "шлёпнул", "врезал")
	force = 12
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = LAVA_PROOF | FIRE_PROOF

/datum/crafting_recipe/oar
	name = "goliath bone oar"
	result = /obj/item/oar
	reqs = list(/obj/item/stack/sheet/bone = 2)
	time = 15
	category = CAT_PRIMAL
	subcategory = CAT_MISC2

/datum/crafting_recipe/boat
	name = "goliath hide boat"
	result = /obj/vehicle/ridden/lavaboat
	reqs = list(/obj/item/stack/sheet/animalhide/goliath_hide = 3)
	time = 50
	category = CAT_PRIMAL
	subcategory = CAT_MISC2
