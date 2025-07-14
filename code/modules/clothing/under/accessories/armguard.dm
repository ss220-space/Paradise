
/obj/item/clothing/accessory/armguard
	name = "armguard"
	ru_names = list(
		NOMINATIVE = "наручи",
		GENITIVE = "наручей",
		DATIVE = "наручам",
		ACCUSATIVE = "наручи",
		INSTRUMENTAL = "наручами",
		PREPOSITIONAL = "наручах"
	)
	desc = "Красивые наручи, только для красоты."
	icon_state = "armguard"
	slot = ACCESSORY_SLOT_ARMBAND


/obj/item/clothing/accessory/armguard/syndicate
	slot = ACCESSORY_SLOT_ARMBAND
	var/datum/action/armguard_hidden_blade/blade_action = new
	var/weapon_type = /obj/item/kitchen/knife/hidden_blade
	var/blade_ready = TRUE
	var/blade_exists = FALSE
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
	var/mob/wearer = has_suit.loc
	if(wearer)
		blade_action.Grant(wearer)

/obj/item/clothing/accessory/armguard/syndicate/on_removed(mob/detacher)
	if(!has_suit)
		return ..()
	var/mob/wearer = has_suit.loc
	if(wearer)
		blade_action.Remove(wearer)
	. = ..()

/obj/item/clothing/accessory/armguard/syndicate/attached_equip(mob/user)
	blade_action.Grant(user)
	. = ..()

/obj/item/clothing/accessory/armguard/syndicate/attached_unequip(mob/user)
	blade_action.Remove(user)
	. = ..()

/obj/item/clothing/accessory/armguard/syndicate/proc/reload(mob/user)
	if(blade_ready)
		return
	if(blade_exists)
		user.balloon_alert(user, "нет клинка")
		return
	user.balloon_alert(user, "зарядка клинка")
	if(!do_after(user, reload_duration SECONDS))
		return
	user.balloon_alert(user, "клинок заряжен")
	blade_ready = TRUE
	blade_action.set_activate_mode()

/obj/item/clothing/accessory/armguard/syndicate/proc/hide_blade(mob/user, obj/item/kitchen/knife/hidden_blade/blade)
	blade.silence = TRUE
	blade_exists = FALSE
	qdel(blade)
	reload(user)

/obj/item/clothing/accessory/armguard/syndicate/proc/appear_blade(mob/user)
	if(!blade_ready)
		reload(user)
		return
	if(blade_exists)
		user.balloon_alert(user, "нет клинка")
		return
	blade_ready = FALSE
	blade_exists = TRUE
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
	blade_exists = FALSE
	blade_ready = TRUE
	blade_action.set_activate_mode()
	if(!istype(user))
		return
	user.balloon_alert(user, "наручи перезаряжены")


///Hidden blade

/obj/item/kitchen/knife/hidden_blade
	name = "hidden blade"
	ru_names = list(
		NOMINATIVE = "скрытый клинок",
		GENITIVE = "скрытого клинка",
		DATIVE = "скрытому клинку",
		ACCUSATIVE = "скрытый клинок",
		INSTRUMENTAL = "скрытым клинком",
		PREPOSITIONAL = "скрытом клинке"
	)
	desc = "Короткий клинок из наручей, профессиональное устройство убийц. Выглядит острым и опасным."
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

/obj/item/kitchen/knife/hidden_blade/Initialize(mapload, obj/item/clothing/accessory/armguard/syndicate/parent_armguard)
	. = ..()
	armguard = parent_armguard
	var/mob/user = armguard.loc
	if(!istype(user))
		return

/obj/item/kitchen/knife/hidden_blade/Destroy()
	var/mob/user = loc
	if(!silence && istype(user))
		armguard.blade_exists = FALSE
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
	playsound(loc, 'sound/items/unsheath.ogg', 30, TRUE, ignore_walls = FALSE, falloff_distance = 0)
	target.Weaken(2 SECONDS)
	//target.apply_damage(40, STAMINA)
	add_attack_logs(user, target, "Backstabbed with [src]", ATKLOG_ALL)
	target.visible_message(span_userdanger("[user] наносит удар [declent_ru(INSTRUMENTAL)] в спину [target]!"))

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
	if (!QDELETED(src))
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
	var/suit = user.get_item_by_slot(ITEM_SLOT_CLOTH_INNER)
	if(!suit)
		return FALSE
	var/obj/item/clothing/accessory/armguard/syndicate/armguard
	if(istype(suit, /obj/item/clothing/under))
		var/obj/item/clothing/under/uniform = suit
		if(LAZYLEN(uniform.accessories))
			armguard = locate() in uniform.accessories
	if(!armguard)
		return FALSE
	var/item_in_hands = user.get_active_hand()
	if(istype(item_in_hands, /obj/item/kitchen/knife/hidden_blade))
		armguard.hide_blade(user, item_in_hands)
		return TRUE
	if(!item_in_hands)
		armguard.appear_blade(user)
		return TRUE
	return FALSE

/datum/action/armguard_hidden_blade/proc/set_activate_mode()
	button_icon_state = activate_icon
	UpdateButtonIcon()


/datum/action/armguard_hidden_blade/proc/set_reload_mode()
	button_icon_state = reload_icon
	UpdateButtonIcon()
