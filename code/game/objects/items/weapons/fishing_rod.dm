#define BAIT_AFFECT 80

//Fishing rode and related stuff

/obj/item/twohanded/fishing_rod
	name = "ol' reliable"
	desc = "Старая, видавшая виды удочка. Если она прослужила так долго и ещё не развалилась - вам точно не следует волноваться о её надёжности."
	ru_names = list(
		NOMINATIVE = "старая удочка",
		GENITIVE = "старой удочки",
		DATIVE = "старой удочке",
		ACCUSATIVE = "старую удочку",
		INSTRUMENTAL = "старой удочкой",
		PREPOSITIONAL = "старой удочке"
	)
	gender = FEMALE
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

	var/throw_sound = 'sound/objects/fishing_rod_throw.ogg'
	var/catch_sound = 'sound/objects/fishing_rod_catch.ogg'

/obj/item/twohanded/fishing_rod/tribal
	name = "fishing rod"
	desc = "Примитивная костяная удочка, использующая сухожилия наблюдателя в качестве высокопрочной лески. Не совсем понятно, почему эта \"леска\" не плавится в лаве."
	ru_names = list(
		NOMINATIVE = "удочка",
		GENITIVE = "удочки",
		DATIVE = "удочке",
		ACCUSATIVE = "удочку",
		INSTRUMENTAL = "удочкой",
		PREPOSITIONAL = "удочке"
	)
	icon_state = "tribal_rod"
	item_state = "tribal_rod"

/obj/item/twohanded/fishing_rod/Destroy()
	. = ..()
	QDEL_NULL(bait)

/obj/item/twohanded/fishing_rod/examine(mob/user)
	. = ..()
	if(bait)
		. += span_notice("на крючке наход[pluralize_ru(bait.gender, "ит", "ят")]ся [bait.declent_ru(NOMINATIVE)].")
		. += span_notice("Вы можете снять наживку, используя <b>Alt + ЛКМ</b>.")

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
			balloon_alert(user, "необходим двуручный хват!")
			return
		fishing = TRUE
		start_fishing(fish_component, user)
	else
		if(fish_component != fishing_component)
			balloon_alert(user, "вы уже рыбачите!")
			return

/obj/item/twohanded/fishing_rod/proc/start_fishing(datum/component/simple_fishing/fc, mob/user)
	if(!bait)
		balloon_alert(user, "вам нужна наживка!")
		fishing = FALSE
		return

	fishing_component = fc
	fisher = user
	var/turf/fishing_turf = fishing_component.parent
	fishing_turf.add_overlay(bobber)
	playsound(src, throw_sound, 30)
	to_chat(user, span_notice("Вы начали рыбачить."))

	if(do_after(fisher, 10 SECONDS, target = fishing_turf, max_interact_count = 1))
		if(prob(20))
			to_chat(user, span_warning("Рыба сорвалась вместе с наживкой! Чёрт!"))
			fishing = FALSE
			fishing_turf.cut_overlay(bobber)
			bait = null
			return

		catch_fish()
		playsound(src, catch_sound, 30)
		fishing = FALSE
		fishing_turf.cut_overlay(bobber)
	else
		balloon_alert(user, "вам нужна стоять на месте!")
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
		balloon_alert(user, "наживка уже на удочке!")
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
