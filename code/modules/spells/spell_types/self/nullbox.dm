/datum/action/cooldown/spell/nullbox
	name = "Призыв блюспейс коробки"
	desc = "Позволяет призывать блюспейс коробку, способную проходить сквозь пол и потолок между этажами, как если бы вы находились в космосе. \
			Если у станции один этаж, коробка бесполезна. Нельзя перейти на другой этаж, если в целевом месте кто-то или что-то находится."
	cooldown_time = 25 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	button_icon_state = "move_up_down"
	sound = 'sound/magic/magic_missile.ogg'

/datum/action/cooldown/spell/nullbox/cast(atom/cast_on)
	. = ..()
	var/mutable_appearance/fake_box = mutable_appearance('icons/obj/cardboard_boxes.dmi', "agentbox")
	fake_box.color = RANDOM_COLOUR
	fake_box.pixel_z = 30
	var/atom/movable/flick_visual/fake_box_visual = cast_on.flick_overlay_view(fake_box, 0.4 SECONDS)
	animate(fake_box_visual, pixel_z = 0, time = 0.3 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(finish_hide), cast_on, fake_box), 0.3 SECONDS)

/datum/action/cooldown/spell/nullbox/proc/finish_hide(mob/user, mutable_appearance/fake_box)
	if(!isturf(user.loc))
		user.balloon_alert(user, "нужно больше места!")
		return

	// Spawn the actual box
	var/obj/structure/closet/cardboard/agent/nullspace/box = new(user.loc)
	box.color = fake_box.color
	box.implant_user_UID = user.UID()
	box.create_fake_box()
	user.forceMove(box)
