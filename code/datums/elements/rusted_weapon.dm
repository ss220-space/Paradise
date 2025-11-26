// Rusted weapon feature component

/datum/element/rusted_weapon
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY | ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Max chance to destroy gun after shot
	var/destroy_max_chance
	/// Max chance of shots in the face
	var/face_shot_max_chance
	/// Shots before gun exploding
	var/malf_low_bound
	var/malf_high_bound

/datum/element/rusted_weapon/Attach(datum/target, face_shot_max_chance, destroy_max_chance, malf_low_bound, malf_high_bound)
	. = ..()
	if(!isgun(target))
		return COMPONENT_INCOMPATIBLE
	src.face_shot_max_chance = face_shot_max_chance
	src.destroy_max_chance = destroy_max_chance
	src.malf_low_bound = malf_low_bound
	src.malf_high_bound = malf_high_bound
	RegisterSignal(target, COMSIG_GUN_AFTER_PROCESS_FIRE, PROC_REF(after_process_fire))

/datum/element/rusted_weapon/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_GUN_AFTER_PROCESS_FIRE)

/datum/element/rusted_weapon/proc/after_process_fire(datum/source, atom/target, mob/living/user)
	var/obj/item/gun/gun = source
	if(!gun.chambered || !gun.chambered.BB)
		return
	if(gun.shots_counter < malf_low_bound)
		return
	var/destroy_chance = gun.shots_counter >= malf_high_bound ? destroy_max_chance : ((gun.shots_counter - malf_low_bound) / (malf_high_bound - malf_low_bound) * destroy_max_chance)
	if(prob(destroy_chance))
		destroy_gun(gun, user)
		return
	// shot in the face probe
	var/face_shot_chance = gun.shots_counter >= malf_high_bound ? face_shot_max_chance : ((gun.shots_counter - malf_low_bound) / (malf_high_bound - malf_low_bound) * face_shot_max_chance)
	if(!prob(face_shot_chance))
		return
	playsound(user, gun.fire_sound, 30, TRUE)
	to_chat(user, span_userdanger("[capitalize(gun.declent_ru(NOMINATIVE))] взрывается прямо у вас перед лицом!"))
	user.take_organ_damage(0, 10)

/datum/element/rusted_weapon/proc/destroy_gun(obj/item/gun/gun, mob/living/user)
	// if the gun grabbed by telekinesis, it's can exploise but without damage for user
	if(user.tkgrabbed_objects[gun])
		user.drop_item_ground(user.tkgrabbed_objects[gun])
		to_chat(user, span_userdanger("БА-БАХ! [capitalize(gun.declent_ru(NOMINATIVE))] взрывается!"))
	else
		user.take_organ_damage(0, 30)
		user.flash_eyes()
		to_chat(user, span_userdanger("БА-БАХ! [capitalize(gun.declent_ru(NOMINATIVE))] взрывается у вас в руках!"))
	new /obj/effect/decal/cleanable/ash(gun.loc)
	playsound(user, SFX_EXPLOSION, 30, TRUE)
	qdel(gun)
