/obj/effect/proc_holder/spell/aoe/conjure/build/mime_wall
	name = "Невидимая стена"
	desc = "Мимическая постановка становится осязаемой."
	school = "mime"
	summon_type = list(/obj/effect/forcefield/mime)
	invocation_type = "emote"
	invocation_emote_self = span_notice("Вы создаёте стену перед cобой.")
	summon_lifespan = 30 SECONDS
	base_cooldown = 30 SECONDS
	clothes_req = FALSE
	cast_sound = null
	human_req = TRUE

	action_icon_state = "mime"
	action_background_icon_state = "bg_mime"


/obj/effect/proc_holder/spell/aoe/conjure/build/mime_wall/Click()
	if(usr && usr.mind)
		if(!usr.mind.miming)
			to_chat(usr, span_warning("Сначала вы должны принять обет молчания!"))
			return
		invocation = "<B>[usr]</B> выглядит так, как будто бы перед [genderize_ru(usr.gender, "ним", "ней", "ним", "ними")] находится стена."
	else
		invocation_type ="none"
	..()


/obj/effect/proc_holder/spell/mime/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/mime/speak
	name = "Обет молчания"
	desc = "Примите или нарушьте обет молчания."
	school = "mime"
	clothes_req = FALSE
	base_cooldown = 5 MINUTES
	human_req = TRUE

	action_icon_state = "mime_silence"
	action_background_icon_state = "bg_mime"


/obj/effect/proc_holder/spell/mime/speak/Click()
	if(!usr)
		return
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr
	if(user.mind.miming)
		still_recharging_msg = span_warning("Вы не можете так быстро нарушить свой обет молчания!")
	else
		still_recharging_msg = span_warning("Вам придётся подождать, прежде чем вы сможете снова дать обет молчания!")
	..()


/obj/effect/proc_holder/spell/mime/speak/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/target = targets[1]

	if(!target.mind)
		return

	target.mind.miming = !target.mind.miming

	if(target.mind.miming)
		to_chat(target, span_notice("Вы даёте обет молчания."))
	else
		to_chat(target, span_notice("Вы нарушаете свой обет молчания."))


/obj/effect/proc_holder/spell/mime/speak/mask
/obj/effect/proc_holder/spell/mime/speak/mask/on_cooldown_tick()
	var/mob/living/carbon/human/user = action.owner
	if(user && cooldown_handler.should_end_cooldown() && !istype(user.wear_mask, /obj/item/clothing/mask/gas/mime))
		if(user.mind?.miming)
			cast(list(user))
		user.mind?.RemoveSpell(src)


//Advanced Mimery traitor item spells

/obj/effect/proc_holder/spell/forcewall/mime
	name = "Великая Невидимая стена"
	desc = "Создайте перед собой невидимую стену шириной в три тайла."
	school = "mime"
	wall_type = /obj/effect/forcefield/mime/advanced
	invocation_type = "emote"
	invocation_emote_self = span_notice("Вы создаёте стену перед cобой.")
	base_cooldown = 60 SECONDS
	sound =  null
	clothes_req = FALSE

	action_icon_state = "mime_bigwall"
	action_background_icon_state = "bg_mime"
	large = TRUE


/obj/effect/proc_holder/spell/forcewall/mime/Click()
	if(usr && usr.mind)
		if(!usr.mind.miming)
			to_chat(usr, span_warning("Сначала вы должны принять обет молчания!"))
			return
		invocation = "<B>[usr]</B> выглядит так, как будто бы перед [genderize_ru(usr.gender, "ним", "ней", "ним", "ними")] находится стена."
	else
		invocation_type ="none"
	..()


/obj/effect/proc_holder/spell/mime/fingergun
	name = "Пальцы-пистолеты"
	desc = "Стреляйте из пальцев бесшумными смертоносными пулями! В вашем распоряжении будет 3 пули. Пау-пау-пау!"
	school = "mime"
	clothes_req = FALSE
	base_cooldown = 1 MINUTES
	human_req = TRUE

	action_icon_state = "fingergun"
	action_background_icon_state = "bg_mime"
	var/gun = /obj/item/gun/projectile/revolver/fingergun
	var/obj/item/gun/projectile/revolver/fingergun/current_gun


/obj/effect/proc_holder/spell/mime/fingergun/fake
	desc = "Представьте, что вы стреляете из пальцев, как из пистолета! В вашем распоряжении будет 6 пуль. Пау-пау-пау!"
	gun = /obj/item/gun/projectile/revolver/fingergun/fake


/obj/effect/proc_holder/spell/mime/fingergun/Destroy()
	current_gun = null
	return ..()


/obj/effect/proc_holder/spell/mime/fingergun/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/human/target in targets)
		if(!current_gun)
			to_chat(user, span_notice("Вы взводите свои пальцы!"))
			current_gun = new gun(get_turf(user), src)
			target.drop_from_active_hand()
			target.put_in_hands(current_gun)
			RegisterSignal(target, COMSIG_MOB_KEY_DROP_ITEM_DOWN, PROC_REF(holster_hand))
		else
			holster_hand(user)
			revert_cast(user)


/obj/effect/proc_holder/spell/mime/fingergun/proc/holster_hand(atom/target)
	SIGNAL_HANDLER
	if(!current_gun || action.owner.get_active_hand() != current_gun)
		return
	to_chat(action.owner, span_notice("Вы ставите свои пальцы на предохранитель! Пока что..."))
	QDEL_NULL(current_gun)
	return COMPONENT_CANCEL_DROP


// Mime Spellbooks

/obj/item/spellbook/oneuse/mime
	spell = /obj/effect/proc_holder/spell/aoe/conjure/build/mime_wall
	spellname = "Невидимая стена"
	name = "Miming Manual"
	desc = "В книге представлены разнообразные фотографии, на которых запечатлены мимы в процессе выступления, а также несколько иллюстрированных руководств."
	ru_names = list(
		NOMINATIVE = "руководство по пантомимам",
		GENITIVE = "руководства по пантомимам",
		DATIVE = "руководству по пантомимам",
		ACCUSATIVE = "руководство по пантомимам",
		INSTRUMENTAL = "руководством по пантомимам",
		PREPOSITIONAL = "руководстве по пантомимам"
	)
	icon_state = "bookmime"


/obj/item/spellbook/oneuse/mime/attack_self(mob/user)
	if(!user.mind)
		return
	for(var/obj/effect/proc_holder/spell/knownspell as anything in user.mind.spell_list)
		if(knownspell.type == spell)
			balloon_alert(user, "вы уже знаете это!")
			return
	if(used)
		recoil(user)
	else
		user.mind.AddSpell(new spell)
		to_chat(user, span_notice("Вы впитываете в себя содержимое книги, приобретая новую способность - <b>\"[spellname]\"</b>!"))
		user.create_log(MISC_LOG, "learned the spell [spellname]")
		user.create_attack_log("<font color='orange'>[key_name(user)] learned the spell [spellname].</font>")
		onlearned(user)


/obj/item/spellbook/oneuse/mime/recoil(mob/user)
	to_chat(user, span_notice("Вы пролистываете страницы, но не находите ничего интересного для себя."))


/obj/item/spellbook/oneuse/mime/onlearned(mob/user)
	used = TRUE
	if(!locate(/obj/effect/proc_holder/spell/mime/speak) in user.mind.spell_list) //add vow of silence if not known by user
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/mime/speak)
		to_chat(user, span_notice("Вы узнали, как применять обет молчания в своих представлениях."))


/obj/item/spellbook/oneuse/mime/fingergun
	spell = /obj/effect/proc_holder/spell/mime/fingergun
	spellname = "Пальцы-пистолеты"
	desc = "Содержит изображения оружия, а также способы его имитации с помощью пантомим."


/obj/item/spellbook/oneuse/mime/fingergun/fake
	spell = /obj/effect/proc_holder/spell/mime/fingergun/fake


/obj/item/spellbook/oneuse/mime/greaterwall
	spell = /obj/effect/proc_holder/spell/forcewall/mime
	spellname = "Великая Невидимая стена"
	desc = "Содержит изображения выдающихся сооружений, которые оставили след в истории человечества."

