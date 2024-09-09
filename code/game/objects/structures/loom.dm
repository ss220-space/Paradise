#define FABRIC_PER_SHEET 4


///This is a loom. It's usually made out of wood and used to weave fabric like durathread or cotton into their respective cloth types.
/obj/structure/loom
	name = "loom"
	desc = "A simple device used to weave cloth and other thread-based fabrics together into usable material."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "loom"
	density = TRUE
	anchored = TRUE


/obj/structure/loom/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/stack/sheet/cotton))
		add_fingerprint(user)
		var/obj/item/stack/sheet/cotton/cotton = I
		if(!anchored)
			to_chat(user, span_warning("The [name] needs to be wrenched down."))
			return ATTACK_CHAIN_PROCEED
		if(cotton.get_amount() < FABRIC_PER_SHEET)
			to_chat(user, span_warning("You need at least [FABRIC_PER_SHEET] units of fabric before using this."))
			return ATTACK_CHAIN_PROCEED
		var/cached_result = cotton.loom_result
		var/cached_name = cotton.name
		user.visible_message(
			span_notice("[user] starts weaving the [cached_name] through the loom."),
			span_notice("You start weaving the [cached_name] through the loom..."),
		)
		if(!do_after(user, cotton.pull_effort, src, category = DA_CAT_TOOL) || !anchored || QDELETED(cotton) || !cotton.use(FABRIC_PER_SHEET))
			return ATTACK_CHAIN_PROCEED
		var/obj/item/result = new cached_result(drop_location())
		result.add_fingerprint(user)
		user.visible_message(
			span_notice("[user] finished weaving the [cached_name] into a workable fabric."),
			span_notice("You finished weaving the [cached_name] into a workable fabric."),
		)
		return ATTACK_CHAIN_PROCEED

	return ..()


/obj/structure/loom/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 50, volume = I.tool_volume))
		TOOL_DISMANTLE_SUCCESS_MESSAGE
		deconstruct(disassembled = TRUE)

/obj/structure/loom/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, time = 20)

/obj/structure/loom/deconstruct(disassembled = FALSE)
	var/mat_drop = 5
	if(disassembled)
		mat_drop = 10
	new /obj/item/stack/sheet/wood(drop_location(), mat_drop)
	..()


#undef FABRIC_PER_SHEET
