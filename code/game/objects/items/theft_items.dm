//Items for nuke theft, supermatter theft traitor objective


// STEALING THE NUKE

//the nuke core, base item
/obj/item/nuke_core
	name = "plutonium core"
	desc = "Extremely radioactive. Wear goggles."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "plutonium_core"
	item_state = "plutoniumcore"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/cooldown = 0
	var/pulseicon = "plutonium_core_pulse"

/obj/item/nuke_core/Initialize()
	. = ..()
	AddComponent(/datum/component/radioactivity, \
				rad_per_cycle = 40, \
				rad_cycle = 2 SECONDS, \
				rad_cycle_radius = 5 \
	)
	START_PROCESSING(SSobj, src)

/obj/item/nuke_core/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/nuke_core/attackby(obj/item/I, mob/user, params)
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/item/nuke_core/process()
	if(cooldown < world.time - 2 SECONDS)
		cooldown = world.time
		flick(pulseicon, src)

/obj/item/nuke_core/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is rubbing [src] against [user.p_them()]self! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return TOXLOSS

/obj/item/nuke_core/plutonium //The steal objective, so it doesnt mess with the SM sliver on pinpointers and objectives

//nuke core box, for carrying the core
/obj/item/nuke_core_container
	name = "nuke core container"
	desc = "A solid container for radioactive objects."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "core_container_empty"
	item_state = "metal"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF //Don't want people trying to break it open with acid, then destroying the core.
	var/obj/item/nuke_core/plutonium/core
	var/dented = FALSE
	var/cracked = FALSE
	var/sealed = FALSE

/obj/item/nuke_core_container/Destroy()
	QDEL_NULL(core)
	return ..()

/obj/item/nuke_core_container/ex_act(severity)
	if(!sealed) //core now immune to blast if not used yet
		return
	if(!isturf(loc)) //if in hands/backpack, can't be cracked open
		return
	switch(severity)
		if(EXPLODE_DEVASTATE)
			if(!cracked)
				crack_open()
				sealed = FALSE
		if(EXPLODE_HEAVY)
			if(!dented)
				dented = TRUE

/obj/item/nuke_core_container/examine(mob/user)
	. = ..()
	if(cracked) // Cracked open.
		. += "<span class='warning'>It is broken, and can no longer store objects safely.</span>"
	else if(dented) // Not cracked, but dented.
		. += "<span class='notice'>[src] looks dented. Perhaps a bigger explosion may break it.</span>"
	else // Not cracked or dented.
		. += "Fine print on the box reads \"Cybersun Industries secure container, guaranteed thermite proof, assistant proof, and explosive resistant.\""


/obj/item/nuke_core_container/update_icon_state()
	if(sealed)
		icon_state = "core_container_sealed"
		return
	if(core)
		icon_state = cracked ? "core_container_cracked_loaded" : "core_container_loaded"
	else
		icon_state = cracked ? "core_container_cracked_empty" : "core_container_empty"


/obj/item/nuke_core_container/attack_hand(mob/user)
	if(cracked && core)
		unload(user)
	else
		return ..()


/obj/item/nuke_core_container/proc/load(obj/item/nuke_core/plutonium/new_core, mob/user)
	if(core || !istype(new_core) || cracked)
		return FALSE
	if(user)
		if(!user.drop_transfer_item_to_loc(new_core, src))
			return FALSE
	else
		new_core.forceMove(src)
	core = new_core
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, span_warning("Container is sealing..."))
	addtimer(CALLBACK(src, PROC_REF(seal)), 10 SECONDS)
	return TRUE


/obj/item/nuke_core_container/proc/unload(mob/user)
	core.add_fingerprint(user)
	user.put_in_active_hand(core)
	core = null
	update_icon(UPDATE_ICON_STATE)

/obj/item/nuke_core_container/proc/seal()
	if(!QDELETED(core))
		STOP_PROCESSING(SSobj, core)
		ADD_TRAIT(core, TRAIT_BLOCK_RADIATION, src)
		sealed = TRUE
		update_icon(UPDATE_ICON_STATE)
		playsound(src, 'sound/items/deconstruct.ogg', 60, TRUE)
		if(ismob(loc))
			to_chat(loc, "<span class='warning'>[src] is permanently sealed, [core]'s radiation is contained.</span>")


/obj/item/nuke_core_container/attackby(obj/item/I, mob/user, params)
	if(load(I, user))
		add_fingerprint(user)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/nuke_core_container/proc/crack_open()
	visible_message("<span class='boldnotice'>[src] bursts open!</span>")
	if(core)
		START_PROCESSING(SSobj, core)
		REMOVE_TRAIT(core, TRAIT_BLOCK_RADIATION, src)
	cracked = TRUE
	update_icon(UPDATE_ICON_STATE)

/obj/item/paper/guides/antag/nuke_instructions
	info = "Как вскрыть ядерную боеголовку Нанотрейзен и вытащить из нее плутониевое ядро:<br>\
	<ul>\
	<li>Добудьте себе одежду, способную защитить от радиации в связи с высокой радиоактивностью ядра.</li>\
	<li>Используйте предоставленную вам отвертку с очень тонким наконечником для того, чтобы открутить переднюю панель терминала боеголовки.</li>\
	<li>Используя лом, снимите переднюю панель боеголовки.</li>\
	<li>Разварите внутренний слой металла, используя сварку.</li>\
	<li>Снимите внутренний слой металла ломом для того, чтобы обнажить плутониевое ядро.</li>\
	<li>Вытащите ядро из ядерной боеголовки.</li>\
	<li>Положите ядро в предоставленный вам контейнер и дождитесь закрытия контейнера.</li>\
	<li>???</li>\
	</ul>"

// STEALING SUPERMATTER.

/obj/item/paper/guides/antag/supermatter_sliver
	info = "Как безопасно получить осколок Суперматерии:<br>\
	<ul>\
	<li>Добудьте лекарственные препараты для лечения возможного радиационного отравления и ожогов, вызванных взаимодействием с кристаллом. </li>\
	<li>Подойдите к активному кристаллу Суперматерии одетым в СИЗ от радиации и высоких температур, со включенными магнитными ботинками. НЕ ПРИКАСАЙТЕСЬ К КРИСТАЛЛУ СУПЕРМАТЕРИИ.</li>\
	<li>Используя предоставленный вам скальпель, предназначенный для работы с Суперматерией, отрежьте осколок от кристалла.</li>\
	<li>Используя так же предоставленные вам щипцы, осторожно возьмите осколок, который вы до этого срезали.</li>\
	<li>Физический контакт любого предмета или живого существа с осколком приведет к уничтожению как предмета, так и вас.</li>\
	<li>Используя щипцы, аккуратно положите осколок в предоставленный контейнер и дождитесь закрытия контейнера.</li>\
	<li>Уходите оттуда, пока кристалл не расслоился.</li>\
	<li>???</li>\
	</ul>"

/obj/item/nuke_core/supermatter_sliver
	name = "supermatter sliver"
	desc = "A tiny, highly volatile sliver of a supermatter crystal. Do not handle without protection!"
	icon_state = "supermatter_sliver"
	pulseicon = "supermatter_sliver_pulse"

/obj/item/nuke_core/supermatter_sliver/attack_tk(mob/user) // no TK gibbing memes
	return

/obj/item/nuke_core/supermatter_sliver/can_be_pulled(atom/movable/puller, grab_state, force, supress_message) // no drag memes
	return FALSE


/obj/item/nuke_core/supermatter_sliver/attackby(obj/item/I, mob/living/user, params)
	. = ATTACK_CHAIN_BLOCKED_ALL
	add_fingerprint(user)

	if(istype(I, /obj/item/retractor/supermatter))
		var/obj/item/retractor/supermatter/tongs = I
		if(tongs.sliver)
			to_chat(user, span_warning("The [tongs.name] are already holding a supermatter sliver!"))
			return .
		if(ismob(loc))
			var/mob/holder = loc
			if(!holder.drop_item_ground(src))
				return .
		forceMove(tongs)
		tongs.sliver = src
		tongs.update_icon(UPDATE_ICON_STATE)
		to_chat(user, span_notice("You carefully pick up [src] with [tongs]."))
		return .

	if(istype(I, /obj/item/scalpel/supermatter) || istype(I, /obj/item/nuke_core_container/supermatter)) // we don't want it to dust
		return .

	to_chat(user, span_danger("As it touches [src], both [src] and [I] bursts into flames!"))
	for(var/mob/living/victim in view(5, get_turf(src)))
		victim.apply_effect(80, IRRADIATE)
	playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
	qdel(I)
	qdel(src)


/obj/item/nuke_core/supermatter_sliver/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!isliving(hit_atom))
		return ..()
	var/mob/living/victim = hit_atom
	if(victim.incorporeal_move || HAS_TRAIT(victim, TRAIT_GODMODE)) //try to keep this in sync with supermatter's consume fail conditions
		return ..()
	if(throwingdatum?.thrower)
		var/mob/user = throwingdatum.thrower
		add_attack_logs(user, victim, "[victim] consumed by [src] thrown by [user] ")
		message_admins("[src] has consumed [key_name_admin(victim)] [ADMIN_JMP(src)], thrown by [key_name_admin(user)].")
		investigate_log("has consumed [key_name(victim)], thrown by [key_name(user)]", "supermatter")
	else
		message_admins("[src] has consumed [key_name_admin(victim)] [ADMIN_JMP(src)] via throw impact.")
		investigate_log("has consumed [key_name(victim)] via throw impact.", "supermatter")
	victim.visible_message("<span class='danger'>As [victim] is hit by [src], both burst into flames and silence fills the room...</span>",
	"<span class='userdanger'>You're hit by [src] and everything suddenly goes silent.\n[src] bursts into flames, and soon as you can register this, you do as well.</span>",
	"<span class='hear'>Everything suddenly goes silent.</span>")
	victim.gib()
	for(var/mob/living/L in view(5, src))
		L.apply_effect(120, IRRADIATE)
	playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
	qdel(src)


/obj/item/nuke_core/supermatter_sliver/pickup(mob/living/user)
	if(!isliving(user) || HAS_TRAIT(user, TRAIT_GODMODE)) //try to keep this in sync with supermatter's consume fail conditions
		return ..()
	user.visible_message(
		span_danger("[user] reaches out and tries to pick up [src]. [user.p_their()] body starts to glow and bursts into flames before bursting into flames!"),
		span_userdanger("You reach for [src] with your hands. That was dumb."),
		span_italics("Everything suddenly goes silent."),
	)
	for(var/mob/living/L in view(5, src))
		L.apply_effect(80, IRRADIATE)
	playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
	user.gib()
	return FALSE


/obj/item/nuke_core_container/supermatter
	name = "supermatter bin"
	desc = "A tiny receptacle that releases an inert hyper-noblium mix upon sealing, allowing a sliver of a supermatter crystal to be safely stored."
	var/obj/item/nuke_core/supermatter_sliver/sliver

/obj/item/nuke_core_container/supermatter/Destroy()
	QDEL_NULL(sliver)
	return ..()


/obj/item/nuke_core_container/supermatter/update_name(updates = ALL)
	. = ..()
	name = cracked ? "broken supermatter bin" : initial(name)


/obj/item/nuke_core_container/supermatter/update_icon_state()
	if(sealed)
		icon_state = "supermatter_container_sealed"
		return
	if(sliver)
		icon_state = cracked ? "core_container_cracked_loaded" : "core_container_loaded"
	else
		icon_state = "core_container_cracked_empty"


/obj/item/nuke_core_container/supermatter/load(obj/item/retractor/supermatter/I, mob/user)
	if(!istype(I) || !I.sliver || sliver)
		return
	I.sliver.forceMove(src)
	sliver = I.sliver
	I.sliver = null
	I.update_icon(UPDATE_ICON_STATE)
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, "<span class='warning'>Container is sealing...</span>")
	addtimer(CALLBACK(src, PROC_REF(seal)), 10 SECONDS)

/obj/item/nuke_core_container/supermatter/seal()
	if(!QDELETED(sliver))
		STOP_PROCESSING(SSobj, sliver)
		ADD_TRAIT(sliver, TRAIT_BLOCK_RADIATION, src)
		playsound(src, 'sound/items/deconstruct.ogg', 60, TRUE)
		sealed = TRUE
		update_icon(UPDATE_ICON_STATE)
		if(ismob(loc))
			to_chat(loc, "<span class='warning'>[src] is permanently sealed, [sliver] is safely contained.</span>")

/obj/item/nuke_core_container/supermatter/unload(obj/item/retractor/supermatter/I, mob/user)
	if(!istype(I) || I.sliver)
		return
	sliver.forceMove(I)
	I.sliver = sliver
	sliver = null
	I.update_icon(UPDATE_ICON_STATE)
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, "<span class='notice'>You carefully pick up [I.sliver] with [I].</span>")


/obj/item/nuke_core_container/supermatter/attackby(obj/item/retractor/supermatter/tongs, mob/user, params)
	if(istype(tongs))
		add_fingerprint(user)
		if(cracked)
			//lets take that shard out
			unload(tongs, user)
		else
			//try to load shard into core
			load(tongs, user)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/nuke_core_container/supermatter/attack_hand(mob/user)
	if(cracked && sliver) //What did we say about touching the shard...
		if(!isliving(user) || HAS_TRAIT(user, TRAIT_GODMODE))
			return FALSE
		user.visible_message("<span class='danger'>[user] reaches out and tries to pick up [sliver]. [user.p_their()] body starts to glow and bursts into flames!</span>",
				"<span class='userdanger'>You reach for [sliver] with your hands. That was dumb.</span>",
				"<span class='italics'>Everything suddenly goes silent.</span>")
		for(var/mob/living/L in view(5, src))
			L.apply_effect(80, IRRADIATE)
		playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
		message_admins("[sliver] has consumed [key_name_admin(user)] [ADMIN_JMP(src)].")
		investigate_log("has consumed [key_name(user)].", "supermatter")
		user.gib()
		QDEL_NULL(sliver)
		update_icon(UPDATE_ICON_STATE)
	else
		return ..()


/obj/item/nuke_core_container/supermatter/crack_open()
	visible_message("<span class='boldnotice'>[src] bursts open!</span>")
	if(sliver)
		START_PROCESSING(SSobj, sliver)
		REMOVE_TRAIT(sliver, TRAIT_BLOCK_RADIATION, src)
	cracked = TRUE
	update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)

/obj/item/scalpel/supermatter
	name = "supermatter scalpel"
	desc = "A scalpel with a fragile tip of condensed hyper-noblium gas, searingly cold to the touch, that can safely shave a sliver off a supermatter crystal."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "supermatter_scalpel"
	toolspeed = 0.5
	damtype = BURN
	usesound = 'sound/weapons/bladeslice.ogg'
	var/uses_left

/obj/item/scalpel/supermatter/Initialize()
	. = ..()
	uses_left = rand(2, 4)

/obj/item/retractor/supermatter
	name = "supermatter extraction tongs"
	desc = "A pair of tongs made from condensed hyper-noblium gas, searingly cold to the touch, that can safely grip a supermatter sliver."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "supermatter_tongs"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	item_state = "supermatter_tongs"
	toolspeed = 0.75
	damtype = BURN
	var/obj/item/nuke_core/supermatter_sliver/sliver

/obj/item/retractor/supermatter/Destroy()
	QDEL_NULL(sliver)
	return ..()


/obj/item/retractor/supermatter/update_icon_state()
	icon_state = "supermatter_tongs[sliver ? "_loaded" : ""]"
	item_state = "supermatter_tongs[sliver ? "_loaded" : ""]"
	update_equipped_item(update_speedmods = FALSE)


/obj/item/retractor/supermatter/afterattack(atom/O, mob/user, proximity, params)
	. = ..()
	if(!sliver)
		return
	if(proximity && ismovable(O) && O != sliver)
		Consume(O, user)

/obj/item/retractor/supermatter/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum) // no instakill supermatter javelins
	if(sliver)
		sliver.forceMove(loc)
		visible_message("<span class='notice'>[sliver] falls out of [src] as it hits the ground.</span>")
		sliver = null
		update_icon(UPDATE_ICON_STATE)
	return ..()

/obj/item/retractor/supermatter/proc/Consume(atom/movable/AM, mob/living/user)
	if(ismob(AM))
		if(!isliving(AM))
			return
		var/mob/living/victim = AM
		if(victim.incorporeal_move || HAS_TRAIT(victim, TRAIT_GODMODE)) //try to keep this in sync with supermatter's consume fail conditions
			return
		victim.gib()
		message_admins("[src] has consumed [key_name_admin(victim)] [ADMIN_JMP(src)].")
		investigate_log("has irradiated [key_name(victim)].", "supermatter")
	else if(istype(AM, /obj/singularity))
		return
	else if(istype(AM, /obj/item/nuke_core_container))
		return
	else if(istype(AM, /obj/machinery/power/supermatter_shard))
		return
	else
		investigate_log("has consumed [AM].", "supermatter")
		qdel(AM)
	if(user)
		add_attack_logs(user, AM, "[AM] and [user] consumed by melee attack with [src] by [user]")
		user.visible_message("<span class='danger'>As [user] touches [AM] with [src], both bursts into flames and silence fills the room...</span>",
			"<span class='userdanger'>You touch [AM] with [src], and everything suddenly goes silent.\n[AM] and [sliver] bursts into flames, and soon as you can register this, you do as well.</span>",
			"<span class='hear'>Everything suddenly goes silent.</span>")
		user.gib()
	for(var/mob/living/L in view(5, src))
		L.apply_effect(60, IRRADIATE)
	playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
	QDEL_NULL(sliver)
	update_icon(UPDATE_ICON_STATE)

