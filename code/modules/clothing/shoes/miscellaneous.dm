/obj/item/clothing/shoes/mime
	name = "mime shoes"
	icon_state = "mime"
	item_color = "mime"

/obj/item/clothing/shoes/combat //basic syndicate combat boots for nuke ops and mob corpses
	name = "combat boots"
	desc = "High speed, low drag combat boots."
	w_class = WEIGHT_CLASS_NORMAL
	can_cut_open = 1
	icon_state = "jackboots"
	item_state = "jackboots"
	armor = list("melee" = 25, "bullet" = 25, "laser" = 25, "energy" = 25, "bomb" = 50, "bio" = 10, "rad" = 0, "fire" = 70, "acid" = 50)
	strip_delay = 70
	resistance_flags = NONE
	pickup_sound = 'sound/items/handling/boots_pickup.ogg'
	drop_sound = 'sound/items/handling/boots_drop.ogg'

/obj/item/clothing/shoes/combat/swat //overpowered boots for death squads
	name = "\improper SWAT shoes"
	desc = "High speed, no drag combat boots."
	permeability_coefficient = 0.01
	armor = list("melee" = 40, "bullet" = 30, "laser" = 25, "energy" = 25, "bomb" = 50, "bio" = 30, "rad" = 30, "fire" = 90, "acid" = 50)
	clothing_traits = list(TRAIT_NO_SLIP_WATER, TRAIT_NO_SLIP_ICE)

/obj/item/clothing/shoes/sandal
	desc = "A pair of rather plain, wooden sandals."
	name = "sandals"
	icon_state = "wizard"
	strip_delay = 50
	put_on_delay = 50
	magical = TRUE

/obj/item/clothing/shoes/sandal/marisa
	desc = "A pair of magic, black shoes."
	name = "magic shoes"
	icon_state = "black"
	resistance_flags = FIRE_PROOF |  ACID_PROOF

/obj/item/clothing/shoes/sandal/magic
	name = "magical sandals"
	desc = "A pair of sandals imbued with magic."
	resistance_flags = FIRE_PROOF |  ACID_PROOF

/obj/item/clothing/shoes/galoshes
	desc = "A pair of yellow rubber boots, designed to prevent slipping on wet surfaces."
	name = "galoshes"
	icon_state = "galoshes"
	permeability_coefficient = 0.05
	clothing_traits = list(TRAIT_NO_SLIP_WATER)
	slowdown = SHOES_SLOWDOWN+1
	strip_delay = 50
	put_on_delay = 50
	resistance_flags = NONE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 40, "acid" = 75)

/obj/item/clothing/shoes/galoshes/dry
	name = "absorbent galoshes"
	desc = "A pair of purple rubber boots, designed to prevent slipping on wet surfaces while also drying them."
	icon_state = "galoshes_dry"

/obj/item/clothing/shoes/galoshes/dry/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_SHOES_STEP_ACTION, PROC_REF(on_step))

/obj/item/clothing/shoes/galoshes/dry/proc/on_step()
	SIGNAL_HANDLER
	var/turf/simulated/t_loc = get_turf(src)
	SEND_SIGNAL(t_loc, COMSIG_TURF_MAKE_DRY, TURF_WET_WATER, TRUE, INFINITY)

/obj/item/clothing/shoes/clown_shoes
	desc = "The prankster's standard-issue clowning shoes. Damn they're huge! Ctrl-click to toggle the waddle dampeners!"
	name = "clown shoes"
	icon_state = "clown"
	item_state = "clown_shoes"
	slowdown = SHOES_SLOWDOWN+1
	item_color = "clown"
	var/enabled_waddle = TRUE

/obj/item/clothing/shoes/clown_shoes/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/clownstep1.ogg', 'sound/effects/clownstep2.ogg'), 50, falloff_exponent = 20) //die off quick please

/obj/item/clothing/shoes/clown_shoes/equipped(mob/user, slot, initial)
	. = ..()
	if(slot == ITEM_SLOT_FEET && enabled_waddle)
		user.AddElement(/datum/element/waddling)

/obj/item/clothing/shoes/clown_shoes/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	if(slot == ITEM_SLOT_FEET && enabled_waddle)
		user.RemoveElement(/datum/element/waddling)

/obj/item/clothing/shoes/clown_shoes/CtrlClick(mob/living/user)
	if(!isliving(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if(user.get_active_hand() != src)
		to_chat(user, "You must hold [src] in your hand to do this.")
		return
	if(!enabled_waddle)
		to_chat(user, "<span class='notice'>You switch off the waddle dampeners!</span>")
		enabled_waddle = TRUE
	else
		to_chat(user, "<span class='notice'>You switch on the waddle dampeners!</span>")
		enabled_waddle = FALSE

/obj/item/clothing/shoes/clown_shoes/nodrop


/obj/item/clothing/shoes/clown_shoes/nodrop/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)


/obj/item/clothing/shoes/clown_shoes/magical
	name = "magical clown shoes"
	desc = "Standard-issue shoes of the wizarding class clown. Damn they're huge! And powerful! Somehow."
	magical = TRUE

/obj/item/clothing/shoes/jackboots
	name = "jackboots"
	desc = "Nanotrasen-issue Security combat boots for combat scenarios or combat situations. All combat, all the time."
	can_cut_open = 1
	icon_state = "jackboots"
	item_state = "jackboots"
	item_color = "hosred"
	strip_delay = 50
	put_on_delay = 50
	resistance_flags = NONE
	pickup_sound = 'sound/items/handling/boots_pickup.ogg'
	drop_sound = 'sound/items/handling/boots_drop.ogg'

/obj/item/clothing/shoes/jackboots/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/jackboots)

/obj/item/clothing/shoes/jackboots/jacksandals
	name = "jacksandals"
	desc = "Nanotrasen-issue Security combat sandals for combat scenarios. They're jacksandals, however that works."
	can_cut_open = 0
	icon_state = "jacksandal"
	item_color = "jacksandal"

/obj/item/clothing/shoes/jackboots/cross
	name = "jackcross"
	desc = "Nanotrasen-issue Security combat cross for combat scenarios. They're jackcross, however that works."
	icon_state = "jackboots_cross"
	item_color = "jackboots_cross"
	can_cut_open = FALSE

/obj/item/clothing/shoes/jackboots/armored
	name = "armored shoes"
	desc = "Combat shoed for combat scenarios. When you need some ballistic protection."
	can_cut_open = TRUE
	icon_state = "armored_shoes"
	item_color = "armored_shoes"
	item_state = "armored_shoes"
	armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/shoes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/shoes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/shoes.dmi'
		)

/obj/item/clothing/shoes/workboots
	name = "work boots"
	desc = "Thick-soled boots for industrial work environments."
	can_cut_open = 1
	icon_state = "workboots"
	pickup_sound = 'sound/items/handling/boots_pickup.ogg'
	drop_sound = 'sound/items/handling/boots_drop.ogg'

/obj/item/clothing/shoes/workboots/mining
	name = "mining boots"
	desc = "Steel-toed mining boots for mining in hazardous environments. Very good at keeping toes uncrushed."
	icon_state = "explorer"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/shoes/workboots/mining/attackby(obj/item/C as obj, mob/user as mob, params)
	..()
	if(istype(C, /obj/item/kitchen/knife/combat/survival))
		var/obj/item/kitchen/knife/combat/survival/O = locate() in src
		if(O)
			to_chat(user, "<span class='notice'>В креплении уже есть нож.</span>")
		else
			user.drop_transfer_item_to_loc(C, src)
			to_chat(user, "<span class='notice'>Вы убрали [C] в [src].</span>")

/obj/item/clothing/shoes/workboots/mining/verb/verb_remove_knife()
	set category = "Object"
	set name = "Remove knife"
	set src in usr
	remove_knife(usr)

/obj/item/clothing/shoes/workboots/mining/proc/remove_knife(mob/user)
	if(issilicon(user))
		return
	if(can_use(user))
		var/obj/item/kitchen/knife/combat/survival/O = locate() in src
		if(O)
			to_chat(user, "<span class='notice'>Вы извлекли [O] из [src].</span>")
			O.forceMove_turf()
			if(istype(loc, /mob))
				var/mob/M = loc
				if(M.get_active_hand() == null)
					M.put_in_hands(O, ignore_anim = FALSE)
					return
		else
			to_chat(user, "<span class='warning'>Крепление пустое.</span>")
	else
		to_chat(user, "<span class='notice'>Сейчас вы не в состоянии сделать это.</span>")

/obj/item/clothing/shoes/winterboots
	name = "winter boots"
	desc = "Boots lined with 'synthetic' animal fur."
	can_cut_open = 1
	icon_state = "winterboots"
	cold_protection = FEET|LEGS
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET|LEGS
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT

/obj/item/clothing/shoes/cult
	name = "boots"
	desc = "A pair of boots usually worn by cultists."
	icon_state = "cult"
	item_state = "cult"
	item_color = "cult"

	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT
	magical = TRUE

/obj/item/clothing/shoes/cyborg
	name = "cyborg boots"
	desc = "Shoes for a cyborg costume"
	icon_state = "boots"

/obj/item/clothing/shoes/slippers
	name = "bunny slippers"
	desc = "Fluffy!"
	icon_state = "slippers"
	item_state = "slippers"

/obj/item/clothing/shoes/slippers_worn
	name = "worn bunny slippers"
	desc = "Fluffy..."
	icon_state = "slippers_worn"
	item_state = "slippers_worn"

/obj/item/clothing/shoes/laceup
	name = "laceup shoes"
	desc = "The height of fashion, and they're pre-polished!"
	icon_state = "laceups"
	put_on_delay = 50

/obj/item/clothing/shoes/laceup/cap
	name = "captain's laceup shoes"
	icon_state = "cap_laceups"
	item_state = "cap_laceups"

/obj/item/clothing/shoes/roman
	name = "roman sandals"
	desc = "Sandals with buckled leather straps on it."
	icon_state = "roman"
	item_state = "roman"
	strip_delay = 100
	put_on_delay = 100

/obj/item/clothing/shoes/centcom
	name = "dress shoes"
	desc = "They appear impeccably polished."
	icon_state = "laceups"

/obj/item/clothing/shoes/griffin
	name = "griffon boots"
	desc = "A pair of costume boots fashioned after bird talons."
	icon_state = "griffinboots"
	item_state = "griffinboots"


/obj/item/clothing/shoes/fluff/noble_boot
	name = "noble boots"
	desc = "The boots are economically designed to balance function and comfort, so that you can step on peasants without having to worry about blisters. The leather also resists unwanted blood stains."
	icon_state = "noble_boot"
	item_color = "noble_boot"
	item_state = "noble_boot"


/obj/item/clothing/shoes/sandal/white
	name = "White Sandals"
	desc = "Medical sandals that nerds wear."
	icon_state = "medsandal"
	item_color = "medsandal"

/obj/item/clothing/shoes/sandal/fancy
	name = "Fancy Sandals"
	desc = "FANCY!!."
	icon_state = "fancysandal"
	item_color = "fancysandal"

/obj/item/clothing/shoes/cursedclown
	name = "cursed clown shoes"
	desc = "Moldering clown flip flops. They're neon green for some reason."
	icon = 'icons/goonstation/objects/clothing/feet.dmi'
	icon_state = "cursedclown"
	item_state = "cclown_shoes"
	onmob_sheets = list(
		ITEM_SLOT_FEET_STRING = 'icons/goonstation/mob/clothing/feet.dmi'
	)
	lefthand_file = 'icons/goonstation/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/goonstation/mob/inhands/clothing_righthand.dmi'
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF


/obj/item/clothing/shoes/cursedclown/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)
	AddComponent(/datum/component/squeak, list('sound/effects/clownstep1.ogg', 'sound/effects/clownstep2.ogg'), 50, falloff_exponent = 20) //die off quick please

/obj/item/clothing/shoes/singery
	name = "yellow performer's boots"
	desc = "These boots were made for dancing."
	icon_state = "ysing"
	put_on_delay = 50

/obj/item/clothing/shoes/singerb
	name = "blue performer's boots"
	desc = "These boots were made for dancing."
	icon_state = "bsing"
	put_on_delay = 50

/obj/item/clothing/shoes/cowboy
	name = "cowboy boots"
	desc = "A pair a' brown boots."
	icon_state = "cowboy_brown"
	item_color = "cowboy_brown"
	pickup_sound = 'sound/items/handling/boots_pickup.ogg'
	drop_sound = 'sound/items/handling/boots_drop.ogg'

/obj/item/clothing/shoes/cowboy/black
	name = "black cowboy boots"
	desc = "A pair a' black rustlers' boots"
	icon_state = "cowboy_black"
	item_color = "cowboy_black"

/obj/item/clothing/shoes/cowboy/white
	name = "white cowboy boots"
	desc = "For the rancher in us all."
	icon_state = "cowboy_white"
	item_color = "cowboy_white"

/obj/item/clothing/shoes/cowboy/fancy
	name = "bilton wrangler boots"
	desc = "A pair of authentic haute couture boots from Japanifornia. You doubt they have ever been close to cattle."
	icon_state = "cowboy_fancy"
	item_color = "cowboy_fancy"

/obj/item/clothing/shoes/cowboy/pink
	name = "pink cowgirl boots"
	desc = "For a Rustlin' tustlin' cowgirl."
	icon_state = "cowboyboots_pink"
	item_color = "cowboyboots_pink"

/obj/item/clothing/shoes/cowboy/lizard
	name = "lizard skin boots"
	desc = "You can hear a faint hissing from inside the boots; you hope it is just a mournful ghost."
	icon_state = "lizardboots_green"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 40, "acid" = 0) //lizards like to stay warm

/obj/item/clothing/shoes/cowboy/lizardmasterwork
	name = "\improper Hugs-The-Feet lizard skin boots"
	desc = "A pair of masterfully crafted lizard skin boots. Finally a good application for the station's most bothersome inhabitants."
	icon_state = "lizardboots_blue"

/obj/effect/spawner/lootdrop/lizardboots
	name = "random lizard boot quality"
	desc = "Which ever gets picked, the lizard race loses"
	icon = 'icons/obj/clothing/shoes.dmi'
	icon_state = "lizardboots_green"
	loot = list(
		/obj/item/clothing/shoes/cowboy/lizard = 7,
		/obj/item/clothing/shoes/cowboy/lizardmasterwork = 1)

/obj/item/clothing/shoes/footwraps
 	name = "cloth footwraps"
 	desc = "A roll of treated canvas used for wrapping claws or paws."
 	icon_state = "clothwrap"
 	item_state = "clothwrap"
 	force = 0
 	silence_steps = TRUE
 	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/shoes/footwraps/yellow
 	name = "yellow cloth footwraps"
 	icon_state = "yellow_wrap"
 	item_state = "yellow_wrap"

/obj/item/clothing/shoes/footwraps/silver
 	name = "silver cloth footwraps"
 	icon_state = "silver_wrap"
 	item_state = "silver_wrap"

/obj/item/clothing/shoes/footwraps/red
 	name = "red cloth footwraps"
 	icon_state = "red_wrap"
 	item_state = "red_wrap"

/obj/item/clothing/shoes/footwraps/blue
 	name = "blue cloth footwraps"
 	icon_state = "blue_wrap"
 	item_state = "blue_wrap"

/obj/item/clothing/shoes/footwraps/black
 	name = "black cloth footwraps"
 	icon_state = "black_wrap"
 	item_state = "black_wrap"

/obj/item/clothing/shoes/footwraps/brown
 	name = "brown cloth footwraps"
 	icon_state = "brown_wrap"
 	item_state = "brown_wrap"

/obj/item/clothing/shoes/footwraps/goliath
	name = "goliath hide footwraps"
	desc = "These wraps, made from goliath hide, make your feet feel snug and secure, while still being breathable and light."
	icon_state = "footwraps_goliath"
	item_state = "footwraps_goliath"
	armor = list("melee" = 5, "bullet" = 5, "laser" = 10, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 10, "acid" = 0)
	resistance_flags = FIRE_PROOF

/obj/item/clothing/shoes/footwraps/dragon
	name = "ash drake hide footwraps"
	desc = "These wraps, made from ash drake hide, make your feet feel snug and secure, while still being breathable and light."
	icon_state = "footwraps_dragon"
	item_state = "footwraps_dragon"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 15, "energy" = 10, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 15, "acid" = 0)
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/shoes/bhop
	name = "jump boots"
	desc = "A specialized pair of combat boots with a built-in propulsion system for rapid foward movement."
	icon_state = "jetboots"
	item_state = "jetboots"
	item_color = "hosred"
	resistance_flags = FIRE_PROOF
	actions_types = list(/datum/action/item_action/bhop)
	permeability_coefficient = 0.05
	can_cut_open = FALSE
	var/jumpdistance = 5 //-1 from to see the actual distance, e.g 4 goes over 3 tiles
	var/jumpspeed = 3
	var/recharging_rate = 60 //default 6 seconds between each dash
	var/recharging_time = 0 //time until next dash
	var/datum/callback/last_jump = null


/obj/item/clothing/shoes/bhop/item_action_slot_check(slot, mob/user, datum/action/action)
	if(slot == ITEM_SLOT_FEET)
		return TRUE


/obj/item/clothing/shoes/bhop/ui_action_click(mob/user, datum/action/action, leftclick)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/jumper = user
	if(jumper.shoes != src)
		to_chat(user, span_warning("You need to wear [src] to use them!"))
		return
	if(recharging_time > world.time)
		to_chat(user, span_warning("The boot's internal propulsion needs to recharge still!"))
		return
	if(user.throwing)
		to_chat(user, span_warning("You can't jump in the middle of another jump!"))
		return
	if(!jumper.has_gravity())
		to_chat(user, span_warning("You can't jump without gravity!"))
		return

	var/atom/target = get_edge_target_turf(user, user.dir) //gets the user's direction

	if(last_jump) //in case we are trying to perfom jumping while first jump was not complete
		last_jump.Invoke()
	ADD_TRAIT(user, TRAIT_MOVE_FLYING, ITEM_JUMP_BOOTS_TRAIT)
	var/after_jump_callback = CALLBACK(src, PROC_REF(after_jump), user)
	if(user.throw_at(target, jumpdistance, jumpspeed, spin = FALSE, diagonals_first = TRUE, callback = after_jump_callback))
		last_jump = after_jump_callback
		playsound(src, 'sound/effects/stealthoff.ogg', 50, 1, 1)
		user.visible_message(span_warning("[user] dashes forward into the air!"))
		recharging_time = world.time + recharging_rate
	else
		to_chat(user, span_warning("Something prevents you from dashing forward!"))
		after_jump(user)


/obj/item/clothing/shoes/bhop/proc/after_jump(mob/user)
	REMOVE_TRAIT(user, TRAIT_MOVE_FLYING, ITEM_JUMP_BOOTS_TRAIT)
	last_jump = null


/obj/item/clothing/shoes/bhop/clown
	desc = "The prankster's standard-issue clowning shoes. Damn they're huge! Ctrl-click to toggle the waddle dampeners!"
	name = "clown shoes"
	icon_state = "clown"
	item_state = "clown_shoes"
	description_antag = "These boots are power-up with a special jumping mechanism that works on the honk-space, allowing you to do excellent acrobatic tricks!"
	slowdown = SHOES_SLOWDOWN+1
	item_color = "clown"
	actions_types = list(/datum/action/item_action/bhop/clown)
	var/enabled_waddle = TRUE
	jumpdistance = 7//-1 from to see the actual distance, e.g 7 goes over 6 tiles

/obj/item/clothing/shoes/bhop/clown/ui_action_click(mob/user, datum/action/action, leftclick)
	user.emote("flip")
	. = ..()

/obj/item/clothing/shoes/bhop/clown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/clownstep1.ogg', 'sound/effects/clownstep2.ogg'), 50, falloff_exponent = 20) //die off quick please

/obj/item/clothing/shoes/bhop/clown/equipped(mob/user, slot, initial)
	. = ..()
	if(slot == ITEM_SLOT_FEET && enabled_waddle)
		user.AddElement(/datum/element/waddling)

/obj/item/clothing/shoes/bhop/clown/dropped(mob/user, silent = FALSE)
	. = ..()
	user.RemoveElement(/datum/element/waddling)

/obj/item/clothing/shoes/bhop/clown/CtrlClick(mob/living/user)
	if(!isliving(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if(user.get_active_hand() != src)
		to_chat(user, "You must hold [src] in your hand to do this.")
		return
	if(!enabled_waddle)
		to_chat(user, "<span class='notice'>You switch off the waddle dampeners!</span>")
		enabled_waddle = TRUE
	else
		to_chat(user, "<span class='notice'>You switch on the waddle dampeners!</span>")
		enabled_waddle = FALSE

/obj/item/clothing/shoes/ducky
	name = "rubber ducky shoes"
	desc = "These shoes are made for quacking, and thats just what they'll do."
	icon_state = "ducky"
	item_state = "ducky"

/obj/item/clothing/shoes/ducky/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/items/squeaktoy.ogg'), 50, falloff_exponent = 20) //die off quick please

/obj/item/clothing/shoes/pathtreads
	name = "pathfinder treads"
	desc = "Massive boots made from chitin, they look hand-crafted."
	icon_state = "pathtreads"
	item_state = "pathtreads"
	body_parts_covered = LEGS|FEET
	resistance_flags = FIRE_PROOF
	heat_protection = LEGS|FEET
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	cold_protection = LEGS|FEET
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/shoes/mr_chang_sandals
	name = "Flashy slippers"
	desc = "Made of wood. Used to support world's economics stable."
	icon_state = "mr_chang_sandals"
	item_state = "mr_chang_sandals"

/obj/item/clothing/shoes/combat/commando //basic syndicate combat boots for nuke ops and mob corpses
	name = "Black military boots"
	desc = "A pair of black military boots. They look really well-made. They have a metal sole, as if specially added to crush bones."
	can_cut_open = FALSE
	icon_state = "commandos_boots"
	item_state = "commandos_boots"

/obj/item/clothing/shoes/leather_boots
	name = "high leather boots"
	desc = "Стройные сапоги сделанные из кожи."
	icon_state = "leather_boots"
	item_state = "leather_boots"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/shoes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/shoes.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/shoes.dmi'
		)

/obj/item/clothing/shoes/reflector
	name = "reflector boots"
	desc = "Довольно легкая хоть и неудобная обувь, сделанная из сплавов высокотехнологичных материалов. Хотя не похоже, что она может защитить то чего-то кроме лазеров."
	icon_state = "reflector"
	item_state = "reflector"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 50, "energy" = 50, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/shoes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/shoes.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/shoes.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/shoes.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/shoes.dmi',
		)
	var/hit_reflect_chance = 50

/obj/item/clothing/shoes/reflector/IsReflect(def_zone)
	if(!(def_zone in list(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)))
		return FALSE
	if (prob(hit_reflect_chance))
		return TRUE
