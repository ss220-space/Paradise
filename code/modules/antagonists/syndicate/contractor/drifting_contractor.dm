/datum/antagonist/contractor/drifting_contractor
	name = "Дрейфующий Контрактник"
	antag_menu_name = "Дрейфующий Контрактник"
	var/our_outfit = /datum/outfit/admin/syndicate/drifting_contractor

/datum/antagonist/contractor/drifting_contractor/give_objectives()
	add_objective(/datum/objective/contractor_kidnap)

/datum/antagonist/contractor/proc/become_contractor(mob/living/carbon/human/our_contractor)
	var/obj/item/contractor_uplink/uplink = new
	our_contractor.put_in_hands(uplink)
	contractor_uplink = uplink
	uplink.hub = new(owner, contractor_uplink)

/datum/antagonist/contractor/drifting_contractor/greet()
	var/list/messages = list()
	messages.Add(span_danger("<center>Вы — [name]!</center>"))
	messages.Add(span_notice("Вы прибыли на станцию для выполнения контрактов по похищению людей в обмен на репутацию, телекристаллы и, конечно же, деньги."))
	messages.Add(span_notice("Вы в праве помогать другим агентам Синдиката, однако вашей первостепенной задачей является выполнение контрактов."))
	return messages

/datum/antagonist/contractor/drifting_contractor/proc/equip()
	var/mob/living/carbon/human/human = owner.current
	if(!istype(human))
		return
	if(!our_outfit)
		return

	for(var/obj/item/item as anything in human.get_equipped_items(TRUE, TRUE))
		qdel(item)

	human.equipOutfit(our_outfit)
	become_contractor(human)

/datum/outfit/admin/syndicate/drifting_contractor
	name = "Contractor"
	mask = /obj/item/clothing/mask/gas/syndicate
	l_ear = /obj/item/radio/headset/syndicate/alt
	glasses = /obj/item/clothing/glasses/night
	shoes = /obj/item/clothing/shoes/magboots/syndie
	implants = list(/obj/item/implant/uplink/contractor, /obj/item/implant/explosive, )
	r_pocket = /obj/item/melee/baton/telescopic/contractor
	l_pocket = /obj/item/tank/internals/emergency_oxygen/engi/syndi
	gloves = /obj/item/clothing/gloves/combat/swat/syndicate
	internals_slot = ITEM_SLOT_POCKET_LEFT
	back = /obj/item/mod/control/pre_equipped/contractor/upgraded
	backpack_contents = list(
		/obj/item/storage/box/survival/survival_syndi = 1,
		/obj/item/paper/contractor_guide_midround = 1,
		/obj/item/storage/firstaid/doctor = 1,
		/obj/item/jammer = 1,
		/obj/item/grenade/plastic/c4 = 1,
		/obj/item/pinpointer/crew/contractor = 1,
	)

/obj/item/implant/uplink/contractor/get_uses_amount()
	return 10

/obj/item/paper/contractor_guide_midround
	name = "Руководство для Контрактника"

/obj/item/paper/contractor_guide_midround/Initialize(mapload)
	info = {"<p>Внимание, агент, вы приближаетесь к намеченной нами станции.</p>
			<p>Скорее всего вы имеете при себе МЭК Контрактника. Однако, если вы до сих пор используете старые ИКСы, то ничего страшного.
			Оба устройства предоставляют вам технологию активной маскировки, позволяющую принимать внешний вид наиболее популярных на станции МЭКов и ИКСов соответственно.
			В то время как ИКСы невозможно улучшить, на МЭК контрактника устанавливаются дополнительные модули, улучшающие его параметры.</p>
			<p>Хаб контрактника, доступный в вашем специализированном аплинке, предоставляет доступ к уникальным предметам и возможностям.
			Покупка осуществляется с помощью особой валюты — репутации, которая предоставляется в двух условных единицах после каждого успешного завершения контракта.</p>
			<h3>Использование аплинка Контрактника</h3>
			<ol>
				<li>Возьмите в руки аплинк, лежащий в вашем наборе, и запустите его.</li>
				<li>После успешного запуска вы можете принимать контракты и получать выплаты в телекристаллах за их выполнение.</li>
				<li>Сумма получаемой награды, указанная в скобках как ТК, это награда, которую вы получите, если доставите вашу цель <b>живой</b>. Награду в виде
				кредитов вы получите в полном объеме, вне зависимости от того, жива ли ваша цель или нет.</li>
				<li>Выполнение контрактов осуществляется путем доставки цели вашего контракта в обозначенную зону эвакуации, запроса эвакуации через ваш аплинк и перемещения цели в под.</li>
			</ol>
			<p>Внимательно всё обдумайте, принимая контракт. В то время как вы можете видеть все возможные зоны эвакуации заранее, отказ от уже взятого контракта приведёт к
			невозможности повторно взять или заменить этот контракт.</p>
			<h3>Похищение</h3>
			<ol>
				<li>Убедитесь, что и вы, и цель находитесь в зоне эвакуации.</li>
				<li>Возьмите в руки ваш аплинк и запросите эвакуацию через кнопку "Call Extraction", после чего подожгите предоставленный вам фальшфейер.</li>
				<li>После использования фальшфейера, дождитесь прибытия эвакуационного дроппода.</li>
				<li>Переместите вашу цель в эвакуационный дроппод.</li>
			</ol>
			<h3>Выкуп</h3>
			<p>Ваши цели нужны нам по нашим собственным причинам, однако, как только они станут для нас бесполезными, мы возвращаем их обратно на станцию за выкуп со стороны НТ.
			Через некоторое время после похищения они будут возвращены в ту локацию, откуда они были доставлены нам. И да, вдобавок от выплаты в виде ТК, вы получите свою долю от выкупа.
			Мы платим на ту карту, что была помещена вами в слот карты в момент эвакуации.</p>
			<p>Удачи, агент. Вы можете выбросить эту бумагу.</p>"}

	return ..()

/datum/objective/contractor_kidnap
	name = "Kidnap Targets"
	explanation_text = "Выполните по меньшей мере три контракта в вашем апплинке."
	needs_target = FALSE
	var/needed_contracts = 3

/datum/objective/contractor_kidnap/check_completion()
	var/completed_contracts = null

	for(var/datum/antagonist/contractor/antag_datum in owner.antag_datums)
		completed_contracts = antag_datum?.contractor_uplink?.hub?.completed_contracts

	if(isnull(completed_contracts))
		return FALSE

	if(completed_contracts >= needed_contracts)
		return TRUE

