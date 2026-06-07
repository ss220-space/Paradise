/obj/item/gun/energy/temperature
	name = "temperature gun"
	icon = 'icons/obj/weapons/gun_temperature.dmi'
	icon_state = "tempgun_4"
	item_state = "tempgun_4"
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	desc = "A gun that changes the body temperature of its targets."
	fire_delay = 1.5 SECONDS
	var/temperature = 300
	var/target_temperature = 300
	origin_tech = "combat=4;materials=4;powerstorage=3;magnets=2"

	ammo_type = list(/obj/item/ammo_casing/energy/temp)
	selfcharge = TRUE

	var/powercost = ""
	var/powercostcolor = ""

	var/dat = ""
	accuracy = GUN_ACCURACY_RIFLE_LASER

/obj/item/gun/energy/temperature/Initialize(mapload, ...)
	. = ..()
	update_icon(UPDATE_ICON_STATE)
	START_PROCESSING(SSobj, src)

/obj/item/gun/energy/temperature/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/gun/energy/temperature/newshot()
	..()

/obj/item/gun/energy/temperature/attack_self(mob/living/user)
	user.set_machine(src)
	update_dat()
	var/datum/browser/popup = new(user, "tempgun", "Temperature Gun Configuration", 510, 120)
	popup.set_content("<hr>[dat]")
	popup.open(TRUE)
	onclose(user, "tempgun")

/obj/item/gun/energy/temperature/emag_act(mob/user)
	if(!emagged)
		add_attack_logs(user, src, "emagged")
		emagged = TRUE
		if(user)
			to_chat(user, span_caution("You double the gun's temperature cap! Targets hit by searing beams will burst into flames!"))
		desc = "A gun that changes the body temperature of its targets. Its temperature cap has been hacked."

/obj/item/gun/energy/temperature/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)

	if(href_list["temp"])
		var/amount = text2num(href_list["temp"])
		if(amount > 0)
			target_temperature = min((500 + 500*emagged), target_temperature+amount)
		else
			target_temperature = max(TCMB, target_temperature+amount)
	if(ismob(loc))
		attack_self(loc)
	add_fingerprint(usr)
	return

/obj/item/gun/energy/temperature/process()
	..()
	var/obj/item/ammo_casing/energy/temp/T = ammo_type[select]
	T.temp = temperature
	switch(temperature)
		if(0 to 100)
			T.e_cost = 300
			powercost = "High"
		if(100 to 250)
			T.e_cost = 200
			powercost = "Medium"
		if(251 to 300)
			T.e_cost = 100
			powercost = "Low"
		if(301 to 400)
			T.e_cost = 200
			powercost = "Medium"
		if(401 to 1000)
			T.e_cost = 300
			powercost = "High"
	switch(powercost)
		if("High")
			powercostcolor = "orange"
		if("Medium")
			powercostcolor = "green"
		else
			powercostcolor = "blue"
	if(target_temperature != temperature)
		var/difference = abs(target_temperature - temperature)
		if(difference >= (10 + 40*emagged)) //so emagged temp guns adjust their temperature much more quickly
			if(target_temperature < temperature)
				temperature -= (10 + 40*emagged)
			else
				temperature += (10 + 40*emagged)
		else
			temperature = target_temperature
		update_icon()

		if(iscarbon(loc))
			var/mob/living/carbon/M = loc
			if(src == M.machine)
				update_dat()
				var/datum/browser/popup = new(M, "tempgun", "Temperature Gun Configuration", 510, 120)
				popup.set_content("<hr>[dat]")
				popup.open(FALSE)
	return

/obj/item/gun/energy/temperature/proc/update_dat()
	dat = ""
	dat += "Current output temperature: "
	if(temperature > 500)
		dat += "<span style='color: red;'><b>[temperature]</b> ([round(temperature-T0C)]&deg;C)</span>"
		dat += "<span style='color: red;'><b> SEARING!</b></span>"
	else if(temperature > (T0C + 50))
		dat += "<span style='color: red;'><b>[temperature]</b> ([round(temperature-T0C)]&deg;C)</span>"
	else if(temperature > (T0C - 50))
		dat += "<span style='color: black;'><b>[temperature]</b> ([round(temperature-T0C)]&deg;C)</span>"
	else
		dat += "<span style='color: blue;'><b>[temperature]</b> ([round(temperature-T0C)]&deg;C)</span>"
	dat += "<br>"
	dat += "Target output temperature: "	//might be string idiocy, but at least it's easy to read
	dat += "<a href='byond://?src=[UID()];temp=-100'>-</a> "
	dat += "<a href='byond://?src=[UID()];temp=-10'>-</a> "
	dat += "<a href='byond://?src=[UID()];temp=-1'>-</a> "
	dat += "[target_temperature] "
	dat += "<a href='byond://?src=[UID()];temp=1'>+</a> "
	dat += "<a href='byond://?src=[UID()];temp=10'>+</a> "
	dat += "<a href='byond://?src=[UID()];temp=100'>+</a>"
	dat += "<br>"
	dat += "Power cost: "
	dat += "<span style='color: [powercostcolor];'><b>[powercost]</b></span>"

/obj/item/gun/energy/temperature/update_icon_state()
	switch(temperature)
		if(501 to INFINITY)
			item_state = "tempgun_8"
		if(400 to 500)
			item_state = "tempgun_7"
		if(360 to 400)
			item_state = "tempgun_6"
		if(335 to 360)
			item_state = "tempgun_5"
		if(295 to 335)
			item_state = "tempgun_4"
		if(260 to 295)
			item_state = "tempgun_3"
		if(200 to 260)
			item_state = "tempgun_2"
		if(120 to 260)
			item_state = "tempgun_1"
		if(-INFINITY to 120)
			item_state = "tempgun_0"

	icon_state = item_state

/obj/item/gun/energy/temperature/update_overlays()
	. = ..()
	switch(cell.charge)
		if(900 to INFINITY)
			. += "900"
		if(800 to 900)
			. += "800"
		if(700 to 800)
			. += "700"
		if(600 to 700)
			. += "600"
		if(500 to 600)
			. += "500"
		if(400 to 500)
			. += "400"
		if(300 to 400)
			. += "300"
		if(200 to 300)
			. += "200"
		if(100 to 202)
			. += "100"
		if(-INFINITY to 100)
			. += "0"
