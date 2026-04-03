/obj/item/gun/energy/clockwork
	name = "clockwork shotgun"
	desc = "Дробовик из латуни с самовосполняющимися за счет энергии Ратвара патронами. От него исходит ритмичное тиканье."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "brassshotgun"
	item_state = "brassshotgun"
	can_holster = FALSE
	slot_flags = ITEM_SLOT_BACK
	weapon_weight = WEAPON_HEAVY
	can_add_sibyl_system = FALSE
	ammo_type = list(/obj/item/ammo_casing/energy/rat/slug)
	can_charge = FALSE
	pb_knockback = 2
	cell_type = /obj/item/stock_parts/cell/clock/shotgun
	var/charge_rate = 2
	var/charge_speed = 7 SECONDS
	var/haveKnockback = TRUE
	var/defaultpb_knockback = 2
	var/def_bullet = /obj/item/ammo_casing/energy/rat/slug
	var/emp_bullet = /obj/item/ammo_casing/energy/rat/slug/emp
	var/heal_bullet = /obj/item/ammo_casing/energy/rat/slug/heal
	var/stun_bullet = /obj/item/ammo_casing/energy/rat/slug/stun
	isclockwork = TRUE
	blocks_emissive = FALSE

/obj/item/gun/energy/clockwork/get_ru_names()
	return list(
		NOMINATIVE = "латунный дробовик",
		GENITIVE = "латунного дробовика",
		DATIVE = "латунному дробовику",
		ACCUSATIVE = "латунный дробовик",
		INSTRUMENTAL = "латунным дробовиком",
		PREPOSITIONAL = "латунном дробовике",
	)

/obj/item/gun/energy/clockwork/examine(mob/user)
	. = ..()
	if(!isclocker(user))
		return
	. += span_clockitalic("\n Остал[declension_ru(cell.charge, "ся", "ось", "ось")] [cell.charge] заряд[DECL_CREDIT(cell.charge)].")

/obj/item/gun/energy/clockwork/proc/charge()
	cell.charge = min(cell.charge + charge_rate, cell.maxcharge)

/obj/item/gun/energy/clockwork/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(charge)), charge_speed, TIMER_LOOP | TIMER_DELETE_ME)
	enchants = GLOB.gun_and_heart_spells

/obj/item/gun/energy/clockwork/update_overlays()
	if(!enchant_type)
		return ..()
	. += "[initial(icon_state)]_overlay_[enchant_type]"

/obj/item/gun/energy/clockwork/add_enchant()
	switch(enchant_type)
		if(EMP_G_SPELL)
			ammo_type = list(emp_bullet)
		if(HEAL_G_SPELL)
			ammo_type = list(heal_bullet)
		if(STUN_G_SPELL)
			ammo_type = list(stun_bullet)
		else
			ammo_type = list(def_bullet)
	update_ammo_types()
	if(enchant_type && haveKnockback)
		pb_knockback = 0
	if(!enchant_type && haveKnockback)
		pb_knockback = defaultpb_knockback
	if(chambered)
		QDEL_NULL(chambered)
	newshot()

/obj/item/gun/energy/clockwork/update_icon_state()
	return

/obj/item/gun/energy/clockwork/emp_act(severity)
	return

/obj/item/gun/energy/clockwork/process_fire(atom/target, mob/living/carbon/human/user, message, params, zone_override, bonus_spread)
	if(!isclocker(user))
		kill_shooter(user)
		return
	. = ..()
	if(!enchant_type)
		return
	remove_enchanted_bullet()

/obj/item/gun/energy/clockwork/proc/kill_shooter(mob/living/carbon/shooter)
	var/zone = BODY_ZONE_HEAD
	if(!shooter.get_organ(zone))
		zone = BODY_ZONE_CHEST
	playsound(src, 'sound/weapons/gunshots/gunshot_strong.ogg', 50, TRUE)
	shooter.visible_message(span_danger("[declent_ru(NOMINATIVE)] начинает ярко светиться!"))
	if(iscultist(shooter))
		to_chat(shooter, span_clocklarge("Получи, грязный еретик!"))
	else
		to_chat(shooter, span_clocklarge("Руки прочь!"))
	shooter.apply_damage(300, BRUTE, zone, sharp = TRUE, used_weapon = "Выстрелил себе в [GLOB.body_zone[zone][ACCUSATIVE]] из [declent_ru(GENITIVE)].")
	shooter.bleed(BLOOD_VOLUME_NORMAL)
	shooter.death()

/obj/item/gun/energy/clockwork/proc/remove_enchanted_bullet()
	deplete_spell()
	pb_knockback = 2
	ammo_type = list(def_bullet)
	update_ammo_types()
	if(chambered)
		QDEL_NULL(chambered)
	newshot()

/obj/item/gun/energy/clockwork/sniper
	name = "clockwork sniper rifle"
	desc = "Снайперская винтовка из латуни с самовосполняющимися за счет энергии Ратвара патронами. От неё исходит ритмичное тиканье."
	icon_state = "brasssniper"
	item_state = "brasssniper"
	ammo_type = list(/obj/item/ammo_casing/energy/rat/snipe)
	zoomable = TRUE
	zoom_amt = 7 //Long range, enough to see in front of you, but no tiles behind you.
	cell_type = /obj/item/stock_parts/cell/clock/sniper
	charge_rate = 1
	recoil = new /datum/gun_recoil/mega()
	charge_speed = 10 SECONDS
	pb_knockback = 0
	haveKnockback = FALSE
	fire_delay = 2 SECONDS

	def_bullet = /obj/item/ammo_casing/energy/rat/snipe
	emp_bullet = /obj/item/ammo_casing/energy/rat/snipe/emp
	heal_bullet = /obj/item/ammo_casing/energy/rat/snipe/heal
	stun_bullet =/obj/item/ammo_casing/energy/rat/snipe/stun

/obj/item/gun/energy/clockwork/sniper/get_ru_names()
	return list(
		NOMINATIVE = "латунная снайперская винтовка",
		GENITIVE = "латунной снайперской винтовки",
		DATIVE = "латунной снайперской винтовке",
		ACCUSATIVE = "латунную снайперскую винтовку",
		INSTRUMENTAL = "латунной снайперской винтовкой",
		PREPOSITIONAL = "латунной снайперской винтовке",
	)

/obj/item/gun/energy/gun/minigun/clockwork
	name = "brass minigun"
	desc = "Устройство из множества шестеренок и латунных запчастей. Выглядит устрашающе."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockgun"
	item_state = "clockgun"
	burst_size = 1
	selfcharge = FALSE
	cell_type = /obj/item/stock_parts/cell/clock/minigun
	isclockwork = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/laser/light/rat)
	recoil = new /datum/gun_recoil/high()
	blocks_emissive = FALSE
	COOLDOWN_DECLARE(overheated)
	COOLDOWN_DECLARE(balloon)
	var/datum/component/automatic_fire/autofire
	var/overheat = FALSE
	var/last_fire = 0
	var/delay_no_beacon = 50
	var/gun_charge_delay = 20
	var/last_charge = 0
	var/charging_amount = 25
	var/cool_time = 15 SECONDS
	var/default_bullet = /obj/item/ammo_casing/energy/laser/light/rat
	var/attack_bullet = /obj/item/ammo_casing/energy/rat_sphere/attack
	var/heal_bullet = /obj/item/ammo_casing/energy/rat_sphere/heal

/obj/item/gun/energy/gun/minigun/clockwork/get_ru_names()
	return list(
		NOMINATIVE = "латунный миниган",
		GENITIVE = "латунного минигана",
		DATIVE = "латунному минигану",
		ACCUSATIVE = "латунный миниган",
		INSTRUMENTAL = "латунным миниганом",
		PREPOSITIONAL = "латунном минигане",
	)

/obj/item/gun/energy/gun/minigun/clockwork/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprocessing, src)
	enchants = GLOB.minigun_spells

/obj/item/gun/energy/gun/minigun/clockwork/process()
	. = ..()
	update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)
	var/obj/structure/clockwork/functional/beacon/beacon_near = locate() in range(5, src.loc)
	if(last_fire == 0)
		return
	if(!(world.time >= last_fire + delay_no_beacon) && isnull(beacon_near))
		return
	if(!(world.time >= last_charge + gun_charge_delay))
		return
	cell.charge = min(cell.charge + charging_amount, cell.maxcharge)
	last_charge = world.time
	if(COOLDOWN_FINISHED(src, overheated))
		overheat = FALSE

/obj/item/gun/energy/gun/minigun/clockwork/ComponentInitialize()
	AddComponent( \
		/datum/component/automatic_fire, \
		0.1 SECONDS \
		)
	autofire = src.GetComponent(/datum/component/automatic_fire)

/obj/item/gun/energy/gun/minigun/clockwork/update_overlays()
	. = ..()
	if(overheat)
		. += "[initial(icon_state)]_overheated"
	if(enchant_type && enchant_type != CASTING_SPELL)
		. += "[initial(icon_state)]_overlay_[enchant_type]"

/obj/item/gun/energy/gun/minigun/clockwork/update_icon_state()
	if(autofire.autofire_stat == AUTOFIRE_STAT_FIRING && !overheat)
		icon_state = "clockgun_firing"
	else
		icon_state = "clockgun"

/obj/item/gun/energy/gun/minigun/clockwork/pickup(mob/user)
	if(isclocker(user))
		return ..()
	user.drop_item_ground(src, TRUE)
	var/obj/item/organ/external/limb_to_burn = user.get_organ((user.hand == ACTIVE_HAND_LEFT) ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
	limb_to_burn.droplimb(TRUE, DROPLIMB_BURN)

/obj/item/gun/energy/gun/minigun/clockwork/add_enchant()
	update_bullet()

/obj/item/gun/energy/gun/minigun/clockwork/proc/update_bullet()
	switch(enchant_type)
		if(MINIGUN_ATTACK)
			ammo_type = list(attack_bullet)
		if(MINIGUN_HEAL)
			ammo_type = list(heal_bullet)
		else
			ammo_type = list(default_bullet)
	update_ammo_types()
	if(chambered)
		QDEL_NULL(chambered)
	newshot()

/obj/item/gun/energy/gun/minigun/clockwork/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	if(overheat)
		if(COOLDOWN_FINISHED(src, balloon))
			balloon_alert(user, "миниган перегрет!")
			COOLDOWN_START(src, balloon, 1 SECONDS)
		return
	if(enchant_type > 0)
		COOLDOWN_START(src, overheated, cool_time)
		overheat = TRUE
		enchant_type = NO_SPELL
	last_fire = world.time
	. = ..()
	update_bullet()
