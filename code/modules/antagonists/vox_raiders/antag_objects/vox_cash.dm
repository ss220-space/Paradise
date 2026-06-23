/obj/item/stack/vox_cash
	name = "vox cash"
	desc = "Криптографический чип доступа к адресам транзакций рассчетных средств воксов."
	icon = 'icons/obj/machines/trader_machine.dmi'
	icon_state = "vox_key"
	hitsound = "swing_hit"
	force = 1
	throwforce = 1
	throw_speed = 1
	w_class = WEIGHT_CLASS_TINY
	max_amount = /obj/item/stack/spacecash::max_amount
	merge_type = /obj/item/stack/vox_cash

/obj/item/stack/vox_cash/get_ru_names()
	return alist(
		NOMINATIVE = "кикиридиты",
		GENITIVE = "кикиридитов",
		DATIVE = "кикиридитам",
		ACCUSATIVE = "кикиридиты",
		INSTRUMENTAL = "кикиридитами",
		PREPOSITIONAL = "кикиридитах",
	)


/obj/item/stack/vox_cash/update_name(updates)
	. = ..()
	var/amount = get_amount()
	name = "[initial(name)] ([amount])"
	var/list/ru_names = get_ru_names_cached()
	if(!ru_names)
		return
	var/list/final_ru_names = new(length(ru_names))
	for(var/i in 1 to length(ru_names))
		final_ru_names[i] = "[ru_names[i]] ([amount])"

/obj/item/stack/vox_cash/Initialize(mapload, new_amount, merge)
	. = ..()
	update_appearance(UPDATE_NAME)

/obj/item/stack/vox_cash/merge(obj/item/stack/material)
	. = ..()
	update_appearance(UPDATE_NAME)

/obj/item/stack/vox_cash/use(used, check = TRUE)
	. = ..()
	update_appearance(UPDATE_NAME)

/obj/item/stack/vox_cash/add(newamount)
	. = ..()
	update_appearance(UPDATE_NAME)

/obj/item/stack/vox_cash/c5
	amount = 5

/obj/item/stack/vox_cash/c10
	amount = 10

/obj/item/stack/vox_cash/c20
	amount = 20

/obj/item/stack/vox_cash/c50
	amount = 50

/obj/item/stack/vox_cash/c100
	amount = 100

/obj/item/stack/vox_cash/c200
	amount = 200

/obj/item/stack/vox_cash/c500
	amount = 500

/obj/item/stack/vox_cash/c1000
	amount = 1000

/obj/item/stack/vox_cash/c10000
	amount = 10000

/obj/item/stack/vox_cash/c25000
	amount = 25000

/obj/item/stack/vox_cash/c50000
	amount = 50000

/obj/item/stack/vox_cash/c100000
	amount = 100000
