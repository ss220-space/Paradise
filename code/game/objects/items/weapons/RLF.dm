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
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/receiver = owner
	if(receiver.stat != CONSCIOUS)
		return FALSE

	var/mob/living/silicon/robot/borg = locateUID(giver_UID)
	if(!isrobot(borg))
		return FALSE

	var/obj/item/reagent_containers/food/snacks/candy/sucker/sucker = locateUID(item_UID)
	if(!sucker)
		return FALSE

	if(receiver.r_hand && receiver.l_hand)
		to_chat(receiver, span_warning("You need to have your hands free to accept [sucker]!"))
		return FALSE

	if(!borg.Adjacent(receiver))
		to_chat(receiver, span_warning("You need to stay in reaching distance of [borg] to take [sucker]!"))
		return FALSE

	UnregisterSignal(sucker, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	borg.cell.charge -= 500
	sucker.forceMove(get_turf(borg))
	receiver.put_in_hands(sucker, ignore_anim = FALSE)
	sucker.add_fingerprint(receiver)
	sucker.on_give(borg, receiver)
	receiver.visible_message(span_notice("[borg] handed [sucker] to [receiver]."))
	receiver.clear_alert("take item [item_UID]")
	return TRUE
