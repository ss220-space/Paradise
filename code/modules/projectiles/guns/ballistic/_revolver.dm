/**
 * Located in it's own file because we have revolver-like weapons which are not revolvers (like grenade launchers)
 */

/obj/item/gun/projectile/revolver
	name = ".357 revolver"
	desc = "A suspicious revolver. Uses .357 ammo."
	icon_state = "revolver"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder
	origin_tech = "combat=3;materials=2"
	fire_sound = 'sound/weapons/gunshots/1rev.ogg'
	accuracy = GUN_ACCURACY_PISTOL
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_MUZZLE
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list("x" = 19, "y" = 4),
	)
	can_air_shoot = TRUE
	/// If TRUE will show empty casing on examine
	var/show_live_rounds = TRUE

/obj/item/gun/projectile/revolver/Initialize(mapload)
	. = ..()
	if(!istype(magazine, /obj/item/ammo_box/magazine/internal/cylinder))
		verbs -= /obj/item/gun/projectile/revolver/verb/spin

/obj/item/gun/projectile/revolver/chamber_round(spin = TRUE)
	if(!magazine)
		return
	if(spin)
		chambered = magazine.get_round(TRUE)
	else
		chambered = magazine.stored_ammo[1]

/obj/item/gun/projectile/revolver/shoot_with_empty_chamber(mob/living/user)
	. = ..()
	chamber_round(TRUE)

/obj/item/gun/projectile/revolver/process_chamber(eject_casing = FALSE, empty_chamber = TRUE)
	return ..()

/obj/item/gun/projectile/revolver/attackby(obj/item/item, mob/user, params)
	if(speedloader_reload(item, user))
		return ATTACK_CHAIN_PROCEED
	return ..()

/obj/item/gun/projectile/revolver/unload_act(mob/user)
	var/num_unloaded = 0
	chambered = null
	var/atom/drop_loc = drop_location()
	while(get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(FALSE)
		if(CB)
			CB.forceMove(drop_loc)
			CB.pixel_x = rand(-10, 10)
			CB.pixel_y = rand(-10, 10)
			CB.setDir(pick(GLOB.alldirs))
			CB.update_appearance()
			CB.SpinAnimation(10, 1)
			playsound(drop_loc, CB.casing_drop_sound, 60, TRUE)
			num_unloaded++
	if(num_unloaded)
		balloon_alert(user, "[declension_ru(num_unloaded, "разряжен [num_unloaded] патрон",  "разряжено [num_unloaded] патрона",  "разряжено [num_unloaded] патронов")]")
	else
		balloon_alert(user, "уже разряжено!")

/// Removes all the shells in the cylinder
/obj/item/gun/projectile/revolver/proc/unload(user)
	return

/obj/item/gun/projectile/revolver/verb/spin()
	set name = "Вращать барабан"
	set category = VERB_CATEGORY_OBJECT
	set desc = "Click to spin your revolver's chamber."
	set src in usr

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	if(istype(magazine, /obj/item/ammo_box/magazine/internal/cylinder))
		var/obj/item/ammo_box/magazine/internal/cylinder/C = magazine
		C.spin()
		chamber_round(FALSE)
		playsound(loc, 'sound/weapons/revolver_spin.ogg', 50, TRUE)
		usr.visible_message("[usr] spins [src]'s chamber.",  span_notice("You spin [src]'s chamber."))
	else
		verbs -= /obj/item/gun/projectile/revolver/verb/spin

/obj/item/gun/projectile/revolver/can_shoot(mob/user)
	return get_ammo(FALSE, FALSE)

/obj/item/gun/projectile/revolver/get_ammo(countchambered = FALSE, countempties = TRUE)
	. = ..()

/obj/item/gun/projectile/revolver/examine(mob/user)
	. = ..()
	if(!show_live_rounds)
		return

	var/ammo_num = get_ammo(FALSE, FALSE)
	. += span_notice("[ammo_num] из них боев[declension_ru(ammo_num, "ой", "ые", "ые")]")

/obj/item/gun/projectile/revolver/try_air_fire(datum/source, mob/user)
	. = ..()
	if(!user || (user.a_intent != INTENT_GRAB) || !isturf(user.loc))
		return NONE

	INVOKE_ASYNC(src, PROC_REF(perform_air_fire), user)

	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/gun/projectile/revolver/proc/perform_air_fire(mob/user)
	if(!can_shoot(user))
		shoot_with_empty_chamber(user)
		return

	balloon_alert(user, "вы целитесь вверх...")
	if(!do_after(user, 1.5 SECONDS, src, max_interact_count = 1, interaction_key = src, cancel_on_max = TRUE))
		return

	if(!can_shoot(user))
		shoot_with_empty_chamber(user)
		return

	if(chambered)
		QDEL_NULL(chambered.BB)
		shoot_live_shot(user)

	process_chamber()
	user.balloon_alert(user, "выстрел в воздух")
	user.visible_message(
		span_cultlarge("[user] поднима[PLUR_ET_YUT(user)] дуло вверх и стреля[PLUR_ET_YUT(user)], используя [declent_ru(ACCUSATIVE)]!"),
		ignored_mobs = user
	)

	playsound(user, fire_sound, 120, FALSE)
	update_icon()
