/**
 * Objects here function like an energy gun,
 * but aren't inherited from /obj/item/gun/energy/gun for some reason
 */

// MARK: L.W.A.P. Energy Sniper
/obj/item/gun/energy/sniperrifle
	name = "L.W.A.P. Sniper Rifle"
	desc = "A rifle constructed of lightweight materials, fitted with a SMART aiming-system scope."
	icon_state = "esniper"
	origin_tech = "combat=6;materials=5;powerstorage=4"
	ammo_type = list(/obj/item/ammo_casing/energy/sniper)
	item_state = null
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	can_holster = FALSE
	zoomable = TRUE
	zoom_amt = 7 //Long range, enough to see in front of you, but no tiles behind you.
	shaded_charge = TRUE
	accuracy = GUN_ACCURACY_SNIPER

/obj/item/gun/energy/sniperrifle/pod_pilot
	name = "LSR-39 Queen blade"
	desc = "Прототип компактной лазерной снайперской винтовки с парализующим и летальным режимом стрельбы, оснащена большим оптическим прицелом для эффективной работы в открытом космосе."
	icon_state = "LSR-39"
	ammo_type = list(
		/obj/item/ammo_casing/energy/podsniper/disabler,
		/obj/item/ammo_casing/energy/podsniper/laser,
	)
	item_state = null
	weapon_weight = WEAPON_MEDIUM
	w_class = WEIGHT_CLASS_BULKY
	charge_sections = 3
	modifystate = TRUE
	accuracy = GUN_ACCURACY_SNIPER

// MARK: Dominator
/obj/item/gun/energy/dominator
	name = "Доминатор"
	desc = "Проприетарное высокотехнологичное оружие правоохранительной организации Sibyl System, произведённое специально для борьбы с преступностью."
	icon = 'icons/obj/weapons/dominator.dmi'
	icon_state = "dominator"
	base_icon_state = "dominator"
	item_state = null
	force = 10
	resistance_flags = INDESTRUCTIBLE|LAVA_PROOF|FIRE_PROOF|ACID_PROOF
	origin_tech = "combat=4;magnets=4"
	cell_type = /obj/item/stock_parts/cell/dominator
	modifystate = TRUE
	shaded_charge = TRUE
	charge_sections = 3
	ammo_type = list(
		/obj/item/ammo_casing/energy/dominator/stun,
		/obj/item/ammo_casing/energy/dominator/paralyzer,
		/obj/item/ammo_casing/energy/dominator/eliminator,
	)
	/// Sounds played after selecting the firemode, must be in the same order as ammo_type
	var/sound_voice = list(
		null,
		'sound/voice/dominator/nonlethal-paralyzer.ogg',
		'sound/voice/dominator/lethal-eliminator.ogg',
		'sound/voice/dominator/execution-slaughter.ogg',
	)
	/// Whether we are currently equipped or not.
	/// Its rather this variable or delayed icon update on dropped.
	var/is_equipped = FALSE
	/// Timestamp used for sound effects
	COOLDOWN_DECLARE(last_sound_effect)
	accuracy = GUN_ACCURACY_PISTOL
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_RAIL | GUN_MODULE_CLASS_PISTOL_UNDER | GUN_MODULE_CLASS_ENERGY_WEAPON
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = -3, ATTACHMENT_OFFSET_Y = 7),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 7, ATTACHMENT_OFFSET_Y = -8),
	)

/obj/item/gun/energy/dominator/sibyl/Initialize(mapload)
	. = ..()
	install_sibyl()

/obj/item/gun/energy/dominator/select_fire(mob/living/user)
	. = ..()
	if(sibyl_mod && sibyl_mod.voice_is_enabled && sound_voice[select] && COOLDOWN_FINISHED(src, last_sound_effect))
		user.playsound_local(user, sound_voice[select], 50, FALSE)
		COOLDOWN_START(src, last_sound_effect, 2 SECONDS)

/obj/item/gun/energy/dominator/update_icon_state()
	. = ..()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(cell.charge < shot.e_cost)
		item_state = "[base_icon_state]_empty"
	else
		item_state = "[base_icon_state]_[shot.select_name]"

/obj/item/gun/energy/dominator/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	is_equipped = TRUE
	update_icon()

/obj/item/gun/energy/dominator/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	is_equipped = FALSE
	update_icon()

// MARK: Specter pistol
/obj/item/gun/energy/specter
	name = "Specter"
	desc = "Современный пистолет \"Спектр\", работающий на съёмных аккумуляторах, имеет магнитные приводы для быстрой перезарядки. Поставляется только силовым структурам \"Нанотрейзен\"."
	icon_state = "specter"
	item_state = "specter"
	force = 10
	origin_tech = "combat=4;materials=2"
	cell_type = /obj/item/stock_parts/cell/specter
	var/obj/item/weapon_cell/magazine = new /obj/item/weapon_cell/specter()
	ammo_type = list(/obj/item/ammo_casing/energy/specter/disable, /obj/item/ammo_casing/energy/specter/laser)
	materials = list(MAT_METAL = 1000)
	accuracy = GUN_ACCURACY_PISTOL
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_RAIL | GUN_MODULE_CLASS_PISTOL_UNDER | GUN_MODULE_CLASS_ENERGY_WEAPON
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 0, ATTACHMENT_OFFSET_Y = 8),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 8, ATTACHMENT_OFFSET_Y = -3),
	)
	ammo_x_offset = 0
	actions_types = list(/datum/action/item_action/toggle_firemode)

/obj/item/gun/energy/specter/sibyl/Initialize(mapload)
	. = ..()
	install_sibyl()

/obj/item/gun/energy/specter/get_ru_names()
	return list(
		NOMINATIVE = "Спектр",
		GENITIVE = "Спектра",
		DATIVE = "Спектру",
		ACCUSATIVE = "Спектр",
		INSTRUMENTAL = "Спектром",
		PREPOSITIONAL = "Спектре",
	)

/obj/item/gun/energy/specter/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/ammo_alarm, 'sound/weapons/gun_interactions/spec_magout.ogg')
	AddElement(/datum/element/item_skins, item_path = /obj/item/gun/energy/specter)

/obj/item/gun/energy/specter/update_icon_state()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(current_skin)
		icon_state = "[current_skin][magazine && magazine.is_available_shot(shot.e_cost) ? "" : "-e"]"
	else
		icon_state = "[initial(icon_state)][magazine && magazine.is_available_shot(shot.e_cost) ? "" : "-e"]"

/obj/item/gun/energy/specter/can_shoot(mob/living/user, silent)
	if(!magazine)
		return FALSE
	return ..()

/obj/item/gun/energy/specter/attackby(obj/item/item, mob/user, params)
	if(!is_spectercell(item))
		return ..()
	add_fingerprint(user)
	if(!user.drop_transfer_item_to_loc(item, src))
		balloon_alert(user, "отпустить невозможно!")
		return ATTACK_CHAIN_PROCEED
	if(magazine)
		magazine.update_icon(UPDATE_OVERLAYS)
		user.put_in_hands(magazine)
	cell = item.get_cell()
	cell_type = cell.type
	magazine = item
	balloon_alert(user, "батарейка заменена")
	update_icon(UPDATE_ICON_STATE)
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(magazine.is_available_shot(shot.e_cost))
		playsound(loc, 'sound/weapons/gun_interactions/spec_magin.ogg', 50, TRUE)
	return ATTACK_CHAIN_PROCEED

/obj/item/gun/energy/specter/ui_action_click(mob/user, datum/action/action, leftclick)
	if(istype(action, /datum/action/item_action/toggle_firemode))
		if(length(ammo_type) > 1)
			select_fire(user)
			update_icon()
		return TRUE
	return ..()

/obj/item/gun/energy/specter/attack_self(mob/living/user)
	if(!magazine)
		return ..()
	magazine.update_icon(UPDATE_OVERLAYS)
	user.put_in_hands(magazine)
	cell = null
	magazine = null
	update_icon(UPDATE_ICON_STATE)

// MARK: Emmitter gun
/obj/item/gun/energy/emittergun
	name = "Handicraft Emitter Rifle"
	desc = "A rifle constructed of some trash materials. Looks rough but very powerful."
	icon_state = "emittercannonvgovne"
	item_state = null
	origin_tech = "combat=3;materials=3;powerstorage=2;magnets=2"
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	can_holster = FALSE
	cell_type = /obj/item/stock_parts/cell/emittergun
	ammo_type = list(/obj/item/ammo_casing/energy/emittergun)
	accuracy = GUN_ACCURACY_MINIMAL
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 0, ATTACHMENT_OFFSET_Y = 7),
	)

// MARK: Ion Rifle
/obj/item/gun/energy/ionrifle
	name = "ion rifle"
	desc = "A man portable anti-armor weapon designed to disable mechanical threats"
	icon_state = "ionrifle"
	item_state = null	//so the human update icon uses the icon_state instead.
	fire_sound = 'sound/weapons/ionrifle.ogg'
	origin_tech = "combat=4;magnets=4"
	w_class = WEIGHT_CLASS_HUGE
	can_holster = FALSE
	slot_flags = ITEM_SLOT_BACK
	zoomable = TRUE
	zoom_amt = 7
	ammo_type = list(/obj/item/ammo_casing/energy/ion)
	ammo_x_offset = 3
	accuracy = GUN_ACCURACY_RIFLE_LASER

/obj/item/gun/energy/ionrifle/emp_act(severity)
	return

/obj/item/gun/energy/ionrifle/carbine
	name = "ion carbine"
	desc = "The MK.II Prototype Ion Projector is a lightweight carbine version of the larger ion rifle, built to be ergonomic and efficient."
	icon_state = "ioncarbine"
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	zoomable = FALSE
	ammo_x_offset = 2
	accuracy = GUN_ACCURACY_RIFLE_LASER
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 9, ATTACHMENT_OFFSET_Y = 8),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 7, ATTACHMENT_OFFSET_Y = -4),
	)
