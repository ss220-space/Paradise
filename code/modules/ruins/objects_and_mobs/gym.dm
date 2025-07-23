#define EXERCISES_PER_TRY			6
#define PUNCHINGBAG_HITS_PER_TRY	10

/obj/structure/punching_bag
	name = "punching bag"
	ru_names = list(
		NOMINATIVE = "боксёрская груша",
		GENITIVE = "боксёрской груши",
		DATIVE = "боксёрской груше",
		ACCUSATIVE = "боксёрскую грушу",
		INSTRUMENTAL = "боксёрской грушей",
		PREPOSITIONAL = "боксёрской груше",
	)
	desc = "Боксёрская груша. Есть мнение, что её использование становится более эффективным, если представлять на её месте своего начальника."
	gender = FEMALE
	icon = 'icons/goonstation/objects/fitness.dmi'
	icon_state = "punchingbag"
	anchored = TRUE
	layer = WALL_OBJ_LAYER
	var/list/hit_sounds = list('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg',\
	'sound/weapons/punch1.ogg', 'sound/weapons/punch2.ogg', 'sound/weapons/punch3.ogg', 'sound/weapons/punch4.ogg')
	var/material_drop = /obj/item/stack/sheet/cloth
	var/material_drop_amount = 10

/obj/structure/punching_bag/attack_hand(mob/living/user, obj/item/item)
	. = FALSE
	if(.)
		return

	if(iswirecutter(item))
		return

	flick("[icon_state]2", src)
	playsound(loc, pick(hit_sounds), 25, TRUE, -1)
	user.changeNext_move(CLICK_CD_MELEE)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/attacker = user
	if(!SEND_SIGNAL(user, COMSIG_MOB_EXERCISED, 1.0 / PUNCHINGBAG_HITS_PER_TRY))
		return

	attacker.apply_status_effect(STATUS_EFFECT_EXERCISED)

/obj/structure/punching_bag/wirecutter_act(mob/user, obj/item/item)
	. = TRUE

	if(!item.tool_start_check(src, user, 0))
		return

	WIRECUTTER_ATTEMPT_DISMANTLE_MESSAGE
	if(!item.use_tool(src, user, 5 SECONDS, volume = item.tool_volume))
		return

	WIRECUTTER_DISMANTLE_SUCCESS_MESSAGE
	deconstruct(TRUE)

/obj/structure/punching_bag/deconstruct(disassembled = TRUE)
	if(ispath(material_drop) && material_drop_amount && !(obj_flags & NODECONSTRUCT))
		new material_drop(loc, material_drop_amount)
	qdel(src)

/obj/structure/weightmachine
	name = "weight machine"
	ru_names = list(
		NOMINATIVE = "силовой тренажёр",
		GENITIVE = "силового тренажёра",
		DATIVE = "силовому тренажёру",
		ACCUSATIVE = "силовой тренажёр",
		INSTRUMENTAL = "силовым тренажёром",
		PREPOSITIONAL = "силовом тренажёре",
	)
	desc = "Даже при взгляде на этот тренажёр вы ощущаете усталость."
	gender = MALE
	density = TRUE
	anchored = TRUE
	var/icon_state_inuse
	var/material_drop = /obj/item/stack/sheet/metal
	var/material_drop_amount = 5

/obj/structure/weightmachine/proc/AnimateMachine(mob/living/user)
	return

/obj/structure/weightmachine/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if(!ishuman(user))
		balloon_alert(user, "неподходящее телосложение!")
		return

	if(in_use)
		balloon_alert(user, "уже занято!")
		return

	if(IS_HORIZONTAL(user))
		balloon_alert(user, "сначала встаньте!")
		return

	if(get_dist(user, src) > 1 || user.z != src.z)
		return

	in_use = TRUE
	icon_state = icon_state_inuse
	user.setDir(SOUTH)
	user.forceMove(src.loc)
	var/bragmessage = pick(
		"раздвига[pluralize_ru(user.gender, "ет", "ют")] границы своих возможностей",
		"превосход[pluralize_ru(user.gender, "ит", "ят")] самого себя",
		"гор[pluralize_ru(user.gender, "ит", "ят")] решимостью",
		"броса[pluralize_ru(user.gender, "ет", "ют")] вызов своим возможностям",
		"станов[pluralize_ru(user.gender, "ит", "ят")]ся сильнее",
		"облива[pluralize_ru(user.gender, "ет", "ют")]ся потом",
	)
	user.visible_message(span_bold("[user] [bragmessage]!"))
	AnimateMachine(user)

	playsound(user, 'sound/machines/click.ogg', 60, 1)
	in_use = FALSE
	user.pixel_y = 0
	var/finishmessage = pick(
		"Вы чувствуете себя сильнее!",
		"Вы чувствуете, что можете покорить мир!",
		"Вы чувствуете силу!",
		"Вы чувствуете себя непобедимым!",
	)
	icon_state = initial(icon_state)
	to_chat(user, finishmessage)
	user.apply_status_effect(STATUS_EFFECT_EXERCISED)

/obj/structure/weightmachine/welder_act(mob/user, obj/item/item)
	. = TRUE

	if(!item.tool_use_check(user, 0))
		return

	if(in_use)
		user.balloon_alert(user, "занято")
		return

	WELDER_ATTEMPT_SLICING_MESSAGE
	if(!item.use_tool(src, user, 40, volume = item.tool_volume))
		return

	WELDER_SLICING_SUCCESS_MESSAGE
	deconstruct(TRUE)

/obj/structure/weightmachine/deconstruct(disassembled = TRUE)
	if(ispath(material_drop) && material_drop_amount && !(obj_flags & NODECONSTRUCT))
		new material_drop(loc, material_drop_amount)
	qdel(src)

/obj/structure/weightmachine/stacklifter
	name = "chest press"
	ru_names = list(
		NOMINATIVE = "грузоблочный тренажёр",
		GENITIVE = "грузоблочного тренажёра",
		DATIVE = "грузоблочному тренажёру",
		ACCUSATIVE = "грузоблочный тренажёр",
		INSTRUMENTAL = "грузоблочным тренажёром",
		PREPOSITIONAL = "грузоблочном тренажёре"
	)
	icon = 'icons/goonstation/objects/fitness.dmi'
	icon_state = "fitnesslifter"
	icon_state_inuse = "fitnesslifter2"

/obj/structure/weightmachine/stacklifter/AnimateMachine(mob/living/carbon/human/user)
	var/lifts = 0
	while(lifts++ < EXERCISES_PER_TRY)
		if(user.loc != src.loc)
			break

		user.Stun(9)
		sleep(3)
		animate(user, pixel_y = -2, time = 3)
		sleep(3)
		animate(user, pixel_y = -4, time = 3)
		sleep(3)
		playsound(user, 'sound/goonstation/effects/spring.ogg', 60, 1)

		if(!SEND_SIGNAL(user, COMSIG_MOB_EXERCISED, 1.0 / EXERCISES_PER_TRY))
			return

/obj/structure/weightmachine/weightlifter
	name = "bench press"
	ru_names = list(
		NOMINATIVE = "скамья для жима",
		GENITIVE = "скамьи для жима",
		DATIVE = "скамье для жима",
		ACCUSATIVE = "скамью для жима",
		INSTRUMENTAL = "скамьёй для жима",
		PREPOSITIONAL = "скамье для жима"
	)
	icon = 'icons/goonstation/objects/fitness.dmi'
	icon_state = "fitnessweight"
	icon_state_inuse = "fitnessweight-c"

/obj/structure/weightmachine/weightlifter/AnimateMachine(mob/living/carbon/human/user)
	var/mutable_appearance/swole_overlay = mutable_appearance(icon, "fitnessweight-w", WALL_OBJ_LAYER)
	add_overlay(swole_overlay)
	var/reps = 0
	user.pixel_y = 5
	while(reps++ < EXERCISES_PER_TRY)
		if(user.loc != src.loc)
			break

		for(var/innerReps = max(reps, 1), innerReps > 0, innerReps--)
			user.Stun(3)
			sleep(3)
			animate(user, pixel_y = (user.pixel_y == 3) ? 5 : 3, time = 3)

		playsound(user, 'sound/goonstation/effects/spring.ogg', 60, 1)
		if(!SEND_SIGNAL(user, COMSIG_MOB_EXERCISED, 1.0 / EXERCISES_PER_TRY))
			break

	user.Stun(6)
	sleep(3)
	animate(user, pixel_y = 2, time = 3)
	sleep(3)
	cut_overlay(swole_overlay)

/obj/structure/weightmachine/horizontalbar
	name = "турник"
	ru_names = list(
		NOMINATIVE = "турник",
		GENITIVE = "турника",
		DATIVE = "турнику",
		ACCUSATIVE = "турник",
		INSTRUMENTAL = "турником",
		PREPOSITIONAL = "турнике",
	)
	desc = "Простенький турник. На большинстве планет с развитой разумной жизнью его аналоги используются в качестве вешалки."
	icon = 'icons/goonstation/objects/fitness.dmi'
	icon_state = "horizontalbar"
	icon_state_inuse = "horizontalbar"
	var/rod_y = 28

/obj/structure/weightmachine/horizontalbar/AnimateMachine(mob/living/carbon/human/user)
	var/mutable_appearance/swole_overlay = mutable_appearance(icon, "rod", WALL_OBJ_LAYER)
	swole_overlay.pixel_y = rod_y
	add_overlay(swole_overlay)
	var/reps = 0
	user.pixel_y = 10
	while(reps++ < EXERCISES_PER_TRY)
		if(user.loc != src.loc)
			break

		user.Stun(8)
		animate(user, pixel_y = 14, time = 6)
		sleep(6)
		animate(user, pixel_y = 5, time = 2)
		sleep(2)

		playsound(user, 'sound/goonstation/effects/spring.ogg', 60, 1)
		if(!SEND_SIGNAL(user, COMSIG_MOB_EXERCISED, 1.0 / EXERCISES_PER_TRY))
			break

	user.Stun(6)
	sleep(3)
	animate(user, pixel_y = 2, time = 3)
	sleep(3)
	cut_overlay(swole_overlay)
	user.apply_status_effect(STATUS_EFFECT_EXERCISED)

/obj/structure/weightmachine/horizontalbar/high
	icon = 'icons/goonstation/objects/horizontalbar2.dmi'
	rod_y = 32

/datum/crafting_recipe/horizontalbar
	name = "Турник"
	result = /obj/structure/weightmachine/horizontalbar
	tools = list(TOOL_WELDER)
	reqs = list(/obj/item/stack/rods = 5,
				/obj/item/stack/cable_coil = 5)
	time = 6 SECONDS
	category = CAT_MISC

/datum/crafting_recipe/horizontalbar_high
	name = "Турник (Высокий)"
	result = /obj/structure/weightmachine/horizontalbar/high
	tools = list(TOOL_WELDER)
	reqs = list(/obj/item/stack/rods = 7,
				/obj/item/stack/cable_coil = 5)
	time = 6 SECONDS
	category = CAT_MISC

#undef EXERCISES_PER_TRY
#undef PUNCHINGBAG_HITS_PER_TRY
