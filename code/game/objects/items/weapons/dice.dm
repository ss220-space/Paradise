/obj/item/storage/pill_bottle/dice
	name = "Мешок игральных костей"
	desc = "Содержит всю удачу, которая вам могла бы пригодиться."
	icon = 'icons/obj/dice.dmi'
	icon_state = "dicebag"
	can_hold = list(/obj/item/dice)
	allow_wrap = FALSE

/obj/item/storage/pill_bottle/dice/New()
	..()
	var/special_die = pick("1","2","fudge","00","100")
	if(special_die == "1")
		new /obj/item/dice/d1(src)
	if(special_die == "2")
		new /obj/item/dice/d2(src)
	new /obj/item/dice/d4(src)
	new /obj/item/dice/d6(src)
	if(special_die == "fudge")
		new /obj/item/dice/fudge(src)
	new /obj/item/dice/d8(src)
	new /obj/item/dice/d10(src)
	if(special_die == "00")
		new /obj/item/dice/d00(src)
	new /obj/item/dice/d12(src)
	new /obj/item/dice/d20(src)
	if(special_die == "100")
		new /obj/item/dice/d100(src)

/obj/item/storage/pill_bottle/dice/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] Играет со смертью! Похоже [user.p_theyre()] пытается покончить жизнь самоубийством!</span>")
	return (OXYLOSS)

/obj/item/dice //depreciated d6, use /obj/item/dice/d6 if you actually want a d6
	name = "куб"
	desc = "Кубик с шестью гранями. Непримечательный и лёгкий в обращении"
	icon = 'icons/obj/dice.dmi'
	icon_state = "d6"
	w_class = WEIGHT_CLASS_TINY

	var/sides = 6
	var/result = null
	var/list/special_faces = list() //entries should match up to sides var if used

	var/rigged = DICE_NOT_RIGGED
	var/rigged_value

/obj/item/dice/Initialize(mapload)
	. = ..()
	if(!result)
		result = roll(sides)
	update_icon()

/obj/item/dice/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] играет со смертью! Похоже [user.p_theyre()] пытается покончить жизнь самоубийством!</span>")
	return (OXYLOSS)

/obj/item/dice/d1
	name = "d1"
	desc = "Куб с одной гранью. Детерминированный!"
	icon_state = "d1"
	sides = 1

/obj/item/dice/d2
	name = "d2"
	desc = "Кубик с двумя гранями. Монеты не достойны!"
	icon_state = "d2"
	sides = 2

/obj/item/dice/d4
	name = "d4"
	desc = "Купик с четырьмя гранями. Игрушка зануд."
	icon_state = "d4"
	sides = 4

/obj/item/dice/d4/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, 1, 4) //1d4 damage

/obj/item/dice/d6
	name = "d6"

/obj/item/dice/fudge
	name = "куб обмана"
	desc = "Кубик с шестью гранями, но только с тремя результатами. Это плюс или минус? Твой разум не понимает..."
	sides = 3 //shhh --- Мы никому не скажем
	icon_state = "fudge"
	special_faces = list("minus","blank","plus")

/obj/item/dice/d8
	name = "d8"
	desc = "Куб с восемью гранями. Кажется... удачливым."
	icon_state = "d8"
	sides = 8

/obj/item/dice/d10
	name = "d10"
	desc = "Куб с десятью гранями. Полезно для процентов."
	icon_state = "d10"
	sides = 10

/obj/item/dice/d00
	name = "d00"
	desc = "Куб с десятью гранями. Лучше подходит для рола d100, чем мяч для гольфа."
	icon_state = "d00"
	sides = 10

/obj/item/dice/d12
	name = "d12"
	desc = "Куб с двенадцатью гранями. Ощущается пренебрежение. Похоже им никогда не пользовались..."
	icon_state = "d12"
	sides = 12

/obj/item/dice/d20
	name = "d20"
	desc = "Куб с двадцатью гранями. Настоящий выбор Игрового Мастера."
	icon_state = "d20"
	sides = 20

/obj/item/dice/d100
	name = "d100"
	desc = "Игральная кость с сотней граней! Наверное неправильно взвешана..."
	icon_state = "d100"
	sides = 100

/obj/item/dice/d100/update_icon()
	return

/obj/item/dice/d20/e20
	var/triggered = FALSE

/obj/item/dice/attack_self(mob/user)
	diceroll(user)

/obj/item/dice/throw_impact(atom/target)
	diceroll(thrownby)
	. = ..()

/obj/item/dice/proc/diceroll(mob/user)
	result = roll(sides)
	if(rigged != DICE_NOT_RIGGED && result != rigged_value)
		if(rigged == DICE_BASICALLY_RIGGED && prob(clamp(1 / (sides - 1) * 100, 25, 80)))
			result = rigged_value
		else if(rigged == DICE_TOTALLY_RIGGED)
			result = rigged_value

	. = result

	var/fake_result = roll(sides)//Daredevil isn't as good as he used to be
	var/comment = ""
	if(sides == 20 && result == 20)
		comment = "ДВАДЦАТКА!"
	else if(sides == 20 && result == 1)
		comment = "Ауч, невезуха."
	update_icon()
	if(initial(icon_state) == "d00")
		result = (result - 1) * 10
	if(length(special_faces) == sides)
		result = special_faces[result]
	if(user != null) //Dice was rolled in someone's hand
		user.visible_message("[user] бросил [src.name]. Приземлившись выдав результат [result]. [comment]",
							 "<span class='notice'>Вы бросили [src.name]. Приземлившись выдав результат [result]. [comment]</span>",
							 "<span class='italics'>Вы слышите как катится [src.name], звучит как [fake_result].</span>")
	else if(!throwing) //Dice was thrown and is coming to rest
		visible_message("<span class='notice'>[src.name] прекращает катиться, останавливаясь на [result]. [comment]</span>")

/obj/item/dice/d20/e20/diceroll(mob/user, thrown)
	if(triggered)
		return

	. = ..()

	if(result == 1)
		to_chat(user, "<span class='danger'>Твоя линия судьбы обрывается, и ты умираешь.</span>")
		user.gib()
		add_attack_logs(src, user, "detonated with a roll of [result], gibbing them!", ATKLOG_FEW)
	else
		triggered = TRUE
		visible_message("<span class='notice'>Вы слышите тихий щелчок.</span>")
		addtimer(CALLBACK(src, .proc/boom, user, result), 4 SECONDS)

/obj/item/dice/d20/e20/proc/boom(mob/user, result)
	var/capped = FALSE
	var/actual_result = result
	if(result != 20)
		capped = TRUE
		result = min(result, GLOB.max_ex_light_range) // Apply the bombcap
	else // Rolled a nat 20, screw the bombcap
		result = 24

	var/turf/epicenter = get_turf(src)
	var/area/A = get_area(epicenter)
	explosion(epicenter, round(result * 0.25), round(result * 0.5), round(result), round(result * 1.5), TRUE, capped)
	investigate_log("E20 detonated at [A.name] ([epicenter.x],[epicenter.y],[epicenter.z]) with a roll of [actual_result]. Triggered by: [key_name(user)]", INVESTIGATE_BOMB)
	log_game("E20 detonated at [A.name] ([epicenter.x],[epicenter.y],[epicenter.z]) with a roll of [actual_result]. Triggered by: [key_name(user)]")
	add_attack_logs(user, src, "detonated with a roll of [actual_result]", ATKLOG_FEW)

/obj/item/dice/update_icon()
	overlays.Cut()
	overlays += "[icon_state][result]"

/obj/item/storage/box/dice
	name = "Коробка игральных костей"
	desc = "ЕЩЕ ОДИН!? ДА БЛЯТЬ!"
	icon_state = "box"

/obj/item/storage/box/dice/New()
	..()
	new /obj/item/dice/d2(src)
	new /obj/item/dice/d4(src)
	new /obj/item/dice/d8(src)
	new /obj/item/dice/d10(src)
	new /obj/item/dice/d00(src)
	new /obj/item/dice/d12(src)
	new /obj/item/dice/d20(src)
