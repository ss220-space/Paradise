/obj/item/gun/energy/bsg
	name = "Б.С.П." // No \improper because it's russian name. "The Б.С.П." is worse than just "Б.С.П.".
	desc = "Большая С*** Пушка. Использует ядро энергетической аномалии и блюспейс кристалл для производства разрушительных взрывов энергии, вдохновленный дивизионом БСА Нанотрейзен."
	icon_state = "bsg"
	item_state = "bsg"
	origin_tech = "combat=6;materials=6;powerstorage=6;bluespace=6;magnets=6" //cutting edge technology, be my guest if you want to deconstruct one instead of use it.
	ammo_type = list(/obj/item/ammo_casing/energy/bsg)
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	can_holster = FALSE
	slot_flags = ITEM_SLOT_BACK
	cell_type = /obj/item/stock_parts/cell/bsg
	shaded_charge = TRUE
	gender = FEMALE
	/// Inserted flux anomaly core.
	var/obj/item/assembly/signaler/core/energetic/core = null
	var/has_bluespace_crystal = FALSE
	var/admin_model = FALSE //For the admin gun, prevents crystal shattering, so anyone can use it, and you dont need to carry backup crystals.

/obj/item/gun/energy/bsg/Destroy()
	if(!ismachinery(loc))
		core?.forceMove(get_turf(src))
	else
		core?.forceMove(loc)

	core = null
	. = ..()


/obj/item/gun/energy/bsg/examine(mob/user)
	. = ..()
	if(core && has_bluespace_crystal)
		. += span_notice("[src] в рабочем состоянии!")
		return

	if(core)
		. += span_warning("Ядро энергетической аномалии вставлено, но не хватает БС кристалла.")
		return

	if(has_bluespace_crystal)
		. += span_warning("БС кристалл присутствует, но не хватает ядра энергетической аномалии.")
		return

	. += span_warning("Не хватает ядра энергетической аномалии и БС кристалла для работы.")


/obj/item/gun/energy/bsg/attackby(obj/item/item, mob/user, params)
	if(isbluespacecrystal(item))
		add_fingerprint(user)
		var/obj/item/stack/ore/bluespace_crystal/crystal = item
		if(has_bluespace_crystal)
			balloon_alert(user, "уже установлено!")
			return ATTACK_CHAIN_PROCEED

		if(!crystal.use(1))
			balloon_alert(user, "недостаточно кристаллов!")
			return ATTACK_CHAIN_PROCEED

		balloon_alert(user, "установлено")
		has_bluespace_crystal = TRUE
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(iscoreflux(item))
		add_fingerprint(user)
		if(core)
			balloon_alert(user, "уже установлено!")
			return ATTACK_CHAIN_PROCEED

		var/obj/item/assembly/signaler/core/Icore = item
		if(Icore.get_strenght() < 140)
			balloon_alert(user, "ядро слишком слабо")
			return

		if(!user.drop_transfer_item_to_loc(item, src))
			return ..()

		balloon_alert(user, "установлено")
		core = item
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/gun/energy/bsg/click_alt(mob/user)
	if(!core)
		user.balloon_alert(user, "нет ядра")
		return

	if(!user.put_in_hands(core))
		core.forceMove(get_turf(user))

	core = null
	user.balloon_alert(user, "ядро извлечено")
	update_icon(UPDATE_ICON_STATE)

/obj/item/gun/energy/bsg/process_fire(atom/target, mob/living/user, message = TRUE, params, zone_override, bonus_spread = 0)
	if(!has_bluespace_crystal)
		balloon_alert(user, "нужен блюспейс кристалл")
		return

	if(!core)
		balloon_alert(user, "нужно ядро аномалии")
		return

	if(!chambered && can_shoot(user))
		process_chamber()

	if(!chambered?.BB)
		return ..()

	var/obj/projectile/energy/bsg/bsg_BB = chambered.BB
	bsg_BB.core_strenght = core.get_strenght()
	return ..()


/obj/item/gun/energy/bsg/update_icon_state()
	if(core)
		icon_state = "bsg_[has_bluespace_crystal ? "finished" : "core"]"
		return

	icon_state = "bsg[has_bluespace_crystal ? "_crystal" : ""]"


/obj/item/gun/energy/bsg/emp_act(severity)
	..()
	if(!prob(75 / severity))
		return

	if(has_bluespace_crystal)
		shatter()

/obj/item/gun/energy/bsg/proc/shatter()
	if(admin_model)
		return

	visible_message(span_warning("БС кристалл внутри [src] треснул!"))
	playsound(src, 'sound/effects/pylon_shatter.ogg', 50, TRUE)
	has_bluespace_crystal = FALSE
	update_icon(UPDATE_ICON_STATE)


/obj/item/gun/energy/bsg/turret_check()
	return core && has_bluespace_crystal


/obj/item/gun/energy/bsg/prepare_gun_data(list/data)
	data["core"] = core


/obj/item/gun/energy/bsg/turret_deconstruct(list/data)
	has_bluespace_crystal = TRUE
	core = data["core"]
	core.forceMove(src)


/obj/item/gun/energy/bsg/setup_gun_for_turret(list/data, turret)
	core = data["core"]
	has_bluespace_crystal = TRUE
	core.forceMove(turret)


/obj/item/gun/energy/bsg/prebuilt
	icon_state = "bsg_finished"
	has_bluespace_crystal = TRUE
	core = new /obj/item/assembly/signaler/core/energetic/tier3()

/obj/item/gun/energy/bsg/prebuilt/Initialize(mapload)
	. = ..()
	core.charge = 75
	update_icon(UPDATE_ICON_STATE)

/obj/item/gun/energy/bsg/prebuilt/admin
	desc = "Большая С*** Пушка. Лучшим людям ― лучшее творение. У этой версии БС кристалл никогда не треснет, и уже загружено ядро энергетической аномалии."
	admin_model = TRUE
	core = new /obj/item/assembly/signaler/core/energetic/tier3/tier4()

/obj/item/gun/energy/bsg/prebuilt/admin/Initialize(mapload)
	. = ..()
	core.charge = 100
	update_icon(UPDATE_ICON_STATE)
