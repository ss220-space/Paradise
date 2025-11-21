// Rusted weapon feature component

/datum/component/rusted_weapon
	/// Max chance to destroy gun after shot
	var/destroy_max_chance
	/// Max chance of shots in the face
	var/face_shot_max_chance
	/// Shots before gun exploding
	var/malf_low_bound
	var/malf_high_bound

/datum/component/rusted_weapon/Initialize(face_shot_max_chance = 25, destroy_max_chance = 10, malf_low_bound = 40, malf_high_bound = 80)
	. = ..()
	if(!isgun(parent))
		return COMPONENT_INCOMPATIBLE
	src.face_shot_max_chance = face_shot_max_chance
	src.destroy_max_chance = destroy_max_chance
	src.malf_low_bound = malf_low_bound
	src.malf_high_bound = malf_high_bound

/datum/component/rusted_weapon/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_GUN_AFTER_PROCESS_FIRE, PROC_REF(after_process_fire))

/datum/component/rusted_weapon/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_GUN_AFTER_PROCESS_FIRE)

/datum/component/rusted_weapon/proc/after_process_fire(datum/source, atom/target, mob/living/user)
	var/obj/item/gun/gun = parent
	if(!gun.chambered || !gun.chambered.BB)
		return
	if(gun.shots_counter < malf_low_bound)
		return
	var/destroy_chance = gun.shots_counter >= malf_high_bound ? destroy_max_chance : ((gun.shots_counter - malf_low_bound) / (malf_high_bound - malf_low_bound) * destroy_max_chance)
	if(prob(destroy_chance))
		// if the gun grabbed by telekinesis, it's can exploise but without damage for user
		if(user.tkgrabbed_objects[gun])
			user.drop_item_ground(user.tkgrabbed_objects[gun])
			to_chat(user, span_userdanger("БА-БАХ! [capitalize(gun.declent_ru(NOMINATIVE))] взрывается!"))
		else
			user.take_organ_damage(0, 30)
			user.flash_eyes()
			to_chat(user, span_userdanger("БА-БАХ! [capitalize(gun.declent_ru(NOMINATIVE))] взрывается у вас в руках!"))
		new /obj/effect/decal/cleanable/ash(gun.loc)
		playsound(user, 'sound/effects/explosion1.ogg', 30, TRUE)
		qdel(gun)
		return
	// shot in the face probe
	var/face_shot_chance = gun.shots_counter >= malf_high_bound ? face_shot_max_chance : ((gun.shots_counter - malf_low_bound) / (malf_high_bound - malf_low_bound) * face_shot_max_chance)
	if(!prob(face_shot_chance))
		return
	playsound(user, gun.fire_sound, 30, TRUE)
	to_chat(user, span_userdanger("[capitalize(gun.declent_ru(NOMINATIVE))] взрывается прямо у вас перед лицом!"))
	user.take_organ_damage(0, 10)
