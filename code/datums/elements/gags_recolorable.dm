/datum/element/gags_recolorable

/datum/element/gags_recolorable/Attach(datum/target)
	. = ..()
	RegisterSignal(target, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/element/gags_recolorable/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, list(COMSIG_PARENT_ATTACKBY, COMSIG_PARENT_EXAMINE))

/datum/element/gags_recolorable/proc/on_examine(atom/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	examine_text += span_notice("You could recolor [source.p_them()] with a spraycan...")

/datum/element/gags_recolorable/proc/on_attackby(datum/source, obj/item/attacking_item, mob/user)
	SIGNAL_HANDLER

	if(!isatom(source))
		return

	if(!istype(attacking_item, /obj/item/toy/crayon/spraycan))
		return
	var/obj/item/toy/crayon/spraycan/can = attacking_item

	if(can.capped || can.uses < 0)
		return

	INVOKE_ASYNC(src, PROC_REF(open_ui), user, can, source)
	return COMPONENT_NO_AFTERATTACK

/datum/element/gags_recolorable/proc/open_ui(mob/user, obj/item/toy/crayon/spraycan/can, atom/target)
	var/atom/atom_parent = target
	var/list/allowed_configs = list()
	var/config = initial(atom_parent.greyscale_config)
	if(!config)
		return
	allowed_configs += "[config]"
	if(isitem(atom_parent))
		var/obj/item/item = atom_parent
		var/list/worn = item.greyscale_config_worn
		var/list/species = item.greyscale_config_worn_species

		for(var/new_config in worn)
			allowed_configs += "[worn[new_config]]"

		for(var/new_config in species)
			allowed_configs += "[species[new_config]]"

		if(initial(item.greyscale_config_inhand_left))
			allowed_configs += "[initial(item.greyscale_config_inhand_left)]"

		if(initial(item.greyscale_config_inhand_right))
			allowed_configs += "[initial(item.greyscale_config_inhand_right)]"

	var/datum/greyscale_modify_menu/spray_paint/menu = new(
		atom_parent, user, allowed_configs, CALLBACK(src, PROC_REF(recolor), user, can, target),
		starting_icon_state = target::post_init_icon_state || target::icon_state,
		starting_config = initial(atom_parent.greyscale_config),
		starting_colors = atom_parent.greyscale_colors,
		used_spraycan = can
	)
	menu.ui_interact(user)

/datum/element/gags_recolorable/proc/recolor(mob/user, obj/item/toy/crayon/spraycan/can, atom/target, datum/greyscale_modify_menu/menu)
	if(!isatom(target))
		return


	if(can.capped || can.uses < 0)
		menu.ui_close()
		return

	can.uses--
	target.audible_message(span_hear("You hear spraying."))
	playsound(target.loc, 'sound/effects/spray.ogg', 5, TRUE, 5)

	target.set_greyscale_colors(menu.split_colors)

	// If the item is a piece of clothing and is being worn, make sure it updates on the player
	if(!isclothing(target))
		return
	if(!ishuman(target.loc))
		return
	var/obj/item/clothing/clothing_parent = target
	var/mob/living/carbon/human/wearer = target.loc
	wearer.update_clothing(clothing_parent.slot_flags)
	menu.ui_close()
