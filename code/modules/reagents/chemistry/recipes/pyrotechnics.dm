/datum/chemical_reaction/explosion_potassium
	name = "Взрыв" // Explosion
	id = "explosion_potassium"
	result = null
	required_reagents = list("water" = 1, "potassium" = 1)
	result_amount = 2
	mix_message = "Смесь взрывается!"

/datum/chemical_reaction/explosion_potassium/on_reaction(datum/reagents/holder, created_volume)
	var/datum/effect_system/reagents_explosion/e = new()
	e.set_up(round (created_volume/10, 1), holder.my_atom, 0, 0)
	e.start()
	holder.clear_reagents()

/datum/chemical_reaction/emp_pulse
	name = "ЭМИ" // EMP Pulse
	id = "emp_pulse"
	result = null
	required_reagents = list("uranium" = 1, "iron" = 1) // Yes, laugh, it's the best recipe I could think of that makes a little bit of sense
	result_amount = 2

/datum/chemical_reaction/emp_pulse/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	// 100 created volume = 4 heavy range & 7 light range. A few tiles smaller than traitor EMP grandes.
	// 200 created volume = 8 heavy range & 14 light range. 4 tiles larger than traitor EMP grenades.
	empulse(location, round(created_volume / 24), round(created_volume / 14), 1)
	holder.clear_reagents()

/datum/chemical_reaction/beesplosion
	name = "Пчелиный взрыв" // Bee Explosion
	id = "beesplosion"
	result = null
	required_reagents = list("honey" = 1, "strange_reagent" = 1, "radium" = 1)
	result_amount = 1

/datum/chemical_reaction/beesplosion/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	if(created_volume < 5)
		playsound(location,'sound/effects/sparks1.ogg', 100, 1)
	else
		playsound(location,'sound/creatures/bee.ogg', 100, 1)
		var/list/beeagents = list()
		for(var/X in holder.reagent_list)
			var/datum/reagent/R = X
			if(R.id in required_reagents)
				continue
			if(!R.can_synth)
				continue
			beeagents += R
		var/bee_amount = round(created_volume * 0.2)
		for(var/i in 1 to bee_amount)
			var/mob/living/simple_animal/hostile/poison/bees/new_bee = new(location)
			if(LAZYLEN(beeagents))
				new_bee.assign_reagent(pick(beeagents))

/datum/chemical_reaction/nitroglycerin
	name = "Нитроглицерин" // Nitroglycerin
	id = "nitroglycerin"
	required_reagents = list("glycerol" = 1, "facid" = 1, "sacid" = 1)
	result_amount = 2

/datum/chemical_reaction/nitroglycerin/on_reaction(datum/reagents/holder, created_volume)
	var/datum/effect_system/reagents_explosion/e = new()
	e.set_up(round(created_volume/2, 1), holder.my_atom, 0, 0)
	e.start()
	holder.clear_reagents()

/datum/chemical_reaction/stabilizing_agent
	name = "Стабилизирующий агент" // stabilizing_agent
	id = "stabilizing_agent"
	result = "stabilizing_agent"
	required_reagents = list("iron" = 1, "oxygen" = 1, "hydrogen" = 1)
	result_amount = 2
	mix_message = "Смесь превращается в жёлтую жидкость!"

/datum/chemical_reaction/clf3
	name = "Трёхфтористый хлор" // Chlorine Trifluoride
	id = "clf3"
	result = "clf3"
	required_reagents = list("chlorine" = 1, "fluorine" = 3)
	result_amount = 2
	min_temp = T0C + 150

/datum/chemical_reaction/clf3/on_reaction(datum/reagents/holder, created_volume)
	fire_flash_log(holder, id)
	fireflash(holder.my_atom, 1, 7000)

/datum/chemical_reaction/sorium
	name = "Сорий" // Sorium
	id = "sorium"
	result = "sorium"
	required_reagents = list("mercury" = 1, "carbon" = 1, "nitrogen" = 1, "oxygen" = 1, "stabilizing_agent" = 1)
	result_amount = 4
	mix_message = "Смесь хлопает и потрескивает, перед тем как осесть."

/datum/chemical_reaction/sorium_explosion
	name = "Сориевый взрыв" // Sorium Explosion
	id = "sorium_explosion"
	required_reagents = list("mercury" = 1, "carbon" = 1, "nitrogen" = 1, "oxygen" = 1)
	result_amount = 1
	mix_message = "Смесь взрывается большим взрывом!"

/datum/chemical_reaction/sorium_explosion/on_reaction(datum/reagents/holder, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	if(!T)
		return
	goonchem_vortex(T, 0, created_volume)

/datum/chemical_reaction/sorium_explosion/sorium
	name = "Вихрь сория" // sorium_vortex
	id = "sorium_vortex"
	required_reagents = list("sorium" = 1)
	min_temp = T0C + 200
	mix_sound = null
	mix_message = null

/datum/chemical_reaction/liquid_dark_matter
	name = "Жидкая тёмная материя" // Liquid Dark Matter
	id = "liquid_dark_matter"
	result = "liquid_dark_matter"
	required_reagents = list("plasma" = 1, "radium" = 1, "carbon" = 1, "stabilizing_agent" = 1)
	result_amount = 4
	mix_message = "Смесь начинает светиться тёмно-фиолетовым цветом."

/datum/chemical_reaction/ldm_implosion
	name = "Имплозия" // Implosion
	id = "implosion"
	required_reagents = list("plasma" = 1, "radium" = 1, "carbon" = 1)
	result_amount = 1
	mix_message = "Смесь внезапно взрывается внутрь."

/datum/chemical_reaction/ldm_implosion/on_reaction(datum/reagents/holder, created_volume)
	var/turf/simulated/T = get_turf(holder.my_atom)
	if(!T)
		return
	goonchem_vortex(T, 1, created_volume)

/datum/chemical_reaction/ldm_implosion/liquid_dark_matter
	name = "Вихрь ЖТМ" // LDM Vortex
	id = "ldm_vortex"
	required_reagents = list("liquid_dark_matter" = 1)
	min_temp = T0C + 200
	mix_sound = null
	mix_message = null

/datum/chemical_reaction/blackpowder
	name = "Чёрный порох" // Black Powder
	id = "blackpowder"
	result = "blackpowder"
	required_reagents = list("saltpetre" = 1, "charcoal" = 1, "sulfur" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/fuse.ogg'

/datum/chemical_reaction/blackpowder_explosion
	name = "Чёрный порох Бабах" // Black Powder Kaboom
	id = "blackpowder_explosion"
	result = null
	required_reagents = list("blackpowder" = 1)
	result_amount = 1
	min_temp = T0C + 200
	mix_message = null
	mix_sound = null

/datum/chemical_reaction/blackpowder_explosion/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	do_sparks(2, 1, location)
	addtimer(CALLBACK(null, .proc/blackpowder_detonate, holder, created_volume), rand(5, 15))

/proc/blackpowder_detonate(datum/reagents/holder, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	var/ex_severe = round(created_volume / 100)
	var/ex_heavy = round(created_volume / 42)
	var/ex_light = round(created_volume / 20)
	var/ex_flash = round(created_volume / 8)
	explosion(T, ex_severe, ex_heavy,ex_light, ex_flash, 1)
	// If this black powder is in a decal, remove the decal, because it just exploded
	if(istype(holder.my_atom, /obj/effect/decal/cleanable/dirt/blackpowder))
		qdel(holder.my_atom)

/datum/chemical_reaction/flash_powder
	name = "Порох-вспышка" // Flash powder
	id = "flash_powder"
	result = "flash_powder"
	required_reagents = list("aluminum" = 1, "potassium" = 1, "sulfur" = 1, "chlorine" = 1, "stabilizing_agent" = 1)
	result_amount = 5
	mix_message = "Смесь немного свистит и шипит, прежде чем замереть."

/datum/chemical_reaction/flash
	name = "Вспышка" // Flash
	id = "flash"
	result = null
	required_reagents = list("aluminum" = 1, "potassium" = 1, "sulfur" = 1, "chlorine" = 1)
	mix_message = "Смесь бурно воспламеняется и ярко горит!"
	mix_sound = 'sound/effects/bang.ogg'

/datum/chemical_reaction/flash/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	if(!location)
		return
	do_sparks(2, 1, location)
	bang(location, holder.my_atom, 5, flash = TRUE, bang = FALSE)

/datum/chemical_reaction/flash/flash_powder
	name = "Вспышка порох-вспышки" // flash_powder_flash
	id = "flash_powder_flash"
	required_reagents = list("flash_powder" = 1)
	min_temp = T0C + 100
	mix_message = null

/datum/chemical_reaction/phlogiston
	name = "Флогистон" // Phlogiston
	id = "phlogiston"
	result = "phlogiston"
	required_reagents = list("phosphorus" = 1, "plasma" = 1, "sacid" = 1, "stabilizing_agent" = 1)
	result_amount = 4
	mix_message = "Вещество становится липким и очень горячим."

/datum/chemical_reaction/phlogiston_dust
	name = "Флогистоновая пыль" // Phlogiston Dust
	id = "phlogiston_dust"
	result = "phlogiston_dust"
	required_reagents = list("phlogiston" = 1, "charcoal" = 1, "phosphorus" = 1, "sulfur" = 1)
	result_amount = 2
	mix_message = "Смесь превращается в кучку горящей пыли."

/datum/chemical_reaction/phlogiston_fire //This MUST be above the smoke recipe.
	name = "Флогистоновый огонь" // Phlogiston Fire
	id = "phlogiston_fire"
	result = "phlogiston"
	required_reagents = list("phosphorus" = 1, "plasma" = 1, "sacid" = 1)
	mix_message = "Вещество вспыхивает диким огнём."

/datum/chemical_reaction/phlogiston_fire/on_reaction(datum/reagents/holder, created_volume)
	fire_flash_log(holder, id)
	fireflash(get_turf(holder.my_atom), min(max(2, round(created_volume / 10)), 8))

/datum/chemical_reaction/napalm
	name = "Напалм" // Napalm
	id = "napalm"
	result = "napalm"
	required_reagents = list("fuel" = 1, "sugar" = 1, "ethanol" = 1)
	result_amount = 3
	mix_message = "Смесь сгущается липким гелем."

/datum/chemical_reaction/smoke_powder
	name = "Дым-порошок" // smoke_powder
	id = "smoke_powder"
	result = "smoke_powder"
	required_reagents = list("potassium" = 1, "sugar" = 1, "phosphorus" = 1, "stabilizing_agent" = 1)
	result_amount = 3
	mix_message = "Смесь превращается в сероватый порошок!"

/datum/chemical_reaction/smoke
	name = "Дым" // smoke
	id = "smoke"
	result = null
	required_reagents = list("potassium" = 1, "sugar" = 1, "phosphorus" = 1)
	result_amount = 1
	mix_message = "Смесь быстро превращается в пелену дыма!"
	var/forbidden_reagents = list("sugar", "phosphorus", "potassium", "stimulants") //Do not transfer this stuff through smoke.

/datum/chemical_reaction/smoke/on_reaction(datum/reagents/holder, created_volume)
	for(var/f_reagent in forbidden_reagents)
		holder.del_reagent(f_reagent)
	var/location = get_turf(holder.my_atom)
	var/datum/effect_system/smoke_spread/chem/S = new
	playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
	if(S)
		S.set_up(holder, location)
		if(created_volume < 5)
			S.start(1)
		if(created_volume >=5 && created_volume < 10)
			S.start(2)
		if(created_volume >= 10 && created_volume < 15)
			S.start(3)
		if(created_volume >=15)
			S.start(4)

/datum/chemical_reaction/smoke/smoke_powder
	name = "Дым от дым-порошка" // smoke_powder_smoke
	id = "smoke_powder_smoke"
	required_reagents = list("smoke_powder" = 1)
	min_temp = T0C + 100
	result_amount = 1
	forbidden_reagents = list("stimulants")
	mix_sound = null

/datum/chemical_reaction/sonic_powder
	name = "Звуковой порошок" // sonic_powder
	id = "sonic_powder"
	result = "sonic_powder"
	required_reagents = list("oxygen" = 1, "cola" = 1, "phosphorus" = 1, "stabilizing_agent" = 1)
	result_amount = 2
	mix_message = "Смесь слегка пузырится."

/datum/chemical_reaction/sonic_deafen
	name = "Оглушающий звук" // sonic_deafen
	id = "sonic_deafen"
	result = null
	required_reagents = list("oxygen" = 1, "cola" = 1, "phosphorus" = 1)
	mix_message = "Смесь яростно пузырится!"
	mix_sound = 'sound/effects/bang.ogg'

/datum/chemical_reaction/sonic_deafen/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	if(!location)
		return
	bang(location, holder.my_atom, 5, flash = FALSE, bang = TRUE)

/datum/chemical_reaction/sonic_deafen/sonic_powder
	name = "Оглушение звуковым порошком" // sonic_powder_deafen
	id = "sonic_powder_deafen"
	required_reagents = list("sonic_powder" = 1)
	min_temp = T0C + 100
	mix_message = null

/datum/chemical_reaction/cryostylane
	name = "Криостилан" // cryostylane
	id = "cryostylane"
	result = "cryostylane"
	required_reagents = list("water" = 1, "plasma" = 1, "nitrogen" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/pyrosium
	name = "Пирозий" // pyrosium
	id = "pyrosium"
	result = "pyrosium"
	required_reagents = list("plasma" = 1, "radium" = 1, "phosphorus" = 1)
	result_amount = 3

/datum/chemical_reaction/azide
	name = "Азид" // azide
	id = "azide"
	result = null
	required_reagents = list("chlorine" = 1, "oxygen" = 1, "nitrogen" = 1, "ammonia" = 1, "sodium" = 1, "silver" = 1)
	result_amount = 1
	mix_message = "Смесь мощно детонирует!"
	mix_sound = 'sound/effects/bang.ogg'

/datum/chemical_reaction/azide/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	explosion(location, 0, 1, 4)

/datum/chemical_reaction/firefighting_foam
	name = "Пожарная пена" // firefighting_foam
	id = "firefighting_foam"
	result = "firefighting_foam"
	required_reagents = list("carbon" = 1, "chlorine" = 1, "sulfur" = 1)
	result_amount = 3
	mix_message = "Смесь мягко пузырится."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

// TODO: Пожарная пена + трёхфтористый хлор = clf3_firefighting??? Как это назвать?
/datum/chemical_reaction/clf3_firefighting
	name = "clf3_firefighting"
	id = "clf3_firefighting"
	result = null
	required_reagents = list("firefighting_foam" = 1, "clf3" = 1)
	result_amount = 1
	mix_message = "Смесь мощно детонирует!"
	mix_sound = 'sound/effects/bang.ogg'

/datum/chemical_reaction/clf3_firefighting/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	explosion(location, -1, 0, 2)

/datum/chemical_reaction/shock_explosion
	name = "Шоковый взрыв" // shock_explosion
	id = "shock_explosion"
	result = null
	required_reagents = list("teslium" = 5, "uranium" = 5) //uranium to this so it can't be spammed like no tomorrow without mining help.
	result_amount = 1
	mix_message = "<span class='danger'>Реакция создаёт электрический взрыв!</span>"
	mix_sound = 'sound/magic/lightningbolt.ogg'

/datum/chemical_reaction/shock_explosion/on_reaction(datum/reagents/holder, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	for(var/mob/living/L in view(min(8, round(created_volume * 2)), T))
		L.Beam(T, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 5) //What? Why are we beaming from the mob to the turf? Turf to mob generates really odd results.
		L.electrocute_act(3.5, "электрическим взрывом")
	holder.del_reagent("teslium") //Clear all remaining Teslium and Uranium, but leave all other reagents untouched.
	holder.del_reagent("uranium")

/datum/chemical_reaction/thermite
	name = "Термит" // Thermite
	id = "thermite"
	result = "thermite"
	required_reagents = list("aluminum" = 1, "iron" = 1, "oxygen" = 1)
	result_amount = 3
