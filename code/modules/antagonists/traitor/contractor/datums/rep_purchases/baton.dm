/**
  * # Rep Purchase - Contractor Baton and upgrades
  */
/datum/rep_purchase/item/baton
	name = "Дубинка Контрактника"
	description = "Компактная специализированная дубинка, которую выдают контрактникам Синдиката. \
			Это оружие применяется для поражения цели слабым электрическим током, что позволяет быстро обездвижить её."
	cost = 2
	stock = 2
	item_type = /obj/item/melee/baton/telescopic/contractor

/datum/rep_purchase/item/baton_cuffup
	name = "Улучшение для дубинки — \"Стяжки\""
	description = "Позволяет заряжать стяжки, которые будут автоматически надеваться на цель во время оглушения."
	cost = 2
	stock = 1
	item_type = /obj/item/baton_upgrade/cuff

/datum/rep_purchase/item/baton_muteup
	name = "Улучшение для дубинки — \"Безмолвие\""
	description = "Удар дубинкой на 5 секунд лишает цель возможности говорить."
	cost = 2
	stock = 1
	item_type = /obj/item/baton_upgrade/mute

/datum/rep_purchase/item/baton_focusup
	name = "Улучшение для дубинки — \"Фокусировка\""
	description = "Теперь, когда вы используете дубинку на цели, указанной в вашем контракте, она станет еще более эффективной."
	cost = 2
	stock = 1
	item_type = /obj/item/baton_upgrade/focus

/datum/rep_purchase/item/baton_antidropup
	name = "Улучшение для дубинки — \"Защита от выпадения\""
	description = "Экспериментальная технология, представляющая собой систему шипов. \
			Когда вы держите дубинку, шипы впиваются в вашу кожу, обеспечивая надёжную фиксацию и предотвращая её выпадение."
	cost = 2
	stock = 1
	item_type = /obj/item/baton_upgrade/antidrop
