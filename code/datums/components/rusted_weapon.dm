// Rusted weapon feature component

/datum/component/rusted_weapon
	/// Higher value means more shots in the face
	var/self_shot_divisor
	/// Shots before gun exploding
	var/malf_low_bound
	var/malf_high_bound
	// Random number between malf_low_bound and malf_high_bound
	var/malf_counter

/datum/component/rusted_weapon/Initialize(self_shot_divisor = 3, malf_low_bound = 40, malf_high_bound = 80)
	. = ..()
	if(!isgun(parent))
		return COMPONENT_INCOMPATIBLE
	src.self_shot_divisor = self_shot_divisor
	src.malf_low_bound = malf_low_bound
	src.malf_high_bound = malf_high_bound
	malf_counter = rand(malf_low_bound, malf_high_bound)

/datum/component/rusted_weapon/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_GUN_AFTER_PROCESS_FIRE, PROC_REF(after_process_fire))

/datum/component/rusted_weapon/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_GUN_AFTER_PROCESS_FIRE)

/datum/component/rusted_weapon/proc/after_process_fire(datum/source, atom/target, mob/living/user)
	var/obj/item/gun/gun = parent
	malf_counter -= gun.burst_size
	// if the gun grabbed by telekinesis, it's can exploise but without damage for user
	if(user.tkgrabbed_objects[gun])
		if(malf_counter > 0 || prob(50))
			return
		user.drop_item_ground(user.tkgrabbed_objects[gun])
		new /obj/effect/decal/cleanable/ash(gun.loc)
		to_chat(user, span_userdanger("БА-БАХ! [capitalize(gun.declent_ru(NOMINATIVE))] взрывается!"))
		playsound(user, 'sound/effects/explosion1.ogg', 30, TRUE)
		qdel(gun)
		return
	// explode in hands probe
	if(malf_counter <= 0 && prob(50))
		new /obj/effect/decal/cleanable/ash(user.loc)
		user.take_organ_damage(0, 30)
		user.flash_eyes()
		to_chat(user, span_userdanger("БА-БАХ! [capitalize(gun.declent_ru(NOMINATIVE))] взрывается у вас в руках!"))
		playsound(user, 'sound/effects/explosion1.ogg', 30, TRUE)
		qdel(gun)
		return
	// shot in the face probe
	var/face_shot_chance = 40 - (malf_counter > 0 ? round(malf_counter / self_shot_divisor) : 0)
	if(!prob(face_shot_chance))
		return
	playsound(user, gun.fire_sound, 30, TRUE)
	to_chat(user, span_userdanger("[capitalize(gun.declent_ru(NOMINATIVE))] взрывается прямо у вас перед лицом!"))
	user.take_organ_damage(0, 10)
