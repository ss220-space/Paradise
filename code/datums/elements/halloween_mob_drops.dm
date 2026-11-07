/datum/element/halloween_mob_drop
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH_ON_HOST_DESTROY
	argument_hash_start_idx = 2
	/// mob uids that already dropped their loot
	var/list/mob_uids = list()
	/// its 100 in sum, zuzya add ideas what to add
	var/list/loot = list(
		/obj/item/necromantic_stone = 1,
		/obj/item/melee/ghost_sword = 1,
		/obj/item/clothing/suit/hooded/fluff/bone = 8,
		/obj/item/instrument/trumpet/spectral = 5,
		/obj/item/wisp_lantern = 5,
		/obj/item/reagent_containers/food/snacks/ectoplasm = 30,
		/obj/item/reagent_containers/food/snacks/grown/pumpkin = 30,
		/obj/item/stack/sheet/bone = 20,
	)

/datum/element/halloween_mob_drop/Attach(mob/living/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(drop_loot))

/datum/element/halloween_mob_drop/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_LIVING_DEATH)

/datum/element/halloween_mob_drop/proc/drop_loot(mob/living/target, gibbed)
	SIGNAL_HANDLER

	var/mob_uid = target.UID()
	if(mob_uids[mob_uid])
		return

	mob_uids[mob_uid] = TRUE
	var/loot_type = pickweight(loot)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return

	new loot_type(target_turf)

