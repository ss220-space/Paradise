/obj/item/stock_parts/cell/vox_spike
	name = "\improper vox spike power cell"
	desc = "Зарядная пурпурная светящаяся стандартная ячейка для шипометов."
	icon = 'icons/obj/weapons/ammo.dmi'
	icon_state = "spike_cell"

/obj/item/ammo_casing/energy/vox_spike
	name = "spike"
	desc = "Маленький самозаряжающийся кристаллический шип испускающий энергетический вайб."
	muzzle_flash_effect = null
	e_cost = 100
	delay = 3
	select_name = "spike"
	fire_sound = 'sound/weapons/gun_es4.ogg'
	projectile_type = /obj/projectile/bullet/vox_spike
	e_cost = 25

/obj/projectile/bullet/vox_spike
	name = "spike"
	desc = "Маленький самозаряжающийся кристаллический шип испускающий энергетический вайб."
	icon_state = "magspear"
	armour_penetration = 20
	damage = 7
	var/bleed_loss = 5

/obj/projectile/bullet/vox_spike/on_hit(atom/target, blocked = 0)
	if((blocked < 100) && ishuman(target))
		var/mob/living/carbon/human/human_target = target
		human_target.bleed(bleed_loss)
	return ..()

/obj/item/ammo_casing/energy/vox_spike/long
	projectile_type = /obj/projectile/bullet/vox_spike/long
	e_cost = 50

/obj/projectile/bullet/vox_spike/long
	damage = 5
	armour_penetration = 60
	jitter = 1 SECONDS
	forcedodge = 3
	bleed_loss = 3

/obj/item/ammo_casing/energy/vox_spike/big
	projectile_type = /obj/projectile/bullet/vox_spike/big
	e_cost = 80	// 1000 / (80*3) = 4 выстрела

/obj/projectile/bullet/vox_spike/big
	damage = 15
	stamina = 50
	stutter = 2 SECONDS
	jitter = 4 SECONDS
	speed = 2
	bleed_loss = 10

	tile_dropoff = 1	//how much damage should be decremented as the bullet moves
	tile_dropoff_s = 2.5	//same as above but for stamina

	ricochets_max = 3
	ricochet_chance = 50
