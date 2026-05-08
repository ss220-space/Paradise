// In it's own file because bolt-action rifles are inherited from /shotgun for some reason
// TODO: transform shotguns and bolt-action rifles into two childern of one base type

/obj/item/gun/projectile/shotgun
	name = "shotgun"
	desc = "A traditional shotgun with wood furniture and a four-shell capacity underneath."
	icon_state = "shotgun"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	can_holster = FALSE
	slot_flags = ITEM_SLOT_BACK
	origin_tech = "combat=4;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/shot
	fire_sound = 'sound/weapons/gunshots/1shotgun_old.ogg'
	weapon_weight = WEAPON_HEAVY
	pb_knockback = 1
	COOLDOWN_DECLARE(last_pump)	// to prevent spammage
	accuracy = GUN_ACCURACY_SHOTGUN
	recoil = GUN_RECOIL_HIGH
	/// Sound for pump action
	var/reload_sound = 'sound/weapons/gun_interactions/shotgunpump.ogg'
	/// Available reload animation (pump action animation)
	var/available_reload_animation = TRUE

/obj/item/gun/projectile/shotgun/attackby(obj/item/item, mob/user, params)
	if(speedloader_reload(item, user))
		return ATTACK_CHAIN_PROCEED
	return ..()

/obj/item/gun/projectile/shotgun/handle_chamber(eject_casing = TRUE, empty_chamber = TRUE)
	return ..(FALSE, FALSE)

/obj/item/gun/projectile/shotgun/chamber_round()
	return

/obj/item/gun/projectile/shotgun/can_shoot(mob/user)
	if(!chambered)
		return FALSE
	return (chambered.BB ? TRUE : FALSE)

/obj/item/gun/projectile/shotgun/unload_act(mob/user)
	if(!COOLDOWN_FINISHED(src, last_pump))
		return
	COOLDOWN_START(src, last_pump, 1 SECONDS)
	pump(user)

/obj/item/gun/projectile/shotgun/proc/pump(mob/M)
	playsound(M, reload_sound, 60, TRUE)
	pump_unload(M)
	pump_reload(M)
	update_icon() //I.E. fix the desc
	if(available_reload_animation)
		flick(icon_state + "_reload", src)
	return 1

/obj/item/gun/projectile/shotgun/proc/pump_unload(mob/M)
	if(chambered)//We have a shell in the chamber
		chambered.loc = get_turf(src)//Eject casing
		chambered.SpinAnimation(5, 1)
		playsound(src, chambered.casing_drop_sound, 60, TRUE)
		chambered = null

/obj/item/gun/projectile/shotgun/proc/pump_reload(mob/M)
	if(!magazine.ammo_count())
		return 0
	var/obj/item/ammo_casing/AC = magazine.get_round() //load next casing.
	chambered = AC

/obj/item/gun/projectile/shotgun/examine(mob/user)
	. = ..()
	if(chambered)
		. += span_notice("A [chambered.BB ? "live" : "spent"] one is in the chamber.")
