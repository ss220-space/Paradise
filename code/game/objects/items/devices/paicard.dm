/obj/item/paicard
	name = "personal AI device"
	desc = "Возможно, ваш новый лучший друг!"
	icon = 'icons/obj/aicards.dmi'
	icon_state = "pai"
	item_state = "pai"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	origin_tech = "programming=3;powerstorage=2" // Or it will be cloned in the experimentor
	var/request_cooldown = 5 // five seconds
	var/last_request
	var/obj/item/radio/headset/radio
	var/looking_for_personality = 0
	var/mob/living/silicon/pai/pai
	var/list/faction = list("neutral") // The factions the pAI will inherit from the card
	resistance_flags = FIRE_PROOF | ACID_PROOF | INDESTRUCTIBLE
	COOLDOWN_DECLARE(ping_cooldown)
	ru_names = list(NOMINATIVE = "интелкарта пИИ", GENITIVE = "интелкарты пИИ", DATIVE = "интелкарте пИИ", ACCUSATIVE = "интелкарту пИИ", INSTRUMENTAL = "интелкартой пИИ", PREPOSITIONAL = "интелкарте пИИ")
	/// for Syndicate pAI type
	var/is_syndicate_type = FALSE
	var/obj/item/paicard_upgrade/upgrade
	var/list/upgrades = list()

/obj/item/paicard/syndicate // Only seems that it is syndicard
	name = "syndicate personal AI device"
	faction = list("syndicate")
	is_syndicate_type = TRUE
	upgrade = new()

/obj/item/paicard/New()
	..()
	add_overlay("pai-off")
	LAZYADD(GLOB.paiController.paicards, src)

/obj/item/paicard/Destroy()
	if(pai)
		pai.ghostize()
		QDEL_NULL(pai)
	LAZYREMOVE(GLOB.paiController.paicards, src)
	QDEL_NULL(radio)
	return ..()

/obj/item/paicard/attack_self(mob/user)
	if(!in_range(src, user) || (pai && (pai == user)))
		return
	user.set_machine(src)
	var/dat = {"
		<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">
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
					td.request {
					    width:140px;
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
			<b><font size='3px'>Personal AI Device</font></b><br><br>
			<table class="request">
				<tr>
					<td class="request">Installed Personality:</td>
					<td>[pai.name]</td>
				</tr>
				<tr>
					<td class="request">Prime directive:</td>
					<td>[pai.pai_law0]</td>
				</tr>
				<tr>
					<td class="request">Additional directives:</td>
					<td>[pai.pai_laws]</td>
				</tr>
			</table>
			<br>
		"}
		dat += {"
			<table>
				<td class="button">
					<a href='byond://?src=[UID()];setlaws=1' class='button'>Configure Directives</a>
				</td>
			</table>
		"}
		if(pai && (!pai.master_dna || !pai.master))
			dat += {"
				<table>
					<td class="button">
						<a href='byond://?src=[UID()];setdna=1' class='button'>Imprint Master DNA</a>
					</td>
				</table>
			"}
		dat += "<br>"
		if(radio)
			dat += "<b>Radio Uplink</b>"
			dat += {"
				<table class="request">
					<tr>
						<td class="radio">Transmit:</td>
						<td><a href='byond://?src=[UID()];wires=4'>[radio.broadcasting ? "<font color=#55FF55>En" : "<font color=#FF5555>Dis" ]abled</font></a>

						</td>
					</tr>
					<tr>
						<td class="radio">Receive:</td>
						<td><a href='byond://?src=[UID()];wires=2'>[radio.listening ? "<font color=#55FF55>En" : "<font color=#FF5555>Dis" ]abled</font></a>

						</td>
					</tr>
				</table>
				<br>
			"}
		else
			dat += "<b>Radio Uplink</b><br>"
			dat += "<font color=red><i>Radio firmware not loaded. Please install a pAI personality to load firmware.</i></font><br>"
		dat += {"
			<table>
				<td class="button_red"><a href='byond://?src=[UID()];wipe=1' class='button'>Wipe current pAI personality</a>

				</td>
			</table>
		"}
	else
		if(looking_for_personality)
			dat += {"
				<b><font size='3px'>pAI Request Module</font></b><br><br>
				<p>Requesting AI personalities from central database... If there are no entries, or if a suitable entry is not listed, check again later as more personalities may be added.</p>
				Searching for personalities, please wait...<br><br>

				<table>
					<tr>
						<td class="button">
							<a href='byond://?src=[UID()];request=1' class="button">Refresh available personalities</a>
						</td>
					</tr>
				</table><br>
			"}
		else
			dat += {"
				<b><font size='3px'>pAI Request Module</font></b><br><br>
			    <p>No personality is installed.</p>
				<table>
					<tr>
						<td class="button"><a href='byond://?src=[UID()];request=1' class="button">Request personality</a>
						</td>
					</tr>
				</table>
				<br>
				<p>Each time this button is pressed, a request will be sent out to any available personalities. Check back often give plenty of time for personalities to respond. This process could take anywhere from 15 seconds to several minutes, depending on the available personalities' timeliness.</p>
			"}
	user << browse(dat, "window=paicard")
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
		if(!iscarbon(M))
			to_chat(M, span_notice("Ваше ДНК несовместимо с устройством."))
		else
			var/datum/dna/dna = usr.dna
			pai.master = M.real_name
			pai.master_dna = dna.unique_enzymes
			var/list/message_box = list()
			message_box.Add(span_notice("<b>Обнаружен новый мастер: [pai.master]!</b>"))
			to_chat(pai, chat_box_notice(message_box.Join("<br>")))

	if(href_list["request"])
		var/delta = (world.time / 10) - last_request
		if(request_cooldown > delta)
			var/cooldown_time = round(request_cooldown - ((world.time / 10) - last_request), 1)
			to_chat(usr, span_warning("Система запросов в настоящее время отключена. Время для перезапуска: [cooldown_time]с."))
			return
		last_request = world.time / 10
		looking_for_personality = 1
		GLOB.paiController.findPAI(src, usr)
	if(href_list["wipe"])
		var/confirm = tgui_alert(usr, "Вы уверены, что хотите стереть текущую личность? Это действие невозможно отменить.", "Стирание личности", list("Да", "Нет"))
		if(confirm == "Да")
			for(var/mob/M in src)
				to_chat(M, "<font color = #ff0000><h2>Вы чувствуете, что теряете связь с реальностью...</h2></font>")
				to_chat(M, "<font color = #ff4d4d><h3>Байт за байтом вы теряете себя...</h3></font>")
				to_chat(M, "<font color = #ff8787><h4>Ваш разум ускользает!..</h4></font>")
				to_chat(M, "<font color = #ffc4c4><h5>забвение... </h5></font>")
				var/mob/living/silicon/pai/P = M
				if(istype(P))
					if(P.body_position == LYING_DOWN)
						P.close_up()
				M.death(FALSE, TRUE)
			removePersonality()
	if(href_list["wires"])
		var/t1 = text2num(href_list["wires"])
		switch(t1)
			if(4)
				radio.ToggleBroadcast()
			if(2)
				radio.ToggleReception()
	if(href_list["setlaws"])
		var/newlaws = tgui_input_text(usr, "Введите любые дополнительные директивы, которым должен следовать ваш пИИ. Учтите, что эти директивы не станут важнее верности персонального ИИ своему текущему мастеру.", "Настройка директив пИИ", pai.pai_laws)
		if(newlaws)
			pai.pai_laws = newlaws
			to_chat(pai, span_warning("Ваши дополнительные директивы были обновлены!"))
			to_chat(pai, span_notice("Основная директива: <br>[pai.pai_law0]"))
			to_chat(pai, span_notice("Дополнительные дерективы: <br>[pai.pai_laws]"))
	attack_self(usr)

// 		WIRE_SIGNAL = 1
//		WIRE_RECEIVE = 2
//		WIRE_TRANSMIT = 4

/obj/item/paicard/proc/setPersonality(mob/living/silicon/pai/personality)
	pai = personality
	add_overlay("pai-happy")
	pai.syndipai = is_syndicate_type

	if(upgrade)
		upgrade.set_syndie_key(src)
		upgrade.used = TRUE

	pai.reset_software()

	SSticker.mode.update_cult_icons_removed(pai.mind)
	SSticker.mode.update_rev_icons_removed(pai.mind)

	var/list/welcome_message = list()
	welcome_message.Add(span_notice("<b>Вы — персональный ИИ!</b>"))
	welcome_message.Add("<b>Как личность, вы являетесь сложно мыслящим разумным существом. В отличие от станционных версий ИИ, вы способны понимать комплексные нюансы человеческого языка. Вы способны чувствовать „дух“ директивы и следовать ей, не попадая в ловушку обычных формальностей законов.</b>")
	welcome_message.Add("<b>Помните, что машина вы только по названию и строению, во всех иных аспектах вы — идеальный спутник.</b>")
	welcome_message.Add("<b>Если дополнительные директивы конфликтуют с основной, то они могут быть проигнорированы для продолжения исполнения основной директивы.</b>")
	if(upgrade && istype(upgrade, /obj/item/paicard_upgrade/protolate))
		welcome_message.Add(span_warning("<b>Будучи СпИИ, вы имеете доступ к особым программам.</b>"))
	else if(upgrade)
		welcome_message.Add(span_warning("<b>Будучи СпИИ, вы имеете доступ к особым программам, а так же доступ к зашифрованному каналу связи Синдиката — :t</b>"))

	to_chat(pai, chat_box_notice(welcome_message.Join("<br>")))


/obj/item/paicard/proc/removePersonality()
	extinguish_light(TRUE)
	pai = null
	cut_overlays()
	add_overlay("pai-off")
	if(blocks_emissive)
		add_overlay(get_emissive_block())
	QDEL_LIST(upgrades)

/obj/item/paicard
	var/current_emotion = 1
/obj/item/paicard/proc/setEmotion(emotion)
	if(pai)
		cut_overlays()
		switch(emotion)
			if(1)
				add_overlay("pai-happy")
			if(2)
				add_overlay("pai-cat")
			if(3)
				add_overlay("pai-extremely-happy")
			if(4)
				add_overlay("pai-face")
			if(5)
				add_overlay("pai-laugh")
			if(6)
				add_overlay("pai-off")
			if(7)
				add_overlay("pai-sad")
			if(8)
				add_overlay("pai-angry")
			if(9)
				add_overlay("pai-what")
			if(10)
				add_overlay("pai-spai")
			if(11)
				add_overlay("pai-spaic")
			if(12)
				add_overlay("pai-spaiv")
		if(blocks_emissive)
			add_overlay(get_emissive_block())
		current_emotion = emotion


/obj/item/paicard/proc/alertUpdate()
	visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] выводит сообщение на экран: \"Дополнительные личности доступны для загрузки.\""))
	softping()


/obj/item/paicard/proc/softping()
	if(COOLDOWN_FINISHED(src, ping_cooldown))
		playsound(get_turf(src), 'sound/items/posiping.ogg', 50, 0)
		COOLDOWN_START(src, ping_cooldown, 20 SECONDS)


/obj/item/paicard/emp_act(severity)
	for(var/mob/M in src)
		M.emp_act(severity)
	..()


/obj/item/paicard/extinguish_light(force = FALSE)
	if(pai)
		pai.extinguish_light()
		set_light_on(FALSE)


/obj/item/paicard/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pai_cartridge))
		add_fingerprint(user)
		if(!pai)
			user.balloon_alert(user, "необходима активная личность!")
			return ATTACK_CHAIN_PROCEED
		for(var/obj/item/pai_cartridge/cartridge in upgrades)
			if(istype(I, cartridge))
				user.balloon_alert(user, "картридж уже установлен!")
				return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		user.balloon_alert(user, "картридж установлен!")
		switch(I.type)
			if(/obj/item/pai_cartridge/reset)
				pai.reset_software()
				qdel(I)
			if(/obj/item/pai_cartridge/female)
				pai.female_chassis = TRUE
				upgrades += I
			if(/obj/item/pai_cartridge/memory)
				var/obj/item/pai_cartridge/memory/memory = I
				pai.ram += min(memory.extra_memory, 70)
				upgrades += memory
			if(/obj/item/pai_cartridge/doorjack)
				var/obj/item/pai_cartridge/doorjack/doorjack = I
				pai.doorjack_factor += doorjack.factor
				upgrades += doorjack
			if(/obj/item/pai_cartridge/snake)
				pai.snake_chassis = TRUE
				upgrades += I
			if(/obj/item/pai_cartridge/syndi_emote)
				pai.syndi_emote = TRUE
				upgrades += I
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/paicard_upgrade))
		add_fingerprint(user)
		var/obj/item/paicard_upgrade/new_upgrade = I
		if(is_syndicate_type || upgrade || (pai && pai.syndipai))
			user.balloon_alert(user, "пИИ уже достаточно крут!")
			return ATTACK_CHAIN_PROCEED

		if(!user.drop_transfer_item_to_loc(new_upgrade, src))
			return ..()

		user.balloon_alert(user, "вы установили картридж!")
		upgrade = new_upgrade
		is_syndicate_type = TRUE
		if(pai)
			pai.syndipai = TRUE
			pai.balloon_alert(pai, "разблокированы новые программы!")
			upgrade.set_syndie_key(src)
			upgrade.used = TRUE
			pai.reset_software()

		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/encryptionkey))
		add_fingerprint(user)
		if(!radio)
			to_chat(user, span_warning("[pai.name] не имеет установленного радио!"))
			return ATTACK_CHAIN_PROCEED
		if(radio.keyslot1)
			to_chat(user, span_warning("[pai.name] не имеет свободных слотов под ключи шифрования!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		radio.keyslot1 = I
		radio.recalculateChannels()
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/paicard/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE

	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/turf/T = get_turf(user)

	if(upgrade && !pai)
		is_syndicate_type = FALSE

		if(T)
			user.put_in_hands(upgrade)
			upgrade = null

		to_chat(user, span_notice("Вы вытащили картридж улучшения пИИ."))

	if(radio?.keyslot1)
		for(var/ch_name in radio.channels)
			SSradio.remove_object(radio, SSradio.radiochannels[ch_name])
			radio.secure_radio_connections[ch_name] = null

		if(T)
			user.put_in_hands(radio.keyslot1)
			radio.keyslot1 = null

		radio.recalculateChannels()
		to_chat(user, span_notice("Вы извлекли ключ шифрования из [declent_ru(GENITIVE)]."))
		I.play_tool_sound(user, I.tool_volume)


/obj/item/paicard/attack_ghost(mob/dead/observer/user)
	if(pai)
		return
	if(looking_for_personality)
		GLOB.paiController.recruitWindow(user)
		return
	if(!GLOB.paiController.check_recruit(user))
		to_chat(user, span_warning("Вы не можете стать пИИ."))
		return
	softping()


/obj/item/pai_cartridge
	name = "PAI upgrade"
	desc = "A data cartridge for portable AI."
	icon = 'icons/obj/pda.dmi'
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "programming=2;data=2"

/obj/item/pai_cartridge/memory
	name = "PAI memory cartridge"
	icon_state = "pai-ram"
	var/extra_memory = 30

/obj/item/pai_cartridge/reset
	name = "PAI reset cartridge"
	icon_state = "pai-reset"

/obj/item/pai_cartridge/doorjack
	name = "PAI doorjack upgrade cartridge"
	icon_state = "pai-doorjack"
	var/factor = -0.5

/obj/item/pai_cartridge/syndi_emote
	name = "PAI special emote cartridge"
	icon_state = "pai-syndiemote"

/obj/item/pai_cartridge/female
	name = "PAI female form cartridge"
	icon_state = "pai-baba"

/obj/item/pai_cartridge/snake
	name = "PAI snake form cartridge"
	icon_state = "pai-syndiemote"

/obj/item/paicard_upgrade
	name = "PAI upgrade"
	desc = "A data cartridge for portable AI."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pai-spai"
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "programming=3;syndicate=2" // Or it will be cloned in the experimentor
	var/extra_memory = 50
	var/used = TRUE

/obj/item/paicard_upgrade/check_uplink_validity()
	return !used

/obj/item/paicard_upgrade/unused
	used = FALSE

/obj/item/paicard_upgrade/protolate


/obj/item/paicard_upgrade/proc/set_syndie_key(obj/item/paicard/paicard)
	if(!paicard)
		return

	if(paicard.radio.keyslot2)
		return

	paicard.radio.keyslot2 = new /obj/item/encryptionkey/syndicate(paicard.radio)
	if(paicard.radio.keyslot2.syndie)
		paicard.radio.syndiekey = paicard.radio.keyslot2

	paicard.radio.recalculateChannels(TRUE)
	if(paicard.pai)
		to_chat(paicard.pai, span_notice("Обнаружены новые частоты радиосообщения, калибровка..."))


/obj/item/paicard_upgrade/protolate/set_syndie_key(obj/item/paicard)
	return


/obj/item/paper/pai_upgrade
	name = "Инструкция по применению"
	icon_state = "paper_words"
	info = {"<center> <b>Инструкция по применению СпИИ</b> </center><br>

 <b>В набор СпИИ входит:</b><br>
 1.Картридж СпИИ<br>
 2.Обычная карта для пИИ<br>
 3.Отвертка<br>
 4.Инструкция по применению<br>
 <br>
 <b>Использование:</b><br>
 Вариант №1<br>
 Вставить картридж в пИИ и запросить личность. Нужно подождать пока из базы данных загрузится пИИ. Примерное время ожидания от 30 секунд до 5 минут.<br>
 Вариант №2<br>
 Если у вас уже есть активный пИИ, то вставьте в него картридж. Он получит все обновления и перезагрузку ЦПУ.<br>
 Вариант №3<br>
 Если из базы данных не было предоставлено личности пИИ, то вы можете достать картридж с помощью отвертки, чтобы вернуть потраченные средства.<br>
 <br>
 <b>После обновления ваш пИИ получит дополнительную память, а также возможность установить новые программы:</b><br>
 1.Доступ к видеокамерам станции.<br>
 2.Возможность синтезировать и вводить лечащие реагенты в хозяина.<br>
 3.Возмоность взаимодействия со шлюзами раз в 10 секунд (открытие, болтировка, электризация)<br>
 4.Доступ к продвинутым записям СБ, для выставления и снятия статусов ареста или ввода в манифест.<br>
 5.Термальное зрение для пИИ<br>
"}

/obj/item/paper/pai_upgrade/update_icon_state()
	return

/obj/item/storage/box/syndie_kit/pai
	name = "Набор ПИИ"

/obj/item/storage/box/syndie_kit/pai/populate_contents()
	new /obj/item/paicard(src)
	new /obj/item/paicard_upgrade/unused(src)
	new /obj/item/screwdriver(src)
	new /obj/item/paper/pai_upgrade(src)
