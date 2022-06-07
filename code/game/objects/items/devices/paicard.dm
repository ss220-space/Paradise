/obj/item/paicard
	name = "personal AI device"
	icon = 'icons/obj/aicards.dmi'
	icon_state = "pai"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_BELT
	origin_tech = "programming=2"
	var/request_cooldown = 5 // five seconds
	var/last_request
	var/obj/item/radio/radio
	var/looking_for_personality = 0
	var/mob/living/silicon/pai/pai
	var/list/faction = list("neutral") // The factions the pAI will inherit from the card
	resistance_flags = FIRE_PROOF | ACID_PROOF | INDESTRUCTIBLE
	gender = MALE
	ru_names = list(NOMINATIVE = "персональный ИИ", GENITIVE = "персонального ИИ", DATIVE = "персональному ИИ", ACCUSATIVE = "персональный ИИ", INSTRUMENTAL = "персональным ИИ", PREPOSITIONAL = "персональном ИИ")

/obj/item/paicard/syndicate
	name = "syndicate personal AI device"
	faction = list("syndicate")
	ru_names = list(NOMINATIVE = "персональный ИИ Синдиката", GENITIVE = "персонального ИИ Синдиката", DATIVE = "персональному ИИ Синдиката", ACCUSATIVE = "персональный ИИ Синдиката", INSTRUMENTAL = "персональным ИИ Синдиката", PREPOSITIONAL = "персональном ИИ Синдиката")

/obj/item/paicard/New()
	..()
	overlays += "pai-off"

/obj/item/paicard/Destroy()
	if(pai)
		pai.ghostize()
		QDEL_NULL(pai)
	QDEL_NULL(radio)
	return ..()

/obj/item/paicard/attack_self(mob/user)
	if(!in_range(src, user))
		return
	user.set_machine(src)
	var/dat = {"
		<!DOCTYPE HTML>
		<title>Персональный ИИ</title>
		<html>
			<meta charset="UTF-8">
			<head>
				<style>
					body {
					    margin-top:5px;
					    font-family:Verdana;
					    color:white;
					    font-size:13px;
					    background-image:url('uiBackground.png');
					    background-repeat:repeat-x;
					    background-color:#272727;
						background-position:center top;
					}
					table {
					    font-size:13px;
					    margin-left:-2px;
					}
					table.request {
					    border-collapse:collapse;
					}
					table.desc {
					    border-collapse:collapse;
					    font-size:13px;
					    border: 1px solid #161616;
					    width:100%;
					}
					table.download {
					    border-collapse:collapse;
					    font-size:13px;
					    border: 1px solid #161616;
					    width:100%;
					}
					tr.d0 td, tr.d0 th {
					    background-color: #506070;
					    color: white;
					}
					tr.d1 td, tr.d1 th {
					    background-color: #708090;
					    color: white;
					}
					tr.d2 td {
					    background-color: #00FF00;
					    color: white;
					    text-align:center;
					}
					td.button {
					    border: 1px solid #161616;
					    background-color: #40628a;
					}
					td.button {
					    border: 1px solid #161616;
					    background-color: #40628a;
					    text-align: center;
					}
					td.button_red {
					    border: 1px solid #161616;
					    background-color: #B04040;
					    text-align: center;
					}
					td.download {
					    border: 1px solid #161616;
					    background-color: #40628a;
					    text-align: center;
					}
					th {
					    text-align:left;
					    width:125px;
					}
					th.request {
					    width:240px;
					}
					th.request,
					td.request {
					    vertical-align:top;
					}
					td.radio {
					    width:90px;
					    vertical-align:top;
					}
					td.request {
					    vertical-align:top;
					}
					a {
					    color:#4477E0;
					}
					a.button {
					    color:white;
					    text-decoration: none;
					    padding: .1em .5em;
					}
					h2 {
					    font-size:15px;
					}
				</style>
			</head>
			<body>
	"}

	if(pai)
		dat += {"
			<table class="request">
				<tr>
					<th class="request">Установленная личность:</th>
					<td>[pai.name]</td>
				</tr>
				<tr>
					<th class="request">Основная директива:</th>
					<td>[pai.pai_law0]</td>
				</tr>
				<tr>
					<th class="request">Дополнительные директивы:</th>
					<td>[pai.pai_laws]</td>
				</tr>
			</table>
			<br>
		"}
		dat += {"
			<table>
				<td class="button">
					<a href='byond://?src=[UID()];setlaws=1' class='button'>Настроить директивы</a>
				</td>
			</table>
		"}
		if(pai && (!pai.master_dna || !pai.master))
			dat += {"
				<table>
					<td class="button">
						<a href='byond://?src=[UID()];setdna=1' class='button'>Установить ДНК хозяина</a>
					</td>
				</table>
			"}
		dat += "<br>"
		if(radio)
			dat += "<b>Радиосвязь</b>"
			dat += {"
				<table class="request">
					<tr>
						<td class="radio">Передача:</td>
						<td><a href='byond://?src=[UID()];wires=4'>[radio.broadcasting ? "<font color=#55FF55>Разрешена" : "<font color=#FF5555>Запрещена"]</font></a>
						</td>
					</tr>
					<tr>
						<td class="radio">Приём:</td>
						<td><a href='byond://?src=[UID()];wires=2'>[radio.listening ? "<font color=#55FF55>Разрешена" : "<font color=#FF5555>Запрещена"]</font></a>
						</td>
					</tr>
				</table>
				<br>
			"}
		else
			dat += "<b>Радиосвязь</b><br>"
			dat += "<font color=red><i>ПО для радиосвязи не установлено. Пожалуйста, установите личность ПИИ для загрузки ПО.</i></font><br>"
		dat += {"
			<table>
				<td class="button_red">
					<a href='byond://?src=[UID()];wipe=1' class='button'>Стереть текущую личность ПИИ: [pai.name]</a>
				</td>
			</table>
		"}
	else
		if(looking_for_personality)
			dat += {"
				<b><font size='3px'>Модуль запроса ПИИ</font></b><br><br>
				<p>Запрос личностей ПИИ из центральной базы данных… Если личности не будут обнаружены, либо если не будет найдена подходящая личность, попробуйте выполнить повторный поиск позже, когда могут быть загружены новые личности ПИИ.</p>
				Поиск личностей… Пожалуйста, ожидайте…<br><br>

				<table>
					<tr>
						<td class="button">
							<a href='byond://?src=[UID()];request=1' class="button">Обновить список доступных личностей</a>
						</td>
					</tr>
				</table><br>
			"}
		else
			dat += {"
				<b><font size='3px'>Модуль запроса ПИИ</font></b><br><br>
			    <p>Личность не установлена.</p>
				<table>
					<tr>
						<td class="button"><a href='byond://?src=[UID()];request=1' class="button">Найти личность ПИИ</a>
						</td>
					</tr>
				</table>
				<br>
				<p>При каждом нажатии этой кнопки всем доступным личностям ПИИ будет послан запрос. Частые проверки устройства увеличивают шансы, что личность ответит на ваш запрос.</p>
                <p>Этот процесс может занять от 15 секунд до нескольких минут, в зависимости от своевременности загрузки доступных личностей.</p>
			"}
	user << browse(dat, "window=paicard;size=500x350")
	onclose(user, "paicard")
	return

/obj/item/paicard/Topic(href, href_list)

	var/mob/U = usr

	if(!usr || usr.stat)
		return

	if(pai)
		if(!in_range(src, U))
			U << browse(null, "window=paicard")
			usr.unset_machine()
			return

	if(href_list["setdna"])
		if(pai.master_dna)
			return
		var/mob/M = usr
		if(!istype(M, /mob/living/carbon))
			to_chat(usr, "<font color=blue>У вас нет ДНК или ваше ДНК несовместимо с этим устройством.</font>")
		else
			var/datum/dna/dna = usr.dna
			pai.master = M.real_name
			pai.master_dna = dna.unique_enzymes
			to_chat(pai, "<font color = red><h3>Вы были привязаны к новому хозяину.</h3></font>")
	if(href_list["request"])
		var/delta = (world.time / 10) - last_request
		if(request_cooldown > delta)
			var/cooldown_time = round(request_cooldown - ((world.time / 10) - last_request), 1)
			var/seconds_text = declension_ru(cooldown_time,"секунду","секунды","секунд")
			to_chat(usr, "<span class='warning'>Запрошенная система сейчас отключена. Пожалуйста, подождите ещё [cooldown_time] [seconds_text].</span>")
			return
		last_request = world.time / 10
		looking_for_personality = 1
		GLOB.paiController.findPAI(src, usr)
	if(href_list["wipe"])
		var/confirm = input("Вы УВЕРЕНЫ что хотите стереть текущую личность ПИИ? Это действие нельзя отменить.", "Стирание личности") in list("Да", "Нет")
		if(confirm == "Да")
			for(var/mob/M in src)
				to_chat(M, "<font color='#ff0000'><h2>Вы чувствуете как разрывается ваша связь с реальностью.</h2></font>")
				to_chat(M, "<font color='#ff4d4d'><h3>Байт за байтом ускользает ваше чувство собственного "я".</h3></font>")
				to_chat(M, "<font color='#ff8787'><h4>Ментальные способности оставляют вас.</h4></font>")
				to_chat(M, "<font color='#ffc4c4'><h5>…забвение…</h5></font>")
				var/mob/living/silicon/pai/P = M
				if(istype(P))
					if(P.resting || P.canmove)
						P.close_up()
				M.death(0, 1)
			removePersonality()
	if(href_list["wires"])
		var/t1 = text2num(href_list["wires"])
		switch(t1)
			if(4)
				radio.ToggleBroadcast()
			if(2)
				radio.ToggleReception()
	if(href_list["setlaws"])
		var/newlaws = sanitize(copytext_char(input("Введите любые дополнительные директивы.\nЛичность вашего ПИИ будет им следовать.\nУчтите что эти директивы не могут отменить верность личности ПИИ её привязанному хозяину.\nКонфликтующие директивы будут игнорироваться.", "Настройка директив ПИИ", pai.pai_laws) as message,1,MAX_MESSAGE_LEN))
		if(newlaws)
			pai.pai_laws = newlaws
			to_chat(pai, "Ваши дополнительные директивы были обновлены. Ваши новые директивы:")
			to_chat(pai, "Основная директива: <br>[pai.pai_law0]")
			to_chat(pai, "Дополнительные директивы: <br>[pai.pai_laws]")
	attack_self(usr)

// 		WIRE_SIGNAL = 1
//		WIRE_RECEIVE = 2
//		WIRE_TRANSMIT = 4

/obj/item/paicard/proc/setPersonality(mob/living/silicon/pai/personality)
	pai = personality
	overlays += "pai-happy"

/obj/item/paicard/proc/removePersonality()
	pai = null
	overlays.Cut()
	overlays += "pai-off"

/obj/item/paicard
	var/current_emotion = 1
/obj/item/paicard/proc/setEmotion(var/emotion)
	if(pai)
		overlays.Cut()
		switch(emotion)
			if(1) overlays += "pai-happy"
			if(2) overlays += "pai-cat"
			if(3) overlays += "pai-extremely-happy"
			if(4) overlays += "pai-face"
			if(5) overlays += "pai-laugh"
			if(6) overlays += "pai-off"
			if(7) overlays += "pai-sad"
			if(8) overlays += "pai-angry"
			if(9) overlays += "pai-what"
		current_emotion = emotion

/obj/item/paicard/proc/alertUpdate()
	var/turf/T = get_turf_or_move(loc)
	for(var/mob/M in viewers(T))
		M.show_message("<span class='notice'>Во весь экран [src.declent_ru(GENITIVE)] вспыхивает надпись: <i>«Новые личности ПИИ доступны для скачивания»</i>.</span>", 3, "<span class='notice'>[src.declent_ru(NOMINATIVE)] электронно бипа[pluralize_ru(src.gender,"ет","ют")].</span>", 2)

/obj/item/paicard/emp_act(severity)
	for(var/mob/M in src)
		M.emp_act(severity)
	..()

/obj/item/paicard/extinguish_light()
	pai.extinguish_light()
	set_light(0)
