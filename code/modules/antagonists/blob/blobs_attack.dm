/atom/proc/can_blob_attack()
	return TRUE

/mob/living/can_blob_attack()
	. = ..()
	if(!.)
		return
	return !incorporeal_move

/obj/effect/dummy/phased_mob/can_blob_attack()
	return FALSE
