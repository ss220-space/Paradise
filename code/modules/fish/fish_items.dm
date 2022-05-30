
//////////////////////////////////////////////
//			Aquarium Supplies				//
//////////////////////////////////////////////

/obj/item/egg_scoop
	name = "fish egg scoop"
	desc = "A small scoop to collect fish eggs with."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "egg_scoop"
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7

/obj/item/fish_net
	name = "fish net"
	desc = "A tiny net to capture fish with. It's a death sentence!"
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "net"
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7

/obj/item/fish_net/suicide_act(mob/user)			//"A tiny net is a death sentence: it's a net and it's tiny!" https://www.youtube.com/watch?v=FCI9Y4VGCVw
	to_chat(viewers(user), "<span class='warning'>[user] places the [src.name] on top of [user.p_their()] head, [user.p_their()] fingers tangled in the netting! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return OXYLOSS

/obj/item/fishfood
	name = "fish food can"
	desc = "A small can of Carp's Choice brand fish flakes. The label shows a smiling Space Carp."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "fish_food"
	throwforce = 1
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7

/obj/item/tank_brush
	name = "aquarium brush"
	desc = "A brush for cleaning the inside of aquariums. Contains a built-in odor neutralizer."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "brush"
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	attack_verb = list("scrubbed", "brushed", "scraped")

/obj/item/tank_brush/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='warning'>[user] is vigorously scrubbing [user.p_them()]self raw with the [name]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return BRUTELOSS|FIRELOSS

/obj/item/storage/bag/fish
	name = "fish bag"
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "bag"
	storage_slots = 100
	max_combined_w_class = 100
	max_w_class = WEIGHT_CLASS_NORMAL
	w_class = WEIGHT_CLASS_TINY
	can_hold = list(
		/obj/item/fish,
		/obj/item/fish_eggs,
		/obj/item/reagent_containers/food/snacks/shrimp,
	)
	resistance_flags = FLAMMABLE

//////////////////////////////////////////////
//				Fish Items					//
//////////////////////////////////////////////

/obj/item/reagent_containers/food/snacks/shrimp
	name = "shrimp"
	desc = "A single raw shrimp."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "shrimp_raw"
	filling_color = "#FF1C1C"

/obj/item/reagent_containers/food/snacks/shrimp/New()
	..()
	desc = pick("Anyway, like I was sayin', shrimp is the fruit of the sea.", "You can barbecue it, boil it, broil it, bake it, saute it.")
	reagents.add_reagent("protein", 1)
	src.bitesize = 1

/obj/item/reagent_containers/food/snacks/feederfish
	name = "feeder fish"
	desc = "A tiny feeder fish. Sure doesn't look very filling..."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "feederfish"
	filling_color = "#FF1C1C"

/obj/item/reagent_containers/food/snacks/shrimp/New()
	..()
	reagents.add_reagent("protein", 1)
	src.bitesize = 1

/obj/item/fish
	name = "fish"
	desc = "a generic fish"
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "fish"
	throwforce = 1
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	force = 1
	attack_verb = list("slapped", "humiliated", "hit", "rubbed")
	hitsound = 'sound/effects/snap.ogg'
	var/size = 10
	var/sizemod
	var/adj
	var/noun
	var/unique_noun
	var/unique_desc
	var/icon/unique_underlay

/obj/item/fish/New()
	..()
	if(prob(75))
		size = rand(1, 30)
	if(prob(25))
		size = rand(25, 60)
	if(prob(10))
		size = rand(50, 80)
	if(prob(5))
		size = rand(75, 99)
	if(prob(1))
		size = 100
	transform *= TRANSFORM_USING_VARIABLE(size, 100) + 0.8
	sizemod = (round(size, 10)/10)
	if(sizemod == 1)	adj = "tiny"
	if(sizemod == 2)	adj = "small"
	if(sizemod == 3)	adj = "average"
	if(sizemod == 4)	adj = "overweight"
	if(sizemod == 5)	adj = "chonky"
	if(sizemod == 6)	adj = "obese"
	if(sizemod == 7)	adj = "huge"
	if(sizemod == 8)	adj = "enormous"
	if(sizemod == 9)	adj = "gigantic"
	if(sizemod == 10)	adj ="colossal"
	switch (size)
		if(1 to 40) w_class = WEIGHT_CLASS_NORMAL
		if(41 to 100) w_class = WEIGHT_CLASS_BULKY
		
	if(size == 100)
		sizemod = 20
		adj = ""
		alpha = 180
		noun = unique_noun
		desc = unique_desc
		unique_underlay = icon('icons/obj/rune.dmi', pick("main2", "main3", "main4", "main5", "shade1", "shade5", "shade6", "shade4"))
		unique_underlay.SwapColor("#000000", pick("#1dd82d15", "#2c18df13", "#ff06f313", "#0ddfe610"))
		underlays += unique_underlay
	name = "[adj] [noun]"

/obj/item/fish/glofish
	noun = "glofish"
	unique_noun = "Sunburst"
	desc = "A small bio-luminescent fish. Not very bright, but at least it's pretty!"
	unique_desc = "This shining monstrosity seem to be able to burn eyes even from far away"
	icon_state = "glofish"

/obj/item/fish/glofish/New()
	..()
	if(size == 100)
		set_light(15, 5,"#ffffff")
	else
		set_light(max(1, (sizemod/2)), max(1,(sizemod/5)),"#99FF66")

/obj/item/fish/electric_eel
	noun = "electric eel"
	unique_noun = "Abaia"
	desc = "An eel capable of producing a mild electric shock. Keep away from unprotected skin."
	unique_desc = "Looks like an oversized python if pythons were able to deep-fry you. You probably shouldn't pick it up."
	icon_state = "electric_eel"

/obj/item/fish/electric_eel/attack(mob/living/target, mob/living/user)
	..()
	target.apply_damage(sizemod, BURN)
	if(ishuman(target))
		target.adjustStaminaLoss(sizemod*2.5)
	if(prob(10+sizemod))
		user.apply_damage(sizemod, BURN)
		visible_message("[user] tries to swing [src] but it fights back!" )
	playsound(src, pick('sound/effects/sparks1.ogg', 'sound/effects/sparks2.ogg', 'sound/effects/sparks3.ogg', 'sound/effects/sparks4.ogg'), 100, 10)

/obj/item/fish/shark
	noun = "shark"
	unique_noun = "Bruce"
	desc = "Warning: Keep away from tornadoes."
	unique_desc = "Who's the dinner now?"
	icon_state = "shark"
	hitsound = 'sound/weapons/bite.ogg'
	force = 3

/obj/item/fish/shark/attackby(var/obj/item/weapon, var/mob/user)
	if(iswirecutter(weapon))
		to_chat(user, "You butcher \the [src.name]!")
		new /obj/item/shard/shark_teeth(get_turf(src))
		if(sizemod >= 5)
			new /obj/item/stack/sheet/bone(get_turf(src))
			new /obj/item/reagent_containers/food/snacks/meat(get_turf(src))
		if(size == 100)
			for(var/i = 1 to sizemod)
				new /obj/item/stack/sheet/bone(get_turf(src))
				new /obj/item/stack/sheet/leather(get_turf(src))
				new /obj/item/reagent_containers/food/snacks/meat(get_turf(src))
				new /obj/item/reagent_containers/food/snacks/meat(get_turf(src))
				new /obj/item/reagent_containers/food/snacks/meat(get_turf(src))
		qdel(src)
		return
	..()

/obj/item/shard/shark_teeth
	name = "shark teeth"
	desc = "A number of teeth, supposedly from a shark."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "teeth"
	force = 2.0
	throwforce = 5.0
	materials = list()

/obj/item/shard/shark_teeth/New()
	..()
	src.pixel_x = rand(-5,5)
	src.pixel_y = rand(-5,5)

/obj/item/fish/catfish
	noun = "catfish"
	unique_noun = "Namazu"
	desc = "Apparently, catfish don't purr like you might have expected them to. Such a confusing name!"
	unique_desc = "You quiver a bit as this creature gently flops around."
	icon_state = "catfish"

/obj/item/fish/catfish/attackby(var/obj/item/weapon, var/mob/user)
	if(!is_sharp(weapon))
		return ..()
		
	to_chat(user, "You carefully clean and gut \the [src.name].")
		for(var/i = 1 to sizemod)
			new /obj/item/reagent_containers/food/snacks/catfishmeat(get_turf(src))
		qdel(src)
		return
	..()

/obj/item/fish/catfish/throw_impact(atom/hit_atom)
	. = ..()
	if(size != 100)
		return
	playsound(src, 'sound/effects/meteorimpact.ogg', 50, 15)
	for(var/mob/M in range(10, src))
		if(!M.stat && !istype(M, /mob/living/silicon/ai))\
			shake_camera(M, 3, 1)

/obj/item/fish/catfish/attack(mob/living/target, mob/living/user)
	. = ..()
	if(size != 100)
		return
	playsound(src, 'sound/effects/meteorimpact.ogg', 50, 15)
	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
	target.throw_at(throw_target, 3, 5)
	shake_camera(user, 3, 1)
	shake_camera(target, 3, 1)

/obj/item/fish/goldfish
	noun = "goldfish"
	unique_noun = "Cleo"
	desc = "A goldfish, just like the one you never won at the county fair."
	unique_desc = "It's not too late to wish for something actually useful"
	icon_state = "goldfish"

/obj/item/fish/salmon
	noun = "salmon"
	unique_noun = "Mack"
	desc = "The second-favorite food of Space Bears, right behind crew members."
	unique_desc = "You can feed an entire fortress for year with it. Too bad you are in space"
	icon_state = "salmon"

/obj/item/fish/salmon/attackby(var/obj/item/O, var/mob/user as mob)
	if(!is_sharp(weapon))
		return ..()
		
	for(var/i = 1 to (sizemod*3))
		new /obj/item/reagent_containers/food/snacks/salmonmeat(get_turf(src))
	qdel(src)

/obj/item/fish/babycarp
	noun = "baby space carp"
	unique_noun = "Baz"
	desc = "Substantially smaller than the space carp lurking outside the hull, but still unsettling."
	unique_desc = "Owww, it's just adorable! You have fingers to spare anyway so..."
	icon_state = "babycarp"
	hitsound = 'sound/weapons/bite.ogg'
	force = 3

/obj/item/fish/babycarp/attackby(var/obj/item/O, var/mob/user as mob)
	if(is_sharp(O))
		to_chat(user, "You carefully clean and gut \the [src.name].")
		new /obj/item/reagent_containers/food/snacks/carpmeat(get_turf(src)) //just one fillet; this is a baby, afterall.
		qdel(src)
		return
	..()

/obj/item/fish/babycarp/Crossed(atom/movable/AM, oldloc)
	..()
	if(ismob(AM))
		var/mob/living/carbon/C = AM
		visible_message("[src] bites [C]!" )
		C.apply_damage(sizemod*2, BRUTE)
		playsound(src, 'sound/weapons/bite.ogg', 50, 15)
	if(istype(AM, /obj/item/fish))
		visible_message("[AM] is eaten by [src]!" )
		if(src.sizemod < 12)
			src.sizemod++
		playsound(src, 'sound/weapons/bite.ogg', 50, 15)
		qdel(AM)

/obj/item/fish/clownfish
	noun = "clown fish"
	unique_noun = "Honker"
	desc = "Even underwater, you cannot escape HONKing."
	unique_desc = "It looks nor funny, nor right. What's wrong with it?"
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "clownfish"
	throwforce = 1
	force = 1
	attack_verb = list("slapped", "humiliated", "hit", "rubbed")

/obj/item/fish/clownfish/ComponentInitialize()
	..()
	AddComponent(/datum/component/slippery, src, 2, 2, 100, 0, FALSE)

/obj/item/fish/clownfish/attackby(var/obj/item/O, var/mob/user as mob)
	if(is_sharp(O) && size == 100)
		to_chat(user, "You carefully clean and gut \the [src.name].")
		for(var/i = 1 to (sizemod/2))
			new /obj/item/reagent_containers/food/pill/patch/jestosterone(get_turf(src))
			new /obj/item/stack/ore/bananium(get_turf(src))
		qdel(src)
		return
	..()
