/obj/mecha/working/ripley
	desc = "Autonomous Power Loader Unit. This newer model is refitted with powerful armour against the dangers of the EVA mining process."
	name = "APLU \"Ripley\""
	icon_state = "ripley"
	initial_icon = "ripley"
	step_in = 4 //Move speed, lower is faster.
	fast_pressure_step_in = 2 //step_in while in normal pressure conditions
	slow_pressure_step_in = 4 //step_in while in better pressure conditions
	max_temperature = 20000
	max_integrity = 200
	lights_power = 7
	deflect_chance = 15
	armor = list("melee" = 40, "bullet" = 20, "laser" = 10, "energy" = 20, "bomb" = 40, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	max_equip = 6
	wreckage = /obj/structure/mecha_wreckage/ripley
	var/hides = 0
	var/plates = 0

	mech_type = MECH_TYPE_RIPLEY


/obj/mecha/working/ripley/Destroy()
	for(var/i=1, i <= hides, i++)
		new /obj/item/stack/sheet/animalhide/goliath_hide(loc) //If a goliath-plated ripley gets killed, all the plates drop
	return ..()


/obj/mecha/working/ripley/update_overlays()
	. = ..()
	if(hides && !plates)
		if(hides < 3)
			. += occupant ? "ripley-g" : "ripley-g-open"
		else
			. += occupant ? "ripley-g-full" : "ripley-g-full-open"

	else if(plates && !hides)
		if(plates < 3)
			. += occupant ? "ripley-a" : "ripley-a-open"
		else
			. += occupant ? "ripley-a-full" : "ripley-a-full-open"

	else if(plates && hides)
		if(plates < 3 && hides >= 3)
			. += occupant ? "ripley-g-full" : "ripley-g-full-open"
			. += occupant ? "ripley-a" : "ripley-a-open"

		else if(plates < 3 && hides < 3)
			. += occupant ? "ripley-a-full" : "ripley-a-full-open"
			. += occupant ? "ripley-g" : "ripley-g-open"

		else if(plates >= 3 && hides < 3)
			. += occupant ? "ripley-a-full" : "ripley-a-full-open"
			. += occupant ? "ripley-g" : "ripley-g-open"

		else if(plates >= 3 && hides >= 3)
			. += occupant ? "ripley-g-full" : "ripley-g-full-open"
			. += occupant ? "ripley-a" : "ripley-a-open"


/obj/mecha/working/ripley/update_desc(updates = ALL)
	. = ..()

	if(hides && !plates)
		if(hides < 3)
			desc = "Autonomous Power Loader Unit. You see reinforcements made of plates of goliath hide attached to the armor."
		else
			desc = "Autonomous Power Loader Unit. It has an intimidating carapace composed entirely of plates of goliath hide - its pilot must be an experienced monster hunter."

	else if(plates && !hides)
		if(plates < 3)
			desc = "Autonomous Power Loader Unit. You can see the pieces of homemade armor on the hull."
		else
			desc = "Autonomous Power Loader Unit. Completely encrusted with reinforced debris, this shiny lump of metal looks incredibly durable."

	else if(plates && hides)
		if(plates < 3 && hides >= 3)
			desc = "Autonomous Power Loader Unit. Not only is the goliath hide armor intimidating, it's additionally covered in pieces of homemade armor. How do you kill that?!"
		else if(plates < 3 && hides < 3)
			desc = "Autonomous Power Loader Unit. The owner of the mech decided to go all out - clad in pieces of homemade armor and goliath skins."
		else if(plates >= 3 && hides < 3)
			desc = "Autonomous Power Loader Unit. Fully covered with homemade armor and few goliath hides on top."
		else if(plates >= 3 && hides >= 3)
			desc = "Autonomous Power Loader Unit. Clad in homemade armor from ear to toe, with Goliath plates on top - a real tank, no other way."


/obj/mecha/working/ripley/firefighter
	desc = "Standart APLU chassis was refitted with additional thermal protection and cistern."
	name = "APLU \"Firefighter\""
	icon_state = "firefighter"
	initial_icon = "firefighter"
	max_temperature = 65000
	max_integrity = 250
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	lights_power = 7
	armor = list("melee" = 40, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 60, "bio" = 0, "rad" = 70, "fire" = 100, "acid" = 100)
	max_equip = 5 // More armor, less tools
	wreckage = /obj/structure/mecha_wreckage/ripley/firefighter

/obj/mecha/working/ripley/deathripley
	desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA DIE"
	name = "DEATH-RIPLEY"
	icon_state = "deathripley"
	initial_icon = "deathripley"
	step_in = 3
	slow_pressure_step_in = 3
	opacity = FALSE
	max_temperature = 65000
	max_integrity = 300
	lights_power = 7
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 0, "bomb" = 70, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	wreckage = /obj/structure/mecha_wreckage/ripley/deathripley
	step_energy_drain = 0
	normal_step_energy_drain = 0

/obj/mecha/working/ripley/deathripley/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill
	ME.attach(src)
	return

/obj/mecha/working/ripley/mining
	desc = "An old, dusty mining ripley."
	name = "APLU \"Miner\""
	obj_integrity = 75 //Low starting health

/obj/mecha/working/ripley/mining/New()
	..()
	if(cell)
		cell.charge = FLOOR(cell.charge * 0.25, 1) //Starts at very low charge
	//Attach drill
	if(prob(70)) //Maybe add a drill
		if(prob(15)) //Possible diamond drill... Feeling lucky?
			var/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill/D = new
			D.attach(src)
		else
			var/obj/item/mecha_parts/mecha_equipment/drill/D = new
			D.attach(src)

	else //Add plasma cutter if no drill
		var/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma/P = new
		P.attach(src)

	//Add ore box to cargo
	LAZYADD(cargo, new /obj/structure/ore_box(src))

	//Attach hydraulic clamp
	var/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/HC = new
	HC.attach(src)
	QDEL_LIST(trackers) //Deletes the beacon so it can't be found easily

	var/obj/item/mecha_parts/mecha_equipment/mining_scanner/scanner = new
	scanner.attach(src)


/obj/mecha/working/ripley/emag_act(mob/user)
	if(!emagged)
		add_attack_logs(user, src, "emagged")
		emagged = TRUE
		if(user)
			to_chat(user, "<span class='notice'>You slide the card through [src]'s ID slot.</span>")
		playsound(loc, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		desc += "</br><span class='danger'>The mech's equipment slots spark dangerously!</span>"
	else if(user)
		to_chat(user, "<span class='warning'>[src]'s ID slot rejects the card.</span>")

/obj/mecha/working/ripley/full_load
	name = "Тестовый Рипли"
	desc = "Рипли, который несет в себе все возможные модули, предназначенные для рабочих мехов, с целью их испытания в индивидуальном порядке. Конструкция надежна как Nokia 3310, скорость как у гоночного болида, но стоимость производства настолько высока, что в массовое производство он никогда не пойдет. Специально для ведущих гениев робототехники."
	max_equip = 40
	strafe_allowed = TRUE
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 0, acid = 0) // для тестов урона
	max_integrity = 1000
	deflect_chance = 0 // нахуй рандом
	mech_enter_time = 1
	fast_pressure_step_in = 1 //не хочу страдать на щитспавн мехе для тестов
	slow_pressure_step_in = 0.5

/obj/mecha/working/ripley/full_load/New()
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/drill
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/drill/diamonddrill
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/multimodule/atmos_module
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/rcd
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/wormhole_generator
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/gravcatapult
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/teleporter
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/teleporter/precise
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/mining_scanner
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/eng_toolset
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/cargo_upgrade
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/mecha_kineticgun
	ME.attach(src)

/obj/mecha/working/ripley/full_load/add_cell()
	cell = new /obj/item/stock_parts/cell/bluespace(src) // для тестов энергопотребления.
