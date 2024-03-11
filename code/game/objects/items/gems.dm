//rare and valulable gems- designed to eventually be used for archeology, or to be given as opposed to money as loot. Auctioned off at export, or kept as a trophy. -MemedHams

/obj/item/gem
	name = "\improper gem"
	desc = "Oooh! Shiny!"
	icon = 'icons/obj/lavaland/gems.dmi'
	icon_state = "rupee"
	w_class = WEIGHT_CLASS_SMALL

	///have we been analysed with a mining scanner?
	var/analysed = FALSE
	///how many points we grant to whoever discovers us
	var/point_value = 100
	///what's our real name that will show upon discovery? null to do nothing
	var/true_name
	///the message given when you discover this gem.
	var/analysed_message = null
	///the thing that spawns in the item.
	var/sheet_type = null
	///how many cargo point or cash we will get from sending this to station
	var/sell_multiplier = 1

	var/image/shine_overlay //shows this overlay when not scanned

	///Can you use this gem to make a necklace?
	var/insertable = TRUE
	///Can you make simple jewelry with it?
	var/simple = FALSE

/obj/item/gem/Initialize()
	. = ..()
	shine_overlay = image(icon = 'icons/obj/lavaland/gems.dmi',icon_state = "shine")
	add_overlay(shine_overlay)
	pixel_x = rand(-8,8)
	pixel_y = rand(-8,8)

/obj/item/gem/attackby(obj/item/item, mob/living/user, params) //Stolen directly from geysers, removed the internal gps
	if(!istype(item, /obj/item/mining_scanner) && !istype(item, /obj/item/t_scanner/adv_mining_scanner))
		return ..()

	if(analysed)
		to_chat(user, span_warning("This gem has already been analysed!"))
		return

	to_chat(user, span_notice("You analyse the precious gemstone!"))
	if(analysed_message)
		to_chat(user, analysed_message)

	analysed = TRUE
	if(true_name)
		name = true_name

	if(shine_overlay)
		cut_overlay(shine_overlay)
		qdel(shine_overlay)

	if(isliving(user))
		var/mob/living/living = user

		var/obj/item/card/id/card = living.get_id_card()
		if(card)
			to_chat(user, span_notice("[point_value] mining points have been paid out!"))
			card.mining_points += point_value
			playsound(src, 'sound/machines/ping.ogg', 15, TRUE)

/obj/item/gem/welder_act(mob/living/user, obj/item/I) //Jank code that detects if the gem in question has a sheet_type and spawns the items specifed in it
	if(I.use_tool(src, user, 0, volume=50))
		if(src.sheet_type)
			new src.sheet_type(user.loc)
			to_chat(user, span_notice("You carefully cut [src]."))
			qdel(src)
		else
			to_chat(user, span_notice("You can't seem to cut [src]."))
	return TRUE

//goldgrub gem
/obj/item/gem/rupee
	name = "\improper ruperium crystal"
	desc = "A radioactive, crystalline compound rarely found in the goldgrubs. While able to be cut into sheets of uranium, the mineral's true value is in its resonating, humming properties."
	icon_state = "rupee"
	materials = list(MAT_URANIUM = 60000)
	sheet_type = /obj/item/stack/sheet/mineral/uranium{amount = 30}
	point_value = 500
	var/damaged = FALSE
	var/pulse = "rupee_pulse"
	sell_multiplier = 2

/obj/item/gem/rupee/Initialize()
	AddComponent(/datum/component/radioactivity, \
			rad_per_cycle = 10, \
			rad_cycle = 3 SECONDS, \
			rad_cycle_radius = 5 \
	)
	ADD_TRAIT(src, TRAIT_BLOCK_RADIATION, src)
	. = ..()

/obj/item/gem/rupee/examine(mob/user)
	. = ..()
	if(!damaged)
		. += "<span class='notice'>You could use something sharp to damage crystal.</span>"
	else
		. += "<span class='warning'>The crystal glows strongly!</span>"

/obj/item/gem/rupee/attackby(obj/item/W, mob/user, params)
	..()
	if(is_sharp(W) && !damaged)
		to_chat(user, span_notice("You started damaging the crystal. You have the feeling that's it's not a good idea..."))
		if(!do_after(user, 5 SECONDS, FALSE, src))
			to_chat(user, span_notice("You decide not to die from radiation."))
			return
		to_chat(user, span_warning("You make a crack in the crystal! Your head hurts..."))
		var/mob/living/carbon/human/H = user
		H.apply_effect(50, IRRADIATE)
		damaged = TRUE
		src.icon_state = "broken_rupee"
		REMOVE_TRAIT(src, TRAIT_BLOCK_RADIATION, src)

//magmawing watcher gem
/obj/item/gem/magma
	name = "\improper calcified auric"
	desc = "A hot, lightly glowing mineral born from the inner workings of magmawing watchers. It is most commonly smelted down into deposits of pure gold."
	icon_state = "magma"
	materials = list(MAT_GOLD = 100000)
	sheet_type = /obj/item/stack/sheet/mineral/gold{amount = 50}
	point_value = 700 //there is no magmawing tendrills, silly me
	sell_multiplier = 2
	light_range = 4
	light_power = 2
	light_color = "#ff7b00"
	var/hot = TRUE

/obj/item/gem/magma/examine(mob/user)
	. = ..()
	if(!hot)
		. += "<span class='notice'>The diamond feels cold to the touch.</span>"
	else
		. += "<span class='notice'>The crystal is very hot to touch! It seems you can warm up you squeeze it</span>"

/obj/item/gem/magma/attack_self(mob/user)
	. = ..()
	var/mob/living/carbon/human/H = user
	if(!hot)
		to_chat(H, span_notice("You are pressing [src] to your breast, but it's too cold for now.."))
		return
	to_chat(H, span_notice("You are pressing [src] to your breast and a strong heat passes through your body!"))
	H.custom_emote(1, "прижимает кристалл к груди.") //HRP style
	H.adjust_bodytemperature(60)
	light_range = 0
	light_power = 0
	light_color = null
	update_light()
	hot = FALSE
	addtimer(CALLBACK(src, PROC_REF(reset_cooldown)), 15 SECONDS)

/obj/item/gem/magma/proc/reset_cooldown()
	hot = TRUE
	light_range = initial(light_range)
	light_power = initial(light_power)
	light_color = initial(light_color)
	update_light()

//icewing watcher gem
/obj/item/gem/fdiamond
	name = "\improper frost diamond"
	desc = "A unique diamond that is produced within icewing watchers. It looks like it can be cut into smaller sheets of diamond ore."
	icon_state = "diamond"
	materials = list(MAT_DIAMOND = 60000)
	sheet_type = /obj/item/stack/sheet/mineral/diamond{amount = 30}
	point_value = 700
	light_range = 4
	light_power = 2
	light_color = "#62cad5"
	var/cold = TRUE
	sell_multiplier = 2

/obj/item/gem/fdiamond/examine(mob/user)
	. = ..()
	if(!cold)
		. += "<span class='notice'>The diamond feels warm to the touch.</span>"
	else
		. += "<span class='notice'>The crystal is very cold to touch! It seems you can cool if you squeeze it</span>"

/obj/item/gem/fdiamond/attack_self(mob/user)
	. = ..()
	var/mob/living/carbon/human/H = user
	if(!cold)
		to_chat(H, span_notice("You are pressing [src] to your breast, but it's too warm for now.."))
		return
	to_chat(H, span_notice("You are pressing [src] to your breast and a strong cold passes through your body!"))
	H.custom_emote(1, "прижимает алмаз к груди.") //HRP style
	H.adjust_bodytemperature(-60)
	light_range = 0
	light_power = 0
	light_color = null
	update_light()
	cold = FALSE
	addtimer(CALLBACK(src, PROC_REF(reset_cooldown)), 15 SECONDS)

/obj/item/gem/fdiamond/proc/reset_cooldown()
	cold = TRUE
	light_range = initial(light_range)
	light_power = initial(light_power)
	light_color = initial(light_color)
	update_light()

//blood-drunk miner gem
/obj/item/gem/phoron
	name = "\improper stabilized baroxuldium"
	desc = "A soft, glowing crystal only found in the deepest veins of plasma. It looks like it could be destructively analyzed to extract the condensed materials within."
	icon_state = "phoron"
	materials = list(MAT_PLASMA = 80000)
	sheet_type = /obj/item/stack/sheet/mineral/plasma{amount = 40}
	origin_tech = "materials=6;plasmatech=6"
	point_value = 1000
	sell_multiplier = 3
	light_range = 4
	light_power = 4
	light_color = "#62326a"

//hierophant gem
/obj/item/gem/purple
	name = "\improper densified dilithium"
	desc = "A strange mass of dilithium which pulses to a steady rhythm. Its strange surface exudes a unique radio signal detectable by GPS."
	icon_state = "purple"
	point_value = 1200
	sell_multiplier = 4
	light_range = 4
	light_power = 2
	light_color = "#cc47a6"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	var/obj/item/gps/internal

/obj/item/gem/purple/Initialize()
	. = ..()
	internal = new /obj/item/gps/internal/purple(src)

/obj/item/gem/purple/Destroy(force)
	if(force)
		. = ..()
	else
		return QDEL_HINT_LETMELIVE

/obj/item/gps/internal/purple
	icon_state = null
	gpstag = "Harmonic Signal"
	desc = "It's ringing."
	invisibility = 100

//drake gem
/obj/item/gem/amber //all cool effects in the necklace, not here. Also this works as fuel for Anvil
	name = "\improper draconic amber"
	desc = "A brittle, strange mineral that forms when an ash drake's blood hardens after death. Cherished by gemcutters for its faint glow and unique, soft warmth. Poacher tales whisper of the dragon's strength being bestowed to one that wears a necklace of this amber."
	icon_state = "amber"
	point_value = 1400
	sell_multiplier = 5
	light_range = 4
	light_power = 4
	light_color = "#FFBF00"

//colossus gem
/obj/item/gem/void
	name = "\improper null crystal"
	desc = "A shard of stellar, crystallized energy. These strange objects occasionally appear spontaneously in areas where the bluespace fabric is largely unstable. Its surface gives a light jolt to those who touch it."
	icon_state ="void"
	point_value = 1600
	sell_multiplier = 6
	light_range = 4
	light_power = 2
	light_color = "#4785a4"
	var/blink_range = 6
	var/cooldown = FALSE
	var/cooldown_time = 40 SECONDS

/obj/item/gem/void/examine(mob/user)
	. = ..()
	if(!cooldown)
		. += "<span class='notice'>The crystall is glowing!</span>"


/obj/item/gem/void/attack_self(mob/user)
	if(cooldown)
		to_chat(user, span_warning("The crystal is still. Perhaps you should wait a little longer."))
		return
	var/mob/living/carbon/human/H = user
	teleport(H)
	H.visible_message("<span class='notice'>[H] squeezes the crystal in [H.p_their()] hands!</span>")
	cooldown = TRUE
	addtimer(CALLBACK(src, PROC_REF(reset_cooldown)),cooldown_time)

/obj/item/gem/void/proc/teleport(mob/living/L)
	if(!is_teleport_allowed(L.z))
		src.visible_message("<span class='warning'>[src] begin rapidly vibrating.</span>")
		return
	do_teleport(L, get_turf(L), blink_range, asoundin = 'sound/effects/phasein.ogg')

/obj/item/gem/void/proc/reset_cooldown()
	cooldown = FALSE

//bubblegum gem. Can be used for antags to get some active blood or TK.
/obj/item/gem/bloodstone
	name = "\improper ichorium"
	desc = "A weird, sticky substance, known to coalesce in the presence of otherwordly phenomena. While shunned by most spiritual groups, this gemstone has unique ties to the occult which find it handsomely valued by mysterious patrons."
	icon_state = "red"
	point_value = 1800
	sell_multiplier = 7
	light_range = 4
	light_power = 6
	light_color = "#ac0606"
	var/used = FALSE
	var/blood = 50
	var/charges = 10

/obj/item/gem/bloodstone/examine(mob/user)
	. = ..()
	if(isvampire(user) && !used)
		. += "<span class='warning'>You can smell human blood coming from the bloodstone.</span>"
	if(user.mind.has_antag_datum(/datum/antagonist/traitor))
		. += "<span class='notice'>You have a feeling, that you could you this gem to charge your uplink.</span>"

/obj/item/gem/bloodstone/attack_self(mob/user)
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(vampire && !used)
		user.visible_message(span_warning("[user] forcefully squeezes [src] in his hands!"), \
							span_notice("You squeeze [src] in your hands."))
		if(!do_after_once(user, 10 SECONDS, target = user, attempt_cancel_message = "You relax your grip on [src]"))
			return
		user.visible_message(span_warning("[user] begins to absorb the liquid contents of the crystal!"), \
						span_notice("You absorb the contents of [src]. The energy from the crystal saturates your body."))
		vampire.bloodusable += blood
		used = TRUE
		light_range = 3
		light_power = 2
		light_color = "#ac2626"
		update_light()


/obj/item/gem/bloodstone/afterattack(obj/item/I, mob/user, proximity)
	if(!proximity)
		return
	if(istype(I) && I.hidden_uplink && I.hidden_uplink.active)
		I.hidden_uplink.uses += charges
		qdel(src)
		to_chat(user, "<span class='notice'>You slot [src] into [I] and charge its internal uplink.</span>")


//vetus gem
/obj/item/gem/data
	name = "\improper bluespace data crystal"
	desc = "A large bluespace crystal, etched internally with nano-circuits, it seemingly draws power from nowhere."
	icon_state = "data"
	materials = list(MAT_BLUESPACE = 48000)
	sheet_type = /obj/item/stack/sheet/bluespace_crystal{amount = 24}
	origin_tech = "materials=6;bluespace=7" //uh-oh
	light_range = 4
	light_power = 6
	light_color = "#4245f3"
	point_value = 2000
	insertable = FALSE
	sell_multiplier = 10

//mining gems
/obj/item/gem/random
	name = "random gem"
	icon_state = "ruby"
	var/gem_list = list(/obj/item/gem/ruby, /obj/item/gem/sapphire, /obj/item/gem/emerald, /obj/item/gem/topaz)

/obj/item/gem/random/Initialize(quantity)
	. = ..()
	var/q = quantity ? quantity : 1
	for(var/i = 0, i < q, i++)
		var/obj/item/gem/G = pick(gem_list)
		new G(loc)
	qdel(src)

/obj/item/gem/ruby
	name = "\improper ruby"
	icon_state = "ruby"
	point_value = 100
	simple = TRUE
	sell_multiplier = 0.5

/obj/item/gem/sapphire
	name = "\improper sapphire"
	icon_state = "sapphire"
	point_value = 100
	simple = TRUE
	sell_multiplier = 0.5

/obj/item/gem/emerald
	name = "\improper emerald"
	icon_state = "emerald"
	point_value = 100
	simple = TRUE
	sell_multiplier = 0.5

/obj/item/gem/topaz
	name = "\improper topaz"
	icon_state = "topaz"
	point_value = 100
	simple = TRUE
	sell_multiplier = 0.5
