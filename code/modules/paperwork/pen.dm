/* Pens!
 * Contains:
 *		Pens
 *		Sleepy Pens
 *		Edaggers
 *		Assassin pens
 */

/*
 * MARK: Pens
 */
/obj/item/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	slot_flags = ITEM_SLOT_BELT|ITEM_SLOT_EARS
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	materials = list(MAT_METAL=10)
	var/colour = "black"	//what colour the ink is!
	pressure_resistance = 2
	var/fake_signing = FALSE //do we always write like [sign]?
	/// The mind of the first user who activated the pen. Used to lock its special functions to the original owner.
	var/datum/weakref/first_activated_mind_weakref
	/// At what angle head of pen now
	var/degrees

/obj/item/pen/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))
	create_transform_component()

/obj/item/pen/proc/create_transform_component()
	AddComponent( \
		/datum/component/transforming, \
		sharpness_on = NONE, \
		w_class_on = w_class, \
		manual_icon_state_change = TRUE, \
		inhand_icon_change = NONE, \
	)

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Clicks the pen to make an annoying sound. Clickity clickery click!
 */
/obj/item/pen/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	if(user)
		balloon_alert(user, "*клик*")
	playsound(src, 'sound/items/pen_click.ogg', 30, TRUE, -3)
	icon_state = (base_icon_state ? base_icon_state : initial(icon_state)) + (active ? "_retracted" : "") // base_icon_state for skins support
	//update_appearance(UPDATE_ICON)

	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/pen/proc/handle_mind_check(mob/user)
	if(!first_activated_mind_weakref)
		first_activated_mind_weakref = WEAKREF(user.mind)
		return TRUE

	var/first_activated_mind_resolved = first_activated_mind_weakref.resolve()
	if(first_activated_mind_weakref && first_activated_mind_resolved != user.mind)
		return FALSE
	return TRUE

/obj/item/pen/CtrlClick(mob/living/carbon/user)
	if(loc != user)
		to_chat(user, span_warning("Вы должны держать ручку!"))
		return CLICK_ACTION_BLOCKING
	var/deg = tgui_input_number(user, "На какой угол вы хотите повернуть головку ручки? (0-360)", "Поворот головки ручки", max_value = 360)
	if(isnull(deg) || QDELETED(user) || QDELETED(src) || !user.can_perform_action(src) || loc != user)
		return CLICK_ACTION_BLOCKING
	degrees = deg
	to_chat(user, span_notice("Вы повернули головку ручки на [deg] градусов."))
	SEND_SIGNAL(src, COMSIG_PEN_ROTATED, deg, user)
	return CLICK_ACTION_SUCCESS

/obj/item/pen/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] starts scribbling numbers over [user.p_them()]self with the [name]! It looks like [user.p_theyre()] trying to commit sudoku."))
	return BRUTELOSS

/obj/item/proc/on_write(obj/item/paper/P, mob/user)
	return

/obj/item/pen/blue
	name = "blue-ink pen"
	desc = "It's a normal blue ink pen."
	icon_state = "pen_blue"
	colour = "blue"

/obj/item/pen/red
	name = "red-ink pen"
	desc = "It's a normal red ink pen."
	icon_state = "pen_red"
	colour = "red"

/obj/item/pen/gray
	name = "gray-ink pen"
	desc = "It's a normal gray ink pen."
	colour = "gray"

/obj/item/pen/invisible
	desc = "It's an invisble pen marker."
	colour = "white"

/obj/item/pen/multi
	name = "multicolor pen"
	desc = "It's a cool looking pen. Lots of colors!"
	icon_state = "multicolor"

	// these values are for the overlay
	var/list/colour_choices = list(
		"black" = list(0.25, 0.25, 0.25),
		"red" = list(1, 0.25, 0.25),
		"green" = list(0, 1, 0),
		"blue" = list(0.5, 0.5, 1),
		"yellow" = list(1, 1, 0))
	var/pen_color_iconstate = "pencolor"

/obj/item/pen/multi/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Clicks and change color.
 */
/obj/item/pen/multi/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	if(user)
		balloon_alert(user, "*клик*")
	select_colour(user)
	playsound(src, 'sound/items/pen_click.ogg', 30, TRUE, -3)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/pen/multi/proc/select_colour(mob/user)
	. = tgui_input_list(user, "Which colour would you like to use?", name, colour_choices, colour)
	if(.)
		colour = .
		playsound(loc, 'sound/effects/pop.ogg', 50, TRUE)
		update_icon(UPDATE_OVERLAYS)

/obj/item/pen/multi/update_overlays()
	. = ..()
	var/icon/color_overlay = new(icon, pen_color_iconstate)
	var/list/colors = colour_choices[colour]
	color_overlay.SetIntensity(colors[1], colors[2], colors[3])
	. += color_overlay

/obj/item/pen/fountain
	name = "fountain pen"
	desc = "Дорого выглядящая ручка. Для самых богатых."
	icon_state = "pen-fountain"

/obj/item/pen/fountain/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/item_skins, item_path = /obj/item/pen/fountain)

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Just CLICKS and nothing more.
 */
/obj/item/pen/fountain/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	if(user)
		balloon_alert(user, "*клик*")
	playsound(src, 'sound/items/pen_click.ogg', 30, TRUE, -3)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/pen/survival
	name = "survival pen"
	desc = "The latest in portable survival technology, this pen was designed as a miniature diamond pickaxe."
	icon_state = "digging_pen"
	tool_behaviour = TOOL_MINING //For the classic "digging out of prison with a spoon but you're in space so this analogy doesn't work" situation.
	toolspeed = 10 //You will never willingly choose to use one of these over a shovel.
	colour = COLOR_BLUE
	usesound = 'sound/effects/picaxe1.ogg'

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Just CLICKS and nothing more too.
 */
/obj/item/pen/survival/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	if(user)
		balloon_alert(user, "*клик*")
	playsound(src, 'sound/items/pen_click.ogg', 30, TRUE, -3)
	return COMPONENT_NO_DEFAULT_MESSAGE

/*
 * MARK: Fake sign pen
 */
/obj/item/pen/fakesign
	fake_signing = TRUE
	//desc = "It's a normal black ink pen with constantly moving tip. Wait what?" //documented bcs its should be stealthy item, like edagger and poison

/*
 * MARK: Bomb pen
 */
/obj/item/pen/fountain/bomb
	var/clickscount = 0
	var/bomb_timer
	var/obj/item/grenade/syndieminibomb/bomb

/obj/item/pen/fountain/bomb/Initialize(mapload)
	. = ..()
	bomb = new(src)

/obj/item/pen/fountain/bomb/Destroy()
	QDEL_NULL(bomb)
	return ..()

/obj/item/pen/fountain/bomb/examine(mob/user)
	. = ..()
	if(istraitor(user))
		. += span_specialnotice("They always said the pen is mightier than the sword.")

/obj/item/pen/fountain/bomb/attack_self(mob/user)
	..()
	if(++clickscount == 3)
		clickscount = initial(clickscount)

		if(!bomb_timer)
			bomb_timer = addtimer(CALLBACK(src, PROC_REF(prime_bomb), user), bomb.det_time, TIMER_STOPPABLE|TIMER_DELETE_ME)
			if(iscarbon(user))
				var/mob/living/carbon/carbon_user = user
				carbon_user.throw_mode_on()
		else
			deltimer(bomb_timer)
			bomb_timer = null

/obj/item/pen/fountain/bomb/proc/prime_bomb(mob/user)
	log_and_message_admins("[key_name_admin(user)] has detonated a pen-bomb.")
	update_mob()
	bomb.prime()

/obj/item/pen/fountain/bomb/proc/update_mob()
	if(ismob(loc))
		var/mob/mob_loc = loc
		mob_loc.drop_item_ground(src)

/obj/item/pen/fountain/bomb/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type)
	return bomb.hit_reaction(owner, hitby, attack_text, final_block_chance, damage, attack_type)

/obj/item/pen/fountain/bomb/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	return bomb.tool_act(user, tool, modifiers) || ..()

/*
 * MARK: Sleepypen
 */
/obj/item/pen/sleepy
	container_type = OPENCONTAINER
	origin_tech = "engineering=4;syndicate=2"

/obj/item/pen/sleepy/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!target.can_inject(user, TRUE, ignore_pierceimmune = TRUE))
		return ATTACK_CHAIN_PROCEED
	. = ATTACK_CHAIN_PROCEED_SUCCESS
	var/transfered = 0
	if(reagents.total_volume && target.reagents)
		transfered = reagents.trans_to(target, 50)
	to_chat(user, span_warning("You sneakily stab [target] with the pen."))
	add_attack_logs(user, target, "Stabbed with (sleepy) [src]. [transfered]u of reagents transfered.")

/obj/item/pen/sleepy/Initialize(mapload)
	. = ..()
	create_reagents(100)
	reagents.add_reagent("ketamine", 100)

/*
 * MARK: Edagger
 */
/obj/item/pen/edagger
	origin_tech = "combat=3;syndicate=1"
	light_range = 2
	light_color = COLOR_SOFT_RED
	light_on = FALSE
	light_system = OVERLAY_LIGHT
	armour_penetration = 20
	var/on = FALSE
	var/backstab_sound = 'sound/items/unsheath.ogg'
	var/backstab_damage = 12
	COOLDOWN_DECLARE(backstab_cooldown)

/obj/item/pen/edagger/create_transform_component()
	AddComponent( \
		/datum/component/transforming, \
		force_on = 18, \
		throwforce_on = 35, \
		throw_speed_on = 4, \
		sharpness_on = TRUE, \
		w_class_on = WEIGHT_CLASS_NORMAL, \
		hitsound_on = 'sound/weapons/blade1.ogg', \
		attack_verb_on = list("полоснул", "уколол", "поранил", "порезал"), \
		inhand_icon_change = NONE, \
	)

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Handles special sounds and light.
 */
/obj/item/pen/edagger/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	on = !on // Need for special logic at attack() proc
	icon_state = active ? "edagger" : initial(icon_state)
	item_state = active ? "edagger" : initial(item_state)
	playsound(src, active ? 'sound/weapons/saberon.ogg' : 'sound/weapons/saberoff.ogg', 5, TRUE)
	set_light_on(active)
	//update_appearance(UPDATE_ICON|UPDATE_NAME)
	handle_mind_check(user)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/pen/edagger/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	var/extra_force_applied = FALSE
	var/cached_sound = hitsound
	if(on && user != target && user.dir == target.dir && COOLDOWN_FINISHED(src, backstab_cooldown) && !target.incapacitated(IGNORE_RESTRAINTS))
		hitsound = null
		force += backstab_damage
		extra_force_applied = TRUE
	. = ..()
	if(!extra_force_applied)
		return .
	hitsound = cached_sound
	force -= backstab_damage
	COOLDOWN_START(src, backstab_cooldown, 10 SECONDS)
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.))
		return .
	target.Weaken(2 SECONDS)
	target.apply_damage(40, STAMINA)
	add_attack_logs(user, target, "Backstabbed with [src]", ATKLOG_ALL)
	playsound(loc, backstab_sound, 30, TRUE, ignore_walls = FALSE, falloff_distance = 0)
	target.visible_message(
		span_warning("[user] stabs [target] in the back!"),
		span_userdanger("[user] stabs you in the back! The energy blade makes you collapse in pain!"),
	)

/obj/item/pen/edagger/get_clamped_volume() //So the parent proc of attack isn't the loudest sound known to man
	if(!force)
		return ..()
	return 20

/obj/item/pen/edagger/comms
	icon_state = "ofcommpen"
	item_state = "ofcommpen"
	light_color = LIGHT_COLOR_BLUE

/obj/item/pen/edagger/comms/update_icon_state()
	icon_state = on ? "ofcommpen_active" : initial(icon_state)
	item_state = on ? "ofcommpen_active" : initial(item_state)

/*
 * MARK: Poison pen
 */
/obj/item/pen/poison
	var/uses_left = 3

/obj/item/pen/poison/on_write(obj/item/paper/P, mob/user)
	if(P.contact_poison_volume)
		to_chat(user, span_warning("[P] is already coated."))
	else if(uses_left)
		uses_left--
		P.contact_poison = "amanitin"
		P.contact_poison_volume = 15
		P.contact_poison_poisoner = user.name
		add_attack_logs(user, P, "Poison pen'ed")
		to_chat(user, span_warning("You apply the poison to [P]."))
	else
		to_chat(user, span_warning("[src] clicks. It seems to be depleted."))

/*
 * MARK: Assassin pen
 */
/obj/item/pen/assassin_pen
	var/safety = TRUE
	var/obj/item/gun/projectile/revolver/assassin_pen_gun/oneuse_10mm

/obj/item/pen/assassin_pen/Initialize(mapload)
	. = ..()
	oneuse_10mm = new(src)

/obj/item/pen/assassin_pen/Destroy(force)
	QDEL_NULL(oneuse_10mm)
	return ..()

/obj/item/pen/assassin_pen/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	playsound(src, 'sound/items/pen_click.ogg', 30, TRUE, -3)
	safety = !safety //Because of special attack. Need to check something at attack() proc
	//update_appearance(UPDATE_ICON_STATE|UPDATE_NAME) // Cant handle icon and name changes here because icon and name permanentrly changes exactly after fast_fire(). So used update_icon_state() and update_name()
	handle_mind_check(user)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/pen/assassin_pen/update_icon_state()
	if(!oneuse_10mm.chambered.BB)
		icon_state = "assassin_pen0"
		return
	icon_state = safety ? initial(icon_state) : "assassin_pen1" // No skins so only initial(icon_state)

/obj/item/pen/assassin_pen/update_name(updates)
	. = ..()
	if(!oneuse_10mm.chambered.BB)
		name = "used assassin's pen"
		return
	name = safety ? initial(name) : "assassin's pen"

/obj/item/pen/assassin_pen/attack(mob/living/target, mob/living/user, list/modifiers, def_zone, skip_attack_anim)
	if(safety || !user.Adjacent(target) || !oneuse_10mm.chambered.BB)
		return ..()
	oneuse_10mm.chambered.BB.forced_accuracy = TRUE
	oneuse_10mm.fast_fire(target, user)
	//update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)
	return ATTACK_CHAIN_BLOCKED_ALL

/// Assassin pen's gun stuff
/obj/item/gun/projectile/revolver/assassin_pen_gun
	name = "assassin pen's gun"
	desc = "Кодовая затычка для работы ручки ассассина. Если вы её увидели - пишите багрепорт с описанием получения."
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/assassin_pen_mag
	fire_sound = 'sound/weapons/gunshots/1stechkin.ogg'
	accuracy = GUN_ACCURACY_PISTOL_STECHKIN
	attachable_allowed = GUN_MODULE_CLASS_NONE
	can_air_shoot = FALSE
	suppressed = TRUE
	damage_mod = 2

/obj/item/ammo_box/magazine/internal/cylinder/assassin_pen_mag
	name = "assassin pen mag"
	ammo_type = /obj/item/ammo_casing/c10mm/hp
	caliber = CALIBER_10MM
	max_ammo = 1
