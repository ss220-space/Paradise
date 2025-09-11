/**
 * # Banhammer
 */
/obj/item/banhammer
	desc = "banhammer"
	name = "banhammer"
	icon = 'icons/obj/items.dmi'
	icon_state = "toyhammer"
	slot_flags = ITEM_SLOT_BELT
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 7
	throw_range = 15
	attack_verb = list("banned")
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 70)
	resistance_flags = FIRE_PROOF

/obj/item/banhammer/suicide_act(mob/user)
	to_chat(viewers(user), span_suicide("[user] бь[pluralize_ru(user.gender,"ёт","ют")] себя [declent_ru(INSTRUMENTAL)]! Похоже, [genderize_ru(user.gender,"он","она","оно","они")] хоч[pluralize_ru(user.gender,"ет","ют")] заблокировать себя!"))
	return BRUTELOSS|FIRELOSS|TOXLOSS|OXYLOSS

/obj/item/banhammer/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	to_chat(target, span_danger("<b>Тебя [user] ЗАБАНИЛ БЕЗ ПРИЧИЙНЫ!</b>"))
	to_chat(user, span_danger("Вы <b>ЗАБАНИЛИ</b> [target]!"))
	playsound(loc, 'sound/effects/adminhelp.ogg', 15) //keep it at 15% volume so people don't jump out of their skin too much
	return ..()

/obj/item/banhammer/meta_hammer
	desc = "Наполнен мета-энергией."
	COOLDOWN_DECLARE(cooldown)

/obj/item/banhammer/meta_hammer/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!target)
		return ATTACK_CHAIN_PROCEED

	if(!COOLDOWN_FINISHED(src, cooldown))
		user.balloon_alert(user, "перезарядка!")
		return ATTACK_CHAIN_PROCEED_SUCCESS
	send_random_fake_pm(target)
	COOLDOWN_START(src, cooldown, 1 MINUTES)
	user.do_attack_animation(target)

	return ATTACK_CHAIN_PROCEED

/obj/item/sord
	name = "SORD"
	desc = "This thing is so unspeakably shitty you are having a hard time even holding it."
	icon_state = "sord"
	item_state = "sord"
	slot_flags = ITEM_SLOT_BELT
	force = 2
	throwforce = 1
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("атаковал", "полоснул", "уколол", "поранил", "порезал")

/obj/item/sord/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] пыта[pluralize_ru(user.gender,"ет","ют")]ся насадить себя на [declent_ru(ACCUSATIVE)]! Выглядит как попытка суицида, если бы не было так жалко."), span_suicide("Вы пытаетесь насадить себя на [declent_ru(ACCUSATIVE)], но это БЕСПОЛЕЗНО..."))
	return SHAME

/obj/item/melee/claymore
	name = "claymore"
	desc = "What are you standing around staring at this for? Get to killing!"
	icon_state = "claymore"
	item_state = "claymore"
	flags = CONDUCT
	hitsound = 'sound/weapons/bladeslice.ogg'
	slot_flags = ITEM_SLOT_BELT
	force = 40
	throwforce = 10
	sharp = 1
	embed_chance = 20
	pickup_sound = 'sound/items/handling/pickup/knife_pickup.ogg'
	drop_sound = 'sound/items/handling/drop/knife_drop.ogg'
	embedded_ignore_throwspeed_threshold = TRUE
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("атаковал", "полоснул", "уколол", "поранил", "порезал")
	block_chance = 50
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 50)
	resistance_flags = FIRE_PROOF

/obj/item/melee/claymore/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/cleave_attack, \
		arc_size = 180, \
		swing_speed_mod = 2, \
		afterswing_slowdown = 0.25, \
		slowdown_duration = 0.75 SECONDS, \
		swing_sound = SFX_BLADE_SWING_HEAVY \
	)

/obj/item/melee/claymore/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] падает на [declent_ru(ACCUSATIVE)]! Похоже, [genderize_ru(user.gender,"он","она","оно","они")] пыта[pluralize_ru(user.gender,"ет","ют")]ся покончить с собой."))
	return BRUTELOSS

/obj/item/melee/claymore/ceremonial
	name = "ceremonial claymore"
	desc = "An engraved and fancy version of the claymore. It appears to be less sharp than it's more functional cousin."
	force = 20

/obj/item/melee/katana
	name = "katana"
	desc = "Woefully underpowered in D20"
	icon_state = "katana"
	item_state = "katana"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT|ITEM_SLOT_BACK
	force = 40
	throwforce = 10
	sharp = 1
	embed_chance = 20
	embedded_ignore_throwspeed_threshold = TRUE
	w_class = WEIGHT_CLASS_NORMAL
	pickup_sound = 'sound/items/handling/pickup/knife_pickup.ogg'
	drop_sound = 'sound/items/handling/drop/knife_drop.ogg'
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("атаковал", "полоснул", "уколол", "поранил", "порезал")
	block_chance = 50
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 50)
	resistance_flags = FIRE_PROOF

/obj/item/melee/katana/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/cleave_attack, \
		swing_speed_mod = 1.75, \
		afterswing_slowdown = 0, \
		swing_sound = SFX_KATANA_SWING \
	)

/obj/item/melee/katana/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] вспарывает себе живот [declent_ru(INSTRUMENTAL)]! Похоже на попытку совершить сэппуку."))
	return BRUTELOSS

/obj/item/melee/katana/basalt
	name = "basalt katana"
	desc = "Катана, изготовленная из закалённого базальта, представляет особую опасность для обитателей Лазиса."
	icon_state = "basalt_katana"
	item_state = "basalt_katana"
	force = 30
	block_chance = 30
	var/faction_bonus_force = 30
	var/nemesis_factions = list("mining", "boss")

/obj/item/melee/katana/basalt/get_ru_names()
	return list(
		NOMINATIVE = "базальтовая катана",
		GENITIVE = "базальтовой катаны",
		DATIVE = "базальтовой катане",
		ACCUSATIVE = "базальтовую катану",
		INSTRUMENTAL = "базальтовой катаной",
		PREPOSITIONAL = "базальтовой катане"
	)


/obj/item/melee/katana/basalt/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	var/nemesis_faction = FALSE
	if(LAZYLEN(nemesis_factions))
		for(var/faction in target.faction)
			if(faction in nemesis_factions)
				nemesis_faction = TRUE
				force += faction_bonus_force
				break
	. = ..()
	if(nemesis_faction)
		force -= faction_bonus_force


/obj/item/harpoon
	name = "harpoon"
	sharp = 1
	embed_chance = 70
	embedded_ignore_throwspeed_threshold = TRUE
	desc = "Tharr she blows!"
	icon_state = "harpoon"
	item_state = "harpoon"
	force = 20
	throwforce = 15
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("уколол", "тыкнул")

/obj/item/wirerod
	name = "Wired rod"
	desc = "A rod with some wire wrapped around the top. It'd be easy to attach something to the top bit."
	icon_state = "wiredrod"
	item_state = "rods"
	flags = CONDUCT
	force = 9
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=1150, MAT_GLASS=75)
	attack_verb = list("ударил", "огрел")


/obj/item/wirerod/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/shard))
		add_fingerprint(user)
		if(loc == user && !user.can_unEquip(src))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		var/obj/item/twohanded/spear/spear
		if(istype(I, /obj/item/shard/plasma))
			spear = new /obj/item/twohanded/spear/plasma(drop_location())
		else
			spear = new /obj/item/twohanded/spear(drop_location())
		spear.add_fingerprint(user)
		to_chat(user, span_notice("Ты закрепляешь осколок стекла на конце стержня с помощью провода."))
		user.put_in_hands(spear, ignore_anim = FALSE)
		qdel(I)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(isigniter(I))
		add_fingerprint(user)
		if(loc == user && !user.can_unEquip(src))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		var/obj/item/melee/baton/security/cattleprod/cattleprod = new(drop_location())
		cattleprod.add_fingerprint(user)
		to_chat(user, span_notice("Ты закрепляешь [I.declent_ru(ACCUSATIVE)] на конце стержня с помощью провода."))
		user.put_in_hands(cattleprod, ignore_anim = FALSE)
		qdel(I)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/throwing_star
	name = "throwing star"
	desc = "An ancient weapon still used to this day due to it's ease of lodging itself into victim's body parts"
	icon_state = "throwingstar"
	item_state = "eshield0"
	force = 2
	throwforce = 20 //This is never used on mobs since this has a 100% embed chance.
	throw_speed = 4
	embedded_pain_multiplier = 4
	w_class = WEIGHT_CLASS_SMALL
	embed_chance = 100
	embedded_fall_chance = 0 //Hahaha!
	sharp = 1
	materials = list(MAT_METAL=500, MAT_GLASS=500)
	resistance_flags = FIRE_PROOF

/obj/item/melee/baseball_bat
	name = "baseball bat"
	desc = "There ain't a skull in the league that can withstand a swatter."
	icon = 'icons/obj/items.dmi'
	icon_state = "baseball_bat"
	item_state = "baseball_bat"
	var/deflectmode = FALSE // deflect small/medium thrown objects
	var/lastdeflect
	force = 10
	throwforce = 12
	attack_verb = list("beat", "шлёпнул")
	w_class = WEIGHT_CLASS_HUGE
	pickup_sound = 'sound/items/handling/pickup/wooden_pickup.ogg'
	drop_sound = 'sound/items/handling/drop/wooden_drop.ogg'
	var/next_throw_time = 0
	var/homerun_ready = 0
	var/homerun_able = 0
	var/can_deflect = TRUE
	var/homerun_always_charged = 0

/obj/item/melee/baseball_bat/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/cleave_attack, \
		swing_speed_mod = 2, \
		no_multi_hit = TRUE, \
		swing_sound = SFX_GENERIC_SWING_HEAVY \
	)

/obj/item/melee/baseball_bat/homerun
	name = "home run bat"
	desc = "This thing looks dangerous... Dangerously good at baseball, that is."
	homerun_able = 1

/obj/item/melee/baseball_bat/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	. = ..()
	if(!isitem(hitby) || attack_type != THROWN_PROJECTILE_ATTACK)
		return FALSE
	var/obj/item/I = hitby
	if(I.w_class <= WEIGHT_CLASS_NORMAL || istype(I, /obj/item/beach_ball)) // baseball bat deflecting
		if(deflectmode)
			if(prob(10))
				visible_message(span_boldwarning("[owner] отбива[pluralize_ru(owner.gender,"ет","ют")] [I.declent_ru(ACCUSATIVE)] прямо в метателя! Это хоум-ран!"), span_boldwarning("[pluralize_ru(owner.gender,"Ты отбиваешь","Вы отбиваете")] [I.declent_ru(ACCUSATIVE)] прямо в метателя! Это хоум-ран!"))
				playsound(get_turf(owner), 'sound/weapons/homerun.ogg', 100, TRUE)
				do_attack_animation(I, ATTACK_EFFECT_DISARM)
				I.throw_at(locateUID(I.thrownby), 20, 20, owner)
				deflectmode = FALSE
				if(!istype(I, /obj/item/beach_ball))
					lastdeflect = world.time + 600
				return TRUE
			else if(prob(30))
				visible_message(span_warning("[owner] замахива[pluralize_ru(owner.gender,"ет","ют")]ся... и промахива[pluralize_ru(owner.gender,"ет","ют")]ся! Как неловко..."), span_warning("[pluralize_ru(owner.gender,"Ты замахиваешься","Вы замахиваетесь")]... и промахивае[pluralize_ru(owner.gender,"шься","тесь")]! Вот чёрт!"))
				playsound(get_turf(owner), 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
				do_attack_animation(get_step(owner, pick(GLOB.alldirs)), ATTACK_EFFECT_DISARM)
				deflectmode = FALSE
				if(!istype(I, /obj/item/beach_ball))
					lastdeflect = world.time + 600
				return FALSE
			else
				visible_message(span_warning("[owner] замахива[pluralize_ru(owner.gender,"ет","ют")]ся и отбивает [I.declent_ru(ACCUSATIVE)]!"), span_warning("[pluralize_ru(owner.gender,"Ты отбиваешь","Вы отбиваете")] [I.declent_ru(ACCUSATIVE)]!"))
				playsound(get_turf(owner), 'sound/weapons/baseball_hit.ogg', 50, TRUE, -1)
				do_attack_animation(I, ATTACK_EFFECT_DISARM)
				I.throw_at(get_edge_target_turf(owner, pick(GLOB.cardinal)), rand(8,10), 14, owner)
				deflectmode = FALSE
				if(!istype(I, /obj/item/beach_ball))
					lastdeflect = world.time + 600
				return TRUE

/obj/item/melee/baseball_bat/attack_self(mob/user)
	if(!homerun_able && can_deflect)
		if(!deflectmode && world.time >= lastdeflect)
			to_chat(user, span_notice("Вы готовитесь отбивать летящие в вас предметы. Атаковать в этом режиме нельзя."))
			deflectmode = TRUE
		else if(deflectmode && world.time >= lastdeflect)
			to_chat(user, span_notice("Вы больше не отбиваете предметы. Теперь можно атаковать."))
			deflectmode = FALSE
		else
			to_chat(user, span_warning("Нужно подождать, прежде чем отбивать снова. Способность будет готова через [time2text(lastdeflect - world.time, "mm:ss")]."))
		return ..()
	if(homerun_ready)
		to_chat(user, span_notice("Вы готовы к хоум-рану!"))
		return ..()
	to_chat(user, span_warning("Вы начинаете копить силу..."))
	playsound(get_turf(src), 'sound/magic/lightning_chargeup.ogg', 65, TRUE)
	if(do_after(user, 9 SECONDS, user))
		to_chat(user, span_userdanger("Вы накопили мощь! Пора сделать хоум-ран!"))
		homerun_ready = 1
	..()


/obj/item/melee/baseball_bat/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(deflectmode)
		to_chat(user, span_warning("Вы не можете атаковать в режиме отбивания!"))
		return ATTACK_CHAIN_PROCEED
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.))
		return .
	if(homerun_ready)
		user.visible_message(span_userdanger("Это хоум-ран!"))
		var/atom/throw_target = get_edge_target_turf(target, user.dir)
		INVOKE_ASYNC(target, TYPE_PROC_REF(/atom/movable, throw_at), throw_target, rand(8, 10), 14, user)
		target.ex_act(EXPLODE_HEAVY)
		playsound(loc, 'sound/weapons/homerun.ogg', 100, TRUE)
		if(!homerun_always_charged)
			homerun_ready = FALSE
		return .
	if(world.time < next_throw_time)
		// Limit the rate of throwing, so you can't spam it.
		return .
	if(!istype(target))
		// Should already be /mob/living, but check anyway.
		return .
	if(target.anchored)
		// No throwing mobs that are anchored to the floor.
		return .
	if(target.mob_size > MOB_SIZE_HUMAN)
		// No throwing things that are physically bigger than you are.
		// Covers: blobbernaut, alien empress, ai core, juggernaut, ed209, mulebot, alien/queen/large, carp/megacarp, deathsquid, hostile/tree, megafauna, hostile/asteroid, terror_spider/queen/empress
		return .
	if(!(target.status_flags & CANPUSH) || HAS_TRAIT(target, TRAIT_PUSHIMMUNE))
		// No throwing mobs specifically flagged as immune to being pushed.
		// Covers: revenant, hostile/blob/*, most borgs, juggernauts, hivebot/tele, spaceworms, shades, bots, alien queens, hostile/syndicate/melee, hostile/asteroid
		return .
	if(target.move_resist > MOVE_RESIST_DEFAULT)
		// No throwing mobs that have higher than normal move_resist.
		// Covers: revenant, bot/mulebot, hostile/statue, hostile/megafauna, goliath
		return .
	if(!homerun_always_charged)
		target.Knockdown(1 SECONDS)
	next_throw_time = world.time + 10 SECONDS


/obj/item/melee/baseball_bat/ablative
	name = "metal baseball bat"
	desc = "This bat is made of highly reflective, highly armored material."
	icon_state = "baseball_bat_metal"
	item_state = "baseball_bat_metal"
	force = 12
	throwforce = 15

/obj/item/melee/baseball_bat/ablative/IsReflect()//some day this will reflect thrown items instead of lasers
	var/picksound = rand(1,2)
	var/turf = get_turf(src)
	if(picksound == 1)
		playsound(turf, 'sound/weapons/effects/batreflect1.ogg', 50, TRUE)
	if(picksound == 2)
		playsound(turf, 'sound/weapons/effects/batreflect2.ogg', 50, TRUE)
	return 1

/obj/item/melee/baseball_bat/homerun/central_command
	name = "тактическая бита Флота NanoTrasen"
	description_info = "Выдвижная тактическая бита Центрального командования Nanotrasen. \
	В официальных документах эта бита проходит под элегантным названием \"Высокоскоростная система доставки СРП\". \
	Выдаваясь только самым верным и эффективным офицерам NanoTrasen, это оружие является одновременно символом статуса \
	и инструментом высшего правосудия."
	w_class = WEIGHT_CLASS_SMALL

	can_deflect = FALSE
	homerun_always_charged = TRUE
	var/on = FALSE
	/// Force when concealed
	force = 5
	/// Force when extended
	var/force_on = 20
	/// Item state when concealed
	item_state = "centcom_bat_0"
	/// Item state when extended
	var/item_state_on = "centcom_bat_1"
	/// Icon state when concealed
	icon_state = "centcom_bat_0"
	/// Icon state when extended
	var/icon_state_on = "centcom_bat_1"
	/// Sound to play when concealing or extending
	var/extend_sound = 'sound/weapons/batonextend.ogg'
	/// Attack verbs when concealed (created on Initialize)
	attack_verb = list("ударил", "ткнул")
	/// Attack verbs when extended (created on Initialize)
	var/list/attack_verb_on = list("шлёпнул", "ударил", "треснул", "поколотил")


/obj/item/melee/baseball_bat/homerun/central_command/srt
	name = "тактическая бита ГСН"
	desc = "Выдвижная тактическая бита Центрального командования Nanotrasen. Скорее всего, к этому моменту командование станции уже осознало, что их коленные чашечки не переживут эту встречу."
	item_state = "srt_bat_0"
	item_state_on = "srt_bat_1"
	icon_state = "srt_bat_0"
	icon_state_on = "srt_bat_1"


/obj/item/melee/baseball_bat/homerun/central_command/update_icon_state()
	icon_state = on ? icon_state_on : initial(icon_state)
	item_state = on ? item_state_on : initial(item_state)


/obj/item/melee/baseball_bat/homerun/central_command/proc/toggle(mob/living/user)
	on = !on
	slot_flags = on ? NONE : ITEM_SLOT_BELT
	force = on ? force_on : initial(force)
	attack_verb = on ? attack_verb_on : initial(attack_verb)
	w_class = on ? WEIGHT_CLASS_HUGE : WEIGHT_CLASS_SMALL
	homerun_able = on
	homerun_ready = on
	update_icon(UPDATE_ICON_STATE)
	update_equipped_item()
	playsound(loc, extend_sound, 50, TRUE)
	add_fingerprint(user)
	if(on)
		to_chat(user, span_userdanger("Вы активировали [name] - время для правосудия!"))
	else
		to_chat(user, span_notice("Вы деактивировали [name]."))


/obj/item/melee/baseball_bat/homerun/central_command/pickup(mob/living/user)
	if(!(isertmindshielded(user)))
		user.Weaken(10 SECONDS)
		user.drop_item_ground(src, force = TRUE)
		to_chat(user, span_cultlarge("\"Это - оружие истинного правосудия. Тебе не дано обуздать его мощь.\""))
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(rand(force/2, force), BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		else
			user.adjustBruteLoss(rand(force/2, force))
		return FALSE
	return ..()


/obj/item/melee/baseball_bat/homerun/central_command/attack_self(mob/user)
	toggle(user)


/obj/item/melee/claymore/bone
	name = "bone sword"
	desc = "Зубчатые костяные обломки привязаны к тому, что выглядит как бедренная кость голиафа."
	icon_state = "bone_sword"
	item_state = "bone_sword"
	slot_flags = ITEM_SLOT_BELT|ITEM_SLOT_BACK
	force = 18
	throwforce = 10
	armour_penetration = 15
	w_class = WEIGHT_CLASS_BULKY
	block_chance = 30

/obj/item/melee/claymore/bone/get_ru_names()
	return list(
		NOMINATIVE = "костяной меч",
		GENITIVE = "костяного меча",
		DATIVE = "костяному мечу",
		ACCUSATIVE = "костяной меч",
		INSTRUMENTAL = "костяным мечом",
		PREPOSITIONAL = "костяном мече"
	)

/obj/item/melee/claymore/bone/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/cleave_attack, \
		arc_size = 180, \
		swing_speed_mod = 2, \
		afterswing_slowdown = 0.25, \
		slowdown_duration = 0.75 SECONDS, \
		swing_sound = SFX_BLADE_SWING_LIGHT \
	)

/obj/item/melee/nutcracker
	name = "nutcracker"
	desc = "Простейшая дубина из кости. Воплощение силы первобытного разума и природной мощи. Настоящая классика."
	icon_state = "nutcracker"
	item_state = "nutcracker"
	gender = FEMALE
	hitsound = 'sound/weapons/kolotushka_smash.ogg'
	slot_flags = ITEM_SLOT_BELT
	force = 3
	throwforce = 3
	w_class = WEIGHT_CLASS_NORMAL
	var/stamina_damage = 22

/obj/item/melee/nutcracker/get_ru_names()
	return list(
		NOMINATIVE = "колотушка",
		GENITIVE = "колотушки",
		DATIVE = "колотушке",
		ACCUSATIVE = "колотушку",
		INSTRUMENTAL = "колотушкой",
		PREPOSITIONAL = "колотушке"
	)

/obj/item/melee/nutcracker/afterattack(atom/target, mob/user, proximity, params, status)
	if(!isliving(target) || !proximity || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	var/mob/living/victim = target
	if(isrobot(victim))
		if(prob(30))
			victim.flash_eyes(3 SECONDS)
			victim.Stun(3 SECONDS)

	if(ishuman(victim))
		var/mob/living/carbon/human/human_victim = target

		if(human_victim.check_shields(src, 25))
			return

		if(check_martial_counter(human_victim, user))
			return

		human_victim.apply_damage(stamina_damage, STAMINA, blocked = victim.getarmor(user.zone_selected, MELEE))
		if(prob(30))
			human_victim.Knockdown(3 SECONDS)
