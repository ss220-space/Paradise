/obj/item/steroids
	name = "Strange syringe"
	desc = "Syringe is filled by some strange colourless... You biceps want it!"
	icon = 'icons/obj/items.dmi'
	icon_state = "implanter1"
	item_state = "syringe_0"
	var/used = FALSE

/obj/item/steroids/attack_self(mob/user)
	. = ..()
	if(!used)
		var/datum/martial_art/steroids/steroids= new(null)
		steroids.teach(user)
		used = TRUE
		icon_state = "implanter0"


/datum/martial_art/steroids
	name = "Musculine style"
	has_explaination_verb = TRUE

/obj/item/dumbell
	name = "dumbell"
	desc = "It looks so powerfull!"
	icon_state = "dumbell"
	force = 10
	throwforce = 15
	throw_speed = 2
	throw_range = 6
	w_class = WEIGHT_CLASS_SMALL

/obj/item/dumbell/ComponentInitialize()
	AddComponent(/datum/component/stumbling, 10, BRUTE, 4)

/obj/item/dumbell/kettlebell
	name = "kettlebell"
	desc = "Kettlebell with laser engraving 'for the best trainer'."
	icon_state = "kettlebell"
	w_class = WEIGHT_CLASS_NORMAL
	var/used_once = FALSE
	throw_range = 1

/obj/item/dumbell/equipped(mob/user)
	. = ..()
	if(!user?.mind.martial_art && !istype(user.mind.martial_art,/datum/martial_art/steroids))
		to_chat(user, span_warning("It's too HEAVY!"))
		user.drop_item_ground(src, force = TRUE)

/obj/item/dumbell/kettlebell/attack_self(mob/user)
	if(!used_once)
		used_once = TRUE
		var/datum/action/kettlebellreturn/ketret = new /datum/action/kettlebellreturn(src)
		ketret.Grant(user)
		to_chat(user, span_notice("Now thats your kettlebell!"))
	else
		on_throw(user)
	. = ..()

/obj/item/dumbell/kettlebell/proc/on_throw(mob/user)
	var/mob/living/carbon/H = user
	H.throw_mode_on()
	throw_range = 6
	H.spin(5 SECONDS, pick(0.1 SECONDS, 0.2 SECONDS))
	addtimer(CALLBACK(src, PROC_REF(off_throw),H), 5 SECONDS)

/obj/item/dumbell/kettlebell/proc/off_throw(mob/user)
	var/mob/living/carbon/H = user
	H.throw_mode_off()
	throw_range = 1

/datum/action/kettlebellreturn
	name = "Recall kettlebell"
	desc = "Teleports your kettlebell to you"
	COOLDOWN_DECLARE(last_return)

/datum/action/kettlebellreturn/New(Target)
	..()

/datum/action/kettlebellreturn/ApplyIcon(obj/screen/movable/action_button/current_button)
	var/obj/item/I = target
	var/old_layer = I.layer
	var/old_plane = I.plane
	var/old_appearance_flags = I.appearance_flags
	I.layer = FLOAT_LAYER //AAAH
	I.plane = FLOAT_PLANE //^ what that guy said
	I.appearance_flags |= RESET_COLOR | RESET_ALPHA
	if(I.outline_filter)
		I.filters -= I.outline_filter
	current_button.cut_overlays()
	current_button.add_overlay(I)
	I.layer = old_layer
	I.plane = old_plane
	I.appearance_flags = old_appearance_flags
	if(I.outline_filter)
		I.filters -= I.outline_filter
		I.filters += I.outline_filter

/datum/action/kettlebellreturn/Trigger(attack_self = FALSE)
	..()
	if(COOLDOWN_FINISHED(src, last_return))
		kettlereturn(owner, target)
	else
		to_chat(owner ,span_warning("Kettlebell is not ready yet!"))

/datum/action/kettlebellreturn/proc/kettlereturn(var/mob/user,var/obj/I)
	if(!(I in list(user.get_active_hand(), user.get_inactive_hand())))
		if(!user.put_in_active_hand(I) && !user.put_in_inactive_hand(I))
			I.loc = user.loc
			I.loc.visible_message(span_caution("The kettlebell suddenly appears!"))
		else
			I.loc.visible_message(span_caution("The kettlebell suddenly appears in your hands!"))
		COOLDOWN_START(src, last_return, 8 SECONDS)
	else
		to_chat(user, span_caution("The kettlebell already in your hands"))

