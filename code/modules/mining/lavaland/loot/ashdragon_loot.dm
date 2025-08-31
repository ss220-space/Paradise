/obj/structure/closet/crate/necropolis/dragon
	name = "dragon chest"
	ru_names = list(
		NOMINATIVE = "драконий сундук",
		GENITIVE = "драконьего сундука",
		DATIVE = "драконьему сундуку",
		ACCUSATIVE = "драконий сундук",
		INSTRUMENTAL = "драконьим сундуком",
		PREPOSITIONAL = "драконьем сундуке"
	)

/obj/structure/closet/crate/necropolis/dragon/populate_contents()
	new /obj/item/gem/amber(src)
	var/loot = rand(1,5)
	switch(loot)
		if(1)
			new /obj/item/melee/ghost_sword(src)
		if(2)
			new /obj/item/lava_staff(src)
		if(3)
			new /obj/item/spellbook/oneuse/sacredflame(src)
			new /obj/item/gun/magic/wand/fireball(src)
		if(4)
			new /obj/item/dragons_blood(src)
		if(5)
			new /obj/item/dragons_blood/refined(src) //turning into lizard stuff


/obj/structure/closet/crate/necropolis/dragon/crusher
	name = "firey dragon chest"
	ru_names = list(
		NOMINATIVE = "огненный драконий сундук",
		GENITIVE = "огненного драконьего сундука",
		DATIVE = "огненному драконьему сундуку",
		ACCUSATIVE = "огненный драконий сундук",
		INSTRUMENTAL = "огненным драконьим сундуком",
		PREPOSITIONAL = "огненном драконьем сундуке"
	)

/obj/structure/closet/crate/necropolis/dragon/crusher/populate_contents()
	. = ..()
	new /obj/item/crusher_trophy/tail_spike(src)


// Spectral Blade

/obj/item/melee/ghost_sword
	name = "spectral blade"
	desc = "Ржавый затупленный клинок. Выглядит так, будто не нанесёт много урона. Слабо светится."
	ru_names = list(
		NOMINATIVE = "спектральный клинок",
		GENITIVE = "спектрального клинка",
		DATIVE = "спектральному клинку",
		ACCUSATIVE = "спектральный клинок",
		INSTRUMENTAL = "спектральным клинком",
		PREPOSITIONAL = "спектральном клинке"
	)
	icon_state = "spectral"
	item_state = "spectral"
	flags = CONDUCT
	sharp = 1
	w_class = WEIGHT_CLASS_BULKY
	force = 1
	throwforce = 1
	embed_chance = 25
	embedded_ignore_throwspeed_threshold = TRUE
	hitsound = 'sound/effects/ghost2.ogg'
	attack_verb = list("атаковал", "полоснул", "уколол", "поранил")
	var/summon_cooldown = 0
	var/list/mob/dead/observer/spirits

/obj/item/melee/ghost_sword/New()
	..()
	spirits = list()
	START_PROCESSING(SSobj, src)
	GLOB.poi_list |= src

/obj/item/melee/ghost_sword/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/cleave_attack, \
		swing_sound = SFX_BLADE_SWING_LIGHT \
	)

/obj/item/melee/ghost_sword/Destroy()
	for(var/mob/dead/observer/G in spirits)
		G.invisibility = initial(G.invisibility)
	spirits.Cut()
	STOP_PROCESSING(SSobj, src)
	GLOB.poi_list -= src
	. = ..()

/obj/item/melee/ghost_sword/attack_self(mob/user)
	if(summon_cooldown > world.time)
		to_chat(user, "Вы недавно уже призывали помощь. Не стоит раздражать духов.")
		return
	to_chat(user, "Вы взываете о помощи, пытаясь призвать духов на свою сторону.")

	notify_ghosts("[user] поднима[pluralize_ru(user.gender,"ет","ют")] [declent_ru(ACCUSATIVE)], взывая о вашей помощи!", enter_link="<a href='byond://?src=[UID()];follow=1'>(Нажмите, чтобы помочь)</a>", source = user, action = NOTIFY_FOLLOW)

	summon_cooldown = world.time + 600

/obj/item/melee/ghost_sword/Topic(href, href_list)
	if(href_list["follow"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			ghost.ManualFollow(src)

/obj/item/melee/ghost_sword/process()
	ghost_check()

/obj/item/melee/ghost_sword/proc/ghost_check()
	var/ghost_counter = 0
	var/turf/T = get_turf(src)
	var/list/contents = T.GetAllContents()
	var/mob/dead/observer/current_spirits = list()

	for(var/mob/dead/observer/O in GLOB.player_list)
		if((O.orbiting in contents))
			ghost_counter++
			O.invisibility = 0
			current_spirits |= O

	for(var/mob/dead/observer/G in spirits - current_spirits)
		G.invisibility = initial(G.invisibility)

	spirits = current_spirits

	return ghost_counter


/obj/item/melee/ghost_sword/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	force = 0
	var/ghost_counter = ghost_check()
	force = clamp((ghost_counter * 4), 0, 75)
	user.visible_message(
		span_danger("[user] нанос[pluralize_ru(user.gender,"ит","ят")] удар с силой [ghost_counter] [declension_ru(ghost_counter,"мстительного духа","мстительных духов","мстительных духов")]!"),
		span_notice("Вы бьёте с силой [ghost_counter] [declension_ru(ghost_counter,"мстительного духа","мстительных духов","мстительных духов")]!"),
	)
	return ..()


/obj/item/melee/ghost_sword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	var/ghost_counter = ghost_check()
	final_block_chance += clamp((ghost_counter * 5), 0, 75)
	owner.visible_message(span_danger("[owner] защищён кольцом из [ghost_counter] [declension_ru(ghost_counter,"призрака","призраков","призраков")]!"), projectile_message = (attack_type == PROJECTILE_ATTACK))
	return ..()

// Blood

/obj/item/dragons_blood
	name = "bottle of dragons blood"
	desc = "Вы же не собираетесь это на самом деле пить, да?"
	ru_names = list(
		NOMINATIVE = "бутылка драконьей крови",
		GENITIVE = "бутылки драконьей крови",
		DATIVE = "бутылке драконьей крови",
		ACCUSATIVE = "бутылку драконьей крови",
		INSTRUMENTAL = "бутылкой драконьей крови",
		PREPOSITIONAL = "бутылке драконьей крови"
	)
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/dragons_blood/attack_self(mob/living/carbon/human/user)
	if(!ishuman(user))
		return

	var/random = rand(1,3)

	switch(random)
		if(1)
			to_chat(user, span_danger("Ваша плоть начинает плавиться! Чудесным образом, в остальном вы в порядке."))
			user.set_species(/datum/species/skeleton)
		if(2)
			if(user.mind)
				if(locate(/obj/effect/proc_holder/spell/shapeshift/dragon) in user.mind.spell_list)
					to_chat(user, span_danger("Знакомая сила течёт по вашим жилам! Но вы уже умеете превращаться в дракона..."))
				else
					to_chat(user, span_danger("Сила переполняет вас! Теперь вы можете менять форму по желанию."))
					var/obj/effect/proc_holder/spell/shapeshift/dragon/shapeshift = new
					user.mind.AddSpell(shapeshift)
		if(3)
			to_chat(user, span_danger("Кажется, теперь вы могли бы пройтись прямо сквозь лаву."))
			ADD_TRAIT(user, TRAIT_LAVA_IMMUNE, name)

	playsound(user.loc,'sound/items/drink.ogg', rand(10,50), TRUE)
	qdel(src)

/obj/item/dragons_blood/refined
	name = "bottle of refined dragons blood"
	desc = "Вы ведь точно собираетесь это выпить, не так ли?"
	ru_names = list(
		NOMINATIVE = "бутылка очищенной драконьей крови",
		GENITIVE = "бутылки очищенной драконьей крови",
		DATIVE = "бутылке очищенной драконьей крови",
		ACCUSATIVE = "бутылку очищенной драконьей крови",
		INSTRUMENTAL = "бутылкой очищенной драконьей крови",
		PREPOSITIONAL = "бутылке очищенной драконьей крови"
	)

/obj/item/dragons_blood/refined/attack_self(mob/living/carbon/human/user)
	if(!istype(user))
		return

	var/mob/living/carbon/human/H = user
	to_chat(user, span_danger("Вы чувствуете, как тепло разливается по телу, сопровождаемое странным желанием сжечь деревню. Теперь вы маленький человекоподобный пепельный дрейк!"))
	H.set_species(/datum/species/unathi/draconid, save_appearance = TRUE)

	playsound(user.loc,'sound/items/drink.ogg', rand(10,50), 1)
	qdel(src)

/datum/disease/virus/transformation/dragon
	name = "Драконья трансформация"
	cure_text = "Неизлечимо"
	cures = list("adminordrazine")
	agent = "Кровь дракона"
	desc = "Какое отношение драконы имеют к Космической Станции 13?"
	stage_prob = 20
	severity = BIOHAZARD
	visibility_flags = VISIBLE
	stage1	= list("Ваши кости ноют.")
	stage2	= list("Ваша кожа кажется чешуйчатой.")
	stage3	= list(span_danger("Вы чувствуете непреодолимое желание напугать пару крестьян."), span_danger("Ваши зубы кажутся острее."))
	stage4	= list(span_danger("Ваша кровь кипит!"))
	stage5	= list(span_danger("Вы, блять, дракон! Однако любые прежние обязательства всё ещё действуют. Было бы крайне невежливо съесть своих всё ещё человеческих друзей без причины."))
	new_form = /mob/living/simple_animal/hostile/megafauna/dragon/lesser

//Lava Staff

/obj/item/lava_staff
	name = "staff of lava"
	desc = "Сила огня и камней в ваших руках!"
	ru_names = list(
		NOMINATIVE = "лавовый посох",
		GENITIVE = "лавового посоха",
		DATIVE = "лавовому посоху",
		ACCUSATIVE = "лавовый посох",
		INSTRUMENTAL = "лавовым посохом",
		PREPOSITIONAL = "лавовом посохе"
	)
	icon_state = "lavastaff"
	lefthand_file = 'icons/mob/inhands/staff_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/staff_righthand.dmi'
	item_state = "lavastaff"
	icon = 'icons/obj/weapons/magic.dmi'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	force = 25
	damtype = BURN
	hitsound = 'sound/weapons/sear.ogg'
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	needs_permit = TRUE
	var/turf_type = /turf/simulated/floor/lava
	var/transform_string = "lava"
	var/reset_turf_type = /turf/simulated/floor/plating/asteroid/basalt
	var/reset_string = "basalt"
	var/create_cooldown = 100
	var/create_delay = 30
	var/reset_cooldown = 50
	var/timer = 0
	var/banned_turfs

/obj/item/lava_staff/New()
	. = ..()
	banned_turfs = typecacheof(list(/turf/space/transit, /turf/simulated/wall, /turf/simulated/mineral))

/obj/item/lava_staff/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(timer > world.time)
		return

	if(is_type_in_typecache(target, banned_turfs))
		return

	if(!is_mining_level(user.z)) //Will only spawn a few sparks if not on mining z level
		timer = world.time + create_delay + 1
		user.visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] [user] даёт сбой!"))
		do_sparks(5, FALSE, user)
		return

	if(target in view(user.client.maxview(), get_turf(user)))

		var/turf/simulated/T = get_turf(target)
		if(!istype(T))
			return
		if(!istype(T, turf_type))
			var/obj/effect/temp_visual/lavastaff/L = new /obj/effect/temp_visual/lavastaff(T)
			L.alpha = 0
			animate(L, alpha = 255, time = create_delay)
			user.visible_message(span_danger("[user] направля[pluralize_ru(user.gender,"ет","ют")] [declent_ru(ACCUSATIVE)] на [T.declent_ru(ACCUSATIVE)]!"))
			timer = world.time + create_delay + 1
			if(do_after(user, create_delay, T))
				user.visible_message(span_danger("[user] превраща[pluralize_ru(user.gender,"ет","ют")] [T.declent_ru(ACCUSATIVE)] в лаву!"))
				message_admins("[key_name_admin(user)] fired the lava staff at [ADMIN_COORDJMP(T)]")
				add_attack_logs(user, target, "fired lava staff", ATKLOG_MOST)
				T.ChangeTurf(turf_type, keep_icon = FALSE)
				timer = world.time + create_cooldown
				qdel(L)
			else
				timer = world.time
				qdel(L)
				return
		else
			user.visible_message(span_danger("[user] превраща[pluralize_ru(user.gender,"ет","ют")] [T.declent_ru(ACCUSATIVE)] в базаль!"))
			T.ChangeTurf(reset_turf_type, keep_icon = FALSE)
			timer = world.time + reset_cooldown
		playsound(T,'sound/magic/fireball.ogg', 200, TRUE)

/obj/effect/temp_visual/lavastaff
	icon_state = "lavastaff_warn"
	duration = 50
