// Recruiting observers to play as pAIs

GLOBAL_DATUM_INIT(paiController, /datum/paiController, new) // Global handler for pAI candidates

/datum/paiCandidate
	var/name
	var/key
	var/description
	var/role
	var/comments
	var/ready = 0

/datum/paiController
	var/list/pai_candidates = list()
	var/list/asked = list()

	var/askDelay = 10 * 60 * 1	// One minute [ms * sec * min]

/datum/paiController/Topic(href, href_list[])

	var/datum/paiCandidate/candidate = locateUID(href_list["candidate"])

	if(candidate)
		if(!istype(candidate))
			message_admins("Warning: possible href exploit by [key_name_admin(usr)] (paiController/Topic, candidate is not a pAI)")
			log_debug("Warning: possible href exploit by [key_name(usr)] (paiController/Topic, candidate is not a pAI)")
			return

	if(href_list["download"])
		var/obj/item/paicard/card = locate(href_list["device"])
		if(card.pai)
			return
		if(usr.incapacitated() || isobserver(usr) || !card.Adjacent(usr))
			return
		if(istype(card, /obj/item/paicard) && istype(candidate, /datum/paiCandidate))
			var/mob/living/silicon/pai/pai = new(card)
			if(!candidate.name)
				pai.name = pick(GLOB.ninja_names)
			else
				pai.name = candidate.name
			pai.real_name = pai.name
			pai.key = candidate.key

			card.setPersonality(pai)
			card.looking_for_personality = 0

			SSticker.mode.update_cult_icons_removed(card.pai.mind)
			SSticker.mode.update_rev_icons_removed(card.pai.mind)

			pai_candidates -= candidate
			usr << browse(null, "window=findPai")
		return

	if("signup" in href_list)
		var/mob/dead/observer/O = locate(href_list["signup"])
		if(!O)
			return
		if(!(O in GLOB.respawnable_list))
			to_chat(O, "У вас нет возможности вернуться в раунд!")
			return
		if(!check_recruit(O))
			return
		recruitWindow(O)
		return

	if(candidate)
		if(candidate.key && usr.key && candidate.key != usr.key)
			message_admins("Warning: possible href exploit by [key_name_admin(usr)] (paiController/Topic, candidate and usr have different keys)")
			log_debug("Warning: possible href exploit by [key_name(usr)] (paiController/Topic, candidate and usr have different keys)")
			return

	if(href_list["new"])
		var/option = href_list["option"]
		var/t = ""

		switch(option)
			if("name")
				t = input("Введите имя вашего ПИИ", "Имя ПИИ", candidate.name) as text
				if(t)
					candidate.name = sanitize(copytext_char(t,1,MAX_NAME_LEN))
			if("desc")
				t = input("Введите описание вашего ПИИ", "Описание ПИИ", candidate.description) as message
				if(t)
					candidate.description = sanitize(copytext_char(t,1,MAX_MESSAGE_LEN))
			if("role")
				t = input("Введите роль вашего ПИИ", "Роль ПИИ", candidate.role) as text
				if(t)
					candidate.role = sanitize(copytext_char(t,1,MAX_MESSAGE_LEN))
			if("ooc")
				t = input("Введите любые OOC-комментарии", "OOC-комментарии ПИИ", candidate.comments) as message
				if(t)
					candidate.comments = sanitize(copytext_char(t,1,MAX_MESSAGE_LEN))
			if("save")
				candidate.savefile_save(usr)
			if("load")
				candidate.savefile_load(usr)
				//In case people have saved unsanitized stuff.
				if(candidate.name)
					candidate.name = sanitize(copytext_char(candidate.name,1,MAX_NAME_LEN))
				if(candidate.description)
					candidate.description = sanitize(copytext_char(candidate.description,1,MAX_MESSAGE_LEN))
				if(candidate.role)
					candidate.role = sanitize(copytext_char(candidate.role,1,MAX_MESSAGE_LEN))
				if(candidate.comments)
					candidate.comments = sanitize(copytext_char(candidate.comments,1,MAX_MESSAGE_LEN))

			if("submit")
				if(candidate)
					candidate.ready = 1
					for(var/obj/item/paicard/p in world)
						if(p.looking_for_personality == 1)
							p.alertUpdate()
				usr << browse(null, "window=paiRecruit")
				return
		recruitWindow(usr)

/datum/paiController/proc/recruitWindow(var/mob/M as mob)
	var/datum/paiCandidate/candidate
	for(var/datum/paiCandidate/c in pai_candidates)
		if(!istype(c) || !istype(M))
			break
		if(c.key == M.key)
			candidate = c
	if(!candidate)
		candidate = new /datum/paiCandidate()
		candidate.key = M.key
		pai_candidates.Add(candidate)


	var/dat = {"<!DOCTYPE html"><html>
		<meta charset="UTF-8">
		<title>Настройка личности ПИИ</title>
		<head>
			<style type="text/css">
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
					border-collapse:collapse;
					font-size:13px;
				}
				th, td {
					border: 1px solid #333333;
				}
				p.top {
					background-color: none;
					color: white;
				}
				tr.d0 td {
					background-color: #c0c0c0;
					color: black;
					border:0px;
					border: 1px solid #333333;
				}
				tr.d0 th {
					background-color: none;
					color: #4477E0;
					text-align:right;
					vertical-align:top;
					width:180px;
					border:0px;
				}
				tr.d1 td {
					background-color: #555555;
					color: white;
				}
				td.button {
					border: 1px solid #161616;
					background-color: #40628a;
				}
				td.desc {
					font-weight:bold;
				}
				a {
					color:#4477E0;
				}
				a.button {
					color:white;
					text-decoration: none;
					padding: .1em .5em;
				}
			</style>
		</head>
		<body>
			<p class="top">Пожалуйста, укажите параметры своей личности ПИИ.</p>
			<p>Помните: от того, что вы здесь укажете, зависит, выберет ли вас пользователь, запрашивающий личность ПИИ!</p>

			<table>
				<tr class="d0">
					<th rowspan="2"><a href='byond://?src=[UID()];option=name;new=1;candidate=[candidate.UID()]'>Имя</a>:</th>
					<td class="desc">[candidate.name]&nbsp;</td>
				</tr>
				<tr class="d1">
					<td>Как вы хотите себя называть.<br>Предложение: любое имя, которое вы бы выбрали для персонажа экипажа станции или ИИ.</td>
				</tr>
				<tr class="d0">
					<th rowspan="2"><a href='byond://?src=[UID()];option=desc;new=1;candidate=[candidate.UID()]'>Описание</a>:</th>
					<td class="desc">[candidate.description]&nbsp;</td>
				</tr>
				<tr class="d1">
					<td>Каким ПИИ Вы обычно играете?<br>Ваши манеры, особенности и прочее.<br>Можете описать кратко или подробно, как вам нравится.</td>
				</tr>
				<tr class="d0">
					<th rowspan="2"><a href='byond://?src=[UID()];option=role;new=1;candidate=[candidate.UID()]'>Предпочитаемая роль</a>:</th>
					<td class="desc">[candidate.role]&nbsp;</td>
				</tr>
				<tr class="d1">
					<td>Вам нравится сотрудничать с подлыми социальными ниндзя?<br>Нравится помогать службе безопасности выслеживать преступников?<br>Нравится сидеть на плечах инженера, пока он в очередной спасает станцию?<br>Ваша роль не ограничивается только должностями экипажа станции. Сюда уместно написать любое общее описание того, чем вы бы хотели заниматься.</td>
				</tr>
				<tr class="d0">
					<th rowspan="2"><a href='byond://?src=[UID()];option=ooc;new=1;candidate=[candidate.UID()]'>OOC-комментарии</a>:</th>
					<td class="desc">[candidate.comments]&nbsp;</td>
				</tr>
				<tr class="d1">
					<td>Любая неигровая информация которую вы бы хотели адресовать игроку, ищущему себе ПИИ.<br><i>«Я предпочитаю более серьёзное РП»</i>, <i>«Я всё ещё путаюсь в интерфейсе!»</i> и тому подобное.<br>Не стесняйтесь оставлять это поле пустым, если хотите.</td>
				</tr>
			</table>
			<br>
			<table>
				<tr>
					<td class="button">
						<a href='byond://?src=[UID()];option=save;new=1;candidate=[candidate.UID()]' class="button">Сохранить личность</a>
					</td>
				</tr>
				<tr>
					<td class="button">
						<a href='byond://?src=[UID()];option=load;new=1;candidate=[candidate.UID()]' class="button">Загрузить личность</a>
					</td>
				</tr>
			</table><br>
			<table>
				<td class="button"><a href='byond://?src=[UID()];option=submit;new=1;candidate=[candidate.UID()]' class="button"><b><font size="4px">Отправить личность</font></b></a></td>
			</table>
		</body></html>
	"}

	M << browse(dat, "window=paiRecruit;size=800x600")

/datum/paiController/proc/findPAI(var/obj/item/paicard/p, var/mob/user)
	requestRecruits(p, user)
	var/list/available = list()
	for(var/datum/paiCandidate/c in GLOB.paiController.pai_candidates)
		if(c.ready)
			var/found = 0
			for(var/mob/o in GLOB.respawnable_list)
				if(o.key == c.key)
					found = 1
			if(found)
				available.Add(c)
	var/dat = ""

	dat += {"
		<!DOCTYPE HTML>
		<title>Список доступных ПИИ</title>
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
					}
					table.desc {
						border-collapse:collapse;
						font-size:13px;
						border: 1px solid #161616;
						margin-bottom: 1em;
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
						text-align: center;
					}
					td.download {
						border: 1px solid #161616;
						background-color: #40628a;
						text-align: center;
					}
					th {
						text-align:left;
						width:180px;
						vertical-align:top;
					}
					a.button {
						color:white;
						text-decoration: none;
					}
				</style>
			</head>
			<body>
	"}
	dat += "<p>Отображение доступных личностей ПИИ из центральной базы данных…</p><p>Если личности не будут обнаружены, либо если не будет найдена подходящая личность, попробуйте выполнить повторный поиск позже, когда могут быть загружены новые личности ПИИ.</p><p>Поиск личностей начат, вы можете закрыть это окно до получения уведомления о появлении доступных личностей. Обычно это занимает от 15 секунд до нескольких минут.</p>"

	for(var/datum/paiCandidate/c in available)
		dat += {"
			<table class="desc">
				<tr class="d0">
					<th>Имя:</th>
					<td>[c.name]</td>
				</tr>
				<tr class="d1">
					<th>Описание:</th>
					<td>[c.description]</td>
				</tr>
				<tr class="d0">
					<th>Предпочитаемая роль:</th>
					<td>[c.role]</td>
				</tr>
				<tr class="d1">
					<th>OOC-комментарии:</th>
					<td>[c.comments]</td>
				</tr>
			</table>
			<table class="download">
				<td class="download"><a href='byond://?src=[UID()];download=1;candidate=[c.UID()];device=\ref[p]' class="button"><b>Скачать [c.name]</b></a>
				</td>
			</table>
		"}

	dat += {"
			</body>
		</html>
	"}

	user << browse(dat, "window=findPai;size=600x[300 + (length(available) * 140)]")

/datum/paiController/proc/requestRecruits(var/obj/item/paicard/P, mob/user)
	for(var/mob/dead/observer/O in GLOB.player_list)
		if(O.client && (ROLE_PAI in O.client.prefs.be_special))
			if(player_old_enough_antag(O.client,ROLE_PAI))
				if(check_recruit(O))
					to_chat(O, "<span class='boldnotice'>[user.real_name] активировал[genderize_ru(user.gender,"","а","о","и")] поиск личностей ПИИ. (<a href='?src=[O.UID()];jump=\ref[P]'>Телепорт</a> | <a href='?src=[UID()];signup=\ref[O]'>Записаться</a>)</span>")
					//question(O.client)

/datum/paiController/proc/check_recruit(var/mob/dead/observer/O)
	if(jobban_isbanned(O, ROLE_PAI) || jobban_isbanned(O,"nonhumandept"))
		return 0
	if(!player_old_enough_antag(O.client,ROLE_PAI))
		return 0
	if(cannotPossess(O))
		return 0
	if(O.client)
		return 1
	return 0

/datum/paiController/proc/question(var/client/C)
	spawn(0)
		if(!C)	return
		asked.Add(C.key)
		asked[C.key] = world.time
		var/response = alert(C, "Кто-то ищет личность ПИИ. Вы хотите сыграть за персонального ИИ?", "Запрос ПИИ", "Да", "Нет", "Никогда в этом раунде")
		if(!C)	return		//handle logouts that happen whilst the alert is waiting for a response.
		if(response == "Да")
			recruitWindow(C.mob)
		else if(response == "Никогда в этом раунде")
			var/warning = alert(C, "Вы уверены? Это действие будет невозможно отменить, и вам нужно будет ждать следующего раунда.", "Вы уверены?", "Да", "Нет")
			if(warning == "Да")
				asked[C.key] = INFINITY
			else
				question(C)
