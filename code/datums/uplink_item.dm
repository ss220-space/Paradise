#define UPLINK_DISCOUNTS 4

/**
 * Proc that generates a list of items, available for certain uplink.
 *
 * Arguments:
 * * target_uplink - uplink we are checking.
 * * only_main_operations - skips sales and discounts, used for surplus crates generation.
 */
/proc/get_uplink_items(obj/item/uplink/target_uplink, generate_discounts = FALSE)
	. = list()
	var/list/sales_items = generate_discounts ? list() : null

	for(var/datum/uplink_item/uplink_item as anything in GLOB.uplink_items)
		if(length(uplink_item.uplinktypes) && !(target_uplink.uplink_type in uplink_item.uplinktypes) && target_uplink.uplink_type != UPLINK_TYPE_ADMIN)
			continue

		if(length(uplink_item.excludefrom) && (target_uplink.uplink_type in uplink_item.excludefrom) && target_uplink.uplink_type != UPLINK_TYPE_ADMIN)
			continue

		if(uplink_item.limited_stock != -1 || (uplink_item.can_discount && uplink_item.refundable))
			uplink_item = new uplink_item.type //If item has limited stock or can be discounted and refundable at same time make a copy
		. += uplink_item

		if(generate_discounts && uplink_item.limited_stock < 0 && uplink_item.can_discount && uplink_item.cost > 5)
			sales_items += uplink_item

	if(generate_discounts)
		for(var/i in 1 to UPLINK_DISCOUNTS)
			var/datum/uplink_item/discount_origin = pick_n_take(sales_items)

			var/datum/uplink_item/discount_item = new discount_origin.type
			var/discount = 0.5
			var/init_cost = initial(discount_item.cost)
			discount_item.limited_stock = 1
			if(discount_item.cost >= 100)
				discount *= 0.5 // If the item costs 100TC or more, it's only 25% off.
			discount_item.cost = max(round(discount_item.cost * (1 - discount)), 1)
			discount_item.category = "Discounted Gear"
			discount_item.name += " ([round(((init_cost - discount_item.cost) / init_cost) * 100)]% off!)"
			discount_item.job = null // If you get a job specific item selected, actually lets you buy it in the discount section
			discount_item.desc += " Limit of [discount_item.limited_stock] per uplink. Normally costs [init_cost] TC."
			discount_item.surplus = 0 // stops the surplus crate potentially giving out a bit too much

			. += discount_item

	return .


/datum/uplink_item
	/// Uplink name.
	var/name = "item name"
	/// Uplink category.
	var/category = "item category"
	/// Uplink description.
	var/desc = "Item Description"
	/// Item object, must be defined in every datum entry and must be /obj path.
	var/item
	/// Item cost in TC.
	var/cost = 0
	/// Empty list means it is in all the uplink types. Otherwise place the uplink type here.
	var/list/uplinktypes
	/// Empty list does nothing. Place the name of uplink type you don't want this item to be available in here.
	var/list/excludefrom
	/// Empty list means it is available for every job assignment.
	var/list/job
	/// Empty list means it is available for every in game species.
	var/list/race
	/// Chance of being included in the surplus crate (when pick() selects it).
	var/surplus = 100
	/// Whether item can be on sales category.
	var/can_discount = TRUE
	/// Can you only buy so many? -1 allows for infinite purchases.
	var/limited_stock = -1
	/// Can this item be purchased only with hijack objective?
	var/hijack_only = FALSE
	/// Is this item refundable?
	var/refundable = FALSE
	/// Alternative path for refunds, in case the item purchased isn't what is actually refunded (ie: holoparasites).
	var/refund_path
	/// Associative list UID - refund cost
	var/static/list/item_to_refund_cost


/datum/uplink_item/Destroy(force)
	if(force)
		return ..()
	else
		// if you're deleting an uplink item something has gone wrong
		return QDEL_HINT_LETMELIVE


/**
 * Spawns object item contained as path in datum item variable if possible.
 *
 * Arguments:
 * * buyer - mob who performs the transaction.
 * * target_uplink - uplink we are buying from.
 */
/datum/uplink_item/proc/spawn_item(mob/buyer, obj/item/uplink/target_uplink)
	. = null
	//nukies get items that regular traitors only get with hijack. If a hijack-only item is not for nukies, then exclude it via the gamemode list.
	if(hijack_only && !(buyer.mind.special_role == SPECIAL_ROLE_NUKEOPS) && !(locate(/datum/objective/hijack) in buyer.mind.get_all_objectives()) && target_uplink.uplink_type != UPLINK_TYPE_ADMIN)
		to_chat(buyer, span_warning("The Syndicate will only issue this extremely dangerous item to agents assigned the Hijack objective."))
		return .

	if(!item)
		return .

	target_uplink.uses -= max(cost, 0)
	target_uplink.used_TC += cost
	SSblackbox.record_feedback("nested tally", "traitor_uplink_items_bought", 1, list("[initial(name)]", "[cost]"))
	return new item(get_turf(buyer))


/**
 * Actulizes datum description.
 */
/datum/uplink_item/proc/description()
	if(!desc)
		// Fallback description
		var/obj/temp = item
		desc = replacetext(initial(temp.desc), "\n", "<br>")
	return desc


/**
 * Handles buying an item, and logging.
 *
 * Arguments:
 * * target_uplink - uplink we are buying from.
 * * buyer - mob who performs the transaction.
 */
/datum/uplink_item/proc/buy(obj/item/uplink/hidden/target_uplink, mob/living/carbon/human/buyer, put_in_hands = TRUE)

	if(!istype(target_uplink))
		return FALSE

	if(buyer.stat || HAS_TRAIT(buyer, TRAIT_HANDS_BLOCKED))
		return FALSE

	if(!ishuman(buyer))
		return FALSE

	// If the uplink's holder is in the user's contents
	if(!(target_uplink.loc in buyer.contents) && !(in_range(target_uplink.loc, buyer) && isturf(target_uplink.loc.loc)))
		return FALSE

	if(cost > target_uplink.uses)
		return FALSE

	. = TRUE

	buyer.set_machine(target_uplink)

	var/obj/spawned = spawn_item(buyer, target_uplink)

	if(!spawned)
		return .

	if(category == "Discounted Gear" && refundable)
		var/obj/item/refund_item
		if(istype(spawned, refund_path))
			refund_item = spawned
		else
			refund_item = locate(refund_path) in spawned

		if(!item_to_refund_cost)
			item_to_refund_cost = list()

		if(refund_item)
			item_to_refund_cost[refund_item.UID()] = cost
		else
			stack_trace("Can not find [refund_path] in [src]")

	if(limited_stock > 0)
		limited_stock--
		add_game_logs("purchased [name]. [name] was discounted to [cost].", buyer)
		if(!buyer.mind.special_role)
			message_admins("[key_name_admin(buyer)] purchased [name] (discounted to [cost]), as a non antagonist.")
	else
		add_game_logs("purchased [name].", buyer)
		if(!buyer.mind.special_role)
			message_admins("[key_name_admin(buyer)] purchased [name], as a non antagonist.")

	if(put_in_hands)
		buyer.put_in_any_hand_if_possible(spawned)

	if(istype(spawned, /obj/item/storage/box) && length(spawned.contents))
		for(var/atom/box_item in spawned)
			target_uplink.purchase_log += "<BIG>[bicon(box_item)]</BIG>"
	else
		target_uplink.purchase_log += "<BIG>[bicon(spawned)]</BIG>"

	return spawned

/*
//
//	UPLINK ITEMS
//
*/
//Work in Progress, job specific antag tools

//Discounts (dynamically filled above)

/datum/uplink_item/discounts
	category = "Discounted Gear"

//Job specific gear

/datum/uplink_item/jobspecific
	category = "Job Specific Tools"
	can_discount = FALSE
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST) // Stops the job specific category appearing for nukies

//Clown
/datum/uplink_item/jobspecific/clowngrenade
	name = "Banana Grenade"
	desc = "A grenade that explodes into HONK! brand banana peels that are genetically modified to be extra slippery and extrude caustic acid when stepped on"
	item = /obj/item/grenade/clown_grenade
	cost = 8
	job = list(JOB_TITLE_CLOWN)

/datum/uplink_item/jobspecific/cmag
	name = "Jestographic Sequencer"
	desc = "The jestographic sequencer, also known as a cmag, is a small card that inverts the access on any door it's used on. Perfect for locking command out of their own departments. Honk!"
	item = /obj/item/card/cmag
	cost = 20
	surplus = 50
	job = list(JOB_TITLE_CLOWN)

/datum/uplink_item/jobspecific/clownmagboots
	name = "Clown Magboots"
	desc = "A pair of modified clown shoes fitted with an advanced magnetic traction system. Look and sound exactly like regular clown shoes unless closely inspected."
	item = /obj/item/clothing/shoes/magboots/clown
	cost = 12
	job = list(JOB_TITLE_CLOWN)

/datum/uplink_item/jobspecific/acrobatic_shoes
	name = "Acrobatic Shoes"
	desc = "A pair of modified clown shoes are power-up with a special jumping mechanism that works on the honk-space, allowing you to do excellent acrobatic tricks!"
	item = /obj/item/clothing/shoes/bhop/clown
	cost = 12
	job = list(JOB_TITLE_CLOWN)

/datum/uplink_item/jobspecific/trick_revolver
	name = "Trick Revolver"
	desc = "A revolver that will fire backwards and kill whoever attempts to use it. Perfect for those pesky vigilante or just a good laugh."
	item = /obj/item/storage/box/syndie_kit/fake_revolver
	cost = 5
	job = list(JOB_TITLE_CLOWN)

//Mime
/datum/uplink_item/jobspecific/caneshotgun
	name = "Cane Shotgun and Assassination Shells"
	desc = "A specialised, one shell shotgun with a built-in cloaking device to mimic a cane. The shotgun is capable of hiding it's contents and the pin alongside being supressed. Comes boxed with 6 specialised shrapnel rounds laced with a silencing toxin and 1 preloaded in the shotgun's chamber."
	item = /obj/item/storage/box/syndie_kit/caneshotgun
	cost = 25
	job = list(JOB_TITLE_MIME)

/datum/uplink_item/jobspecific/mimery
	name = "Guide to Advanced Mimery Series"
	desc = "Contains two manuals to teach you advanced Mime skills. You will be able to shoot stunning bullets out of your fingers, and create large walls that can block an entire hallway!"
	item = /obj/item/storage/box/syndie_kit/mimery
	cost = 30
	job = list(JOB_TITLE_MIME)

/datum/uplink_item/jobspecific/mimejutsu
	name = "Mimejutsu manual"
	desc =	"An old manual of the martial art of mimes."
	item = /obj/item/mimejutsu_scroll
	cost = 40
	job = list(JOB_TITLE_MIME)

/datum/uplink_item/jobspecific/combat_baking
	name = "Combat Bakery Kit"
	desc = "A kit of clandestine baked weapons. Contains a baguette which a skilled mime could use as a sword, \
		a pair of throwing croissants, and the recipe to make more on demand. Once the job is done, eat the evidence."
	item = /obj/item/storage/box/syndie_kit/combat_baking
	cost = 25
	job = list(JOB_TITLE_MIME, JOB_TITLE_CHEF)

//Miner
/datum/uplink_item/jobspecific/pressure_mod
	name = "Kinetic Accelerator Pressure Mod"
	desc = "A modification kit which allows Kinetic Accelerators to do greatly increased damage while indoors. Occupies 35% mod capacity."
	item = /obj/item/borg/upgrade/modkit/indoors
	cost = 18 //you need two for full damage, so total of 8 for maximum damage
	job = list(JOB_TITLE_MINER, JOB_TITLE_QUARTERMASTER)

/datum/uplink_item/jobspecific/mining_charge_hacker
	name = "Mining Charge Hacker"
	desc = "Looks and functions like an advanced mining scanner, but allows mining charges to be placed anywhere and destroy more than rocks. \
	Use it on a mining charge to override its safeties. Reduces explosive power of mining charges due to the modification of their internals."
	item = /obj/item/t_scanner/adv_mining_scanner/syndicate
	cost = 20
	job = list(JOB_TITLE_MINER, JOB_TITLE_QUARTERMASTER)

//Chef
/datum/uplink_item/jobspecific/specialsauce
	name = "Chef Excellence's Special Sauce"
	desc = "A custom sauce made from the highly poisonous fly amanita mushrooms. Anyone who ingests it will take variable toxin damage depending on how long it has been in their system, with a higher dosage taking longer to metabolize."
	item = /obj/item/reagent_containers/food/condiment/syndisauce
	cost = 1
	job = list(JOB_TITLE_CHEF)

/datum/uplink_item/jobspecific/meatcleaver
	name = "Meat Cleaver"
	desc = "A mean looking meat cleaver that does damage comparable to an Energy Sword but with the added benefit of chopping your victim into hunks of meat after they've died."
	item = /obj/item/kitchen/knife/butcher/meatcleaver
	cost = 20
	job = list(JOB_TITLE_CHEF)

/datum/uplink_item/jobspecific/syndidonk
	name = "Syndicate Donk Pockets"
	desc = "A box of highly specialized Donk pockets with a number of regenerative and stimulating chemicals inside of them; the box comes equipped with a self-heating mechanism."
	item = /obj/item/storage/box/syndidonkpockets
	cost = 10
	job = list(JOB_TITLE_CHEF)

/datum/uplink_item/jobspecific/CQC_upgrade
	name = "CQC Upgrade implant"
	desc = "Contain special implant for chefs, which destroy safety check their innate CQC implant, allow them to use martial art outside the kitchen. Use in hand."
	item = /obj/item/CQC_manual/chef
	cost = 30
	job = list(JOB_TITLE_CHEF)
	surplus = 0 //because it's useless for all non-chefs

/datum/uplink_item/jobspecific/dangertray
	name = "Dangerous Tray pack"
	desc = "Contains a set of three sharp metal trays capable of cutting off limbs. "
	item = /obj/item/storage/box/syndie_kit/dangertray
	cost = 15
	job = list(JOB_TITLE_CHEF)

//Chaplain
/datum/uplink_item/jobspecific/voodoo
	name = "Voodoo Doll"
	desc = "A doll created by Syndicate Witch Doctors. Ingredients: Something of the Thread, Something of the Head, Something of the Body, Something of the Dead, Secret Voodoo herbs, and Monosodium glutamate."
	item = /obj/item/voodoo
	cost = 11
	job = list(JOB_TITLE_CHAPLAIN)

/datum/uplink_item/jobspecific/missionary_kit
	name = "Missionary Starter Kit"
	desc = "A box containing a missionary staff, missionary robes, and bible. The robes and staff can be linked to allow you to convert victims at range for a short time to do your bidding. The bible is for bible stuff."
	item = /obj/item/storage/box/syndie_kit/missionary_set
	cost = 72
	job = list(JOB_TITLE_CHAPLAIN)

/datum/uplink_item/jobspecific/artistic_toolbox
	name = "Artistic Toolbox"
	desc = "An accursed toolbox that grants its followers extreme power at the cost of requiring repeated sacrifices to it. If sacrifices are not provided, it will turn on its follower."
	item = /obj/item/storage/toolbox/green/memetic
	cost = 100
	job = list(JOB_TITLE_CHAPLAIN, JOB_TITLE_CIVILIAN)
	surplus = 0 //No lucky chances from the crate; if you get this, this is ALL you're getting
	hijack_only = TRUE //This is a murderbone weapon, as such, it should only be available in those scenarios.

/datum/uplink_item/jobspecific/book_of_babel
	name = "Book of Babel"
	desc = "An ancient tome written in countless tongues. Despite this fact, you can read this book effortlessly, to learn all the existing languages. Don't ask questions."
	item = /obj/item/book_of_babel
	cost = 1
	job = list(JOB_TITLE_CHAPLAIN, JOB_TITLE_LIBRARIAN)
	surplus = 0
	can_discount = FALSE

//Janitor
/datum/uplink_item/jobspecific/cautionsign
	name = "Proximity Mine"
	desc = "An Anti-Personnel proximity mine cleverly disguised as a wet floor caution sign that is triggered by running past it, activate it to start the 15 second timer and activate again to disarm."
	item = /obj/item/caution/proximity_sign
	cost = 11
	job = list(JOB_TITLE_JANITOR)
	surplus = 0

/datum/uplink_item/jobspecific/holomine
	name = "Holomine Projector"
	desc = "Projector that can set up to 5 stun mines with additional EMP effect."
	item = /obj/item/holosign_creator/janitor/syndie
	cost = 40
	job = list(JOB_TITLE_JANITOR)
	surplus = 0

//Medical
/datum/uplink_item/jobspecific/rad_laser
	name = "Radiation Laser"
	desc = "A radiation laser concealed inside of a Health Analyzer. After a moderate delay, causes temporary collapse and radiation. Has adjustable controls, but will not function as a regular health analyzer, only appears like one. May not function correctly on radiation resistant humanoids!"
	item = /obj/item/rad_laser
	cost = 23
	job = list(JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_INTERN, JOB_TITLE_GENETICIST, JOB_TITLE_PSYCHIATRIST, \
			JOB_TITLE_CHEMIST, JOB_TITLE_PARAMEDIC, JOB_TITLE_CORONER, JOB_TITLE_VIROLOGIST)

/datum/uplink_item/jobspecific/batterer
	name = "Mind Batterer"
	desc = "A device that has a chance of knocking down people around you for a long amount of time or slowing them down. The user is unaffected. Each charge takes 2 minutes to recharge."
	item = /obj/item/batterer
	cost = 50
	job = list(JOB_TITLE_CMO, JOB_TITLE_PSYCHIATRIST)

/datum/uplink_item/jobspecific/dna_upgrader
	name = "Genetic Superiority Injector"
	desc = "Experimental DNA injector which will give you one advanced gene modification and increase your gene stability."
	item = /obj/item/dna_upgrader
	cost = 55
	job = list(JOB_TITLE_CMO, JOB_TITLE_GENETICIST)
	surplus = 0

/datum/uplink_item/jobspecific/laser_eyes_injector
	name = "Laser Eyes Injector"
	desc = "Эксперементальный ДНК инжектор, который навсегда даст вам способность стрелять лазерами из глаз."
	item = /obj/item/laser_eyes_injector
	cost = 37
	job = list(JOB_TITLE_GENETICIST)
	surplus = 0

//Virology
/datum/uplink_item/jobspecific/viral_injector
	name = "Viral Injector"
	desc = "A modified hypospray disguised as a functional pipette. The pipette can infect victims with viruses upon injection."
	item = /obj/item/reagent_containers/dropper/precision/viral_injector
	cost = 15
	job = list(JOB_TITLE_VIROLOGIST)

/datum/uplink_item/jobspecific/cat_grenade
	name = "Feral Cat Delivery Grenade"
	desc = "The feral cat delivery grenade contains 5 dehydrated feral cats in a similar manner to dehydrated monkeys, which, upon detonation, will be rehydrated by a small reservoir of water contained within the grenade. These cats will then attack anything in sight."
	item = /obj/item/grenade/spawnergrenade/feral_cats
	cost = 3
	job = list(JOB_TITLE_PSYCHIATRIST)//why? Becuase its funny that a person in charge of your mental wellbeing has a cat granade..

/datum/uplink_item/jobspecific/gbs
	name = "GBS virus bottle"
	desc = "A bottle containing Gravitokinetic Bipotential SADS culture. Also known as GBS, extremely deadly virus."
	item = /obj/item/reagent_containers/glass/bottle/gbs
	cost = 60
	job = list(JOB_TITLE_VIROLOGIST)
	surplus = 0
	hijack_only = TRUE

/datum/uplink_item/jobspecific/lockermech
	name = "Syndie Locker Mech"
	desc = "A massive and incredibly deadly Syndicate exosuit(Not really)."
	item = /obj/mecha/combat/lockersyndie/loaded
	cost = 25
	job = list(JOB_TITLE_CIVILIAN, JOB_TITLE_ROBOTICIST)
	surplus = 0

/datum/uplink_item/jobspecific/stungloves
	name = "Stungloves"
	desc = "A pair of sturdy shock gloves with insulated layer. Protects user from electric shock and allows to shock enemies."
	item = /obj/item/storage/box/syndie_kit/stungloves
	cost = 7
	job = list(JOB_TITLE_CIVILIAN, JOB_TITLE_MECHANIC, JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_CHIEF)

//Bartender
/datum/uplink_item/jobspecific/drunkbullets
	name = "Boozey Shotgun Shells"
	desc = "A box containing 6 shotgun shells that simulate the effects of extreme drunkenness on the target, more effective for each type of alcohol in the target's system."
	item = /obj/item/storage/belt/bandolier/booze
	cost = 15
	job = list(JOB_TITLE_BARTENDER)

//Barber
/datum/uplink_item/jobspecific/safety_scissors //Hue
	name = "Safety Scissors"
	desc = "A pair of scissors that are anything but what their name implies; can easily cut right into someone's throat."
	item = /obj/item/scissors/safety
	cost = 6
	job = list(JOB_TITLE_BARBER)

//Botanist
/datum/uplink_item/jobspecific/bee_briefcase
	name = "Briefcase Full of Bees"
	desc = "A seemingly innocent briefcase full of not-so-innocent Syndicate-bred bees. Inject the case with blood to train the bees to ignore the donor(s). It also wirelessly taps into station intercomms to broadcast a message of TERROR."
	item = /obj/item/bee_briefcase
	cost = 22
	job = list(JOB_TITLE_BOTANIST)

/datum/uplink_item/jobspecific/gatfruit
	name = "Gatfruit seeds"
	desc = "Seeds of the Gatfruit plant, the fruits eaten will produce a .36 caliber revolver! It also contains chemicals 10% sulfur, 10% carbon, 7% nitrogen, 5% potassium."
	item = /obj/item/seeds/gatfruit
	cost = 22
	job = list(JOB_TITLE_BOTANIST)

//Engineer
/datum/uplink_item/jobspecific/powergloves
	name = "Power Gloves"
	desc = "Insulated gloves that can utilize the power of the station to deliver a short arc of electricity at a target. Must be standing on a powered cable to use."
	item = /obj/item/clothing/gloves/color/yellow/power
	cost = 33
	job = list(JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_CHIEF)

/datum/uplink_item/jobspecific/supertoolbox
	name = "Superior Suspicious Toolbox"
	desc = "Ultimate version of all toolboxes, this one more robust and more useful than his cheaper version. Comes with experimental type tools, combat gloves and cool sunglasses."
	item = /obj/item/storage/toolbox/syndisuper
	cost = 8
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	job = list(JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_CHIEF, \
			JOB_TITLE_MECHANIC, JOB_TITLE_ROBOTICIST, JOB_TITLE_PARAMEDIC)

//RD
/datum/uplink_item/jobspecific/telegun
	name = "Telegun"
	desc = "An extremely high-tech energy gun that utilizes bluespace technology to teleport away living targets. Select the target beacon on the telegun itself; projectiles will send targets to the beacon locked onto."
	item = /obj/item/gun/energy/telegun
	cost = 66
	job = list(JOB_TITLE_RD)

//Roboticist
/datum/uplink_item/jobspecific/syndiemmi
	name = "Syndicate MMI"
	desc = "A syndicate developed man-machine-interface which will make any cyborg it is inserted into follow the standard syndicate lawset."
	item = /obj/item/mmi/syndie
	cost = 6
	job = list(JOB_TITLE_ROBOTICIST)
	surplus = 0

/datum/uplink_item/jobspecific/missilemedium
	name = "SRM-8 Missile Rack"
	desc = "Those missile launcher are known to be used on high-end mechs like mauler and marauder. Way more powerful, than missile modules you can print on standard mech fabs. It comes without lockbox - plug and play!"
	item = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/medium
	cost = 50
	job = list(JOB_TITLE_ROBOTICIST)
	surplus = 0
	can_discount = FALSE
	hijack_only = TRUE

//Librarian
/datum/uplink_item/jobspecific/etwenty
	name = "The E20"
	desc = "A seemingly innocent die, those who are not afraid to roll for attack will find it's effects quite explosive. Has a four second timer."
	item = /obj/item/dice/d20/e20
	cost = 8
	job = list(JOB_TITLE_LIBRARIAN)
	surplus = 0
	hijack_only = TRUE

/datum/uplink_item/jobspecific/random_spell_book
	name = "Random spell book"
	desc = "A random spell book stolen from the wizards federation."
	item = /obj/item/spellbook/oneuse/random
	cost = 25
	job = list(JOB_TITLE_LIBRARIAN)
	can_discount = FALSE

/datum/uplink_item/jobspecific/dice_of_fate
	name = "Dice of fate"
	desc = "Everything or nothing; that is my motto."
	item = /obj/item/dice/d20/fate/one_use
	cost = 100
	job = list(JOB_TITLE_LIBRARIAN)
	surplus = 0
	can_discount = FALSE

//Botanist
/datum/uplink_item/jobspecific/ambrosiacruciatus
	name = "Ambrosia Cruciatus Seeds"
	desc = "Part of the notorious Ambrosia family, this species is nearly indistinguishable from Ambrosia Vulgaris- but its' branches contain a revolting toxin. Eight units are enough to drive victims insane."
	item = /obj/item/seeds/ambrosia/cruciatus
	cost = 4
	job = list(JOB_TITLE_BOTANIST)

//Atmos Tech
/datum/uplink_item/jobspecific/contortionist
	name = "Contortionist's Jumpsuit"
	desc = "A highly flexible jumpsuit that will help you navigate the ventilation loops of the station internally. Comes with pockets and ID slot, but can't be used without stripping off most gear, including backpack, belt, helmet, and exosuit. Free hands are also necessary to crawl around inside."
	item = /obj/item/clothing/under/contortionist
	cost = 50
	job = list(JOB_TITLE_ATMOSTECH, JOB_TITLE_CHIEF)

/datum/uplink_item/jobspecific/energizedfireaxe
	name = "Energized Fire Axe"
	desc = "A fire axe with a massive energy charge built into it. Upon striking someone while charged it will throw them backwards while stunning them briefly, but will take some time to charge up again. It is also much sharper than a regular axe and can pierce light armor."
	item = /obj/item/twohanded/fireaxe/energized
	cost = 18
	job = list(JOB_TITLE_ATMOSTECH, JOB_TITLE_CHIEF)

//CE
/datum/uplink_item/jobspecific/combat_rcd
	name = "Syndicate RCD"
	desc = "Special RCD capable to destroy reinforced walls and have 500 matter units instead of 100."
	item = /obj/item/rcd/combat
	cost = 25
	job = list(JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_MECHANIC, JOB_TITLE_ATMOSTECH, JOB_TITLE_CHIEF)
	surplus = 0

//Tator Poison Bottles

/datum/uplink_item/jobspecific/poisonbottle
	name = "Poison Bottle"
	desc = "The Syndicate will ship a bottle containing 40 units of a randomly selected poison. The poison can range from highly irritating to incredibly lethal."
	item = /obj/item/reagent_containers/glass/bottle/traitor
	cost = 10
	job = list(JOB_TITLE_RD, JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_INTERN, JOB_TITLE_PSYCHIATRIST, \
			JOB_TITLE_CHEMIST, JOB_TITLE_PARAMEDIC, JOB_TITLE_VIROLOGIST, JOB_TITLE_BARTENDER, JOB_TITLE_CHEF)

// Paper contact poison pen

/datum/uplink_item/jobspecific/poison_pen
	name = "Poison Pen"
	desc = "Cutting edge of deadly writing implements technology, this gadget will infuse any piece of paper with delayed contact poison."
	item = /obj/item/pen/poison
	cost = 5
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	job = list(JOB_TITLE_HOP, JOB_TITLE_QUARTERMASTER, JOB_TITLE_CARGOTECH, JOB_TITLE_LIBRARIAN)


// Racial

/datum/uplink_item/racial
	category = "Racial Specific Tools"
	can_discount = FALSE
	surplus = 0
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

//IPC

/datum/uplink_item/racial/ipc_combat_upgrade
	name = "Ipc combat upgrade"
	desc = "Advanced data storage designed to be compatible with positronic systems.This one include melee algorithms along with overwritten microbattery safety protocols."
	item = /obj/item/ipc_combat_upgrade
	cost = 11
	race = list(SPECIES_MACNINEPERSON)

/datum/uplink_item/racial/supercharge
	name = "Supercharge Implant"
	desc = "An implant injected into the body, and later activated manually to inject a chemical cocktail, which has the effect of removing and reducing the time of all stuns and increasing movement speed. Can be activated up to 3 times."
	item = /obj/item/implanter/supercharge
	cost = 40
	race = list(SPECIES_MACNINEPERSON)


//Slime People

/datum/uplink_item/racial/anomaly_extract
	name = "Anomaly extract"
	desc = "The result of the work of scientists on mixing an experimental stable mutagen with the core of a pyroclastic anomaly. Gives the user the opportunity to become a slime and heat himself up."
	item = /obj/item/anomaly_extract
	cost = 40
	race = list(SPECIES_SLIMEPERSON)

//Plasmaman

/datum/uplink_item/racial/plasma_chameleon
	name = "Plasmaman Chameleon Kit"
	desc = "A set of items that contain chameleon technology allowing you to disguise as pretty much anything on the station, and more! \
			Due to budget cuts, the shoes don't provide protection against slipping. The set comes with a complementary chameleon stamp. Only for Plasmamen."
	item = /obj/item/storage/box/syndie_kit/plasma_chameleon
	cost = 20
	race = list(SPECIES_PLASMAMAN)

//Nucleation

/datum/uplink_item/racial/second_chance
	name = "Second Chance Implant"
	desc = "An implant injected into the body, and later activated at the user's will. It will simulate the death of the operator and transport him to an exact safe place."
	item = /obj/item/implanter/second_chance
	cost = 40
	race = list(SPECIES_NUCLEATION)

//Human

/datum/uplink_item/racial/holo_cigar
	name = "Holo-Cigar"
	desc = "A holo-cigar imported from the Sol system. The full effects of looking so badass aren't understood yet, but users show an increase in precision while dual-wielding firearms."
	item = /obj/item/clothing/mask/holo_cigar
	cost = 10
	race = list(SPECIES_HUMAN)

//Grey

/datum/uplink_item/racial/agent_belt
	name = "Agent Belt"
	desc = "A military toolbelt used by abductor agents. Contains a full set of alien tools."
	item = /obj/item/storage/belt/military/abductor/full
	cost = 16
	race = list(SPECIES_GREY)

/datum/uplink_item/racial/silencer
	name = "Abductor Silencer"
	desc = "A compact device used to shut down communications equipment."
	item = /obj/item/abductor/silencer
	cost = 12
	race = list(SPECIES_GREY)


// DANGEROUS WEAPONS

/datum/uplink_item/dangerous
	category = "Highly Visible and Dangerous Weapons"

/datum/uplink_item/dangerous/minotaur
	name = "AS-12 'Minotaur' Shotgun"
	desc = "A modern, burst firing, mag-fed combat shotgun, that uses 12g ammo. Holds a 12/24 round drums, perfect for cleaning out crowds of people in narrow corridors. Welcome to the Minotaur's labyrinth!"
	item = /obj/item/gun/projectile/automatic/shotgun/minotaur
	cost = 80
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

/datum/uplink_item/dangerous/pistol
	name = "Stechkin Pistol"
	desc = "A small, easily concealable handgun that uses 10mm auto rounds in 8-round magazines and is compatible with suppressors."
	item = /obj/item/gun/projectile/automatic/pistol
	cost = 20

/datum/uplink_item/dangerous/revolver
	name = "Syndicate .357 Revolver"
	desc = "A brutally simple syndicate revolver that fires .357 Magnum cartridges and has 7 chambers."
	item = /obj/item/gun/projectile/revolver
	cost = 50
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 50

/datum/uplink_item/dangerous/deagle
	name = "Desert Eagle"
	desc = "A legendary high power pistol that uses 7 rounds .50AE magazines."
	item = /obj/item/gun/projectile/automatic/pistol/deagle
	cost = 50
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/dangerous/uzi
	name = "Type U3 Uzi"
	desc = "A fully-loaded lightweight blowback-operated submachine gun that uses 30-rounds 9mm magazines."
	item = /obj/item/gun/projectile/automatic/mini_uzi
	cost = 60
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/dangerous/smg
	name = "C-20r Submachine Gun"
	desc = "A fully-loaded Scarborough Arms bullpup submachine gun that fires .45 rounds with a 20-round magazine and is compatible with suppressors."
	item = /obj/item/gun/projectile/automatic/c20r
	cost = 70
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 40

/datum/uplink_item/dangerous/carbine
	name = "M-90gl Carbine"
	desc = "A fully-loaded three-round burst carbine that uses 30-round 5.56mm magazines with a togglable underslung 40mm grenade launcher."
	item = /obj/item/gun/projectile/automatic/m90
	cost = 80
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 50

/datum/uplink_item/dangerous/machinegun
	name = "L6 Squad Automatic Weapon"
	desc = "A fully-loaded Aussec Armory belt-fed machine gun. This deadly weapon has a massive 50-round magazine of devastating 7.62x51mm ammunition."
	item = /obj/item/gun/projectile/automatic/l6_saw
	cost = 175
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

/datum/uplink_item/dangerous/rapid
	name = "Gloves of the North Star"
	desc = "These gloves let the user punch people very fast. Does not improve weapon attack speed."
	item = /obj/item/clothing/gloves/fingerless/rapid
	cost = 16

/datum/uplink_item/dangerous/sniper
	name = "Sniper Rifle"
	desc = "Ranged fury, Syndicate style. guaranteed to cause shock and awe or your TC back!"
	item = /obj/item/gun/projectile/automatic/sniper_rifle/syndicate
	cost = 100
	surplus = 25
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/dangerous/sniper_compact //For when you really really hate that one guy.
	name = "Compact Sniper Rifle"
	desc = "A compact, unscoped version of the operative sniper rifle. Packs a powerful punch, but ammo is limited."
	item = /obj/item/gun/projectile/automatic/sniper_rifle/compact
	cost = 40
	surplus = 0
	can_discount = FALSE
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/dangerous/crossbow
	name = "Energy Crossbow"
	desc = "A miniature energy crossbow that is small enough both to fit into a pocket and to slip into a backpack unnoticed by observers. Fires bolts tipped with toxin, a poisonous substance that is the product of a living organism. Stuns enemies for a short period of time. Recharges automatically."
	item = /obj/item/gun/energy/kinetic_accelerator/crossbow
	cost = 48
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 50

/datum/uplink_item/dangerous/flamethrower
	name = "Flamethrower"
	desc = "A flamethrower, fuelled by a portion of highly flammable bio-toxins stolen previously from Nanotrasen stations. Make a statement by roasting the filth in their own greed. Use with caution."
	item = /obj/item/flamethrower/full/tank
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 40

/datum/uplink_item/dangerous/sword
	name = "Energy Sword"
	desc = "The energy sword is an edged weapon with a blade of pure energy. The sword is small enough to be pocketed when inactive. Activating it produces a loud, distinctive noise."
	item = /obj/item/melee/energy/sword/saber
	cost = 40

/datum/uplink_item/dangerous/powerfist
	name = "Power Fist"
	desc = "The power-fist is a metal gauntlet with a built-in piston-ram powered by an external gas supply.\
		 Upon hitting a target, the piston-ram will extend foward to make contact for some serious damage. \
		 Using a wrench on the piston valve will allow you to tweak the amount of gas used per punch to \
		 deal extra damage and hit targets further. Use a screwdriver to take out any attached tanks."
	item = /obj/item/melee/powerfist
	cost = 18

/datum/uplink_item/dangerous/chainsaw
	name = "Chainsaw"
	desc = "A high powered chainsaw for cutting up ...you know...."
	item = /obj/item/twohanded/chainsaw
	cost = 60

/datum/uplink_item/dangerous/rapier
	name = "Syndicate rapier"
	desc = "An elegant plastitanium rapier with a diamond tip and coated in a specialized knockout poison. The rapier comes with its own sheath, and is capable of puncturing through almost any defense. However, due to the size of the blade and obvious nature of the sheath, the weapon stands out as being obviously nefarious."
	item = /obj/item/storage/belt/rapier/syndie
	cost = 40

/datum/uplink_item/dangerous/commando_kit
	name = "Commandos knife operation kit"
	desc = "A box that smells like a mix of gunpowder, napalm and cheap whiskey.  Contains everything you need to survive in such places."
	item = /obj/item/storage/box/syndie_kit/commando_kit
	cost = 33
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

// SUPPORT AND MECHAS

/datum/uplink_item/support
	category = "Support and Mechanized Exosuits"
	surplus = 0
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/support/gygax
	name = "Gygax Exosuit"
	desc = "A lightweight exosuit, painted in a dark scheme. Its speed and equipment selection make it excellent for hit-and-run style attacks. \
	This model lacks a method of space propulsion, and therefore it is advised to repair the mothership's teleporter if you wish to make use of it."
	item = /obj/mecha/combat/gygax/dark/loaded
	cost = 400

/datum/uplink_item/support/rover
	name = "Rover Exosuit"
	desc = "A syndicate version of durand designed for teamwork. Has an abillity to create a forcewalls that only syndicate members can pass through."
	item = /obj/mecha/combat/durand/rover/loaded
	cost = 500

/datum/uplink_item/support/mauler
	name = "Mauler Exosuit"
	desc = "A massive and incredibly deadly Syndicate exosuit. Features long-range targeting, thrust vectoring, and deployable smoke."
	item = /obj/mecha/combat/marauder/mauler/loaded
	cost = 700

/datum/uplink_item/support/reinforcement
	name = "Reinforcement"
	desc = "Call in an additional team member. They won't come with any gear, so you'll have to save some telecrystals \
			to arm them as well."
	item = /obj/item/antag_spawner/nuke_ops
	refund_path = /obj/item/antag_spawner/nuke_ops
	cost = 100
	refundable = TRUE
	can_discount = FALSE

/datum/uplink_item/support/reinforcement/assault_borg
	name = "Syndicate Assault Cyborg"
	desc = "A cyborg designed and programmed for systematic extermination of non-Syndicate personnel. \
			Comes equipped with a self-resupplying LMG, a grenade launcher, energy sword, emag, pinpointer, flash and crowbar."
	item = /obj/item/antag_spawner/nuke_ops/borg_tele/assault
	refund_path = /obj/item/antag_spawner/nuke_ops/borg_tele/assault
	cost = 325

/datum/uplink_item/support/reinforcement/medical_borg
	name = "Syndicate Medical Cyborg"
	desc = "A combat medical cyborg. Has limited offensive potential, but makes more than up for it with its support capabilities. \
			It comes equipped with a nanite hypospray, a medical beamgun, combat defibrillator, full surgical kit including an energy saw, an emag, pinpointer and flash. \
			Thanks to its organ storage bag, it can perform surgery as well as any humanoid."
	item = /obj/item/antag_spawner/nuke_ops/borg_tele/medical
	refund_path = /obj/item/antag_spawner/nuke_ops/borg_tele/medical
	cost = 175

/datum/uplink_item/support/reinforcement/saboteur_borg
	name = "Syndicate Saboteur Cyborg"
	desc = "A streamlined engineering cyborg, equipped with covert modules and engineering equipment. Also incapable of leaving the welder in the shuttle. \
			Its chameleon projector lets it disguise itself as a Nanotrasen cyborg, on top it has thermal vision and a pinpointer."
	item = /obj/item/antag_spawner/nuke_ops/borg_tele/saboteur
	refund_path = /obj/item/antag_spawner/nuke_ops/borg_tele/saboteur

/datum/uplink_item/dangerous/foamsmg
	name = "Toy Submachine Gun"
	desc = "A fully-loaded Donksoft bullpup submachine gun that fires riot grade rounds with a 20-round magazine."
	item = /obj/item/gun/projectile/automatic/c20r/toy
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

/datum/uplink_item/dangerous/foammachinegun
	name = "Toy Machine Gun"
	desc = "A fully-loaded Donksoft belt-fed machine gun. This weapon has a massive 50-round magazine of devastating riot grade darts, that can briefly incapacitate someone in just one volley."
	item = /obj/item/gun/projectile/automatic/l6_saw/toy
	cost = 50
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

/datum/uplink_item/dangerous/guardian
	name = "Holoparasites"
	desc = "Though capable of near sorcerous feats via use of hardlight holograms and nanomachines, they require an organic host as a home base and source of fuel. \
			The holoparasites are unable to incoporate themselves to changeling and vampire agents."
	item = /obj/item/storage/box/syndie_kit/guardian
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	cost = 69
	refund_path = /obj/item/guardiancreator/tech/choose
	refundable = TRUE
	can_discount = TRUE

// Ammunition

/datum/uplink_item/ammo
	category = "Ammunition"
	surplus = 40

/datum/uplink_item/ammo/pistol
	name = "Stechkin - Two 10mm Magazines"
	desc = "A 2 additional 8-round 10mm magazines for use in the syndicate pistol, loaded with rounds that are cheap but around half as effective as .357"
	item = /obj/item/storage/box/syndie_kit/pistol_ammo
	cost = 5

/datum/uplink_item/ammo/pistolap
	name = "Stechkin - 10mm Armour Piercing Magazine"
	desc = "An additional 8-round 10mm magazine for use in the syndicate pistol, loaded with rounds that are less effective at injuring the target but penetrate protective gear."
	item = /obj/item/ammo_box/magazine/m10mm/ap
	cost = 5

/datum/uplink_item/ammo/pistolfire
	name = "Stechkin - 10mm Incendiary Magazine"
	desc = "An additional 8-round 10mm magazine for use in the syndicate pistol, loaded with incendiary rounds which ignite the target."
	item = /obj/item/ammo_box/magazine/m10mm/fire
	cost = 5

/datum/uplink_item/ammo/pistolhp
	name = "Stechkin - 10mm Hollow Point Magazine"
	desc = "An additional 8-round 10mm magazine for use in the syndicate pistol, loaded with rounds which are more damaging but ineffective against armour."
	item = /obj/item/ammo_box/magazine/m10mm/hp
	cost = 5

/datum/uplink_item/ammo/bullbuck
	name = "Drum - 12g Buckshot"
	desc = "An additional 12-round buckshot magazine for use in the auto shotguns. Front towards enemy."
	item = /obj/item/ammo_box/magazine/m12g
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bulldragon
	name = "Drum - 12g Dragon's Breath"
	desc = "An alternative 12-round dragon's breath magazine for use in the auto shotguns. I'm a fire starter, twisted fire starter!"
	item = /obj/item/ammo_box/magazine/m12g/dragon
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bullflechette
	name = "Drum - 12g Flechette"
	desc = "An additional 12-round flechette magazine for use in the auto shotguns. Works well against armour."
	item = /obj/item/ammo_box/magazine/m12g/flechette
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bullterror
	name = "Drum - 12g Bioterror"
	desc = "An alternative 12-round bioterror magazine for use in the auto shotguns. Extremely toxic!"
	item = /obj/item/ammo_box/magazine/m12g/bioterror
	cost = 15
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bullmeteor
	name = "Drum - 12g Meteor"
	desc = "An alternative 12-round breaching magazine for use in the auto shotguns. This ammo should be illegal!"
	item = /obj/item/ammo_box/magazine/m12g/breach
	cost = 25
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bull_XLbuck
	name = "Extended drum - 12g Buckshot"
	desc = "An additional 24-round buckshot magazine for use in the auto shotguns. Front towards enemy."
	item = /obj/item/ammo_box/magazine/m12g/XtrLrg
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bull_XLflechette
	name = "Extended drum - 12g Flechette"
	desc = "An additional 24-round flechette magazine for use in the auto shotguns. Works well against armour."
	item = /obj/item/ammo_box/magazine/m12g/XtrLrg/flechette
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bull_XLdragon
	name = "Extended drum - 12g Dragon's Breath"
	desc = "An additional 24-round dragon's breath magazine for use in the auto shotguns. I'm a fire starter, twisted fire starter!"
	item = /obj/item/ammo_box/magazine/m12g/XtrLrg/dragon
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bulldog_ammobag
	name = "Drum - 12g Ammo Duffel Bag"
	desc = "A duffel bag filled with enough 12g ammo to supply an entire team, at a discounted price."
	item = /obj/item/storage/backpack/duffel/syndie/ammo/shotgun
	cost = 60 // normally 90
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bulldog_XLmagsbag
	name = "Drum - 12g XL Ammo Duffel Bag"
	desc = "A duffel bag containing three 24 round drum magazines(Buckshot, Flechette, Dragon's Breath)."
	item = /obj/item/storage/backpack/duffel/syndie/ammo/shotgunXLmags
	cost = 45 // normally 90
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/uzi
	name = "Type U3 Uzi - 9mm Magazine"
	desc = "An additional 30 round 9mm magazine for use in Type-U3 Uzi."
	item = /obj/item/ammo_box/magazine/uzim9mm
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/uzi_ammobag
	name = "Type U3 Uzi - 9mm Ammo Duffel Bag"
	desc = "A duffel bag filled with enough 9mm ammo to supply an entire gang. Groove street forever."
	item = /obj/item/storage/backpack/duffel/syndie/ammo/uzi
	cost = 70 // normally 100
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/smg
	name = "C-20r - .45 Magazine"
	desc = "An additional 20-round .45 magazine for use in the C-20r submachine gun. These bullets pack a lot of punch that can knock most targets down, but do limited overall damage."
	item = /obj/item/ammo_box/magazine/smgm45
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/smg_ammobag
	name = "C-20r - .45 Ammo Duffel Bag"
	desc = "A duffel bag filled with enough .45 ammo to supply an entire team, at a discounted price."
	item = /obj/item/storage/backpack/duffel/syndie/ammo/smg
	cost = 70 // normally 100
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/carbine
	name = "Carbine - 5.56 Toploader Magazine"
	desc = "An additional 30-round 5.56 magazine for use in the M-90gl carbine. These bullets don't have the punch to knock most targets down, but dish out higher overall damage."
	item = /obj/item/ammo_box/magazine/m556
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/a40mm
	name = "Carbine - 40mm Grenade Ammo Box"
	desc = "A box of 4 additional 40mm HE grenades for use the C-90gl's underbarrel grenade launcher. Your teammates will thank you to not shoot these down small hallways."
	item = /obj/item/ammo_box/a40mm
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/carbine_ammobag
	name = "Carbine - 5.56 Ammo Duffel Bag"
	desc = "A duffel bag filled with 9 5.56 Toploader magazines, and a 40 mm Grenade Ammo Box. Pew pew."
	item = /obj/item/storage/backpack/duffel/syndie/ammo/carbine
	cost = 90 // normally 120
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/machinegun
	name = "L6 SAW - 5.56x45mm Box Magazine"
	desc = "A 50-round magazine of 5.56x45mm ammunition for use in the L6 SAW machine gun. By the time you need to use this, you'll already be on a pile of corpses."
	item = /obj/item/ammo_box/magazine/mm556x45
	cost = 50
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

/datum/uplink_item/ammo/LMG_ammobag
	name = "L6 SAW - 5.56x45m Ammo Duffel Bag"
	desc = "A Duffel Bag filled with 5 mm556x45 box magazines. Remember, no Russian."
	item = /obj/item/storage/backpack/duffel/syndie/ammo/lmg
	cost = 200 // normally 250
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/sniper
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/sniper/basic
	name = "Sniper - .50 Magazine"
	desc = "An additional standard 5-round magazine for use with .50 sniper rifles."
	item = /obj/item/ammo_box/magazine/sniper_rounds
	cost = 20

/datum/uplink_item/ammo/sniper/soporific
	name = "Sniper - .50 Soporific Magazine"
	desc = "A 3-round magazine of soporific ammo designed for use with .50 sniper rifles. Put your enemies to sleep today!"
	item = /obj/item/ammo_box/magazine/sniper_rounds/soporific
	cost = 15

/datum/uplink_item/ammo/sniper/explosive
	name = "Sniper - .50 Explosive Magazine"
	desc = "A 5-round magazine of explosive ammo designed for use with .50 sniper rifles. Human rights? What?"
	item = /obj/item/ammo_box/magazine/sniper_rounds/explosive
	cost = 30

/datum/uplink_item/ammo/sniper/penetrator
	name = "Sniper - .50 Penetrator Magazine"
	desc = "A 5-round magazine of penetrator ammo designed for use with .50 sniper rifles. \
			Can pierce walls and multiple enemies."
	item = /obj/item/ammo_box/magazine/sniper_rounds/penetrator
	cost = 25

/datum/uplink_item/ammo/bioterror
	name = "Box of Bioterror Syringes"
	desc = "A box full of preloaded syringes, containing various chemicals that seize up the victim's motor and broca system , making it impossible for them to move or speak while in their system."
	item = /obj/item/storage/box/syndie_kit/bioterror
	cost = 25
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/toydarts
	name = "Box of Riot Darts"
	desc = "A box of 40 Donksoft foam riot darts, for reloading any compatible foam dart gun. Don't forget to share!"
	item = /obj/item/ammo_box/foambox/riot
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

/datum/uplink_item/ammo/compact
	name = "50. compact ammo box"
	desc = "A box of 50. cal sniper ammo."
	item = /obj/item/ammo_box/magazine/sniper_rounds/compact
	cost = 10
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/revolver
	name = ".357 Revolver - Two Speedloaders"
	desc = "A box with 2 speed loaders that contains fourteen additional .357 Magnum rounds for the syndicate revolver. For when you really need a lot of things dead."
	item = /obj/item/storage/box/syndie_kit/revolver_ammo
	cost = 5
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/deagle
	name = ".50AE handgun magazine"
	desc = "A magazine that contains seven additional .50AE round for Desert Eagle. Kill them all."
	item = /obj/item/ammo_box/magazine/m50
	cost = 5
	surplus = 0

/datum/uplink_item/ammo/rocketHE
	name = "84mm High Explosive rocket"
	desc = "A rocket from a rocketlauncher. This one deals a devastating explosion, enough to tear the station and civillian apart."
	item = /obj/item/ammo_casing/caseless/rocket
	cost = 40
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/rocketHEDP
	name = "84mm High Explosive Dual Purpose rocket"
	desc = "A rocket from a rocketlauncher. This one emits shrapnel and incendiary ammunition. The rocket itself is strong enough to destroy station mechs and robots with one shot."
	item = /obj/item/ammo_casing/caseless/rocket/hedp
	cost = 30
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/knives_kit
	name = "Throwing knives kit"
	desc = "A box containing 7 throwing knives"
	item = /obj/item/storage/box/syndie_kit/knives_kit
	cost = 4
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

// STEALTHY WEAPONS

/datum/uplink_item/stealthy_weapons
	category = "Stealthy and Inconspicuous Weapons"

/datum/uplink_item/stealthy_weapons/garrote
	name = "Fiber Wire Garrote"
	desc = "A length of fiber wire between two wooden handles, perfect for the discrete assassin. This weapon, when used on a target from behind \
			will instantly put them in your grasp and silence them, as well as causing rapid suffocation. Does not work on those who do not need to breathe."
	item = /obj/item/twohanded/garrote
	cost = 20

/datum/uplink_item/stealthy_weapons/martialarts
	name = "Martial Arts Scroll"
	desc = "This scroll contains the secrets of an ancient martial arts technique. You will master unarmed combat, \
			deflecting all ranged weapon fire, but you also refuse to use dishonorable ranged weaponry. Learning this art means you will also refuse to use dishonorable ranged weaponry. \
			Unable to be understood by vampire and changeling agents."
	item = /obj/item/sleeping_carp_scroll
	cost = 80
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

	refundable = TRUE
	can_discount = FALSE

/datum/uplink_item/stealthy_weapons/cqc
	name = "CQC Manual"
	desc = "A manual that teaches a single user tactical Close-Quarters Combat before self-destructing. Does not restrict weapon usage, but cannot be used alongside Gloves of the North Star."
	item = /obj/item/CQC_manual
	cost = 50
	can_discount = FALSE

/datum/uplink_item/stealthy_weapons/mr_chang
	name = "Mr. Chang's Aggressive Marketing Technique"
	desc = "This package was kindly provided to us by Mr. Cheng's corporation. It contains a wide range of implements for the most effective promotion of products in a free market environment."
	item = /obj/item/storage/box/syndie_kit/mr_chang_technique
	cost = 18

/datum/uplink_item/stealthy_weapons/cameraflash
	name = "Camera Flash"
	desc = "A flash disguised as a camera with a self-charging safety system preventing the flash from burning out.\
			 Due to its design, this flash cannot be overcharged like regular flashes can.\
			 Useful for stunning borgs and individuals without eye protection or blinding a crowd for a get away."
	item = /obj/item/flash/cameraflash
	cost = 6

/datum/uplink_item/stealthy_weapons/throwingweapons
	name = "Box of Throwing Weapons"
	desc = "A box of shurikens and reinforced bolas from ancient Earth martial arts. They are highly effective \
			 throwing weapons. The bolas can knock a target down and the shurikens will embed into limbs."
	item = /obj/item/storage/box/syndie_kit/throwing_weapons
	cost = 3

/datum/uplink_item/stealthy_weapons/edagger
	name = "Energy Dagger"
	desc = "A dagger made of energy that looks and functions as a pen when off."
	item = /obj/item/pen/edagger
	cost = 7

/datum/uplink_item/stealthy_weapons/sleepy_pen
	name = "Sleepy Pen"
	desc = "A syringe disguised as a functional pen. It's filled with a potent anaesthetic. \ The pen holds two doses of the mixture. The pen can be refilled."
	item = /obj/item/pen/sleepy
	cost = 36
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_weapons/foampistol
	name = "Toy Gun (with Stun Darts)"
	desc = "An innocent looking toy pistol designed to fire foam darts. Comes loaded with riot grade darts, to incapacitate a target."
	item = /obj/item/gun/projectile/automatic/toy/pistol/riot
	cost = 12
	surplus = 10

/datum/uplink_item/stealthy_weapons/false_briefcase
	name = "False Bottomed Briefcase"
	desc = "A modified briefcase capable of storing and firing a gun under a false bottom. Use a screwdriver to pry away the false bottom and make modifications. Distinguishable upon close examination due to the added weight."
	item = /obj/item/storage/briefcase/false_bottomed
	cost = 1

/datum/uplink_item/stealthy_weapons/soap
	name = "Syndicate Soap"
	desc = "A sinister-looking surfactant used to clean blood stains to hide murders and prevent DNA analysis. You can also drop it underfoot to slip people."
	item = /obj/item/soap/syndie
	cost = 1
	surplus = 50

/datum/uplink_item/stealthy_weapons/tape
	name = "Thick tape roll"
	desc = "Incredibly thick duct tape, suspiciously black in appearance. It is quite uncomfortable to hold it as it sticks to your hands."
	item = /obj/item/stack/tape_roll/thick
	cost = 7
	surplus = 50

/datum/uplink_item/stealthy_weapons/dart_pistol
	name = "Dart Pistol Kit"
	desc = "A miniaturized version of a normal syringe gun. It is very quiet when fired and can fit into any space a small item can. Comes with 3 syringes, a knockout poison, a silencing agent and a deadly neurotoxin."
	item = /obj/item/storage/box/syndie_kit/dart_gun
	cost = 18
	surplus = 50
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_weapons/RSG
	name = "Rapid Syringe Gun"
	desc = "A rapid syringe gun able to hold six shot and fire them rapidly. Great together with the bioterror syringe"
	item = /obj/item/gun/syringe/rapidsyringe
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_weapons/silencer
	name = "Universal Suppressor"
	desc = "Fitted for use on any small caliber weapon with a threaded barrel, this suppressor will silence the shots of the weapon for increased stealth and superior ambushing capability."
	item = /obj/item/suppressor
	cost = 4
	surplus = 10

/datum/uplink_item/stealthy_weapons/dehy_carp
	name = "Dehydrated Space Carp"
	desc = "Just add water to make your very own hostile to everything space carp. It looks just like a plushie. The first person to squeeze it will be registered as its owner, who it will not attack. If no owner is registered, it'll just attack everyone."
	item = /obj/item/toy/carpplushie/dehy_carp
	cost = 7

// GRENADES AND EXPLOSIVES

/datum/uplink_item/explosives
	category = "Grenades and Explosives"

/datum/uplink_item/explosives/plastic_explosives
	name = "Composition C-4"
	desc = "C-4 is plastic explosive of the common variety Composition C. You can use it to breach walls or connect an assembly to its wiring to make it remotely detonable. It has a modifiable timer with a minimum setting of 10 seconds."
	item = /obj/item/grenade/plastic/c4
	cost = 2

/datum/uplink_item/explosives/plastic_explosives_pack
	name = "Pack of 5 C-4 Explosives"
	desc = "A package containing 5 C-4 Explosives at a discounted price. For when you need that little bit extra for your sabotaging needs."
	item = /obj/item/storage/box/syndie_kit/c4
	cost = 8

/datum/uplink_item/explosives/c4bag
	name = "Bag of C-4 explosives"
	desc = "Because sometimes quantity is quality. Contains 10 C-4 plastic explosives."
	item = /obj/item/storage/backpack/duffel/syndie/c4
	cost = 40 //20% discount!
	can_discount = FALSE
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/breaching_charge
	name = "Composition X-4"
	desc = "X-4 is a shaped charge designed to be safe to the user while causing maximum damage to the occupants of the room beach breached. It has a modifiable timer with a minimum setting of 10 seconds."
	item = /obj/item/grenade/plastic/x4
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/x4bag
	name = "Bag of X-4 explosives"
	desc = "Contains 3 X-4 shaped plastic explosives. Similar to C4, but with a stronger blast that is directional instead of circular. \
			X-4 can be placed on a solid surface, such as a wall or window, and it will blast through the wall, injuring anything on the opposite side, while being safer to the user. \
			For when you want a controlled explosion that leaves a wider, deeper, hole."
	item = /obj/item/storage/backpack/duffel/syndie/x4
	cost = 20
	can_discount = FALSE
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/t4
	name = "Breaching T-4"
	desc = "Thermite-charged breaching explosive. Effective to destroy wall, but not to destroy airlocks."
	item = /obj/item/grenade/plastic/x4/thermite
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/t4_pack
	name = "Pack of 3 T-4 explosives"
	desc = "A package containing 3 T-4."
	item = /obj/item/storage/box/syndie_kit/t4P
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/syndicate_bomb
	name = "Syndicate Bomb"
	desc = "The Syndicate Bomb has an adjustable timer with a minimum setting of 90 seconds. Ordering the bomb sends you a small beacon, which will teleport the explosive to your location when you activate it. \
	You can wrench the bomb down to prevent removal. The crew may attempt to defuse the bomb."
	item = /obj/item/radio/beacon/syndicate/bomb
	cost = 40
	surplus = 0
	can_discount = FALSE
	hijack_only = TRUE
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/syndicate_bomb/nuke
	item = /obj/item/radio/beacon/syndicate/bomb
	cost = 55
	excludefrom = list()
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	hijack_only = FALSE

/datum/uplink_item/explosives/emp_bomb
	name = "EMP bomb"
	desc = "The EMP has an adjustable timer with a minimum setting of 90 seconds. Ordering the bomb sends you a small beacon, which will teleport the explosive to your location when you activate it. \
	You can wrench the bomb down to prevent removal. The crew may attempt to defuse the bomb."
	item = /obj/item/radio/beacon/syndicate/bomb/emp
	cost = 40
	surplus = 0
	can_discount = FALSE
	hijack_only = TRUE
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/emp_bomb/nuke
	item = /obj/item/radio/beacon/syndicate/bomb/emp
	cost = 50
	excludefrom = list()
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	hijack_only = FALSE


/datum/uplink_item/explosives/syndicate_minibomb
	name = "Syndicate Minibomb"
	desc = "The minibomb is a grenade with a five-second fuse."
	item = /obj/item/grenade/syndieminibomb
	cost = 30

/datum/uplink_item/explosives/rocketlauncher
	name = "84mm Rocket Propelled Grenade Launcher"
	desc = "A reusable rocket propelled grenade launcher preloaded with a low-yield 84mm HE round. Guaranteed to send your target out with a bang or your money back!"
	item = /obj/item/gun/projectile/revolver/rocketlauncher
	cost = 50
	surplus = 0 // no way
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/rocketbelt
	name = "84mm Rocket Belt"
	desc = "A belt full of rockets for a rocket propelled grenade launcher. Guaranteed to eliminate most of your targets. Just don't blow up your mates!"
	item = /obj/item/storage/belt/rocketman
	cost = 175
	surplus = 0
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/detomatix
	name = "Detomatix PDA Cartridge"
	desc = "When inserted into a personal digital assistant, this cartridge gives you five opportunities to detonate PDAs of crewmembers who have their message feature enabled. The concussive effect from the explosion will knock the recipient out for a short period, and deafen them for longer. It has a chance to detonate your PDA."
	item = /obj/item/cartridge/syndicate
	cost = 30

/datum/uplink_item/explosives/pizza_bomb
	name = "Pizza Bomb"
	desc = "A pizza box with a bomb taped inside of it. The timer needs to be set by opening the box; afterwards, opening the box again will trigger the detonation."
	item = /obj/item/pizza_bomb
	cost = 15
	surplus = 80

/datum/uplink_item/explosives/fraggrenade
	name = "Frag grenade's"
	desc = "A belt containing 4 lethally dangerous and destructive grenades."
	item = /obj/item/storage/belt/grenade/frag
	cost = 10

/datum/uplink_item/explosives/grenadier
	name = "Grenadier's belt"
	desc = "A belt containing 26 lethally dangerous and destructive grenades."
	item = /obj/item/storage/belt/grenade/full
	cost = 125
	surplus = 0
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/manhacks
	name = "Viscerator Delivery Grenade"
	desc = "A unique grenade that deploys a swarm of viscerators upon activation, which will chase down and shred any non-operatives in the area."
	item = /obj/item/grenade/spawnergrenade/manhacks
	cost = 30
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 35

/datum/uplink_item/explosives/atmosn2ogrenades
	name = "Knockout Gas Grenades"
	desc = "A box of two (2) grenades that spread knockout gas over a large area. Equip internals before using one of these."
	item = /obj/item/storage/box/syndie_kit/atmosn2ogrenades
	cost = 18

/datum/uplink_item/explosives/atmosfiregrenades
	name = "Plasma Fire Grenades"
	desc = "A box of two (2) grenades that cause large plasma fires. Can be used to deny access to a large area. Most useful if you have an atmospherics hardsuit."
	item = /obj/item/storage/box/syndie_kit/atmosfiregrenades
	hijack_only = TRUE
	cost = 50
	surplus = 0
	can_discount = FALSE

/datum/uplink_item/explosives/emp
	name = "EMP Grenades and Implanter Kit"
	desc = "A box that contains two EMP grenades and an EMP implant with 2 uses. Useful to disrupt communication, \
			security's energy weapons, and silicon lifeforms when you're in a tight spot."
	item = /obj/item/storage/box/syndie_kit/emp
	cost = 10

// STEALTHY TOOLS

/datum/uplink_item/stealthy_tools
	category = "Stealth and Camouflage Items"

/datum/uplink_item/stealthy_tools/syndie_kit/counterfeiter_bundle
	name = "Syndicate Counterfeiter Bundle"
	desc = "A cleverly implemented bundle designed to document counterfeiting. Comes with a chameleon stamp, capable of imitating any NanoTrasen issued stamps and a fakesign pen to alter the world through the sheer force of paperwork. While making the user capable of faking almost any document, this Syndicate technology has been rumored to cause a huge upheaval on NT objects. "
	cost = 2
	surplus = 35
	item = /obj/item/storage/box/syndie_kit/counterfeiter_bundle

/datum/uplink_item/stealthy_tools/chameleonflag
	name = "Chameleon Flag"
	desc = "A flag that can be disguised as any other known flag. There is a hidden spot in the pole to boobytrap the flag with a grenade or minibomb, which will detonate some time after the flag is set on fire."
	item = /obj/item/flag/chameleon
	cost = 1
	surplus = 35

/datum/uplink_item/stealthy_tools/chamsechud
	name = "Chameleon Security HUD"
	desc = "A stolen Nanotrasen Security HUD with Syndicate chameleon technology implemented into it. Similarly to a chameleon jumpsuit, the HUD can be morphed into various other eyewear, while retaining the HUD qualities when worn."
	item = /obj/item/clothing/glasses/hud/security/chameleon
	cost = 8

/datum/uplink_item/stealthy_tools/thermal
	name = "Thermal Chameleon Glasses"
	desc = "These glasses are thermals with Syndicate chameleon technology built into them. They allow you to see organisms through walls by capturing the upper portion of the infra-red light spectrum, emitted as heat and light by objects. Hotter objects, such as warm bodies, cybernetic organisms and artificial intelligence cores emit more of this light than cooler objects like walls and airlocks."
	item = /obj/item/clothing/glasses/chameleon/thermal
	cost = 20

/datum/uplink_item/stealthy_tools/traitor_belt
	name = "Traitor's Toolbelt"
	desc = "A robust seven-slot belt made for carrying a broad variety of weapons, ammunition and explosives. It's modelled after the standard NT toolbelt so as to avoid suspicion while wearing it."
	item = /obj/item/storage/belt/military/traitor
	cost = 2
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_tools/frame
	name = "F.R.A.M.E. PDA Cartridge"
	desc = "When inserted into a personal digital assistant, this cartridge gives you five PDA viruses which \
			when used cause the targeted PDA to become a new uplink with zero TCs, and immediately become unlocked.  \
			You will receive the unlock code upon activating the virus, and the new uplink may be charged with \
			telecrystals normally."
	item = /obj/item/cartridge/frame
	cost = 16
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_tools/agent_card
	name = "Agent ID Card"
	desc = "Agent cards prevent artificial intelligences from tracking the wearer, and can copy access from other identification cards. The access is cumulative, so scanning one card does not erase the access gained from another."
	item = /obj/item/card/id/syndicate
	cost = 10

/datum/uplink_item/stealthy_tools/chameleon
	name = "Chameleon Kit"
	desc = "A set of items that contain chameleon technology allowing you to disguise as pretty much anything on the station, and more! \
			Due to budget cuts, the shoes don't provide protection against slipping. The set comes with a complementary chameleon stamp."
	item = /obj/item/storage/box/syndie_kit/chameleon
	cost = 20

/datum/uplink_item/stealthy_tools/syndigaloshes
	name = "No-Slip Chameleon Shoes"
	desc = "These shoes will allow the wearer to run on wet floors and slippery objects without falling down. \
			They do not work on heavily lubricated surfaces."
	item = /obj/item/clothing/shoes/chameleon/noslip
	cost = 8
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_tools/syndigaloshes/nuke
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_tools/chameleon_proj
	name = "Chameleon-Projector"
	desc = "Projects an image across a user, disguising them as an object scanned with it, as long as they don't move the projector from their hand. The disguised user cannot run and projectiles pass over them."
	item = /obj/item/chameleon
	cost = 26

/datum/uplink_item/stealthy_tools/camera_bug
	name = "Camera Bug"
	desc = "Enables you to view all cameras on the network to track a target."
	item = /obj/item/camera_bug
	cost = 3
	surplus = 90

/datum/uplink_item/stealthy_tools/dnascrambler
	name = "DNA Scrambler"
	desc = "A syringe with one injection that randomizes appearance and name upon use. A cheaper but less versatile alternative to an agent card and voice changer."
	item = /obj/item/dnascrambler
	cost = 10

/datum/uplink_item/stealthy_tools/smugglersatchel
	name = "Smuggler's Satchel"
	desc = "This satchel is thin enough to be hidden in the gap between plating and tiling, great for stashing your stolen goods. Comes with a crowbar and a floor tile inside."
	item = /obj/item/storage/backpack/satchel_flat
	cost = 6
	surplus = 30

/datum/uplink_item/stealthy_tools/emplight
	name = "EMP Flashlight"
	desc = "A small, self-charging, short-ranged EMP device disguised as a flashlight. \
		Useful for disrupting headsets, cameras, and borgs during stealth operations."
	item = /obj/item/flashlight/emp
	cost = 19
	surplus = 30

/datum/uplink_item/stealthy_tools/syndigaloshes
	name = "No-Slip Chameleon Shoes"
	desc = "These shoes will allow the wearer to run on wet floors and slippery objects without falling down. They do not work on heavily lubricated surfaces."
	item = /obj/item/clothing/shoes/chameleon/noslip
	cost = 8
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_tools/syndigaloshes/nuke
	item = /obj/item/clothing/shoes/chameleon/noslip
	cost = 20
	excludefrom = list()
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/stealthy_tools/cutouts
	name = "Adaptive Cardboard Cutouts"
	desc = "These cardboard cutouts are coated with a thin material that prevents discoloration and makes the images on them appear more lifelike. This pack contains three as well as a \
	spraycan for changing their appearances."
	item = /obj/item/storage/box/syndie_kit/cutouts
	cost = 1
	surplus = 20

/datum/uplink_item/stealthy_tools/clownkit
	name = "Honk Brand Infiltration Kit"
	desc = "All the tools you need to play the best prank Nanotrasen has ever seen. Includes a voice changer mask, magnetic clown shoes, and standard clown outfit, tools, and backpack."
	item = /obj/item/storage/backpack/clown/syndie
	cost = 30
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

/datum/uplink_item/stealthy_tools/chameleon_counter
	name = "Chameleon Counterfeiter"
	desc = "This device disguises itself as any object scanned by it. It's unstable and disguise will be disabled in about 30 minutes. The box contains three counterfeiters."
	item = /obj/item/storage/box/syndie_kit/chameleon_counter
	cost = 6
// DEVICE AND TOOLS

/datum/uplink_item/device_tools
	category = "Devices and Tools"

/datum/uplink_item/device_tools/emag
	name = "Cryptographic Sequencer"
	desc = "The cryptographic sequencer, also known as an emag, is a small card that unlocks hidden functions in electronic devices, subverts intended functions and characteristically breaks security mechanisms."
	item = /obj/item/card/emag
	cost = 30 // Brainrot allowed

/datum/uplink_item/device_tools/access_tuner
	name = "Access Tuner"
	desc = "The access tuner is a small device that can interface with airlocks from range. It takes a few seconds to connect and can change the bolt state, open the door, or toggle emergency access."
	item = /obj/item/door_remote/omni/access_tuner
	cost = 30

/datum/uplink_item/device_tools/toolbox
	name = "Fully Loaded Toolbox"
	desc = "The syndicate toolbox is a suspicious black and red. Aside from tools, it comes with insulated gloves and a multitool."
	item = /obj/item/storage/toolbox/syndicate
	cost = 3

/datum/uplink_item/device_tools/supertoolbox
	name = "Superior Suspicious Toolbox"
	desc = "Ultimate version of all toolboxes, this one more robust and more useful than his cheaper version. Comes with experimental type tools, combat gloves and cool sunglasses."
	item = /obj/item/storage/toolbox/syndisuper
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/holster
	name = "Shoulder Holster"
	desc = "For holding your favourite gun close and always being ready for a cowboy duel with clown."
	item = /obj/item/clothing/accessory/holster
	cost = 2

/datum/uplink_item/device_tools/holster/knives
	name = "Knife holster"
	desc = "A bunch of straps connected into one holster. Has 7 special slots for holding knives."
	item = /obj/item/clothing/accessory/holster/knives
	cost = 2
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/webbing
	name = "Combat Webbing"
	desc = "Sturdy mess of synthcotton belts and buckles, ready to share your burden."
	item = /obj/item/clothing/accessory/storage/webbing
	cost = 2

/datum/uplink_item/device_tools/black_vest
	name = "Black Vest"
	desc = "Robust black synthcotton vest with lots of pockets to hold whatever you need, but cannot hold in hands."
	item = /obj/item/clothing/accessory/storage/black_vest
	cost = 2

/datum/uplink_item/device_tools/brown_vest
	name = "Brown Vest"
	desc = "Worn brownish synthcotton vest with lots of pockets to unload your hands."
	item = /obj/item/clothing/accessory/storage/brown_vest
	cost = 2

/datum/uplink_item/device_tools/blackops_kit
	name = "Black ops kit"
	desc = "A package of clothing for dangerous covert operations"
	item = /obj/item/storage/box/syndie_kit/blackops_kit
	cost = 8

/datum/uplink_item/device_tools/surgerybag
	name = "Syndicate Surgery Duffelbag"
	desc = "The Syndicate Surgical Bag comes with a complete set of everything you need for quality surgery, including a straitjacket and muzzle. The bag itself is unprecedentedly light, doesn't slow you down, and is completely silent."
	item = /obj/item/storage/backpack/duffel/syndie/surgery
	cost = 7

/datum/uplink_item/device_tools/bonerepair
	name = "Prototype Nanite Autoinjector Kit"
	desc = "Stolen prototype full body repair nanites. Contains one prototype nanite autoinjector and guide."
	item = /obj/item/storage/box/syndie_kit/bonerepair
	cost = 6

/datum/uplink_item/device_tools/syndicate_teleporter
	name = "Experimental Syndicate Teleporter"
	desc = "The Syndicate teleporter is a handheld device that teleports the user 4-8 meters forward. \
			Beware, teleporting into a wall will make the teleporter do a parallel emergency teleport, \
			but if that emergency teleport fails, it will kill you. \
			Has 4 charges, recharges, warranty voided if exposed to EMP."
	item = /obj/item/storage/box/syndie_kit/teleporter
	cost = 44

/datum/uplink_item/device_tools/spai
	name = "Syndicate Personal AI Device (SPAI)"
	desc = "You will have your personal assistant. It comes with an increased amount of memory and special programs."
	item = /obj/item/storage/box/syndie_kit/pai
	cost = 37
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	refundable = TRUE
	refund_path = /obj/item/paicard_upgrade/unused
	can_discount = FALSE

/datum/uplink_item/device_tools/thermal_drill
	name = "Amplifying Thermal Safe Drill"
	desc = "A tungsten carbide thermal drill with magnetic clamps for the purpose of drilling hardened objects. Comes with built in security detection and nanite system, to keep you up if security comes a-knocking."
	item = /obj/item/thermal_drill/syndicate
	cost = 2
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/dthermal_drill
	name = "Amplifying Diamond Tipped Thermal Safe Drill"
	desc = "A diamond tipped thermal drill with magnetic clamps for the purpose of quickly drilling hardened objects. Comes with built in security detection and nanite system, to keep you up if security comes a-knocking."
	item = /obj/item/thermal_drill/diamond_drill/syndicate
	cost = 5
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/jackhammer
	name = "Jackhammer"
	desc = "A jackhammer for breaking stone. Or walls. Or skulls"
	item = /obj/item/pickaxe/drill/jackhammer
	cost = 15

/datum/uplink_item/device_tools/pickpocketgloves
	name = "Pickpocket's Gloves"
	desc = "A pair of sleek gloves to aid in pickpocketing. While wearing these, you can loot your target without them knowing. Pickpocketing puts the item directly into your hand."
	item = /obj/item/clothing/gloves/color/black/thief
	cost = 30

/datum/uplink_item/device_tools/medkit
	name = "Syndicate Combat Medic Kit"
	desc = "The syndicate medkit is a suspicious black and red. Included is a combat stimulant injector for rapid healing, a medical HUD for quick identification of injured comrades, \
	and other medical supplies helpful for a medical field operative."
	item = /obj/item/storage/firstaid/syndie
	cost = 35
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/vtec
	name = "Syndicate Cyborg Upgrade Module (VTEC)"
	desc = "Increases the movement speed of a Cyborg. Install into any Borg, Syndicate or subverted"
	item = /obj/item/borg/upgrade/vtec
	cost = 30
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/cyborg_magboots
	name = "Syndicate Cyborg Upgrade Module (F-Magnet)"
	desc = "Позволяет киборгу частично примагничиваться к корпусу, что позволяет игнорировать некоторые условия отсутсвия гравитации."
	item = /obj/item/borg/upgrade/magboots
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/autoimplanter
	name = "Syndicate Autoimplanter"
	desc = "Cheaper version of nuclear operatives autoimplanter, this model allows you to install three cybernetic implants on the field."
	item = /obj/item/autoimplanter/traitor
	cost = 28
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

//Space Suits and Hardsuits
/datum/uplink_item/suits
	category = "Space Suits and Hardsuits"
	surplus = 40

/datum/uplink_item/suits/space_suit
	name = "Syndicate Space Suit"
	desc = "This red and black syndicate space suit is less encumbering than Nanotrasen variants, \
			fits inside bags, and has a weapon slot. Comes packaged with internals. Nanotrasen crewmembers are trained to report red space suit \
			sightings, however. "
	item = /obj/item/storage/box/syndie_kit/space
	cost = 18

/datum/uplink_item/suits/hardsuit
	name = "Syndicate Hardsuit"
	desc = "The feared suit of a syndicate nuclear agent. Features armor and a combat mode \
			for faster movement on station. Toggling the suit in and out of \
			combat mode will allow you all the mobility of a loose fitting uniform without sacrificing armoring. \
			Additionally the suit is collapsible, making it small enough to fit within a backpack. Comes packaged with internals. \
			Nanotrasen crew who spot these suits are known to panic."
	item = /obj/item/storage/box/syndie_kit/hardsuit
	cost = 33
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/suits/chameleon_hardsuit
	name = "Chameleon Hardsuit"
	desc = "A top-tier Hardsuit developed with cooperation of Cybersun Industries and the Gorlex Marauders, a favorite of Syndicate Contractors. \
	In addition, it has an in-built chameleon system, allowing you to disguise your hardsuit to the most common variations on your mission area. \
	This one disquised as engineering hardsuit."
	cost = 46 //reskinned blood-red hardsuit with chameleon
	item = /obj/item/storage/box/syndie_kit/chameleon_hardsuit

/datum/uplink_item/suits/hardsuit/elite
	name = "Elite Syndicate Hardsuit"
	desc = "An advanced hardsuit with superior armor and mobility to the standard Syndicate Hardsuit."
	item = /obj/item/clothing/suit/space/hardsuit/syndi/elite
	cost = 50
	excludefrom = list()
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/suits/hardsuit/shielded
	name = "Shielded Hardsuit"
	desc = "An advanced hardsuit with built-in energy shielding. The shields will rapidly recharge when not under fire."
	item = /obj/item/clothing/suit/space/hardsuit/syndi/shielded
	cost = 150
	excludefrom = list()
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/binary
	name = "Binary Translator Key"
	desc = "A key, that when inserted into a radio headset, allows you to listen to and talk with artificial intelligences and cybernetic organisms in binary. To talk on the binary channel, type :+ before your radio message."
	item = /obj/item/encryptionkey/binary
	cost = 21
	surplus = 75

/datum/uplink_item/device_tools/bowman_kit
	name = "Bowman Conversion kit + Syndicate Encryption Key"
	desc = "Easy-to-apply device which enchances headset with loud noise protection and chameleoning headsets. \
	A key, that when inserted into a radio headset, allows you to listen to all station department channels as well as talk on an encrypted Syndicate channel."
	item = /obj/item/storage/box/syndie_kit/bowman_conversion_kit
	cost = 2
	surplus = 75

/datum/uplink_item/device_tools/hacked_module
	name = "Hacked AI Upload Module"
	desc = "When used with an upload console, this module allows you to upload priority laws to an artificial intelligence. Be careful with their wording, as artificial intelligences may look for loopholes to exploit."
	item = /obj/item/aiModule/syndicate
	cost = 38

/datum/uplink_item/device_tools/magboots
	name = "Blood-Red Magboots"
	desc = "A pair of magnetic boots with a Syndicate paintjob that assist with freer movement in space or on-station during gravitational generator failures. \
	These reverse-engineered knockoffs of Nanotrasen's 'Advanced Magboots' slow you down in simulated-gravity environments much like the standard issue variety."
	item = /obj/item/clothing/shoes/magboots/syndie
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/magboots/advance
	name = "Advanced Blood-Red Magboots"
	desc = "A pair of magnetic boots with a Syndicate paintjob that assist with freer movement in space or on-station during gravitational generator failures. \
	These reverse-engineered knockoffs of Nanotrasen's 'Advanced Magboots' not slow you down in simulated-gravity environments and provide protection against slipping on the space lube."
	item = /obj/item/clothing/shoes/magboots/syndie/advance
	cost = 40
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/powersink
	name = "Power Sink"
	desc = "When screwed to wiring attached to an electric grid, then activated, this large device places excessive load on the grid, causing a stationwide blackout. The sink cannot be carried because of its excessive size. Ordering this sends you a small beacon that will teleport the power sink to your location on activation."
	item = /obj/item/powersink
	cost = 40

/datum/uplink_item/device_tools/singularity_beacon
	name = "Power Beacon"
	desc = "When screwed to wiring attached to an electric grid and activated, this large device pulls any \
			active gravitational singularities or tesla balls towards it. This will not work when the engine is still \
			in containment. Because of its size, it cannot be carried. Ordering this \
			sends you a small beacon that will teleport the larger beacon to your location upon activation."
	item = /obj/item/radio/beacon/syndicate
	cost = 30
	surplus = 0
	hijack_only = TRUE //This is an item only useful for a hijack traitor, as such, it should only be available in those scenarios.
	can_discount = FALSE

/datum/uplink_item/device_tools/ion_caller
	name = "Low Orbit Ion Cannon Remote"
	desc = "The Syndicate has recently installed a remote satellite nearby capable of generating a localized ion storm every 15 minutes. \
			However, your local authorities will be informed of your general location when it is activated."
	item = /obj/item/ion_caller
	limited_stock = 1	// Might be too annoying if someone had multiple.
	cost = 30
	surplus = 10
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)


/datum/uplink_item/device_tools/syndicate_detonator
	name = "Syndicate Detonator"
	desc = "The Syndicate Detonator is a companion device to the Syndicate Bomb. Simply press the included button and an encrypted radio frequency will instruct all live syndicate bombs to detonate. \
	Useful for when speed matters or you wish to synchronize multiple bomb blasts. Be sure to stand clear of the blast radius before using the detonator."
	item = /obj/item/syndicatedetonator
	cost = 15
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/advpinpointer
	name = "Advanced Pinpointer"
	desc = "A pinpointer that tracks any specified coordinates, DNA string, high value item or the nuclear authentication disk."
	item = /obj/item/pinpointer/advpinpointer
	cost = 19

/datum/uplink_item/device_tools/ai_detector
	name = "Artificial Intelligence Detector" // changed name in case newfriends thought it detected disguised ai's
	desc = "A functional multitool that turns red when it detects an artificial intelligence watching it or its holder. Knowing when an artificial intelligence is watching you is useful for knowing when to maintain cover."
	item = /obj/item/multitool/ai_detect
	cost = 2

/datum/uplink_item/device_tools/jammer
	name = "Radio Jammer"
	desc = "This device will disrupt any nearby outgoing radio communication when activated."
	item = /obj/item/jammer
	cost = 6

/datum/uplink_item/device_tools/teleporter
	name = "Teleporter Circuit Board"
	desc = "A printed circuit board that completes the teleporter onboard the mothership. Advise you test fire the teleporter before entering it, as malfunctions can occur."
	item = /obj/item/circuitboard/teleporter
	cost = 100
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

/datum/uplink_item/device_tools/assault_pod
	name = "Assault Pod Targetting Device"
	desc = "Use to select the landing zone of your assault pod."
	item = /obj/item/assault_pod
	cost = 125
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

/datum/uplink_item/device_tools/shield
	name = "Energy Shield"
	desc = "An incredibly useful personal shield projector, capable of reflecting energy projectiles, but it cannot block other attacks. Pair with an Energy Sword for a killer combination."
	item = /obj/item/shield/energy/syndie
	cost = 60
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 20

/datum/uplink_item/device_tools/medgun
	name = "Medbeam Gun"
	desc = "Medical Beam Gun, useful in prolonged firefights. DO NOT CROSS THE BEAMS. Crossing beams with another medbeam or attaching two beams to one target will have explosive consequences."
	item = /obj/item/gun/medbeam
	cost = 75
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

//Stimulants
/datum/uplink_item/device_tools/stims
	name = "Stimulants"
	desc = "A highly illegal compound contained within a compact auto-injector; when injected it makes the user extremely resistant to incapacitation and greatly enhances the body's ability to repair itself."
	item = /obj/item/reagent_containers/hypospray/autoinjector/stimulants
	cost = 28
	excludefrom = list(UPLINK_TYPE_NUCLEAR)

// IMPLANTS

/datum/uplink_item/implants
	category = "Implants"

/datum/uplink_item/implants/freedom
	name = "Freedom Implant"
	desc = "An implant injected into the body and later activated manually to break out of any restraints. Can be activated up to 4 times."
	item = /obj/item/implanter/freedom
	cost = 18

/datum/uplink_item/implants/freedom/prototype
	name = "Prototype Freedom Implant"
	desc = "An implant injected into the body and later activated manually to break out of any restraints. This prototype can be activated 1 time."
	item = /obj/item/implanter/freedom/prototype
	cost = 6

/datum/uplink_item/implants/uplink
	name = "Uplink Implant"
	desc = "An implant injected into the body, and later activated manually to open an uplink with 10 telecrystals. The ability for an agent to open an uplink after their possessions have been stripped from them makes this implant excellent for escaping confinement."
	item = /obj/item/implanter/uplink
	cost = 60
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0
	can_discount = FALSE

/datum/uplink_item/implants/storage
	name = "Storage Implant"
	desc = "An implant injected into the body, and later activated at the user's will. It will open a small subspace pocket capable of storing two items."
	item = /obj/item/implanter/storage
	cost = 27

/datum/uplink_item/implants/mindslave
	name = "Mindslave Implant"
	desc = "A box containing an implanter filled with a mindslave implant that when injected into another person makes them loyal to you and your cause, unless of course they're already implanted by someone else. Loyalty ends if the implant is no longer in their system."
	item = /obj/item/implanter/traitor
	cost = 25

/datum/uplink_item/implants/adrenal
	name = "Adrenal Implant"
	desc = "An implant injected into the body, and later activated manually to inject a chemical cocktail, which has a mild healing effect along with removing and reducing the time of all stuns and increasing movement speed. Can be activated up to 3 times."
	item = /obj/item/implanter/adrenalin
	cost = 44
	can_discount = FALSE
	surplus = 0

/datum/uplink_item/implants/adrenal/prototype
	name = "Prototype Adrenal Implant"
	desc = "An implant injected into the body, and later activated manually to inject a chemical cocktail, which has a mild healing effect along with removing and reducing the time of all stuns and increasing movement speed. This prototype can be activated 1 time."
	item = /obj/item/implanter/adrenalin/prototype
	cost = 16

/datum/uplink_item/implants/microbomb
	name = "Microbomb Implant"
	desc = "An implant injected into the body, and later activated either manually or automatically upon death. The more implants inside of you, the higher the explosive power. \
	This will permanently destroy your body, however."
	item = /obj/item/implanter/explosive
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/implants/stealthbox
    name = "Stealth Implant"
    desc = "An implant injected into the body, and later activated manually to deploy a box, fully hiding you in the surroundings. Can be used indefinitely"
    item = /obj/item/implanter/stealth
    cost = 40

// Cybernetics
/datum/uplink_item/cyber_implants
	category = "Cybernetic Implants"
	surplus = 0
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/cyber_implants/thermals
	name = "Thermal Vision Implant"
	desc = "These cybernetic eyes will give you thermal vision. Comes with an automated implanting tool."
	item = /obj/item/storage/box/cyber_implants/thermals
	cost = 40

/datum/uplink_item/cyber_implants/xray
	name = "X-Ray Vision Implant"
	desc = "These cybernetic eyes will give you X-ray vision. Comes with an automated implanting tool."
	item = /obj/item/storage/box/cyber_implants/xray
	cost = 50

/datum/uplink_item/cyber_implants/antistun
	name = "Hardened CNS Rebooter Implant"
	desc = "This implant will help you get back up on your feet faster after being stunned. It is invulnerable to EMPs. Incompatible with the Neural Jumpstarter.\
			Comes with an automated implanting tool."
	item = /obj/item/storage/box/cyber_implants/anti_stun_hardened
	cost = 60

/datum/uplink_item/cyber_implants/antisleep
	name = "Hardened Neural Jumpstarter Implant"
	desc = "This implant will help you regain your consciousness, but there is short delay for that. It is invulnerable to EMPs. Incompatible with the CNS Rebooter.\
			Comes with an automated implanting tool."
	item = /obj/item/storage/box/cyber_implants/anti_sleep_hardened
	cost = 75

/datum/uplink_item/cyber_implants/reviver
	name = "Hardened Reviver Implant"
	desc = "This implant will attempt to revive you if you lose consciousness. It is invulnerable to EMPs. Comes with an automated implanting tool."
	item = /obj/item/storage/box/cyber_implants/reviver_hardened
	cost = 40

/datum/uplink_item/cyber_implants/mantisblade
	name = "Mantis Blades"
	desc = "A box containing a set of two Gorlex Hidden Blade Implants comes with self-destructing auto-implanters. After the EMP, they return to service to show that it's too early to write you off."
	item = /obj/item/storage/box/syndie_kit/mantisblade
	cost = 57
	surplus = 90
	uplinktypes = list()

/datum/uplink_item/cyber_implants/razorblade
	name = "Tail Razorblade"
	desc = "Tail Razorblade Implant comes with self-destructing auto-implanter. Show the enemy how deadly your tail can be."
	item = /obj/item/autoimplanter/oneuse/razorblade
	cost = 42
	surplus = 0
	uplinktypes = list(UPLINK_TYPE_TRAITOR)

/datum/uplink_item/cyber_implants/laserblade
	name = "Overcharged Tail Laserblade"
	desc = "Tail Laserblade Implant comes with self-destructing auto-implanter. Show the enemy how deadly your tail can be."
	item = /obj/item/autoimplanter/oneuse/laserblade
	cost = 38
	surplus = 0
	uplinktypes = list(UPLINK_TYPE_TRAITOR)

// POINTLESS BADASSERY

/datum/uplink_item/badass
	category = "(Pointless) Badassery"
	surplus = 0

/datum/uplink_item/badass/desert_eagle
	name = "Desert Eagle"
	desc = "A badass gold plated Desert Eagle folded over a million times by superior martian gunsmiths. Uses .50AE ammo. Kill with style."
	item = /obj/item/gun/projectile/automatic/pistol/deagle/gold
	cost = 50

/datum/uplink_item/badass/syndiecigs
	name = "Syndicate Smokes"
	desc = "Strong flavor, dense smoke, infused with syndiezine."
	item = /obj/item/storage/fancy/cigarettes/cigpack_syndicate
	cost = 2

/datum/uplink_item/badass/syndiecards
	name = "Syndicate Playing Cards"
	desc = "A special deck of space-grade playing cards with a mono-molecular edge and metal reinforcement, making them lethal weapons both when wielded as a blade and when thrown. \
	You can also play card games with them."
	item = /obj/item/deck/cards/syndicate
	cost = 2
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 40

/datum/uplink_item/badass/syndiecash
	name = "Syndicate Briefcase Full of Cash"
	desc = "A secure briefcase containing 5000 space credits. Useful for bribing personnel, or purchasing goods and services at lucrative prices. \
	The briefcase also feels a little heavier to hold; it has been manufactured to pack a little bit more of a punch if your client needs some convincing."
	item = /obj/item/storage/secure/briefcase/syndie
	cost = 5

/datum/uplink_item/badass/plasticbag
	name = "Plastic Bag"
	desc = "A simple, plastic bag. Keep out of reach of small children, do not apply to head."
	item = /obj/item/storage/bag/plasticbag
	cost = 1
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/badass/balloon
	name = "For showing that you are The Boss"
	desc = "A useless red balloon with the syndicate logo on it, which can blow the deepest of covers."
	item = /obj/item/toy/syndicateballoon
	cost = 100
	can_discount = FALSE

/datum/uplink_item/badass/unocard
	name = "Syndicate Reverse Card"
	desc = "Hidden in an ordinary-looking playing card, this device will teleport an opponent's gun to your hand when they fire at you. Just make sure to hold this in your hand!"
	item = /obj/item/syndicate_reverse_card
	cost = 10

/datum/uplink_item/implants/macrobomb
	name = "Macrobomb Implant"
	desc = "An implant injected into the body, and later activated either manually or automatically upon death. Upon death, releases a massive explosion that will wipe out everything nearby."
	item = /obj/item/implanter/explosive_macro
	cost = 100
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/bundles_TC
	category = "Bundles and Telecrystals"
	surplus = 0
	can_discount = FALSE

/datum/uplink_item/bundles_TC/bulldog
	name = "Bulldog Bundle"
	desc = "Lean and mean: Optimized for people that want to get up close and personal. Contains the popular \
			Bulldog shotgun, two 12g buckshot drums, and a pair of Thermal imaging goggles."
	item = /obj/item/storage/backpack/duffel/syndie/bulldogbundle
	cost = 45 // normally 60
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/bundles_TC/c20r
	name = "C-20r Bundle"
	desc = "Old Faithful: The classic C-20r, bundled with three magazines and a (surplus) suppressor at discount price."
	item = /obj/item/storage/backpack/duffel/syndie/c20rbundle
	cost = 90 // normally 105
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/bundles_TC/cyber_implants
	name = "Cybernetic Implants Bundle"
	desc = "A random selection of cybernetic implants. Guaranteed 5 high quality implants. \
			Comes with an automated implanting tool."
	item = /obj/item/storage/box/cyber_implants/bundle
	cost = 200
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/bundles_TC/medical
	name = "Medical Bundle"
	desc = "The support specialist: Aid your fellow operatives with this medical bundle. Contains a tactical medkit, additional mender and hypospray, \
			a medical beam gun implant, a surgery implant, a handheld defibrillator, autoimplanter, health analyzers, and a medical hardsuit."
	item = /obj/item/storage/backpack/duffel/syndie/med/medicalbundle
	cost = 175 // normally 200
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/bundles_TC/sniper
	name = "Sniper bundle"
	desc = "Elegant and refined: Contains a collapsed sniper rifle in an expensive carrying case, \
			two soporific knockout magazines, a free surplus suppressor, and a sharp-looking tactical turtleneck suit. \
			We'll throw in a free red tie if you order NOW."
	item = /obj/item/storage/briefcase/sniperbundle
	cost = 110 // normally 135
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/bundles_TC/cyborg_maint
	name = "Cyborg maintenance crate"
	desc = "A box containing all internal parts of cyborg for repair."
	item = /obj/item/storage/box/syndie_kit/cyborg_maint
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/bundles_TC/badass
	name = "Syndicate Bundle"
	desc = "Syndicate Bundles are specialised groups of items that arrive in a plain box. These items are collectively worth more than 100 telecrystals. You can select one out of three specialisations after purchase."
	item = /obj/item/radio/beacon/syndicate/bundle
	cost = 100
	refundable = TRUE
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/bundles_TC/surplus_crate
	name = "Syndicate Surplus Crate"
	desc = "A crate containing 250 telecrystals worth of random syndicate leftovers."
	cost = 100
	item = /obj/item/storage/box/syndicate
	excludefrom = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	var/crate_value = 250

/datum/uplink_item/bundles_TC/surplus_crate/super
	name = "Syndicate Super Surplus Crate"
	desc = "A crate containing 625 telecrystals worth of random syndicate leftovers."
	cost = 200
	crate_value = 625


/datum/uplink_item/bundles_TC/surplus_crate/spawn_item(mob/buyer, obj/item/uplink/target_uplink)
	var/obj/structure/closet/crate/crate = new(get_turf(buyer))
	var/list/buyable_items = get_uplink_items(target_uplink, generate_discounts = FALSE)
	var/remaining_TC = crate_value
	var/list/bought_items = list()
	var/list/itemlog = list()
	target_uplink.uses -= cost
	target_uplink.used_TC = cost


	while(remaining_TC && buyable_items.len)
		var/datum/uplink_item/chosen_item = pick(buyable_items)
		if(!chosen_item.surplus || prob(100 - chosen_item.surplus))
			continue
		if(chosen_item.cost > remaining_TC)
			continue
		if((chosen_item.item in bought_items) && prob(33)) //To prevent people from being flooded with the same thing over and over again.
			continue
		bought_items += chosen_item.item
		remaining_TC -= chosen_item.cost
		itemlog += chosen_item.name // To make the name more readable for the log compared to just i.item

	target_uplink.purchase_log += "<BIG>[bicon(crate)]</BIG>"
	for(var/bought_item in bought_items)
		var/obj/purchased = new bought_item(crate)
		target_uplink.purchase_log += "<BIG>[bicon(purchased)]</BIG>"
	add_game_logs("purchased a surplus crate with [jointext(itemlog, ", ")]", buyer)


/datum/uplink_item/bundles_TC/telecrystal
	name = "Raw Telecrystal"
	desc = "Telecrystal in its rawest and purest form; can be utilized on active uplinks to increase their telecrystal count."
	item = /obj/item/stack/telecrystal
	cost = 1

/datum/uplink_item/bundles_TC/telecrystal/twenty_five
	name = "25 Raw Telecrystals"
	desc = "Twenty five telecrystals in their rawest and purest form; can be utilized on active uplinks to increase their telecrystal count."
	item = /obj/item/stack/telecrystal/twenty_five
	cost = 25

/datum/uplink_item/bundles_TC/telecrystal/hundred
	name = "100 Raw Telecrystals"
	desc = "Hundred telecrystals in their rawest and purest form; can be utilized on active uplinks to increase their telecrystal count."
	item = /obj/item/stack/telecrystal/hundred
	cost = 100

/datum/uplink_item/bundles_TC/telecrystal/twohundred_fifty
	name = "250 Raw Telecrystals"
	desc = "Two hundred fifty telecrystals in their rawest and purest form. You know you want that Mauler."
	item = /obj/item/stack/telecrystal/twohundred_fifty
	cost = 250
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/contractor
	category = "Contractor"
	uplinktypes = list(UPLINK_TYPE_ADMIN)
	surplus = 0
	can_discount = FALSE

/datum/uplink_item/contractor/balloon
	name = "Contractor Balloon"
	desc = "An unique black and gold balloon with no purpose other than showing off. All contracts must be completed in the hardest location to unlock this."
	item = /obj/item/toy/syndicateballoon/contractor
	cost = 240

/datum/uplink_item/contractor/baton
	name = "Contractor Baton"
	desc = "A compact, specialised baton issued to Syndicate contractors. Applies light electrical shocks to targets. Never know when you will get disarmed."
	item = /obj/item/melee/baton/telescopic/contractor
	cost = 40

/datum/uplink_item/contractor/baton_cuffup
	name = "Baton Cuff Upgrade"
	desc = "Using technology reverse-engineered from some alien batons we had lying around, you can now cuff people using your baton. Due to technical limitations, only cable cuffs work, and they need to be loaded into the baton manually."
	item = /obj/item/baton_upgrade/cuff
	cost = 40

/datum/uplink_item/contractor/baton_muteup
	name = "Baton Mute Upgrade"
	desc = "A relatively new advancement in completely proprietary baton technology, this baton upgrade will mute anyone hit for about five seconds."
	item = /obj/item/baton_upgrade/mute
	cost = 40

/datum/uplink_item/contractor/baton_focusup
	name = "Baton Focus Upgrade"
	desc = "When applied to a baton, it will exhaust the target even more, should they be the target of your current contract."
	item = /obj/item/baton_upgrade/focus
	cost = 40

/datum/uplink_item/contractor/baton_antidropup
	name = "Baton Antidrop Upgrade"
	desc = "An experimental and extremely undertested technology that activates a system of spikes that burrow into the skin when user extends baton, preventing the user to drop it. That will hurt.."
	item = /obj/item/baton_upgrade/antidrop
	cost = 40

/datum/uplink_item/contractor/fulton
	name = "Fulton Extraction Kit"
	desc = "For getting your target across the station to those difficult dropoffs. Place the beacon somewhere secure, and link the pack. Activating the pack on your target will send them over to the beacon - make sure they're not just going to run away though!"
	item = /obj/item/storage/box/contractor/fulton_kit
	cost = 20

/datum/uplink_item/contractor/contractor_hardsuit
	name = "Contractor Hardsuit"
	desc = "A top-tier Hardsuit developed with cooperation of Cybersun Industries and the Gorlex Marauders, a favorite of Syndicate Contractors. \
	In addition, it has an in-built chameleon system, allowing you to disguise your hardsuit to the most common variations on your mission area."
	item = /obj/item/storage/box/contractor/hardsuit
	cost = 80

/datum/uplink_item/contractor/pinpointer
	name = "Contractor Pinpointer"
	desc = "A low accuracy pinpointer that can track anyone in the sector without the need for suit sensors. Can only be used by the first person to activate it."
	item = /obj/item/pinpointer/crew/contractor
	cost = 20

/datum/uplink_item/contractor/contractor_partner
	name = "Reinforcements"
	desc = "Upon purchase we'll give you a device, that contact available units in the area. Should there be an agent free, we'll send them down to assist you immediately. If no units are free, we give a full refund."
	item = /obj/item/antag_spawner/contractor_partner
	cost = 40
	refundable = TRUE

/datum/uplink_item/contractor/spai_kit
	name = "SPAI Kit"
	desc = "A kit with your personal assistant. It comes with an increased amount of memory and special programs."
	item = /obj/item/storage/box/contractor/spai_kit
	cost = 40
	refundable = TRUE
	refund_path = /obj/item/paicard_upgrade/unused

/datum/uplink_item/contractor/zippo
	name = "Contractor Zippo Lighter"
	desc = "A kit with your personal assistant. It comes with an increased amount of memory and special programs."
	item = /obj/item/storage/box/contractor/spai_kit
	cost = 120

/datum/uplink_item/contractor/loadout_box
	name = "Contractor standard loadout box"
	desc = "A standard issue box included in a contractor kit."
	item = /obj/item/storage/box/syndie_kit/contractor_loadout
	cost = 40

#undef UPLINK_DISCOUNTS
