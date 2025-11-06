/datum/antagonist/contractor/drifting_contractor
	name = "Дрейфующий Контрактник"
	antag_menu_name = "Дрейфующий Контрактник"
	greet_name = "Дрейфующий Контрактник"
	show_in_roundend = TRUE
	show_in_orbit = TRUE
	race_equipment = list(
		SPECIES_OTHER = /datum/outfit/admin/syndicate/drifting_contractor
	)

/datum/antagonist/contractor/drifting_contractor/give_objectives()
	add_objective(/datum/objective/contractor_kidnap)

/datum/antagonist/contractor/drifting_contractor/greet()
	var/list/messages = list()
	messages.Add(span_danger("<center>Вы - [name]!</center>"))
	messages.Add(span_notice("Вы прибыли на станцию для выполнения контрактов по похищению людей в обмен на репутацию, телекристаллы и, конечно же, деньги."))
	messages.Add(span_notice("Вы в праве помогать другим агентам Синдиката, однако вашей первостепенной задачей является выполнение контрактов."))
	return messages

/datum/outfit/admin/syndicate/drifting_contractor
	name = "Syndicate Drifting Contractor (hardsuit)"
	toggle_helmet = TRUE
	suit = /obj/item/clothing/suit/space/hardsuit/contractor
	mask = /obj/item/clothing/mask/gas/syndicate
	l_ear = /obj/item/radio/headset/syndicate/alt
	glasses = /obj/item/clothing/glasses/night
	shoes = /obj/item/clothing/shoes/magboots/syndie
	implants = list(/obj/item/implant/uplink/contractor, /obj/item/implant/explosive)
	r_pocket = /obj/item/melee/baton/telescopic/contractor
	l_pocket = /obj/item/pinpointer/crew/contractor

	gloves = /obj/item/clothing/gloves/combat/swat/syndicate
	internals_slot = ITEM_SLOT_SUITSTORE

	id_access = SYNDICATE_OPERATIVE

	backpack_contents = list(
		/obj/item/storage/box/survival_syndi = 1,
		/obj/item/paper/contractor_guide/midround = 1,
		/obj/item/contractor_uplink = 1,
		/obj/item/ammo_box/magazine/m10mm = 1,
		/obj/item/crowbar/red = 1,
		/obj/item/grenade/plastic/c4 = 1,
	)

/obj/item/implant/uplink/contractor/get_uses_amount()
	return 0

/obj/item/paper/contractor_guide/midround/Initialize(mapload)
	info = {"<p>Внимание, агент, вы приближаетесь к намеченной нами станции.</p>
			<p>Скорее всего вы имеете при себе МЭК Контрактника. Однако, если вы до сих пор используете старые ИКСы, то ничего страшного.
			Оба устройства предоставляют вам технологию активной маскировки, позволяющую принимать внешний вид наиболее популярных на станции МЭКов и ИКСов соответственно.
			В то время, как ИКСы невозможно улучшить, на МЭК контрактника устанавливаются дополнительные модули, улучшающие его параметры.</p>
			<p>Хаб контрактника, доступный в вашем специализированном аплинке, предоставляет доступ к уникальным предметам и возможностям.
			Покупка осуществляется с помощью особой валюты — репутации, которая предоставляется в двух условных единицах после каждого успешного завершения контракта.</p>
			<h3>Использование аплинка Контрактника</h3>
			<ol>
				<li>Возьмите в руки аплинк, лежащий в вашем наборе, и запустите его.</li>
				<li>После успешного запуска вы можете принимать контракты и получать выплаты в телекристаллах за их выполнение.</li>
				<li>Сумма получаемой награды, указанная в скобках как ТК, это награда, которую вы получите, если доставите вашу цель <b>живой</b>. Награду в виде
				кредитов вы получите в полном объеме, вне зависимости от того, жива ли ваша цель, или нет.</li>
				<li>Выполнение контрактов осуществляется путем доставки цели вашего контракта в обозначенную зону эвакуации, запроса эвакуации через ваш аплинк и перемещения цели в под.</li>
			</ol>
			<p>Внимательно всё обдумайте, принимая контракт. В то время, как вы можете видеть все возможные зоны эвакуации заранее, отказ от уже взятого контракта приведёт к
			невозможности повторно взять или заменить этот контракт.</p>
			<h3>Похищение</h3>
			<ol>
				<li>Убедитесь, что и вы, и цель находитесь в зоне эвакуации.</li>
				<li>Возьмите в руки ваш аплинк и запросите эвакуацию через кнопку "Call Extraction", после чего подожгите предоставленный вам фальшфейер.</li>
				<li>После использования фальшфейера, дождитесь прибытия эвакуационного дроппода.</li>
				<li>Переместите вашу цель в эвакуационный портал.</li>
			</ol>
			<h3>Выкуп</h3>
			<p>Ваши цели нужны нам по нашим собственным причинам, однако, как только они станут для нас бесполезными, мы возвращаем их обратно на станцию за выкуп со стороны НТ.
			Через некоторое время после похищения они будут возвращены в ту локацию, откуда они были доставлены нам. И да, вдобавок от выплаты в виде ТК, вы получите свою долю от выкупа.
			Мы платим на ту карту, что была помещена вами в слот карты в момент эвакуации.</p>
			<p>Удачи, агент. Вы можете выбросить эту бумагу.</p>"}

	return ..()

/datum/objective/contractor_kidnap
