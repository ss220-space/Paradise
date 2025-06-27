/obj/item/stack/telecrystal
	name = "telecrystal"
	desc = "Кажется, что он переполнен загадочной и притягательной энергией."
	ru_names = list(
		NOMINATIVE = "телекристалл",
		GENITIVE = "телекристалла",
		DATIVE = "телекристаллу",
		ACCUSATIVE = "телекристалл",
		INSTRUMENTAL = "телекристаллом",
		PREPOSITIONAL = "телекристалле"
	)
	gender = MALE
	description_antag = "Телекристалл можно активировать, используя на устройствах с активным аплинком."
	singular_name = "telecrystal"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "telecrystal"
	w_class = WEIGHT_CLASS_TINY
	max_amount = 250
	item_flags = NOBLUDGEON
	origin_tech = "materials=6"


/obj/item/stack/telecrystal/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(target != user) //You can't go around smacking people with crystals to find out if they have an uplink or not.
		return .
	for(var/obj/item/implant/uplink/uplink_imp in user)
		if(uplink_imp.imp_in != user)
			continue
		uplink_imp.hidden_uplink.uses += amount
		balloon_alert(user, "ТК активирован!")
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL


/obj/item/stack/telecrystal/afterattack(obj/item/I, mob/user, proximity, params)
	if(!proximity)
		return
	if(istype(I) && I.hidden_uplink && I.hidden_uplink.active) //No metagaming by using this on every PDA around just to see if it gets used up.
		I.hidden_uplink.uses += amount
		use(amount)
		balloon_alert(user, "ТК активирован!")
	else if(istype(I, /obj/item/cartridge/frame))
		var/obj/item/cartridge/frame/cart = I
		if(!cart.charges)
			balloon_alert(user, "заряды кончился!")
			return
		cart.telecrystals += amount
		use(amount)
		balloon_alert(user, "ТК активирован!")

/obj/item/stack/telecrystal/five
	amount = 5

/obj/item/stack/telecrystal/twenty_five
	amount = 25

/obj/item/stack/telecrystal/hundred
	amount = 100

/obj/item/stack/telecrystal/twohundred_fifty
	amount = 250
