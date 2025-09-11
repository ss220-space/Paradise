#define REVIVE_SPELL_TIME 5 MINUTES
#define REVIVE_SPELL_NECROSIS_PROB 30

/obj/effect/proc_holder/spell/summon_wealth
	name = "Призвать богатство"
	desc = "Ваша награда за продажу души."

	invocation_type = "whisper"
	invocation = "Divitiae, da mihi divitias"

	school = "conjuration"
	clothes_req = FALSE
	base_cooldown = 10 SECONDS
	cooldown_min = 1 SECONDS
	action_icon_state = "moneybag"


/obj/effect/proc_holder/spell/summon_wealth/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.range = 7
	return T


/obj/effect/proc_holder/spell/summon_wealth/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/C in targets)
		if(user.drop_from_active_hand())
			var/obj/item = pick(
					new /obj/item/coin/gold(user.loc),
					new /obj/item/coin/diamond(user.loc),
					new /obj/item/coin/silver(user.loc),
					new /obj/item/stack/sheet/mineral/gold(user.loc),
					new /obj/item/stack/sheet/mineral/silver(user.loc),
					new /obj/item/stack/sheet/mineral/diamond(user.loc),
					new /obj/item/stack/spacecash/c1000(user.loc))
			C.put_in_active_hand(item)


/obj/effect/proc_holder/spell/view_range
	name = "Дальний взор"
	desc = "Ваша награда за продажу души."

	invocation_type = "whisper"
	invocation = "Da mihi divinum aspectum"

	clothes_req = FALSE
	base_cooldown = 5 SECONDS
	cooldown_min = 1 SECONDS
	action_icon_state = "camera_jump"
	/// Currently selected view range
	var/selected_view = "default"
	/// View ranges to apply
	var/static/list/view_ranges = list(
		"default",
		"17x17",
		"19x19",
		"21x21",
	)


/obj/effect/proc_holder/spell/view_range/Destroy(force)
	UnregisterSignal(action.owner, COMSIG_LIVING_DEATH)
	if(selected_view == "default" || QDELETED(action.owner) || !action.owner.client)
		return ..()
	ASYNC
		action.owner.client.change_view(action.owner.client.prefs.viewrange)
	return ..()

/obj/effect/proc_holder/spell/view_range/proc/make_view_normal(mob/user)
	SIGNAL_HANDLER
	if(!QDELETED(user) && user.client)
		INVOKE_ASYNC(user.client, TYPE_PROC_REF(/client, change_view), user.client.prefs.viewrange)

/obj/effect/proc_holder/spell/view_range/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/view_range/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	if(!user.client)
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/view_range/on_spell_gain(mob/user = usr)
	RegisterSignal(user, COMSIG_LIVING_DEATH, TYPE_PROC_REF(/obj/effect/proc_holder/spell/view_range, make_view_normal))

/obj/effect/proc_holder/spell/view_range/cast(list/targets, mob/user = usr)
	var/new_view = tgui_input_list(user, "Выберите область видимости:", "Видимость", view_ranges, "default")
	if(isnull(new_view) || !user.client)
		return
	if(new_view == "default")
		new_view = user.client.prefs.viewrange
	selected_view = new_view
	user.client.change_view(new_view)


/obj/effect/proc_holder/spell/view_range/genetic
	desc = "Позволяет вам выбрать, как далеко вы будете видеть."
	invocation_type = "none"
	invocation = null

/obj/effect/proc_holder/spell/summon_friend
	name = "Призвать друга"
	desc = "Ваша награда за продажу души."

	invocation_type = "whisper"
	invocation = "Amicus meus fidelis infernalis, suus ' vicis"

	action_icon_state = "sacredflame"
	clothes_req = FALSE
	base_cooldown = 5 SECONDS
	cooldown_min = 1 SECONDS
	var/mob/living/friend
	var/obj/effect/mob_spawn/human/demonic_friend/friendShell


/obj/effect/proc_holder/spell/summon_friend/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/summon_friend/cast(list/targets, mob/user = usr)
	if(!QDELETED(friend))
		to_chat(friend, span_userdanger("Твой хозяин посчитал тебя плохим другом. Тебе пора обратно в ад."))
		to_chat(user, span_notice("Вы изгоняете вашего друга туда, откуда [genderize_ru(friend.gender, "он пришел", "она пришла", "оно пришло", "они пришли")]."))
		friend.dust()
		QDEL_NULL(friendShell)
		return
	if(!QDELETED(friendShell))
		QDEL_NULL(friendShell)
		return
	for(var/C in targets)
		var/mob/living/L = C
		friendShell = new /obj/effect/mob_spawn/human/demonic_friend(L.loc, L.mind, src)


/obj/effect/proc_holder/spell/touch/revive_touch
	name = "Воскрешающее косание"
	desc = "Чрезвычайно могущественное некромантическое заклинание"
	hand_path = /obj/item/melee/touch_attack/revive_touch
	school = "transmutation"

	base_cooldown = 1 MINUTES
	clothes_req = FALSE
	cooldown_min = 10 SECONDS //50 deciseconds reduction per rank
	action_icon_state = "revive"


/obj/item/melee/touch_attack/revive_touch
	name = "воскрешающее касание"
	desc = "Воскрешает тело умершего на определенное время."
	catchphrase = "Surge e lecto"
	on_use_sound = 'sound/magic/staff_healing.ogg'
	icon_state = "disintegrate"
	color = "#acb78e"

/obj/item/melee/touch_attack/revive_touch/get_ru_names()
	return list(
		NOMINATIVE = "воскрешающее касание",
		GENITIVE = "воскрешающего касания",
		DATIVE = "воскрешающему касанию",
		ACCUSATIVE = "воскрешающее касание",
		INSTRUMENTAL = "воскрешающим касанием",
		PREPOSITIONAL = "воскрешающем касании"
	)

/obj/item/melee/touch_attack/revive_touch/afterattack(atom/target, mob/living/carbon/user, proximity, params)
	. = ..()

	if(!isliving(target))
		return .

	var/mob/living/mob = target

	if(mob.stat != DEAD || !(mob.mind.is_revivable()))
		return .

	mob.revive()

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(late_death), mob), REVIVE_SPELL_TIME)

/proc/late_death(mob/living/mob)
	mob.death()

	if(!ishuman(mob))
		return

	necrotize_body(mob, REVIVE_SPELL_NECROSIS_PROB)

/obj/effect/proc_holder/spell/conjure_item/contract_gun
	name = "Призвать верное оружие"
	desc = "Призвать оружие, полученное в обмен на душу."

	invocation_type = "whisper"
	invocation = "Amicus meus, suus ' vicis"


	action_icon_state = "bolt_action_old"
	action_background_icon_state = "bg_demon"


/obj/effect/proc_holder/spell/conjure_item/contract_gun/Initialize(mapload, weapon_type)
	. = ..()
	item_type = weapon_type

/obj/effect/proc_holder/spell/conjure_item/contract_gun/update_item(obj/item/item)
	item.origin_tech = list()
	item.materials = list()
	ADD_TRAIT(item, TRAIT_NODROP, INNATE_TRAIT)
	ADD_TRAIT(item, TRAIT_NOT_TURRET_GUN, INNATE_TRAIT)

#undef REVIVE_SPELL_TIME
#undef REVIVE_SPELL_NECROSIS_PROB
