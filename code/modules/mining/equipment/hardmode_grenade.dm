/obj/item/grenade/megafauna_hardmode
	name = "\improper HRD-MDE Scanning Grenade"
	desc = "An advanced grenade that releases nanomachines, which enter nearby megafauna. This will enrage them greatly, but allows nanotrasen to fully research their abilities."
	icon_state = "enrager"
	item_state = "grenade"

/obj/item/grenade/megafauna_hardmode/prime()
	update_mob()
	playsound(loc, 'sound/effects/empulse.ogg', 50, TRUE)
	for(var/mob/living/simple_animal/hostile/megafauna/M in range(7, src))
		M.enrage()
		visible_message("<span class='userdanger'>[M] begins to wake up as the nanomachines enter them, it looks pissed!</span>")
	qdel(src)

/obj/item/paper/hardmode
	name = "Инструкции по использованию гранаты типа \"HRD-MDE\"" //no joke on russian, uh-oh
	icon_state = "paper"
	info = {"<b> Добро пожаловать в исследовательскую программу НТ \"HRD-MDE\""</b><br>
	<br>
	Данный инструктаж расскажет вам об основах использования экспериментальных научно-исследовательских гранатах.<br>
	<br>
	При использовании, данные гранаты выпускают облако практически безопасных* для человеческого организма наномашин, которые, при соприкосновении с фауной, позволяют пристально изучить строение их тела при жизни. Мы будем использовать эти данные для создания новых товаров широкого потребления, и для этого нам понадобится ваша помощь!<br>
	<br>
	Нам необходимо изучить фауну в своей полной, всеобъемлющей силе, пока в них находятся наномашины, поэтому вам необходимо будет с ними сразиться. Предупреждаем, что этот тип наномашин вызывает сильное раздражение у агрессию у фауны, а так же вводит в их тела боевой коктейль военного образца, заставляющий их тела работать на ранее невиданных мощностях."<br>
	<br>
	Мы работаем с очень огрниченным бюджетом, однако мы предоставим вам оплату за участие в программе: вы получите до 0.01% прибыли** от продажи всех товаров, полученных в результате этого исследования, а так же медали, демонстрирующие ваше стремление к идеалам НТ и продвижение науки вперед.
	<br><hr>
	<font size =\"1\"><i>*НТ не несет ответственности за возможные последствия при контакте нанитов с кожей.<br>
	<br>**95% средств, полученных вами за участие в эксперименте, будет изъято в счёт погашения долга за перелёт на шаттле Харон, проживание на станциях НТ и страхование жизни класса А-5.<br>
	<br>Учавствуя в данном эксперименте, вы отказываетесь от всех прав на получение компенсации в случае смерть на рабочем месте.</font></i>
"}

/obj/item/disk/fauna_research
	name = "empty HRD-MDE project disk"
	desc = "A disk used by the HRD-MDE project. Seems empty?"
	icon_state = "holodisk"
	var/obj/item/clothing/accessory/medal/output

/obj/item/disk/fauna_research/Initialize(mapload)
	. = ..()
	for(var/obj/structure/closet/C in get_turf(src))
		forceMove(C)
		return

/obj/item/disk/fauna_research/blood_drunk_miner
	name = "blood drunk HRD-MDE project disk"
	desc = "A disk used by the HRD-MDE project. Contains data on the dash and resistance of the blood drunk miner."
	output = /obj/item/clothing/accessory/medal/blood_drunk

/obj/item/disk/fauna_research/hierophant
	name = "\improper Hierophant HRD-MDE project disk"
	desc = "A disk used by the HRD-MDE project. Contains data on the energy manipulation and material composition of the Hierophant."
	output = /obj/item/clothing/accessory/medal/plasma/hierophant

/obj/item/disk/fauna_research/ash_drake
	name = "ash drake HRD-MDE project disk"
	desc = "A disk used by the HRD-MDE project. Contains data on the fire production methods and rapid regeneration of the ash drakes."
	output = /obj/item/clothing/accessory/medal/plasma/ash_drake

/obj/item/disk/fauna_research/vetus
	name = "\improper Vetus Speculator HRD-MDE project disk"
	desc = "A disk used by the HRD-MDE project. Contains data on the anomaly manipulation and computing processes of the Vetus Speculator."
	output = /obj/item/clothing/accessory/medal/alloy/vetus

/obj/item/disk/fauna_research/colossus
	name = "colossus HRD-MDE project disk"
	desc = "A disk used by the HRD-MDE project. Contains data on the powerful voice and A-T field of the colossi."
	output = /obj/item/clothing/accessory/medal/silver/colossus

/obj/item/disk/fauna_research/legion
	name = "\improper Legion HRD-MDE project disk"
	desc = "A disk used by the HRD-MDE project. Contains data on the endless regeneration and disintegration laser of the Legion."
	output = /obj/item/clothing/accessory/medal/silver/legion

/obj/item/disk/fauna_research/bubblegum
	name = "\improper Bubblegum HRD-MDE project disk"
	desc = "A disk used by the HRD-MDE project. Contains data on the bloodcrawling and \[REDACTED\] of Bubblegum." //I hate this so much
	output = /obj/item/clothing/accessory/medal/gold/bubblegum
