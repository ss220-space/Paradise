/obj/item/whetstone
	name = "whetstone"
	desc = "Каменный брусок для заточки инструментов."
	ru_names = list(
		NOMINATIVE = "точильный камень",
		GENITIVE = "точильного камня",
		DATIVE = "точильному камню",
		ACCUSATIVE = "точильный камень",
		INSTRUMENTAL = "точильным камнем",
		PREPOSITIONAL = "точильном камне"
	)
	gender = MALE
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "whetstone"
	w_class = WEIGHT_CLASS_SMALL
	usesound = 'sound/items/screwdriver.ogg'
	/// Amount of uses the whetstone has. Set to -1 for functionally infinite uses.
	var/uses = 1
	/// How much force the whetstone can add to an item.
	var/increment = 4
	/// How much force the whetstone can add to humanoid claws.
	var/claws_increment = 2
	/// Maximum force sharpening items with the whetstone can result in.
	var/max = 30
	/// The prefix a whetstone applies when an item is sharpened with it.
	var/prefix = "sharpened"
	/// If TRUE, the whetstone will only sharpen already sharp items.
	var/requires_sharpness = TRUE


/obj/item/whetstone/attackby(obj/item/I, mob/user, params)
	. = ATTACK_CHAIN_BLOCKED_ALL
	if(!uses)
		to_chat(user, span_warning("Точильный камень слишком изношен для дальнейшего использования!"))
		return .
	if(I.item_flags & NOSHARPENING)
		to_chat(user, span_warning("Сомневаюсь, что [I.declent_ru(NOMINATIVE)] станет острее."))
		return .
	if(I.force >= max || I.throwforce >= max) //So the whetstone never reduces force or throw_force
		to_chat(user, span_warning("[capitalize(I.declent_ru(NOMINATIVE))] и так уже предельно остр[genderize_ru(I.gender,"ый","ая","ое","ые")]!"))
		return .
	if(requires_sharpness && !I.sharp)
		to_chat(user, span_warning("Можно заточить только режущие предметы, например ножи!"))
		return .

	//This block is used to check more things if the item has a relevant component.
	var/signal_out = SEND_SIGNAL(I, COMSIG_ITEM_SHARPEN_ACT, increment, max) //Stores the bitflags returned by SEND_SIGNAL
	if(signal_out & COMPONENT_BLOCK_SHARPEN_MAXED) //If the item's components enforce more limits on maximum power from sharpening,  we fail
		to_chat(user, span_warning("[capitalize(I.declent_ru(NOMINATIVE))] и так уже предельно остр[genderize_ru(I.gender,"ый","ая","ое","ые")]!"))
		return .
	if(signal_out & COMPONENT_BLOCK_SHARPEN_BLOCKED)
		to_chat(user, span_warning("[capitalize(I.declent_ru(NOMINATIVE))] нельзя заточить!"))
		return .
	if((signal_out & COMPONENT_BLOCK_SHARPEN_ALREADY) || (!signal_out && I.force > initial(I.force))) //No sharpening stuff twice
		to_chat(user, span_warning("[capitalize(I.declent_ru(NOMINATIVE))] уже было заточено ранее. Дальнейшая заточка невозможна!"))
		return .
	//If component returns nothing and sharpen_act() returns FALSE we are out
	if(!(signal_out & COMPONENT_BLOCK_SHARPEN_APPLIED) && !I.sharpen_act(src, user))
		return .

	user.visible_message(
		span_notice("[user] затачива[pluralize_ru(user.gender,"ет","ют")] [I.declent_ru(ACCUSATIVE)] при помощи [declent_ru(GENITIVE)]!"),
		span_notice("Вы затачиваете [I.declent_ru(ACCUSATIVE)], делая его гораздо опаснее."),
	)
	playsound(src, usesound, 50, TRUE)
	uses--
	update_appearance()


/obj/item/whetstone/update_name(updates = ALL)
	. = ..()
	name = "[!uses ? "worn out " : ""][initial(name)]"


/obj/item/whetstone/update_desc(updates = ALL)
	. = ..()
	desc = "[initial(desc)][!uses ? " По крайней мере, раньше мог." : ""]"


/obj/item/whetstone/attack_self(mob/living/carbon/human/user)
	. = ..()
	if(!ishuman(user) || !istype(user.dna.species.unarmed, /datum/unarmed_attack/claws))
		return .
	if(!uses)
		to_chat(user, span_warning("Точильный брусок слишком изношен, чтобы его можно было использовать повторно!"))
		return .
	var/datum/unarmed_attack/claws/claws = user.dna.species.unarmed
	if(claws.damage > initial(claws.damage))
		to_chat(user, span_warning("Вы больше не можете точить свои когти!"))
		return .

	claws.damage = clamp(claws.damage + claws_increment, 0, max)
	user.visible_message(
		span_notice("[user] точ[pluralize_ru(user.gender,"ит","ят")] свои когти о [declent_ru(ACCUSATIVE)]!"),
		span_notice("Вы точите свои когти о [declent_ru(ACCUSATIVE)]."),
	)
	playsound(src, usesound, 50, TRUE)
	uses--
	update_appearance()


/obj/item/whetstone/super
	name = "super whetstone block"
	desc = "Каменный блок, который заточит ваше оружие острее, чем Эйнштейн на аддералле."
	ru_names = list(
		NOMINATIVE = "суперточильный блок",
		GENITIVE = "суперточильного блока",
		DATIVE = "суперточильному блоку",
		ACCUSATIVE = "суперточильный блок",
		INSTRUMENTAL = "суперточильным блоком",
		PREPOSITIONAL = "суперточильном блоке"
	)
	increment = 200
	max = 200
	prefix = "super-sharpened"
	requires_sharpness = FALSE
	claws_increment = 200

/obj/item/whetstone/crab_shell
	name = "sturdy crab shell"
	desc = "Маленький панцирь пепельного рака, подходящий для заточки оружия или когтей. Достаточно крепкий для того, чтобы им можно пользоваться несколько раз."
	ru_names = list(
		NOMINATIVE = "панцирь пепельного рака",
		GENITIVE = "панциря пепельного рака",
		DATIVE = "панцирю пепельного рака",
		ACCUSATIVE = "панцирь пепельного рака",
		INSTRUMENTAL = "панцирем пепельного рака",
		PREPOSITIONAL = "панцире пепельного рака"
	)
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "crab_shell"
	lefthand_file = 'icons/mob/inhands/lavaland/fish_items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/fish_items_righthand.dmi'
	item_state = "crab_shell"
	increment = 2
	uses = 2
