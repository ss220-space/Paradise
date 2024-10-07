/*
 *	Everything derived from the common cardboard box.
 *	Basically everything except the original is a kit (starts full).
 *
 *	Contains:
 *		Empty box, starter boxes (survival/engineer),
 *		Latex glove and sterile mask boxes,
 *		Syringe, beaker, dna injector boxes,
 *		Blanks, flashbangs, and EMP grenade boxes,
 *		Tracking and chemical implant boxes,
 *		Prescription glasses and drinking glass boxes,
 *		Condiment bottle and silly cup boxes,
 *		Donkpocket and monkeycube boxes,
 *		ID and security PDA cart boxes,
 *		Handcuff, mousetrap, and pillbottle boxes,
 *		Snap-pops and matchboxes,
 *		Replacement light boxes.
 *
 *		For syndicate call-ins see uplink_kits.dm
 */

/obj/item/storage/box
	name = "box"
	desc = "It's just an ordinary box."
	icon_state = "box"
	item_state = "syringe_kit"
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/cardboardbox_drop.ogg'
	pickup_sound =  'sound/items/handling/cardboardbox_pickup.ogg'
	foldable = /obj/item/stack/sheet/cardboard
	foldable_amt = 1

/obj/item/storage/box/large
	name = "large box"
	desc = "You could build a fort with this."
	icon_state = "largebox"
	w_class = 4 // Big, bulky.
	foldable_amt = 4
	storage_slots = 21
	max_combined_w_class = 42 // 21*2

/obj/item/storage/box/survival
	icon_state = "box_civ"

/obj/item/storage/box/survival/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival/brigphys
	icon_state = "box_brigphys"

/obj/item/storage/box/survival_vox
	icon_state = "box_vox"

/obj/item/storage/box/survival_vox/populate_contents()
	new /obj/item/clothing/mask/breath/vox(src)
	new /obj/item/tank/internals/emergency_oxygen/nitrogen(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival_machine
	icon_state = "box_machine"

/obj/item/storage/box/survival_machine/populate_contents()
	new /obj/item/weldingtool(src)
	new /obj/item/stack/cable_coil/random(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival_nucleation
	icon_state = "box_nucleation"

/obj/item/storage/box/survival_nucleation/populate_contents()
	new /obj/item/storage/firstaid/crew/nucleation(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival_plasmaman
	icon_state = "box_plasma"

/obj/item/storage/box/survival_plasmaman/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen/plasma(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/engineer
	icon_state = "box_eng"

/obj/item/storage/box/engineer/populate_contents()
	new /obj/item/clothing/mask/breath( src )
	new /obj/item/tank/internals/emergency_oxygen/engi( src )
	new /obj/item/storage/firstaid/crew( src )
	new /obj/item/flashlight/flare/glowstick/blue( src )
	return

/obj/item/storage/box/survival_mining
	icon_state = "box_min"

/obj/item/storage/box/survival_mining/populate_contents()
	new /obj/item/clothing/mask/gas/explorer/folded(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/blue(src)

/obj/item/storage/box/survival_security
	icon_state = "box_sec"

/obj/item/storage/box/survival_security/populate_contents()
	new /obj/item/tank/internals/emergency_oxygen/engi/sec(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/red(src)
	new /obj/item/crowbar/red/sec(src)
	new /obj/item/clothing/mask/gas/sechailer/folded(src)
	new /obj/item/radio/sec(src)

/obj/item/storage/box/survival_security/hos
	icon_state = "box_hos"

/obj/item/storage/box/survival_security/cadet
	icon_state = "box_cadet"

/obj/item/storage/box/survival_security/warden
	icon_state = "box_warden"

/obj/item/storage/box/survival_security/pilot
	icon_state = "box_pilot"

/obj/item/storage/box/survival_security/detective
	icon_state = "box_detective"

/obj/item/storage/box/survival_laws
	icon_state = "box_avd"

/obj/item/storage/box/survival_laws/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen(src)
	new /obj/item/storage/firstaid/crew(src)
	new /obj/item/flashlight/flare/glowstick/pink(src)
	new /obj/item/book/manual/security_space_law(src)
	new /obj/item/taperecorder(src)
	new /obj/item/camera(src)

/obj/item/storage/box/survival_laws/magisraka
	icon_state = "box_magisraka"

/obj/item/storage/box/survival_syndi
	icon_state = "box_syndi"

/obj/item/storage/box/survival_syndi/populate_contents()
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/tank/internals/emergency_oxygen/engi/syndi(src)
	new /obj/item/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/reagent_containers/food/pill/initropidril(src)
	new /obj/item/flashlight/flare/glowstick/red(src)

/obj/item/storage/box/gloves
	name = "box of latex gloves"
	desc = "Contains white gloves."
	icon_state = "latex"

/obj/item/storage/box/gloves/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/clothing/gloves/color/latex(src)

/obj/item/storage/box/masks
	name = "sterile masks"
	desc = "This box contains masks of sterility."
	icon_state = "sterile"

/obj/item/storage/box/masks/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/clothing/mask/surgical(src)

/obj/item/storage/box/syringes
	name = "syringes"
	desc = "A box full of syringes."
	desc = "A biohazard alert warning is printed on the box"
	icon_state = "syringe"

/obj/item/storage/box/syringes/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/reagent_containers/syringe(src)

/obj/item/storage/box/beakers
	name = "beaker box"
	icon_state = "beaker"

/obj/item/storage/box/beakers/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/reagent_containers/glass/beaker(src)

/obj/item/storage/box/beakers/bluespace
	name = "box of bluespace beakers"
	icon_state = "beaker"

/obj/item/storage/box/beakers/bluespace/populate_contents()
	..()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/glass/beaker/bluespace(src)

/obj/item/storage/box/iv_bags
	name = "IV Bags"
	desc = "A box full of empty IV bags."
	icon_state = "beaker"

/obj/item/storage/box/iv_bags/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/iv_bag(src)

/obj/item/storage/box/injectors
	name = "\improper DNA injectors"
	desc = "This box contains injectors it seems."

/obj/item/storage/box/injectors/populate_contents()
	new /obj/item/dnainjector/h2m(src)
	new /obj/item/dnainjector/h2m(src)
	new /obj/item/dnainjector/h2m(src)
	new /obj/item/dnainjector/m2h(src)
	new /obj/item/dnainjector/m2h(src)
	new /obj/item/dnainjector/m2h(src)

/obj/item/storage/box/flashbangs
	name = "box of flashbangs (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness or deafness in repeated use.</B>"
	icon_state = "flashbang"

/obj/item/storage/box/flashbangs/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/grenade/flashbang(src)

/obj/item/storage/box/flashes
	name = "box of flashbulbs"
	desc = "<B>WARNING: Flashes can cause serious eye damage, protective eyewear is required.</B>"
	icon_state = "flashbang"

/obj/item/storage/box/flashes/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/flash(src)

/obj/item/storage/box/teargas
	name = "box of tear gas grenades (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness and skin irritation.</B>"
	icon_state = "flashbang"

/obj/item/storage/box/teargas/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/grenade/chem_grenade/teargas(src)

/obj/item/storage/box/barrier
	name = "box of barrier grenades"
	desc = "Instant cover.</B>"
	icon_state = "flashbang"

/obj/item/storage/box/barrier/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/grenade/barrier(src)

/obj/item/storage/box/emps
	name = "emp grenades"
	desc = "A box with 5 emp grenades."
	icon_state = "flashbang"

/obj/item/storage/box/emps/populate_contents()
	for(var/I in 1 to 5)
		new /obj/item/grenade/empgrenade(src)

/obj/item/storage/box/trackimp
	name = "tracking implant kit"
	desc = "Box full of scum-bag tracking utensils."
	icon_state = "implant"

/obj/item/storage/box/trackimp/populate_contents()
	for(var/I in 1 to 4)
		new /obj/item/implantcase/tracking(src)
	new /obj/item/implanter(src)
	new /obj/item/implantpad(src)
	new /obj/item/gps/security(src)

/obj/item/storage/box/minertracker
	name = "boxed tracking implant kit"
	desc = "For finding those who have died on the accursed lavaworld."
	icon_state = "implant"

/obj/item/storage/box/minertracker/populate_contents()
	for(var/I in 1 to 3)
		new /obj/item/implantcase/tracking(src)
	new /obj/item/implanter(src)
	new /obj/item/implantpad(src)
	new /obj/item/gps/security(src)

/obj/item/storage/box/chemimp
	name = "chemical implant kit"
	desc = "Box of stuff used to implant chemicals."
	icon_state = "implant"

/obj/item/storage/box/chemimp/populate_contents()
	for(var/I in 1 to 5)
		new /obj/item/implantcase/chem(src)
	new /obj/item/implanter(src)
	new /obj/item/implantpad(src)

/obj/item/storage/box/exileimp
	name = "boxed exile implant kit"
	desc = "Box of exile implants. It has a picture of a clown being booted through the Gateway."
	icon_state = "implant"

/obj/item/storage/box/exileimp/populate_contents()
	for(var/I in 1 to 5)
		new /obj/item/implantcase/exile(src)
	new /obj/item/implanter(src)

/obj/item/storage/box/deathimp
	name = "death alarm implant kit"
	desc = "Box of life sign monitoring implants."
	icon_state = "implant"
	storage_slots = 8

/obj/item/storage/box/deathimp/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/implantcase/death_alarm(src)
	new /obj/item/implanter(src)

/obj/item/storage/box/tapes
	name = "Tape Box"
	desc = "A box of spare recording tapes"
	icon_state = "box"

/obj/item/storage/box/tapes/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/tape(src)

/obj/item/storage/box/rxglasses
	name = "prescription glasses"
	desc = "This box contains nerd glasses."
	icon_state = "glasses"

/obj/item/storage/box/rxglasses/populate_contents()
	for(var/I in 1 to 4)
		new /obj/item/clothing/glasses/regular(src)

/obj/item/storage/box/drinkingglasses
	name = "box of drinking glasses"
	desc = "It has a picture of drinking glasses on it."

/obj/item/storage/box/drinkingglasses/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/reagent_containers/food/drinks/drinkingglass(src)

/obj/item/storage/box/cdeathalarm_kit
	name = "Death Alarm Kit"
	desc = "Box of stuff used to implant death alarms."
	icon_state = "implant"
	item_state = "syringe_kit"

/obj/item/storage/box/cdeathalarm_kit/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/implantcase/death_alarm(src)
	new /obj/item/implanter(src)

/obj/item/storage/box/condimentbottles
	name = "box of condiment bottles"
	desc = "It has a large ketchup smear on it."

/obj/item/storage/box/condimentbottles/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/reagent_containers/food/condiment(src)

/obj/item/storage/box/cups
	name = "box of paper cups"
	desc = "It has pictures of paper cups on the front."
	icon_state = "papercup"

/obj/item/storage/box/cups/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/reagent_containers/food/drinks/sillycup(src)

/obj/item/storage/box/donkpockets
	name = "box of donk-pockets"
	desc = "<B>Instructions:</B> <I>Heat in microwave. Product will cool if not eaten within seven minutes.</I>"
	icon_state = "donk_kit"

/obj/item/storage/box/donkpockets/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/reagent_containers/food/snacks/donkpocket(src)

/obj/item/storage/box/syndidonkpockets
	name = "box of donk-pockets"
	desc = "This box feels slightly warm"
	icon_state = "donk_kit"

/obj/item/storage/box/syndidonkpockets/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/reagent_containers/food/snacks/syndidonkpocket(src)

/obj/item/storage/box/monkeycubes
	name = "monkey cube box"
	desc = "Drymate brand monkey cubes. Just add water!"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "monkeycubebox"
	storage_slots = 7
	can_hold = list(/obj/item/reagent_containers/food/snacks/monkeycube)
	var/monkey_cube_type = /obj/item/reagent_containers/food/snacks/monkeycube

/obj/item/storage/box/monkeycubes/populate_contents()
	for(var/i in 1 to 5)
		new monkey_cube_type(src)

/obj/item/storage/box/monkeycubes/syndicate
	desc = "Waffle Co. brand monkey cubes. Just add water and a dash of subterfuge!"
	monkey_cube_type = /obj/item/reagent_containers/food/snacks/monkeycube/syndicate

/obj/item/storage/box/monkeycubes/farwacubes
	name = "farwa cube box"
	desc = "Drymate brand farwa cubes. Just add water!"
	monkey_cube_type = /obj/item/reagent_containers/food/snacks/monkeycube/farwacube

/obj/item/storage/box/monkeycubes/stokcubes
	name = "stok cube box"
	desc = "Drymate brand stok cubes. Just add water!"
	monkey_cube_type = /obj/item/reagent_containers/food/snacks/monkeycube/stokcube

/obj/item/storage/box/monkeycubes/neaeracubes
	name = "neaera cube box"
	desc = "Drymate brand neaera cubes. Just add water!"
	monkey_cube_type = /obj/item/reagent_containers/food/snacks/monkeycube/neaeracube

/obj/item/storage/box/monkeycubes/wolpincubes
	name = "wolpin cube box"
	desc = "Drymate brand wolpin cubes. Just add water!"
	monkey_cube_type = /obj/item/reagent_containers/food/snacks/monkeycube/wolpincube

/obj/item/storage/box/permits
	name = "box of construction permits"
	desc = "A box for containing construction permits, used to officially declare built rooms as additions to the station."
	icon_state = "id"

/obj/item/storage/box/permits/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/areaeditor/permit(src)

/obj/item/storage/box/syndicate_permits
	name = "box of syndicate construction permits"
	desc = "A box for containing construction permits, used to officially declare built rooms as additions to the station."
	icon_state = "syndie_id"

/obj/item/storage/box/syndicate_permits/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/areaeditor/permit/syndicate(src)

/obj/item/storage/box/ids
	name = "spare IDs"
	desc = "Has so many empty IDs."
	icon_state = "id"

/obj/item/storage/box/ids/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/card/id(src)

/obj/item/storage/box/prisoner
	name = "prisoner IDs"
	desc = "Take away their last shred of dignity, their name."
	icon_state = "id"

/obj/item/storage/box/prisoner/populate_contents()
	new /obj/item/card/id/prisoner/one(src)
	new /obj/item/card/id/prisoner/two(src)
	new /obj/item/card/id/prisoner/three(src)
	new /obj/item/card/id/prisoner/four(src)
	new /obj/item/card/id/prisoner/five(src)
	new /obj/item/card/id/prisoner/six(src)
	new /obj/item/card/id/prisoner/seven(src)

/obj/item/storage/box/seccarts
	name = "spare R.O.B.U.S.T. Cartridges"
	desc = "A box full of R.O.B.U.S.T. Cartridges, used by Security."
	icon_state = "pda"

/obj/item/storage/box/seccarts/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/cartridge/security(src)

/obj/item/storage/box/holobadge
	name = "holobadge box"
	icon_state = "box_badge"
	desc = "A box claiming to contain holobadges."

/obj/item/storage/box/holobadge/populate_contents()
	for(var/I in 1 to 4)
		new /obj/item/clothing/accessory/holobadge(src)
	new /obj/item/clothing/accessory/holobadge/cord(src)
	new /obj/item/clothing/accessory/holobadge/cord(src)

/obj/item/storage/box/evidence
	name = "evidence bag box"
	desc = "A box claiming to contain evidence bags."
	icon_state = "box_evidence"

/obj/item/storage/box/evidence/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/evidencebag(src)

/obj/item/storage/box/handcuffs
	name = "spare handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "handcuff"

/obj/item/storage/box/handcuffs/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/restraints/handcuffs(src)

/obj/item/storage/box/zipties
	name = "box of spare zipties"
	desc = "A box full of zipties."
	icon_state = "handcuff"

/obj/item/storage/box/zipties/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/restraints/handcuffs/cable/zipties(src)

/obj/item/storage/box/alienhandcuffs
	name = "box of spare handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "alienboxCuffs"

/obj/item/storage/box/alienhandcuffs/populate_contents()
	for(var/i in 1 to 7)
		new	/obj/item/restraints/handcuffs/alien(src)

/obj/item/storage/box/manacles
	name = "box of spare manacles"
	desc = "A box full of manacles. Old but gold."
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "box_manacle"

/obj/item/storage/box/manacles/populate_contents()
	for(var/i in 1 to 7)
		new	/obj/item/restraints/handcuffs/manacles(src)

/obj/item/storage/box/fakesyndiesuit
	name = "boxed space suit and helmet"
	desc = "A sleek, sturdy box used to hold replica spacesuits."
	icon_state = "box_of_doom"

/obj/item/storage/box/fakesyndiesuit/populate_contents()
	new /obj/item/clothing/head/syndicatefake(src)
	new /obj/item/clothing/suit/syndicatefake(src)

/obj/item/storage/box/enforcer_rubber
	name = "enforcer pistol kit (rubber)"
	desc = "A box marked with pictures of an enforcer pistol, two ammo clips, and the word 'NON-LETHAL'."
	icon_state = "box_ert"

/obj/item/storage/box/enforcer_rubber/populate_contents()
	new /obj/item/gun/projectile/automatic/pistol/enforcer(src) // loaded with rubber by default
	new /obj/item/ammo_box/magazine/enforcer(src)
	new /obj/item/ammo_box/magazine/enforcer(src)

/obj/item/storage/box/enforcer_lethal
	name = "enforcer pistol kit (lethal)"
	desc = "A box marked with pictures of an enforcer pistol, two ammo clips, and the word 'LETHAL'."
	icon_state = "box_ert"

/obj/item/storage/box/enforcer_lethal/populate_contents()
	new /obj/item/gun/projectile/automatic/pistol/enforcer/lethal(src)
	new /obj/item/ammo_box/magazine/enforcer/lethal(src)
	new /obj/item/ammo_box/magazine/enforcer/lethal(src)

/obj/item/storage/box/enforcer/security
	name = "enforcer pistol kit (rubber)"
	desc = "A box marked with pictures of an enforcer pistol, two ammo clips, and the word 'NON-LETHAL'."
	icon_state = "box_ert"

/obj/item/storage/box/enforcer/security/populate_contents()
	new /obj/item/gun/projectile/automatic/pistol/enforcer/security(src) // loaded with rubber by default
	new /obj/item/ammo_box/magazine/enforcer(src)
	new /obj/item/ammo_box/magazine/enforcer(src)

/obj/item/storage/box/bartender_rare_ingredients_kit
	name = "bartender rare reagents kit"
	desc = "A box intended for experienced bartenders."

/obj/item/storage/box/bartender_rare_ingredients_kit/populate_contents()
	var/list/reagent_list = list("sacid", "radium", "ether", "methamphetamine", "plasma", "gold", "silver", "capsaicin", "psilocybin")
	for(var/reag in reagent_list)
		var/obj/item/reagent_containers/glass/bottle/B = new(src)
		B.reagents.add_reagent(reag, 30)
		B.name = "[reag] bottle"

/obj/item/storage/box/chef_rare_ingredients_kit
	name = "chef rare reagents kit"
	desc = "A box intended for experienced chefs."

/obj/item/storage/box/chef_rare_ingredients_kit/populate_contents()
	new /obj/item/reagent_containers/food/condiment/soysauce(src)
	new /obj/item/reagent_containers/food/condiment/enzyme(src)
	new /obj/item/reagent_containers/food/condiment/pack/hotsauce(src)
	new /obj/item/kitchen/knife/butcher(src)
	var/list/reagent_list = list("msg", "triple_citrus", "salglu_solution", "nutriment", "gravy", "honey", "vitfro")
	for(var/reag in reagent_list)
		var/obj/item/reagent_containers/glass/bottle/B = new(src)
		B.reagents.add_reagent(reag, 30)
		B.name = "[reag] bottle"

/obj/item/storage/box/mousetraps
	name = "box of Pest-B-Gon mousetraps"
	desc = "<B><FONT color='red'>WARNING:</FONT></B> <I>Keep out of reach of children</I>."
	icon_state = "mousetraps"

/obj/item/storage/box/mousetraps/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/assembly/mousetrap(src)

/obj/item/storage/box/pillbottles
	name = "box of pill bottles"
	desc = "It has pictures of pill bottles on its front."

/obj/item/storage/box/pillbottles/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/storage/pill_bottle(src)

/obj/item/storage/box/patch_packs
	name = "box of patch packs"
	desc = "It has pictures of patch packs on its front."

/obj/item/storage/box/patch_packs/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/storage/pill_bottle/patch_pack(src)

/obj/item/storage/box/bodybags
	name = "body bags"
	desc = "This box contains body bags."
	icon_state = "bodybags"

/obj/item/storage/box/bodybags/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/bodybag(src)

/obj/item/storage/box/bodybags/biohazard
	name = "biohazard body bags"
	desc = "This box contains biohazard body bags."
	icon_state = "biohazard_bodybags"

/obj/item/storage/box/bodybags/biohazard/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/bodybag/biohazard(src)

/obj/item/storage/box/snappops
	name = "snap pop box"
	desc = "Eight wrappers of fun! Ages 8 and up. Not suitable for children."
	icon = 'icons/obj/toy.dmi'
	icon_state = "spbox"
	storage_slots = 8
	can_hold = list(/obj/item/toy/snappop)

/obj/item/storage/box/snappops/populate_contents()
	for(var/I in 1 to storage_slots)
		new /obj/item/toy/snappop(src)

/obj/item/storage/box/matches
	name = "matchbox"
	desc = "A small box of Almost But Not Quite Plasma Premium Matches."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "matchbox"
	item_state = "matchbox"
	base_icon_state = "matchbox"
	storage_slots = 10
	w_class = WEIGHT_CLASS_TINY
	max_w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT
	drop_sound = 'sound/items/handling/matchbox_drop.ogg'
	pickup_sound =  'sound/items/handling/matchbox_pickup.ogg'
	can_hold = list(/obj/item/match)

/obj/item/storage/box/matches/populate_contents()
	for(var/i in 1 to storage_slots)
		new /obj/item/match(src)


/obj/item/storage/box/matches/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/match))
		var/obj/item/match/match = I
		if(match.lit)
			return ..()
		add_fingerprint(user)
		match.matchignite()
		playsound(user.loc, 'sound/goonstation/misc/matchstick_light.ogg', 50, TRUE)
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()


/obj/item/storage/box/matches/update_icon_state()
	switch(length(contents))
		if(10 to INFINITY)
			icon_state = base_icon_state
		if(5 to 9)
			icon_state = "[base_icon_state]_almostfull"
		if(1 to 4)
			icon_state = "[base_icon_state]_almostempty"
		else
			icon_state = "[base_icon_state]_e"


/obj/item/storage/box/autoinjectors
	name = "box of injectors"
	desc = "Contains autoinjectors."
	icon_state = "syringe"

/obj/item/storage/box/autoinjectors/populate_contents()
	for(var/I in 1 to storage_slots)
		new /obj/item/reagent_containers/hypospray/autoinjector(src)

/obj/item/storage/box/autoinjector/utility
	name = "autoinjector kit"
	desc = "A box with several utility autoinjectors for the economical miner."
	icon_state = "syringe"

/obj/item/storage/box/autoinjector/utility/populate_contents()
	new /obj/item/reagent_containers/hypospray/autoinjector/teporone(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/teporone(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/stimpack(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/stimpack(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/stimpack(src)

/obj/item/storage/box/lights
	name = "replacement bulbs"
	icon = 'icons/obj/storage.dmi'
	icon_state = "light"
	desc = "This box is shaped on the inside so that only light tubes and bulbs fit."
	item_state = "syringe_kit"
	storage_slots=21
	can_hold = list(/obj/item/light/tube, /obj/item/light/bulb)
	max_combined_w_class = 21
	use_to_pickup = 1 // for picking up broken bulbs, not that most people will try

/obj/item/storage/box/lights/bulbs/populate_contents()
	for(var/I in 1 to 21)
		new /obj/item/light/bulb(src)

/obj/item/storage/box/lights/tubes
	name = "replacement tubes"
	icon_state = "lighttube"

/obj/item/storage/box/lights/tubes/populate_contents()
	for(var/I in 1 to 21)
		new /obj/item/light/tube(src)

/obj/item/storage/box/lights/mixed
	name = "replacement lights"
	icon_state = "lightmixed"

/obj/item/storage/box/lights/mixed/populate_contents()
	for(var/I in 1 to 14)
		new /obj/item/light/tube(src)
	for(var/I in 1 to 7)
		new /obj/item/light/bulb(src)

/obj/item/storage/box/barber
	name = "Barber Starter Kit"
	desc = "For all hairstyling needs."
	icon_state = "implant"

/obj/item/storage/box/barber/populate_contents()
	new /obj/item/scissors/barber(src)
	new /obj/item/hair_dye_bottle(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/hairgrownium(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/hair_dye(src)
	new /obj/item/reagent_containers/glass/bottle/reagent(src)
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/clothing/mask/fakemoustache(src) //totally necessary for successful barbering -Fox

/obj/item/storage/box/lip_stick
	name = "Lipstick Kit"
	desc = "For all your lip coloring needs."
	icon_state = "implant"

/obj/item/storage/box/lip_stick/populate_contents()
	new /obj/item/lipstick(src)
	new /obj/item/lipstick/purple(src)
	new /obj/item/lipstick/jade(src)
	new /obj/item/lipstick/black(src)
	new /obj/item/lipstick/green(src)
	new /obj/item/lipstick/blue(src)
	new /obj/item/lipstick/white(src)

#define NODESIGN "None"
#define NANOTRASEN "NanotrasenStandard"
#define SYNDI "SyndiSnacks"
#define HEART "Heart"
#define SMILE "SmileyFace"

/obj/item/storage/box/papersack
	name = "paper sack"
	desc = "A sack neatly crafted out of paper."
	icon_state = "paperbag_None"
	item_state = "paperbag_None"
	resistance_flags = FLAMMABLE
	foldable = null
	var/design = NODESIGN


/obj/item/storage/box/papersack/update_desc(updates = ALL)
	. = ..()
	switch(design)
		if(NODESIGN)
			desc = "A sack neatly crafted out of paper."
		if(NANOTRASEN)
			desc = "A standard Nanotrasen paper lunch sack for loyal employees on the go."
		if(SYNDI)
			desc = "The design on this paper sack is a remnant of the notorious 'SyndieSnacks' program."
		if(HEART)
			desc = "A paper sack with a heart etched onto the side."
		if(SMILE)
			desc = "A paper sack with a crude smile etched onto the side."


/obj/item/storage/box/papersack/update_icon_state()
	item_state = "paperbag_[design]"
	icon_state = length(contents) ? "[item_state]_closed" : "[item_state]"


/obj/item/storage/box/papersack/attackby(obj/item/I, mob/user, params)
	if(is_pen(I))
		add_fingerprint(user)
		//if a pen is used on the sack, dialogue to change its design appears
		if(length(contents))
			to_chat(user, span_warning("You cannot modify [src] with the items inside!"))
			return ATTACK_CHAIN_PROCEED
		var/static/list/designs = list(NODESIGN, NANOTRASEN, SYNDI, HEART, SMILE)
		var/switchDesign = tgui_input_list(user, "Select a Design:", "Paper Sack Design", designs)
		if(!switchDesign || !Adjacent(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
			return ATTACK_CHAIN_BLOCKED_ALL
		if(design == switchDesign)
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You make some modifications to [src] using your pen."))
		design = switchDesign
		update_appearance(UPDATE_DESC|UPDATE_ICON_STATE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(is_sharp(I))
		add_fingerprint(user)
		if(length(contents))
			to_chat(user, span_warning("You cannot modify [src] with the items inside!"))
			return ATTACK_CHAIN_PROCEED
		var/obj/item/clothing/head/papersack/papersack
		if(design == SMILE)
			papersack = new /obj/item/clothing/head/papersack/smiley(drop_location())
		else
			papersack = new /obj/item/clothing/head/papersack(drop_location())
		papersack.add_fingerprint(user)
		to_chat(user, span_notice("You cut eyeholes into [src] and modify the design."))
		if(loc == user)
			user.temporarily_remove_item_from_inventory(src)
		user.put_in_hands(papersack, ignore_anim = FALSE)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/storage/box/centcomofficer
	name = "officer kit"
	icon_state = "box_ert"
	storage_slots = 14
	max_combined_w_class = 20

/obj/item/storage/box/centcomofficer/populate_contents()
	new /obj/item/clothing/mask/gas/sechailer/folded(src)
	new /obj/item/tank/internals/emergency_oxygen/double(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/kitchen/knife/combat(src)

	new /obj/item/radio/centcom(src)
	new /obj/item/door_remote/omni(src)
	new /obj/item/implanter/death_alarm(src)

	new /obj/item/reagent_containers/hypospray/combat/nanites(src)
	new /obj/item/pinpointer(src)
	new /obj/item/pinpointer/crew/centcom(src)

/obj/item/storage/box/responseteam
	name = "boxed survival kit"
	icon_state = "box_ert"

/obj/item/storage/box/responseteam/populate_contents()
	new /obj/item/clothing/mask/gas/sechailer/folded(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/radio/centcom(src)
	new /obj/item/storage/firstaid/crew(src)

// ERT set for trial admins
/obj/item/storage/box/responseteam/amber/commander
	name = "ERT Amber Commander kit"

/obj/item/storage/box/responseteam/amber/commander/populate_contents()
	new /obj/item/clothing/under/rank/centcom_officer/sensor (src)
	new /obj/item/radio/headset/ert/alt/commander (src)
	new /obj/item/card/id/ert/registration/commander (src)
	new /obj/item/pinpointer (src)
	new /obj/item/melee/baton/telescopic (src)
	new /obj/item/clothing/shoes/combat (src)
	new /obj/item/clothing/gloves/combat (src)
	new /obj/item/clothing/suit/armor/vest/ert/command (src)
	new /obj/item/clothing/glasses/hud/skills/sunglasses (src)
	new /obj/item/clothing/mask/gas/sechailer/swat (src)
	new /obj/item/gun/energy/gun/pdw9/ert (src)
	new /obj/item/clothing/head/helmet/ert/command (src)
	new /obj/item/storage/backpack/ert/commander/prespawn (src)

/obj/item/storage/backpack/ert/commander/prespawn/populate_contents()
	new /obj/item/storage/box/responseteam (src)
	new /obj/item/restraints/handcuffs (src)
	new /obj/item/storage/lockbox/mindshield (src)
	new /obj/item/flashlight/seclite (src)

/obj/item/storage/box/responseteam/amber/security
	name = "ERT Amber Security kit"

/obj/item/storage/box/responseteam/amber/security/populate_contents()
	new /obj/item/storage/box/responseteam (src)
	new /obj/item/clothing/under/rank/security/sensor (src)
	new /obj/item/storage/belt/security/response_team (src)
	new /obj/item/pda/heads/ert/security (src)
	new /obj/item/card/id/ert/registration/security (src)
	new /obj/item/clothing/shoes/combat (src)
	new /obj/item/clothing/gloves/combat (src)
	new /obj/item/clothing/suit/armor/vest/ert/security (src)
	new /obj/item/gun/energy/gun/advtaser/sibyl (src)
	new /obj/item/clothing/glasses/hud/security/sunglasses (src)
	new /obj/item/clothing/mask/gas/sechailer/swat (src)
	new /obj/item/clothing/head/helmet/ert/security (src)
	new /obj/item/storage/backpack/ert/security/trialmoment/prespawn (src)

/obj/item/storage/backpack/ert/security/trialmoment/prespawn/populate_contents()
	new /obj/item/storage/box/responseteam (src)
	new /obj/item/storage/box/zipties (src)
	new /obj/item/storage/box/teargas (src)
	new /obj/item/flashlight/seclite (src)
	new /obj/item/gun/energy/laser/sibyl (src)

/obj/item/storage/box/responseteam/amber/medic
	name = "ERT Amber Medic kit"

/obj/item/storage/box/responseteam/amber/medic/populate_contents()
	new /obj/item/clothing/under/rank/medical (src)
	new /obj/item/pda/heads/ert/medical (src)
	new /obj/item/card/id/ert/registration/medic (src)
	new /obj/item/clothing/shoes/white (src)
	new /obj/item/clothing/gloves/combat (src)
	new /obj/item/clothing/suit/armor/vest/ert/medical (src)
	new /obj/item/gun/energy/gun/pdw9/ert (src)
	new /obj/item/clothing/glasses/hud/health/sunglasses (src)
	new /obj/item/clothing/head/helmet/ert/medical (src)
	new /obj/item/clothing/mask/surgical (src)
	new /obj/item/storage/belt/medical/surgery/loaded (src)
	new /obj/item/reagent_containers/hypospray/safety/ert (src)
	new /obj/item/melee/baton/telescopic (src)
	new /obj/item/defibrillator/loaded (src)
	new /obj/item/storage/backpack/ert/medical/trialmoment/prespawn (src)
	new /obj/item/storage/firstaid/adv (src)
	new /obj/item/storage/firstaid/regular (src)
	new /obj/item/storage/pill_bottle/ert (src)
	new /obj/item/flashlight/seclite (src)

/obj/item/storage/backpack/ert/engineer/trialmoment/prespawn/populate_contents()
	new /obj/item/storage/firstaid/adv (src)
	new /obj/item/storage/firstaid/regular (src)
	new /obj/item/storage/box/autoinjectors (src)
	new /obj/item/roller/holo (src)
	new /obj/item/storage/pill_bottle/ert (src)
	new /obj/item/flashlight/seclite (src)
	new /obj/item/healthanalyzer/advanced (src)
	new /obj/item/handheld_defibrillator (src)

/obj/item/storage/box/responseteam/amber/engineer
	name = "ERT Amber Engineer kit"

/obj/item/storage/box/responseteam/amber/engineer/populate_contents()
	new /obj/item/clothing/under/rank/engineer (src)
	new /obj/item/storage/belt/utility/full/multitool (src)
	new /obj/item/pda/heads/ert/engineering (src)
	new /obj/item/card/id/ert/registration/engineering (src)
	new /obj/item/clothing/shoes/magboots (src)
	new /obj/item/clothing/gloves/combat (src)
	new /obj/item/clothing/suit/space/hardsuit/ert/engineer (src)
	new /obj/item/tank/internals/emergency_oxygen/engi (src)
	new /obj/item/clothing/glasses/meson/night (src)
	new /obj/item/clothing/mask/gas (src)
	new /obj/item/melee/baton/telescopic (src)
	new /obj/item/storage/backpack/ert/engineer/trialmoment/prespawn (src)

/obj/item/storage/backpack/ert/engineer/prespawn/trialmoment/populate_contents()
	new /obj/item/storage/box/responseteam (src)
	new /obj/item/gun/energy/gun/pdw9/ert (src)
	new /obj/item/t_scanner (src)
	new /obj/item/stack/sheet/glass/fifty (src)
	new /obj/item/stack/sheet/metal/fifty (src)
	new /obj/item/rpd (src)
	new /obj/item/flashlight (src)

/obj/item/storage/box/responseteam/amber/janitor
	name = "ERT Amber Janitor kit"

/obj/item/storage/box/responseteam/amber/janitor/populate_contents()
	new /obj/item/clothing/under/color/purple/sensor (src)
	new /obj/item/storage/belt/janitor/ert (src)
	new /obj/item/clothing/gloves/combat (src)
	new /obj/item/clothing/shoes/galoshes (src)
	new /obj/item/radio/headset/ert/alt (src)
	new /obj/item/card/id/ert/registration/janitor (src)
	new /obj/item/pda/centcom (src)
	new /obj/item/melee/baton/telescopic (src)
	new /obj/item/clothing/suit/armor/vest/ert/janitor (src)
	new /obj/item/clothing/head/helmet/ert/janitor (src)
	new /obj/item/clothing/glasses/sunglasses (src)
	new /obj/item/storage/backpack/ert/janitor/trialmoment/prespawn (src)

/obj/item/storage/backpack/ert/janitor/trialmoment/prespawn/populate_contents()
	new /obj/item/storage/box/responseteam (src)
	new /obj/item/gun/energy/gun/pdw9/ert (src)
	new /obj/item/grenade/chem_grenade/antiweed (src)
	new /obj/item/grenade/chem_grenade/antiweed (src)
	new /obj/item/reagent_containers/spray/cleaner (src)
	new /obj/item/storage/bag/trash (src)
	new /obj/item/storage/box/lights/mixed (src)
	new /obj/item/holosign_creator/janitor (src)
	new /obj/item/flashlight (src)
	new /obj/item/melee/flyswatter (src)

/obj/item/storage/box/responseteam/red/commander
	name = "ERT Red Commander kit"

/obj/item/storage/box/responseteam/red/commander/populate_contents()
	new /obj/item/clothing/under/rank/centcom_officer/sensor (src)
	new /obj/item/radio/headset/ert/alt/commander (src)
	new /obj/item/card/id/ert/registration/commander (src)
	new /obj/item/pinpointer (src)
	new /obj/item/melee/baton/telescopic (src)
	new /obj/item/clothing/shoes/combat (src)
	new /obj/item/clothing/gloves/combat (src)
	new /obj/item/clothing/suit/space/hardsuit/ert/commander (src)
	new /obj/item/clothing/glasses/sunglasses (src)
	new /obj/item/clothing/mask/gas/sechailer/swat (src)
	new /obj/item/gun/energy/gun/pdw9/ert (src)
	new /obj/item/gun/projectile/automatic/pistol/sp8/sp8t (src)
	new /obj/item/storage/backpack/ert/commander/trialmoment/prespawn (src)

/obj/item/storage/backpack/ert/commander/trialmoment/prespawn/populate_contents()
	new /obj/item/storage/box/responseteam (src)
	new /obj/item/ammo_box/magazine/sp8 (src)
	new /obj/item/ammo_box/magazine/sp8 (src)
	new /obj/item/camera_bug/ert (src)
	new /obj/item/door_remote/omni (src)
	new /obj/item/restraints/handcuffs (src)
	new /obj/item/clothing/shoes/magboots (src)
	new /obj/item/storage/lockbox/mindshield (src)
	new/obj/item/implanter/mindshield/ert (src)
	new/obj/item/implanter/death_alarm (src)

/obj/item/storage/box/responseteam/red/security
	name = "ERT Red Security kit"

/obj/item/storage/box/responseteam/red/security/populate_contents()
	new /obj/item/clothing/under/rank/security/sensor (src)
	new /obj/item/storage/belt/security/response_team (src)
	new /obj/item/pda/heads/ert/security (src)
	new /obj/item/card/id/ert/registration/security (src)
	new /obj/item/clothing/shoes/combat (src)
	new /obj/item/clothing/gloves/combat (src)
	new /obj/item/clothing/suit/space/hardsuit/ert/security (src)
	new /obj/item/gun/projectile/automatic/lasercarbine (src)
	new /obj/item/clothing/glasses/night (src)
	new /obj/item/clothing/mask/gas/sechailer/swat (src)
	new /obj/item/storage/backpack/ert/security/trialmoment/prespawn (src)

/obj/item/storage/backpack/ert/security/trialmoment/prespawn/populate_contents()
	new /obj/item/storage/box/responseteam (src)
	new	/obj/item/gun/projectile/automatic/pistol/sp8/sp8t (src)
	new /obj/item/ammo_box/magazine/sp8 (src)
	new /obj/item/ammo_box/magazine/sp8 (src)
	new /obj/item/ammo_box/magazine/sp8 (src)
	new /obj/item/clothing/shoes/magboots (src)
	new /obj/item/storage/box/handcuffs (src)
	new /obj/item/grenade/flashbang (src)
	new /obj/item/grenade/flashbang (src)
	new/obj/item/ammo_box/magazine/laser (src)
	new/obj/item/ammo_box/magazine/laser (src)
	new /obj/item/gun/energy/gun/pdw9/ert (src)
	new /obj/item/implanter/mindshield/ert (src)
	new /obj/item/implanter/death_alarm (src)

/obj/item/storage/box/responseteam/red/engineer
	name = "ERT Red Engineer kit"

/obj/item/storage/box/responseteam/red/engineer/populate_contents()
	new /obj/item/clothing/under/rank/engineer (src)
	new /obj/item/pda/heads/ert/engineering (src)
	new /obj/item/card/id/ert/registration/engineering (src)
	new /obj/item/clothing/shoes/magboots/advance (src)
	new /obj/item/clothing/gloves/combat (src)
	new /obj/item/storage/belt/utility/chief/full (src)
	new /obj/item/clothing/suit/space/hardsuit/ert/engineer (src)
	new /obj/item/tank/internals/emergency_oxygen/engi (src)
	new /obj/item/clothing/glasses/meson/night (src)
	new /obj/item/clothing/mask/gas (src)
	new /obj/item/t_scanner/extended_range (src)
	new /obj/item/melee/baton/telescopic (src)
	new /obj/item/storage/backpack/ert/engineer/trialmoment/prespawn (src)

/obj/item/storage/backpack/ert/engineer/trialmoment/prespawn/populate_contents()
	new /obj/item/storage/box/responseteam (src)
	new /obj/item/gun/projectile/automatic/pistol/sp8/sp8t (src)
	new /obj/item/ammo_box/magazine/sp8 (src)
	new /obj/item/ammo_box/magazine/sp8 (src)
	new /obj/item/rcd/preloaded (src)
	new /obj/item/rcd_ammo (src)
	new /obj/item/rcd_ammo (src)
	new /obj/item/rcd_ammo (src)
	new /obj/item/rpd (src)
	new /obj/item/gun/energy/gun/sibyl (src)
	new /obj/item/implanter/mindshield/ert (src)
	new /obj/item/implanter/death_alarm (src)

/obj/item/storage/box/responseteam/red/medic
	name = "ERT Red Medic kit"

/obj/item/storage/box/responseteam/red/medic/populate_contents()
	new /obj/item/clothing/under/rank/medical (src)
	new /obj/item/pda/heads/ert/medical (src)
	new /obj/item/card/id/ert/registration/medic (src)
	new /obj/item/clothing/shoes/white (src)
	new /obj/item/clothing/gloves/combat (src)
	new /obj/item/clothing/suit/space/hardsuit/ert/medical (src)
	new /obj/item/clothing/glasses/hud/health/sunglasses (src)
	new /obj/item/gun/energy/gun/sibyl (src)
	new /obj/item/defibrillator/compact/loaded (src)
	new /obj/item/reagent_containers/hypospray/safety/ert (src)
	new /obj/item/melee/baton/telescopic (src)
	new /obj/item/storage/backpack/ert/medical/trialmoment/prespawn (src)

/obj/item/storage/backpack/ert/medical/trialmoment/prespawn/populate_contents()
	new /obj/item/storage/box/responseteam (src)
	new /obj/item/gun/projectile/automatic/pistol/sp8/sp8t (src)
	new /obj/item/ammo_box/magazine/sp8 (src)
	new /obj/item/ammo_box/magazine/sp8 (src)
	new /obj/item/storage/firstaid/ertm (src)
	new /obj/item/clothing/mask/surgical (src)
	new /obj/item/storage/firstaid/toxin (src)
	new /obj/item/storage/firstaid/brute (src)
	new /obj/item/storage/firstaid/fire (src)
	new /obj/item/storage/box/autoinjectors (src)
	new /obj/item/roller/holo (src)
	new /obj/item/clothing/shoes/magboots (src)
	new /obj/item/bodyanalyzer (src)
	new /obj/item/healthanalyzer/advanced (src)
	new /obj/item/handheld_defibrillator (src)
	new /obj/item/implanter/mindshield/ert (src)
	new /obj/item/implanter/death_alarm (src)

/obj/item/storage/box/responseteam/red/janitor
	name = "ERT red Janitor kit"

/obj/item/storage/box/responseteam/red/janitor/populate_contents()
	new	/obj/item/clothing/under/color/purple/sensor (src)
	new /obj/item/storage/belt/janitor/ert (src)
	new /obj/item/clothing/gloves/combat (src)
	new /obj/item/clothing/shoes/galoshes (src)
	new /obj/item/radio/headset/ert/alt (src)
	new /obj/item/card/id/ert/registration/janitor (src)
	new /obj/item/pda/centcom (src)
	new /obj/item/melee/baton/telescopic (src)
	new /obj/item/clothing/suit/space/hardsuit/ert/janitor
	new /obj/item/clothing/glasses/hud/security/sunglasses
	new /obj/item/scythe/tele
	new /obj/item/storage/backpack/ert/janitor/trialmoment/prespawn(src)

/obj/item/storage/backpack/ert/janitor/trialmoment/prespawn/populate_contents()
	new /obj/item/storage/box/responseteam (src)
	new /obj/item/gun/energy/gun/pdw9/ert (src)
	new /obj/item/grenade/chem_grenade/antiweed (src)
	new /obj/item/grenade/chem_grenade/antiweed (src)
	new /obj/item/reagent_containers/spray/cleaner (src)
	new /obj/item/storage/bag/trash (src)
	new /obj/item/storage/box/lights/mixed (src)
	new /obj/item/holosign_creator/janitor (src)
	new /obj/item/flashlight (src)
	new /obj/item/melee/flyswatter (src)
	new /obj/item/gun/projectile/automatic/pistol/sp8/sp8t (src)
	new /obj/item/ammo_box/magazine/sp8 (src)
	new /obj/item/ammo_box/magazine/sp8 (src)
	new /obj/item/implanter/mindshield/ert (src)
	new /obj/item/implanter/death_alarm (src)

/obj/item/storage/box/hardsuit
	icon_state = "box_ert"
	storage_slots = 3

/obj/item/storage/box/hardsuit/engineering/response_team
	name = "Boxed engineer response team hardsuit kit"

/obj/item/storage/box/hardsuit/engineering/response_team/populate_contents()
	new /obj/item/clothing/mask/breath (src)
	new /obj/item/clothing/suit/space/hardsuit/ert/engineer (src)
	new /obj/item/tank/internals/emergency_oxygen (src)

/obj/item/storage/box/hardsuit/engineering
	name = "Boxed engineering hardsuit kit"

/obj/item/storage/box/hardsuit/engineering/populate_contents()
	new /obj/item/clothing/mask/breath (src)
	new /obj/item/clothing/suit/space/hardsuit/engine (src)
	new /obj/item/tank/internals/emergency_oxygen (src)

/obj/item/storage/box/hardsuit/medical/responseteam
	name = "Boxed medical response team hardsuit kit"

/obj/item/storage/box/hardsuit/medical/populate_contents()
	new /obj/item/clothing/mask/breath (src)
	new /obj/item/clothing/suit/space/hardsuit/ert/medical (src)
	new /obj/item/tank/internals/emergency_oxygen (src)

/obj/item/storage/box/hardsuit/medical
	name = "Boxed medical hardsuit kit"

/obj/item/storage/box/medical/populate_contents()
	new /obj/item/clothing/mask/breath (src)
	new /obj/item/clothing/suit/space/hardsuit/medical (src)
	new /obj/item/tank/internals/emergency_oxygen (src)

/obj/item/storage/box/hardsuit/janitor/response_team
	name = "Boxed janitor response team hardsuit kit"

/obj/item/storage/box/hardsuit/janitor/response_team/populate_contents()
	new /obj/item/clothing/mask/breath (src)
	new /obj/item/clothing/suit/space/hardsuit/ert/janitor (src)
	new /obj/item/tank/internals/emergency_oxygen (src)

/obj/item/storage/box/soviet
	name = "boxed survival kit"
	desc = "A standard issue Soviet military survival kit."
	icon_state = "box_soviet"

/obj/item/storage/box/soviet/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/reagent_containers/hypospray/autoinjector
	new /obj/item/flashlight/flare(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/reagent_containers/food/pill/patch/synthflesh(src)
	new /obj/item/reagent_containers/food/pill/patch/synthflesh(src)

/obj/item/storage/box/clown
	name = "clown box"
	desc = "A colorful cardboard box for the clown"
	icon_state = "box_clown"


/obj/item/storage/box/emptysandbags
	name = "box of empty sandbags"

/obj/item/storage/box/emptysandbags/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/emptysandbag(src)

/obj/item/storage/box/rndboards
	name = "the Liberator's legacy"
	desc = "A box containing a gift for worthy golems."

/obj/item/storage/box/rndboards/populate_contents()
	new /obj/item/circuitboard/protolathe(src)
	new /obj/item/circuitboard/destructive_analyzer(src)
	new /obj/item/circuitboard/circuit_imprinter(src)
	new /obj/item/circuitboard/rdconsole/public(src)

/obj/item/storage/box/stockparts/basic //for ruins where it's a bad idea to give access to an autolathe/protolathe, but still want to make stock parts accessible
	name = "box of stock parts"
	desc = "Contains a variety of basic stock parts."

/obj/item/storage/box/stockparts/basic/populate_contents()
	for(var/i in 1 to 3)
		new /obj/item/stock_parts/capacitor(src)
		new /obj/item/stock_parts/scanning_module(src)
		new /obj/item/stock_parts/manipulator(src)
		new /obj/item/stock_parts/micro_laser(src)
		new /obj/item/stock_parts/matter_bin(src)

/obj/item/storage/box/stockparts/deluxe
	name = "box of deluxe stock parts"
	desc = "Contains a variety of deluxe stock parts."
	icon_state = "stock_box_t4"

/obj/item/storage/box/stockparts/deluxe/populate_contents()
	for(var/i in 1 to 3)
		new /obj/item/stock_parts/capacitor/quadratic(src)
		new /obj/item/stock_parts/scanning_module/triphasic(src)
		new /obj/item/stock_parts/manipulator/femto(src)
		new /obj/item/stock_parts/micro_laser/quadultra(src)
		new /obj/item/stock_parts/matter_bin/bluespace(src)

/obj/item/storage/box/stockparts/experimental_parts
	name = "box of experimental stock parts"
	desc = "Contains some strange looking parts. Looks like it has some bluespace matter and something red."
	icon_state = "stock_box_t5"

/obj/item/storage/box/stockparts/experimental_parts/populate_contents()
	new /obj/item/stock_parts/capacitor/purple(src)
	new /obj/item/stock_parts/scanning_module/purple(src)
	new /obj/item/stock_parts/manipulator/purple(src)
	new /obj/item/stock_parts/micro_laser/purple(src)
	new /obj/item/stock_parts/matter_bin/purple(src)

/obj/item/storage/box/flare
	name = "Flare box"
	desc = "For emergency use."

/obj/item/storage/box/flare/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/flashlight/flare(src)

/obj/item/storage/box/bola
	name = "Energy bola box"
	desc = "Бола для самых быстрых из быстрых"

/obj/item/storage/box/bola/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/restraints/legcuffs/bola/energy(src)

/obj/item/storage/box/hug
	name = "box of hugs"
	desc = "A special box for sensitive people."
	icon_state = "hugbox"
	foldable = null

/obj/item/storage/box/hug/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] clamps the box of hugs on [user.p_their()] jugular! Guess it wasn't such a hugbox after all..</span>")
	return (BRUTELOSS)

/obj/item/storage/box/hug/attack_self(mob/user)
	..()
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(loc, "rustle", 50, 1, -5)
	user.visible_message("<span class='notice'>[user] hugs \the [src].</span>","<span class='notice'>You hug \the [src].</span>")

/obj/item/storage/box/wizard
	name = "magical box"
	desc = "It's just an ordinary magical box."
	icon_state = "box_wizard"

/obj/item/storage/box/wizard/hardsuit
	name = "Battlemage Armour Bundle"
	desc = "This box contains a bundle of Battlemage Armour"
	icon_state = "box_wizard"

/obj/item/storage/box/wizard/hardsuit/populate_contents()
	new /obj/item/clothing/suit/space/hardsuit/wizard/shielded(src)
	new /obj/item/clothing/shoes/magboots/wizard(src)

/obj/item/storage/box/wizard/recharge
	name = "Armour Recharge Bundle"
	desc = "This box contains a bundle of Battlemage Armour Recharges"
	icon_state = "box_wizard"

/obj/item/storage/box/wizard/recharge/populate_contents()
	for(var/I in 1 to 3)
		new /obj/item/wizard_armour_charge(src)

/obj/item/storage/box/wizard/kit_spell_book
	name = "набор волшебных книг"
	desc = "Набор волшебных книг, купленных в волшебной книге, для волшебников, чтобы делать волшебство! ЗВУЧИТ ПРОСТО ВОЛШЕБНО!"
	icon_state = "box_wizard"

/obj/item/storage/box/wizard/kit_spell_book/populate_contents()
		for(var/i = 1 to 4)
				new /obj/item/spellbook/oneuse/random(src)

/obj/item/storage/box/candythief
	name = "набор радужных конфет"
	desc = "Набор для самых маленьких и не уверенных в себе работников, обожающих простые пути, смешивая всевозможные в один. Поставляется с сосательной конфетой. Удобный набор если нужно где-то засесть и не выходить. Производитель не отвечает за возникающие акне и галлюцинации от вашего времяпровождения."
	icon_state = "box_thief"

/obj/item/storage/box/candythief/populate_contents()
	for(var/i in 0 to 5)
		new /obj/item/reagent_containers/food/snacks/candy/gummybear/wtf(src)
		new /obj/item/reagent_containers/food/snacks/candy/gummyworm/wtf(src)
		new /obj/item/reagent_containers/food/snacks/candy/jellybean/wtf(src)
	new /obj/item/reagent_containers/food/snacks/candy/sucker(src)

/obj/item/storage/pouch
	name = "pouch"
	desc = "Подсумок на два магазина."
	icon = 'icons/obj/storage.dmi'
	icon_state = "pouch"
	item_state = "pouch"
	storage_slots = 2
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT
	can_hold = list(/obj/item/ammo_box/magazine)


/obj/item/storage/pouch/fast
	name = "fast pouch"
	desc = "Подсумок на два магазина, настолько быстро перезаряжать оружие ещё никогда не было!"
	icon_state = "pouch_fast"
	item_state = "pouch_fast"


/obj/item/storage/pouch/fast/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/gun/projectile/automatic))
		add_fingerprint(user)
		var/obj/item/gun/projectile/automatic/gun = I
		for(var/obj/item/ammo_box/magazine/magazine in contents)
			if(!istype(magazine, gun.mag_type))
				continue
			var/obj/item/ammo_box/magazine/gun_magazine = gun.magazine
			gun.attackby(magazine, user, params)
			var/mag_changed = (gun_magazine && gun_magazine.loc != gun)
			var/success = mag_changed || (!gun_magazine && gun.magazine)
			if(mag_changed && can_be_inserted(gun_magazine))
				handle_item_insertion(gun_magazine)
				gun_magazine.update_appearance()
			if(success)
				break
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/storage/box/sec
	name = "officer starter kit"
	desc = "Коробка, что вмещает в себе все нужное дабы стать офицером! Мелким шрифтом вы можете разобрать: Не включает действительно все."

/obj/item/storage/box/sec/populate_contents()
	new /obj/item/clothing/head/helmet(src)
	new /obj/item/clothing/under/rank/security(src)
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/clothing/gloves/combat(src)
	new /obj/item/storage/backpack/security(src)
	new /obj/item/clothing/suit/armor/vest/security(src)
	new /obj/item/clothing/accessory/holster(src)
	new /obj/item/security_voucher(src)
	new /obj/item/restraints/handcuffs(src)
	new /obj/item/flash(src)
	new /obj/item/implanter/mindshield(src)

/obj/item/storage/box/dominator_kit
	name = "Dominator kit"
	icon_state = "box_dominator"

/obj/item/storage/box/dominator_kit/populate_contents()
	new /obj/item/gun/energy/dominator/sibyl(src)
	new /obj/item/clothing/accessory/holster(src)

/obj/item/storage/box/enforcer_kit
	name = "Enforcer kit"
	icon_state = "box_enforcer"

/obj/item/storage/box/enforcer_kit/populate_contents()
	new /obj/item/gun/projectile/automatic/pistol/enforcer/security(src)
	new /obj/item/ammo_box/magazine/enforcer(src)
	new /obj/item/ammo_box/magazine/enforcer(src)
	new /obj/item/clothing/accessory/holster(src)

/obj/item/storage/box/revolver_kit
	name = "Revolver kit"
	icon_state = "box_revolver"

/obj/item/storage/box/revolver_kit/populate_contents()
	new /obj/item/ammo_box/speedloader/c38(src)
	new /obj/item/ammo_box/speedloader/c38(src)
	new /obj/item/gun/projectile/revolver/detective(src)
	new /obj/item/clothing/accessory/holster/armpit(src)

/obj/item/storage/box/hardmode_box
	name = "box of HRD-MDE project box"
	desc = "Contains everything needed to get yourself killed for a medal."

/obj/item/storage/box/hardmode_box/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/grenade/megafauna_hardmode(src)
	new /obj/item/storage/lockbox/medal/hardmode_box(src)
	new /obj/item/paper/hardmode(src)

/obj/item/storage/box/random_syndi
	icon_state = "box_of_doom"
	var/static/list/allowed_uplink_items


/obj/item/storage/box/random_syndi/populate_contents()
	if(!allowed_uplink_items)
		allowed_uplink_items = list()
		for(var/datum/uplink_item/uplink_item as anything in GLOB.uplink_items)
			if(istype(uplink_item, /datum/uplink_item/racial) || uplink_item.hijack_only || uplink_item.cost > 20)
				continue
			allowed_uplink_items += uplink_item.item

	if(!length(allowed_uplink_items))
		return

	for(var/item_path in pick_multiple_unique(allowed_uplink_items, 3))
		new item_path(src)


/obj/item/storage/box/crayfish_bucket
	name = "Mr. Chang's Spicy Lobsters"
	desc = "Supply of lobsters from Mr. Chang. Crayfish instead of lobsters, super discount, great rating!"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "crayfish_bucket"
	item_state = "chinese2"
	storage_slots = 3
	display_contents_with_number = TRUE
	can_hold = list(
		/obj/item/reagent_containers/food/snacks/crayfish_cooked/mr_chang,
		/obj/item/reagent_containers/food/snacks/crayfish_cooked_small/mr_chang,
		/obj/item/reagent_containers/food/drinks/cans/beer,
	)


/obj/item/storage/box/crayfish_bucket/populate_contents()
	var/big_ones = rand(2, 4)
	var/small_ones = 5 - big_ones
	for(var/i in 1 to big_ones)
		new /obj/item/reagent_containers/food/snacks/crayfish_cooked/mr_chang(src)
	for(var/i in 1 to small_ones)
		new /obj/item/reagent_containers/food/snacks/crayfish_cooked_small/mr_chang(src)
	new /obj/item/reagent_containers/food/drinks/cans/beer(src)

/obj/item/storage/box/mr_cheng
	name = "Mr. Cheng ad agent kit"
	desc = "Contains essential advertising agent kit for Mr. Cheng"
	icon_state = "box_mr_chang"

/obj/item/storage/box/mr_cheng/populate_contents()
	new /obj/item/clothing/suit/mr_chang_coat(src)
	new /obj/item/clothing/shoes/mr_chang_sandals(src)
	new /obj/item/clothing/head/mr_chang_band(src)

/obj/item/storage/box/bombsecurity
	name = "\improper Security Bombsuit"
	desc = "It's a box with explosion-protective suit."

/obj/item/storage/box/bombclosetsecurity/populate_contents()
	new /obj/item/clothing/suit/bomb_suit/security( src )
	new /obj/item/clothing/under/rank/security( src )
	new /obj/item/clothing/shoes/brown( src )
	new /obj/item/clothing/head/bomb_hood/security( src )

/*
 *  Plant DNA Disks Box
 */
/obj/item/storage/box/disks_plantgene
	name = "plant data disks box"
	icon_state = "disk_kit"

/obj/item/storage/box/disks_plantgene/New()
	..()
	for(var/i in 1 to 7)
		new /obj/item/disk/plantgene(src)

#undef NODESIGN
#undef NANOTRASEN
#undef SYNDI
#undef HEART
#undef SMILE
