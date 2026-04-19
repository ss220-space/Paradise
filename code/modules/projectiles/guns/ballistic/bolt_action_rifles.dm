// TODO: Merge it with sniper.dm

// MARK: Basic (Mosin-Nagant)
/obj/item/gun/projectile/shotgun/boltaction
	name = "Mosin Nagant"
	desc = "This piece of junk looks like something that could have been used 700 years ago. Has a bayonet lug for attaching a knife."
	icon_state = "moistnugget"
	item_state = "moistnugget"
	slot_flags = NONE //no ITEM_SLOT_BACK sprite, alas
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction
	fire_sound = 'sound/weapons/gunshots/1rifle.ogg'
	pb_knockback = 0
	accuracy = GUN_ACCURACY_RIFLE
	attachable_allowed = GUN_MODULE_CLASS_SHOTGUN_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 7, ATTACHMENT_OFFSET_Y = 4),
	)
	recoil = GUN_RECOIL_MEDIUM
	available_reload_animation = FALSE

/obj/item/gun/projectile/shotgun/boltaction/pump(mob/M)
	playsound(M, 'sound/weapons/gun_interactions/rifle_load.ogg', 60, TRUE)
	if(bolt_open)
		pump_reload(M)
	else
		pump_unload(M)
	bolt_open = !bolt_open
	update_icon(UPDATE_ICON_STATE)
	return 1

/obj/item/gun/projectile/shotgun/boltaction/update_icon_state()
	icon_state = "[initial(icon_state)][bolt_open ? "-open" : ""]"

/obj/item/gun/projectile/shotgun/blow_up(mob/user)
	. = 0
	if(chambered?.BB)
		process_fire(user, user,0)
		. = 1

/obj/item/gun/projectile/shotgun/boltaction/attackby(obj/item/I, mob/user, params)
	if(!bolt_open)
		add_fingerprint(user)
		balloon_alert(user, "затвор закрыт!")
		return ATTACK_CHAIN_PROCEED
	return ..()

/obj/item/gun/projectile/shotgun/boltaction/examine(mob/user)
	. = ..()
	. += span_notice("The bolt is [bolt_open ? "open" : "closed"].")

// MARK: Enchanted
/obj/item/gun/projectile/shotgun/boltaction/enchanted
	name = "enchanted bolt action rifle"
	desc = "Careful not to lose your head."
	var/guns_left = 30
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/enchanted

/obj/item/gun/projectile/shotgun/boltaction/enchanted/Initialize(mapload)
	. = ..()
	bolt_open = 1
	pump()

/obj/item/gun/projectile/shotgun/boltaction/enchanted/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	guns_left = 0

/obj/item/gun/projectile/shotgun/boltaction/enchanted/attack_self()
	return

/obj/item/gun/projectile/shotgun/boltaction/enchanted/shoot_live_shot(mob/living/user, atom/target, pointblank = FALSE, message = TRUE)
	..()
	if(guns_left)
		var/obj/item/gun/projectile/shotgun/boltaction/enchanted/GUN = new type
		GUN.guns_left = guns_left - 1
		discard_gun(user)
		user.swap_hand()
		user.drop_from_active_hand()
		user.put_in_hands(GUN)
	else
		discard_gun(user)

/obj/item/gun/projectile/shotgun/boltaction/enchanted/proc/discard_gun(mob/living/user)
	user.visible_message(span_warning("[user] tosses aside the spent rifle!"))
	user.throw_item(pick(oview(7, get_turf(user))))

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage
	name = "arcane barrage"
	desc = "Pew Pew Pew."
	fire_sound = 'sound/weapons/emitter.ogg'
	icon_state = "arcane_barrage"
	item_state = "arcane_barrage"
	slot_flags = null
	item_flags = NOBLUDGEON|DROPDEL|ABSTRACT
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/examine(mob/user)
	var/f_name = "\a [src]."
	. = list("[get_examine_icon(user)] That's [f_name]")
	. += desc // Override since magical hand lasers don't have chambers or bolts

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/discard_gun(mob/living/user)
	qdel(src)

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/blood
	name = "blood bolt barrage"
	desc = "Blood for blood."
	item_state = "disintegrate"
	lefthand_file = 'icons/mob/inhands/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/melee_righthand.dmi'
	color = "#ff0000"
	guns_left = 24
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage/blood
	fire_sound = 'sound/magic/wand_teleport.ogg'
	pickup_sound = 'sound/effects/splat.ogg'
	drop_sound = 'sound/effects/splat.ogg'
	item_flags = NOBLUDGEON|DROPDEL
