/*
CONTAINS:
RLF
*/

/obj/item/rlf
	name = "Rapid Lollipop Fabricator"
	desc = "A device used to rapidly deploy lollipop."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rlf"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/rlf/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(!proximity_flag)
		return
	if(!isrobot(user))
		return
	if(!iscarbon(target))
		return
	var/mob/living/carbon/receiver = target
	if(receiver.stat != CONSCIOUS)
		to_chat(user, span_warning("[receiver] can't accept any items because they're not conscious!"))
		return
	if(!user.Adjacent(receiver))
		to_chat(user, span_warning("You need to be closer to [receiver] to offer them lollipop."))
		return
	if(!receiver.client)
		to_chat(user, span_warning("You offer lollipop to [receiver], but they don't seem to respond..."))
		return
	var/obj/item/sucker = new /obj/item/reagent_containers/food/snacks/candy/sucker/lollipop
	receiver.throw_alert("take item [sucker.UID()]", /atom/movable/screen/alert/take_item/RLF, alert_args = list(user, receiver, sucker))
	to_chat(user, span_notice("You offer lollipop to [receiver]."))

/atom/movable/screen/alert/take_item/RLF

/atom/movable/screen/alert/take_item/RLF/Click(location, control, params)
	var/mob/living/silicon/robot/borg = locateUID(giver_UID)
	. = ..()
	if(!.)
		return FALSE
	if(isrobot(borg) && borg.cell)
		borg.cell.charge -= 500
	return TRUE
