/obj/item/implanter
	name = "bio-chip implanter"
	desc = "A sterile automatic bio-chip injector."
	icon = 'icons/obj/implants.dmi'
	icon_state = "implanter0"
	item_state = "syringe_0"
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "materials=2;biotech=3"
	materials = list(MAT_METAL = 600, MAT_GLASS = 200)
	toolspeed = 1
	/// Path thats will be transformed into object on Initialize()
	var/obj/item/implant/imp


/obj/item/implanter/Initialize(mapload)
	. = ..()
	if(ispath(imp, /obj/item/implant))
		imp = new imp(src)
	update_state()


/obj/item/implanter/Destroy()
	QDEL_NULL(imp)
	return ..()


/obj/item/implanter/proc/update_state()
	origin_tech = imp ? imp.origin_tech : initial(origin_tech)
	update_icon(UPDATE_ICON_STATE)


/obj/item/implanter/update_icon_state()
	icon_state = "implanter[imp ? "1" : "0"]"


/obj/item/implanter/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(!iscarbon(target))
		return .

	if(!user || !imp)
		return .

	// paradise balance moment
	var/static/list/whitelisted_implants = list(
		/obj/item/implant/traitor,
		/obj/item/implant/mindshield,
		/obj/item/implant/mindshield/ert,
	)

	if(!(imp.type in whitelisted_implants) && HAS_TRAIT(target, TRAIT_NO_BIOCHIPS))
		to_chat(user, span_warning("Био-чип не приживётся в этом теле."))
		return .

	if(target != user)
		target.visible_message(span_warning("[user] пыта[pluralize_ru(user.gender,"ет","ют")]ся имплантировать био-чип в [target]."))
		if(!do_after(user, 5 SECONDS * toolspeed, target, category = DA_CAT_TOOL) || QDELETED(user) || QDELETED(target) || QDELETED(src) || QDELETED(imp))
			return .

	if(!imp.implant(target, user))
		return .

	. |= ATTACK_CHAIN_SUCCESS
	if(user == target)
		to_chat(user, span_notice("Вы имплантировали био-чип."))
	else
		target.visible_message(
			span_warning("[user] имплантирова[genderize_ru(user.gender, "л", "ла", "ло", "ли")] био-чип в [target]."),
			span_notice("[user] имплантирова[genderize_ru(user.gender, "л", "ла", "ло", "ли")] вам био-чип."),
		)
	imp = null
	update_state()


/obj/item/implanter/attackby(obj/item/I, mob/user, params)
	if(is_pen(I))
		rename_interactive(user, I)
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()

