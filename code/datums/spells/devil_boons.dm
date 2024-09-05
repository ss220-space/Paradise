/obj/effect/proc_holder/spell/summon_wealth
	name = "Summon wealth"
	desc = "The reward for selling your soul."
	school = "conjuration"
	clothes_req = FALSE
	base_cooldown = 10 SECONDS
	cooldown_min = 1 SECONDS
	action_icon_state = "moneybag"


/obj/effect/proc_holder/spell/summon_wealth/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.range = 7
	return T


/obj/effect/proc_holder/spell/summon_wealth/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/C in targets)
		if(user.drop_from_active_hand())
			var/obj/item = pick(
					new /obj/item/coin/gold(user.loc),
					new /obj/item/coin/diamond(user.loc),
					new /obj/item/coin/silver(user.loc),
					new /obj/item/stack/sheet/mineral/gold(user.loc),
					new /obj/item/stack/sheet/mineral/silver(user.loc),
					new /obj/item/stack/sheet/mineral/diamond(user.loc),
					new /obj/item/stack/spacecash/c1000(user.loc))
			C.put_in_active_hand(item)


/obj/effect/proc_holder/spell/view_range
	name = "Distant vision"
	desc = "The reward for selling your soul."
	clothes_req = FALSE
	base_cooldown = 5 SECONDS
	cooldown_min = 1 SECONDS
	action_icon_state = "camera_jump"
	/// Currently selected view range
	var/selected_view = "default"
	/// View ranges to apply
	var/static/list/view_ranges = list(
		"default",
		"17x17",
		"19x19",
		"21x21",
	)


/obj/effect/proc_holder/spell/view_range/Destroy()
	UnregisterSignal(action.owner, COMSIG_LIVING_DEATH)
	if(selected_view != "default" && !QDELETED(action.owner) && action.owner.client)
		action.owner.client.change_view(action.owner.client.prefs.viewrange)
	return ..()

/obj/effect/proc_holder/spell/view_range/proc/make_view_normal(mob/user)
	SIGNAL_HANDLER
	if(!QDELETED(user) && user.client)
		INVOKE_ASYNC(user.client, TYPE_PROC_REF(/client, change_view), user.client.prefs.viewrange)

/obj/effect/proc_holder/spell/view_range/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/view_range/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	if(!user.client)
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/view_range/on_spell_gain(mob/user = usr)
	RegisterSignal(user, COMSIG_LIVING_DEATH, TYPE_PROC_REF(/obj/effect/proc_holder/spell/view_range, make_view_normal))

/obj/effect/proc_holder/spell/view_range/cast(list/targets, mob/user = usr)
	var/new_view = tgui_input_list(user, "Select view range:", "View", view_ranges, "default")
	if(isnull(new_view) || !user.client)
		return
	if(new_view == "default")
		new_view = user.client.prefs.viewrange
	selected_view = new_view
	user.client.change_view(new_view)


/obj/effect/proc_holder/spell/view_range/genetic
	desc = "Allows you to choose how far you can see."

/obj/effect/proc_holder/spell/summon_friend
	name = "Summon Friend"
	desc = "The reward for selling your soul."
	action_icon_state = "sacredflame"
	clothes_req = FALSE
	base_cooldown = 5 SECONDS
	cooldown_min = 1 SECONDS
	var/mob/living/friend
	var/obj/effect/mob_spawn/human/demonic_friend/friendShell


/obj/effect/proc_holder/spell/summon_friend/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/summon_friend/cast(list/targets, mob/user = usr)
	if(!QDELETED(friend))
		to_chat(friend, "<span class='userdanger'>Your master has deemed you a poor friend. Your durance in hell will now resume.</span>")
		to_chat(user, "<span class='notice'>You banish your friend back to whence [friend.p_they()] came.</span>")
		friend.dust()
		QDEL_NULL(friendShell)
		return
	if(!QDELETED(friendShell))
		QDEL_NULL(friendShell)
		return
	for(var/C in targets)
		var/mob/living/L = C
		friendShell = new /obj/effect/mob_spawn/human/demonic_friend(L.loc, L.mind, src)

