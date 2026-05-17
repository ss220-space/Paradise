
/mob/verb/join_vc()
	set name = "Подключится"
	set category = "ProxChat"
	if(!SSvoicechat || !SSvoicechat.actually_initialized)
		to_chat(src, span_ooc("Подсистема SSVoicechat отключена, действие не возможно."))
		return
	SSvoicechat.join_vc(client)

/mob/verb/join_with_url()
	set name = "Подключится вручную"
	set category = "ProxChat"
	if(!SSvoicechat || !SSvoicechat.actually_initialized)
		to_chat(src, span_ooc("Подсистема SSVoicechat отключена, действие не возможно."))
		return

	if(SSvoicechat)
		SSvoicechat.join_vc(client, external=TRUE)

/mob/verb/help_voicechat()
	set name = "Справочник"
	set category = "ProxChat"
	var/dat = {"
	<html>
<html>
		<h2>Экспериментальный Proximity Chat</h2>
		<p>
			Попробуйте нажать на <b>join</b>, чтобы подключиться, используя Ваш основной браузер.
			Если браузер вылетает/не может открыться через эту кнопку, попробуйте <b>"Join with URL"</b>.<br>
			Когда браузер откроется:<br>
				1. Браузер запросит разрешение на использование микрофона, разрешите.<br>
				2. Удостоверьтесь в том, что всё работает, посмотрев на облачко активности голосового чата возле вашего персонажа в игре (как при наборе сообщения в чате).<br>
				3. Перетащите вкладку с голосовым чатом в отдельное окно, чтобы в отдельном окне была только эта активная вкладка.<br>
			Если Вы откроете другую вкладку в этом отдельном окне, то голосовой чат не сможет принимать сигнал с микрофона.
			Так что убедитесь, что вкладка голосового чата находится в отдельном окне браузера.
		</p>
		<h4>Verbs</h4>
		<p>
			Join - открывает вкладку, используя Ваш основной браузер<br>
			Join with URL - генерирует ссылку для подключения, если Join не смог открыть вкладку самостоятельно<br>
			Leave - отключает Вас от голосового чата. Вкладку эта кнопка не закрывает<br>
			Mute - заглушает Ваш микрофон<br>
			Deafen - отключает звук голосового чата в целом<br>
			Примечание: для безопасности, <b>вербы Mute и Deafen работают в одну сторону,</b> то есть чтобы размутиться или включить звук - надо нажать на соответствующую кнопку на вкладке голосового чата.
		</p>
		<h4>Советы по устранению неполадок</h4>
		<p>
			* Убедитесь, что расширения браузера выключены и вкладка/страница не находится в черном списке.<br>
			* VPN и средства обхода блокировок изредка ломают голосовой чат.<br>
			* Для наилучшего качества, проверьте, поддерживает ли Ваш браузер технологию WebRTC.
		</p>
		<h4>Issues</h4>
		<p>
			Примечание: Вы не сможете переподключиться по одной и той же ссылке.<br>
			<b>Каждый раз, когда Вы переподключаетесь, Вам нужно получить новую ссылку, нажав на кнопку Join в вербах.</b>
		</p>
		<p>
			Если у Вас всё равно наблюдаются неполадки, скорее всего они связаны с Вашим микрофоном или RTC подключением.
			Чтобы убедиться, что микрофон подключен к голосовому чату/вкладке, <b>Откройте настройки</b> и нажмите на <b>Проверить микрофон (Эхо)</b>
			Если Вы слышите себя через небольшую задержку, то проблема не в микрофоне.
			Чтобы убедиться, что проблема с RTC, откройте <b>Инструменты разработчика</b> вашего браузера и<br>
			проверьте консоль на наличие большого количества ошибок/текста красного цвета.
			Если можете подтвердить, что они есть и/или их много, то попробуйте настроить брандмауэр, чтобы открыть нужные порты (обычно голосовому чату требуется порт 3000).
		</p>
		<h4>Source</h4>
		<p>
			Этот код портирован, но небольшая демка от автора оригинального ПР находится тут: <a href="https://github.com/forgman6/voice_chat_byond">github.com/forgman6/voice_chat_byond</a><br>
		</p>
	</html>
	"}

	var/datum/browser/popup = new(src, "voicechat_help", "Справочник по ProximityChat", 1000, 500)
	popup.set_content(dat)
	popup.open()

/mob/verb/mute_self()
	set name = "Mute"
	set category = "ProxChat"
	if(!SSvoicechat)
		return
	SSvoicechat.mute_mic(client)


/mob/verb/deafen()
	set name = "Deafen"
	set category = "ProxChat"
	if(!SSvoicechat)
		return
	SSvoicechat.mute_mic(client, deafen=TRUE)

/mob/verb/leave()
	set name = "Leave"
	set category = "ProxChat"
	if(!SSvoicechat)
		return
	var/userCode = SSvoicechat.client_userCode_map[client]
	if(!userCode)
		to_chat(src, span_ooc("Не найдено действующего подключения, убедитесь, что вы закрыли вкладку голосового чата"))
		return
	SSvoicechat.disconnect(userCode, from_byond=TRUE)
	to_chat(src, span_ooc("Голосовой чат: Вы отключились"))

ADMIN_VERB(restart_voicechat, R_ADMIN, "Restart Voicechat", "Disconnects voicechat clients and restarts voicechat", "ProxChat.Admin")
	if(!SSvoicechat)
		return

	var/confirm = tgui_alert(usr, "Перезапуск SSVoiceChat отключит всех игроков от него.", "Перезапустить SSVoicechat?", list("Да", "Нет"))

	if(confirm == "Да")
		SSvoicechat.restart()

ADMIN_VERB(stop_voicechat, R_ADMIN, "Stop Voicechat", "disconnects voicechat clients and stops voicechat", "ProxChat.Admin")
	if(SSvoicechat)
		SSvoicechat.Shutdown()
