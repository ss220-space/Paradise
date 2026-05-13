/*
 * Balloons
 */
/obj/item/toy/waterballoon
	name = "water balloon"
	desc = "A translucent balloon. There's nothing in it."
	icon = 'icons/obj/toys/balloons.dmi'
	icon_state = "balloon_red-e"
	item_state = "waterballoon-e"

/obj/item/toy/waterballoon/Initialize(mapload)
	. = ..()
	create_reagents(10)

/obj/item/toy/waterballoon/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED

/obj/item/toy/waterballoon/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(!proximity_flag)
		return

	if(istype(target, /obj/structure/reagent_dispensers))
		var/obj/structure/reagent_dispensers/RD = target
		if(RD.reagents.total_volume <= 0)
			to_chat(user, span_warning("[DECLENT_RU_CAP(RD, NOMINATIVE)] пустой."))
		else if(reagents.total_volume >= 10)
			to_chat(user, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] полный."))
		else
			user.changeNext_move(CLICK_CD_MELEE)
			target.reagents.trans_to(src, 10)
			to_chat(user, span_notice("Вы наполняете шарик из [target.declent_ru(GENITIVE)]."))
			desc = "A translucent balloon with some form of liquid sloshing around in it."
			update_icon(UPDATE_ICON_STATE)

/obj/item/toy/waterballoon/wash(mob/user, atom/source)
	if(reagents.total_volume < 10)
		reagents.add_reagent("water", min(10-reagents.total_volume, 10))
		to_chat(user, span_notice("Вы наполняете шарик из [source.declent_ru(GENITIVE)]."))
		desc = "A translucent balloon with some form of liquid sloshing around in it."
		update_icon(UPDATE_ICON_STATE)

/obj/item/toy/waterballoon/attackby(obj/item/I, mob/user, params)
	if(isglassreagentcontainer(I) || istype(I, /obj/item/reagent_containers/food/drinks/drinkingglass))
		add_fingerprint(user)
		if(!I.reagents || I.reagents.total_volume < 1)
			to_chat(user, span_warning("[DECLENT_RU_CAP(I, NOMINATIVE)] пуст!"))
			return ATTACK_CHAIN_PROCEED
		if(I.reagents.has_reagent("facid", 1) || I.reagents.has_reagent("acid", 1))
			to_chat(user, span_warning("Кислота прожигает шарик!"))
			I.reagents.reaction(user)
			qdel(src)
			return ATTACK_CHAIN_BLOCKED_ALL
		desc = "A translucent balloon with some form of liquid sloshing around in it."
		to_chat(user, span_notice("Вы наполняете шарик из [I.declent_ru(GENITIVE)]."))
		I.reagents.trans_to(src, 10)
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/item/toy/waterballoon/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..()) //was it caught by a mob?
		balloon_burst(hit_atom)

/obj/item/toy/waterballoon/proc/balloon_burst(atom/AT)
	if(!reagents || reagents.total_volume < 1)
		return

	var/turf/turf
	if(AT)
		turf = get_turf(AT)
	else
		turf = get_turf(src)

	turf.visible_message(span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] лопается!"), "Вы слышите хлопок и всплеск.")
	reagents.reaction(turf)

	for(var/atom/atom in turf)
		reagents.reaction(atom)

	icon_state = "burst"
	qdel(src)

/obj/item/toy/waterballoon/update_icon_state()
	if(reagents.total_volume >= 1)
		icon_state = "waterballoon"
		item_state = "waterballoon"
	else
		icon_state = "balloon_red-e"
		item_state = "waterballoon-e"
	return ..()

#define BALLOON_COLORS list("red", "blue", "green", "yellow", "orange", "purple")

/obj/item/toy/balloon
	name = "balloon"
	desc = "No birthday is complete without it. Sealed with a mechanical bluespace wrap so it remains floating no matter what."
	icon = 'icons/obj/toys/balloons.dmi'
	icon_state = "balloon"
	item_state = "balloon"
	lefthand_file = 'icons/mob/inhands/balloons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/balloons_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	force = 0
	var/random_color = TRUE
	/// the string describing the name of balloon's current colour.
	var/current_color

/obj/item/toy/balloon/long
	name = "long balloon"
	desc = "A perfect balloon to contort into goofy forms. Sealed with a mechanical bluespace wrap so it remains floating no matter what."
	icon_state = "balloon_long"
	item_state = "balloon"
	w_class = WEIGHT_CLASS_NORMAL
	/// Combinations of balloon colours to make specific animals.
	var/list/balloon_combos = list(
		list("red", "blue") = /obj/item/toy/balloon_animal/guy,
		list("red", "green") = /obj/item/toy/balloon_animal/nukie,
		list("red", "yellow") = /obj/item/toy/balloon_animal/clown,
		list("red", "orange") = /obj/item/toy/balloon_animal/cat,
		list("red", "purple") = /obj/item/toy/balloon_animal/fly,
		list("blue", "green") = /obj/item/toy/balloon_animal/podguy,
		list("blue", "yellow") = /obj/item/toy/balloon_animal/ai,
		list("blue", "orange") = /obj/item/toy/balloon_animal/dog,
		list("blue", "purple") = /obj/item/toy/balloon_animal/xeno,
		list("green", "yellow") = /obj/item/toy/balloon_animal/banana,
		list("green", "orange") = /obj/item/toy/balloon_animal/lizard,
		list("green", "purple") = /obj/item/toy/balloon_animal/slime,
		list("yellow", "orange") = /obj/item/toy/balloon_animal/moth,
		list("orange", "purple") = /obj/item/toy/balloon_animal/plasmaman,
	)


/obj/item/toy/balloon/long/attackby(obj/item/attacking_item, mob/living/user, list/modifiers, list/attack_modifiers)
	if(!istype(attacking_item, /obj/item/toy/balloon/long))
		return ..()

	var/obj/item/toy/balloon/long/hit_by = attacking_item
	if(hit_by.current_color == current_color)
		to_chat(user, span_warning("You must use balloons of different colours to do that!"))
		return ..()
	visible_message(
		span_notice("[user.name] starts contorting up a balloon animal!"),
		blind_message = span_hear("You hear balloons being contorted."),
		vision_distance = 3,
		ignored_mobs = user,
	)
	for(var/list/pair_of_colors in balloon_combos)
		if((hit_by.current_color == pair_of_colors[1] && current_color == pair_of_colors[2]) || (current_color == pair_of_colors[1] && hit_by.current_color == pair_of_colors[2]))
			var/path_to_spawn = balloon_combos[pair_of_colors]
			user.put_in_hands(new path_to_spawn)
			break
	qdel(hit_by)
	qdel(src)
	return TRUE

/obj/item/toy/balloon/attackby(obj/item/I, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(I, /obj/projectile/bullet/reusable/foam_dart) && ismonkey(user))
		pop_balloon(monkey_pop = TRUE)
	else
		return ..()

/obj/item/toy/balloon/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	var/mob/thrower = throwingdatum?.thrower
	if(ismonkey(thrower) && istype(AM, /obj/projectile/bullet/reusable/foam_dart))
		pop_balloon(monkey_pop = TRUE)
	else
		return ..()

/obj/item/toy/balloon/bullet_act(obj/projectile/proj)
	if((istype(proj, /obj/projectile/bullet/) || istype(proj, /obj/projectile/bullet/reusable/foam_dart)) && ismonkey(proj.firer))
		pop_balloon(monkey_pop = TRUE)
	return ..()

/obj/item/toy/balloon/proc/pop_balloon(monkey_pop = FALSE)
	playsound(src, 'sound/effects/cartoon_sfx/cartoon_pop.ogg', 50, vary = TRUE)
	if(monkey_pop) // Monkeys make money from popping bloons
		new /obj/item/coin/iron(get_turf(src))
	qdel(src)

/obj/item/toy/balloon/Initialize(mapload)
	. = ..()
	if(!random_color)
		return
	current_color = pick(BALLOON_COLORS)
	update_appearance()

/obj/item/toy/balloon/update_name(updates)
	. = ..()
	name = "[current_color ? "[current_color] ":null][initial(name)]"

/obj/item/toy/balloon/vv_edit_var(vname, vval)
	. = ..()
	if(vname == NAMEOF(src, current_color))
		update_appearance()

/obj/item/toy/balloon/update_icon_state()
	. = ..()
	var/new_icon = "[initial(icon_state)][current_color ? "_[current_color]":null]"
	item_state = new_icon
	icon_state = "[new_icon][isturf(loc) ? null : "_storage"]"

/obj/item/toy/balloon/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	update_appearance()

/obj/item/toy/balloon/corgi
	name = "corgi balloon"
	desc = "A balloon in the shape of a corgi's head. For the all year good boys."
	icon_state = "corgi"
	item_state = "corgi"
	random_color = FALSE

/obj/item/toy/balloon/heart
	name = "heart balloon"
	desc = "A balloon in the shape of a heart. How lovely"
	icon_state = "heart"
	item_state = "heart"
	random_color = FALSE

/obj/item/toy/balloon/syndicate
	name = "syndicate balloon"
	desc = "There is a tag on the back that reads \"FUK NT!11!\"."
	icon_state = "syndballoon"
	item_state = "syndballoon"
	random_color = FALSE

/obj/item/toy/balloon/contractor
	name = "contractor balloon"
	desc = "Черно-золотой шар, который носят только легендарные агенты \"Синдиката\"."
	gender = MALE
	icon_state = "contractorballoon"
	item_state = "contractorballoon"
	random_color = FALSE

/obj/item/toy/balloon/contractor/get_ru_names()
	return list(
		NOMINATIVE = "воздушный шарик контрактника",
		GENITIVE = "воздушного шарика контрактника",
		DATIVE = "воздушному шарику контрактника",
		ACCUSATIVE = "воздушный шарик контрактника",
		INSTRUMENTAL = "воздушным шариком контрактника",
		PREPOSITIONAL = "воздушном шарике контрактника",
	)

/obj/item/toy/balloon/arrest
	name = "arreyst balloon"
	desc = "A half inflated balloon about a boyband named Arreyst that was popular about ten years ago, famous for making fun of red jumpsuits as unfashionable."
	icon_state = "arrestballoon"
	item_state = "arrestballoon"
	random_color = FALSE

#undef BALLOON_COLORS

/*
* Balloon animals
*/

/obj/item/toy/balloon_animal
	name = "balloon animal"
	desc = "You shouldn't have this."
	icon = 'icons/obj/toys/balloons.dmi'
	item_state = "balloon"
	lefthand_file = 'icons/mob/inhands/balloons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/balloons_righthand.dmi'
	abstract_type = /obj/item/toy/balloon_animal
	throwforce = 0
	throw_speed = 2
	throw_range = 5
	force = 0

/obj/item/toy/balloon_animal/guy
	name = "balloon guy"
	desc = "A balloon effigy of the everyday standard issue human guy. Wonder if he pays balloon taxes. He probably evades them."
	icon_state = "balloon_guy"

/obj/item/toy/balloon_animal/nukie
	name = "balloon nukie"
	desc = "A balloon effigy of syndicate's nuclear operative. Either made to appease them and pray for survival, or to poke fun at them."
	icon_state = "balloon_nukie"

/obj/item/toy/balloon_animal/clown
	name = "balloon clown"
	desc = "A balloon clown, smiling from ear to ear and beyond!"
	icon_state = "balloon_clown"

/obj/item/toy/balloon_animal/cat
	name = "balloon cat"
	desc = "Without the sharp claws, balloon cats are possibly cuter than their live counterparts, though not as relatable, warm and fuzzy."
	icon_state = "balloon_cat"

/obj/item/toy/balloon_animal/fly
	name = "balloon fly"
	desc = "A balloon effigy of a flyperson. Thankfully, it doesn't come with balloon vomit."
	icon_state = "balloon_fly"

/obj/item/toy/balloon_animal/podguy
	name = "balloon podguy"
	desc = "A balloon effigy of a podperson. Though, actual podpeople have heads and not stalks and leaves."
	icon_state = "balloon_podguy"

/obj/item/toy/balloon_animal/ai
	name = "balloon ai core"
	desc = "A somewhat unrealistic balloon effigy of the station's AI core. Actual AI probably wouldn't smile like this."
	icon_state = "balloon_ai"

/obj/item/toy/balloon_animal/dog
	name = "balloon dog"
	desc = "A balloon effigy of the best boy. It cannot truly compare, but it makes an effort."
	icon_state = "balloon_dog"

/obj/item/toy/balloon_animal/xeno
	name = "balloon xeno"
	desc = "A balloon effigy of a spooky xeno! Too squishy to scare anyone itself, though."
	icon_state = "balloon_xeno"

/obj/item/toy/balloon_animal/banana
	name = "balloon banana"
	desc = "A balloon banana. This one can't be slipped on. Good for psychological warfare, though."
	icon_state = "balloon_banana"

/obj/item/toy/balloon_animal/lizard
	name = "balloon lizard"
	desc = "A balloon effigy of a lizard. One of the first species to adapt to clown planet's culture. Perhaps because they are naturally laughable?"
	icon_state = "balloon_lizard"

/obj/item/toy/balloon_animal/slime
	name = "balloon slime"
	desc = "A balloon effigy of single specimen of the galaxy-wide slime scourge, of purple variety. Slimes tried to invade clown planet once. They got quickly washed out by water-spitting flowers, though."
	icon_state = "balloon_slime"

/obj/item/toy/balloon_animal/moth
	name = "balloon moth"
	desc = "A balloon effigy of a common member of moth flotillas. Very few of them ever decide to settle on the clown planet, but those who do have the best 'piece-of-cloth-disappearing' acts."
	icon_state = "balloon_moth"

/obj/item/toy/balloon_animal/plasmaman
	name = "balloon plasmaman"
	desc = "A balloon effigy of a plasmaman. Among the rarest on the clown planet, only having appeared recently thanks to ready trade between clown planet and NT."
	icon_state = "balloon_plasmaman"
