//rare and valulable gems- designed to eventually be used for archeology, or to be given as opposed to money as loot. Auctioned off at export, or kept as a trophy. -MemedHams

/obj/item/gem
	name = "\improper gem"
	desc = "Ооо! Блестяшка!"
	ru_names = list(
		NOMINATIVE = "самоцвет",
		GENITIVE = "самоцвета",
		DATIVE = "самоцвету",
		ACCUSATIVE = "самоцвет",
		INSTRUMENTAL = "самоцветом",
		PREPOSITIONAL = "самоцвете"
	)
	gender = MALE
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
	base_pixel_x = pixel_x
	base_pixel_y = pixel_y


/obj/item/gem/attackby(obj/item/item, mob/living/user, params) //Stolen directly from geysers, removed the internal gps
	if(!istype(item, /obj/item/mining_scanner) && !istype(item, /obj/item/t_scanner/adv_mining_scanner))
		return ..()

	add_fingerprint(user)
	if(analysed)
		balloon_alert(user, "уже просканировано!")
		return ATTACK_CHAIN_PROCEED

	. = ATTACK_CHAIN_PROCEED_SUCCESS

	balloon_alert(user, "просканировано")
	if(analysed_message)
		to_chat(user, analysed_message)

	analysed = TRUE
	if(true_name)
		name = true_name

	if(shine_overlay)
		cut_overlay(shine_overlay)
		qdel(shine_overlay)

	var/obj/item/card/id/card = user.get_id_card()
	if(!card)
		return .

	to_chat(user, span_notice("Вам было выплачено [point_value] ОДР."))
	card.mining_points += point_value
	playsound(loc, 'sound/machines/ping.ogg', 15, TRUE)


/obj/item/gem/welder_act(mob/living/user, obj/item/I) //Jank code that detects if the gem in question has a sheet_type and spawns the items specifed in it
	if(I.use_tool(src, user, 0, volume=50))
		if(src.sheet_type)
			new src.sheet_type(user.loc)
			to_chat(user, span_notice("Вы осторожно разрезаете [declent_ru(ACCUSATIVE)]."))
			qdel(src)
		else
			balloon_alert(user, "не получается разрезать!")
	return TRUE

//goldgrub gem
/obj/item/gem/rupee
	name = "\improper ruperium crystal"
	desc = "Крайне радиоактивное кристаллическое соединение, которое можно найти во внутренностях златожора. Хоть вы и можете преобразовать кристалл в урановую руду, его истинная ценность заключается в его резонирующих свойствах."
	ru_names = list(
		NOMINATIVE = "кристалл рупериума",
		GENITIVE = "кристалла рупериума",
		DATIVE = "кристаллу рупериума",
		ACCUSATIVE = "кристалл рупериума",
		INSTRUMENTAL = "кристаллом рупериума",
		PREPOSITIONAL = "кристалле рупериума"
	)
	light_color = "#5ECC38"
	icon_state = "rupee"
	materials = list(MAT_URANIUM = 60000)
	sheet_type = /obj/item/stack/sheet/mineral/uranium{amount = 30}
	point_value = 500
	sell_multiplier = 2


/obj/item/gem/rupee/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/radioactivity, \
			rad_per_cycle = 10, \
			rad_cycle = 3 SECONDS, \
			rad_cycle_radius = 5 \
	)
	ADD_TRAIT(src, TRAIT_BLOCK_RADIATION, INNATE_TRAIT)


/obj/item/gem/rupee/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_BLOCK_RADIATION))
		. += span_info("Вы можете использовать что-нибудь <b>острое</b>, чтобы распилить кристалл.")
	else
		. += span_warning("Кристалл ярко горит!")


/obj/item/gem/rupee/update_icon_state()
	icon_state = "[HAS_TRAIT(src, TRAIT_BLOCK_RADIATION) ? "" : "broken_"]rupee"


/obj/item/gem/rupee/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !is_sharp(I) || !HAS_TRAIT(src, TRAIT_BLOCK_RADIATION))
		return .

	to_chat(user, span_notice("Вы начали распиливать кристалл! Это явно плохая идея..."))
	if(!do_after(user, 5 SECONDS, src, max_interact_count = 1, cancel_on_max = TRUE, cancel_message = span_notice("Вы решили не делать глупостей."), category = DA_CAT_TOOL))
		return .
	. |= ATTACK_CHAIN_SUCCESS
	to_chat(user, span_warning("Вы разрушили внешнюю оболочку кристалла! Голова начинает болеть..."))
	user.apply_effect(50, IRRADIATE)
	REMOVE_TRAIT(src, TRAIT_BLOCK_RADIATION, INNATE_TRAIT)
	update_icon(UPDATE_ICON_STATE)


//magmawing watcher gem
/obj/item/gem/magma
	name = "\improper calcified auric"
	desc = "Горячий на ощупь, слегка святящийся минерал, получаемый из потрохов магменных наблюдателей. Может быть переплавлен в чистое золото."
	ru_names = list(
		NOMINATIVE = "окаменелый аурит",
		GENITIVE = "окаменелого аурита",
		DATIVE = "окаменелому ауриту",
		ACCUSATIVE = "окаменелый аурит",
		INSTRUMENTAL = "окаменелым ауритом",
		PREPOSITIONAL = "окаменелом аурите"
	)
	icon_state = "magma"
	materials = list(MAT_GOLD = 100000)
	sheet_type = /obj/item/stack/sheet/mineral/gold{amount = 50}
	point_value = 700 //there is no magmawing tendrills, silly me
	sell_multiplier = 2
	light_range = 4
	light_power = 2
	light_color = "#ff7b00"
	light_system = MOVABLE_LIGHT
	var/hot = TRUE

/obj/item/gem/magma/examine(mob/user)
	. = ..()
	if(!hot)
		. += span_notice("Кристалл, кажется, комнатной температуры.")
	else
		. += span_notice("Кристалл на ощупь очень горячий! Вы можете согреться, если приложите его к груди...")

/obj/item/gem/magma/attack_self(mob/user)
	. = ..()
	var/mob/living/carbon/human/H = user
	if(!hot)
		to_chat(H, span_notice("Вы прикладываете [declent_ru(ACCUSATIVE)] к вашей груди, но он недостаточно теплый."))
		return
	to_chat(H, span_notice("Вы прикладываете [declent_ru(ACCUSATIVE)] к вашей груди и чувствуете поток тепла по всему телу!"))
	H.custom_emote(1, "прижимает кристалл к груди.") //HRP style
	H.adjust_bodytemperature(60)
	set_light_on(FALSE)
	hot = FALSE
	addtimer(CALLBACK(src, PROC_REF(reset_cooldown)), 15 SECONDS)

/obj/item/gem/magma/proc/reset_cooldown()
	hot = TRUE
	set_light_on(TRUE)

//icewing watcher gem
/obj/item/gem/fdiamond
	name = "\improper frost diamond"
	desc = "Уникальный алмаз, получаемый из морозных наблюдателей. Кажется его можно разрезать на маленькие алмазы."
	ru_names = list(
		NOMINATIVE = "морозный бриллиант",
		GENITIVE = "морозного бриллианта",
		DATIVE = "морозному бриллианту",
		ACCUSATIVE = "морозный бриллиант",
		INSTRUMENTAL = "морозным бриллиантом",
		PREPOSITIONAL = "морозном бриллианте"
	)
	icon_state = "diamond"
	materials = list(MAT_DIAMOND = 60000)
	sheet_type = /obj/item/stack/sheet/mineral/diamond{amount = 30}
	point_value = 700
	light_range = 4
	light_power = 2
	light_color = "#62cad5"
	light_system = MOVABLE_LIGHT
	var/cold = TRUE
	sell_multiplier = 2

/obj/item/gem/fdiamond/examine(mob/user)
	. = ..()
	if(!cold)
		. += span_notice("Кристалл, кажется, комнатной температуры.")
	else
		. += span_notice("Кристалл на ощупь очень холодный! Вы можете охладиться, если приложите его к груди...")

/obj/item/gem/fdiamond/attack_self(mob/user)
	. = ..()
	var/mob/living/carbon/human/H = user
	if(!cold)
		to_chat(H, span_notice("Вы прикладываете [declent_ru(ACCUSATIVE)] к вашей груди, но он недостаточно холодный."))
		return
	to_chat(H, span_notice("Вы прикладываете [declent_ru(ACCUSATIVE)] к вашей груди и чувствуете поток холода по всему телу!"))
	H.custom_emote(1, "прижимает алмаз к груди.") //HRP style
	H.adjust_bodytemperature(-60)
	set_light_on(FALSE)
	cold = FALSE
	addtimer(CALLBACK(src, PROC_REF(reset_cooldown)), 15 SECONDS)

/obj/item/gem/fdiamond/proc/reset_cooldown()
	cold = TRUE
	set_light_on(TRUE)

//blood-drunk miner gem
/obj/item/gem/phoron
	name = "\improper stabilized baroxuldium"
	desc = "Мягкий на ощупь кристалл, который можно найти исключительно в самых глубоких жилах плазмы. Судя по всему, ученые им явно заинтересуются."
	ru_names = list(
		NOMINATIVE = "стабилизированный бароксильдиум",
		GENITIVE = "стабилизированного бароксильдиума",
		DATIVE = "стабилизированному бароксильдиуму",
		ACCUSATIVE = "стабилизированный бароксильдиум",
		INSTRUMENTAL = "стабилизированным бароксильдиумом",
		PREPOSITIONAL = "стабилизированном бароксильдиуме"
	)
	icon_state = "phoron"
	materials = list(MAT_PLASMA = 80000)
	sheet_type = /obj/item/stack/sheet/mineral/plasma{amount = 40}
	origin_tech = "materials=6;plasmatech=6"
	point_value = 1000
	sell_multiplier = 3
	light_range = 4
	light_power = 4
	light_color = "#62326a"
	light_system = MOVABLE_LIGHT

//hierophant gem
/obj/item/gem/purple
	name = "\improper densified dilithium"
	desc = "Крайне необычная форма дилитиума, пульсирующая в устойчивом ритме. Этот ритм достаточно легко улавливается большинством систем GPS."
	ru_names = list(
		NOMINATIVE = "уплотненный дилитиум",
		GENITIVE = "уплотненного дилитиума",
		DATIVE = "уплотненному дилитиуму",
		ACCUSATIVE = "уплотненный дилитиум",
		INSTRUMENTAL = "уплотненным дилитиумом",
		PREPOSITIONAL = "уплотненном дилитиуме"
	)
	icon_state = "purple"
	point_value = 1200
	sell_multiplier = 4
	light_range = 4
	light_power = 2
	light_color = "#cc47a6"
	light_system = MOVABLE_LIGHT
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
	desc = "Крайне хрупкий минерал, формирующийся из загустевшей крови пепельного дракона. Крайне популярен среди браконьеров из-за его необычной формы и свечения. Среди охотников ходят истории о невероятной силе, даруемой носителю украшений из этого жемчуга."
	ru_names = list(
		NOMINATIVE = "Драконий жемчуг",
		GENITIVE = "драконего жемчуга",
		DATIVE = "драконьему жемчугу",
		ACCUSATIVE = "драконий жемчуг",
		INSTRUMENTAL = "драконим жемчугом",
		PREPOSITIONAL = "драконем жемчуге"
	)
	icon_state = "amber"
	point_value = 1400
	sell_multiplier = 5
	light_range = 4
	light_power = 4
	light_color = "#FFBF00"
	light_system = MOVABLE_LIGHT

//colossus gem
/obj/item/gem/void
	name = "\improper null crystal"
	desc = "Осколок чистой, кристаллизированной энергии. Эти странные объекты изредка формируются там, где покров реальности крайне неустойчив. Он слегка бьётся током при прикосновении."
	ru_names = list(
		NOMINATIVE = "пустотный кристалл",
		GENITIVE = "пустотного кристалла",
		DATIVE = "пустотному кристаллу",
		ACCUSATIVE = "пустотный кристалл",
		INSTRUMENTAL = "пустотным кристаллом",
		PREPOSITIONAL = "пустотном кристалле"
	)
	icon_state ="void"
	point_value = 1600
	sell_multiplier = 6
	light_range = 4
	light_power = 2
	light_color = "#4785a4"
	light_system = MOVABLE_LIGHT
	var/blink_range = 6
	var/cooldown = FALSE
	var/cooldown_time = 40 SECONDS

/obj/item/gem/void/attack_self_tk(mob/user)
	return

/obj/item/gem/void/examine(mob/user)
	. = ..()
	if(!cooldown)
		. += span_notice("Кристалл подрагивает и ярко светится.")


/obj/item/gem/void/attack_self(mob/user)
	if(cooldown)
		to_chat(user, span_warning("Кристалл неподвижен. Может стоит немного подождать?"))
		return
	var/mob/living/carbon/human/H = user
	teleport(H)
	H.visible_message(span_notice("[H] сжима[pluralize_ru(H.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)] в руках!"))
	cooldown = TRUE
	addtimer(CALLBACK(src, PROC_REF(reset_cooldown)),cooldown_time)

/obj/item/gem/void/proc/teleport(mob/living/L)
	if(!is_teleport_allowed(L.z))
		src.visible_message(span_warning("Кажется, [declent_ru(NOMINATIVE)] начинает дрожать!"))
		return
	do_teleport(L, get_turf(L), blink_range, asoundin = 'sound/effects/phasein.ogg')

/obj/item/gem/void/proc/reset_cooldown()
	cooldown = FALSE

//bubblegum gem. Can be used for antags to get some active blood or TK.
/obj/item/gem/bloodstone
	name = "\improper ichorium"
	desc = "Странная, липкая субстанция, срастающаяся в единое целое в присутствии чего-то ужасающего и потустороннего. В то время, как большинство спиритических групп избегает использования этого кристалла, некоторые наиболее опасные секты высоко его ценят."
	ru_names = list(
		NOMINATIVE = "кровавый ихор",
		GENITIVE = "кровавого ихора",
		DATIVE = "кровавому ихору",
		ACCUSATIVE = "кровавый ихор",
		INSTRUMENTAL = "кровавым ихором",
		PREPOSITIONAL = "кровавом ихоре"
	)
	icon_state = "red"
	point_value = 1800
	sell_multiplier = 7
	light_range = 4
	light_power = 6
	light_color = "#ac0606"
	light_system = MOVABLE_LIGHT
	var/used = FALSE
	var/blood = 50
	var/charges = 10

/obj/item/gem/bloodstone/examine(mob/user)
	. = ..()
	if(isvampire(user) && !used)
		. += span_warning("Вы чувствуете опьяняющий запах крови, исходящий от кристалла.")
	if(user.mind.has_antag_datum(/datum/antagonist/traitor))
		. += span_warning("Судя по всему, этот кристалл можно использовать, чтобы зарядить ваш аплинк.")

/obj/item/gem/bloodstone/attack_self(mob/user)
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(vampire && !used)
		user.visible_message(span_warning("[user] начина[pluralize_ru(user.gender, "ет", "ют")] сжимать [declent_ru(ACCUSATIVE)] в своих руках!"), \
							span_notice("вы сжимаете [declent_ru(ACCUSATIVE)] в ваших руках."))
		if(!do_after(user, 10 SECONDS, user, max_interact_count = 1, cancel_on_max = TRUE, cancel_message = span_warning("Вы ослабили хватку.")))
			return
		user.visible_message(span_warning("[user] начина[pluralize_ru(user.gender, "ет", "ют")] впитывать в себя содержимое [declent_ru(GENITIVE)]!"), \
						span_notice("Вы пожираете содержимое [declent_ru(GENITIVE)]. Энергия от кристалла насыщает вас."))
		vampire.bloodusable += blood
		used = TRUE
		set_light_range_power_color(3, 2, "#ac2626")


/obj/item/gem/bloodstone/afterattack(obj/item/I, mob/user, proximity, params)
	if(!proximity)
		return
	if(istype(I) && I.hidden_uplink && I.hidden_uplink.active)
		I.hidden_uplink.uses += charges
		qdel(src)
		to_chat(user, span_notice("Вы вставляете [declent_ru(ACCUSATIVE)] внутрь вашего апплинка, заряжая его."))


//vetus gem
/obj/item/gem/data
	name = "\improper bluespace data crystal"
	desc = "Массивный блюспейс кристалл, на котором выгравированы наносхемы. Кажется, он черпает энергию из воздуха."
	ru_names = list(
		NOMINATIVE = "блюспейс кристалл данных",
		GENITIVE = "блюспейс кристалла данных",
		DATIVE = "блюспейс кристаллу данных",
		ACCUSATIVE = "блюспейс кристалл данных",
		INSTRUMENTAL = "блюспейс кристаллом данных",
		PREPOSITIONAL = "блюспейс кристалле данных"
	)
	icon_state = "data"
	materials = list(MAT_BLUESPACE = 48000)
	sheet_type = /obj/item/stack/sheet/bluespace_crystal{amount = 24}
	origin_tech = "materials=6;bluespace=7" //uh-oh
	light_range = 4
	light_power = 6
	light_color = "#4245f3"
	light_system = MOVABLE_LIGHT
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
	ru_names = list(
		NOMINATIVE = "рубин",
		GENITIVE = "рубина",
		DATIVE = "рубину",
		ACCUSATIVE = "рубин",
		INSTRUMENTAL = "рубином",
		PREPOSITIONAL = "рубине"
	)
	icon_state = "ruby"
	point_value = 100
	simple = TRUE
	light_color = "#C72414"
	sell_multiplier = 0.5

/obj/item/gem/sapphire
	name = "\improper sapphire"
	ru_names = list(
		NOMINATIVE = "сапфир",
		GENITIVE = "сапфира",
		DATIVE = "сапфиру",
		ACCUSATIVE = "сапфир",
		INSTRUMENTAL = "сапфиром",
		PREPOSITIONAL = "сапфире"
	)
	icon_state = "sapphire"
	point_value = 100
	simple = TRUE
	light_color = "#1726BF"
	sell_multiplier = 0.5

/obj/item/gem/emerald
	name = "\improper emerald"
	ru_names = list(
		NOMINATIVE = "изумруд",
		GENITIVE = "изумруда",
		DATIVE = "изумруду",
		ACCUSATIVE = "изумруд",
		INSTRUMENTAL = "изумрудом",
		PREPOSITIONAL = "изумруд"
	)
	icon_state = "emerald"
	point_value = 100
	simple = TRUE
	light_color = "#14A73C"
	sell_multiplier = 0.5

/obj/item/gem/topaz
	name = "\improper topaz"
	ru_names = list(
		NOMINATIVE = "топаз",
		GENITIVE = "топаза",
		DATIVE = "топазу",
		ACCUSATIVE = "топаз",
		INSTRUMENTAL = "топазом",
		PREPOSITIONAL = "топазе"
	)
	icon_state = "topaz"
	point_value = 100
	simple = TRUE
	light_color = "#C73914"
	sell_multiplier = 0.5
