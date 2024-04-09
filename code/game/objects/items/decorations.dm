/obj/item/decorations
	icon = 'icons/obj/decorations.dmi'


//duct tape decorations
/obj/item/decorations/sticky_decorations
	w_class = WEIGHT_CLASS_TINY

/obj/item/decorations/sticky_decorations/New()
	. = ..()
	AddComponent(/datum/component/ducttape, src, null, 0, 0, TRUE)//add this to something to make it sticky but without the tape overlay



/obj/item/decorations/sticky_decorations/flammable
	resistance_flags = FLAMMABLE


//Non-holiday decorations

/obj/item/decorations/sticky_decorations/flammable/heart
	name = "paper heart"
	desc = "Do not break."
	icon_state = "decoration_heart"

/obj/item/decorations/sticky_decorations/flammable/star
	name = "paper star"
	desc = "Throw it and make a wish!"
	icon_state = "decoration_star"

/obj/item/decorations/sticky_decorations/flammable/singleeye
	name = "paper eye"
	desc = "Feels like it stares into your soul."
	icon_state = "paper_eye"

/obj/item/decorations/sticky_decorations/flammable/googlyeyes
	name = "paper googly eyes"
	desc = "Seems to be looking at something with interest."
	icon_state = "paper_googly_eyes"

/obj/item/decorations/sticky_decorations/flammable/paperclock
	name = "paper clock"
	desc = "A paper clock. Right at least twice a day."
	icon_state = "paper_clock"


/obj/item/decorations/flag/soviet
	name = "An old Soviet flag"
	desc = "Archaic flag, remembres to it owner past times."
	icon_state = "sov_flag"
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_SMALL

//Holiday decorations

//Halloween decorations

/obj/item/decorations/sticky_decorations/flammable/jack_o_lantern
	name = "paper jack o'lantern"
	desc = "A paper jack o'lantern. Although you can't put a candle in him he has a fun loving smile none the less!"
	icon_state = "decoration_jack_o_lantern"

/obj/item/decorations/sticky_decorations/flammable/ghost
	name = "paper ghost"
	desc = "A paper ghost. If it starts moving on its own, you know who to call."
	icon_state = "decoration_ghost"

/obj/item/decorations/sticky_decorations/flammable/spider
	name = "paper spider"
	desc = "A paper spider. Creepy but not venomous, thankfully."
	icon_state = "decoration_spider"

/obj/item/decorations/sticky_decorations/flammable/spiderweb
	name = "paper spiderweb"
	desc = "A paper spiderweb. You see someone wrote 'For Rent' on it."
	icon_state = "decoration_spider_web"

/obj/item/decorations/sticky_decorations/flammable/skull
	name = "paper skull"
	desc = "A paper skull. Seems a paper skeleton lost their head!"
	icon_state = "decoration_skull"

/obj/item/decorations/sticky_decorations/flammable/skeleton
	name = "paper skeleton"
	desc = "A paper skeleton. Instead of rattling, his bones rustle."
	icon_state = "decoration_skeleton"

/obj/item/decorations/sticky_decorations/flammable/cauldron
	name = "paper cauldron"
	desc = "A paper cauldron. Careful, a paper witch might be about."
	icon_state = "paper_cauldron"

//Christmas decorations

/obj/item/decorations/sticky_decorations/flammable/snowman
	name = "paper snowman"
	desc = "A paper snowman. This one won't melt when it gets warm."
	icon_state = "decoration_snowman"

/obj/item/decorations/sticky_decorations/flammable/christmas_stocking
	name = "paper stocking"
	desc = "A paper Christmas stocking. Sadly you won't find gifts in it but at least you won't find coal either."
	icon_state = "decoration_christmas_stocking"

/obj/item/decorations/sticky_decorations/flammable/christmas_tree
	name = "paper christmas tree"
	desc = "A paper Christmas tree. Maybe someone will leave a present under it?"
	icon_state = "decoration_christmas_tree"

/obj/item/decorations/sticky_decorations/flammable/snowflake
	name = "paper snowflake"
	desc = "A paper snowflake. Imagine if snow was this big!"
	icon_state = "decoration_snowflake"

/obj/item/decorations/sticky_decorations/flammable/candy_cane
	name = "paper candy cane"
	desc = "A paper candy cane. Sadly, non-edible."
	icon_state = "decoration_candy_cane"

/obj/item/decorations/sticky_decorations/flammable/mistletoe
	name = "paper mistletoe"
	desc = "Paper mistletoe. If you stand next to this, expect to be kissed."
	icon_state = "decoration_mistletoe"

/obj/item/decorations/sticky_decorations/flammable/holly
	name = "paper holly"
	desc = "Paper holly. Wait is it the red berries or the white ones you kiss under?"
	icon_state = "decoration_holly"

//Tinsel

/obj/item/decorations/sticky_decorations/flammable/tinsel
	name = "paper tinsel"
	desc = "Paper tinsel, because Nanotrasen is too cheap to buy the real deal."
	icon_state = "decoration_tinsel_white"

/obj/item/decorations/sticky_decorations/flammable/tinsel/red
	icon_state = "decoration_tinsel_red"

/obj/item/decorations/sticky_decorations/flammable/tinsel/blue
	icon_state = "decoration_tinsel_blue"

/obj/item/decorations/sticky_decorations/flammable/tinsel/yellow
	icon_state = "decoration_tinsel_yellow"

/obj/item/decorations/sticky_decorations/flammable/tinsel/purple
	icon_state = "decoration_tinsel_purple"

/obj/item/decorations/sticky_decorations/flammable/tinsel/green
	icon_state = "decoration_tinsel_green"

/obj/item/decorations/sticky_decorations/flammable/tinsel/orange
	icon_state = "decoration_tinsel_orange"

/obj/item/decorations/sticky_decorations/flammable/tinsel/black
	icon_state = "decoration_tinsel_black"

/obj/item/decorations/sticky_decorations/flammable/tinsel/halloween
	desc = "Paper tinsel, because Nanotrasen is too cheap to buy the real deal. At least this one is spooky."
	icon_state = "decoration_tinsel_halloween"

//Valentines decorations



/obj/item/decorations/sticky_decorations/flammable/arrowed_heart
	name = "paper heart"
	desc = "A paper heart. It's been shot through and Cupid is to blame!"
	icon_state = "decoration_arrow_heart"

/obj/item/decorations/sticky_decorations/flammable/heart_chain
	name = "paper heart chain"
	desc = "A paper chain of hearts. May our hearts always be together."
	icon_state = "decoration_heart_chain"

//St. Patrick's day

/obj/item/decorations/sticky_decorations/flammable/four_leaf_clover
	name = "paper four leaf clover"
	desc = "A paper four leaf clover. Take it with you, it might bring good luck!"
	icon_state = "decoration_four_leaf_clover"

/obj/item/decorations/sticky_decorations/flammable/pot_of_gold
	name = "paper pot of gold"
	desc = "A paper pot of gold. You found the end of the paper rainbow!"
	icon_state = "decoration_pot_o_gold"

/obj/item/decorations/sticky_decorations/flammable/leprechaun_hat
	name = "paper leprechaun hat"
	desc = "A paper leprechaun hat. If you find the paper leprechaun that dropped this they might give you their pot of paper gold!"
	icon_state = "decoration_leprechaun_hat"

//Easter

/obj/item/decorations/sticky_decorations/flammable/easter_bunny
	name = "paper Easter bunny"
	desc = "A paper Easter bunny. Help him find his lost eggs!"
	icon_state = "decoration_easter_bunny"

/obj/item/decorations/sticky_decorations/flammable/easter_egg
	name = "paper Easter egg"
	desc = "A paper Easter egg. If the chef won't let us use their eggs, then this will have to do."
	icon_state = "decoration_easter_egg_blue"

/obj/item/decorations/sticky_decorations/flammable/easter_egg/yellow
	icon_state = "decoration_easter_egg_yellow"

/obj/item/decorations/sticky_decorations/flammable/easter_egg/red
	icon_state = "decoration_easter_egg_red"

/obj/item/decorations/sticky_decorations/flammable/easter_egg/purple
	icon_state = "decoration_easter_egg_purple"

/obj/item/decorations/sticky_decorations/flammable/easter_egg/orange
	icon_state = "decoration_easter_egg_orange"




///////
//Decorative structures
///////


/obj/structure/decorative_structures
	icon = 'icons/obj/decorations.dmi'
	icon_state = ""
	density = 1
	anchored = FALSE
	max_integrity = 100

/obj/structure/decorative_structures/fireplace
	name = "Old fireplace"
	desc = "Looks warm and comfy."
	icon = 'icons/obj/fireplace.dmi'
	icon_state = "fireplace"
	anchored = TRUE
	density = 0
	pixel_x = -16

/obj/structure/decorative_structures/fireplace/Initialize(mapload)
	. = ..()
	add_overlay(icon('icons/obj/fireplace.dmi', "fireplace_fire3"))
	add_overlay(icon('icons/obj/fireplace.dmi', "fireplace_glow"))
	set_light(6, ,"#ffb366")

/obj/structure/decorative_structures/garland
	density = 0
	anchored = TRUE
	max_integrity = 100
	icon_state = "xmaslights"

/obj/structure/decorative_structures/garland/Initialize(mapload)
	. = ..()
	set_light(2, ,"#ffffffbb")

/obj/structure/decorative_structures/metal
	flags = CONDUCT

/obj/structure/decorative_structures/metal/statue/metal_angel
	name = "metal angel statue"
	desc = "You feel a holy presence looking back at you."
	icon_state = "metal_angel_statue"

/obj/structure/decorative_structures/metal/statue/golden_disk
	name = "golden disk statue"
	desc = "You aren't sure what the runes say around the large plasma crystal."
	icon_state = "golden_disk_statue"

/obj/structure/decorative_structures/metal/statue/sun
	name = "sun statue"
	desc = "You wonder if you could be so grossly incandescent."
	icon_state = "sun_statue"

/obj/structure/decorative_structures/metal/statue/tesla
	name = "tesla statue"
	desc = "Lady Tesla, a powerful and dangerous mistress."
	icon_state = "tesla_statue"

/obj/structure/decorative_structures/metal/statue/moon
	name = "moon statue"
	desc = "Expect a lot of Vulps to howl around this thing."
	icon_state = "moon_statue"

/obj/structure/decorative_structures/metal/statue/tesla_monument
	name = "tesla monument"
	desc = "Praise be to lady Tesla!"
	icon_state = "tesla_monument"

/obj/structure/decorative_structures/metal/repeater
	name = "broken machine"
	desc = "Похоже именно этот аппарат и создаёт помехи. Он безвозвратно сломан."
	icon = 'icons/obj/machines/repeater.dmi'
	icon_state = "repeater-broken"
	anchored = TRUE
	max_integrity = 200


/obj/structure/decorative_structures/flammable
	resistance_flags = FLAMMABLE
	max_integrity = 50


/obj/structure/decorative_structures/flammable/grandfather_clock
	name = "grandfather clock"
	desc = "Seems the hands have stopped."
	icon_state = "grandfather_clock"

/obj/structure/decorative_structures/flammable/lava_land_display
	name = "lava land display"
	desc = "The tomb of many a miner and possibly a home for much worse things."
	icon_state = "lava_land_display"



///////
//Decorative corpses
///////


/obj/structure/decorative_structures/corpse
	name = "Bloody body"
	icon_state = "deadbody2"
	density = 0
	max_integrity = 5
	/// number of tiles with blood while pulling
	var/bloodtiles = 8
	/// special checker type for virus dead_corpse_structure/Crossed
	var/field_checker_type = /obj/effect/abstract/proximity_checker/dead_corpse_structure/cadaver

/obj/structure/decorative_structures/corpse/Initialize()
	. = ..()
	AddComponent(/datum/component/proximity_monitor/dead_corpse_structure, _radius = 4, field_checker_type = src.field_checker_type)

/obj/structure/decorative_structures/corpse/Destroy()
	playsound(src, 'sound/goonstation/effects/gib.ogg', 30, 0)
	var/turf/T = get_turf(src)
	new /obj/effect/particle_effect/smoke/vomiting(T)
	new /obj/item/reagent_containers/food/snacks/monstermeat/rotten/jumping(T)
	new /obj/item/reagent_containers/food/snacks/monstermeat/rotten/jumping(T)
	new /obj/item/reagent_containers/food/snacks/monstermeat/rotten/jumping(T)
	new /obj/effect/decal/cleanable/blood/gibs(T)
	new /obj/effect/decal/cleanable/blood(T)
	..()

/obj/structure/decorative_structures/corpse/attack_hand(mob/living/user)
	take_damage(pick(2,3), BRUTE, "melee")
	playsound(src, (pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')), 20, 0)
	user.visible_message("<span class='danger'>You punched something viscous! You hear a slimy sound.</span>")

/obj/structure/decorative_structures/corpse/play_attack_sound()
	return

/obj/structure/decorative_structures/corpse/climb_on()
	return

/obj/structure/decorative_structures/corpse/Move()
	. = ..()
	bloodtiles -= 1
	if(bloodtiles >= 0 && prob(40))
		new /obj/effect/decal/cleanable/blood(get_turf(src))

/datum/component/proximity_monitor/dead_corpse_structure
	field_checker_type = /obj/effect/abstract/proximity_checker/dead_corpse_structure

/datum/component/proximity_monitor/dead_corpse_structure/Initialize(_radius, _always_active, field_checker_type)
	if(!ispath(field_checker_type, /obj/effect/abstract/proximity_checker/dead_corpse_structure))
		return COMPONENT_INCOMPATIBLE
	src.field_checker_type = field_checker_type
	. = ..()

/obj/effect/abstract/proximity_checker/dead_corpse_structure
	var/virus_type = /datum/disease/virus/cadaver

/obj/effect/abstract/proximity_checker/dead_corpse_structure/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(!ishuman(AM))
		return
	var/mob/living/carbon/human/cross_human = AM
	if(prob(5))
		var/obj/item/clothing/mask/M = cross_human.wear_mask
		if(M && (M.flags_cover & MASKCOVERSMOUTH))
			return
		if(NO_BREATHE in cross_human.dna.species.species_traits)
			return //no puking if you can't smell!
		to_chat(cross_human, span_warning("You smell something foul..."))
		cross_human.fakevomit()
		return

	if(prob(1))
		var/datum/disease/virus/D = new virus_type()
		D.Contract(cross_human, CONTACT|AIRBORNE, need_protection_check = TRUE)

/obj/effect/abstract/proximity_checker/dead_corpse_structure/cadaver
	virus_type = /datum/disease/virus/cadaver

///// jumping meat for body explotion effect

/obj/item/reagent_containers/food/snacks/monstermeat/rotten/jumping/Initialize(var/turf/T)
	T = get_offset_target_turf(src.loc, rand(2)-rand(2), rand(2)-rand(2))
	src.throw_at(T, 2, 1)
	..()

///// vomit cause gas
/obj/effect/particle_effect/smoke/vomiting
	color = "#752424"
	lifetime = 3

/obj/effect/particle_effect/smoke/vomiting/process()
	if(..())
		for(var/mob/living/carbon/M in range(2,src))
			smoke_mob(M)

/obj/effect/particle_effect/smoke/vomiting/smoke_mob(mob/living/carbon/carbon_mob)
	. = ..()
	if(!.)
		return
	carbon_mob.drop_from_active_hand()
	carbon_mob.vomit()
	carbon_mob.emote("cough")
	return TRUE

/datum/effect_system/smoke_spread/vomiting
	effect_type = /obj/effect/particle_effect/smoke/vomiting

////// Bouquets

/obj/item/decorations/bouquets
	name = "Flower bouquet"
	desc = "A bouquet of beautiful flowers, looks a little withered."
	icon = 'icons/obj/weapons/bouquet.dmi'
	icon_state = "mixedbouquet"
	attack_verb = list("attacked", "slashed", "torn", "ripped", "cut", "smashed")
	max_integrity = 20
	force = 2
	throwforce = 1
	throw_range = 3

	resistance_flags = FLAMMABLE

/obj/item/decorations/bouquets/Initialize(mapload)
	. = ..()
	hitsound = pick('sound/effects/footstep/grass1.ogg', 'sound/effects/footstep/grass2.ogg', 'sound/effects/footstep/grass3.ogg')

/obj/item/decorations/bouquets/random

/obj/item/decorations/bouquets/random/Initialize(mapload)
	. = ..()
	var/pick_flower = pick("mixedbouquet", "poppybouquet", "rosebouquet", "sunbouquet")
	icon_state = "[pick_flower]"

////// Cultist's crystal

/obj/structure/decorative_structures/cult_crystal
	name = "Bloody crystal"
	icon_state = "cult_crystal"
	max_integrity = 120
	anchored = TRUE

/obj/structure/decorative_structures/cult_crystal/Initialize(mapload)
	. = ..()
	set_light(2, 1, COLOR_RED)

/obj/structure/decorative_structures/cult_crystal/attackby(obj/item/I, mob/user, params)
	electrocute_mob(user, get_area(src), src, 0.5, TRUE)
	to_chat(user, span_warning("When you touch it, you feel some dark energy."))
	..()

/obj/structure/decorative_structures/cult_crystal/attack_hand(mob/living/user)
	electrocute_mob(user, get_area(src), src, 0.5, TRUE)
	to_chat(user, span_warning("When you touch it, you feel some dark energy."))
	..()

/obj/structure/decorative_structures/cult_crystal/Destroy()
	playsound(src, 'sound/effects/glassbr3.ogg', 30, 0)
	var/turf/T = get_turf(src)
	var/mob/living/simple_animal/crystal_soul = new /mob/living/simple_animal/hostile/construct/armoured/hostile(T)
	crystal_soul.loot = list(pick(
		/obj/item/gun/magic/wand/resurrection,
		/obj/item/gun/magic/wand/fireball,
		/obj/item/gun/magic/wand/slipping,
		/obj/item/spellbook/oneuse/sacredflame,
		/obj/item/spellbook/oneuse/smoke,
		/obj/item/spellbook/oneuse/forcewall,
		/obj/item/soulstone/anybody,
	))
	new /obj/effect/particle_effect/smoke/vomiting(T)
	new /obj/effect/decal/cleanable/blood/gibs(T)
	new /obj/effect/decal/cleanable/blood(T)
	..()

/obj/structure/decorative_structures/snowcloud
	name = "snow cloud"
	desc = "Let it snow, let it snow, let it snow!"
	icon = 'icons/effects/effects.dmi'
	icon_state = "snowcloud"
	layer = FLY_LAYER
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	density = 0

/obj/item/decorations/distillator
	max_integrity = 20
	name = "distillator"
	desc = "Some chemical equipment seems to be missing something."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "distill"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/decorations/distillator/Destroy()
	playsound(src, 'sound/effects/glassbr3.ogg', 30, FALSE)
	new /obj/effect/decal/cleanable/glass(get_turf(src))
	new /obj/item/shard(get_turf(src))
	..()

/obj/item/decorations/distillator/full
	name = "distillator"
	desc = "Some chemical equipment looks like something was evaporated through it. It's better not to smell it."
	icon_state = "distill_nocol"

/obj/structure/decorative_structures/centrifuge
	name = "centrifuge"
	desc = "Broken centrifuge. It's better not to touch it, who knows what was mixed inside it."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "centrifuge"
	max_integrity = 50
	anchored = 1
	density = 0

/obj/structure/decorative_structures/centrifuge/Destroy()
	new /obj/item/stack/sheet/metal(get_turf(src), 5)
	new /obj/item/stack/cable_coil/random(get_turf(src), 5)
	new /obj/item/shard(get_turf(src))
	..()

/obj/structure/decorative_structures/chemanalyzer
	name = "chemical analyzer"
	desc = "A chemical analyzer capable of recognizing the smallest atoms."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer1"
	max_integrity = 150
	anchored = 1
	density = 0

/obj/structure/decorative_structures/chemanalyzer/broken
	icon_state = "mixer1_b"

/obj/structure/decorative_structures/chemanalyzer/Destroy()
	new /obj/effect/decal/cleanable/glass(get_turf(src))
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	new /obj/item/shard(get_turf(src))
	..()

/obj/structure/decorative_structures/broken_cell
	name = "broken cell"
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "cell-broken2"
	max_integrity = 200
	anchored = TRUE
	var/goo_color = "#752424"

/obj/structure/decorative_structures/broken_cell/update_overlays()
	. = ..()
	. += mutable_appearance(icon, icon_state = "goo2", appearance_flags = RESET_COLOR, color = goo_color)

/obj/structure/decorative_structures/broken_cell/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)
