/obj/machinery/computer/arcade
	name = "random arcade"
	ru_names = list(
		NOMINATIVE = "игровой автомат",
		GENITIVE = "игрового автомата",
		DATIVE = "игровому автомату",
		ACCUSATIVE = "игровой автомат",
		INSTRUMENTAL = "игровым автоматом",
		PREPOSITIONAL = "игровом автомате"
	)
	desc = "Случайный аркадный автомат."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "arcade"
	icon_keyboard = null
	icon_screen = "invaders"
	light_color = "#00FF00"
	var/prize = /obj/item/stack/tickets

/obj/machinery/computer/arcade/proc/Reset()
	return

/obj/machinery/computer/arcade/Initialize(mapload)
	. = ..()
	if(!circuit)
		var/choice = pick(/obj/machinery/computer/arcade/battle, /obj/machinery/computer/arcade/orion_trail)
		new choice(loc)
		return INITIALIZE_HINT_QDEL

	Reset()

/obj/machinery/computer/arcade/proc/prizevend(var/score)
	if(!contents.len)
		var/prize_amount
		if(score)
			prize_amount = score
		else
			prize_amount = rand(1, 10)
		new prize(get_turf(src), prize_amount)
	else
		var/atom/movable/prize = pick(contents)
		prize.forceMove(get_turf(src))

/obj/machinery/computer/arcade/emp_act(severity)
	..(severity)
	if(stat & (NOPOWER|BROKEN))
		return
	var/num_of_prizes = 0
	switch(severity)
		if(1)
			num_of_prizes = rand(1,4)
		if(2)
			num_of_prizes = rand(0,2)
	for(var/i = num_of_prizes; i > 0; i--)
		prizevend()
	explosion(get_turf(src), -1, 0, 1+num_of_prizes, flame_range = 1+num_of_prizes)


/obj/machinery/computer/arcade/battle
	name = "arcade machine"
	desc = "Не поддерживает пинбол."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "arcade"
	circuit = /obj/item/circuitboard/arcade/battle
	var/enemy_name = "Space Villian"
	var/temp = "Победители не употребляют Космодурь" //Temporary message, for attack messages, etc
	var/player_hp = 30 //Player health/attack points
	var/player_mp = 10
	var/enemy_hp = 45 //Enemy health/attack points
	var/enemy_mp = 20
	var/gameover = 0
	var/blocked = 0 //Player cannot attack/heal while set
	var/turtle = 0

/obj/machinery/computer/arcade/battle/Reset()
	var/name_action
	var/name_part1
	var/name_part2

	name_action = pick("Defeat ", "Annihilate ", "Save ", "Strike ", "Stop ", "Destroy ", "Robust ", "Romance ", "Pwn ", "Own ", "Ban ")

	name_part1 = pick("the Automatic ", "Farmer ", "Lord ", "Professor ", "the Cuban ", "the Evil ", "the Dread King ", "the Space ", "Lord ", "the Great ", "Duke ", "General ")
	name_part2 = pick("Melonoid", "Murdertron", "Sorcerer", "Ruin", "Jeff", "Ectoplasm", "Crushulon", "Uhangoid", "Vhakoid", "Peteoid", "slime", "Griefer", "ERPer", "Lizard Man", "Unicorn", "Bloopers")

	enemy_name = replacetext((name_part1 + name_part2), "the ", "")
	name = (name_action + name_part1 + name_part2)
	ru_names = list(
		NOMINATIVE = "игровой автомат [name]",
		GENITIVE = "игрового автомата [name]",
		DATIVE = "игровому автомату [name]",
		ACCUSATIVE = "игровой автомат [name]",
		INSTRUMENTAL = "игровым автоматом [name]",
		PREPOSITIONAL = "игровом автомате [name]"
	)

/obj/machinery/computer/arcade/battle/attack_hand(mob/user as mob)
	if(..())
		return
	user.set_machine(src)
	var/dat = {"<meta charset="UTF-8"><a href='byond://?src=[UID()];close=1'>Close</a>"}
	dat += "<center><h4>[enemy_name]</h4></center>"

	dat += "<br><center><h3>[temp]</h3></center>"
	dat += "<br><center>Здоровье: [player_hp] | Мана: [player_mp] | Здоровье врага: [enemy_hp]</center>"

	if(gameover)
		dat += "<center><b><a href='byond://?src=[UID()];newgame=1'>Новая игра</a>"
	else
		dat += "<center><b><a href='byond://?src=[UID()];attack=1'>Атака</a> | "
		dat += "<a href='byond://?src=[UID()];heal=1'>Лечение</a> | "
		dat += "<a href='byond://?src=[UID()];charge=1'>Восполнить ману</a>"

	dat += "</b></center>"

	//user << browse(dat, "window=arcade")
	//onclose(user, "arcade")
	var/datum/browser/popup = new(user, "arcade", "Space Villian 2000", 420, 280, src)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/computer/arcade/battle/Topic(href, href_list)
	if(..())
		return

	if(!blocked && !gameover)
		if(href_list["attack"])
			blocked = 1
			var/attackamt = rand(2,6)
			temp = "Ваша атака нанесла [attackamt] единиц[declension_ru(attackamt, "у", "ы", "")] урона!"
			playsound(loc, 'sound/arcade/hit.ogg', 50, TRUE)
			updateUsrDialog()
			if(turtle > 0)
				turtle--

			sleep(10)
			enemy_hp -= attackamt
			arcade_action()

		else if(href_list["heal"])
			blocked = 1
			var/pointamt = rand(1,3)
			var/healamt = rand(6,8)
			temp = "Вы использовали [pointamt] единиц[declension_ru(pointamt, "у", "ы", "")] ману <br>и восстановили [healamt] единиц здоровья!"
			playsound(loc, 'sound/arcade/heal.ogg', 50, TRUE)
			updateUsrDialog()
			turtle++

			sleep(10)
			player_mp -= pointamt
			player_hp += healamt
			blocked = 1
			updateUsrDialog()
			arcade_action()

		else if(href_list["charge"])
			blocked = 1
			var/chargeamt = rand(4,7)
			temp = "Вы восстанавливаете [chargeamt] единиц[declension_ru(chargeamt, "у", "ы", "")] маны"
			playsound(loc, 'sound/arcade/mana.ogg', 50, TRUE)
			player_mp += chargeamt
			if(turtle > 0)
				turtle--

			updateUsrDialog()
			sleep(10)
			arcade_action()

	if(href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=arcade")

	else if(href_list["newgame"]) //Reset everything
		temp = "New Round"
		player_hp = 30
		player_mp = 10
		enemy_hp = 45
		enemy_mp = 20
		gameover = 0
		turtle = 0

		if(emagged)
			Reset()
			emagged = 0

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/arcade/battle/proc/arcade_action()
	if((enemy_mp <= 0) || (enemy_hp <= 0))
		if(!gameover)
			gameover = 1
			temp = "[enemy_name] пал! Возрадуйтесь!"
			playsound(loc, 'sound/arcade/win.ogg', 50, TRUE)

			if(emagged)
				SSblackbox.record_feedback("tally", "arcade_status", 1, "win_emagged")
				new /obj/effect/spawner/newbomb/timer/syndicate(get_turf(src))
				new /obj/item/clothing/head/collectable/petehat(get_turf(src))
				message_admins("[key_name_admin(usr)] has outbombed Cuban Pete and been awarded a bomb.")
				add_game_logs("has outbombed Cuban Pete and been awarded a bomb.", usr)
				Reset()
				emagged = 0
			else
				SSblackbox.record_feedback("tally", "arcade_status", 1, "win_normal")
				var/score = player_hp + player_mp + 5
				prizevend(score)

	else if(emagged && (turtle >= 4))
		var/boomamt = rand(5,10)
		temp = "[enemy_name] бросает бомбу, <br>которая наносит вам [boomamt] единиц[declension_ru(boomamt, "у", "ы", "")] урона взрывом!"
		playsound(loc, 'sound/arcade/boom.ogg', 50, TRUE)
		player_hp -= boomamt

	else if((enemy_mp <= 5) && (prob(70)))
		var/stealamt = rand(2,3)
		temp = "[enemy_name] крадёт [stealamt] единиц[declension_ru(stealamt, "у", "ы", "")] вашей маны!"
		playsound(loc, 'sound/arcade/steal.ogg', 50, TRUE)
		player_mp -= stealamt
		updateUsrDialog()

		if(player_mp <= 0)
			gameover = 1
			sleep(10)
			temp = "Вы были опустошены! ИГРА ОКОНЧЕНА"
			playsound(loc, 'sound/arcade/lose.ogg', 50, TRUE)
			if(emagged)
				SSblackbox.record_feedback("tally", "arcade_status", 1, "loss_mana_emagged")
				usr.gib()
			else
				SSblackbox.record_feedback("tally", "arcade_status", 1, "loss_mana_normal")

	else if((enemy_hp <= 10) && (enemy_mp > 4))
		temp = "[enemy_name] восстанавливает 4 единицы здоровья!"
		playsound(loc, 'sound/arcade/heal.ogg', 50, TRUE)
		enemy_hp += 4
		enemy_mp -= 4

	else
		var/attackamt = rand(3,6)
		temp = "[enemy_name] наносит [attackamt] единиц[declension_ru(attackamt, "у", "ы", "")] урона!"
		playsound(loc, 'sound/arcade/hit.ogg', 50, TRUE)
		player_hp -= attackamt

	if((player_mp <= 0) || (player_hp <= 0))
		gameover = 1
		temp = "Вы были сокрушены! ИГРА ОКОНЧЕНА"
		playsound(loc, 'sound/arcade/lose.ogg', 50, TRUE)
		if(emagged)
			SSblackbox.record_feedback("tally", "arcade_status", 1, "loss_hp_emagged")
			usr.gib()
		else
			SSblackbox.record_feedback("tally", "arcade_status", 1, "loss_hp_normal")

	blocked = 0
	return


/obj/machinery/computer/arcade/battle/emag_act(mob/user)
	if(!emagged)
		add_attack_logs(user, src, "emagged")
		temp = "Если вы умрёте в игре, вы умрёте по-настоящему!"
		player_hp = 30
		player_mp = 10
		enemy_hp = 45
		enemy_mp = 20
		gameover = 0
		blocked = 0

		emagged = 1

		enemy_name = "Cuban Pete"
		name = "Outbomb Cuban Pete"

		updateUsrDialog()

// *** THE ORION TRAIL ** //

#define ORION_TRAIL_WINTURN		9

//Orion Trail Events
#define ORION_TRAIL_RAIDERS		"Рейдеры"
#define ORION_TRAIL_FLUX		"Межзвездный поток"
#define ORION_TRAIL_ILLNESS		"Болезнь"
#define ORION_TRAIL_BREAKDOWN	"Авария"
#define ORION_TRAIL_LING		"Генокрады?"
#define ORION_TRAIL_LING_ATTACK "Засада генокрадов"
#define ORION_TRAIL_MALFUNCTION	"Неисправность"
#define ORION_TRAIL_COLLISION	"Столкновение"
#define ORION_TRAIL_SPACEPORT	"Космопорт"
#define ORION_TRAIL_BLACKHOLE	"Черная Дыра"


/obj/machinery/computer/arcade/orion_trail
	name = "The Orion Trail"
	ru_names = list(
		NOMINATIVE = "игровой автомат The Orion Trail",
		GENITIVE = "игрового автомата The Orion Trail",
		DATIVE = "игровому автомату The Orion Trail",
		ACCUSATIVE = "игровой автомат The Orion Trail",
		INSTRUMENTAL = "игровым автоматом The Orion Trail",
		PREPOSITIONAL = "игровом автомате The Orion Trail"
	)
	desc = "Узнайте, как наши предки добрались до Ориона, и повеселитесь в процессе!"
	icon_state = "arcade"
	circuit = /obj/item/circuitboard/arcade/orion_trail
	var/busy = 0 //prevent clickspam that allowed people to ~speedrun~ the game.
	var/engine = 0
	var/hull = 0
	var/electronics = 0
	var/food = 80
	var/fuel = 60
	var/turns = 4
	var/playing = 0
	var/gameover = 0
	var/alive = 4
	var/eventdat = null
	var/event = null
	var/list/settlers = list("Harry","Larry","Bob")
	var/list/events = list(ORION_TRAIL_RAIDERS		= 3,
						   ORION_TRAIL_FLUX			= 1,
						   ORION_TRAIL_ILLNESS		= 3,
						   ORION_TRAIL_BREAKDOWN	= 2,
						   ORION_TRAIL_LING			= 3,
						   ORION_TRAIL_MALFUNCTION	= 2,
						   ORION_TRAIL_COLLISION	= 1,
						   ORION_TRAIL_SPACEPORT	= 2
						   )
	var/list/stops = list()
	var/list/stopblurbs = list()
	var/lings_aboard = 0
	var/spaceport_raided = 0
	var/spaceport_freebie = 0
	var/last_spaceport_action = ""

/obj/machinery/computer/arcade/orion_trail/Reset()
	// Sets up the main trail
	stops = list("Плутон","Пояс астероидов","Проксима Центавра","Мёртвый Космос","Ригель Прайм","Tau Ceti Beta","Чёрная Дыра","Космический аванпост Бета-9","Орион Прайм")
	stopblurbs = list(
		"Плутон, уже давно оснащенный датчиками и сканерами дальнего действия, готов и даже продолжает исследовать дальние уголки галактики.",
		"На окраине Солнечной системы находится коварный пояс астероидов. Многие были раздавлены случайными астероидами и ошибочными суждениями.",
		"Ближайшая к Солнцу звездная система, в прошлые века она служила напоминанием о границах досветовых путешествий, а теперь стала малонаселенным убежищем для искателей приключений и торговцев.",
		"Эта область космоса особенно лишена материи. Известно, что такие области с низкой плотностью существуют, но их обширность поражает.",
		"Ригель Прайм, центр системы Ригель, пылает, излучая тепло и радиацию на свои планеты",
		"Tau Ceti Beta стала отправной точкой для колонистов, направляющихся к Ориону. Поблизости находится множество кораблей и временных станций.",
		"Датчики показывают, что гравитационное поле черной дыры влияет на область пространства, через которую мы направляемся. Мы могли бы придерживаться курса, но есть риск, что нас одолеет ее гравитация, или же мы могли бы изменить курс и обогнуть ее, что займет больше времени.",
		"Вы оказались в поле зрения первого рукотворного сооружения в этом регионе космоса. Оно было построено не путешественниками с Солнечной Системы, а колонистами с Ориона. Оно стоит как памятник успеху колонистов.",
		"Вы добрались до Ориона! Поздравляю! Ваша команда – одна из немногих, кто создал новую точку опоры для человечества!"
		)

/obj/machinery/computer/arcade/orion_trail/proc/newgame()
	// Set names of settlers in crew
	settlers = list()
	for(var/i = 1; i <= 3; i++)
		add_crewmember()
	add_crewmember("[usr]")
	// Re-set items to defaults
	engine = 1
	hull = 1
	electronics = 1
	food = 80
	fuel = 60
	alive = 4
	turns = 1
	event = null
	playing = 1
	gameover = 0
	lings_aboard = 0

	//spaceport junk
	spaceport_raided = 0
	spaceport_freebie = 0
	last_spaceport_action = ""

/obj/machinery/computer/arcade/orion_trail/attack_hand(mob/user)
	if(..())
		return
	if(fuel <= 0 || food <=0 || settlers.len == 0)
		gameover = 1
		event = null
	user.set_machine(src)
	var/dat = {"<!DOCTYPE html><meta charset="UTF-8">"}
	if(gameover)
		dat = "<center><h1>Игра Окончена</h1></center>"
		dat += "Как и многие до вас, ваша команда так и не добралась до Ориона, затерявшись в космосе... <br><b>Навсегда</b>."
		if(settlers.len == 0)
			dat += "<br>Весь ваш экипаж погиб, и ваш корабль присоединяется к флоту кораблей-призраков, разбросанных по галактике."
		else
			if(food <= 0)
				dat += "<br>У вас закончилась еда, и вы умерли с голоду."
				if(emagged)
					user.set_nutrition(0) //yeah you pretty hongry
					to_chat(user, span_userdanger("<font size=3>Ваше тело мгновенно сжимается, как у человека, который не ел месяцами. Когда вы падаете на пол, вас охватывают мучительные судороги."))
			if(fuel <= 0)
				dat += "<br>У вас закончилось Топливо, и вы медленно приближаетесь к звезде."
				if(emagged)
					var/mob/living/M = user
					M.adjust_fire_stacks(5)
					M.IgniteMob() //flew into a star, so you're on fire
					to_chat(user, span_userdanger("<font size=3>Вы чувствуете, как от игрового автомата исходит огромная волна жара. Ваша кожа загорается."))
		dat += "<br><P ALIGN=Right><a href='byond://?src=[UID()];menu=1'>OK...</a></P>"

		if(emagged)
			to_chat(user, span_userdanger("<font size=3>Ты никогда не доберешься до Ориона...</font>"))
			user.death()
			emagged = 0 //removes the emagged status after you lose
			playing = 0 //also a new game
			name = "The Orion Trail"
			ru_names = list(
				NOMINATIVE = "игровой автомат The Orion Trail",
				GENITIVE = "игрового автомата The Orion Trail",
				DATIVE = "игровому автомату The Orion Trail",
				ACCUSATIVE = "игровой автомат The Orion Trail",
				INSTRUMENTAL = "игровым автоматом The Orion Trail",
				PREPOSITIONAL = "игровом автомате The Orion Trail"
			)
			desc = "Узнайте, как наши предки добрались до Ориона, и повеселитесь в процессе!"

	else if(event)
		dat = eventdat
	else if(playing)
		var/title = stops[turns]
		var/subtext = stopblurbs[turns]
		dat = "<center><h1>[title]</h1></center>"
		dat += "[subtext]"
		dat += "<h3><b>Экипаж:</b></h3>"
		dat += english_list(settlers)
		dat += "<br><b>Пища: </b>[food] | <b>Топливо: </b>[fuel]"
		dat += "<br><b>Детали двигателя: </b>[engine] | <b>Панели корпуса: </b>[hull] | <b>Электроника: </b>[electronics]"
		if(turns == 7)
			dat += "<P ALIGN=Right><a href='byond://?src=[UID()];pastblack=1'>Обогнуть</a> <a href='byond://?src=[UID()];blackhole=1'>Продолжить</a></P>"
		else
			dat += "<P ALIGN=Right><a href='byond://?src=[UID()];continue=1'>Продолжить</a></P>"
		dat += "<P ALIGN=Right><a href='byond://?src=[UID()];killcrew=1'>Убить члена экипажа</a></P>"
		dat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Закрыть</a></P>"
	else
		dat = "<center><h2>The Orion Trail</h2></center>"
		dat += "<br><center><h3>Испытайте себя в роли первопроходца!</h3></center><br><br>"
		dat += "<center><b><a href='byond://?src=[UID()];newgame=1'>Новая Игра</a></b></center>"
		dat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Закрыть</a></P>"
	var/datum/browser/popup = new(user, "arcade", "The Orion Trail", 520, 420, src)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/computer/arcade/orion_trail/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=arcade")
	if(busy)
		return
	busy = 1

	if(href_list["continue"]) //Continue your travels
		if(turns >= ORION_TRAIL_WINTURN)
			win()
		else
			food -= (alive+lings_aboard)*2
			fuel -= 5
			if(turns == 2 && prob(30))
				event = ORION_TRAIL_COLLISION
				event()
			else if(prob(75))
				event = pickweight(events)
				if(lings_aboard)
					if(event == ORION_TRAIL_LING || prob(55))
						event = ORION_TRAIL_LING_ATTACK
				event()
			turns += 1
		if(emagged)
			var/mob/living/carbon/M = usr //for some vars
			switch(event)
				if(ORION_TRAIL_RAIDERS)
					if(prob(50))
						to_chat(usr, span_userdanger("Вы слышите боевые кличи. Грохот шагов по металлическому полу. Крики боли. Свист рассекаемого воздуха. Вы теряете рассудок?"))
						M.AdjustHallucinate(30 SECONDS)
						M.last_hallucinator_log = "Emagged Orion Trail"
					else
						to_chat(usr, span_userdanger("Что-то ударяет вас сзади! Это адски больно и ощущается как удар тупым оружием, но на самом деле там ничего нет..."))
						M.take_organ_damage(30)
						playsound(loc, 'sound/weapons/genhit2.ogg', 100, TRUE)
				if(ORION_TRAIL_ILLNESS)
					var/severity = rand(1,3) //pray to RNGesus. PRAY, PIGS
					if(severity == 1)
						to_chat(M, span_userdanger("Вы внезапно чувствуете легкую тошноту."))//got off lucky

					if(severity == 2)
						to_chat(usr, span_userdanger("Внезапно вы ощущаете приступ тошноты. Вы сгибаетесь, пока не пройдёт это состояние."))
						M.Stun(6 SECONDS)
					if(severity >= 3) //you didn't pray hard enough
						to_chat(M, span_warning("На вас накатывает непреодолимая волна тошноты. Вы сгибаетесь пополам, содержимое вашего желудка готовится к эффектному выходу."))
						M.Stun(10 SECONDS)
						sleep(30)
						atom_say("[M] сильно тошнит!")
						playsound(loc, 'sound/effects/splat.ogg', 50, TRUE)
						M.adjust_nutrition(-50) //lose a lot of food
						var/turf/location = usr.loc
						if(issimulatedturf(location))
							location.add_vomit_floor(TRUE)
				if(ORION_TRAIL_FLUX)
					if(prob(75))
						M.Weaken(6 SECONDS)
						atom_say("Внезапный порыв мощного ветра швыряет [M] на пол!")
						M.take_organ_damage(25)
						playsound(src.loc, 'sound/weapons/genhit.ogg', 100, TRUE)
					else
						to_chat(M, span_userdanger("Сильный порыв ветра проносится мимо вас, и вам едва удается устоять на ногах!"))
				if(ORION_TRAIL_COLLISION) //by far the most damaging event
					if(prob(90))
						playsound(src.loc, 'sound/effects/bang.ogg', 100, TRUE)
						var/turf/simulated/floor/F
						for(F in orange(1, src))
							F.ChangeTurf(F.baseturf)
						atom_say("Что-то врезается в пол возле [declent_ru(GENITIVE)], оставляя дыру в обшивке!")
						if(hull)
							sleep(10)
							atom_say("Возле [declent_ru(GENITIVE)] внезапно появляется новый этаж. Какого чёрта?")
							playsound(loc, 'sound/weapons/genhit.ogg', 100, TRUE)
							var/turf/space/T
							for(T in orange(1, src))
								T.ChangeTurf(/turf/simulated/floor/plating)
					else
						atom_say("Что-то врезается в пол рядом с [declent_ru(INSTRUMENTAL)] – к счастью, оно не пробило его насквозь!")
						playsound(loc, 'sound/effects/bang.ogg', 20, TRUE)
				if(ORION_TRAIL_MALFUNCTION)
					playsound(loc, 'sound/effects/empulse.ogg', 20, TRUE)
					visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] сбоит, из-за чего внутриигровые показатели перемешиваются!"))
					var/oldfood = food
					var/oldfuel = fuel
					food = rand(10,80) / rand(1,2)
					fuel = rand(10,60) / rand(1,2)
					if(electronics)
						sleep(10)
						if(oldfuel > fuel && oldfood > food)
							audible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] издаёт какой-то успокаивающий гул."))
						else if(oldfuel < fuel || oldfood < food)
							audible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] издаёт какой-то зловещий гул."))
						food = oldfood
						fuel = oldfuel
						playsound(loc, 'sound/machines/chime.ogg', 20, TRUE)

	else if(href_list["newgame"]) //Reset everything
		newgame()
	else if(href_list["menu"]) //back to the main menu
		playing = 0
		event = null
		gameover = 0
		food = 80
		fuel = 60
		settlers = list("Harry","Larry","Bob")
	else if(href_list["slow"]) //slow down
		food -= (alive+lings_aboard)*2
		fuel -= 5
		event = null
	else if(href_list["pastblack"]) //slow down
		food -= ((alive+lings_aboard)*2)*3
		fuel -= 15
		turns += 1
		event = null
	else if(href_list["useengine"]) //use parts
		engine = max(0, --engine)
		event = null
	else if(href_list["useelec"]) //use parts
		electronics = max(0, --electronics)
		event = null
	else if(href_list["usehull"]) //use parts
		hull = max(0, --hull)
		event = null
	else if(href_list["wait"]) //wait 3 days
		food -= ((alive+lings_aboard)*2)*3
		event = null
	else if(href_list["keepspeed"]) //keep speed
		if(prob(75))
			event = "Breakdown"
			event()
		else
			event = null
	else if(href_list["blackhole"]) //keep speed past a black hole
		if(prob(75))
			event = ORION_TRAIL_BLACKHOLE
			event()
			if(emagged) //has to be here because otherwise it doesn't work
				playsound(loc, 'sound/effects/supermatter.ogg', 100, TRUE)
				atom_say("Перед [declent_ru(INSTRUMENTAL)] [src] внезапно появляется миниатюрная черная дыра, пожирающая [usr] заживо!")
				if(isliving(usr))
					var/mob/living/L = usr
					L.Stun(20 SECONDS) //you can't run :^)
				var/S = new /obj/singularity/academy(usr.loc)
				emagged = 0 //immediately removes emagged status so people can't kill themselves by sprinting up and interacting
				sleep(50)
				atom_say("Черная дыра исчезает так же внезапно, как и появилась.")
				qdel(S)
		else
			event = null
			turns += 1
	else if(href_list["holedeath"])
		gameover = 1
		event = null
	else if(href_list["eventclose"]) //end an event
		event = null

	else if(href_list["killcrew"]) //shoot a crewmember
		if(length(settlers) <= 0 || alive <= 0)
			return
		var/sheriff = remove_crewmember() //I shot the sheriff
		playsound(loc, 'sound/weapons/gunshots/gunshot.ogg', 100, TRUE)

		if(length(settlers) == 0 || alive == 0)
			atom_say("Последний член команды [sheriff], застрелился, ИГРА ОКОНЧЕНА!")
			if(emagged)
				usr.death(FALSE)
				emagged = FALSE
			gameover = TRUE
			event = null
		else if(emagged)
			if(usr.name == sheriff)
				atom_say("Экипаж корабля решил убить [usr.name]!")
				usr.death(FALSE)

		if(event == ORION_TRAIL_LING) //only ends the ORION_TRAIL_LING event, since you can do this action in multiple places
			event = null

	//Spaceport specific interactions
	//they get a header because most of them don't reset event (because it's a shop, you leave when you want to)
	//they also call event() again, to regen the eventdata, which is kind of odd but necessary
	else if(href_list["buycrew"]) //buy a crewmember
		var/bought = add_crewmember()
		last_spaceport_action = "Вы наняли [bought] в качестве нового члена экипажа."
		fuel -= 10
		food -= 10
		event()

	else if(href_list["sellcrew"]) //sell a crewmember
		var/sold = remove_crewmember()
		last_spaceport_action = "Вы продали своего члена экипажа, [sold]!"
		fuel += 7
		food += 7
		event()

	else if(href_list["leave_spaceport"])
		event = null
		spaceport_raided = 0
		spaceport_freebie = 0
		last_spaceport_action = ""

	else if(href_list["raid_spaceport"])
		var/success = min(15 * alive,100) //default crew (4) have a 60% chance
		spaceport_raided = 1

		var/FU = 0
		var/FO = 0
		if(prob(success))
			FU = rand(5,15)
			FO = rand(5,15)
			last_spaceport_action = "Вы успешно совершили налёт на космопорт! Вы получили [FU] единиц[declension_ru(FU, "у", "ы", "")] Топлива и [FO] единиц[declension_ru(FO, "у", "ы", "")] Пищи! (+[FU]FU,+[FO]FO)"
		else
			FU = rand(-5,-15)
			FO = rand(-5,-15)
			last_spaceport_action = "Вам не удалось совершить налёт на космопорт! Вы потеряли [FU*-1] единиц[declension_ru(FU*-1, "у", "ы", "")] Топлива и [FO*-1] единиц[declension_ru(FO*-1, "у", "ы", "")] Пищи, унося свои ноги оттуда! ([FU]FU,[FO]FO)"

			//your chance of lose a crewmember is 1/2 your chance of success
			//this makes higher % failures hurt more, don't get cocky space cowboy!
			if(prob(success*5))
				var/lost_crew = remove_crewmember()
				last_spaceport_action = "Вам не удалось совершить налёт на космопорт! Вы потеряли [FU*-1] единиц[declension_ru(FU*-1, "у", "ы", "")] Топлива, [FO*-1] единиц[declension_ru(FO*-1, "у", "ы", "")] Пищи, и [lost_crew], унося свои ноги оттуда! ([FU]FI,[FO]FO,-Crew)"
				if(emagged)
					atom_say("ВИИИУ-ВИИИУ, служба безопасности космопорта в пути!")
					for(var/i, i<=3, i++)
						var/mob/living/simple_animal/hostile/syndicate/ranged/orion/O = new/mob/living/simple_animal/hostile/syndicate/ranged/orion(get_turf(src))
						O.GiveTarget(usr)


		fuel += FU
		food += FO
		event()

	else if(href_list["buyparts"])
		switch(text2num(href_list["buyparts"]))
			if(1) //Engine Parts
				engine++
				last_spaceport_action = "Купить Детали для двигателя"
			if(2) //Hull Plates
				hull++
				last_spaceport_action = "Купить Панели корпуса"
			if(3) //Spare Electronics
				electronics++
				last_spaceport_action = "Купить Запасную электронику"
		fuel -= 5 //they all cost 5
		event()

	else if(href_list["trade"])
		switch(text2num(href_list["trade"]))
			if(1) //Fuel
				fuel -= 5
				food += 5
				last_spaceport_action = "Обменять Топливо на Пищу"
			if(2) //Food
				fuel += 5
				food -= 5
				last_spaceport_action = "Обменять Пищу на Топливо"
		event()

	add_fingerprint(usr)
	updateUsrDialog()
	busy = 0
	return


/obj/machinery/computer/arcade/orion_trail/proc/event()
	eventdat = "<center><h1>[event]</h1></center>"

	switch(event)
		if(ORION_TRAIL_RAIDERS)
			eventdat += "Пираты проникли на борт вашего корабля!"
			if(prob(50))
				var/sfood = rand(1,10)
				var/sfuel = rand(1,10)
				food -= sfood
				fuel -= sfuel
				eventdat += "<br>Они украли [sfood] единиц[declension_ru(sfood, "у", "ы", "")] <b>Пищи</b> и [sfuel] единиц[declension_ru(sfuel, "у", "ы", "")] <b>Топлива</b>."
			else if(prob(10))
				var/deadname = remove_crewmember()
				eventdat += "<br>[deadname] пытался сопротивляться, но был убит."
			else
				eventdat += "<br>К счастью, вы отбились от них без каких-либо проблем."
			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];eventclose=1'>Продолжить</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Закрыть</a></P>"

		if(ORION_TRAIL_FLUX)
			eventdat += "Эта область пространства очень турбулентна. <br>Если мы будем двигаться медленно, то, возможно, избежим большего ущерба, но если мы сохраним скорость, то не потратим впустую припасы."
			eventdat += "<br>Что ты будешь делать?"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];slow=1'>Замедлиться</a> <a href='byond://?src=[UID()];keepspeed=1'>Сохранить скорость</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Закрыть</a></P>"

		if(ORION_TRAIL_ILLNESS)
			eventdat += "Кто-то подхватил смертельную болезнь!"
			var/deadname = remove_crewmember()
			eventdat += "<br>[deadname] умер из-за болезни."
			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];eventclose=1'>Продолжить</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Закрыть</a></P>"

		if(ORION_TRAIL_BREAKDOWN)
			eventdat += "О, нет! Двигатель сломался!"
			eventdat += "<br>Вы можете починить его с помощью детали двигателя или произвести ремонт в течение 3 дней."
			if(engine >= 1)
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];useengine=1'>Использовать детали</a><a href='byond://?src=[UID()];wait=1'>Подождать</a></P>"
			else
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];wait=1'>Подождать</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Закрыть</a></P>"

		if(ORION_TRAIL_MALFUNCTION)
			eventdat += "Системы корабля неисправны!"
			eventdat += "<br>Вы можете заменить вышедшую из строя электронику запасными частями или потратить 3 дня на устранение неполадок с ИИ."
			if(electronics >= 1)
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];useelec=1'>Использовать электронику</a><a href='byond://?src=[UID()];wait=1'>Подождать</a></P>"
			else
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];wait=1'>Подождать</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Закрыть</a></P>"

		if(ORION_TRAIL_COLLISION)
			eventdat += "Что-то ударило в нас! Похоже, есть небольшие повреждения корпуса."
			if(prob(25))
				var/sfood = rand(5,15)
				var/sfuel = rand(5,15)
				food -= sfood
				fuel -= sfuel
				eventdat += "<br>[sfood] единиц[declension_ru(sfood, "у", "ы", "")] <b>Пищи</b> и [sfuel] единиц[declension_ru(sfuel, "у", "ы", "")] <b>Топлива</b> выброшены в открытый космос.."
			if(prob(10))
				var/deadname = remove_crewmember()
				eventdat += "<br>[deadname] погиб в результате быстрой разгерметизации."
			eventdat += "<br>Вы можете устранить повреждения с помощью панелей корпуса или потратить следующие 3 дня на сварку металлолома."
			if(hull >= 1)
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];usehull=1'>Использовать панели</a><a href='byond://?src=[UID()];wait=1'>Подождать</a></P>"
			else
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];wait=1'>Подождать</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Закрыть</a></P>"

		if(ORION_TRAIL_BLACKHOLE)
			eventdat += "Тебя унесло в черную дыру."
			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];holedeath=1'>Ох...</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Закрыть</a></P>"
			settlers = list()

		if(ORION_TRAIL_LING)
			eventdat += "Странные сообщения предупреждают о том, что Генокрады проникают в экипаж во время полетов на Орион..."
			if(settlers.len <= 2)
				eventdat += "<br>Шансы вашей команды добраться до Ориона настолько малы, что Генокрады, скорее всего, избегали вашего корабля..."
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];eventclose=1'>Продолжить</a></P>"
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Закрыть</a></P>"
				if(prob(10)) // "likely", I didn't say it was guaranteed!
					lings_aboard = min(++lings_aboard,2)
			else
				if(lings_aboard) //less likely to stack lings
					if(prob(20))
						lings_aboard = min(++lings_aboard,2)
				else if(prob(70))
					lings_aboard = min(++lings_aboard,2)

				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];killcrew=1'>Убить члена экипажа</a></P>"
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];eventclose=1'>Рискнуть</a></P>"
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Закрыть</a></P>"

		if(ORION_TRAIL_LING_ATTACK)
			if(lings_aboard <= 0) //shouldn't trigger, but hey.
				eventdat += "Ха-ха, я одурачил вас, на борту нет Генокрадов!"
				eventdat += "<br>(Вам следует сообщить об этом кодеру :S)"
			else
				var/ling1 = remove_crewmember()
				var/ling2 = ""
				if(lings_aboard >= 2)
					ling2 = remove_crewmember()

				eventdat += "О нет, некоторые из вашей команды – Генокрады!"
				if(ling2)
					eventdat += "<br>Руки [ling1] и [ling2] изгибаются, превращаясь в гротескные клинки!"
				else
					eventdat += "<br>Рука [ling1] изгибается, превращаясь в гротескный клинок!"

				var/chance2attack = alive*20
				if(prob(chance2attack))
					var/chancetokill = 30*lings_aboard-(5*alive) //eg: 30*2-(10) = 50%, 2 lings, 2 crew is 50% chance
					if(prob(chancetokill))
						var/deadguy = remove_crewmember()
						eventdat += "<br>Генокрад[ling2 ? "ы":""] [ling2 ? "подбегают":"подбегает"] к [deadguy] и [ling2 ? "рубят":"рубит"] его на части!"
					else
						eventdat += "<br>Вы доблестно сражаетесь с Генокрад[ling2 ? "ами":"ом"]!"
						eventdat += "<br>Вы порезали Генокрад[ling2 ? "ов":"а"] в мясо... Фуу"
						if(ling2)
							food += 30
							lings_aboard = max(0,lings_aboard-2)
						else
							food += 15
							lings_aboard = max(0,--lings_aboard)
				else
					eventdat += "<br>Генокрад[ling2 ? "ы":""] [ling2 ? "бегут":"бежит"] прочь, какие слабаки!"
					if(ling2)
						lings_aboard = max(0,lings_aboard-2)
					else
						lings_aboard = max(0,--lings_aboard)

			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];eventclose=1'>Продолжить</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Закрыть</a></P>"


		if(ORION_TRAIL_SPACEPORT)
			if(spaceport_raided)
				eventdat += "Космопорт приведён в состояние повышенной готовности! Они не позволят вам причалить, так как вы пытались напасть на них!"
				if(last_spaceport_action)
					eventdat += "<br>Последнее действие в космопорту: [last_spaceport_action]"
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];leave_spaceport=1'>Отчалить из космопорта</a></P>"
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Закрыть</a></P>"
			else
				eventdat += "Вы подводите корабль к причалу в ближайшем космопорту — удача!"
				eventdat += "<br>Этот космопорт является домом для путешественников, которым не удалось достичь Ориона, но удалось найти другой дом..."
				eventdat += "<br>Торговые условия: FU = Топливо, FO = Пища"
				if(last_spaceport_action)
					eventdat += "<br>Последнее действие в космопорту:: [last_spaceport_action]"
				eventdat += "<h3><b>Экипаж:</b></h3>"
				eventdat += english_list(settlers)
				eventdat += "<br><b>Пища: </b>[food] | <b>Топливо: </b>[fuel]"
				eventdat += "<br><b>Детали двигателя: </b>[engine] | <b>Панели корпуса: </b>[hull] | <b>Электроника: </b>[electronics]"


				//If your crew is pathetic you can get freebies (provided you haven't already gotten one from this port)
				if(!spaceport_freebie && (fuel < 20 || food < 20))
					spaceport_freebie++
					var/FU = 10
					var/FO = 10
					var/freecrew = 0
					if(prob(30))
						FU = 25
						FO = 25

					if(prob(10))
						add_crewmember()
						freecrew++

					eventdat += "<br>Торговцы космопорта жалеют вас и дают немного Пищи и Топлива (+[FU]FU,+[FO]FO)"
					if(freecrew)
						eventdat += "<br>Вы также получаете нового члена экипажа!"

					fuel += FU
					food += FO

				//CREW INTERACTIONS
				eventdat += "<P ALIGN=Right>Управление экипажем:</P>"

				//Buy crew
				if(food >= 10 && fuel >= 10)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];buycrew=1'>Нанять нового члена экипажа (-10FU,-10FO)</a></P>"
				else
					eventdat += "<P ALIGN=Right>Вы не можете позволить себе нанять нового члена экипажа</P>"

				//Sell crew
				if(settlers.len > 1)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];sellcrew=1'>Продать члена экипажа за Топливо и Пищу (+7FU,+7FO)</a></P>"
				else
					eventdat += "<P ALIGN=Right>Вы не можете продать члена экипажа</P>"

				//BUY/SELL STUFF
				eventdat += "<P ALIGN=Right>Детали двигателя:</P>"

				//Engine parts
				if(fuel > 5)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];buyparts=1'>Купить Детали для двигателя (-5FU)</a></P>"
				else
					eventdat += "<P ALIGN=Right>Вы не можете позволить себе купить Детали для двигателя</a>"

				//Hull plates
				if(fuel > 5)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];buyparts=2'>Купить Панели корпуса (-5FU)</a></P>"
				else
					eventdat += "<P ALIGN=Right>Вы не можете позволить себе купить Панели корпуса</a>"

				//Electronics
				if(fuel > 5)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];buyparts=3'>Купить Запасную электронику (-5FU)</a></P>"
				else
					eventdat += "<P ALIGN=Right>Вы не можете позволить себе купить Запасную электронику</a>"

				//Trade
				if(fuel > 5)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];trade=1'>Обменять Топливо на Пищу (-5FU,+5FO)</a></P>"
				else
					eventdat += "<P ALIGN=Right>Вы не можете позволить себе обменять Топливо на Пищу</P>"

				if(food > 5)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];trade=2'>Обменять Пищу на Топливо (+5FU,-5FO)</a></P>"
				else
					eventdat += "<P ALIGN=Right>Вы не можете позволить себе обменять Пищу на Топливо</P>"

				//Raid the spaceport
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];raid_spaceport=1'>!! Рейд Космопорта !!</a></P>"

				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];leave_spaceport=1'>Отчалить из космопорта</a></P>"


//Add Random/Specific crewmember
/obj/machinery/computer/arcade/orion_trail/proc/add_crewmember(var/specific = "")
	var/newcrew = ""
	if(specific)
		newcrew = specific
	else
		if(prob(50))
			newcrew = pick(GLOB.first_names_male)
		else
			newcrew = pick(GLOB.first_names_female)
	if(newcrew)
		settlers += newcrew
		alive++
	return newcrew


//Remove Random/Specific crewmember
/obj/machinery/computer/arcade/orion_trail/proc/remove_crewmember(var/specific = "", var/dont_remove = "")
	var/list/safe2remove = settlers
	var/removed = ""
	if(dont_remove)
		safe2remove -= dont_remove
	if(specific && specific != dont_remove)
		safe2remove = list(specific)
	else
		if(safe2remove.len >= 1) //need to make sure we even have anyone to remove
			removed = pick(safe2remove)

	if(removed)
		if(lings_aboard && prob(40*lings_aboard)) //if there are 2 lings you're twice as likely to get one, obviously
			lings_aboard = max(0,--lings_aboard)
		settlers -= removed
		alive--
	return removed


/obj/machinery/computer/arcade/orion_trail/proc/win()
	playing = 0
	turns = 1
	atom_say("Поздравляю, вы добрались до Ориона!")
	if(emagged)
		new /obj/item/orion_ship(get_turf(src))
		message_admins("[key_name_admin(usr)] made it to Orion on an emagged machine and got an explosive toy ship.")
		add_game_logs("made it to Orion on an emagged machine and got an explosive toy ship.", usr)
	else
		var/score = alive + round(food/2) + round(fuel/5) + engine + hull + electronics - lings_aboard
		prizevend(score)
	emagged = 0
	name = "The Orion Trail"
	ru_names = list(
		NOMINATIVE = "игровой автомат The Orion Trail",
		GENITIVE = "игрового автомата The Orion Trail",
		DATIVE = "игровому автомату The Orion Trail",
		ACCUSATIVE = "игровой автомат The Orion Trail",
		INSTRUMENTAL = "игровым автоматом The Orion Trail",
		PREPOSITIONAL = "игровом автомате The Orion Trail"
	)
	desc = "Узнайте, как наши предки добрались до Ориона, и повеселитесь в процессе!"

/obj/machinery/computer/arcade/orion_trail/emag_act(mob/user)
	if(!emagged)
		add_attack_logs(user, src, "emagged")
		if(user)
			to_chat(user, span_notice("Вы переопределяете меню чит-кода и переходите к разделу Чит-код #[rand(1, 50)]: Реализм Мод."))
		name = "The Orion Trail: Realism Edition"
		ru_names = list(
			NOMINATIVE = "игровой автомат The Orion Trail: Realism Edition",
			GENITIVE = "игрового автомата The Orion Trail: Realism Edition",
			DATIVE = "игровому автомату The Orion Trail: Realism Edition",
			ACCUSATIVE = "игровой автомат The Orion Trail: Realism Edition",
			INSTRUMENTAL = "игровым автоматом The Orion Trail: Realism Edition",
			PREPOSITIONAL = "игровом автомате The Orion Trail: Realism Edition"
		)
		desc = "Узнайте, как наши предки добрались до Ориона, и постарайтесь не сдохнуть в процессе!"
		newgame()
		emagged = 1

/mob/living/simple_animal/hostile/syndicate/ranged/orion
	name = "spaceport security"
	ru_names = list(
		NOMINATIVE = "охрана космопорта",
		GENITIVE = "охраны космопорта",
		DATIVE = "охране космопорта",
		ACCUSATIVE = "охрану космопорта",
		INSTRUMENTAL = "охраной космопорта",
		PREPOSITIONAL = "охране космопорта"
	)
	desc = "Лучшие корпоративные силы службы безопасности для всех космопортов, расположенных вдоль пути к Ориону."
	faction = list("orion")
	loot = list()
	del_on_death = TRUE

/obj/item/orion_ship
	name = "model settler ship"
	ru_names = list(
		NOMINATIVE = "модель корабля колонистов",
		GENITIVE = "модели корабля колонистов",
		DATIVE = "модели корабля колонистов",
		ACCUSATIVE = "модель корабля колонистов",
		INSTRUMENTAL = "моделью корабля колонистов",
		PREPOSITIONAL = "модели корабля колонистов"
	)
	desc = "Модель космического корабля, похожая на те, что использовались в прежние времена при полетах на Орион! В ней даже есть миниатюрный реактор FX-293, который славился своей нестабильностью и склонностью к взрывам..."
	icon = 'icons/obj/toy.dmi'
	icon_state = "ship"
	w_class = WEIGHT_CLASS_SMALL
	var/active = 0 //if the ship is on

/obj/item/orion_ship/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		if(!active)
			. += span_notice("Внизу есть маленький переключатель. Он повернут вниз.")
		else
			. += span_notice("Внизу есть маленький переключатель. Он повернут вверх.")

/obj/item/orion_ship/attack_self(mob/user) //Minibomb-level explosion. Should probably be more because of how hard it is to survive the machine! Also, just over a 5-second fuse
	if(active)
		return

	message_admins("[key_name_admin(usr)] primed an explosive Orion ship for detonation.")
	add_game_logs("primed an explosive Orion ship for detonation.", usr)

	to_chat(user, span_warning("Вы щелкаете выключателем на нижней стороне [declent_ru(GENITIVE)]."))
	active = 1
	visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] тихо пищит и жужжит, пробуждаясь к жизни!"))
	playsound(src.loc, 'sound/machines/defib_saftyon.ogg', 25, TRUE)
	atom_say("Это корабль ID #[rand(1,1000)] руководству порта Орион. Мы заходим на посадку, приём.")
	sleep(20)
	visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] начинает вибрировать..."))
	atom_say("Э-э, порт? Возникли некоторые проблемы с нашим реактором, не могли бы вы проверить его? Приём.")
	sleep(30)
	atom_say("О, Боже! Код восемь! КОД ВОСЕМЬ! ЭТО БУД-")
	playsound(loc, 'sound/machines/buzz-sigh.ogg', 25, TRUE)
	sleep(3.6)
	visible_message(span_userdanger("[capitalize(declent_ru(NOMINATIVE))] взрывается!"))
	explosion(src.loc, 1,2,4, flame_range = 3, cause = user)
	qdel(src)

/obj/machinery/computer/arcade/orion_trail/pc_frame
	name = "special purpose computer"
	desc = "Выполнять вычисления на этом компьютере будет сложно..."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "aimainframe"

/obj/machinery/computer/arcade/orion_trail/pc_frame/macintosh
	icon = 'icons/obj/machines/computer3.dmi'
	icon_state = "oldcomp"
	icon_screen = "stock_computer"

/obj/machinery/computer/arcade/battle/pc_frame
	name = "special purpose computer"
	desc = "Выполнять вычисления на этом компьютере будет сложно..."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "aimainframe"

/obj/machinery/computer/arcade/battle/pc_frame/macintosh
	icon = 'icons/obj/machines/computer3.dmi'
	icon_state = "oldcomp"
	icon_screen = "stock_computer"

#undef ORION_TRAIL_WINTURN
#undef ORION_TRAIL_RAIDERS
#undef ORION_TRAIL_FLUX
#undef ORION_TRAIL_ILLNESS
#undef ORION_TRAIL_BREAKDOWN
#undef ORION_TRAIL_LING
#undef ORION_TRAIL_LING_ATTACK
#undef ORION_TRAIL_MALFUNCTION
#undef ORION_TRAIL_COLLISION
#undef ORION_TRAIL_SPACEPORT
#undef ORION_TRAIL_BLACKHOLE
