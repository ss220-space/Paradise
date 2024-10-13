//MISC items
//These items don't belong anywhere else, so they have this file.

//Current contents:
/*
	Cursor Drag Pointer
	Beach Ball
	Mouse Jetpack
*/

/obj/item/mouse_drag_pointer = MOUSE_ACTIVE_POINTER


/obj/item/beach_ball
	icon = 'icons/misc/beach.dmi'
	icon_state = "ball"
	name = "beach ball"
	item_state = "beachball"
	density = FALSE
	anchored = FALSE
	w_class = WEIGHT_CLASS_TINY
	force = 0.0
	throwforce = 0.0
	throw_speed = 1
	throw_range = 20
	flags = CONDUCT
	item_flags = NO_PIXEL_RANDOM_DROP


/obj/item/mouse_jetpack
	name = "improvised mouse jetpack"
	desc = "A roughly made jetpack designed for satisfy extremely small persons."
	icon_state = "jetpack_mouse"
	icon = 'icons/obj/tank.dmi'
	w_class = WEIGHT_CLASS_SMALL


/obj/item/syndicate_reverse_card
	name = "playing card"
	icon = 'icons/obj/toy.dmi'
	icon_state = "singlecard_down_syndicate"
	desc = "A playing card. You can only see the back."
	w_class = WEIGHT_CLASS_TINY
	var/used = FALSE //has this been used before? If not, give no hints about it's nature
	description_antag = "Hold this in your hand when you are getting shot at to steal your opponent's gun. You'll lose this, so be careful!"

/obj/item/syndicate_reverse_card/update_icon_state()
	. = ..()
	if(used)
		icon_state = "reverse_card"

/obj/item/syndicate_reverse_card/update_name()
	. = ..()
	if(used)
		name = "\improper 'Red Reverse' card"

/obj/item/syndicate_reverse_card/examine(mob/user)
	. = ..()
	if(used)
		. += span_warning("Something sinister is strapped to this card. It looks like it was once masked with some sort of cloaking field, which is now nonfunctional.")

/obj/item/syndicate_reverse_card/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	if(attack_type != PROJECTILE_ATTACK)
		return FALSE //this means the attack goes through
	if(istype(hitby, /obj/item/projectile))
		var/obj/item/projectile/P = hitby
		if(P?.firer && P.firer_source_atom && (P.firer != P.firer_source_atom)) //if the projectile comes from YOU, like your spit or some shit, you can't steal that bro. Also protects mechs
			if(iscarbon(P.firer)) //You can't switcharoo with turrets or simplemobs, or borgs
				switcharoo(P.firer, owner, P.firer_source_atom)
				return TRUE //this means the attack is blocked
	return ..()

/obj/item/syndicate_reverse_card/proc/switcharoo(mob/firer, mob/user, obj/item/gun/target_gun) //this proc teleports the target_gun out of the firer's hands and into the user's. The firer gets the card.
	//first, the sparks!
	do_sparks(12, TRUE, user)
	//next, we move the gun to the user and the card to the firer
	if(firer.drop_item_ground(target_gun) && user.drop_item_ground(src))
		to_chat(user, span_warning("The [src] vanishes from your hands, and [target_gun] appears in them!"))
		to_chat(firer, span_warning("[target_gun] vanishes from your hands, and a [src] appears in them!"))
		user.put_in_hands(target_gun)
		firer.put_in_hands(src)
		used = TRUE
		update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)
