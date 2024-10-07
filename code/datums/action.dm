#define BUTTON_LAYER_ICON -4
#define BUTTON_LAYER_UNAVAILABLE -3
#define BUTTON_LAYER_MAPTEXT -2
#define BUTTON_LAYER_SELECTOR -1

/datum/action
	var/name = "Generic Action"
	var/desc = null
	var/obj/target = null
	var/check_flags = 0
	var/invisibility = FALSE
	var/atom/movable/screen/movable/action_button/button = null
	var/button_icon = 'icons/mob/actions/actions.dmi'
	var/button_icon_state = "default"
	var/background_icon
	var/background_icon_state = "bg_default"
	var/buttontooltipstyle = ""
	var/icon_icon = 'icons/mob/actions/actions.dmi'
	var/mob/owner

/datum/action/New(Target)
	target = Target
	button = new
	button.linked_action = src
	button.name = name
	button.actiontooltipstyle = buttontooltipstyle
	button.desc = desc

/datum/action/Destroy()
	if(owner)
		Remove(owner)
	if(target)
		target = null
	QDEL_NULL(button)
	return ..()


/datum/action/proc/Grant(mob/user)
	if(owner)
		if(owner == user)
			return FALSE
		Remove(owner)
	owner = user
	owner.actions += src

	if(owner.client)
		owner.client.screen += button
		button.locked = TRUE
	owner.update_action_buttons()

	if(check_flags & AB_CHECK_CONSCIOUS)
		RegisterSignal(owner, COMSIG_MOB_STATCHANGE, PROC_REF(update_status_on_signal))
	if(check_flags & AB_CHECK_LYING)
		RegisterSignal(owner, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(update_status_on_signal))
	if(check_flags & AB_CHECK_IMMOBILE)
		RegisterSignal(owner, list(SIGNAL_ADDTRAIT(TRAIT_IMMOBILIZED), SIGNAL_REMOVETRAIT(TRAIT_IMMOBILIZED)), PROC_REF(update_status_on_signal))
	if(check_flags & AB_CHECK_HANDS_BLOCKED && !isAI(owner))
		RegisterSignal(owner, list(SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED), SIGNAL_REMOVETRAIT(TRAIT_HANDS_BLOCKED)), PROC_REF(update_status_on_signal))
	if(check_flags & AB_CHECK_INCAPACITATED)
		RegisterSignal(owner, list(SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED), SIGNAL_REMOVETRAIT(TRAIT_INCAPACITATED)), PROC_REF(update_status_on_signal))
	return TRUE


/datum/action/proc/Remove(mob/user)
	owner = null
	if(!user)
		return FALSE

	if(user.client)
		user.client.screen -= button
		button.clean_up_keybinds(user)

	button.moved = FALSE //so the button appears in its normal position when given to another owner.
	button.locked = FALSE
	user.actions -= src
	user.update_action_buttons()

	// Clean up our check_flag signals
	UnregisterSignal(user, list(
		COMSIG_MOB_STATCHANGE,
		COMSIG_LIVING_SET_BODY_POSITION,
		SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED),
		SIGNAL_ADDTRAIT(TRAIT_IMMOBILIZED),
		SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED),
		SIGNAL_REMOVETRAIT(TRAIT_HANDS_BLOCKED),
		SIGNAL_REMOVETRAIT(TRAIT_IMMOBILIZED),
		SIGNAL_REMOVETRAIT(TRAIT_INCAPACITATED),
	))

	return TRUE


/// A general use signal proc that reacts to an event and updates JUST our button
/datum/action/proc/update_status_on_signal(datum/source, new_stat, old_stat)
	SIGNAL_HANDLER
	UpdateButtonIcon()


/datum/action/proc/Trigger(left_click = TRUE)
	if(!IsAvailable())
		return FALSE
	return TRUE

/datum/action/proc/AltTrigger()
	Trigger()

/datum/action/proc/Process()
	return

/datum/action/proc/override_location() // Override to set coordinates manually
	return


/datum/action/proc/enable_invisibility(enable = TRUE)
	if(!owner?.client)
		return
	if(enable)
		if(invisibility)
			return
		invisibility = TRUE
		owner.client.screen -= button
		owner.actions -= src
	else
		if(!invisibility)
			return
		invisibility = FALSE
		owner.client.screen += button
		owner.actions += src
	owner.update_action_buttons()


/datum/action/proc/IsAvailable()// returns 1 if all checks pass
	if(!owner)
		return FALSE
	if((check_flags & AB_CHECK_HANDS_BLOCKED) && HAS_TRAIT(owner, TRAIT_HANDS_BLOCKED) && !isAI(owner))
		return FALSE
	if((check_flags & AB_CHECK_IMMOBILE) && HAS_TRAIT(owner, TRAIT_IMMOBILIZED))
		return FALSE
	if((check_flags & AB_CHECK_INCAPACITATED) && HAS_TRAIT_NOT_FROM(owner, TRAIT_INCAPACITATED, STAT_TRAIT))
		return FALSE
	if((check_flags & AB_CHECK_LYING) && owner.IsLying())
		return FALSE
	if((check_flags & AB_CHECK_CONSCIOUS) && owner.stat)
		return FALSE
	if((check_flags & AB_CHECK_TURF) && !isturf(owner.loc))
		return FALSE
	return TRUE


/datum/action/proc/UpdateButtonIcon()
	if(!button)
		return FALSE

	if(owner?.client && background_icon_state == "bg_default") // If it's a default action background, apply the custom HUD style
		button.alpha = owner.client.prefs.UI_style_alpha
		button.color = owner.client.prefs.UI_style_color
		button.icon = ui_style2icon(owner.client.prefs.UI_style)
		button.icon_state = "template"
	else
		if(background_icon)
			button.icon = background_icon
		else
			button.icon = button_icon
		button.icon_state = background_icon_state

	button.name = name
	button.desc = desc

	ApplyIcon()

	toggle_active_overlay()

	var/obj/effect/proc_holder/spell/spell = target
	if(!IsAvailable() || istype(spell) && spell.cooldown_handler.should_draw_cooldown())
		apply_unavailable_effect()
		return FALSE
	return TRUE


/datum/action/proc/apply_unavailable_effect()
	var/static/mutable_appearance/unavailable_effect = mutable_appearance('icons/mob/screen_white.dmi', "template", BUTTON_LAYER_UNAVAILABLE, alpha = 200, appearance_flags = RESET_COLOR|RESET_ALPHA, color = "#000000")
	button.add_overlay(unavailable_effect)


/datum/action/proc/ApplyIcon()
	button.cut_overlays()
	if(!icon_icon || !button_icon_state)
		return
	var/mutable_appearance/new_icon = mutable_appearance(icon_icon, button_icon_state, BUTTON_LAYER_ICON, appearance_flags = RESET_COLOR|RESET_ALPHA)
	button.add_overlay(new_icon)


/datum/action/proc/toggle_active_overlay()
	return


//Presets for item actions
/datum/action/item_action
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	/// Whether action trigger should call attack self proc.
	var/attack_self = TRUE
	var/use_itemicon = TRUE
	var/action_initialisation_text = null	//Space ninja abilities only

/datum/action/item_action/New(Target, custom_icon, custom_icon_state)
	..()
	var/obj/item/I = target
	LAZYADD(I.actions, src)
	if(custom_icon && custom_icon_state)
		use_itemicon = FALSE
		icon_icon = custom_icon
		button_icon_state = custom_icon_state

/datum/action/item_action/Destroy()
	var/obj/item/I = target
	LAZYREMOVE(I.actions, src)
	return ..()

/datum/action/item_action/Trigger(left_click = TRUE)
	if(!..())
		return FALSE
	if(target && attack_self)
		var/obj/item/I = target
		I.ui_action_click(owner, src, left_click)
	return TRUE


/datum/action/item_action/ApplyIcon()
	button.cut_overlays()
	if(!use_itemicon)
		return ..()
	if(!target)
		return
	var/mutable_appearance/new_icon = mutable_appearance(target.icon, target.icon_state, BUTTON_LAYER_ICON, appearance_flags = RESET_COLOR|RESET_ALPHA)
	new_icon.copy_overlays(target)
	button.add_overlay(new_icon)


/datum/action/item_action/toggle_light
	name = "Toggle Light"

/datum/action/item_action/toggle_hood
	name = "Toggle Hood"

/datum/action/item_action/toggle_firemode
	name = "Toggle Firemode"

/datum/action/item_action/startchainsaw
	name = "Pull The Starting Cord"

/datum/action/item_action/print_report
	name = "Print Report"

/datum/action/item_action/print_forensic_report
	name = "Print Report"
	button_icon_state = "scanner_print"
	use_itemicon = FALSE

/datum/action/item_action/clear_records
	name = "Clear Scanner Records"

/datum/action/item_action/toggle_gunlight
	name = "Toggle Gunlight"

/datum/action/item_action/toggle_mode
	name = "Toggle Mode"

/datum/action/item_action/toggle_barrier_spread
	name = "Toggle Barrier Spread"

/datum/action/item_action/equip_unequip_TED_Gun
	name = "Equip/Unequip TED Gun"

/datum/action/item_action/toggle_paddles
	name = "Toggle Paddles"

/datum/action/item_action/set_internals
	name = "Set Internals"

/datum/action/item_action/set_internals/UpdateButtonIcon()
	if(..()) //button available
		if(iscarbon(owner))
			var/mob/living/carbon/C = owner
			if(target == C.internal)
				button.icon = 'icons/mob/actions/actions.dmi'
				button.icon_state = "bg_default_on"

/datum/action/item_action/set_internals_ninja
	name = "Set Internals"
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"

/datum/action/item_action/set_internals_ninja/UpdateButtonIcon()
	if(..()) //button available
		if(iscarbon(owner))
			var/mob/living/carbon/C = owner
			if(target == C.internal)
				button.icon_state = "[background_icon_state]_active"

/datum/action/item_action/toggle_mister
	name = "Toggle Mister"

/datum/action/item_action/toggle_helmet_light
	name = "Toggle Helmet Light"

/datum/action/item_action/toggle_welding_screen/plasmaman
	name = "Toggle Welding Screen"

/datum/action/item_action/toggle_helmet_mode
	name = "Toggle Helmet Mode"

/datum/action/item_action/toggle_hardsuit_mode
	name = "Toggle Hardsuit Mode"

/datum/action/item_action/toggle_unfriendly_fire
	name = "Toggle Friendly Fire \[ON\]"
	desc = "Toggles if the club's blasts cause friendly fire."
	button_icon_state = "vortex_ff_on"

/datum/action/item_action/toggle_unfriendly_fire/Trigger(left_click = TRUE)
	if(..())
		UpdateButtonIcon()

/datum/action/item_action/toggle_unfriendly_fire/UpdateButtonIcon()
	if(istype(target, /obj/item/hierophant_club))
		var/obj/item/hierophant_club/H = target
		if(H.friendly_fire_check)
			button_icon_state = "vortex_ff_off"
			name = "Toggle Friendly Fire \[OFF\]"
			button.name = name
		else
			button_icon_state = "vortex_ff_on"
			name = "Toggle Friendly Fire \[ON\]"
			button.name = name
	..()

/datum/action/item_action/vortex_recall
	name = "Vortex Recall"
	desc = "Recall yourself, and anyone nearby, to an attuned hierophant beacon at any time.<br>If the beacon is still attached, will detach it."
	button_icon_state = "vortex_recall"

/datum/action/item_action/vortex_recall/IsAvailable()
	if(istype(target, /obj/item/hierophant_club))
		var/obj/item/hierophant_club/H = target
		if(H.teleporting)
			return FALSE
	return ..()

/datum/action/item_action/change_headphones_song
	name = "Change Headphones Song"

/datum/action/item_action/toggle

/datum/action/item_action/toggle/New(Target)
	..()
	name = "Toggle [target.name]"
	button.name = name

/datum/action/item_action/openclose

/datum/action/item_action/openclose/New(Target)
	..()
	name = "Open/Close [target.name]"
	button.name = name

/datum/action/item_action/button

/datum/action/item_action/button/New(Target)
	..()
	name = "Button/Unbutton [target.name]"
	button.name = name

/datum/action/item_action/zipper

/datum/action/item_action/zipper/New(Target)
	..()
	name = "Zip/Unzip [target.name]"
	button.name = name

/datum/action/item_action/activate

/datum/action/item_action/activate/New(Target)
	..()
	name = "Activate [target.name]"
	button.name = name

/datum/action/item_action/activate/enchant

/datum/action/item_action/activate/enchant/New(Target)
	..()
	UpdateButtonIcon()
/datum/action/item_action/halt
	name = "HALT!"

/datum/action/item_action/selectphrase
	name = "Change Phrase"

/datum/action/item_action/hoot
	name = "Hoot"

/datum/action/item_action/caw
	name = "Caw"

/datum/action/item_action/toggle_voice_box
	name = "Toggle Voice Box"

/datum/action/item_action/change
	name = "Change"

/datum/action/item_action/noir
	name = "Noir"

/datum/action/item_action/YEEEAAAAAHHHHHHHHHHHHH
	name = "YEAH!"

/datum/action/item_action/laugh_track
	name = "Laugh Track"

/datum/action/item_action/adjust

/datum/action/item_action/adjust/New(Target)
	..()
	name = "Adjust [target.name]"
	button.name = name

/datum/action/item_action/pontificate
	name = "Pontificate Evilly"

/datum/action/item_action/tip_fedora
	name = "Tip Fedora"

/datum/action/item_action/flip_cap
	name = "Flip Cap"

/datum/action/item_action/switch_hud
	name = "Switch HUD"

/datum/action/item_action/toggle_wings
	name = "Toggle Wings"

/datum/action/item_action/toggle_helmet
	name = "Toggle Helmet"

/datum/action/item_action/remove_tape
	name = "Remove Duct Tape"
	attack_self = FALSE

/datum/action/item_action/remove_tape/Trigger(left_click = TRUE)
	if(..())
		var/component = target.GetComponent(/datum/component/ducttape)
		if(component)
			usr.transfer_fingerprints_to(target)
			to_chat(usr, span_notice("You tear the tape off [target]!"))
			qdel(component)

/datum/action/item_action/toggle_jetpack
	name = "Toggle Jetpack"

/datum/action/item_action/jetpack_stabilization
	name = "Toggle Jetpack Stabilization"

/datum/action/item_action/jetpack_stabilization/IsAvailable()
	var/obj/item/tank/jetpack/J = target
	if(!istype(J) || !J.on)
		return FALSE
	return ..()

/datum/action/item_action/toggle_jetpack/ninja
	name = "Toggle Jetpack"
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"

/datum/action/item_action/toggle_jetpack/ninja/apply_unavailable_effect()
	return

/datum/action/item_action/toggle_jetpack/ninja/UpdateButtonIcon()
	. = ..()
	var/obj/item/tank/jetpack/J = target
	if(!istype(J) || !J.on)
		button.icon_state = "[background_icon_state]"
	else
		button.icon_state = "[background_icon_state]_active"

/datum/action/item_action/jetpack_stabilization/ninja
	name = "Toggle Jetpack Stabilization"
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"

/datum/action/item_action/jetpack_stabilization/ninja/UpdateButtonIcon()
	. = ..()
	var/obj/item/tank/jetpack/J = target
	if(!istype(J) || !J.stabilize)
		button.icon_state = "[background_icon_state]"
	else
		button.icon_state = "[background_icon_state]_active"


/datum/action/item_action/hands_free
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/item_action/hands_free/activate
	name = "Activate"

/datum/action/item_action/hands_free/activate/always
	check_flags = NONE

/datum/action/item_action/toggle_research_scanner
	name = "Toggle Research Scanner"

/datum/action/item_action/toggle_research_scanner/Trigger(left_click = TRUE)
	if(IsAvailable())
		owner.research_scanner = !owner.research_scanner
		to_chat(owner, "<span class='notice'>Research analyzer is now [owner.research_scanner ? "active" : "deactivated"].</span>")
		return TRUE

/datum/action/item_action/toggle_research_scanner/Remove(mob/living/L)
	if(owner)
		owner.research_scanner = 0
	..()


/datum/action/item_action/toggle_research_scanner/ApplyIcon()
	button.cut_overlays()
	var/static/mutable_appearance/new_icon = mutable_appearance('icons/mob/actions/actions.dmi', "scan_mode", BUTTON_LAYER_ICON, appearance_flags = RESET_COLOR|RESET_ALPHA)
	button.add_overlay(new_icon)


/datum/action/item_action/instrument
	name = "Use Instrument"
	desc = "Use the instrument specified."

/datum/action/item_action/instrument/Trigger(left_click = TRUE)
	if(istype(target, /obj/item/instrument))
		var/obj/item/instrument/I = target
		I.interact(usr)
		return
	return ..()


/datum/action/item_action/remove_badge
	name = "Remove Holobadge"

// Jump boots
/datum/action/item_action/bhop
	name = "Activate Jump Boots"
	desc = "Activates the jump boot's internal propulsion system, allowing the user to dash over 4-wide gaps."
	icon_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "jetboot"

/datum/action/item_action/bhop/clown
	name = "Activate Honk Boots"
	desc = "Activates the jump boot's internal honk system, allowing the user to flip over 6-wide gaps."
	icon_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "clown"

/datum/action/item_action/gravity_jump
	name = "Gravity jump"
	desc = "Directs a pulse of gravity in front of the user, pulling them forward rapidly."
	attack_self = FALSE

/datum/action/item_action/gravity_jump/Trigger(left_click = TRUE)
	. = ..()
	if(!.)
		return FALSE

	var/obj/item/clothing/shoes/magboots/gravity/G = target
	G.dash(usr)

/datum/action/item_action/toggle_rapier_nodrop
	name = "Toggle Anti-Drop"
	desc = "Activates/deactivates CentComm rapier Anti-Drop."

///prset for organ actions
/datum/action/item_action/organ_action
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/item_action/organ_action/IsAvailable()
	var/obj/item/organ/internal/I = target
	if(!I.owner)
		return FALSE
	return ..()

/datum/action/item_action/organ_action/toggle

/datum/action/item_action/organ_action/toggle/New(Target)
	..()
	name = "Toggle [target.name]"
	button.name = name

/datum/action/item_action/organ_action/use/New(Target)
	..()
	name = "Use [target.name]"
	button.name = name

/datum/action/item_action/voice_changer/toggle
	name = "Toggle Voice Changer"

/datum/action/item_action/voice_changer/voice
	name = "Set Voice"

/datum/action/item_action/voice_changer/voice/Trigger(left_click = TRUE)
	if(!IsAvailable())
		return FALSE

	var/obj/item/voice_changer/V = target
	V.set_voice(usr)

// for clothing accessories like holsters
/datum/action/item_action/accessory
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED

/datum/action/item_action/accessory/IsAvailable()
	. = ..()
	if(!.)
		return FALSE
	if(target.loc == owner)
		return TRUE
	if(istype(target.loc, /obj/item/clothing/under) && target.loc.loc == owner)
		return TRUE
	return FALSE

/datum/action/item_action/accessory/holster
	name = "Holster"

/datum/action/item_action/accessory/holobadge
	name = "Holobadge"

/datum/action/item_action/accessory/storage
	name = "View Storage"

/datum/action/item_action/accessory/petcollar
	name = "Remove ID"

/datum/action/item_action/accessory/herald
	name = "Mirror Walk"
	desc = "Use near a mirror to enter it."

//Preset for spells
/datum/action/spell_action
	check_flags = 0
	background_icon_state = "bg_spell"
	var/recharge_text_color = "#FFFFFF"

/datum/action/spell_action/New(Target)
	..()
	var/obj/effect/proc_holder/spell/spell = target
	spell.action = src
	name = spell.name
	desc = spell.desc
	button_icon = spell.action_icon
	background_icon = spell.action_background_icon
	button_icon_state = spell.action_icon_state
	background_icon_state = spell.action_background_icon_state
	button.name = name

/datum/action/spell_action/Destroy()
	var/obj/effect/proc_holder/spell/S = target
	S.action = null
	return ..()

/datum/action/spell_action/Trigger(left_click = TRUE)
	if(!IsAvailable(TRUE))
		return FALSE

	if(target)
		var/obj/effect/proc_holder/spell = target
		spell.Click()
		return TRUE

/datum/action/spell_action/AltTrigger()
	if(target)
		var/obj/effect/proc_holder/spell/spell = target
		spell.AltClick(usr)
		return TRUE

/datum/action/spell_action/IsAvailable(message = FALSE)
	if(!target)
		return FALSE
	var/obj/effect/proc_holder/spell/spell = target

	if(owner)
		return spell.can_cast(owner, show_message = message)
	return FALSE


/datum/action/spell_action/toggle_active_overlay()
	var/obj/effect/proc_holder/spell/spell = target
	if(!istype(spell) || !spell.need_active_overlay)
		return
	var/static/mutable_appearance/selector = mutable_appearance('icons/mob/screen_gen.dmi', "selector", BUTTON_LAYER_SELECTOR, appearance_flags = RESET_COLOR|RESET_ALPHA)
	if(spell.active)
		button.add_overlay(selector)
	else
		button.cut_overlay(selector)


/datum/action/spell_action/ApplyIcon()
	button.cut_overlays()
	if(!button_icon || !button_icon_state)
		return
	var/mutable_appearance/new_icon = mutable_appearance(button_icon, button_icon_state, BUTTON_LAYER_ICON, appearance_flags = RESET_COLOR|RESET_ALPHA)
	button.add_overlay(new_icon)


/datum/action/spell_action/apply_unavailable_effect()
	var/obj/effect/proc_holder/spell/spell = target
	if(!istype(spell))
		return ..()
	var/mutable_appearance/unavailable_effect = mutable_appearance('icons/mob/screen_white.dmi', "template", BUTTON_LAYER_UNAVAILABLE, appearance_flags = RESET_COLOR|RESET_ALPHA, color = "#000000")
	unavailable_effect.alpha = spell.cooldown_handler.get_cooldown_alpha()
	button.add_overlay(unavailable_effect)
	// Make a holder for the charge text
	var/static/mutable_appearance/maptext_holder = mutable_appearance('icons/effects/effects.dmi', "nothing", BUTTON_LAYER_MAPTEXT, appearance_flags = RESET_COLOR|RESET_ALPHA)
	var/text = spell.cooldown_handler.cooldown_info()
	maptext_holder.maptext = "<div style=\"font-size:6pt;color:[recharge_text_color];font:'Small Fonts';text-align:center;\" valign=\"bottom\">[text]</div>"
	button.add_overlay(maptext_holder)


//Preset for general and toggled actions
/datum/action/innate
	check_flags = 0
	var/active = FALSE

/datum/action/innate/Trigger(left_click = TRUE)
	if(!..())
		return FALSE
	if(!active)
		Activate()
	else
		Deactivate()
	return TRUE

/datum/action/innate/proc/Activate()
	return

/datum/action/innate/proc/Deactivate()
	return

/datum/action/innate/research_scanner
	name = "Toggle Research Scanner"

/datum/action/innate/research_scanner/Trigger(left_click = TRUE)
	if(IsAvailable())
		owner.research_scanner = !owner.research_scanner
		to_chat(owner, "<span class='notice'>Research analyzer is now [owner.research_scanner ? "active" : "deactivated"].</span>")
		return TRUE

/datum/action/innate/research_scanner/Remove(mob/living/L)
	if(owner)
		owner.research_scanner = 0
	..()


/datum/action/innate/research_scanner/ApplyIcon()
	button.cut_overlays()
	var/static/mutable_appearance/new_icon = mutable_appearance('icons/mob/actions/actions.dmi', "scan_mode", BUTTON_LAYER_ICON, appearance_flags = RESET_COLOR|RESET_ALPHA)
	button.add_overlay(new_icon)


//Preset for action that call specific procs (consider innate)
/datum/action/generic
	check_flags = 0
	var/procname

/datum/action/generic/Trigger(left_click = TRUE)
	if(!..())
		return FALSE
	if(target && procname)
		call(target,procname)(usr)
	return TRUE

/datum/action/generic/configure_mmi_radio
	name = "Configure MMI Radio"
	desc = "Configure the radio installed in your MMI."
	check_flags = AB_CHECK_CONSCIOUS
	procname = "ui_interact"
	var/obj/item/mmi = null


/datum/action/generic/configure_mmi_radio/New(Target, obj/item/mmi/M)
	. = ..()
	mmi = M


/datum/action/generic/configure_mmi_radio/Destroy()
	mmi = null
	return ..()


/datum/action/generic/configure_mmi_radio/ApplyIcon()
	button.cut_overlays()
	if(!mmi)
		return
	var/mutable_appearance/new_icon = mutable_appearance(mmi.icon, mmi.icon_state, BUTTON_LAYER_ICON, appearance_flags = RESET_COLOR|RESET_ALPHA)
	new_icon.copy_overlays(mmi)
	button.add_overlay(new_icon)


// This item actions have their own charges/cooldown system like spell procholders, but without all the unnecessary magic stuff
/datum/action/item_action/advanced
	var/recharge_text_color = "#FFFFFF"
	var/charge_type = ADV_ACTION_TYPE_RECHARGE //can be recharge, toggle, toggle_recharge or charges, see description in the defines file
	var/charge_max = 100 //recharge time in deciseconds if charge_type = "recharge" or "toggle_recharge", alternatively counts as starting charges if charge_type = "charges"
	var/charge_counter = 0 //can only use if it equals "recharge" or "toggle_recharge", ++ each decisecond if charge_type = "recharge" or -- each cast if charge_type = "charges"
	var/starts_charged = TRUE //Does this action start ready to go?
	var/still_recharging_msg = "<span class='notice'> action is still recharging.</span>"
	//toggle and toggle_recharge stuff
	var/action_ready = TRUE //Only for toggle and toggle_recharge charge_type. Toggle it via code yourself. Haha 'toggle', get it?
	var/icon_state_active = "bg_default_on"	//What icon_state we switch to when we toggle action active in "toggle" actions
	var/icon_state_disabled = "bg_default"	//Old icon_state we switch to when we toggle action back in "toggle" actions
	//cooldown overlay stuff
	var/coold_overlay_icon = 'icons/mob/screen_white.dmi'
	var/coold_overlay_icon_state = "template"
	var/no_count = FALSE  // This means that the action is charged but unavailable due to something else
	var/wait_time = 2 SECONDS // Prevents spamming the button. Only for "charges" type actions
	var/last_use_time = null

/datum/action/item_action/advanced/New()
	. = ..()
	still_recharging_msg = "<span class='notice'>[name] is still recharging.</span>"
	icon_state_disabled = background_icon_state
	last_use_time = world.time
	if(charge_type == ADV_ACTION_TYPE_CHARGES)
		UpdateButtonIcon()
		add_charges_overlay()
	if(starts_charged)
		charge_counter = charge_max
	else
		start_recharge()

/datum/action/item_action/advanced/proc/start_recharge()
	UpdateButtonIcon()
	START_PROCESSING(SSfastprocess, src)

/datum/action/item_action/advanced/process()
	charge_counter += 2
	UpdateButtonIcon()
	if(charge_counter < charge_max)
		return
	STOP_PROCESSING(SSfastprocess, src)
	action_ready = TRUE
	charge_counter = charge_max

/datum/action/item_action/advanced/proc/recharge_action() //resets charge_counter or readds one charge
	switch(charge_type)
		if(ADV_ACTION_TYPE_RECHARGE)
			charge_counter = charge_max
		if(ADV_ACTION_TYPE_TOGGLE)	//this type doesn't use those var's, but why not
			charge_counter = charge_max
		if(ADV_ACTION_TYPE_TOGGLE_RECHARGE)
			charge_counter = charge_max
		if(ADV_ACTION_TYPE_CHARGES)
			charge_counter++
			UpdateButtonIcon()
			add_charges_overlay()

/datum/action/item_action/advanced/proc/use_action()
	if(!IsAvailable(show_message = TRUE))
		return
	switch(charge_type)
		if(ADV_ACTION_TYPE_RECHARGE)
			charge_counter = 0
			start_recharge()
		if(ADV_ACTION_TYPE_TOGGLE)
			toggle_button_on_off()
			action_ready = !action_ready
		if(ADV_ACTION_TYPE_TOGGLE_RECHARGE)
			charge_counter = 0
			start_recharge()
		if(ADV_ACTION_TYPE_CHARGES)
			charge_counter--
			last_use_time = world.time
			UpdateButtonIcon()
			add_charges_overlay()

/* Basic availability checks in this proc.
 * Arguments:
 * show_message - Do we show recharging message to the caller?
 * ignore_ready - Are we ignoring the "action_ready" flag? Usefull when u call this check indirrectly.
 */
/datum/action/item_action/advanced/IsAvailable(show_message = FALSE, ignore_ready = FALSE)
	if(!..())
		return FALSE
	switch(charge_type)
		if(ADV_ACTION_TYPE_RECHARGE)
			if(charge_counter < charge_max)
				if(show_message)
					to_chat(owner, still_recharging_msg)
				return FALSE
		if(ADV_ACTION_TYPE_TOGGLE_RECHARGE)
			if(charge_counter < charge_max)
				if(action_ready && !ignore_ready)
					return TRUE
				if(show_message)
					to_chat(owner, still_recharging_msg)
				return FALSE
		if(ADV_ACTION_TYPE_CHARGES)
			if(world.time < last_use_time + wait_time)
				if(show_message)
					to_chat(owner, "<span class='warning'>[name] is already being used.</span>")
				return FALSE
			if(!charge_counter)
				if(show_message)
					to_chat(owner, "<span class='notice'>[name] has no charges left.</span>")
				return FALSE
	return TRUE

/datum/action/item_action/advanced/proc/get_availability_percentage()
	switch(charge_type)
		if(ADV_ACTION_TYPE_RECHARGE)
			if(charge_counter == 0)
				return 0
			if(charge_max == 0)
				return 1
			return charge_counter / charge_max
		if(ADV_ACTION_TYPE_TOGGLE_RECHARGE)
			if(action_ready)
				return 1
			if(charge_counter == 0)
				return 0
			if(charge_max == 0)
				return 1
			return charge_counter / charge_max
		if(ADV_ACTION_TYPE_CHARGES)
			if(charge_counter)
				return 1
			return 0


/datum/action/item_action/advanced/apply_unavailable_effect()
	var/progress = get_availability_percentage()
	if(progress == 1)
		no_count = TRUE
	var/mutable_appearance/unavailable_effect = mutable_appearance(coold_overlay_icon, coold_overlay_icon_state, BUTTON_LAYER_UNAVAILABLE, appearance_flags = RESET_COLOR|RESET_ALPHA, color = "#000000")
	unavailable_effect.alpha = no_count ? 80 : 220 - 140 * progress
	button.add_overlay(unavailable_effect)
	if(!no_count && charge_type != ADV_ACTION_TYPE_CHARGES)
		add_percentage_overlay(progress)
	else if(charge_type == ADV_ACTION_TYPE_CHARGES)
		add_charges_overlay()
	no_count = FALSE //reset


/datum/action/item_action/advanced/proc/add_percentage_overlay(progress)
	// Make a holder for the charge text
	var/static/mutable_appearance/count_down_holder = mutable_appearance('icons/effects/effects.dmi', "nothing", BUTTON_LAYER_MAPTEXT, appearance_flags = RESET_COLOR|RESET_ALPHA)
	count_down_holder.maptext = "<div style=\"font-size:6pt;color:[recharge_text_color];font:'Small Fonts';text-align:center;\" valign=\"bottom\">[round_down(progress * 100)]%</div>"
	button.add_overlay(count_down_holder)


/datum/action/item_action/advanced/proc/add_charges_overlay()
	// Make a holder for the charge text
	var/static/mutable_appearance/charges_holder = mutable_appearance('icons/effects/effects.dmi', "nothing", BUTTON_LAYER_MAPTEXT, appearance_flags = RESET_COLOR|RESET_ALPHA)
	charges_holder.maptext = "<div style=\"font-size:6pt;color:#ffffff;font:'Small Fonts';text-align:center;\" valign=\"bottom\">[charge_counter]/[charge_max]</div>"
	button.add_overlay(charges_holder)


	//visuals only
/datum/action/item_action/advanced/proc/toggle_button_on_off()
	if(!action_ready)
		icon_state_disabled = background_icon_state
		background_icon_state = "[background_icon_state]_on"
	else
		background_icon_state = icon_state_disabled
	UpdateButtonIcon()

//Ninja action type
/datum/action/item_action/advanced/ninja
	coold_overlay_icon = 'icons/mob/actions/actions_ninja.dmi'
	coold_overlay_icon_state = "background_green"
	icon_state_active = "background_green_active"
	icon_state_disabled = "background_green"

/datum/action/item_action/advanced/ninja/New(Target)
	. = ..()
	var/obj/item/clothing/suit/space/space_ninja/ninja_suit = target
	if(istype(ninja_suit))
		recharge_text_color = ninja_suit.color_choice
		coold_overlay_icon_state = "background_[ninja_suit.color_choice]"

/datum/action/item_action/advanced/ninja/IsAvailable(show_message = FALSE, ignore_ready = FALSE)
	if(!target && !istype(target, /obj/item/clothing/suit/space/space_ninja))
		return FALSE
	return ..()

/datum/action/item_action/advanced/ninja/apply_unavailable_effect()
	var/obj/item/clothing/suit/space/space_ninja/ninja_suit = target
	if(!istype(ninja_suit))
		no_count = TRUE
	. = ..()

/datum/action/item_action/advanced/ninja/toggle_button_on_off()
	if(action_ready)
		background_icon_state = icon_state_active
	else
		background_icon_state = icon_state_disabled
	UpdateButtonIcon()


#undef BUTTON_LAYER_ICON
#undef BUTTON_LAYER_UNAVAILABLE
#undef BUTTON_LAYER_MAPTEXT
#undef BUTTON_LAYER_SELECTOR

