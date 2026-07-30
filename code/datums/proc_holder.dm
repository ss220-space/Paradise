/obj/effect/proc_holder
	var/active = FALSE //Used by toggle based abilities.
	var/ranged_mousepointer
	var/mob/ranged_ability_user

/obj/effect/proc_holder/singularity_act()
	return

/obj/effect/proc_holder/singularity_pull(atom/singularity, current_size)
	return

GLOBAL_LIST_INIT(spells, typesof(/datum/action/cooldown/spell))

/obj/effect/proc_holder/proc/InterceptClickOn(mob/user, params, atom/target)
	if(user.ranged_ability != src)
		to_chat(user, span_warning("<b>[user.ranged_ability.name]</b> has been disabled."))
		user.ranged_ability.remove_ranged_ability(user)
		return TRUE //TRUE for failed, FALSE for passed.
	user.face_atom(target)
	return FALSE

/datum/click_intercept/proc_holder
	var/obj/effect/proc_holder/spell

/datum/click_intercept/proc_holder/New(client/C, obj/effect/proc_holder/spell_to_cast)
	. = ..()
	spell = spell_to_cast

/datum/click_intercept/proc_holder/InterceptClickOn(user, params, atom/object)
	spell.InterceptClickOn(user, params, object)

/datum/click_intercept/proc_holder/quit(force)
	spell.remove_ranged_ability(spell.ranged_ability_user)
	return ..()

/datum/click_intercept/proc_holder/Destroy()
	holder.mouse_override_icon = null
	holder.mouse_pointer_icon = initial(holder.mouse_pointer_icon)
	var/client/user_client = spell?.ranged_ability_user?.client
	if(user_client && user_client.click_intercept == src)
		user_client.click_intercept = null
	spell = null
	return ..()

/obj/effect/proc_holder/proc/add_ranged_ability(mob/user, msg)
	if(!user || !user.client)
		return
	if(user.ranged_ability && user.ranged_ability != src)
		to_chat(user, span_warning("<b>[user.ranged_ability.name]</b> has been replaced by <b>[name]</b>."))
		user.ranged_ability.remove_ranged_ability(user)
	user.ranged_ability = src
	ranged_ability_user = user
	user.client.click_intercept = new /datum/click_intercept/proc_holder(user.client, user.ranged_ability)
	add_mousepointer(user.client)
	active = TRUE
	if(msg)
		to_chat(user, msg)
	update_icon()

/obj/effect/proc_holder/proc/add_mousepointer(client/our_client)
	if(our_client && ranged_mousepointer && our_client.mouse_pointer_icon == initial(our_client.mouse_pointer_icon))
		our_client.mouse_pointer_icon = ranged_mousepointer

/obj/effect/proc_holder/proc/remove_mousepointer(client/our_client)
	if(our_client && ranged_mousepointer && our_client.mouse_pointer_icon == ranged_mousepointer)
		our_client.mouse_pointer_icon = initial(our_client.mouse_pointer_icon)

/obj/effect/proc_holder/proc/remove_ranged_ability(mob/user, msg)
	if(!user || (user.ranged_ability && user.ranged_ability != src)) //To avoid removing the wrong ability
		return
	user.ranged_ability = null
	ranged_ability_user = null
	active = FALSE
	if(user.client)
		QDEL_NULL(user.client.click_intercept)
		remove_mousepointer(user.client)
		if(msg)
			to_chat(user, msg)
	update_icon()

