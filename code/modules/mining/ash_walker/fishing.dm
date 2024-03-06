/*
Fishing bites, fish, fishing related stuff
*/
/obj/item/reagent_containers/food/snacks/bait
	name = "worm"
	desc = "Simple bait for fishing, try to use it on fishing rod!"
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "ash_eater"
	list_reagents = list("protein" = 1) //mmmm tasty
	tastes = list("ash" = 5, "hopelessness" = 1)
	bitesize = 1
	foodtype = MEAT
	var/rod_overlay  = "ash_eater_rod"

/obj/item/reagent_containers/food/snacks/bait/examine(mob/user)
	. = ..()
	. += span_notice("You could use this as a bait for a fishing rod.")


/obj/item/reagent_containers/food/snacks/bait/ash_eater
	name = "ash eater"
	desc = "A tiny worm with a thousand sharp teeth covering its mouth. There are rumors that these crumbs could grow to gigantic sizes. The ash must flow."
	icon_state = "ash_eater"
	rod_overlay = "ash_eater_rod"

/obj/item/reagent_containers/food/snacks/bait/bloody_leach
	name = "bloody leach"
	desc = "A parasitic life form that sucks on the victim with its suckers and feeds on it. Her petite body is covered in red from drinking blood."
	icon_state = "bloody_leach"
	rod_overlay = "bloody_leach_rod"

/obj/item/reagent_containers/food/snacks/bait/goldgrub_larva
	name = "goldgrub larva"
	desc = "A tiny worm that feeds on minerals sprinkled into the ashes. It is just as timid as its adult relatives."
	icon_state = "goldgrub_larva"
	rod_overlay = "goldgrub_larva_rod"

//shrimp. Working little different than standart bait

/obj/item/reagent_containers/food/snacks/charred_krill
	name = "charred krill"
	desc = "One of the rarest inhabitants of Lavaland, considered extinct. This shrimp is one of the most favorite treats for local fish."
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "charred_krill"
	list_reagents = list("protein" = 1)
	bitesize = 1
	tastes = list("ash" = 5, "wasted opportunity" = 1)
	var/in_lava = FALSE

/obj/item/reagent_containers/food/snacks/charred_krill/examine(mob/user)
	. = ..()
	. += span_notice("You could throw it into lava to attract fish onto the surface.")

/obj/item/reagent_containers/food/snacks/charred_krill/can_be_pulled(atom/movable/user, force, show_message)
	if(in_lava)
		if(show_message)
			to_chat(user, span_warning("[src] is almost drowned in lava!"))
		return

/obj/item/reagent_containers/food/snacks/charred_krill/attack_hand(mob/user, pickupfireoverride)
	if(in_lava)
		return
	else
		return ..()

/obj/item/reagent_containers/food/snacks/charred_krill/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is going to krill himself! Oh god...</span>")
	user.say("goodbye krill world.")
	sleep(20)
	var/obj/item/reagent_containers/food/snacks/charred_krill/krill = new /obj/item/reagent_containers/food/snacks/charred_krill(drop_location())
	krill.desc += " Look's like someone KRILLED himself."
	qdel(user)
	return OBLITERATION

// actual fish

/obj/item/lavaland_fish
	name = "generic lavaland fish"
	desc = "Wow, this fish is so unremarkable!"
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "ash_crab"
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	throwforce = 5
	force = 1
	attack_verb = list("slapped", "humiliated", "hit", "rubbed")
	hitsound = 'sound/effects/snap.ogg'

	/// If this fish should do the flopping animation
	var/do_flop_animation = TRUE
	var/flopping = FALSE

	/// Favourite bait. Using this will add more chance to catch this fish
	var/favorite_bait = null

	/// List of items you get after butchering it
	var/list/butcher_loot = list()

/obj/item/lavaland_fish/Initialize(mapload)
	. = ..()
	if(do_flop_animation)
		RegisterSignal(src, COMSIG_ATOM_TEMPORARY_ANIMATION_START, PROC_REF(on_temp_animation))
	START_PROCESSING(SSobj, src)

/obj/item/lavaland_fish/attackby(obj/item/I, mob/living/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	var/sharpness = is_sharp(I)
	if(sharpness && user.a_intent == INTENT_HARM)
		to_chat(user, "<span class='notice'>You begin to butcher [src]...</span>")
		playsound(loc, 'sound/weapons/slice.ogg', 50, 1, -1)
		if(do_mob(user, src, 80 / sharpness) && Adjacent(I))
			harvest(user)
	return ..()

/obj/item/lavaland_fish/proc/harvest(mob/user)
	if(QDELETED(src))
		return
	to_chat(user, "увы.")
	qdel(src)

/obj/item/lavaland_fish/Moved(atom/OldLoc, Dir, Forced)
	. = ..()
	start_flopping()

/obj/item/lavaland_fish/shoreline
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/lavaland_fish/deep_water
	w_class = WEIGHT_CLASS_BULKY

/obj/item/lavaland_fish/shoreline/ash_crab
	name = "ash crab"
	desc = "ворм потом накатает"
	icon_state = "ash_crab"
	favorite_bait = /obj/item/reagent_containers/food/snacks/bait/ash_eater

/obj/item/lavaland_fish/shoreline/dead_horseman
	name = "dead horseman"
	desc = "ворм потом накатает"
	icon_state = "dead_horseman"
	favorite_bait = /obj/item/reagent_containers/food/snacks/bait/bloody_leach

/obj/item/lavaland_fish/shoreline/shellfish
	name = "shellfish"
	desc = "ворм потом накатает"
	icon_state = "shellfish"
	favorite_bait = /obj/item/reagent_containers/food/snacks/bait/goldgrub_larva

/obj/item/lavaland_fish/deep_water/bottom_eel
	name = "bottom eel"
	desc = "ворм потом накатает"
	icon_state = "bottom_eel"
	favorite_bait = /obj/item/reagent_containers/food/snacks/bait/ash_eater

/obj/item/lavaland_fish/deep_water/red_devouver
	name = "red devouver"
	desc = "ворм потом накатает"
	icon_state = "red_devouver"
	favorite_bait = /obj/item/reagent_containers/food/snacks/bait/bloody_leach

/obj/item/lavaland_fish/deep_water/magma_hammerhead
	name = "magma hammerhead"
	desc = "ворм потом накатает"
	icon_state = "magma_hammerhead"
	favorite_bait = /obj/item/reagent_containers/food/snacks/bait/goldgrub_larva

/obj/item/lavaland_fish/deep_water/blind_ripper
	name = "blind ripper"
	desc = "ворм потом накатает"
	icon_state = "blind_ripper"
	favorite_bait = /obj/item/reagent_containers/food/snacks/bait/ash_eater

/obj/item/lavaland_fish/deep_water/herald_of_carnage
	name = "herald of carnage"
	desc = "ворм потом накатает"
	icon_state = "herald_of_carnage"
	favorite_bait = /obj/item/reagent_containers/food/snacks/bait/bloody_leach

/obj/item/lavaland_fish/deep_water/sulfuric_tramp
	name = "sulfuric tramp"
	desc = "ворм потом накатает"
	icon_state = "sulfuric_tramp"
	favorite_bait = /obj/item/reagent_containers/food/snacks/bait/goldgrub_larva

// Fish flopping

#define PAUSE_BETWEEN_PHASES 15
#define PAUSE_BETWEEN_FLOPS 2
#define FLOP_COUNT 2
#define FLOP_DEGREE 20
#define FLOP_SINGLE_MOVE_TIME 1.5
#define JUMP_X_DISTANCE 5
#define JUMP_Y_DISTANCE 6
/// This animation should be applied to actual parent atom instead of vc_object.
/proc/flop_animation(atom/movable/animation_target)
	var/pause_between = PAUSE_BETWEEN_PHASES + rand(1, 5) //randomized a bit so fish are not in sync
	animate(animation_target, time = pause_between, loop = -1)
	//move nose down and up
	for(var/_ in 1 to FLOP_COUNT)
		var/matrix/up_matrix = matrix()
		up_matrix.Turn(FLOP_DEGREE)
		var/matrix/down_matrix = matrix()
		down_matrix.Turn(-FLOP_DEGREE)
		animate(transform = down_matrix, time = FLOP_SINGLE_MOVE_TIME, loop = -1)
		animate(transform = up_matrix, time = FLOP_SINGLE_MOVE_TIME, loop = -1)
		animate(transform = matrix(), time = FLOP_SINGLE_MOVE_TIME, loop = -1, easing = BOUNCE_EASING | EASE_IN)
		animate(time = PAUSE_BETWEEN_FLOPS, loop = -1)
	//bounce up and down
	animate(time = pause_between, loop = -1, flags = ANIMATION_PARALLEL)
	var/jumping_right = FALSE
	var/up_time = 3 * FLOP_SINGLE_MOVE_TIME / 2
	for(var/_ in 1 to FLOP_COUNT)
		jumping_right = !jumping_right
		var/x_step = jumping_right ? JUMP_X_DISTANCE/2 : -JUMP_X_DISTANCE/2
		animate(time = up_time, pixel_y = JUMP_Y_DISTANCE , pixel_x=x_step, loop = -1, flags= ANIMATION_RELATIVE, easing = BOUNCE_EASING | EASE_IN)
		animate(time = up_time, pixel_y = -JUMP_Y_DISTANCE, pixel_x=x_step, loop = -1, flags= ANIMATION_RELATIVE, easing = BOUNCE_EASING | EASE_OUT)
		animate(time = PAUSE_BETWEEN_FLOPS, loop = -1)
#undef PAUSE_BETWEEN_PHASES
#undef PAUSE_BETWEEN_FLOPS
#undef FLOP_COUNT
#undef FLOP_DEGREE
#undef FLOP_SINGLE_MOVE_TIME
#undef JUMP_X_DISTANCE
#undef JUMP_Y_DISTANCE

/// Starts flopping animation
/obj/item/lavaland_fish/proc/start_flopping()
	if(flopping)  //Requires update_transform/animate_wrappers to be less restrictive.
		return
	flopping = TRUE
	flop_animation(src)

/// Stops flopping animation
/obj/item/lavaland_fish/proc/stop_flopping()
	if(flopping)
		flopping = FALSE
		animate(src, transform = matrix()) //stop animation

/// Refreshes flopping animation after temporary animation finishes
/obj/item/lavaland_fish/proc/on_temp_animation(datum/source, animation_duration)
	if(animation_duration > 0)
		addtimer(CALLBACK(src, PROC_REF(refresh_flopping)), animation_duration)

/obj/item/lavaland_fish/proc/refresh_flopping()
	if(flopping)
		flop_animation(src)

/*
Fish loot!
meat, whetstone, street wear, armor components, other strange shit
*/

//meat
/obj/item/reagent_containers/food/snacks/monstermeat/fish_meat
	name = "soft meat cut"
	desc = "мягкое мяско из низших рыбок."
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "soft_meat"
	list_reagents = list("protein" = 3, "vitamin" = 1)
	tastes = list("soft meat" = 1)
	foodtype = MEAT | RAW

//whetstone
/obj/item/whetstone/crab_shell
	name = "sturdy crab shell"
	desc = "маленький панцирь, достаточно крепкий, чтобы выдержать несколько сессий заточки оружия."
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = crab_shell
	increment = 2
	infinity_use = TRUE

//generic lavaland item
/obj/item/abstract_lavaland_item
	name = "abstract item from lavaland"
	desc = "if you see it, contact to a coder."
	var/list/whitelist_for_spawn = list(
		/obj/item/stack/fireproof_rods,
		/obj/item/mining_scanner,
		/obj/item/radio/weather_monitor,
		/obj/item/stack/sheet/animalhide/goliath_hide
	)

/obj/item/abstract_lavaland_item/Initialize(mapload)
	. = ..()
	var/new_item = pick(whitelist_for_spawn)
	new new_item(loc)
	qdel(src)

//helmet
/obj/item/clothing/head/helmet/scorched_skull
	name = "scorched skull"
	desc = "Череп рыбы. Не совсем удобный, и мешает нормально видеть окрестности."
	flags_inv = HIDEMASK|HIDEHEADSETS|HIDEGLASSES|HIDENAME
	flags_cover = HEADCOVERSEYES
	armor = list("melee" = 35, "bullet" = 25, "laser" = 25, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	icon_state = "scorched_skull"
	item_state = "scorched_skull"
	tint = 2


//crafting hide
/obj/item/stack/sheet/animalhide/cartilage_plate
	name = "thick cartilage plate"
	desc = "Кусок панциря рыбы, достаточно крепкий, чтобы из него можно было делать неплохую броню."
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "cartilage_plate"

//robust harvest +
/obj/item/reagent_containers/food/snacks/fish_sack
	name = "conductive organ"
	desc = "Мешочек с рыбьими потрохами или типа того. Сильнодействующий на растения реагент, ужасающе токсичный."
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "fish_sack"
	list_reagents = list("lavalandtnutriment" = 5) //mmmm tasty
	tastes = list("poison" = 5, "hopelessness" = 1)
	bitesize = 1

//crafting materials

/obj/item/eel_tail
	name = "eel sharpened tail"
	desc = "Хвост угря. Используется в рецептах. Такие дела."
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "eel_tail"
	w_class = WEIGHT_CLASS_TINY

/obj/item/sharp_teeth
	name = "razor sharp teeth"
	desc = "Зубы рыбы. Используется в рецептах. Такие дела."
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "teeth"
	w_class = WEIGHT_CLASS_TINY

/obj/item/saw_blade
	name = "circular saw blade"
	desc = "Гигантская пила. Используется в рецептах. Такие дела."
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "saw_blade"
	w_class = WEIGHT_CLASS_TINY

/obj/item/hivelordstabilizer/fish
	name = "gooey molten mass"
	desc = "Рескин стабилизатора ядер. Эти описания - временные, если что. Если вы их видите, зюзя дебил."
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "molten mass"
	luminosity = 1
	light_power = 1
	light_range = 1.6

//ore scanner
/obj/item/t_scanner/adv_mining_scanner/fish
	name = "bleary eye"
	desc = "глаз. Видит руду. Видит быстро в малом радиусе. Прикольно."
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "bleary_eye1"
	range = 4
	cooldown = 0.5 SECONDS
	speaker = FALSE
	origin_tech = null

/obj/item/t_scanner/adv_mining_scanner/fish/Initialize(mapload)
	. = ..()
	on = TRUE
	START_PROCESSING(SSobj, src)

/obj/item/t_scanner/adv_mining_scanner/fish/toggle_mode()
	return

//
