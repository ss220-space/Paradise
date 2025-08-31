#define ARMGUARD_BLADE_READY_FLAG (1<<0)
#define ARMGUARD_BLADE_EXISTS_FLAG (1<<1)
#define ARMGUARD_SILENCE_FLAG (1<<2)


/obj/item/clothing/accessory/armguard
	name = "armguard"
	desc = "Красивые наручи, только для красоты."
	icon_state = "armguard"
	slot = ACCESSORY_SLOT_ARMBAND

/obj/item/clothing/accessory/armguard/get_ru_names()
	return list(
		NOMINATIVE = "наручи",
		GENITIVE = "наручей",
		DATIVE = "наручам",
		ACCUSATIVE = "наручи",
		INSTRUMENTAL = "наручами",
		PREPOSITIONAL = "наручах"
	)

/obj/item/clothing/accessory/armguard/syndicate
	slot = ACCESSORY_SLOT_ARMBAND
	var/datum/action/armguard_hidden_blade/blade_action = new
	var/weapon_type = /obj/item/kitchen/knife/hidden_blade
	var/state_flags = ARMGUARD_BLADE_READY_FLAG
	var/reload_duration = 5
	var/create_new_blade_duration = 120
	var/fire_aim_duration = 1

/obj/item/clothing/accessory/armguard/syndicate/Destroy()
	QDEL_NULL(blade_action)
	. = ..()

/obj/item/clothing/accessory/armguard/syndicate/on_attached(obj/item/clothing/under/new_suit, mob/attacher)
	. = ..()
	if(!has_suit)
		return
	grant_action(has_suit.loc)

/obj/item/clothing/accessory/armguard/syndicate/on_removed(mob/detacher)
	if(!has_suit)
		return ..()
	remove_action(has_suit.loc)
	. = ..()

/obj/item/clothing/accessory/armguard/syndicate/attached_equip(mob/user)
	grant_action(user)
	. = ..()

/obj/item/clothing/accessory/armguard/syndicate/attached_unequip(mob/user)
	remove_action(user)
	. = ..()

/obj/item/clothing/accessory/armguard/syndicate/proc/grant_action(mob/user)
	blade_action.Grant(user)
	RegisterSignal(user, COMSIG_ARMGUARD_ACTION_TOGGLE, PROC_REF(trigger_blade_action))

/obj/item/clothing/accessory/armguard/syndicate/proc/remove_action(mob/user)
	blade_action.Remove(user)
	UnregisterSignal(user, COMSIG_ARMGUARD_ACTION_TOGGLE)

/obj/item/clothing/accessory/armguard/syndicate/proc/reload(mob/user)
	if(state_flags & ARMGUARD_BLADE_READY_FLAG)
		return
	if(state_flags & ARMGUARD_BLADE_EXISTS_FLAG)
		user.balloon_alert(user, "нет клинка")
		return
	user.balloon_alert(user, "зарядка клинка")
	if(!do_after(user, reload_duration SECONDS))
		return
	user.balloon_alert(user, "клинок заряжен")
	state_flags |= ARMGUARD_BLADE_READY_FLAG
	blade_action.set_activate_mode()

/obj/item/clothing/accessory/armguard/syndicate/proc/hide_blade(mob/user, obj/item/kitchen/knife/hidden_blade/blade)
	blade.silence = TRUE
	state_flags &= ~ARMGUARD_BLADE_EXISTS_FLAG
	qdel(blade)
	reload(user)

/obj/item/clothing/accessory/armguard/syndicate/proc/appear_blade(mob/user)
	if(!(state_flags & ARMGUARD_BLADE_READY_FLAG))
		reload(user)
		return
	if(state_flags & ARMGUARD_BLADE_EXISTS_FLAG)
		user.balloon_alert(user, "нет клинка")
		return
	state_flags &= ~ARMGUARD_BLADE_READY_FLAG
	state_flags |= ARMGUARD_BLADE_EXISTS_FLAG
	user.balloon_alert(user, "клинок появился")
	var/obj/item/weapon = new weapon_type(user, src)
	user.put_in_hands(weapon)
	playsound(user, "sound/items/unsheath.ogg", 50, 1)
	blade_action.set_reload_mode()


/obj/item/clothing/accessory/armguard/syndicate/proc/start_create_new_blade(mob/user)
	if (istype(user))
		user.balloon_alert(user, "клинок отрелян")
	addtimer(CALLBACK(src, PROC_REF(create_new_blade), user), create_new_blade_duration SECONDS)

/obj/item/clothing/accessory/armguard/syndicate/proc/create_new_blade(mob/user)
	state_flags &= ~ARMGUARD_BLADE_EXISTS_FLAG
	state_flags |= ARMGUARD_BLADE_READY_FLAG
	blade_action.set_activate_mode()
	if(!istype(user))
		return
	user.balloon_alert(user, "наручи перезаряжены")

/obj/item/clothing/accessory/armguard/syndicate/proc/trigger_blade_action(mob/user)
	SIGNAL_HANDLER
	var/item_in_hands = user.get_active_hand()
	if(istype(item_in_hands, /obj/item/kitchen/knife/hidden_blade))
		INVOKE_ASYNC(src, PROC_REF(hide_blade), user, item_in_hands)
		return
	if(item_in_hands)
		return
	INVOKE_ASYNC(src, PROC_REF(appear_blade), user)


///Hidden blade

/obj/item/kitchen/knife/hidden_blade
	name = "hidden blade"
	desc = "Короткий клинок спрятанный в наручах, профессиональное устройство убийц. Выглядит острым и опасным."
	icon = 'icons/obj/items.dmi'
	icon_state = "armguard_hidden_blade"
	item_state = "knife"
	item_flags = DROPDEL|NOSHARPENING|CONDUCT|IGNORE_SLOWDOWN
	slot_flags = NONE
	w_class = WEIGHT_CLASS_TINY
	force = 15
	throwforce = 50
	throw_range = 15
	throw_speed = 5
	var/throw_armour_penetration = -30
	gender = FEMALE
	sharp = FALSE
	var/obj/item/clothing/accessory/armguard/syndicate/armguard
	var/backstab_damage = 100
	var/backstab_armour_penetration = -30
	var/backstab_cooldown_duration = 10
	COOLDOWN_DECLARE(backstab_cooldown)
	var/silence = FALSE

/obj/item/kitchen/knife/hidden_blade/get_ru_names()
	return list(
		NOMINATIVE = "скрытый клинок",
		GENITIVE = "скрытого клинка",
		DATIVE = "скрытому клинку",
		ACCUSATIVE = "скрытый клинок",
		INSTRUMENTAL = "скрытым клинком",
		PREPOSITIONAL = "скрытом клинке"
	)

/obj/item/kitchen/knife/hidden_blade/Initialize(mapload, obj/item/clothing/accessory/armguard/syndicate/parent_armguard)
	. = ..()
	armguard = parent_armguard

/obj/item/kitchen/knife/hidden_blade/Destroy()
	var/mob/user = loc
	if(!silence && istype(user))
		armguard.state_flags &= ~ARMGUARD_BLADE_EXISTS_FLAG
		user.balloon_alert(user, "клинок скрыт")
	armguard = null
	. = ..()

/obj/item/kitchen/knife/hidden_blade/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	var/extra_force_applied = FALSE
	var/cached_force = force
	var/cached_armour_penetration = armour_penetration
	var/cached_sound = hitsound
	if(user != target && user.dir == target.dir && COOLDOWN_FINISHED(src, backstab_cooldown) && !target.incapacitated(INC_IGNORE_RESTRAINED))
		force = backstab_damage
		armour_penetration = backstab_armour_penetration
		hitsound = null
		extra_force_applied = TRUE
	. = ..()
	if(!extra_force_applied)
		return .
	force = cached_force
	armour_penetration = cached_armour_penetration
	hitsound = cached_sound
	COOLDOWN_START(src, backstab_cooldown, backstab_cooldown_duration SECONDS)
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.))
		return .
	apply_backstab_effect(target, user)

/obj/item/kitchen/knife/hidden_blade/proc/apply_backstab_effect(mob/living/target, mob/living/user)
	playsound(loc, 'sound/items/unsheath.ogg', 30, TRUE, ignore_walls = FALSE, falloff_distance = 0)
	target.Knockdown(2 SECONDS)
	add_attack_logs(user, target, "Backstabbed with [src]", ATKLOG_ALL)
	to_chat(target, span_userdanger("[user] наносит вам удар [declent_ru(INSTRUMENTAL)] в спину!"))

/obj/item/kitchen/knife/hidden_blade/on_thrown(mob/living/carbon/user, atom/target)
	user.balloon_alert(user, "прицеливание")
	if(!do_after(user, armguard.fire_aim_duration SECONDS))
		return
	playsound(loc, 'sound/items/unsheath.ogg', 100, TRUE)
	item_flags &= ~DROPDEL
	armour_penetration = throw_armour_penetration
	armguard.start_create_new_blade(user)
	. = ..()
	item_flags |= DROPDEL

/obj/item/kitchen/knife/hidden_blade/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if (QDELETED(src))
		return
	silence = TRUE
	qdel(src)

///Actions

/datum/action/armguard_hidden_blade
	button_icon_state = "armguard_activate"
	var/activate_icon = "armguard_activate"
	var/reload_icon = "armguard_reload"
	name = "Скрытый клинок"

/datum/action/armguard_hidden_blade/Trigger(left_click)
	if(!..())
		return FALSE
	var/mob/user = usr
	SEND_SIGNAL(user, COMSIG_ARMGUARD_ACTION_TOGGLE)
	return TRUE

/datum/action/armguard_hidden_blade/proc/set_activate_mode()
	button_icon_state = activate_icon
	UpdateButtonIcon()


/datum/action/armguard_hidden_blade/proc/set_reload_mode()
	button_icon_state = reload_icon
	UpdateButtonIcon()


#undef ARMGUARD_BLADE_READY_FLAG
#undef ARMGUARD_BLADE_EXISTS_FLAG
#undef ARMGUARD_SILENCE_FLAG
