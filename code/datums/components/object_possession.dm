/// Component that allows a user to control any object as if it were a mob. Does give the user incorporeal movement.
/datum/component/object_possession
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Stores a reference to the obj that we are currently possessing.
	var/obj/possessed
	/// Ref to the screen object that is currently being displayed.
	var/datum/weakref/screen_alert_ref
	/**
	  * back up of the real name during user possession
	  *
	  * When a user possesses an object it's real name is set to the user name and this
	  * stores whatever the real name was previously. When possession ends, the real name
	  * is reset to this value
	  */
	var/stashed_name

/datum/component/object_possession/Initialize(obj/target)
	. = ..()
	if(!isobj(target) || !ismob(parent))
		return COMPONENT_INCOMPATIBLE

	if(!bind_to_new_object(target))
		return COMPONENT_INCOMPATIBLE

	var/mob/user = parent
	screen_alert_ref = WEAKREF(user.throw_alert(ALERT_UNPOSSESS_OBJECT, /atom/movable/screen/alert/unpossess_object))

/datum/component/object_possession/RegisterWithParent()
	RegisterSignal(parent, list(COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, COMSIG_MOB_CLIENT_PRE_NON_LIVING_MOVE), PROC_REF(on_move))
	RegisterSignal(parent, COMSIG_MOB_GHOSTIZE, PROC_REF(end_possession))

/datum/component/object_possession/UnregisterFromParent()
    UnregisterSignal(parent, list(
		COMSIG_MOB_CLIENT_PRE_LIVING_MOVE,
		COMSIG_MOB_CLIENT_PRE_NON_LIVING_MOVE,
		COMSIG_MOB_GHOSTIZE,
	))

/datum/component/object_possession/Destroy()
	cleanup_object_binding()

	var/mob/user = parent
	var/atom/movable/screen/alert/alert_to_clear = screen_alert_ref?.resolve()

	if(!QDELETED(alert_to_clear))
		user.clear_alert(ALERT_UNPOSSESS_OBJECT)

	return ..()

/datum/component/object_possession/InheritComponent(datum/component/object_possession/old_component, i_am_original, obj/target)
	cleanup_object_binding()

	if(!bind_to_new_object(target))
		qdel(src)

	stashed_name = old_component?.stashed_name

/// Binds the mob to the object and sets up the naming and everything.
/// Returns FALSE if we don't bind, TRUE if we succeed.
/datum/component/object_possession/proc/bind_to_new_object(obj/target)
	if(issingularity(target) && CONFIG_GET(flag/forbid_singulo_possession))
		to_chat(parent, "[target] сопротивляется вашему контролю.", confidential = TRUE)
		return FALSE

	var/mob/user = parent

	stashed_name = user.real_name
	possessed = target

	user.forceMove(target)
	user.real_name = target.name
	user.name = target.name
	user.reset_perspective(target)

	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(end_possession))
	SEND_SIGNAL(target, COMSIG_OBJ_POSSESSED, parent)

	return TRUE

/// Cleans up everything pertinent to the current possessed object.
/datum/component/object_possession/proc/cleanup_object_binding()
	if(QDELETED(possessed))
		return

	var/mob/poltergeist = parent

	UnregisterSignal(possessed, COMSIG_QDELETING)

	if(!isnull(stashed_name))
		poltergeist.real_name = stashed_name
		poltergeist.name = stashed_name

		if(ishuman(poltergeist))
			var/mob/living/carbon/human/human_user = poltergeist
			human_user.name = human_user.get_visible_name()

	poltergeist.forceMove(get_turf(possessed))
	poltergeist.reset_perspective()

	possessed = null

/**
 * force move the parent object instead of the source mob.
 *
 * Has no sanity other than checking the possed obj's density. this means it effectively has incorporeal movement, making it only good for badminnery.
 *
 * We always want to return `COMPONENT_MOVABLE_BLOCK_PRE_MOVE` here regardless
 */
/datum/component/object_possession/proc/on_move(datum/source, new_loc, direct)
	SIGNAL_HANDLER

	. = COMPONENT_MOVABLE_BLOCK_PRE_MOVE // both signals that invoke this are explicitly tied to listen for this define as the return value

	if(!possessed.density)
		possessed.forceMove(get_step(possessed, direct))

	else
		step(possessed, direct)

	possessed.setDir(direct)
	SEND_SIGNAL(possessed, COMSIG_POSSESSED_MOVEMENT, source, new_loc, direct)

	return

/// Just the overall "get me outta here" proc.
/datum/component/object_possession/proc/end_possession(datum/source)
	SIGNAL_HANDLER

	SEND_SIGNAL(possessed, COMSIG_OBJ_RELEASED, parent)
	qdel(src)
