// the different states of the mystery box
/// Closed, can't interact
#define MYSTERY_BOX_COOLING_DOWN 0
/// Closed, ready to be interacted with
#define MYSTERY_BOX_STANDBY 1
/// The box is choosing the prize
#define MYSTERY_BOX_CHOOSING 2
/// The box is presenting the prize, for someone to claim it
#define MYSTERY_BOX_PRESENTING 3

// delays for the different stages of the box's state, the visuals, and the audio
/// How long the box takes to decide what the prize is
#define MBOX_DURATION_CHOOSING (5 SECONDS)
/// How long the box takes to start expiring the offer, though it's still valid until MBOX_DURATION_EXPIRING finishes. Timed to the sound clips
#define MBOX_DURATION_PRESENTING (3.5 SECONDS)
/// How long the box takes to start lowering the prize back into itself. When this finishes, the prize is gone
#define MBOX_DURATION_EXPIRING (4.5 SECONDS)
/// How long after the box closes until it can go again
#define MBOX_DURATION_STANDBY (30 SECONDS) //2.7 in original

GLOBAL_LIST_INIT(mystery_box_guns, list(
	/obj/item/gun/energy/kinetic_accelerator/crossbow/large,
	/obj/item/gun/energy/kinetic_accelerator/crossbow,
	/obj/item/gun/energy/gun,
	/obj/item/gun/energy/gun/nuclear,
	/obj/item/gun/energy/laser/captain,
	/obj/item/gun/energy/sniperrifle/pod_pilot,
	/obj/item/gun/projectile/automatic/aks74u,
	/obj/item/gun/projectile/automatic/shotgun/bulldog,
	/obj/item/gun/projectile/automatic/smg/c20r,
	/obj/item/gun/projectile/automatic/smg/wt550,
	/obj/item/gun/projectile/automatic/smg/sfg,
	/obj/item/gun/projectile/shotgun/automatic/combat,
	/obj/item/gun/projectile/shotgun/boltaction,
	/obj/item/gun/projectile/revolver/golden,
	/obj/item/gun/projectile/revolver/mateba,
	/obj/item/gun/projectile/revolver/nagant,
	/obj/item/gun/projectile/automatic/pistol/deagle,
	/obj/item/gun/projectile/automatic/pistol/aps,
	/obj/item/gun/projectile/automatic/smg/sp91rc,
	/obj/item/storage/box/syndie_kit/rsh12_revolver,
))


GLOBAL_LIST_INIT(mystery_box_extended, list(
	/obj/item/gun/energy/disabler,
	/obj/item/gun/energy/gun/mini,
	/obj/item/gun/projectile/automatic/lr30,
	/obj/item/gun/projectile/revolver/doublebarrel/improvised,
	/obj/item/gun/projectile/automatic/pistol/enforcer,
	/obj/item/twohanded/spear,
	/obj/item/melee/baton/telescopic,
	/obj/item/twohanded/spear/plasma,
	/obj/item/shield/riot,
	/obj/item/shield/riot/tele,
))

/obj/structure/mystery_box
	name = "mystery box"
	desc = "Мистическая коробка, позволяющая пользователю получить случайное оружие или предмет."
	icon = 'icons/obj/crates.dmi'
	icon_state = "wooden_crate"
	anchored = TRUE
	density = TRUE
	max_integrity = 99999
	damage_deflection = 100

	var/crate_open_sound = 'sound/machines/crate_open.ogg'
	var/crate_close_sound = 'sound/machines/crate_close.ogg'

	var/open_sound = 'sound/effects/mbox_full.ogg'
	var/grant_sound = 'sound/effects/mbox_end.ogg'
	/// The box's current state, and whether it can be interacted with in different ways
	var/box_state = MYSTERY_BOX_STANDBY
	/// The object that represents the rapidly changing item that will be granted upon being claimed. Is not, itself, an item.
	var/obj/effect/abstract/mystery_box_item/presented_item
	/// A timer for how long it takes for the box to start its expire animation
	var/box_expire_timer
	/// A timer for how long it takes for the box to close itself
	var/box_close_timer
	/// Every type that's a child of this that has an icon, icon_state, and isn't ABSTRACT is fair game. More granularity to come
	var/selectable_base_type = /obj/item
	/// The instantiated list that contains all of the valid items that can be chosen from. Generated in [/obj/structure/mystery_box/proc/generate_valid_types]
	var/list/valid_types
	/// If the prize is a ballistic gun with an external magazine, should we grant the user a spare mag?
	var/grant_extra_mag = TRUE
	/// Stores the current sound channel we're using so we can cut off our own sounds as needed. Randomized after each roll
	var/current_sound_channel
	/// How many time can it still be used?
	var/uses_left = INFINITY
	/// A list of weakrefs to mind datums of people that opened it and how many times.
	var/list/datum/weakref/minds_that_opened_us

/obj/structure/mystery_box/Initialize(mapload)
	. = ..()
	generate_valid_types()

/obj/structure/mystery_box/Destroy()
	QDEL_NULL(presented_item)
	if(current_sound_channel)
		SSsounds.free_sound_channel(current_sound_channel)
	minds_that_opened_us = null
	return ..()

/obj/structure/mystery_box/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	switch(box_state)
		if(MYSTERY_BOX_STANDBY)
			activate(user)

		if(MYSTERY_BOX_PRESENTING)
			if(presented_item.claimable)
				grant_weapon(user)

/obj/structure/mystery_box/update_icon_state()
	icon_state = "[initial(icon_state)][box_state > MYSTERY_BOX_STANDBY ? "_open" : ""]"
	return ..()

/// This proc is used to define what item types valid_types is filled with
/obj/structure/mystery_box/proc/generate_valid_types()
	valid_types = list()

	for(var/iter_path in typesof(selectable_base_type))
		if(!ispath(iter_path, /obj/item))
			continue
		var/obj/item/iter_item = iter_path
		if((initial(iter_item.item_flags) & ABSTRACT) || !initial(iter_item.icon_state))
			continue
		valid_types += iter_path

/// The box has been activated, play the sound and spawn the prop item
/obj/structure/mystery_box/proc/activate(mob/living/user)
	box_state = MYSTERY_BOX_CHOOSING
	update_icon(UPDATE_ICON_STATE)
	presented_item = new(src)
	presented_item.vis_flags = VIS_INHERIT_PLANE
	vis_contents += presented_item
	presented_item.start_animation(src)
	current_sound_channel = SSsounds.reserve_sound_channel(src)
	playsound(src, open_sound, 70, FALSE, channel = current_sound_channel, falloff_exponent = 10)
	playsound(src, crate_open_sound, 80)
	if(user.mind)
		LAZYINITLIST(minds_that_opened_us)
		var/datum/weakref/ref = WEAKREF(user.mind)
		minds_that_opened_us[ref] += 1
	uses_left--

/// The box has finished choosing, mark it as available for grabbing
/obj/structure/mystery_box/proc/present_weapon()
	visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] проявляет [presented_item.declent_ru(ACCUSATIVE)]!"))
	box_state = MYSTERY_BOX_PRESENTING
	box_expire_timer = addtimer(CALLBACK(src, PROC_REF(start_expire_offer)), MBOX_DURATION_PRESENTING, TIMER_STOPPABLE)

/// The prize is still claimable, but the animation will show it start to recede back into the box
/obj/structure/mystery_box/proc/start_expire_offer()
	presented_item.expire_animation()
	box_close_timer = addtimer(CALLBACK(src, PROC_REF(close_box)), MBOX_DURATION_EXPIRING, TIMER_STOPPABLE)

/// The box is closed, whether because the prize fully expired, or it was claimed. Start resetting all of the state stuff
/obj/structure/mystery_box/proc/close_box()
	box_state = MYSTERY_BOX_COOLING_DOWN
	update_icon(UPDATE_ICON_STATE)
	QDEL_NULL(presented_item)
	deltimer(box_close_timer)
	deltimer(box_expire_timer)
	playsound(src, crate_close_sound, 100)
	box_close_timer = null
	box_expire_timer = null
	addtimer(CALLBACK(src, PROC_REF(ready_again)), MBOX_DURATION_STANDBY)
	if(uses_left <= 0)
		visible_message("[DECLENT_RU_CAP(src, NOMINATIVE)] ломается.")
		deconstruct(disassembled = FALSE)

/// The cooldown between activations has finished, shake to show that
/obj/structure/mystery_box/proc/ready_again()
	SSsounds.free_sound_channel(current_sound_channel)
	current_sound_channel = null
	box_state = MYSTERY_BOX_STANDBY
	Shake(3, 0, 0.5 SECONDS)

/// Someone attacked the box with an empty hand, spawn the shown prize and give it to them, then close the box
/obj/structure/mystery_box/proc/grant_weapon(mob/living/user)
	var/atom/movable/instantiated_weapon = new presented_item.selected_path(loc)
	user.visible_message(span_notice("[user] забирает [presented_item.declent_ru(ACCUSATIVE)] из [declent_ru(GENITIVE)]."), span_notice("Вы забираете [presented_item.declent_ru(ACCUSATIVE)] из [declent_ru(GENITIVE)]."))
	playsound(src, grant_sound, 70, FALSE, channel = current_sound_channel, falloff_exponent = 10)
	close_box()

	if(!isitem(instantiated_weapon))
		return
	user.put_in_hands(instantiated_weapon)

	if(!isgun(instantiated_weapon))
		return

/obj/structure/mystery_box/tdome
	desc = "Мистическая коробка, позволяющая пользователю получить оружие для убийства других. Чего вы ждёте?"

/obj/structure/mystery_box/tdome/lavaland
	icon_state = "necrocrate"

/obj/structure/mystery_box/tdome/generate_valid_types()
	valid_types = GLOB.mystery_box_guns + GLOB.mystery_box_extended

/// This represents the item that comes out of the box and is constantly changing before the box finishes deciding. Can probably be just an /atom or /movable.
/obj/effect/abstract/mystery_box_item
	name = "???"
	desc = "Что же выпадет??"
	icon = 'icons/obj/weapons/projectile.dmi'
	icon_state = "revolver"

	//We need invisibility of abstract effects, but it's need to be actually visible
	invisibility = INVISIBILITY_NONE
	layer = OBJ_LAYER

/// The currently selected item. Constantly changes while choosing, determines what is spawned if the prize is claimed, and its current icon
	var/selected_path = /obj/item/gun/projectile/revolver/nagant
	/// The box that spawned this
	var/obj/structure/mystery_box/parent_box
	/// Whether this prize is currently claimable
	var/claimable = FALSE

/obj/effect/abstract/mystery_box_item/Initialize(mapload)
	. = ..()
	var/matrix/starting = matrix()
	starting.Scale(0.5,0.5)
	transform = starting
	add_filter("weapon_rays", 3, list("type" = "rays", "size" = 28, "color" = COLOR_VIVID_YELLOW))

/obj/effect/abstract/mystery_box_item/Destroy(force)
	parent_box = null
	return ..()

// this way, clicking on the prize will work the same as clicking on the box
/obj/effect/abstract/mystery_box_item/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(claimable)
		parent_box.grant_weapon(user)

/// Start pushing the prize up
/obj/effect/abstract/mystery_box_item/proc/start_animation(atom/parent)
	parent_box = parent
	loop_icon_changes()

/// Keep changing the icon and selected path
/obj/effect/abstract/mystery_box_item/proc/loop_icon_changes()
	var/change_delay = 1 // the running count of the delay
	var/change_delay_delta = 1 // How much to increment the delay per step so the changing slows down
	var/change_counter = 0 // The running count of the running count

	var/matrix/starting = matrix()
	animate(src, pixel_z = 10, transform = starting, time = MBOX_DURATION_CHOOSING, easing = QUAD_EASING | EASE_OUT)

	while((change_counter + change_delay_delta + change_delay) < MBOX_DURATION_CHOOSING)
		change_delay += change_delay_delta
		change_counter += change_delay
		selected_path = pick(parent_box.valid_types)
		addtimer(CALLBACK(src, PROC_REF(update_random_icon), selected_path), change_counter)

	addtimer(CALLBACK(src, PROC_REF(present_item)), MBOX_DURATION_CHOOSING)

/// animate() isn't up to the task for queueing up icon changes, so this is the proc we call with timers to update our icon
/obj/effect/abstract/mystery_box_item/proc/update_random_icon(new_item_type)
	var/atom/movable/new_item = new_item_type
	icon = new_item::icon
	icon_state = new_item::icon_state

/obj/effect/abstract/mystery_box_item/proc/present_item()
	var/atom/movable/selected_item = selected_path
	add_filter("ready_outline", 2, list("type" = "outline", "color" = COLOR_VIVID_YELLOW, "size" = 0.2))
	name = selected_item::name
	parent_box.present_weapon()
	claimable = TRUE

/// Sink back into the box
/obj/effect/abstract/mystery_box_item/proc/expire_animation()
	var/matrix/shrink_back = matrix()
	shrink_back.Scale(0.5,0.5)
	animate(src, pixel_z = -4, transform = shrink_back, time = MBOX_DURATION_EXPIRING)

#undef MYSTERY_BOX_COOLING_DOWN
#undef MYSTERY_BOX_STANDBY
#undef MYSTERY_BOX_CHOOSING
#undef MYSTERY_BOX_PRESENTING
#undef MBOX_DURATION_CHOOSING
#undef MBOX_DURATION_PRESENTING
#undef MBOX_DURATION_EXPIRING
#undef MBOX_DURATION_STANDBY
