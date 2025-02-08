#define BAIT_AFFECT 80

//Fishing rode and related stuff

/obj/item/twohanded/fishing_rod
	name = "ol' reliable"
	ru_names = list(
		NOMINATIVE = "старая добрая удочка",
		GENITIVE = "старой доброй удочки",
		DATIVE = "старой доброй удочке",
		ACCUSATIVE = "старую добрую удочку",
		INSTRUMENTAL = "старой доброй удочкой",
		PREPOSITIONAL = "старой доброй удочке"
	)
	desc = "О! Кажется, я поймал шахтера!"
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	lefthand_file = 'icons/mob/inhands/lavaland/lava_items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/lava_items_righthand.dmi'
	icon_state = "fishing_rod"
	item_state = "fishing_rod"
	w_class = WEIGHT_CLASS_BULKY
	/// Used in sanity checks in order to avoid bugs
	var/fishing = FALSE
	/// What type of bait do we use?
	var/obj/item/reagent_containers/food/snacks/bait/bait = null

	var/static/mutable_appearance/bobber = mutable_appearance('icons/obj/fish_items.dmi',"bobber")

	var/datum/component/simple_fishing/fishing_component

	var/mob/fisher
	/// Actual fish that we catch
	var/reward_fish = null

/obj/item/twohanded/fishing_rod/tribal
	name = "fishing rod"
	ru_names = list(
		NOMINATIVE = "удочка",
		GENITIVE = "удочки",
		DATIVE = "удочке",
		ACCUSATIVE = "удочку",
		INSTRUMENTAL = "удочкой",
		PREPOSITIONAL = "удочке"
	)
	desc = "Примитивная костяная удочка, использующая сухожилия наблюдателя в качестве высокопрочной лески. Не совсем понятно, почему эта \"леска\" не плавится в лаве."
	icon_state = "tribal_rod"
	item_state = "tribal_rod"

/obj/item/twohanded/fishing_rod/Destroy()
	. = ..()
	QDEL_NULL(bait)

/obj/item/twohanded/fishing_rod/examine(mob/user)
	. = ..()
	if(bait)
		. += span_notice("на крючке находится [bait.declent_ru(NOMINATIVE)].")
		. += span_notice("Вы можете снять наживку с помощью комбинации \"Alt+click\".")

/obj/item/twohanded/fishing_rod/update_icon_state()
	. = ..()
	if(!bait)
		cut_overlays()

/obj/item/twohanded/fishing_rod/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return

	var/datum/component/simple_fishing/fish_component = target.GetComponent(/datum/component/simple_fishing)

	if(!fish_component)
		return ..()

	if(!fishing)
		if(!HAS_TRAIT(src, TRAIT_WIELDED))
			to_chat(user, span_warning("Вам необходимо взять удочку в обе руки перед тем, как её использовать!"))
			return
		fishing = TRUE
		start_fishing(fish_component, user)
	else
		if(fish_component != fishing_component)
			to_chat(user, span_warning("Вы уже рыбачите в другом месте!"))
			return

/obj/item/twohanded/fishing_rod/proc/start_fishing(datum/component/simple_fishing/fc, mob/user)
	if(!bait)
		to_chat(user, span_warning("Будет глупо рыбачить без наживки."))
		fishing = FALSE
		return

	fishing_component = fc
	fisher = user
	var/turf/fishing_turf = fishing_component.parent
	fishing_turf.add_overlay(bobber)
	to_chat(user, span_notice("Вы начали рыбачить."))

	if(do_after(fisher, 10 SECONDS, target = fishing_turf, max_interact_count = 1))
		catch_fish()
		fishing = FALSE
		fishing_turf.cut_overlay(bobber)
	else
		to_chat(user, span_warning("Вам нужно стоять смирно для рыбалки!"))
		fishing_turf.cut_overlay(bobber)
		fishing = FALSE
		return

/obj/item/twohanded/fishing_rod/proc/catch_fish()
	if(!fisher) //uh oh
		return

	if(!bait) //double check
		return

	calculate_fishing_chance()
	var/obj/item/fish =  new reward_fish(loc)
	to_chat(fisher, span_notice("Вы поймали [fish.declent_ru(ACCUSATIVE)]!"))

	unwield(fisher)
	fisher.put_in_hands(fish)
	bait = null
	update_icon(UPDATE_OVERLAYS)

/obj/item/twohanded/fishing_rod/proc/calculate_fishing_chance() // I fucking hate it
	var/list/fishable_list = fishing_component.catchable_fish.Copy()
	var/list/bait_list = list()

	for(var/fish in fishable_list) //After this stage, bait_list will have 1-2 fish in bait_list
		var/obj/item/lavaland_fish/cooler_fish = fish
		if(bait.type == cooler_fish.favorite_bait)
			fishable_list -= cooler_fish
			bait_list += cooler_fish
	if(isemptylist(bait_list)) //if something went wrong and list is empty
		reward_fish = pick(fishable_list)
		return

	if(prob(BAIT_AFFECT))
		reward_fish = pick(bait_list)
	else
		reward_fish = pick(fishable_list)

/obj/item/twohanded/fishing_rod/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/reagent_containers/food/snacks/bait))
		return ATTACK_CHAIN_PROCEED

	if(bait)
		to_chat(user, span_warning("На удочке уже есть наживка!"))
		return ATTACK_CHAIN_PROCEED

	var/obj/item/reagent_containers/food/snacks/bait/worm = I
	if(!user.drop_transfer_item_to_loc(I, src))
		return ATTACK_CHAIN_PROCEED
	bait = worm
	to_chat(user, span_notice("Вы насадили [worm.declent_ru(ACCUSATIVE)] на крючок."))
	update_icon(UPDATE_OVERLAYS)
	return ATTACK_CHAIN_PROCEED_SUCCESS


/obj/item/twohanded/fishing_rod/AltClick(mob/user)
	if(bait)
		user.put_in_hands(bait)
		to_chat(user, span_notice("Вы сняли [bait.declent_ru(ACCUSATIVE)] с крючка."))
		bait = null
		update_icon(UPDATE_OVERLAYS)

/obj/item/twohanded/fishing_rod/update_overlays()
	. = ..()
	cut_overlays()
	if(bait)
		add_overlay(bait.rod_overlay)

#undef BAIT_AFFECT
