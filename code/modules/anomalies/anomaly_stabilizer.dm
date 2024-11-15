/obj/item/gun/energy/anomaly_stabilizer
	icon_state = "energy"
	name = "стабилизатор аномалий"
	ru_names = list(
		NOMINATIVE = "стабилизатор аномалий", \
		GENITIVE = "стабилизатора аномалий", \
		DATIVE = "стабилизатору аномалий", \
		ACCUSATIVE = "стабилизатор аномалий", \
		INSTRUMENTAL = "стабилизатором аномалий", \
		PREPOSITIONAL = "стабилизаторе аномалий"
	)
	desc = "Продвинутое устройство предназначенное для стабилизации аномалий. \
			Можно вставить до двух ядер аномалий, для улучшения."
	icon = 'icons/obj/weapons/energy.dmi'
	gun_light_overlay = "flight"
	can_add_sibyl_system = FALSE
	/// Cores inserted into this anomaly stabilizer.
	var/list/obj/item/assembly/signaler/anomaly/cores = list()
	/// Range of allowed stability deltas. If val - X, range is [-x; x].
	var/stability_range = 1
	/// The current value of the anomaly's stability change upon impact.
	var/stability_delta = 1
	/// Max allowed anomaly pull range.
	var/pull_range = 0
	/// Choosen anomaly pull distance.
	var/choosen_pull_dist = 0
	/// Choosen time on which beams block anomaly's normal movements.
	var/block_move_time = 0
	/// Choosen time on which beams block anomaly's impulsive movements.
	var/block_move_impulses_time = 0
	/// The amount by which the strength of the anomaly's effects is temporarily reduced.
	var/weaken_val = 0
	/// The moment at which the reduction in the effects of the anomaly will be reset.
	var/weaken_time = 0

/obj/item/gun/energy/anomaly_stabilizer/attack_self(mob/living/user)
	ui_interact(user)


/obj/item/gun/energy/anomaly_stabilizer/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Anomaly_Stabilizer", "Стабилизатор аномалий")
		ui.set_autoupdate(TRUE)
		ui.open()


/obj/item/gun/energy/anomaly_stabilizer/newshot()
	if(!ammo_type || !cell)
		return

	var/obj/item/ammo_casing/energy/anomaly/shot = ammo_type[select]
	if(cell.charge < shot.e_cost)
		return

	chambered = shot //...prepare a new shot based on the current ammo type selected
	if(!chambered.BB)
		chambered.newshot()

	var/obj/item/ammo_casing/energy/anomaly/en_chambered = chambered
	en_chambered.e_cost *= stability_delta * stability_delta

	var/obj/item/projectile/beam/anomaly/BB = chambered.BB
	BB.stability_delta = stability_delta
	BB.pull_strenght = choosen_pull_dist
	BB.move_block = block_move_time
	BB.move_impulces_block = block_move_impulses_time
	BB.anom_weaken = weaken_val
	BB.weaken_time = weaken_time

/obj/item/gun/energy/anomaly_stabilizer/proc/update_stability_delta(mob/user, new_val)
	new_val = clamp(new_val, -stability_range, stability_range)
	stability_delta = new_val

	if(new_val < 0)
		ammo_type = list(/obj/item/ammo_casing/energy/anomaly/stabilizer)
	else if(new_val > 0)
		ammo_type = list(/obj/item/ammo_casing/energy/anomaly/destabilizer)
	else
		ammo_type = list(/obj/item/ammo_casing/energy/anomaly)


/obj/item/gun/energy/anomaly_stabilizer/proc/eject_core(index)
	if(ishuman(loc))
		var/mob/living/carbon/human/user = loc
		user.put_in_hands(cores[index])
	else
		cores[index].forceMove(get_turf(src))

	cores.Remove(cores[index])
	update_cores()


/obj/item/gun/energy/anomaly_stabilizer/proc/insert_core(obj/item/assembly/signaler/anomaly/core, mob/user)
	if(iscoreempty(core))
		user.balloon_alert("ядро пусто")
		return ATTACK_CHAIN_PROCEED

	if(!user.drop_transfer_item_to_loc(core, src))
		user.balloon_alert("не отпустить")
		return ATTACK_CHAIN_PROCEED

	if(cores.len >= 2)
		balloon_alert(user, "нет места")
		return ATTACK_CHAIN_PROCEED

	cores.Add(core)
	update_cores()
	balloon_alert(user, "ядро вставлено")
	return ATTACK_CHAIN_PROCEED

/obj/item/gun/energy/anomaly_stabilizer/proc/update_cores()
	var/strenght_energetic = 0
	var/strenght_atmospheric = 0
	var/strenght_bluespace = 0
	var/strenght_vortex = 0
	var/strenght_gravitation = 0
	for(var/obj/item/assembly/signaler/anomaly/core in cores)
		var/strenght = core.get_strenght()
		if(iscoreflux(core))
			strenght_energetic += strenght

		if(iscoreatmos(core))
			strenght_atmospheric += strenght

		if(iscorebluespace(core))
			strenght_bluespace += strenght

		if(iscorevortex(core))
			strenght_vortex += strenght

		if(iscoregrav(core))
			strenght_gravitation += strenght

	stability_range = 1 + round(strenght_energetic / 50)
	stability_delta = clamp(stability_delta, -stability_range, stability_range)

	pull_range = strenght_gravitation / 50
	choosen_pull_dist = clamp(choosen_pull_dist, -pull_range, pull_range)

	block_move_time = strenght_vortex / 100

	block_move_impulses_time = strenght_bluespace / 100

	weaken_val = strenght_atmospheric / 3
	weaken_time = strenght_atmospheric / 50

	newshot()

/obj/item/gun/energy/anomaly_stabilizer/attackby(obj/item/I, mob/user, params)
	if(user.intent == INTENT_HARM)
		return ..()

	if(!iscore(I))
		return ..()

	insert_core(I, user)
	return ATTACK_CHAIN_PROCEED
