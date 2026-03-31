// MARK: Generic
/obj/projectile/terrorspider
	name = "basic"
	damage = 0
	icon_state = "toxin"
	damage_type = TOX

/obj/projectile/terrorspider/widow
	name = "widow venom"
	icon_state = "toxin5"
	damage = 15
	stamina = 24

// MARK: Widow - Venom
/obj/projectile/terrorspider/widow/venom
	name = "venom acid"
	damage = 5

/obj/projectile/terrorspider/widow/venom/on_hit(target)
	. = ..()
	var/datum/effect_system/fluid_spread/smoke/chem/smoke = new
	var/turf/T = get_turf(target)
	create_reagents(1250)
	reagents.add_reagent("thc", 250)
	reagents.add_reagent("psilocybin", 250)
	reagents.add_reagent("lsd", 250)
	reagents.add_reagent("space_drugs", 250)
	reagents.add_reagent("terror_black_toxin", 250)
	smoke.set_up(range = 2, location = T, carry = reagents, silent = TRUE)
	smoke.start()

	return ..()

// MARK: Widow - Smoke
/obj/projectile/terrorspider/widow/smoke
	name = "smoke acid"
	damage = 5

/obj/projectile/terrorspider/widow/smoke/on_hit(target)
	. = ..()
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	var/turf/T = get_turf(target)
	smoke.set_up(amount = 15, location = T)
	smoke.start()
	return ..()

// MARK: Queen
/obj/projectile/terrorspider/queen
	name = "queen venom"
	icon_state = "toxin3"
	damage = 40
	stamina = 40
	damage_type = BURN

// MARK: Princess
/obj/projectile/terrorspider/princess
	name = "princess venom"
	icon_state = "toxin4"
	damage = 25
	stamina = 25
	damage_type = BURN

// MARK: Empress
/obj/projectile/terrorspider/empress
	name = "empress venom"
	icon_state = "toxin5"
	damage = 90
	damage_type = BRUTE

// MARK: Builder
/obj/projectile/terrorspider/builder
	name = "drone venom"
	icon_state = "toxin2"
	damage = 15
	stamina = 15
