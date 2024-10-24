/obj/structure/statue
	name = "statue"
	desc = "Placeholder. Yell at Firecage if you SOMEHOW see this."
	icon = 'icons/obj/statue.dmi'
	icon_state = ""
	density = TRUE
	anchored = FALSE
	max_integrity = 100
	var/oreAmount = 5
	var/material_drop_type = /obj/item/stack/sheet/metal


/obj/structure/statue/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/gun/energy/plasmacutter))
		if(obj_flags & NODECONSTRUCT)
			return ..()
		user.visible_message(
			span_notice("[user] start slicing apart [src] with [I]."),
			span_notice("You start slicing apart [src]..."),
		)
		I.play_tool_sound(src, 100)
		if(!do_after(user, 4 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL))
			add_fingerprint(user)
			return ATTACK_CHAIN_PROCEED
		I.play_tool_sound(src, 100)
		user.visible_message(
			span_notice("[user] slices apart [src] with [I]."),
			span_notice("You have sliced apart [src]."),
		)
		deconstruct(TRUE)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/statue/wrench_act(mob/living/user, obj/item/I)
	if(obj_flags & NODECONSTRUCT)
		return FALSE
	return default_unfasten_wrench(user, I)


/obj/structure/statue/welder_act(mob/user, obj/item/I)
	if(anchored)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(I.use_tool(src, user, 40, volume = I.tool_volume))
		WELDER_SLICING_SUCCESS_MESSAGE
		deconstruct(TRUE)


/obj/structure/statue/attack_hand(mob/living/user)
	. = ..()
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("[user] rubs some dust off from the [name]'s surface.", \
						 "<span class='notice'>You rub some dust off from the [name]'s surface.</span>")

/obj/structure/statue/CanAtmosPass(turf/T, vertical)
	return !density

/obj/structure/statue/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		if(material_drop_type)
			var/drop_amt = oreAmount
			if(!disassembled)
				drop_amt -= 2
			if(drop_amt > 0)
				new material_drop_type(get_turf(src), drop_amt)
	qdel(src)

/obj/structure/statue/uranium
	max_integrity = 300
	light_range = 2
	material_drop_type = /obj/item/stack/sheet/mineral/uranium
	var/last_event = 0
	var/active = null

/obj/structure/statue/uranium/nuke
	name = "statue of a nuclear fission explosive"
	desc = "This is a grand statue of a Nuclear Explosive. It has a sickening green colour."
	icon_state = "nuke"

/obj/structure/statue/uranium/eng
	name = "statue of an engineer"
	desc = "This statue has a sickening green colour."
	icon_state = "eng"

/obj/structure/statue/uranium/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/radioactivity, \
				rad_per_interaction = 12, \
				rad_interaction_radius = 3, \
				rad_interaction_cooldown = 1.5 SECONDS \
	)


/obj/structure/statue/plasma
	max_integrity = 200
	material_drop_type = /obj/item/stack/sheet/mineral/plasma
	desc = "This statue is suitably made from plasma."

/obj/structure/statue/plasma/scientist
	name = "statue of a scientist"
	icon_state = "sci"

/obj/structure/statue/plasma/xeno
	name = "statue of a xenomorph"
	icon_state = "xeno"

/obj/structure/statue/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/structure/statue/plasma/bullet_act(obj/item/projectile/P)
	if(!QDELETED(src)) //wasn't deleted by the projectile's effects.
		if(!P.nodamage && ((P.damage_type == BURN) || (P.damage_type == BRUTE)))
			if(P.firer)
				add_attack_logs(P.firer, src, "Ignited by firing with [P.name]", ATKLOG_FEW)
				investigate_log("was <span class='warning'>ignited</span> by [key_name_log(P.firer)] with [P.name]",INVESTIGATE_ATMOS)
			else
				message_admins("A plasma statue was ignited with [P.name] at [ADMIN_COORDJMP(loc)]. No known firer.")
				add_game_logs("A plasma statue was ignited with [P.name] at [COORD(loc)]. No known firer.")
			PlasmaBurn()
	..()


/obj/structure/statue/plasma/attackby(obj/item/I, mob/user, params)
	var/is_hot = is_hot(I)
	if(is_hot > 300)//If the temperature of the object is over 300, then ignite
		add_attack_logs(user, src, "Ignited using [I]", ATKLOG_FEW)
		investigate_log("was <span class='warning'>ignited</span> by [key_name_log(user)]",INVESTIGATE_ATMOS)
		ignite(is_hot)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/structure/statue/plasma/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return
	user.visible_message("<span class='danger'>[user] sets [src] on fire!</span>",\
						"<span class='danger'>[src] disintegrates into a cloud of plasma!</span>",\
						"<span class='warning'>You hear a 'whoompf' and a roar.</span>")
	add_attack_logs(user, src, "ignited using [I]", ATKLOG_FEW)
	investigate_log("was <span class='warning'>ignited</span> by [key_name_log(user)]",INVESTIGATE_ATMOS)
	ignite(2500)

/obj/structure/statue/plasma/proc/PlasmaBurn()
	atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS, 160)
	deconstruct(FALSE)

/obj/structure/statue/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn()

/obj/structure/statue/gold
	max_integrity = 300
	material_drop_type = /obj/item/stack/sheet/mineral/gold
	desc = "This is a highly valuable statue made from gold."

/obj/structure/statue/gold/hos
	name = "statue of the head of security"
	icon_state = "hos"

/obj/structure/statue/gold/hop
	name = "statue of the head of personnel"
	icon_state = "hop"

/obj/structure/statue/gold/cmo
	name = "statue of the chief medical officer"
	icon_state = "cmo"

/obj/structure/statue/gold/ce
	name = "statue of the chief engineer"
	icon_state = "ce"

/obj/structure/statue/gold/rd
	name = "statue of the research director"
	icon_state = "rd"

/obj/structure/statue/silver
	max_integrity = 300
	material_drop_type = /obj/item/stack/sheet/mineral/silver
	desc = "This is a valuable statue made from silver."

/obj/structure/statue/silver/md
	name = "statue of a medical doctor"
	icon_state = "md"

/obj/structure/statue/silver/janitor
	name = "statue of a janitor"
	icon_state = "jani"

/obj/structure/statue/silver/sec
	name = "statue of a security officer"
	icon_state = "sec"

/obj/structure/statue/silver/secborg
	name = "statue of a security cyborg"
	icon_state = "secborg"

/obj/structure/statue/silver/medborg
	name = "statue of a medical cyborg"
	icon_state = "medborg"

/obj/structure/statue/diamond
	max_integrity = 1000
	material_drop_type = /obj/item/stack/sheet/mineral/diamond
	desc = "This is a very expensive diamond statue."

/obj/structure/statue/diamond/captain
	name = "statue of THE captain"
	icon_state = "cap"

/obj/structure/statue/diamond/ai1
	name = "statue of the AI hologram"
	icon_state = "ai1"

/obj/structure/statue/diamond/ai2
	name = "statue of the AI core"
	icon_state = "ai2"

/obj/structure/statue/bananium
	max_integrity = 300
	material_drop_type = /obj/item/stack/sheet/mineral/bananium
	desc = "A bananium statue with a small engraving:'HOOOOOOONK'."
	var/spam_flag = 0

/obj/structure/statue/bananium/clown
	name = "statue of a clown"
	icon_state = "clown"

/obj/structure/statue/bananium/Bumped(atom/movable/moving_atom)
	honk()
	. = ..()


/obj/structure/statue/bananium/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!ATTACK_CHAIN_CANCEL_CHECK(.))
		honk()


/obj/structure/statue/bananium/attack_hand(mob/user)
	honk()
	..()

/obj/structure/statue/bananium/proc/honk()
	if(!spam_flag)
		spam_flag = 1
		playsound(loc, 'sound/items/bikehorn.ogg', 50, 1)
		spawn(20)
			spam_flag = 0

/obj/structure/statue/bananium/clown/unique
	name = "статуя великого Хонкера"
	desc = "Искусно слепленная статуя из бананиума, бананового сока и непонятного белого материала. Судя по его выдающейся улыбки, двум золотым гудкам в руках и наряду, он был лучшим стендапером и шутником на станции. Полное имя, к сожалению плохо читаемо и затерто, похоже кто-то явно завидовал его таланту."
	icon_state = "clown_unique"

/obj/structure/statue/sandstone
	max_integrity = 50
	material_drop_type = /obj/item/stack/sheet/mineral/sandstone

/obj/structure/statue/sandstone/assistant
	name = "statue of an assistant"
	desc = "A cheap statue of sandstone for a greyshirt."
	icon_state = "assist"

/obj/structure/statue/sandstone/venus //call me when we add marble i guess
	name = "statue of a pure maiden"
	desc = "Похоже, что это древняя мраморная статуя. Девушка имеет длинные косы, которые спускаются по всему телу до пола. В руках она держит ящик инструментов. Пожалуй, это лучшее изображение женщины, которое вы когда-либо видели. Художник должен действительно быть мастером своего дела. Жаль что рука сломана."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "venus"

/obj/structure/statue/tranquillite
	max_integrity = 300
	material_drop_type = /obj/item/stack/sheet/mineral/tranquillite
	desc = "..."

/obj/structure/statue/tranquillite/mime
	name = "statue of a mime"
	icon_state = "mime"

/obj/structure/statue/tranquillite/mime/AltClick(mob/user)//has 4 dirs
	if(!Adjacent(user))
		return

	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return

	if(anchored)
		to_chat(user, "It is fastened to the floor!")
		return

	setDir(turn(dir, 90))

/obj/structure/statue/tranquillite/mime/unique
	name = "статуя гордости пантомимы"
	desc = "Искусно слепленная статуя из транквилиума, если приглядеться, то на статую надета старая униформа мима, перекрашенная под текстуру транквилиума, а рот статуи заклеен скотчем. Похоже кто-то полностью отдавал себя искусству пантомимы. На груди виднеется медаль с еле различимой закрашенной надписью \"За Отвагу\", поверх которой написано \"За Военные Преступления\"."
	icon_state = "mime_unique"

/obj/structure/statue/kidanstatue
	name = "Obsidian Kidan warrior statue"
	desc = "A beautifully carved and menacing statue of a Kidan warrior made out of obsidian. It looks very heavy."
	icon_state = "kidan"
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/chickenstatue
	name = "Bronze Chickenman Statue"
	desc = "An antique and oriental-looking statue of a Chickenman made of bronze."
	icon_state = "chicken"
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/angel
	name = "Stone Angel Statue"
	desc = "An antique statue of a human angel made of stone."
	icon_state = "angel"
	anchored = TRUE
	obj_flags = NODECONSTRUCT

/obj/structure/statue/russian_mulebot
	desc = "Like a MULEbot, but more Russian and less functional.";
	icon = 'icons/obj/aibots.dmi';
	icon_state = "mulebot0";
	name = "OXENbot"
	anchored = TRUE
	oreAmount = 10

/obj/structure/statue/armor
	name = "Knight's armor"
	desc = "Shiny metallic armor."
	icon_state = "posarmor"
	anchored = TRUE
/obj/structure/statue/elwycco
	name = "Unknown Hero"
	desc = "Похоже это какой-то очень важный человек, или очень значимый для многих людей. Вы замечаете огроменный топор в его руках, с выгравированным числом 220. Что это число значит? Каждый понимает по своему, однако по слухам оно означает количество его жертв. \n Надпись на табличке - Мы с тобой, Шустрила! Аве, Легион!"
	icon_state = "elwycco"
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/thaumicnik
	name = "Unknown Hero"
	desc = "Перед собою вы наблюдаете интересного молодого человека, который держит в руках чертежи станции очень похожие на станцию Керберос. Возможно он как то принимал участие в разработке или в конструировании этой станции. В другой же руке вы замечаете планшет с листком, на котором расписаны какие-то даты и заметки к ним. Все что удается вам разглядеть, так это заголовок *event-times* на листочке. \n Надпись на табличке - Один из главных инженеров, принимающих участие в разработке передовой научно-исследовательской станции Kerberos."
	icon_state = "thaumicnik"
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/hooker
	name = "Unknown Hero"
	desc = "Возможно вы и не встречали подобного героя, ведь он всегда ходит в маске, и в белом техническом халате. Скорее всего, он все еще скрывается среди экипажа, но уже другой личностью. \n Надпись на табличке - Герой, который пожертвовав собою, уничтожил угрозу станции. Награжден посмертно."
	icon_state = "hooker"
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/artchair
	name = "Unknown Hero"
	desc = "Еще один герой корп. NanoTrasen. Вы замечаете интересную деталь, что спинка стула похожа на тюремное окошко. Так же на нем почему-то присутствует кровь, которая уже налегает слоями и хранится около года. По всей видимости этот стул символизирует какую то личность, которая внесла большой вклад в развитие и поддержание нашей галактической системы. \n Надпись на табличке - Спасибо тебе за все, мы всегда были и будем рады тебе."
	icon_state = "artchair"
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/furukai
	name = "София Вайт"
	desc = "Загадочная девушка, ныне одна из множества офицеров синдиката. Получившая столь высокую позицию не за связи, а за свои способности. \
			Движимая местью за потерю родной сестры из-за коррупционных верхушек Нанотрейзен, она вступила в Синдикат,  \
			где стала известна и как способный агент и как отличный инженер. Хоть ее позывной и отсылал на пушистых, в душе она их ненавидела..."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "furukai"
	pixel_y = 7
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/ell_good
	name = "Mr.Буум"
	desc = "Загадочный клоун с жёлтым оттенком кожи и выразительными зелёными глазами. Лучший двойной агент синдиката умудрявшийся захватить власть множества объектов. \
			Его имя часто произносят неправильно из-за чего его заслуги по документам принадлежат сразу нескольким Буумам. \
			Так же знаменит тем, что убедил руководство НТ тратить время, силы и средства, на золотой унитаз."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "ell_good"
	pixel_y = 7
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/mooniverse
	name = "Неизвестный агент"
	desc = "Информация на табличке под статуей исцарапана и нечитабельна..."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "mooniverse"
	pixel_y = 7
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/carp_mini
	name = "Carp Statue"
	desc = "A great inhabitant of space.."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "carp_mini"
	max_integrity = 200
	anchored = TRUE

/obj/structure/statue/noble
	name = "Noble person"
	desc = "Giant person, not like us... May be a hero from an ancient fairy tale?"
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "frank"
	max_integrity = 2000
	anchored = TRUE
	layer = EDGED_TURF_LAYER

/obj/structure/statue/dude
	name = "Unknown monk"
	desc = "Seems to be one of thinkers from ancient times."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "dude"
	max_integrity = 2000
	anchored = TRUE
	layer = EDGED_TURF_LAYER

/obj/structure/statue/death
	name = "Death"
	desc = "One day It will come and take you and your dreams."
	icon = 'icons/obj/statuebig.dmi'
	icon_state = "death"
	max_integrity = 2000
	anchored = TRUE
	bound_width = 64
	layer = EDGED_TURF_LAYER

/obj/structure/statue/unknown
	name = "Unknown hero"
	desc = "A pedestal for an unknown soldier, perhaps he was somehow connected with the solar system."
	icon = 'icons/obj/statuebig.dmi'
	icon_state = "unknown"
	max_integrity = 2000
	anchored = TRUE
	bound_width = 64
	var/lit = 0
	layer = EDGED_TURF_LAYER
	anchored = TRUE
	obj_flags = NODECONSTRUCT

/obj/structure/statue/unknown/update_icon_state()
	icon_state = "unknown[lit ? "_lit" : ""]"


/obj/structure/statue/unknown/attackby(obj/item/I, mob/user, params)
	if(is_hot(I) && light(span_notice("[user] lights [src] with [I].")))
		add_fingerprint(user)
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()


/obj/structure/statue/unknown/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(I.tool_use_check(user, 0))
		light(span_notice("[user] casually lights the [name] with [I], what a badass."))


/obj/structure/statue/unknown/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	if(!lit)
		light()
	return ..()


/obj/structure/statue/unknown/proc/light(show_message)
	if(lit)
		return FALSE
	. = TRUE
	lit = TRUE
	if(show_message)
		usr.visible_message(show_message)
	set_light(CANDLE_LUM, l_on = TRUE)
	update_icon(UPDATE_ICON_STATE)


/obj/structure/statue/unknown/attack_hand(mob/user)
	if(lit)
		user.visible_message(span_notice("[user] snuffs out [src]."))
		lit = FALSE
		update_icon(UPDATE_ICON_STATE)
		set_light_on(FALSE)

////////////////////////////////

/obj/structure/snowman
	name = "snowman"
	desc = "Seems someone made a snowman here."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "snowman"
	anchored = TRUE
	density = TRUE
	max_integrity = 50

/obj/structure/snowman/built
	desc = "Just like the ones you remember from childhood!"

/obj/structure/snowman/built/Destroy()
	new /obj/item/reagent_containers/food/snacks/grown/carrot(drop_location())
	new /obj/item/grown/log(drop_location())
	new /obj/item/grown/log(drop_location())
	return ..()

/obj/structure/snowman/built/has_prints()
	return FALSE


/obj/structure/snowman/built/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/snowball))
		if(obj_integrity >= max_integrity)
			to_chat(user, span_warning("The [name] is completely intact."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You patch some of the damage on [src] with [I]."))
		obj_integrity = max_integrity
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/snowman/built/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	qdel(src)

/obj/structure/snowman/high
	icon_state = "snowman_high"

/obj/structure/snowman/medium
	icon_state = "snowman_medium"

/obj/structure/snowman/short
	name = "snowboy"
	icon_state = "snowman_short"

///////// Cheese
/obj/structure/statue/cheese
	max_integrity = 100
	material_drop_type = /obj/item/stack/sheet/cheese


/obj/structure/statue/cheese/cheesus
	name = "statue of cheesus"
	desc = "Cheese expertly crafted into a representation of our mighty lord and saviour."
	icon_state = "cheesus1"


/obj/structure/statue/cheese/cheesus/update_icon_state()
	switch(obj_integrity)
		if(-INFINITY to 20)
			icon_state = "cheesus4"
		if(21 to 40)
			icon_state = "cheesus3"
		if(41 to 60)
			icon_state = "cheesus2"
		else
			icon_state = "cheesus1"


/obj/structure/statue/cheese/cheesus/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	. = ..()
	if(. && !QDELETED(src))
		update_icon(UPDATE_ICON_STATE)


//////BONES
/obj/structure/bones
	name = "large bone"
	desc = "a large bone that belong to the unknown creature"
	icon = 'icons/obj/bones_64x64.dmi'
	icon_state = "l_bone"
	anchored = TRUE
	density = TRUE
	max_integrity = 1000

/obj/structure/bones/right
	icon_state = "r_bone"

/obj/structure/bones/skull
	name = "large skull"
	desc = "a large skull that belong to the unknown creature"
	icon_state = "skull"

/obj/structure/bones/ribs_left
	name = "large ribs"
	desc = "a large ribs that belong to the unknown creature"
	icon_state = "l_ribs"

/obj/structure/bones/ribs_right
	name = "large ribs"
	desc = "a large ribs that belong to the unknown creature"
	icon_state = "r_ribs"

/obj/structure/statue/bone/rib
	name = "colossal rib"
	desc = "It's staggering to think that something this big could have lived, let alone died."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "rib"
	anchored = TRUE
	obj_flags = NODECONSTRUCT

