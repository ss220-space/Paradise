/mob/living/simple_animal/hostile/ghost/halloween
	name = "maintenance ghost"
	desc = "Злобный дух ассистента, умершего от решётки под напряжением."

/mob/living/simple_animal/hostile/skeleton/halloween
	name = "maintenance skeleton"
	desc = "Кажется, он остался тут с прошлой смены."

/mob/living/simple_animal/hostile/zombie/halloween
	name = "maintenance zombie"
	desc = "Почему он зелёный? По отличной причине!"

/mob/living/simple_animal/hostile/ghost/halloween/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/halloween_mob_drop)

/mob/living/simple_animal/hostile/skeleton/halloween/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/halloween_mob_drop)

/mob/living/simple_animal/hostile/zombie/halloween/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/halloween_mob_drop)
