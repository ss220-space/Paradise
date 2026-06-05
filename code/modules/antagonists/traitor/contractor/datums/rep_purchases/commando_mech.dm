/**
 * # Rep Purchase - Commando Mech
 */
/datum/rep_purchase/item/commando_mech
	name = "Доставка меха \"Коммандо\""
	description = "Одноразовый маяк, вызывающий экзокостюм \"Коммандо\"."
	cost = 6
	stock = 1
	item_type = /obj/item/mecha_drop/commando

/obj/item/mecha_drop/commando
	name = "устройство доставки меха \"Коммандо\""
	desc = "Одноразовое устройство наведения для доставки компактного экзокостюма Синдиката."
	mecha_type = /obj/mecha/combat/commando/loaded
