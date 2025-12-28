/obj/item/multitool/circuit
	name = "circuit multitool"
	desc = "Мультиметр для схем. Используется для маркировки объектов, которые затем можно загрузить \
			в компоненты нажатием кнопки загрузки на порту. В остальном действует как обычный мультиметр."
	icon = 'icons/obj/circuits.dmi'
	icon_state = "multitool_circuit"

	/// The marked atom of this multitool
	var/atom/marked_atom

/obj/item/multitool/circuit/get_ru_names()
	return list(
		NOMINATIVE = "мультиметр для схем",
		GENITIVE = "мультиметра для схем",
		DATIVE = "мультиметру для схем",
		ACCUSATIVE = "мультиметр для схем",
		INSTRUMENTAL = "мультиметром для схем",
		PREPOSITIONAL = "мультиметре для схем"
	)

/obj/item/multitool/circuit/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_CLONE_IN_EXPERIMENTATOR, INNATE_TRAIT)

/obj/item/multitool/circuit/Destroy()
	marked_atom = null
	return ..()

/obj/item/multitool/circuit/examine(mob/user)
	. = ..()
	. += span_notice("<b>[marked_atom? "Обнаружен" : "Не обнаружен"]</b> отмеченный зарегистрированный объект.")
	. += span_notice("<b>Используйте в руке</b>, чтобы очистить отмеченный объект и пометить другой объект.")

/obj/item/multitool/circuit/attack_self(mob/user, modifiers)
	if(marked_atom)
		atom_say("Отмеченные объекты очищены.")
		clear_marked_atom()
		return

	return ..()

/obj/item/multitool/circuit/melee_attack_chain(mob/user, atom/target, params)
	if(marked_atom || !user.Adjacent(target))
		return ..()

	if(isliving(target))
		INVOKE_ASYNC(src, PROC_REF(mark_mob_or_contents), user, target)
		return TRUE

	select_target(target)

/obj/item/multitool/circuit/proc/select_target(atom/target)
	atom_say("Отмечен [target.declent_ru(NOMINATIVE)].")
	marked_atom = target
	RegisterSignal(marked_atom, COMSIG_QDELETING, PROC_REF(cleanup_marked_atom))
	update_icon()
	flick("multitool_circuit_flick", src)
	playsound(src.loc, 'sound/machines/compiler/compiler-stage2.ogg', 30, TRUE)
	return TRUE

/// Allow users to mark items equipped by the target that are visible.
/obj/item/multitool/circuit/proc/mark_mob_or_contents(mob/user, mob/living/target)
	var/list/visible_items
	var/mob/living/carbon/carbon_target
	if(iscarbon(target))
		carbon_target = target
		visible_items = carbon_target.get_visible_items()
	else
		visible_items = target.get_equipped_items()

	visible_items -= src // the multitool cannot mark itself.

	if(!length(visible_items))
		select_target(target)
		return

	var/list/selectable_targets = list()
	var/datum/radial_menu_choice/mob_choice = new
	mob_choice.image = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_mob")
	mob_choice.name = target.name
	selectable_targets[target.UID()] = mob_choice

	for(var/obj/item/item as anything in visible_items)
		var/datum/radial_menu_choice/item_choice = new

		var/mutable_appearance/item_appearance = new(item)
		item_appearance.layer = FLOAT_LAYER
		item_appearance.plane = FLOAT_PLANE

		item_choice.name = item.declent_ru(NOMINATIVE)
		item_choice.image = item_appearance
		selectable_targets[item.UID()] = item_choice

	var/picked_ref = show_radial_menu(user, src, selectable_targets, radius = 38, custom_check = CALLBACK(src, PROC_REF(check_menu), user, target), require_near = TRUE)
	if(!picked_ref)
		return

	var/atom/movable/chosen = locateUID(picked_ref)
	if(chosen == target || (chosen in (carbon_target ? carbon_target.get_visible_items() : target.get_equipped_items())))
		select_target(chosen)
	else
		balloon_alert(user, "невозможно отметить объект!")

/obj/item/multitool/circuit/proc/check_menu(mob/user, mob/living/target)
	return !marked_atom && user.is_in_hands(src) && user.Adjacent(target)

/obj/item/multitool/circuit/update_overlays()
	. = ..()
	cut_overlays()
	if(marked_atom)
		. += "marked_overlay"

/// Clears the current marked atom
/obj/item/multitool/circuit/proc/clear_marked_atom()
	if(!marked_atom)
		return
	UnregisterSignal(marked_atom, COMSIG_QDELETING)
	marked_atom = null
	update_icon()

/obj/item/multitool/circuit/proc/cleanup_marked_atom(datum/source)
	SIGNAL_HANDLER
	if(source == marked_atom)
		clear_marked_atom()
