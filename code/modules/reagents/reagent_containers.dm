/obj/item/reagent_containers
	abstract_type = /obj/item/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	w_class = WEIGHT_CLASS_TINY
	var/amount_per_transfer_from_this = 5
	var/visible_transfer_rate = TRUE
	/// The different possible amounts of reagent to transfer out of the container
	var/list/possible_transfer_amounts = list(5,10,15,20,25,30)
	/// The maximum amount of reagents this container can hold
	var/volume = 30
	/// A list of what initial reagents this container should spawn with
	var/list/list_reagents = null
	/// If this container should spawn with a disease type inside of it
	var/spawned_disease = null
	/// How much of a disease specified in spawned_disease should this container spawn with
	var/disease_amount = 20
	/**
	 * The different thresholds at which the reagent fill overlay will change. See medical/reagent_fillings.dmi.
	 *
	 * Should be a list of integers which correspond to a reagent unit threshold.
	 * If null, no automatic fill overlays are generated.
	 *
	 * For example, list(0) will mean it will gain a the overlay with any reagents present. This overlay is "overlayname0".
	 * list(0, 10) whill have two overlay options, for 0-10 units ("overlayname0") and 10+ units ("overlayname10").
	 */
	var/list/fill_icon_thresholds = null
	/// The optional custom name for the reagent fill icon_state prefix
	/// If not set, uses the current icon state.
	var/fill_icon_state = null
	/// The icon file to take fill icon appearances from
	var/fill_icon = 'icons/obj/reagentfillings.dmi'
	///If we want to the contrast of the reagent overlay if the reagent mix color is very dark.
	var/adjust_color_contrast = FALSE
	var/temperature_min = 0 // To limit the temperature of a reagent container can atain when exposed to heat/cold
	var/temperature_max = 10000
	/// Pass open check in empty verb
	var/pass_open_check = FALSE
	var/chem_master_made = FALSE

/obj/item/reagent_containers/get_ru_names_cached()
	if(chem_master_made)
		return
	return ..()

/obj/item/reagent_containers/get_short_name()
	if(!length(reagents.reagent_list))
		return declent_ru(NOMINATIVE)

	var/datum/reagent/reagent = reagents.reagent_list[1]
	return reagent.name

/obj/item/reagent_containers/Initialize(mapload)
	. = ..()
	if(!reagents) // Some subtypes create their own reagents
		create_reagents(volume, temperature_min, temperature_max)
	if(spawned_disease)
		var/datum/disease/F = new spawned_disease
		var/list/data = list("diseases" = list(F), "blood_color" = BLOOD_COLOR_RED)
		reagents.add_reagent("blood", disease_amount, data)
	if(list_reagents)
		list_reagents = string_assoc_list(list_reagents)
	add_initial_reagents()
	update_icon()

/obj/item/reagent_containers/examine()
	. = ..()
	if(possible_transfer_amounts.len)
		. += span_notice("Объём перемещения содержимого — [amount_per_transfer_from_this] единиц[declension_ru(amount_per_transfer_from_this, "а", "ы", "")]. Используйте [EXAMINE_HINT("ЛКМ")] или [EXAMINE_HINT("ПКМ")] для изменения.")

/obj/item/reagent_containers/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(user.a_intent != INTENT_HARM)
		return ATTACK_CHAIN_PROCEED
	return ..()

/obj/item/reagent_containers/proc/add_initial_reagents()
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)

/obj/item/reagent_containers/attack_self(mob/user)
	change_transfer_amount(user, FORWARD)

/obj/item/reagent_containers/attack_self_secondary(mob/user)
	change_transfer_amount(user, BACKWARD)

/obj/item/reagent_containers/proc/mode_change_message(mob/user)
	return

/obj/item/reagent_containers/proc/change_transfer_amount(mob/user, direction = FORWARD)
	var/list_len = length(possible_transfer_amounts)
	if(!list_len)
		return
	var/index = possible_transfer_amounts.Find(amount_per_transfer_from_this) || 1
	switch(direction)
		if(FORWARD)
			index = (index % list_len) + 1
		if(BACKWARD)
			index = (index - 1) || list_len
		else
			CRASH("change_transfer_amount() called with invalid direction value")
	amount_per_transfer_from_this = possible_transfer_amounts[index]
	balloon_alert(user, "объём перемещения — [amount_per_transfer_from_this] единиц[declension_ru(amount_per_transfer_from_this, "а", "ы", "")]")
	mode_change_message(user)

/obj/item/reagent_containers/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(user.intent != INTENT_HARM)
		return NONE // non-combat-mode-rmb allows for stuff like opening containers or attacking (bottle breaking)
	if(try_splash(user, interacting_with))
		return ITEM_INTERACT_SUCCESS
	return NONE

/// Tries to splash the target. Used on both right-click and normal click when in combat mode.
/obj/item/reagent_containers/proc/try_splash(mob/user, atom/target)
	if(!is_open_container())
		return FALSE

	if(!reagents?.total_volume)
		return FALSE

	var/punctuation = ismob(target) ? "!" : "."

	user.visible_message(
		span_danger("[user] облива[PLUR_ET_YUT(user)] [target.declent_ru(ACCUSATIVE)] содержимым [declent_ru(GENITIVE)][punctuation]"),
		span_danger("Вы обливаете [target.declent_ru(ACCUSATIVE)] содержимым [declent_ru(GENITIVE)][punctuation]"),
		ignored_mobs = target,
	)

	if(ismob(target))
		var/mob/target_mob = target
		target_mob.show_message(
			span_userdanger("[user] облива[PLUR_ET_YUT(user)] вас содержимым [declent_ru(GENITIVE)]!"),
			EMOTE_VISIBLE,
			span_userdanger("Вас чем-то облили!"),
		)

	playsound(target, 'sound/effects/slosh.ogg', 25, TRUE)

	var/mutable_appearance/splash_animation = mutable_appearance('icons/effects/effects.dmi', "splash")
	if(isturf(target))
		splash_animation.icon_state = "splash_floor"
	splash_animation.color = mix_color_from_reagents(reagents.reagent_list)
	target.flick_overlay_view(splash_animation, 1 SECONDS)

	reagents.reaction(target, REAGENT_TOUCH)
	add_attack_logs(user, target, "splashed [reagents.log_list()]")
	reagents.clear_reagents()

	return TRUE

/obj/item/reagent_containers/verb/empty()

	set name = "Вылить содержимое"
	set category = VERB_CATEGORY_OBJECT
	set src in usr

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return
	if(tgui_alert(usr, "Вы уверены?", "Вылить содержимое", list("Да", "Нет")) != "Да")
		return
	if(!usr.Adjacent(src) || usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return
	if(isturf(usr.loc) && loc == usr)
		if(!is_open_container() && !pass_open_check)
			balloon_alert(usr, "сначала откройте!")
			return
		if(reagents.total_volume)
			balloon_alert(usr, "содержимое вылито")
			splash_reagents(usr.loc)
		else
			balloon_alert(usr, "пусто, нечего выливать!")

/obj/item/reagent_containers/ex_act()
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_ex_act()
	if(!QDELETED(src))
		..()

/obj/item/reagent_containers/proc/get_sound_for_reagent_containers()
	switch(amount_per_transfer_from_this)
		if(0 to 9)
			return SFX_BEAKERPOUR_0_10
		if(10 to 24)
			return SFX_BEAKERPOUR_10_25
		if(25 to 50)
			return SFX_BEAKERPOUR_25_50

	return SFX_BEAKERPOUR_50_INF

/obj/item/reagent_containers/proc/after_transfer(atom/target)
	if(!target)
		return FALSE

	playsound(target, get_sound_for_reagent_containers(), rand(5, 25), TRUE)

/obj/item/reagent_containers/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum, do_splash = TRUE)
	. = ..()
	if(do_splash)
		splash_reagents(hit_atom, throwingdatum?.get_thrower(), was_thrown = TRUE, allow_closed_splash = FALSE)

/**
 * Attempts to splash the reagents in the container onto the target.
 *
 * * target - The target to splash the reagents onto.
 * * throwingdatum - The throwingdatum behind the throw if the
 */
/obj/item/reagent_containers/proc/splash_reagents(atom/target, mob/splasher, was_thrown = FALSE, allow_closed_splash = FALSE)
	if(!reagents || !reagents.total_volume || (!is_open_container() && !allow_closed_splash))
		return

	if(ismob(target) && target.reagents)
		var/splash_multiplier = 1
		if(was_thrown)
			splash_multiplier *= (rand(5,10) * 0.1) //Not all of it makes contact with the target
		var/turf_splash_multiplier = 1 - splash_multiplier
		var/turf/target_turf = get_turf(target)
		target.visible_message(
			span_danger("[DECLENT_RU_CAP(target, NOMINATIVE)] облит[GEND_A_O_Y(target)] содержимым [declent_ru(GENITIVE)]!"),
			span_userdanger("[DECLENT_RU_CAP(target, NOMINATIVE)] облит[GEND_A_O_Y(target)] содержимым [declent_ru(GENITIVE)]!")
		)
		if(splasher)
			add_attack_logs(splasher, target, "splashed")
		reagents.reaction(target, REAGENT_TOUCH)
		if(turf_splash_multiplier > 0)
			reagents.reaction(target_turf, REAGENT_TOUCH, turf_splash_multiplier) // 1 - splash_multiplier because it's what didn't hit the target
	else
		if(isturf(target) && length(reagents.reagent_list) && splasher)
			add_attack_logs(splasher, target, "splashed (thrown) [english_list(reagents.reagent_list)]")
			message_admins("[ADMIN_LOOKUPFLW(splasher)] splashed (thrown) [english_list(reagents.reagent_list)] on [target] in [ADMIN_VERBOSEJMP(target)].")
		visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] выливается на [target.declent_ru(ACCUSATIVE)]."))
		reagents.reaction(target, REAGENT_TOUCH)
		if(QDELETED(src))
			return

	playsound(target, 'sound/effects/slosh.ogg', 25, TRUE)

	var/mutable_appearance/splash_animation = mutable_appearance('icons/effects/effects.dmi', "splash")
	if(isturf(target))
		splash_animation.icon_state = "splash_floor"
	splash_animation.color = mix_color_from_reagents(reagents.reagent_list)
	target.flick_overlay_view(splash_animation, 1.0 SECONDS)

	reagents.clear_reagents()

/obj/item/reagent_containers/update_overlays()
	. = ..()
	if(!fill_icon_thresholds)
		return
	if(!reagents.total_volume)
		return

	var/fill_name = fill_icon_state ? fill_icon_state : icon_state
	var/mutable_appearance/filling = mutable_appearance(fill_icon, "[fill_name][fill_icon_thresholds[1]]")

	var/percent = round((reagents.total_volume / volume) * 100)
	for(var/i in 1 to fill_icon_thresholds.len)
		var/threshold = fill_icon_thresholds[i]
		var/threshold_end = (i == fill_icon_thresholds.len) ? INFINITY : fill_icon_thresholds[i+1]
		if(threshold <= percent && percent < threshold_end)
			filling.icon_state = "[fill_name][fill_icon_thresholds[i]]"


	if(!adjust_color_contrast)
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		. += filling
		return

	var/list/mix_colors = rgb2num(mix_color_from_reagents(reagents.reagent_list))
	//reagent color red
	var/float_r = mix_colors[1] / 255
	//reagent color green
	var/float_g = mix_colors[2] / 255
	//reagent color blue
	var/float_b = mix_colors[3] / 255
	//reagent color alpha
	var/float_a = mix_colors.len > 3 ? mix_colors[4] / 255 : 1

	//value, used to make modifications depending on if our reagent color is light or dark.
	var/float_v = (float_r + float_g + float_b) / 3

	//max result of float_b - float_v is 0.6666 so we multiply with 1.5 to get something close to 1 at max blueness.
	var/blue_mod = max(float_b - float_v, 0) * 1.5

	//red multiplier
	var/red_scale = 1.6
	//green_multiplier
	var/green_scale = 1.5
	//blue scale
	var/blue_scale = 1.1 * (1 + 0.60 * blue_mod)

	//additive red - modifies red across the board by val * 255
	var/red_base = -0.07 - (0.035 * float_v)
	//additive green - modifies green across the board by val * 255
	var/green_base = -0.06 - (0.03 * float_v)
	//additive blue - modifies blue across the board by val * 255
	var/blue_base = 0.10 - (0.050 * float_v) - (0.40 * blue_mod)

	var/list/reagent_color_and_contrast_matrix  = list(
		//Red - RR, RG, RB, RA
		float_r * red_scale, 0, 0, 0,
		//Green - GR - GG - GB - GA
		0, float_g * green_scale, 0, 0,
		///Blue - BR, BG, BB, BA
		0.25 * blue_mod, 0.33 * blue_mod, float_b * blue_scale, 0,
		//Alpha - AR, AG, AB, AA
		0, 0, 0, float_a,
		//Constant - CR, CG, CB, CA
		red_base, green_base, blue_base, 0)

	filling.color = reagent_color_and_contrast_matrix

	. += filling
