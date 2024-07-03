/obj/effect/proc_holder/spell/horsemask
	name = "Curse of the Horseman"
	desc = "Это заклинание накладывает проклятие на цель, заставляя ее носить несъемную маску с лошадиной головой. Цель будет ржать как лошадь! Все маски, которые на надеты на цель, будут уничтожены. Для этого заклинания не требуется роба."
	school = "transmutation"
	base_cooldown = 15 SECONDS
	cooldown_min = 3 SECONDS //30 deciseconds reduction per rank
	clothes_req = FALSE
	human_req = FALSE
	stat_allowed = CONSCIOUS
	invocation = "KN'A FTAGHU, PUCK 'BTHNK!"
	invocation_type = "shout"

	selection_activated_message = "<span class='notice'>Вы начинаете тихо ржать заклинание. Нажмите на цель или рядом с ней, чтобы произнести заклинание.</span>"
	selection_deactivated_message = "<span class='notice'>Вы перестаёте ржать про себя.</span>"

	action_icon_state = "barn"
	sound = 'sound/magic/HorseHead_curse.ogg'
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/horsemask/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.selection_type = SPELL_SELECTION_RANGE
	return T


/obj/effect/proc_holder/spell/horsemask/cast(list/targets, mob/user = usr)
	if(!targets.len)
		user.balloon_alert(user, "рядом нет подходящих целей!")
		return

	var/mob/living/carbon/human/target = targets[1]

	var/obj/item/clothing/mask/horsehead/magichead = new /obj/item/clothing/mask/horsehead
	magichead.item_flags |= DROPDEL	//curses!
	ADD_TRAIT(magichead, TRAIT_NODROP, CURSED_ITEM_TRAIT(magichead.type))
	magichead.flags_inv &= ~HIDENAME	//so you can still see their face
	magichead.voicechange = TRUE	//NEEEEIIGHH
	target.visible_message(	"<span class='danger'>лицо [target] загорается, на его месте появляется лошадиная морда!</span>", \
							"<span class='danger'>Твоё лицо горит, и вскоре ты понимаешь, что у тебя лошадиная морда!</span>")
	if(!target.drop_item_ground(target.wear_mask))
		qdel(target.wear_mask)
	target.equip_to_slot_or_del(magichead, ITEM_SLOT_MASK)

	target.flash_eyes()

