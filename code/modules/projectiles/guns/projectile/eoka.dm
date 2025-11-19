/// Delay before shot (trigger process)
#define EOKA_SHOT_DELAY (0.6 SECONDS)
/// Repair broken eoka duration with welder
#define EOKA_REPAIR_DURATION (8 SECONDS)
/// Chance of process fire on trigger (after do_after delay)
#define EOKA_SHOT_CHANCE 50
// Shot modifiers chances
#define EOKA_BROKE_CHANCE 20
#define EOKA_SELF_FIRE_CHANCE 10
#define EOKA_MISFIRE_CHANCE 15

// Eoka gun from rust
/obj/item/gun/projectile/eoka
	name = "eoka pistol"
	desc = "Самодельный одноразовый пистолет, в котором отсутствует надежный спусковой механизм. \
	Вместо этого пистолет активируется искрой от камня, который ударяется в верхней части оружия. \
	Из-за ненадёжности этого метода, оружие может взорваться в руках."
	icon = 'icons/obj/weapons/handmade.dmi'
	icon_state = "eoka"
	item_state = "eoka"
	mag_type = /obj/item/ammo_box/magazine/internal/eoka
	fire_sound = 'sound/weapons/gunshots/1grenlauncher.ogg'
	w_class = WEIGHT_CLASS_SMALL
	weapon_weight = WEAPON_LIGHT
	accuracy = GUN_ACCURACY_MINIMAL
	recoil = GUN_RECOIL_MEGA
	var/broken = FALSE

/obj/item/gun/projectile/eoka/get_ru_names()
	return list(
		NOMINATIVE = "самодельный пистолет",
		GENITIVE = "самодельного пистолета",
		DATIVE = "самодельному пистолету",
		ACCUSATIVE = "самодельный пистолет",
		INSTRUMENTAL = "самодельным пистолетом",
		PREPOSITIONAL = "самодельном пистолете",
	)

/obj/item/gun/projectile/eoka/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/ammo_casing))
		add_fingerprint(user)
		if(chambered)
			balloon_alert(user, "уже заряжено!")
			return ATTACK_CHAIN_PROCEED
		var/loaded = magazine.reload(item, user, silent = TRUE)
		if(loaded)
			balloon_alert(user, "заряжено")
			chambered = magazine.get_round(TRUE)
			return ATTACK_CHAIN_BLOCKED_ALL
		balloon_alert(user, "не удалось!")
		return ATTACK_CHAIN_PROCEED
	return ..()

/obj/item/gun/projectile/eoka/welder_act(mob/user, obj/item/welder)
	. = TRUE
	if(!broken)
		balloon_alert(user, "не требует ремонта")
		return

	if(welder.use_tool(src, user, EOKA_REPAIR_DURATION, volume = welder.tool_volume))
		WELDER_REPAIR_SUCCESS_MESSAGE
		broken = FALSE

/obj/item/gun/projectile/eoka/update_icon_state()
	icon_state = initial(icon_state) + (broken ?  "-broken" : "")

/obj/item/gun/projectile/eoka/process_chamber(eject_casing = TRUE, empty_chamber = TRUE)
	..(TRUE, TRUE)
	chambered = null

/obj/item/gun/projectile/eoka/get_ammo(countchambered = FALSE, countempties = FALSE)
	return ..(countchambered, countempties)

/obj/item/gun/projectile/eoka/can_shoot(mob/user)
	if(broken)
		return FALSE
	if(!chambered)
		return FALSE
	return (chambered.BB ? TRUE : FALSE)

/obj/item/gun/projectile/eoka/unload_act(mob/user)
	chambered = null
	var/atom/drop_loc = drop_location()
	while(get_ammo(countempties = TRUE) > 0)
		var/obj/item/ammo_casing/casing
		casing = magazine.get_round(FALSE)
		if(!casing)
			continue
		casing.forceMove(drop_loc)
		casing.pixel_x = rand(-10, 10)
		casing.pixel_y = rand(-10, 10)
		casing.setDir(pick(GLOB.alldirs))
		casing.update_appearance()
		casing.SpinAnimation(10, 1)
		playsound(drop_loc, casing.casing_drop_sound, 60, TRUE)
	playsound(loc, 'sound/weapons/bombarda/pump.ogg', 60, TRUE)
	update_icon()

/obj/item/gun/projectile/eoka/chamber_round(spin = TRUE)
	if(!magazine)
		return
	if(spin)
		chambered = magazine.get_round(TRUE)
		return
	if(!length(magazine.stored_ammo))
		return
	chambered = magazine.stored_ammo[1]

/obj/item/gun/projectile/eoka/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	if(!do_after(user, EOKA_SHOT_DELAY, user, interaction_key = src, timed_action_flags = DA_IGNORE_LYING | DA_IGNORE_USER_LOC_CHANGE, max_interact_count = 1))
		return
	if(!prob(EOKA_SHOT_CHANCE))
		//try again (with recusrion)
		return process_fire(target, user, message, params, zone_override, bonus_spread)
	if(prob(EOKA_BROKE_CHANCE))
		//TODO broke sound
		broken = TRUE
		QDEL_NULL(chambered.BB)
		unload_act(user)
		return
	if(prob(EOKA_SELF_FIRE_CHANCE))
		. = ..(user, user, message, params, BODY_ZONE_HEAD, bonus_spread)
		user.emote("scream")
		return
	if(prob(EOKA_MISFIRE_CHANCE))
		balloon_alert(user, "осечка!")
		return
	. = ..()
	unload_act(user)

/obj/item/ammo_box/magazine/internal/eoka
	name = "eoka pistol internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
	caliber = CALIBER_12X70
	max_ammo = 1
	insert_sound = 'sound/weapons/bombarda/load.ogg'
	remove_sound = 'sound/weapons/bombarda/open.ogg'
	load_sound = 'sound/weapons/bombarda/load.ogg'
	start_empty = TRUE
