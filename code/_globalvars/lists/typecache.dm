//please store common type caches here.
//type caches should only be stored here if used in mutiple places or likely to be used in mutiple places.

//Note: typecache can only replace istype if you know for sure the thing is at least a datum.

GLOBAL_LIST_INIT(typecache_mob, typecacheof(/mob))

GLOBAL_LIST_INIT(typecache_living, typecacheof(/mob/living))

GLOBAL_LIST_INIT(typecache_stack, typecacheof(/obj/item/stack))

GLOBAL_LIST_INIT(typecache_machine_or_structure, typecacheof(list(/obj/machinery, /obj/structure)))

GLOBAL_LIST_INIT(typecache_clothing, typecacheof(/obj/item/clothing))

GLOBAL_LIST_INIT(typecache_hostile, typecacheof(/mob/living/simple_animal/hostile))

GLOBAL_LIST_INIT(typecache_reagent, typecacheof(/datum/reagent))

GLOBAL_LIST_INIT(typecache_machinery, typecacheof(/obj/machinery))

GLOBAL_LIST_INIT(typecache_vending, typecacheof(/obj/machinery/vending))

GLOBAL_LIST_INIT(typecache_virus, typecacheof(/datum/disease/virus))
