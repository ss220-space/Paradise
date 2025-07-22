//pyro claws
/obj/item/twohanded/required/pyro_claws
	name = "hardplasma energy claws"
	ru_names = list(
		NOMINATIVE = "энергокогти", \
		GENITIVE = "энергокогтей", \
		DATIVE = "энергокогтям", \
		ACCUSATIVE = "энергокогти", \
		INSTRUMENTAL = "энергокогтями", \
		PREPOSITIONAL = "энергокогтях"
	)
	desc = "Мощь солнца, в моих когтях!"
	gender = PLURAL
	icon_state = "pyro_claws"
	item_flags = ABSTRACT|DROPDEL
	force = 25
	force_wielded = 25
	damtype = BURN
	armour_penetration = 40
	block_chance = 50
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut", "savaged", "clawed")
	toolspeed = 0.5

/obj/item/twohanded/required/pyro_claws/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	START_PROCESSING(SSobj, src)

/obj/item/twohanded/required/pyro_claws/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/twohanded/required/pyro_claws/process()
	if(prob(15))
		do_sparks(rand(1,6), 1, loc)

/obj/item/twohanded/required/pyro_claws/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return

	if(prob(60))
		do_sparks(rand(1,6), 1, loc)

	if(!istype(target, /obj/machinery/door/airlock))
		return

	var/obj/machinery/door/airlock/airlock = target

	if(!airlock.requiresID() || airlock.allowed(user))
		return

	if(airlock.locked)
		to_chat(user, span_notice("Болты шлюза не позволяют взломать его силой."))
		return

	if(airlock.arePowerSystemsOn())
		user.visible_message(span_warning("[user] вставля[pluralize_ru(user.gender,"ет","ют")] [declent_ru(NOMINATIVE)] в шлюз и начина[pluralize_ru(user.gender,"ет","ют")] открывать его!"), \
							span_warning("Вы начинаете силой открывать шлюз."), \
							span_warning("Вы слышите металлический скрежет."))
		playsound(airlock, 'sound/machines/airlock_alien_prying.ogg', 150, TRUE)
		if(!do_after(user, 2.5 SECONDS, airlock))
			return

	user.visible_message(span_warning("[user] силой открыл[genderize_ru(user.gender, "", "а", "о", "и")] шлюз при помощи [declent_ru(GENITIVE)]!"), \
						span_warning("Вы силой открыли шлюз."), \
						span_warning("Вы слышите металлический скрежет."))
	airlock.open(2)

/obj/item/twohanded/required/pyro_claws/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] начина[pluralize_ru(user.gender,"ет","ют")] пилить [declent_ru(NOMINATIVE)] друг об друга! \
						Похоже [genderize_ru(user.gender, "он", "она", "оно", "они")] пыта[pluralize_ru(user.gender,"ет","ют")]ся убить себя!"))
	user.adjust_fire_stacks(10)
	user.IgniteMob()
	return FIRELOSS

/obj/item/clothing/gloves/color/black/pyro_claws
	name = "fusion gauntlets"
	ru_names = list(
		NOMINATIVE = "плавящие перчатки", \
		GENITIVE = "плавящих перчаток", \
		DATIVE = "плавящим перчаткам", \
		ACCUSATIVE = "плавящие перчатки", \
		INSTRUMENTAL = "плавящими перчатками", \
		PREPOSITIONAL = "плавящих перчатках"
	)
	desc = "Перчатки разработаенные Cybersun Industries после того, как один из солдат прикрепил ядро атмосферной аномалии ​​к \
			энергетическому мечу, и нашел результат весьма эффективными."
	gender = PLURAL
	item_state = "pyro"
	item_color = "pyro"
	icon_state = "pyro"
	can_be_cut = FALSE
	actions_types = list(/datum/action/item_action/toggle)
	var/on_cooldown = FALSE
	var/used = FALSE
	var/obj/item/assembly/signaler/core/atmospheric/core

/obj/item/clothing/gloves/color/black/pyro_claws/Destroy()
	QDEL_NULL(core)
	return ..()

/obj/item/clothing/gloves/color/black/pyro_claws/examine(mob/user)
	. = ..()
	if(core)
		. += span_notice("[declent_ru(NOMINATIVE)] полностью работоспособны.")
		return

	. += span_warning("[declent_ru(NOMINATIVE)] требуют атмосферное ядро для работы!")

/obj/item/clothing/gloves/color/black/pyro_claws/item_action_slot_check(slot, mob/user, datum/action/action)
	return slot == ITEM_SLOT_GLOVES

/obj/item/clothing/gloves/color/black/pyro_claws/ui_action_click(mob/user, datum/action/action, leftclick)
	if(!core)
		user.balloon_alert(user, "нет ядра")
		return

	if(on_cooldown)
		user.balloon_alert(user, "идет перезарядка")
		do_sparks(rand(1,6), 1, loc)
		return

	if(used)
		visible_message(span_warning("Энергетические когти скользят обратно в [declent_ru(ACCUSATIVE)]."))
		user.drop_from_active_hand(force = TRUE)//dropdel stuff. only ui act, without hotkeys
		do_sparks(rand(1,6), 1, loc)
		on_cooldown = TRUE
		addtimer(CALLBACK(src, PROC_REF(reboot)), 1 MINUTES)
		return

	if(user.get_active_hand() && !user.drop_from_active_hand())
		to_chat(user, span_notice("[declent_ru(NOMINATIVE)] не могут выпустить клинки, пока у вас в руках есть предметы!"))
		return

	var/obj/item/twohanded/required/pyro_claws/claws = new /obj/item/twohanded/required/pyro_claws
	var/strength_mult = core.get_strength() / 150
	claws.force = 25 * strength_mult
	claws.force_wielded = 25 * strength_mult
	claws.armour_penetration = 100 * (1 - 0.6 / strength_mult)
	claws.block_chance = 100 * (1 - 0.5 / strength_mult)
	claws.toolspeed = 0.5 / strength_mult

	user.visible_message(span_warning("[user] со снопом искр выпуска[pluralize_ru(user.gender,"ет","ют")] [claws.declent_ru(NOMINATIVE)] из запястий!"), \
						span_notice("Вы выпускаете [claws.declent_ru(NOMINATIVE)] из [declent_ru(GENITIVE)]!"), \
						span_warning("Вы слышите сноп искр!"))
	user.put_in_hands(claws)
	ADD_TRAIT(src, TRAIT_NODROP, PYRO_CLAWS_TRAIT)
	used = TRUE
	do_sparks(rand(1,6), 1, loc)


/obj/item/clothing/gloves/color/black/pyro_claws/attackby(obj/item/item, mob/user, params)
	if(!iscoreatmos(item))
		return ..()

	var/obj/item/assembly/signaler/core/I_core = item
	if(I_core.get_strength() < 100)
		user.balloon_alert(user, "ядро слишком слабо")
		return

	add_fingerprint(user)
	var/msg = "ядро вставлено"
	if(core)
		if(!user.put_in_hands(core))
			core.forceMove(get_turf(user))

		msg = "ядро заменено"

	if(!user.drop_transfer_item_to_loc(item, src))
		balloon_alert(user, "отпустить невозможно!")
		return ATTACK_CHAIN_PROCEED

	user.balloon_alert(user, msg)
	to_chat(user, span_notice("Вы вставили [item.declent_ru(NOMINATIVE)] в [declent_ru(ACCUSATIVE)]. \
	От [declent_ru(GENITIVE)] начал исходить жар."))
	core = item
	return ATTACK_CHAIN_BLOCKED_ALL

/obj/item/clothing/gloves/color/black/pyro_claws/click_alt(mob/user)
	if(!user.contains(src))
		return

	if(!core)
		user.balloon_alert(user, "нет ядра")
		return

	if(!user.put_in_hands(core))
		core.forceMove(get_turf(user))

	core = null
	user.balloon_alert(user, "ядро извлечено")

/obj/item/clothing/gloves/color/black/pyro_claws/proc/reboot()
	on_cooldown = FALSE
	used = FALSE
	REMOVE_TRAIT(src, TRAIT_NODROP, PYRO_CLAWS_TRAIT)
	atom_say("Внутренние плазменные баллоны перезаряжены. Перчатки достаточно охлаждены.", FALSE)

/obj/item/clothing/gloves/color/black/pyro_claws/preloaded
	core = new /obj/item/assembly/signaler/core/atmospheric/tier2()
