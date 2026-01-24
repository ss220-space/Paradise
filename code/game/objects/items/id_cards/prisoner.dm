/obj/item/card/id/prisoner
	name = "prisoner ID card"
	desc = "Идентификационная карта для заключённых \"Нанотрейзен\". Служит для подтверждения личности, \
			определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника."
	icon_state = "prisoner"
	item_state = "orange-id"
	registered_name = "Заключёный"
	assignment = "Заключёный"
	/// Points goal for release
	var/goal = 0
	/// Current earned points
	var/points = 0
	/// Used for setting name and assignment
	var/prisoner_number = "000"

/obj/item/card/id/prisoner/get_ru_names()
	return list(
		NOMINATIVE = "ID-карта заключённого",
		GENITIVE = "ID-карты заключённого",
		DATIVE = "ID-карте заключённого",
		ACCUSATIVE = "ID-карту заключённого",
		INSTRUMENTAL = "ID-картой заключённого",
		PREPOSITIONAL = "ID-карте заключённого",
	)

/obj/item/card/id/prisoner/Initialize(mapload)
	. = ..()
	assignment = "Заключёный №[prisoner_number]"
	registered_name = assignment
	update_label()

/obj/item/card/id/prisoner/examine(mob/user)
	. = ..()
	. += span_notice("Очки для освобождения: <b>[points]/[goal]</b>.")

/obj/item/card/id/prisoner/one
	prisoner_number = "001"

/obj/item/card/id/prisoner/two
	prisoner_number = "002"

/obj/item/card/id/prisoner/three
	prisoner_number = "003"

/obj/item/card/id/prisoner/four
	prisoner_number = "004"

/obj/item/card/id/prisoner/five
	prisoner_number = "005"

/obj/item/card/id/prisoner/six
	prisoner_number = "006"

/obj/item/card/id/prisoner/seven
	prisoner_number = "007"

/obj/item/card/id/prisoner/random/Initialize(mapload)
	prisoner_number = "[rand(0, 999)]"
	. = ..()
