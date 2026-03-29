/datum/action/innate/mecha/mech_toggle_flashlights
	name = "Включить мигалки"
	desc = "Переключить мигалки."
	button_icon_state = "mech_flashlights"
	var/in_use = FALSE

/datum/action/innate/mecha/mech_toggle_flashlights/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(istype(chassis, /obj/mecha/combat/hercules))
		var/obj/mecha/combat/hercules/mecha = chassis
		if(mecha.flashlights_working)
			mecha.soundloop.stop()
			mecha.flashlights_working = FALSE
			mecha.update_icon(UPDATE_OVERLAYS)
			button_icon_state = "mech_flashlights"
			UpdateButtonIcon()
			return
		mecha.soundloop.start()
		mecha.flashlights_working = TRUE
		mecha.update_icon(UPDATE_OVERLAYS)
		button_icon_state = "mech_flashlights-on"
		UpdateButtonIcon()

/datum/action/innate/mecha/mech_toggle_stunbaton
	name = "Переключить электро-шокеры"
	desc = "Переключить встроенный стан-батон экзокостюма."
	button_icon_state = "mech_stun"
	var/in_use = FALSE
	var/old_damage_type = null

/datum/action/innate/mecha/mech_toggle_stunbaton/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(istype(chassis, /obj/mecha/combat/hercules))
		var/obj/mecha/combat/hercules/mecha = chassis
		if(mecha.stun_enabled)
			mecha.damtype = old_damage_type
			mecha.stun_enabled = FALSE
			button_icon_state = "mech_stun"
			mecha.balloon_alert(mecha.occupant, "электрошокеры отключены")
			UpdateButtonIcon()
			return
		old_damage_type = mecha.damtype
		mecha.damtype = STAMINA
		mecha.stun_enabled = TRUE
		playsound(mecha, SFX_SPARKS, HALFWAY_SOUND_VOLUME, TRUE)
		mecha.balloon_alert(mecha.occupant, "электрошокеры включены")
		button_icon_state = "mech_stun-on"
		UpdateButtonIcon()

/obj/mecha/combat/hercules
	name = "Hercules"
	desc = "Modified \"Ripley\", created specially for security forces"
	icon_state = "hercules"
	initial_icon = "hercules"
	force = 15
	step_in = 6
	max_temperature = 20000
	max_integrity = 250
	lights_power = 10
	deflect_chance = 20
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 60, BIO = 0, FIRE = 100, ACID = 100)
	wreckage = /obj/structure/mecha_wreckage/hercules
	stepsound = 'sound/mecha/ripley_step.ogg'
	operation_req_access = list(ACCESS_BRIG)
	var/builtin_hud_user = FALSE
	/// Integrated stunbaton status
	var/stun_enabled = FALSE
	var/datum/action/innate/mecha/mech_toggle_stunbaton/stun_action = new
	/// overlays and action for flashlights
	var/datum/looping_sound/ambulance_alarm/soundloop
	var/flashlights_working = FALSE
	var/flashlights_overlay
	var/flashlights_overlay_working
	var/datum/action/innate/mecha/mech_toggle_flashlights/flashlights_action = new

	ui_theme = "security"

	mech_type = MECH_TYPE_HERCULES

/obj/mecha/combat/hercules/GrantActions(mob/living/user, human_occupant = 0)
	..()
	flashlights_action.Grant(user, src)
	stun_action.Grant(user, src)

/obj/mecha/combat/hercules/RemoveActions(mob/living/user, human_occupant = 0)
	..()
	flashlights_action.Remove(user, src)
	stun_action.Remove(user, src)

/obj/mecha/combat/hercules/Initialize(mapload)
	. = ..()
	/// Initialize overlays
	flashlights_overlay = image('icons/obj/mecha/flashlights.dmi', src, "flashlights")
	flashlights_overlay_working = image('icons/obj/mecha/flashlights.dmi', src, "flashlights-working")

	/// Initialize equipment
	var/obj/item/mecha_parts/mecha_equipment/equipment = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/disabler/lightweight
	equipment.attach(src)

	equipment = new /obj/item/mecha_parts/mecha_equipment/cage
	equipment.attach(src)

	trackers += new /obj/item/mecha_parts/mecha_tracking(src)

	update_icon(UPDATE_OVERLAYS)
	soundloop = new(src)

/obj/mecha/combat/hercules/Destroy()
	. = ..()
	QDEL_NULL(soundloop)

/obj/mecha/combat/hercules/update_overlays()
	. = ..()
	if(flashlights_working)
		add_overlay(flashlights_overlay_working)
	else
		add_overlay(flashlights_overlay)

/obj/mecha/combat/hercules/moved_inside(mob/living/carbon/human/H)
	. = ..()
	if(. && ishuman(H))
		if(istype(H.glasses, /obj/item/clothing/glasses/hud))
			occupant_message(span_warning("[H.glasses] prevent you from using the built-in security hud."))
		else
			var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
			hud.show_to(H)
			builtin_hud_user = TRUE

/obj/mecha/combat/hercules/mmi_moved_inside(obj/item/mmi/mmi_as_oc, mob/user)
	. = ..()
	if(.)
		if(occupant.client)
			var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
			hud.show_to(occupant)
			builtin_hud_user = TRUE

/obj/mecha/combat/hercules/proc/remove_builin_hud()
	if(!builtin_hud_user)
		return
	var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
	hud.hide_from(occupant)
	builtin_hud_user = FALSE

/obj/mecha/combat/hercules/go_out()
	remove_builin_hud()

	. = ..()
