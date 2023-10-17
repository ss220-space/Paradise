/**
 * Here lie special thunderdome items.
 * Absurdly strong or weak bundles included.
 */
/obj/item/storage/box/thunderdome
	name = "Uncle Trasen's special gift"
	desc = "You'll never know, what's inside."

/obj/item/storage/box/thunderdome/mr_chang_technique/populate_contents()
	new /obj/item/mr_chang_technique(src)
	new /obj/item/clothing/suit/mr_chang_coat(src)
	new /obj/item/clothing/shoes/mr_chang_sandals(src)
	new /obj/item/clothing/head/mr_chang_band(src)
	var/obj/item/stack/spacecash/cash = new(src)
	cash.amount = 50000
	for(var/i = 0, i < 10, i++)
		new /obj/item/coin/silver(src)

/obj/item/storage/box/thunderdome/mr_chang_technique/spicy/populate_contents()
	new /obj/item/mr_chang_technique(src)
	new /obj/item/clothing/suit/mr_chang_coat(src)
	new /obj/item/clothing/shoes/mr_chang_sandals(src)
	new /obj/item/clothing/head/mr_chang_band(src)
	new /obj/item/melee/energy/axe(src)

/obj/item/storage/box/thunderdome/bombarda/populate_contents()
	new /obj/item/gun/projectile/bombarda(src)
	for(var/i = 0, i < 3, i++)
		new /obj/item/ammo_casing/grenade/improvised/smoke_shell(src)
		new /obj/item/ammo_casing/grenade/improvised/flame_shell(src)
		new /obj/item/ammo_casing/grenade/improvised/exp_shell(src)

/obj/item/storage/box/thunderdome/crossbow/populate_contents()
	var/obj/item/gun/throw/crossbow/cbow = new(src)
	cbow.cell = new /obj/item/stock_parts/cell/infinite(cbow)
	new /obj/item/weldingtool(src)
	new /obj/item/arrow/rod/fire(src)
	new /obj/item/arrow/rod/fire(src)
	new /obj/item/arrow/rod/fire(src)
	new /obj/item/arrow/rod(src)
	new /obj/item/arrow/rod(src)
	new /obj/item/arrow/rod(src)
	new /obj/item/arrow/rod(src)

/obj/item/storage/box/thunderdome/crossbow/energy/populate_contents()
	new /obj/item/gun/energy/kinetic_accelerator/crossbow(src)
	new /obj/item/reagent_containers/hypospray/ertm/pentic_acid(src)

/obj/item/storage/box/thunderdome/spears/populate_contents()
	new /obj/item/twohanded/spear(src)
	new /obj/item/twohanded/spear(src)
	new /obj/item/twohanded/spear(src)
	new /obj/item/restraints/legcuffs/bola/energy(src)

/obj/item/storage/box/thunderdome/laser_eyes/populate_contents()
	new /obj/item/clothing/glasses/sunglasses/lasers(src)

/obj/item/storage/box/thunderdome/maga/populate_contents()
	new /obj/item/clothing/gloves/color/black/krav_maga/sec(src)
	new /obj/item/reagent_containers/hypospray/ertm/perfluorodecalin(src)

/**
 * Oh god.
 */
/obj/item/storage/box/thunderdome/gbs/populate_contents()
	new /obj/item/reagent_containers/glass/bottle/gbs(src)

/obj/item/storage/box/thunderdome/singulatiry/populate_contents()
	new /obj/item/twohanded/singularityhammer(src)
	new /obj/item/implanter/adrenalin(src)
