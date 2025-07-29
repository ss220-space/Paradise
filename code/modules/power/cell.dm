/obj/item/stock_parts/cell
	name = "power cell A"
	desc = "Перезаряжаемый электрохимический элемент питания."
	ru_names = list(
		NOMINATIVE = "батарея А",
		GENITIVE = "батареи А",
		DATIVE = "батарее А",
		ACCUSATIVE = "батарею А",
		INSTRUMENTAL = "батареей А",
		PREPOSITIONAL = "батарее А"
	)
	gender = FEMALE
	icon = 'icons/obj/engines_and_power/power.dmi'
	icon_state = "cell"
	item_state = "cell"
	origin_tech = "powerstorage=1"
	force = 5
	throwforce = 5
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	/// How much charge the battery currently has
	var/charge = 0
	/// How much charge the battery can hold
	var/maxcharge = 1000
	materials = list(MAT_METAL = 700, MAT_GLASS = 50)
	/// If the battery will explode
	var/rigged = FALSE
	/// How much charge is given every tick when recharging
	var/chargerate = 100
	/// Whether it will recharge automatically
	var/self_recharge = FALSE
	/// Whether the description will include the maxcharge
	var/ratingdesc = TRUE
	/// Additional overlay to signify battery being organic
	var/grown_battery = FALSE
	// For custom overlays.
	var/overlay_charged = "cell-o2"

/obj/item/stock_parts/cell/laser
	maxcharge = 1500

/obj/item/stock_parts/cell/laser/gatling
	maxcharge = 9000

/obj/item/stock_parts/cell/get_cell()
	return src

/obj/item/stock_parts/cell/New()
	..()
	START_PROCESSING(SSobj, src)
	charge = maxcharge
	update_icon(UPDATE_OVERLAYS)

/obj/item/stock_parts/cell/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/stock_parts/cell/magic_charge_act(mob/user)
	. = NONE

	if(charge >= maxcharge)
		return

	if(prob(80) && adjust_maxcharge(-200))
		. |= RECHARGE_BURNOUT

	charge = maxcharge
	. |= RECHARGE_SUCCESSFUL

	update_appearance(UPDATE_ICON)


/obj/item/stock_parts/cell/proc/adjust_maxcharge(amount)
	if(self_recharge)
		return FALSE	// SelfCharging uses static charge values ​​per tick, so we don't want it to mess up the recharge balance.

	var/old_maxcharge = maxcharge
	maxcharge = max(maxcharge + amount, 1)

	return maxcharge != old_maxcharge


/obj/item/stock_parts/cell/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == NAMEOF(src, self_recharge))
		if(var_value)
			START_PROCESSING(SSobj, src)
		else
			STOP_PROCESSING(SSobj, src)


/obj/item/stock_parts/cell/process()
	if(self_recharge)
		give(chargerate * 0.25)
	else
		return PROCESS_KILL


/obj/item/stock_parts/cell/update_overlays()
	. = ..()
	if(grown_battery)
		. += image('icons/obj/engines_and_power/power.dmi', "grown_wires")
	if(charge < 0.01)
		return
	else if(charge/maxcharge >=0.995)
		. += overlay_charged
	else
		. += "cell-o1"


/obj/item/stock_parts/cell/proc/percent()		// return % charge of cell
	return 100 * charge / maxcharge

// use power from a cell
/obj/item/stock_parts/cell/use(amount)
	if(rigged && amount > 0)
		explode()
		return 0
	if(charge < amount)
		return 0
	charge = (charge - amount)
	return 1

// recharge the cell
/obj/item/stock_parts/cell/proc/give(amount)
	if(rigged && amount > 0)
		explode()
		return 0
	if(maxcharge < amount)
		amount = maxcharge
	var/power_used = min(maxcharge - charge, amount)
	charge += power_used
	return power_used

/obj/item/stock_parts/cell/examine(mob/user)
	. = ..()

	. += span_notice("<b>Максимальная мощность:</b> [DisplayPower(maxcharge)].")

	if(rigged)
		. += span_notice("Судя по всему, химический элемент был модифицирован.")
	else
		. += span_notice("<b>Индикатор заряда:</b> [round(percent())]%")

/obj/item/stock_parts/cell/suicide_act(mob/user)
	to_chat(viewers(user), span_suicide("[user] облизыва[pluralize_ru(user.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)]! Похоже, что [genderize_ru(user.gender, "он", "она", "оно", "они")] пыта[pluralize_ru(user.gender, "ет", "ют")]ся совершить самоубийство!"))
	return FIRELOSS


/obj/item/stock_parts/cell/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/syringe))
		add_fingerprint(user)
		var/obj/item/reagent_containers/syringe/syringe = I
		if(syringe.mode != 1)	// injecting
			balloon_alert(user, "не в режиме ввода!")
			return ATTACK_CHAIN_PROCEED
		if(!syringe.reagents.total_volume)
			balloon_alert(user, "пусто!")
			return ATTACK_CHAIN_PROCEED
		balloon_alert(user, "вещество введено")
		if(syringe.reagents.has_reagent("plasma", 5) || syringe.reagents.has_reagent("plasma_dust", 5))
			rigged = TRUE
			log_admin("LOG: [key_name(user)] injected a power cell with plasma, rigging it to explode.")
			message_admins("LOG: [key_name_admin(user)] injected a power cell with plasma, rigging it to explode.")
		syringe.reagents.clear_reagents()
		syringe.update_icon()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/stock_parts/cell/proc/explode()
	var/turf/T = get_turf(loc)
	if(charge == 0)
		return
	var/devastation_range = -1 //round(charge/11000)
	var/heavy_impact_range = round(sqrt(charge) / 60)
	var/light_impact_range = round(sqrt(charge) / 30)
	var/flash_range = light_impact_range
	if(light_impact_range == 0)
		corrupt()
		return
	//explosion(T, 0, 1, 2, 2)
	log_admin("LOG: Rigged power cell explosion, last touched by [fingerprintslast]")
	message_admins("LOG: Rigged power cell explosion, last touched by [fingerprintslast]")
	rigged = FALSE

	explosion(T, devastation_range, heavy_impact_range, light_impact_range, flash_range, cause = src)
	qdel(src)

/obj/item/stock_parts/cell/proc/corrupt()
	charge /= 2
	maxcharge = max(maxcharge / 2, chargerate)
	if(prob(10))
		rigged = TRUE //broken batterys are dangerous

/obj/item/stock_parts/cell/emp_act(severity)
	charge -= 1000 / severity
	if(charge < 0)
		charge = 0
	..()

/obj/item/stock_parts/cell/ex_act(severity)
	..()
	if(!QDELETED(src))
		switch(severity)
			if(2)
				if(prob(50))
					corrupt()
			if(3)
				if(prob(25))
					corrupt()

/obj/item/stock_parts/cell/blob_act(obj/structure/blob/B)
	ex_act(EXPLODE_DEVASTATE)

/obj/item/stock_parts/cell/proc/get_electrocute_damage()
	if(charge >= 1000)
		return clamp(20 + round(charge / 25000), 20, 195) + rand(-5, 5)
	else
		return 0

// Cell variants
/obj/item/stock_parts/cell/empty/New()
	..()
	charge = 0

/obj/item/stock_parts/cell/upgraded
	name = "power cell A+"
	ru_names = list(
		NOMINATIVE = "батарея А+",
		GENITIVE = "батареи А+",
		DATIVE = "батарее А+",
		ACCUSATIVE = "батарею А+",
		INSTRUMENTAL = "батареей А+",
		PREPOSITIONAL = "батарее А+"
	)
	maxcharge = 2500
	materials = list(MAT_GLASS = 50)
	rating = 2
	chargerate = 1000

/obj/item/stock_parts/cell/upgraded/plus
	name = "power cell A++"
	ru_names = list(
		NOMINATIVE = "батарея А++",
		GENITIVE = "батареи А++",
		DATIVE = "батарее А++",
		ACCUSATIVE = "батарею А++",
		INSTRUMENTAL = "батареей А++",
		PREPOSITIONAL = "батарее А++"
	)
	maxcharge = 5000

/obj/item/stock_parts/cell/secborg
	name = "security borg power cell"
	ru_names = list(
		NOMINATIVE = "батарея охранного робота",
		GENITIVE = "батареи охранного робота",
		DATIVE = "батарее охранного робота",
		ACCUSATIVE = "батарею охранного робота",
		INSTRUMENTAL = "батареей охранного робота",
		PREPOSITIONAL = "батарее охранного робота"
	)
	origin_tech = null
	maxcharge = 600	//600 max charge / 100 charge per shot = six shots
	materials = list(MAT_GLASS = 40)
	rating = 2.5

/obj/item/stock_parts/cell/secborg/empty/New()
	..()
	charge = 0
	update_icon(UPDATE_OVERLAYS)

/obj/item/stock_parts/cell/pulse //265 pulse shots
	name = "pulse rifle power cell"
	ru_names = list(
		NOMINATIVE = "батарея пульсовой винтовки",
		GENITIVE = "батареи пульсовой винтовки",
		DATIVE = "батарее пульсовой винтовки",
		ACCUSATIVE = "батарею пульсовой винтовки",
		INSTRUMENTAL = "батареей пульсовой винтовки",
		PREPOSITIONAL = "батарее пульсовой винтовки"
	)
	maxcharge = 53000
	rating = 3
	chargerate = 1500

/obj/item/stock_parts/cell/pulse/carbine //33 pulse shots
	name = "pulse carbine power cell"
	ru_names = list(
		NOMINATIVE = "батарея пульсового карабина",
		GENITIVE = "батареи пульсового карабина",
		DATIVE = "батарее пульсового карабина",
		ACCUSATIVE = "батарею пульсового карабина",
		INSTRUMENTAL = "батареей пульсового карабина",
		PREPOSITIONAL = "батарее пульсового карабина"
	)
	maxcharge = 6600

/obj/item/stock_parts/cell/pulse/pistol //13 pulse shots
	name = "pulse pistol power cell"
	ru_names = list(
		NOMINATIVE = "батарея пульсового пистолета",
		GENITIVE = "батареи пульсового пистолета",
		DATIVE = "батарее пульсового пистолета",
		ACCUSATIVE = "батарею пульсового пистолета",
		INSTRUMENTAL = "батареей пульсового пистолета",
		PREPOSITIONAL = "батарее пульсового пистолета"
	)
	maxcharge = 2600

/obj/item/stock_parts/cell/dominator
	name = "Dominator pistol power cell"
	ru_names = list(
		NOMINATIVE = "батарея Доминатора",
		GENITIVE = "батареи Доминатора",
		DATIVE = "батарее Доминатора",
		ACCUSATIVE = "батарею Доминатора",
		INSTRUMENTAL = "батареей Доминатора",
		PREPOSITIONAL = "батарее Доминатора"
	)
	maxcharge = 3000
	chargerate = 200
	rating = 2

/obj/item/stock_parts/cell/high
	name = "power cell AA"
	ru_names = list(
		NOMINATIVE = "батарея АА",
		GENITIVE = "батареи АА",
		DATIVE = "батарее АА",
		ACCUSATIVE = "батарею АА",
		INSTRUMENTAL = "батареей АА",
		PREPOSITIONAL = "батарее АА"
	)
	origin_tech = "powerstorage=2"
	icon_state = "hcell"
	maxcharge = 10000
	materials = list(MAT_GLASS = 60)
	rating = 3
	chargerate = 1500

/obj/item/stock_parts/cell/high/plus
	name = "power cell AA+"
	ru_names = list(
		NOMINATIVE = "батарея АА+",
		GENITIVE = "батареи АА+",
		DATIVE = "батарее АА+",
		ACCUSATIVE = "батарею АА+",
		INSTRUMENTAL = "батареей АА+",
		PREPOSITIONAL = "батарее АА+"
	)
	icon_state = "hcell"
	maxcharge = 15000
	chargerate = 2250

/obj/item/stock_parts/cell/high/empty/New()
	..()
	charge = 0
	update_icon(UPDATE_OVERLAYS)

/obj/item/stock_parts/cell/super
	name = "power cell AAA"
	ru_names = list(
		NOMINATIVE = "батарея ААА",
		GENITIVE = "батареи ААА",
		DATIVE = "батарее ААА",
		ACCUSATIVE = "батарею ААА",
		INSTRUMENTAL = "батареей ААА",
		PREPOSITIONAL = "батарее ААА"
	)
	origin_tech = "powerstorage=3;materials=3"
	icon_state = "scell"
	maxcharge = 20000
	materials = list(MAT_GLASS = 300)
	rating = 4
	chargerate = 2000

/obj/item/stock_parts/cell/super/empty/New()
	..()
	charge = 0
	update_icon(UPDATE_OVERLAYS)

/obj/item/stock_parts/cell/hyper
	name = "power cell AAAA"
	ru_names = list(
		NOMINATIVE = "батарея АААА",
		GENITIVE = "батареи АААА",
		DATIVE = "батарее АААА",
		ACCUSATIVE = "батарею АААА",
		INSTRUMENTAL = "батареей АААА",
		PREPOSITIONAL = "батарее АААА"
	)
	origin_tech = "powerstorage=4;engineering=4;materials=4"
	icon_state = "hpcell"
	maxcharge = 30000
	materials = list(MAT_GLASS = 400)
	rating = 5
	chargerate = 3000

/obj/item/stock_parts/cell/hyper/empty/New()
	..()
	charge = 0
	update_icon(UPDATE_OVERLAYS)

/obj/item/stock_parts/cell/bluespace
	name = "bluespace power cell"
	desc = "Перезаряжаемый электрохимический элемент питания. Экспериментальная модель, созданная с использованием блюспейс-технологий."
	ru_names = list(
		NOMINATIVE = "блюспейс-батарея",
		GENITIVE = "блюспейс-батареи",
		DATIVE = "блюспейс-батарее",
		ACCUSATIVE = "блюспейс-батарею",
		INSTRUMENTAL = "блюспейс-батареей",
		PREPOSITIONAL = "блюспейс-батарее"
	)
	origin_tech = "powerstorage=5;bluespace=4;materials=4;engineering=4"
	icon_state = "bscell"
	maxcharge = 40000
	materials = list(MAT_GLASS = 600)
	rating = 6
	chargerate = 4000
	overlay_charged = "cell-o2-bs"

/obj/item/stock_parts/cell/bluespace/empty/New()
	..()
	charge = 0
	update_icon(UPDATE_OVERLAYS)

/obj/item/stock_parts/cell/infinite
	name = "infinite-capacity power cell"
	ru_names = list(
		NOMINATIVE = "бесконечная батарея",
		GENITIVE = "бесконечной батареи",
		DATIVE = "бесконечной батарее",
		ACCUSATIVE = "бесконечную батарею",
		INSTRUMENTAL = "бесконечной батареей",
		PREPOSITIONAL = "бесконечной батарее"
	)
	icon_state = "icell"
	origin_tech =  "powerstorage=7"
	maxcharge = 30000
	materials = list(MAT_GLASS=1000)
	rating = 6
	chargerate = 30000

/obj/item/stock_parts/cell/infinite/use()
	return TRUE

/obj/item/stock_parts/cell/infinite/abductor
	name = "void core"
	desc = "Необычного вида предмет, похожий на элемент питания."
	ru_names = list(
		NOMINATIVE = "пустотное ядро",
		GENITIVE = "пустотного ядра",
		DATIVE = "пустотному ядру",
		ACCUSATIVE = "пустотное ядро",
		INSTRUMENTAL = "пустотным ядром",
		PREPOSITIONAL = "пустотном ядре"
	)
	icon = 'icons/obj/abductor.dmi'
	icon_state = "cell"
	maxcharge = 50000
	rating = 12
	ratingdesc = FALSE


/obj/item/stock_parts/cell/infinite/abductor/update_overlays()
	return list()

/obj/item/stock_parts/cell/potato
	name = "potato battery"
	desc = "Перезаряжаемый элемент питания, созданный на основе картофельного клубня."
	ru_names = list(
		NOMINATIVE = "картофельная батарея",
		GENITIVE = "картофельной батареи",
		DATIVE = "картофельной батарее",
		ACCUSATIVE = "картофельную батарею",
		INSTRUMENTAL = "картофельной батареей",
		PREPOSITIONAL = "картофельной батарее"
	)
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "potato"
	origin_tech = "powerstorage=1;biotech=1"
	charge = 100
	maxcharge = 300
	materials = list()
	rating = 1
	grown_battery = TRUE //it has the overlays for wires

/obj/item/stock_parts/cell/high/slime
	name = "charged slime core"
	desc = "Ядро слайма жёлтого цвета, заполненное плазмой. Потрескивает от электрического тока."
	ru_names = list(
		NOMINATIVE = "заряженное ядро слайма",
		GENITIVE = "заряженного ядра слайма",
		DATIVE = "заряженному ядру слайма",
		ACCUSATIVE = "заряженное ядро слайма",
		INSTRUMENTAL = "заряженным ядром слайма",
		PREPOSITIONAL = "заряженном ядре слайма"
	)
	origin_tech = "powerstorage=5;biotech=4"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "yellow slime extract"
	materials = list()
	rating = 5 //self-recharge makes these desirable
	self_recharge = 1 // Infused slime cores self-recharge, over time
	chargerate = 500

/obj/item/stock_parts/cell/emproof
	name = "EMP-proof power cell A"
	desc = "Перезаряжаемый электрохимический элемент питания. Модицифированная модель, \
			оснащённая экранированием от ЭМИ."
	ru_names = list(
		NOMINATIVE = "ЭМИ-защищённая батарея А",
		GENITIVE = "ЭМИ-защищённой батареи А",
		DATIVE = "ЭМИ-защищённой батарее А",
		ACCUSATIVE = "ЭМИ-защищённую батарею А",
		INSTRUMENTAL = "ЭМИ-защищённой батареей А",
		PREPOSITIONAL = "ЭМИ-защищённой батарее А"
	)
	maxcharge = 500
	rating = 3

/obj/item/stock_parts/cell/emproof/empty/New()
	..()
	charge = 0
	update_icon(UPDATE_OVERLAYS)

/obj/item/stock_parts/cell/emproof/emp_act(severity)
	return

/obj/item/stock_parts/cell/emproof/corrupt()
	return

/obj/item/stock_parts/cell/emproof/adjust_maxcharge(amount)
	return FALSE

/obj/item/stock_parts/cell/bsg
	name = "B.S.G power cell"
	ru_names = list(
		NOMINATIVE = "батарея Б.С.П.",
		GENITIVE = "батареи Б.С.П.",
		DATIVE = "батарее Б.С.П.",
		ACCUSATIVE = "батарею Б.С.П.",
		INSTRUMENTAL = "батареей Б.С.П.",
		PREPOSITIONAL = "батарее Б.С.П."
	)
	maxcharge = 40000
	chargerate = 2600 // about 30 seconds to charge with a default recharger

/obj/item/stock_parts/cell/emittergun // 11 emitter shots
	name = "emitter gun power cell"
	ru_names = list(
		NOMINATIVE = "батарея эмитерной пушки",
		GENITIVE = "батареи эмитерной пушки",
		DATIVE = "батарее эмитерной пушки",
		ACCUSATIVE = "батарею эмитерной пушки",
		INSTRUMENTAL = "батареей эмитерной пушки",
		PREPOSITIONAL = "батарее эмитерной пушки"
	)
	maxcharge = 2200
	chargerate = 100

/obj/item/stock_parts/cell/degraded
	name = "degraded power cell"
	maxcharge = 750
	chargerate = 25
