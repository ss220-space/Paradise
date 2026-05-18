/obj/item/gun/throw/biogun
	name = "biogun"
	desc = "Метатель живых био-ядер."
	icon = 'icons/obj/weapons/vox_guns.dmi'
	icon_state = "biogun"
	item_state = "spike_long"
	w_class = WEIGHT_CLASS_HUGE
	max_capacity = 3
	projectile_speed = 2
	projectile_range = 30
	valid_projectile_type = /obj/item/biocore
	restricted_species = list(/datum/species/vox)
	var/inhand_charge_sections = 3

/obj/item/gun/throw/biogun/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/item/gun/throw/biogun/process_chamber()
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/item/gun/throw/biogun/update_icon_state()
	var/num = length(loaded_projectiles) + (to_launch ? 1 : 0)
	var/inhand_ratio = (num / max_capacity) * inhand_charge_sections
	var/new_item_state = "[initial(item_state)][inhand_ratio]"
	item_state = new_item_state

/obj/item/gun/throw/biogun/update_overlays()
	. = ..()
	var/num = length(loaded_projectiles) + (to_launch ? 1 : 0)
	if(!num)
		return

	num = min(num, max_capacity)
	. += "[icon_state]_charge[num]"

/obj/item/gun/throw/biogun/notify_ammo_count()
	update_appearance(UPDATE_ICON)
	var/amount = get_ammocount()
	if(get_ammocount() >= 1)
		return span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] заряжен [amount]/[max_capacity].")
	return span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] разряжен.")

/mob/living/simple_animal/hostile/viscerator/vox
	name = "vox viscerator"
	icon_state = "viscerator_vox_attack"
	icon_living = "viscerator_vox_attack"
	faction = list("Vox")
	//mob_biotypes = MOB_ROBOTIC
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = -1, CLONE = -1, STAMINA = 0, OXY = 0)
	fire_damage = 1
	unsuitable_atmos_damage = 0
	flying = FALSE
	melee_damage_lower = 10

/mob/living/simple_animal/hostile/viscerator/vox/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE

/mob/living/simple_animal/hostile/viscerator/vox/stamina
	name = "stakikamka"
	desc = "Небольшое биомеханическое проворное существо на высоких ножках, мешающее и изматывающее тех, кому оно не понравилось."
	icon_state = "stamina"
	icon_living = "stamina"
	density = FALSE
	speed = 0.25
	melee_damage_type = STAMINA
	melee_damage_lower = 5
	melee_damage_upper = 20
	attacktext = "утомляет"

/mob/living/simple_animal/hostile/viscerator/vox/stamina/death(gibbed)
	if(prob(30))
		xgibs(loc)
	return ..()

/mob/living/simple_animal/hostile/viscerator/vox/acid
	name = "acikikid"
	desc = "Небольшое биомеханическое крабоподобное существо из пасти которого стекает кислота, которую тот наматывает на свои маленькие острые клешни."
	icon_state = "acid"
	icon_living = "acid"
	health = 50
	maxHealth = 50
	obj_damage = 20
	melee_damage_type = BURN
	melee_damage_upper = 30
	attacktext = "выжигает"
	mob_size = MOB_SIZE_SMALL

/mob/living/simple_animal/hostile/viscerator/vox/acid/death(gibbed)
	xgibs(loc)
	return ..()

/mob/living/simple_animal/hostile/viscerator/vox/kusaka
	name = "kusakika"
	desc = "Маленькое биомеханическое существо с острыми клыкам с половину его тела."
	icon_state = "kusaka"
	icon_living = "kusaka"
	density = FALSE
	speed = 0.5
	melee_damage_lower = 5
	melee_damage_upper = 10
	armour_penetration = 30
	attacktext = "кусает"

/mob/living/simple_animal/hostile/viscerator/vox/kusaka/death(gibbed)
	if(prob(20))
		robogibs(loc)
	return ..()

/mob/living/simple_animal/hostile/viscerator/vox/taran
	name = "tarakikan"
	desc = "Весомое пластинчатое биомеханическое существо."
	icon_state = "taran"
	icon_living = "taran"
	speed = 2
	health = 100
	maxHealth = 100
	obj_damage = 50
	melee_damage_upper = 20
	armour_penetration = 20
	attacktext = "таранит"
	mob_size = MOB_SIZE_HUMAN

/mob/living/simple_animal/hostile/viscerator/vox/taran/death(gibbed)
	robogibs(loc)
	return ..()

/mob/living/simple_animal/hostile/viscerator/vox/tox
	name = "toxikikic"
	desc = "Маленькое биомеханическое иглоподобное существо."
	icon_state = "tox"
	icon_living = "tox"
	density = FALSE
	melee_damage_type = TOX
	melee_damage_lower = 5
	armour_penetration = 80
	attacktext = "вонзается"

/mob/living/simple_animal/hostile/viscerator/vox/tox/death(gibbed)
	xgibs(loc)
	return ..()
