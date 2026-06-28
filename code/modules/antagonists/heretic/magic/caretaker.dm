// Последнее пристанище смотрителя (Caretaker's Last Refuge) — reworked into a jaunt (Paradise-original,
// improving on tg's intangible status-effect version). Built on the Space Crawl jaunt, but instead of
// requiring a space/low-pressure turf, the gate is "nobody is watching you":
//   * You may only ENTER the Refuge while no conscious onlooker can see you.
//   * You may only EXIT (resurface) on a spot no conscious onlooker can see.
// While phased you are intangible and unable to act, exactly like the Space Crawl. The jaunt model
// (the floating holder + position indicator) is intentionally kept identical to Space Crawl for now - a
// bespoke caretaker visual will come later. Because the parent's can_cast early-returns TRUE while jaunting,
// the cooldown never traps you inside: you can resurface the instant you reach an unwatched spot.
/obj/effect/proc_holder/spell/jaunt/space_crawl/caretaker
	name = "Последнее пристанище смотрителя"
	desc = "Скрывает вас в Убежище Смотрителя, делая прозрачным и неосязаемым. \
			Войти можно, только пока вас никто не видит; выйти — лишь там, где вас никто не видит. \
			В убежище вы неуязвимы, но не можете действовать."
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "caretaker"
	base_cooldown = 2 SECONDS
	invalid_turf_message = "За вами наблюдают — вы не можете скрыться!"
	jaunt_type = /obj/effect/dummy/spell_jaunt/caretaker
	jaunt_hand_type = /obj/item/space_crawl/caretaker


/// The Refuge's "valid turf" is any spot where no conscious onlooker can see us. Used for both entering
/// (while we are visible) and resurfacing (checks the spot we would reappear on).
/obj/effect/proc_holder/spell/jaunt/space_crawl/caretaker/is_valid_turf(mob/user = usr)
	var/turf/our_turf = get_turf(user)
	if(!our_turf)
		return FALSE
	for(var/mob/living/watcher in viewers(7, our_turf))
		if(watcher == user || watcher.stat == DEAD || !watcher.client)
			continue
		return FALSE
	return TRUE


/// Jaunt holder for the Caretaker's Refuge. The holder itself is invisible; this only defines the
/// position-indicator the jaunter sees (a pulsing eldritch crystal, in icons/effects/eldritch.dmi).
/obj/effect/dummy/spell_jaunt/caretaker
	phased_mob_icon = 'icons/effects/eldritch.dmi'
	phased_mob_icon_state = "caretaker"
	movespeed = 0


/// Renamed jaunt "hands" for the Refuge - same purpose as the Space Crawl hands (block all hand use while
/// phased), just flavoured for the Caretaker instead of reading "космический сдвиг".
/obj/item/space_crawl/caretaker
	name = "нечестивая дымка"
	desc = "Пока вы скрыты в Убежище Смотрителя, ваши руки бесплотны и ни на что не способны."


/obj/item/space_crawl/caretaker/get_ru_names()
	return alist(
		NOMINATIVE = "нечестивая дымка",
		GENITIVE = "нечестивой дымки",
		DATIVE = "нечестивой дымке",
		ACCUSATIVE = "нечестивую дымку",
		INSTRUMENTAL = "нечестивой дымкой",
		PREPOSITIONAL = "нечестивой дымке",
	)
