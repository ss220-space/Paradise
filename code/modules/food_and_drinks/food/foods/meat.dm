
//////////////////////
//		Raw Meat	//
//////////////////////

/obj/item/reagent_containers/food/snacks/meat
	name = "meat"
	desc = "A slab of meat"
	icon_state = "meat"
	filling_color = "#FF1C1C"
	bitesize = 3
	list_reagents = list("protein" = 3)
	tastes = list("meat" = 1)
	foodtype = MEAT


/obj/item/reagent_containers/food/snacks/meat/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !is_sharp(I))
		return .

	if(!isturf(loc))
		to_chat(user, span_warning("You cannot cut [src] [ismob(loc) ? "in inventory" : "in [loc]"]."))
		return .

	var/static/list/acceptable_surfaces = typecacheof(list(
		/obj/structure/table,
		/obj/machinery/optable,
		/obj/item/storage/bag/tray,
	))
	var/acceptable = FALSE
	for(var/thing in loc)
		if(is_type_in_typecache(thing, acceptable_surfaces))
			acceptable = TRUE
			break
	if(!acceptable)
		to_chat(user, span_warning("You cannot cut [src] here! You need a table or at least a tray to do it."))
		return .

	. |= ATTACK_CHAIN_BLOCKED_ALL
	var/strips_amount = 3
	if(istype(I, /obj/item/kitchen/knife) || istype(I, /obj/item/scalpel))
		user.visible_message(
			span_notice("[user] cuts the meat in thin strips."),
			span_notice("You have cut the meat in thin strips."),
		)
	else
		strips_amount = 1
		user.visible_message(
			span_notice("[user] crudely cuts the meat in thin strips."),
			span_notice("You have crudely cut the meat in thin strips."),
		)
	for(var/i = 1 to strips_amount)
		var/obj/item/reagent_containers/food/snacks/rawcutlet/cutlet = new(loc)
		transfer_fingerprints_to(cutlet)
		cutlet.add_fingerprint(user)
	qdel(src)


/obj/item/reagent_containers/food/snacks/meat/syntiflesh
	name = "synthetic meat"
	desc = "A synthetic slab of flesh."

/obj/item/reagent_containers/food/snacks/meat/humanoid
	name = "humanoid meat"
	var/subjectname = ""
	var/subjectjob = null
	tastes = list("salty meat" = 1)

/obj/item/reagent_containers/food/snacks/meat/humanoid/Initialize(mapload, mob/living/carbon/human/victim)
	. = ..()
	if(victim)
		subjectname = victim.real_name
		subjectjob = victim.job
		victim.reagents.trans_to(src, (victim.reagents.total_volume) / victim.meatleft)
		transfer_mob_blood_dna(victim)

		if(!isplasmaman(victim) && !ismachineperson(victim))
			reagents.add_reagent("nutriment", (victim.nutrition / 15) / initial(victim.meatleft))

/obj/item/reagent_containers/food/snacks/meat/humanoid/human
	name = "human meat"
	tastes = list("salty meat" = 1)

/obj/item/reagent_containers/food/snacks/meat/humanoid/vulpkanin
	name = "vulpkanin meat"
	tastes = list("salty meat" = 1)
	list_reagents = list("protein" = 5)
	icon_state = "meat_vulp"
	filling_color = "#850808"

/obj/item/reagent_containers/food/snacks/meat/humanoid/tajaran
	name = "tajaran meat"
	tastes = list("salty meat" = 1)
	list_reagents = list("protein" = 3)
	icon_state = "meat_tajara"
	filling_color = "#df1919"

/obj/item/reagent_containers/food/snacks/meat/humanoid/unathi
	name = "unathi meat"
	tastes = list("chiken meat" = 1)
	list_reagents = list("protein" = 3, "zessulblood" = 2)
	icon_state = "meat_unathi"
	filling_color = "#850808"

/obj/item/reagent_containers/food/snacks/meat/humanoid/drask
	name = "drask meat"
	tastes = list("icy meat" = 1)
	list_reagents = list("protein" = 3, "ice" = 10)
	icon_state = "meat_drask"
	filling_color = "#329983"
	bitesize = 5
	var/type1 = "meat_drask"
	var/type2 = "meat_drask2"

/obj/item/reagent_containers/food/snacks/meat/humanoid/drask/New()
	..()
	icon_state = pick(type1, type2)

/obj/item/reagent_containers/food/snacks/meat/humanoid/grey
	name = "grey meat"
	tastes = list("salty meat" = 1)
	list_reagents = list("protein" = 2, "mannitol" = 2)
	icon_state = "meat_grey"
	filling_color = "#8d17a5"
	var/type1 = "meat_grey"
	var/type2 = "meat_grey2"

/obj/item/reagent_containers/food/snacks/meat/humanoid/grey/New()
	..()
	icon_state = pick(type1, type2)

/obj/item/reagent_containers/food/snacks/meat/humanoid/skrell
	name = "skrell meat"
	tastes = list("watery meat" = 1)
	list_reagents = list("protein" = 3, "water" = 20)
	icon_state = "meat_skrell"
	filling_color = "#4d17a5"
	bitesize = 10

/obj/item/reagent_containers/food/snacks/meat/humanoid/vox
	name = "vox meat"
	tastes = list("chiken meat" = 1)
	list_reagents = list("protein" = 3, "toxin" = 1)
	icon_state = "meat_vox"
	filling_color = "#0c5ac0"

/obj/item/reagent_containers/food/snacks/meat/humanoid/slime
	name = "slime jelly"
	tastes = list("sweet jelly" = 1)
	list_reagents = list("sugar" = 5, "slimejelly" = 10)
	icon_state = "meat_slime"
	filling_color = "#11a0cc"
	bitesize = 5

/obj/item/reagent_containers/food/snacks/meat/humanoid/wryn
	name = "wryn meat"
	tastes = list("sweet meat" = 1)
	list_reagents = list("protein" = 1, "sugar" = 5)
	icon_state = "meat_wryn"
	filling_color = "#d1be0d"

/obj/item/reagent_containers/food/snacks/meat/humanoid/kidan
	name = "kidan meat"
	tastes = list("bug meat" = 1)
	list_reagents = list("protein" = 2, "blood" = 1)
	icon_state = "meat_kidan"
	filling_color = "#db9808"

/obj/item/reagent_containers/food/snacks/meat/humanoid/nian
	name = "nian meat"
	tastes = list("bug meat" = 1)
	list_reagents = list("protein" = 2, "phosphorus" = 5)
	icon_state = "meat_nian"
	filling_color = "#866929"

/obj/item/reagent_containers/food/snacks/meat/humanoid/diona
	name = "diona branch"
	tastes = list("crunchy green" = 1)
	list_reagents = list("plantmatter" = 5)
	icon_state = "branch_diona"
	filling_color = "#2d6102"
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/meat/humanoid/nucleation
	name = "nucleation remains"
	tastes = list("radioactive dust" = 1)
	list_reagents = list("radium" = 30)
	icon_state = "dust_nucleation"
	filling_color = "#edf5ac"
	bitesize = 10
	foodtype = TOXIC

/obj/item/reagent_containers/food/snacks/meat/humanoid/plasmaman
	name = "plasmaman remains"
	tastes = list("radioactive dust" = 1)
	list_reagents = list("radium" = 10, "plasma" = 10)
	icon_state = "dust_plasmaman"
	filling_color = "#a502c5"
	bitesize = 10
	foodtype = TOXIC

/obj/item/reagent_containers/food/snacks/meat/humanoid/machine
	name = "machine remains"
	tastes = list("radioactive dust" = 1)
	list_reagents = list("iron" = 3, "aluminum" = 2, "lithium" = 1, "mercury" = 2, "metalicdust" = 1)
	icon_state = "dust_machine"
	filling_color = "#403e41"
	bitesize = 9
	foodtype = TOXIC

/obj/item/reagent_containers/food/snacks/meat/humanoid/monkey
	name = "monkey meat"
	tastes = list("salty meat" = 1)
	list_reagents = list("protein" = 2)
	filling_color = "#FF1C1C"

/obj/item/reagent_containers/food/snacks/meat/humanoid/farwa
	name = "farwa meat"
	list_reagents = list("protein" = 1)
	tastes = list("salty meat" = 1)
	icon_state = "meat_tajara"
	filling_color = "#df1919"

/obj/item/reagent_containers/food/snacks/meat/humanoid/wolpin
	name = "wolpin meat"
	list_reagents = list("protein" = 3)
	tastes = list("salty meat" = 1)
	icon_state = "meat_vulp"
	filling_color = "#850808"
	bitesize = 2

/obj/item/reagent_containers/food/snacks/meat/humanoid/neara
	name = "neara meat"
	list_reagents = list("protein" = 2, "water" = 5)
	tastes = list("watery meat" = 1)
	icon_state = "meat_skrell"
	filling_color = "#4d17a5"
	bitesize = 4

/obj/item/reagent_containers/food/snacks/meat/humanoid/stok
	name = "stok meat"
	list_reagents = list("protein" = 2, "zessulblood" = 1)
	tastes = list("chiken meat" = 1)
	icon_state = "meat_unathi"
	filling_color = "#850808"
	bitesize = 2

/obj/item/reagent_containers/food/snacks/meat/slab/meatproduct
	name = "meat product"
	desc = "A slab of reclaimed and chemically processed meat product."

/obj/item/reagent_containers/food/snacks/meat/slab/gorilla
	name = "gorilla meat"
	desc = "Much meatier than monkey meat."
	list_reagents = list("nutriment" = 5, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/meat/bird
	name = "bird meat"
	desc = "Light and tasty meat"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "birdmeat"

/obj/item/reagent_containers/food/snacks/meat/corgi
	name = "corgi meat"
	desc = "Tastes like the Head of Personnel's hopes and dreams"

/obj/item/reagent_containers/food/snacks/meat/dog
	name = "dog meat"
	desc = "Не слишком питательно. Но говорят деликатес космокорейцев."
	list_reagents = list("protein" = 2, "epinephrine" = 2)

/obj/item/reagent_containers/food/snacks/meat/pug
	name = "pug meat"
	desc = "Slightly less adorable in sliced form."
	list_reagents = list("protein" = 2, "epinephrine" = 2)

/obj/item/reagent_containers/food/snacks/meat/security
	name = "security meat"
	desc = "Мясо наполненное чувством мужества и долга."
	list_reagents = list("protein" = 3, "epinephrine" = 5)

/obj/item/reagent_containers/food/snacks/meat/ham
	name = "ham"
	desc = "For when you need to go ham."
	list_reagents = list("protein" = 3, "porktonium" = 10)

/obj/item/reagent_containers/food/snacks/meat/ham/old
	name = "жесткая ветчина"
	desc = "Мясо почтенного хряка."
	list_reagents = list("protein" = 2, "porktonium" = 10)

/obj/item/reagent_containers/food/snacks/meat/mouse
	name = "мышатина"
	desc = "На безрыбье и мышь мясо. Кто знает чем питался этот грызун до его подачи к столу."
	icon_state = "meat_clear"
	list_reagents = list("nutriment" = 2, "blood" = 3, "toxin" = 1)

/obj/item/reagent_containers/food/snacks/meat/meatwheat
	name = "meatwheat clump"
	desc = "This doesn't look like meat, but your standards aren't <i>that</i> high to begin with."
	list_reagents = list("nutriment" = 3, "vitamin" = 2, "blood" = 5)
	filling_color = rgb(150, 0, 0)
	icon_state = "meatwheat_clump"
	bitesize = 4
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/rawcutlet
	name = "raw cutlet"
	desc = "A thin strip of raw meat."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "rawcutlet"
	bitesize = 1
	list_reagents = list("protein" = 1)
	foodtype = MEAT


/obj/item/reagent_containers/food/snacks/rawcutlet/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !is_sharp(I))
		return .

	if(!isturf(loc))
		to_chat(user, span_warning("You cannot trim [src] [ismob(loc) ? "in inventory" : "in [loc]"]."))
		return .

	var/static/list/acceptable_surfaces = typecacheof(list(
		/obj/structure/table,
		/obj/machinery/optable,
		/obj/item/storage/bag/tray,
	))
	var/acceptable = FALSE
	for(var/thing in loc)
		if(is_type_in_typecache(thing, acceptable_surfaces))
			acceptable = TRUE
			break
	if(!acceptable)
		to_chat(user, span_warning("You cannot trim [src] here! You need a table or at least a tray to do it."))
		return .

	. |= ATTACK_CHAIN_BLOCKED_ALL
	var/bacon_amount = 2
	if(istype(I, /obj/item/kitchen/knife) || istype(I, /obj/item/scalpel))
		user.visible_message(
			span_notice("[user] trims the raw bacon from [src]."),
			span_notice("You have trimmed the raw bacon from [src]."),
		)
	else
		bacon_amount = 1
		user.visible_message(
			span_notice("[user] crudely trims the raw bacon from [src]."),
			span_notice("You have crudely trimmed the raw bacon from [src]."),
		)
	for(var/i = 1 to bacon_amount)
		var/obj/item/reagent_containers/food/snacks/raw_bacon/bacon = new(loc)
		transfer_fingerprints_to(bacon)
		bacon.add_fingerprint(user)
	qdel(src)


//////////////////////////
//		Monster Meat	//
//////////////////////////

// Cannot be used in the usual meat-based food recipies but can be used as cloning pod biomass.

/obj/item/reagent_containers/food/snacks/monstermeat
	// Abstract object used for inheritance. I don't see why you would want one.
	// It's just a convenience to set all monstermeats as biomass-able at once,
	// in the GLOB.cloner_biomass_items list.
	// DOES NOT SPAWN NATURALLY!
	name = "abstract monster meat"
	desc = "A slab of abstract monster meat. This shouldn't exist, contact a coder about this if you are seeing it in-game."
	icon_state = "bearmeat"
	foodtype = MEAT | TOXIC | RAW

/obj/item/reagent_containers/food/snacks/monstermeat/bearmeat
	name = "bear meat"
	desc = "A very manly slab of meat."
	icon_state = "bearmeat"
	filling_color = "#DB0000"
	bitesize = 3
	list_reagents = list("protein" = 12, "morphine" = 5, "vitamin" = 2)
	tastes = list("meat" = 1, "salmon" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/monstermeat/xenomeat
	name = "meat"
	desc = "A slab of meat. It's green!"
	icon_state = "xenomeat"
	filling_color = "#43DE18"
	bitesize = 6
	list_reagents = list("protein" = 3, "vitamin" = 1)
	tastes = list("meat" = 1, "acid" = 1)
	foodtype = MEAT | GROSS | RAW

/obj/item/reagent_containers/food/snacks/monstermeat/spidermeat
	name = "spider meat"
	desc = "A slab of spider meat. Not very appetizing."
	icon_state = "spidermeat"
	bitesize = 3
	list_reagents = list("protein" = 3, "toxin" = 3, "vitamin" = 1)
	tastes = list("cobwebs" = 1)

/obj/item/reagent_containers/food/snacks/monstermeat/lizardmeat
	name = "mutant lizard meat"
	desc = "A peculiar slab of meat. It looks scaly and radioactive."
	icon_state = "xenomeat"
	filling_color = "#43DE18"
	bitesize = 3
	list_reagents = list("protein" = 3, "toxin" = 3)
	tastes = list("tough meat" = 1)

/obj/item/reagent_containers/food/snacks/monstermeat/spiderleg
	name = "spider leg"
	desc = "A still twitching leg of a giant spider. You don't really want to eat this, do you?"
	icon_state = "spiderleg"
	list_reagents = list("protein" = 2, "toxin" = 2)
	tastes = list("cobwebs" = 1, "creepy motion" = 1)

/obj/item/reagent_containers/food/snacks/raw_bacon
	name = "raw bacon"
	desc = "God's gift to man in uncooked form."
	icon_state = "raw_bacon"
	list_reagents = list("nutriment" = 1, "porktonium" = 10)
	tastes = list("bacon" = 1)
	foodtype = MEAT | RAW

/obj/item/reagent_containers/food/snacks/monstermeat/spidereggs
	name = "spider eggs"
	desc = "A cluster of juicy spider eggs. A great side dish for when you don't care about your health."
	icon_state = "spidereggs"
	list_reagents = list("protein" = 2, "toxin" = 2)
	tastes = list("cobwebs" = 1, "spider juice" = 1)

/obj/item/reagent_containers/food/snacks/monstermeat/goliath
	name = "goliath meat"
	desc = "A slab of goliath meat. It's not very edible now, but it cooks great in lava."
	icon_state = "goliathmeat"
	list_reagents = list("protein" = 3, "toxin" = 5)
	tastes = list("tough meat" = 1)

/obj/item/reagent_containers/food/snacks/monstermeat/goliath/burn()
	visible_message("<span class='notice'>[src] finishes cooking!</span>")
	new /obj/item/reagent_containers/food/snacks/goliath_steak(loc)
	qdel(src)

/obj/item/reagent_containers/food/snacks/monstermeat/goldgrub
	name= "goldgrub meat"
	desc = "Gross, slimy, and green intestines with goldgrub skin, retrieved from a Goldgrub. Legends say it is valuable in traditional medicines, however it's highly toxic now."
	icon_state = "Goldgrubmeat"
	list_reagents = list("grub_juice" = 5, "toxin" = 10)
	bitesize = 2
	tastes = list("meat" = 1)

/obj/item/reagent_containers/food/snacks/monstermeat/goldgrub/burn()
	visible_message("<span class='notice'>[src] finishes cooking!</span>")
	new /obj/item/reagent_containers/food/snacks/goldgrubmeat(loc)
	qdel(src)

/obj/item/reagent_containers/food/snacks/monstermeat/rotten
	name = "rotten meat"
	desc = "A slab of rotten meat. Looks really awful, a couple of flies sit on it."
	icon_state = "rottenmeatslab"
	list_reagents = list("protein" = 1, "toxin" = 10, "????" = 20)
	tastes = list("slimy meat" = 3, "rotten meat" = 3, "stink" = 3)
	foodtype = MEAT | GROSS | RAW | TOXIC

//////////////////////
//	Cooked Meat		//
//////////////////////

/obj/item/reagent_containers/food/snacks/meatsteak
	name = "meat steak"
	desc = "A piece of hot spicy meat."
	icon_state = "meatstake"
	trash = /obj/item/trash/plate
	filling_color = "#7A3D11"
	bitesize = 3
	list_reagents = list("nutriment" = 5)
	tastes = list("meat" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/meatsteak/human
	name = "human meat steak"
	icon_state = "meatstake_human"
	list_reagents = list("nutriment" = 3, "vitamin" = 3, "protein" = 3)
	tastes = list("human meat odor" = 1, "eggplant" = 1)

/obj/item/reagent_containers/food/snacks/meatsteak/vulpkanin
	name = "vulpkanin meat steak"
	icon_state = "meatstake_vulp"
	list_reagents = list("nutriment" = 3, "vitamin" = 3, "protein" = 3)
	tastes = list("vulpkanin meat odor" = 1, "chanterelle" = 1, "lemon" = 1)

/obj/item/reagent_containers/food/snacks/meatsteak/tajaran
	name = "tajaran meat steak"
	icon_state = "meatstake_tajara"
	list_reagents = list("nutriment" = 3, "vitamin" = 3, "protein" = 3)
	tastes = list("tajaran meat odor" = 1, "nettle" = 1, "soda water" = 1)

/obj/item/reagent_containers/food/snacks/meatsteak/unathi
	name = "unathi meat steak"
	icon_state = "meatstake_unathi"
	list_reagents = list("nutriment" = 3, "vitamin" = 3, "protein" = 3)
	tastes = list("unathi meat odor" = 1, "tomato" = 2, "harebell" = 1, "black pepper" = 2, "salt" = 2, "chiken" = 1)

/obj/item/reagent_containers/food/snacks/meatsteak/drask
	name = "drask meat steak"
	desc = "A piece of cold spicy meat."
	icon_state = "meatstake_drask"
	list_reagents = list("nutriment" = 3, "vitamin" = 3, "protein" = 3)
	tastes = list("drask meat odor" = 1, "garlic" = 1, "chili" = 2, "berries" = 2, "black pepper" = 2)

/obj/item/reagent_containers/food/snacks/meatsteak/grey
	name = "grey meat steak"
	icon_state = "meatstake_grey"
	list_reagents = list("nutriment" = 3, "vitamin" = 3, "protein" = 3)
	tastes = list("grey meat odor" = 1, "garlic" = 1, "cabbage" = 1, "tomato" = 2, "salt" = 2)

/obj/item/reagent_containers/food/snacks/meatsteak/skrell
	name = "skrell meat steak"
	icon_state = "meatstake_skrell"
	list_reagents = list("nutriment" = 3, "vitamin" = 3, "protein" = 3)
	tastes = list("skrell meat odor" = 1, "banana" = 1, "tomato" = 1, "black pepper" = 2)

/obj/item/reagent_containers/food/snacks/meatsteak/vox
	name = "vox meat steak"
	icon_state = "meatstake_vox"
	list_reagents = list("nutriment" = 3, "vitamin" = 3, "protein" = 3)
	tastes = list("vox meat odor" = 1, "garlic" = 1, "herbs" = 1, "chiken" = 1, "sweet potato" = 2)

/obj/item/reagent_containers/food/snacks/meatsteak/slime
	name = "grilled jelly"
	desc = "A piece of hot spicy jelly."
	icon_state = "meatstake_slime"
	list_reagents = list("nutriment" = 3, "vitamin" = 3, "protein" = 3)
	tastes = list("slime meat odor" = 1, "garlic" = 1, "sugar" = 1, "herbs" = 1, "lemon" = 1, "ambrosia" = 1, "salt" = 2)

/obj/item/reagent_containers/food/snacks/meatsteak/wryn
	name = "wryn meat steak"
	icon_state = "meatstake_wryn"
	list_reagents = list("nutriment" = 3, "vitamin" = 3, "protein" = 3)
	tastes = list("wryn meat odor" = 1, "sweetness" = 1, "potato" = 2, "orange" = 1)

/obj/item/reagent_containers/food/snacks/meatsteak/kidan
	name = "kidan meat steak"
	icon_state = "meatstake_kidan"
	list_reagents = list("nutriment" = 3, "vitamin" = 3, "protein" = 3)
	tastes = list("kidan meat odor" = 1, "bug odor" = 1, "herbs" = 2, "olives" = 2, "salt" = 2)

/obj/item/reagent_containers/food/snacks/meatsteak/nian
	name = "nian meat steak"
	icon_state = "meatstake_nian"
	list_reagents = list("nutriment" = 3, "vitamin" = 3, "protein" = 3)
	tastes = list("nian meat odor" = 1, "bug odor" = 1, "sweetness" = 1, "orange" = 1, "lemon" = 1, "herbs" = 1)

/obj/item/reagent_containers/food/snacks/meatsteak/diona
	name = "grilled vagetables"
	desc = "Hot spicy asparagus."
	filling_color = "#548100"
	icon_state = "meatstake_diona"
	list_reagents = list("plantmatter" = 4, "vitamin" = 5)
	tastes = list("diona odor" = 1, "salt" = 2, "herbs" = 1, "garlic" = 1, "lemon" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/meatsteak/monkey
	name = "monkey meat steak"
	icon_state = "meatstake_monkey"
	list_reagents = list("nutriment" = 3, "vitamin" = 3, "protein" = 3)
	tastes = list("monkey meat odor" = 1, "salt" = 2, "herbs" = 1, "lemon" = 1, "chili" = 2)

/obj/item/reagent_containers/food/snacks/meatsteak/farwa
	name = "farwa meat steak"
	icon_state = "meatstake_farwa"
	list_reagents = list("nutriment" = 3, "vitamin" = 3, "protein" = 3)
	tastes = list("farwa meat odor" = 1, "poppy" = 2, "grape" = 1)

/obj/item/reagent_containers/food/snacks/meatsteak/wolpin
	name = "wolpin meat steak"
	icon_state = "meatstake_wolpin"
	list_reagents = list("nutriment" = 3, "vitamin" = 3, "protein" = 3)
	tastes = list("wolpin meat odor" = 1, "potato" = 1, "onion" = 2)

/obj/item/reagent_containers/food/snacks/meatsteak/neara
	name = "neara meat steak"
	icon_state = "meatstake_neara"
	list_reagents = list("nutriment" = 3, "vitamin" = 3, "protein" = 3)
	tastes = list("neara meat odor" = 1, "lemon" = 1, "soy" = 2, "herbs" = 1)

/obj/item/reagent_containers/food/snacks/meatsteak/stok
	name = "stok meat steak"
	icon_state = "meatstake_stok"
	list_reagents = list("nutriment" = 3, "vitamin" = 3, "protein" = 3)
	tastes = list("stok meat odor" = 1, "chiken" = 1, "cucumber" = 2, "herbs" = 1, "orange" = 1)

/obj/item/reagent_containers/food/snacks/birdsteak
	name = "Chicken steak"
	desc = "A piece of hot light bird meat."
	icon_state = "birdsteak"
	filling_color = "#7A3D11"
	bitesize = 3
	list_reagents = list("nutriment" = 5)
	tastes = list("meat" = 1, "chicken" = 2)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/bacon
	name = "bacon"
	desc = "It looks crispy and tastes amazing! Mmm... Bacon."
	icon_state = "bacon"
	list_reagents = list("nutriment" = 4, "porktonium" = 10, "msg" = 4)
	tastes = list("bacon" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/telebacon
	name = "tele bacon"
	desc = "It tastes a little odd but it's still delicious."
	icon_state = "bacon"
	var/obj/item/radio/beacon/bacon/baconbeacon
	list_reagents = list("nutriment" = 4, "porktonium" = 10)
	tastes = list("bacon" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/telebacon/New()
	..()
	baconbeacon = new /obj/item/radio/beacon/bacon(src)

/obj/item/reagent_containers/food/snacks/telebacon/On_Consume(mob/M, mob/user)
	if(!reagents.total_volume)
		baconbeacon.forceMove(user)
		baconbeacon.digest_delay()
		baconbeacon = null

/obj/item/reagent_containers/food/snacks/meatball
	name = "meatball"
	desc = "A great meal all round."
	icon_state = "meatball"
	filling_color = "#DB0000"
	list_reagents = list("protein" = 4, "vitamin" = 1)
	tastes = list("meat" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/sausage
	name = "sausage"
	desc = "A piece of mixed and cased meat."
	icon_state = "sausage"
	filling_color = "#DB0000"
	list_reagents = list("protein" = 6, "vitamin" = 1, "porktonium" = 10)
	tastes = list("meat" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/cutlet
	name = "cutlet"
	desc = "A tasty meat slice."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "cutlet"
	list_reagents = list("protein" = 2)
	tastes = list("meat" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/spidereggsham
	name = "green eggs and ham"
	desc = "Would you eat them on a train? Would you eat them on a plane? Would you eat them on a state of the art corporate deathtrap floating through space?"
	icon_state = "spidereggsham"
	trash = /obj/item/trash/plate
	bitesize = 4
	list_reagents = list("nutriment" = 6)
	tastes = list("cobwebs" = 1, "the colour green" = 1)
	foodtype = EGG | GROSS

/obj/item/reagent_containers/food/snacks/boiledspiderleg
	name = "boiled spider leg"
	desc = "A giant spider's leg that's still twitching after being cooked. Gross!"
	icon_state = "spiderlegcooked"
	trash = /obj/item/trash/plate
	bitesize = 3
	list_reagents = list("nutriment" = 3, "capsaicin" = 2)
	tastes = list("cobwebs" = 1, "hot peppers" = 1)
	foodtype = MEAT | GROSS

/obj/item/reagent_containers/food/snacks/wingfangchu
	name = "wing fang chu"
	desc = "A savory dish of alien wing wang in soy. Wait, what?"
	icon_state = "wingfangchu"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#43DE18"
	list_reagents = list("nutriment" = 6, "soysauce" = 5, "vitamin" = 2)
	tastes = list("soy" = 1)
	foodtype = MEAT | GROSS

/obj/item/reagent_containers/food/snacks/goliath_steak
	name = "goliath steak"
	desc = "A delicious, lava cooked steak."
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	icon_state = "goliathsteak"
	trash = null
	list_reagents = list("protein" = 6, "vitamin" = 2)
	tastes = list("meat" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/goldgrubmeat
	name= "goldgrub steak"
	desc = "Cooked intestines with goldgrub skin, retrieved from a Goldgrub. Legends say it is valuable in traditional medicines."
	icon_state = "Goldgrubsteak"
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	list_reagents = list("grub_juice" = 5)
	tastes = list("meat" = 1)


/obj/item/reagent_containers/food/snacks/smokedsausage
	name = "Smoked sausage"
	desc = "Piece of smoked sausage. Oh, really?"
	icon_state = "smokedsausage"
	list_reagents = list("protein" = 12)
	tastes = list("meat" = 3)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/sliceable/salami
	name = "Salami"
	desc = "Not the best for sandwiches."
	icon_state = "salami"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/salami
	slices_num = 6
	list_reagents = list("protein" = 12)
	tastes = list("meat" = 3, "garlic" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/slice/salami
	name = "Salami's slice"
	desc = "A slice of salami. The best for sandwiches"
	icon_state = "salami_s"
	bitesize = 2
	foodtype = MEAT

//////////////////////
//		Cubes		//
//////////////////////

/obj/item/reagent_containers/food/snacks/monkeycube
	name = "monkey cube"
	desc = "Just add water!"
	icon_state = "monkeycube"
	bitesize = 12
	filling_color = "#ADAC7F"
	var/faction
	var/datum/species/monkey_type = /datum/species/monkey
	list_reagents = list("nutriment" = 2)
	tastes = list("the jungle" = 1, "bananas" = 1)
	foodtype = MEAT | RAW

/obj/item/reagent_containers/food/snacks/monkeycube/water_act(volume, temperature, source, method = REAGENT_TOUCH)
	. = ..()
	if(volume >= 1)
		return Expand()

/obj/item/reagent_containers/food/snacks/monkeycube/wash(mob/user, atom/source)
	user.drop_from_active_hand()
	forceMove(get_turf(source))
	return 1

/obj/item/reagent_containers/food/snacks/monkeycube/proc/Expand()
	if(LAZYLEN(SSmobs.cubemonkeys) >= CONFIG_GET(number/cubemonkey_cap))
		return
		//Due to server crashing capabilities, chat feature is disabled.

		//if(fingerprintslast)
		//	to_chat(get_mob_by_ckey(fingerprintslast), "<span class='warning'>Bluespace harmonics prevent the spawning of more than [CONFIG_GET(number/cubemonkey_cap)] monkeys on the station at one time!</span>")
		//else
		//	visible_message("<span class='notice'>[src] fails to expand!</span>")

	if(!QDELETED(src))
		visible_message("<span class='notice'>[src] expands!</span>")
		if(fingerprintslast)
			add_misc_logs(what = "Cube ([monkey_type]) inflated, last touched by: " + fingerprintslast)
		else
			add_misc_logs(what = "Cube ([monkey_type]) inflated, last touched by: NO_DATA")
		var/mob/living/carbon/human/lesser/creature = new(get_turf(src), monkey_type)
		if(faction)
			creature.faction = faction
		if(LAZYLEN(fingerprintshidden))
			creature.fingerprintshidden = fingerprintshidden
		SSmobs.cubemonkeys += creature
		qdel(src)

/obj/item/reagent_containers/food/snacks/monkeycube/syndicate
	faction = list("neutral", "syndicate")

/obj/item/reagent_containers/food/snacks/monkeycube/farwacube
	name = "farwa cube"
	monkey_type = /datum/species/monkey/tajaran

/obj/item/reagent_containers/food/snacks/monkeycube/wolpincube
	name = "wolpin cube"
	monkey_type = /datum/species/monkey/vulpkanin

/obj/item/reagent_containers/food/snacks/monkeycube/stokcube
	name = "stok cube"
	monkey_type = /datum/species/monkey/unathi

/obj/item/reagent_containers/food/snacks/monkeycube/neaeracube
	name = "neaera cube"
	monkey_type = /datum/species/monkey/skrell


//////////////////////
//		Eggs		//
//////////////////////

/obj/item/reagent_containers/food/snacks/egg
	name = "egg"
	desc = "An egg!"
	icon_state = "egg"
	filling_color = "#FDFFD1"
	list_reagents = list("protein" = 1, "egg" = 5)
	tastes = list("egg" = 1)
	foodtype = EGG


/obj/item/reagent_containers/food/snacks/egg/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	var/turf/T = get_turf(hit_atom)
	new/obj/effect/decal/cleanable/egg_smudge(T)
	if(reagents)
		reagents.reaction(hit_atom, REAGENT_TOUCH)
	qdel(src)


/obj/item/reagent_containers/food/snacks/egg/update_icon_state()
	icon_state = "egg[item_color ? "-[item_color]" : ""]"


/obj/item/reagent_containers/food/snacks/egg/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/crayon = I
		var/crayon_color = crayon.colourName
		var/static/list/acceptable_colors = list("blue","green","mime","orange","purple","rainbow","red","yellow")
		if(!(crayon_color in acceptable_colors))
			to_chat(user, span_warning("The egg refuses to take on this color!"))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You color [src] [crayon_color]."))
		item_color = crayon_color
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/reagent_containers/food/snacks/egg/blue
	icon_state = "egg-blue"
	item_color = "blue"

/obj/item/reagent_containers/food/snacks/egg/green
	icon_state = "egg-green"
	item_color = "green"

/obj/item/reagent_containers/food/snacks/egg/mime
	icon_state = "egg-mime"
	item_color = "mime"

/obj/item/reagent_containers/food/snacks/egg/orange
	icon_state = "egg-orange"
	item_color = "orange"

/obj/item/reagent_containers/food/snacks/egg/purple
	icon_state = "egg-purple"
	item_color = "purple"

/obj/item/reagent_containers/food/snacks/egg/rainbow
	icon_state = "egg-rainbow"
	item_color = "rainbow"

/obj/item/reagent_containers/food/snacks/egg/red
	icon_state = "egg-red"
	item_color = "red"

/obj/item/reagent_containers/food/snacks/egg/yellow
	icon_state = "egg-yellow"
	item_color = "yellow"

/obj/item/reagent_containers/food/snacks/egg/gland
	desc = "An egg! It looks weird..."

/obj/item/reagent_containers/food/snacks/egg/gland/Initialize(mapload)
	reagents.add_reagent(get_random_reagent_id(), 15)

	color = mix_color_from_reagents(reagents.reagent_list)
	. = ..()

/obj/item/reagent_containers/food/snacks/friedegg
	name = "fried egg"
	desc = "A fried egg, with a touch of salt and pepper."
	icon_state = "friedegg"
	filling_color = "#FFDF78"
	bitesize = 1
	list_reagents = list("nutriment" = 3, "egg" = 5)
	tastes = list("egg" = 1, "salt" = 1, "pepper" = 1)
	foodtype = EGG

/obj/item/reagent_containers/food/snacks/boiledegg
	name = "boiled egg"
	desc = "A hard boiled egg."
	icon_state = "egg"
	filling_color = "#FFFFFF"
	list_reagents = list("nutriment" = 2, "egg" = 5, "vitamin" = 1)
	foodtype = EGG

/obj/item/reagent_containers/food/snacks/chocolateegg
	name = "chocolate egg"
	desc = "Such sweet, fattening food."
	icon_state = "chocolateegg"
	filling_color = "#7D5F46"
	list_reagents = list("nutriment" = 4, "sugar" = 2, "cocoa" = 2)
	foodtype = SUGAR

/obj/item/reagent_containers/food/snacks/omelette
	name = "omelette du fromage"
	desc = "That's all you can say!"
	icon_state = "omelette"
	trash = /obj/item/trash/plate
	filling_color = "#FFF9A8"
	list_reagents = list("nutriment" = 8, "vitamin" = 1)
	bitesize = 1
	tastes = list("egg" = 1, "cheese" = 1)
	foodtype = EGG

/obj/item/reagent_containers/food/snacks/benedict
	name = "eggs benedict"
	desc = "There is only one egg on this, how rude."
	icon_state = "benedict"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "egg" = 3, "vitamin" = 4)
	tastes = list("egg" = 1, "bacon" = 1, "bun" = 1)
	foodtype = EGG | GRAIN


//////////////////////
//		Misc		//
//////////////////////

/obj/item/reagent_containers/food/snacks/hotdog
	name = "hotdog"
	desc = "Not made with actual dogs. Hopefully."
	icon_state = "hotdog"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "ketchup" = 3, "vitamin" = 3)
	tastes = list("bun" = 3, "meat" = 2)
	foodtype = MEAT | GRAIN

/obj/item/reagent_containers/food/snacks/meatbun
	name = "meat bun"
	desc = "Has the potential to not be dog."
	icon_state = "meatbun"
	bitesize = 6
	list_reagents = list("nutriment" = 6, "vitamin" = 2)
	tastes = list("bun" = 3, "meat" = 2)
	foodtype = MEAT | GRAIN

/obj/item/reagent_containers/food/snacks/sliceable/turkey
	name = "turkey"
	desc = "A traditional turkey served with stuffing."
	icon_state = "turkey"
	slice_path = /obj/item/reagent_containers/food/snacks/turkeyslice
	slices_num = 6
	list_reagents = list("protein" = 24, "nutriment" = 18, "vitamin" = 5)
	tastes = list("turkey" = 2, "stuffing" = 2)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/turkeyslice
	name = "turkey serving"
	desc = "A serving of some tender and delicious turkey."
	icon_state = "turkeyslice"
	trash = /obj/item/trash/plate
	filling_color = "#B97A57"
	tastes = list("turkey" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/pelmeni
	name = "pelmeni"
	desc = "Meat wrapped in thin uneven dough."
	icon_state = "pelmeni"
	filling_color = "#d9be29"
	list_reagents = list("protein" = 2)
	bitesize = 2
	tastes = list("raw meat" = 1, "raw dough" = 1)
	foodtype = MEAT | RAW | GRAIN

/obj/item/reagent_containers/food/snacks/boiledpelmeni
	name = "boiled pelmeni"
	desc = "We don't know what was Siberia, but these tasty pelmeni definitely arrived from there."
	icon_state = "boiledpelmeni"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#d9be29"
	list_reagents = list("protein" = 5)
	bitesize = 3
	tastes = list("meat" = 2, "dough" = 2)
	foodtype = MEAT | GRAIN

/obj/item/reagent_containers/food/snacks/organ
	name = "organ"
	desc = "Technically qualifies as organic."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "appendix"
	filling_color = "#E00D34"
	bitesize = 3
	list_reagents = list("protein" = 4, "vitamin" = 4)
	foodtype = MEAT | GROSS

/obj/item/reagent_containers/food/snacks/appendix
//yes, this is the same as meat. I might do something different in future
	name = "appendix"
	desc = "An appendix which looks perfectly healthy."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "appendix"
	filling_color = "#E00D34"
	bitesize = 3
	list_reagents = list("protein" = 3, "vitamin" = 2)
	foodtype = MEAT | GROSS

/obj/item/reagent_containers/food/snacks/appendix/inflamed
	name = "inflamed appendix"
	desc = "An appendix which appears to be inflamed."
	icon_state = "appendixinflamed"
	filling_color = "#E00D7A"

//Food made of species
/obj/item/reagent_containers/food/snacks/fried_vox
	name = "Kentucky Fried Vox"
	desc = "Bucket of voxxy, yaya!"
	icon_state = "fried_vox"
	trash = /obj/item/trash/fried_vox
	list_reagents = list("nutriment" = 3, "protein" = 5)
	tastes = list("quills" = 1, "the shoal" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/kidanragu
	name = "Spicy chitin ragu"
	desc = "Stew with very tough chitinous meat and stewed vegetables."
	icon_state = "kidanragu"
	list_reagents = list("nutriment" = 8, "vitamin" = 4, "protein" = 4)
	tastes = list("insect" = 3, "vegetable" = 2)
	foodtype = GROSS | VEGETABLES

/obj/item/reagent_containers/food/snacks/sliceable/lizard
	name = "Fried reptile meat"
	desc = " A Juicy steaks from the tail of a large lizard, makes you want to lie on warm rocks. Slicable"
	icon_state = "lizard_steak"
	slice_path = /obj/item/reagent_containers/food/snacks/lizardslice
	slices_num = 5
	list_reagents = list("zessulblood" = 50, "protein" = 30, "nutriment" = 20, "vitamin" = 10)
	tastes = list("lizard meat" = 4, "chicken meat" = 2)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/lizardslice
	name = "reptile steak"
	desc = "A serving of unathi meat."
	icon_state = "lizard_slice"
	trash = /obj/item/trash/plate
	filling_color = "#a55f3a"
	tastes = list("lizard meat" = 2, "chicken meat" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/tajaroni
	name = "Tajaroni"
	desc = "Spicy dried sausage with pepper and... Did it just meow?"
	icon_state = "tajaroni"
	list_reagents = list("nutriment" = 8, "vitamin" = 4, "protein" = 4)
	tastes = list("dry meat" = 3, "cat meat" = 2)
	foodtype = MEAT

//vulpix
/obj/item/reagent_containers/food/snacks/vulpix
	name = "Vulpixes"
	desc = "Appetizing-looking meat balls in the dough.. The main thing is not to think about WHO they are made of!"
	icon_state = "vulpix"
	list_reagents = list("nutriment" = 10, "vitamin" = 4, "protein" = 5)
	tastes = list("dough" = 2, "dog meat" = 3)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/vulpix/cheese
	name = "Cheese vulpixes"
	desc = "Appetizing-looking meat balls in the dough filled with cheese.. The main thing is not to think about WHO they are made of!"
	icon_state = "vulpix_cheese"
	tastes = list("dough" = 2, "dog meat" = 3, "cheese" = 2)

/obj/item/reagent_containers/food/snacks/vulpix/bacon
	name = "Bacon and mushroom vulpixes"
	desc = "Appetizing-looking meat balls in the dough filled with.. The main thing is not to think about WHO they are made of!"
	icon_state = "vulpix_bacon"
	tastes = list("dough" = 2, "dog meat" = 3, "bacon" = 2, "mushroom" = 2)

/obj/item/reagent_containers/food/snacks/vulpix/chilli
	name = "Chilli vulpixes"
	desc = "Appetizing-looking meat balls in the dough.. The main thing is not to think about WHO they are made of! Makes your tongue burn."
	icon_state = "vulpix_chillie"
	tastes = list("dough" = 2, "dog meat" = 3, "chillie" = 2)

/obj/item/reagent_containers/food/snacks/bakedvulp
	name = "oven-baked vulp"
	desc = "Oven-baked vulp meat with a juicy apple in the mouth. She was unintelligent... Wasn't she?"
	icon_state = "bakedvulp"
	trash = /obj/item/trash/tray
	list_reagents = list("protein" = 12, "nutriment" = 10, "vitamin" = 5)
	tastes = list("dog meat" = 2, "apple" = 1)
	foodtype = MEAT

