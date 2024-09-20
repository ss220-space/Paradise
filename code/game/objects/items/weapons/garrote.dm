/*
 * Contains:
 * 	Traitor fiber wire
 * 	Improvised garrotes
 */

/obj/item/twohanded/garrote // 12TC traitor item
	name = "fiber wire"
	desc = "A length of razor-thin wire with an elegant wooden handle on either end.<br>You suspect you'd have to be behind the target to use this weapon effectively."
	icon_state = "garrot_wrap"
	w_class = WEIGHT_CLASS_TINY
	var/mob/living/carbon/human/strangling
	var/improvised = FALSE
	COOLDOWN_DECLARE(garrote_cooldown)


/obj/item/twohanded/garrote/Destroy()
	STOP_PROCESSING(SSobj, src)
	strangling = null
	return ..()


/obj/item/twohanded/garrote/update_icon_state()
	if(strangling) // If we're strangling someone we want our icon to stay wielded
		icon_state = "garrot_unwrap"
		return
	icon_state = "garrot_[HAS_TRAIT(src, TRAIT_WIELDED) ? "un" : ""]wrap"


/obj/item/twohanded/garrote/improvised // Made via tablecrafting
	name = "garrote"
	desc = "A length of cable with a shoddily-carved wooden handle tied to either end.<br>You suspect you'd have to be behind the target to use this weapon effectively."
	icon_state = "garrot_I_wrap"
	improvised = TRUE


/obj/item/twohanded/garrote/improvised/update_icon_state()
	if(strangling)
		icon_state = "garrot_I_unwrap"
		return
	icon_state = "garrot_I_[HAS_TRAIT(src, TRAIT_WIELDED) ? "un" : ""]wrap"


/obj/item/twohanded/garrote/unwield(obj/item/source, mob/living/carbon/user)
	if(strangling)
		user.visible_message(
			span_warning("[user] removes [name] from [strangling]'s neck."),
			span_warning("You remove [name] from [strangling]'s neck."),
		)
		strangling = null
		update_icon(UPDATE_ICON_STATE)
		STOP_PROCESSING(SSobj, src)


/obj/item/twohanded/garrote/attack(mob/living/carbon/human/target, mob/living/carbon/human/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(!COOLDOWN_FINISHED(src, garrote_cooldown) || !ishuman(user))
		return .

	if(!ishuman(target))
		user.balloon_alert(user, "неподходящая цель!")
		return .

	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		user.balloon_alert(user, "нужны обе руки!")
		return .

	if(user == target)
		user.suicide() // This will display a prompt for confirmation first.
		return .|ATTACK_CHAIN_SUCCESS

	if(user.dir != target.dir)
		user.balloon_alert(user, "используйте сзади!")
		return .

	if(improvised && ((target.head && (target.head.flags_cover & HEADCOVERSMOUTH)) || (target.wear_mask && (target.wear_mask.flags_cover & MASKCOVERSMOUTH)))) // Improvised garrotes are blocked by mouth-covering items.
		user.balloon_alert(user, "мешает одежда!")
		return .

	if(strangling)
		user.balloon_alert(user, "уже используется!")
		return .

	user.stop_pulling()
	user.mode()
	if(!user.swap_hand())
		return .
	var/grabbed = target.grabbedby(user, supress_message = TRUE)
	user.swap_hand()

	if(!grabbed)
		return .

	. |= ATTACK_CHAIN_SUCCESS

	if(improvised) // Not a trash anymore:|
		target.grippedby(user)
	else
		target.grippedby(user, grab_state_override = GRAB_NECK)
		target.AdjustSilence(2 SECONDS)

	COOLDOWN_START(src, garrote_cooldown, 1 SECONDS)
	START_PROCESSING(SSobj, src)
	strangling = target
	strangling = target
	update_icon(UPDATE_ICON_STATE)

	playsound(loc, 'sound/weapons/cablecuff.ogg', 15, TRUE, -1)

	target.visible_message(
		span_danger("[user] comes from behind and begins garroting [target] with [src]!"),
		span_userdanger("[user] begins garroting you with [src]![improvised ? "" : " You are unable to speak!"]"),
		span_italics("You hear struggling and wire strain against flesh!"),
	)


/obj/item/twohanded/garrote/process()
	if(QDELETED(strangling))
		// Our mark got gibbed or similar
		update_icon(UPDATE_ICON_STATE)
		return PROCESS_KILL

	var/mob/living/carbon/human/strangler = loc
	if(!ishuman(strangler))
		strangling = null
		update_icon(UPDATE_ICON_STATE)
		return PROCESS_KILL

	if(!strangler.pulling || strangler.pulling != strangling)
		strangler.visible_message(
			span_warning("[strangler] loses [strangler.p_their()] grip on [strangling]'s neck."),
			span_warning("You lose your grip on [strangling]'s neck."),
		)
		strangling = null
		update_icon(UPDATE_ICON_STATE)
		return PROCESS_KILL

	if(improvised)
		strangling.Stuttering(6 SECONDS)
		strangling.apply_damage(2, OXY, BODY_ZONE_HEAD)
	else
		strangling.Silence(6 SECONDS)
		strangling.apply_damage(20, OXY, BODY_ZONE_HEAD)


/obj/item/twohanded/garrote/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is wrapping the [src] around [user.p_their()] neck and pulling the handles! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	playsound(src.loc, 'sound/weapons/cablecuff.ogg', 15, 1, -1)
	return OXYLOSS

