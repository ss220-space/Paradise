#define METAL 1
#define WOOD 2
#define SAND 3

#define DROPWALL_UPTIME 1 MINUTES

#define AUTO "автоматический"

/**
 * MARK: Barricade
 */
/obj/structure/barricade
	name = "chest high wall"
	desc = "Looks like this would make good cover."
	anchored = TRUE
	density = TRUE
	max_integrity = 100
	/// How many projectiles will pass the cover. Lower means stronger cover.
	var/proj_pass_rate = 50
	var/bar_material = METAL
	var/drop_amount = 3
	var/stacktype = /obj/item/stack/sheet/metal
	/// This variable is used to allow projectiles to always shoot through a barrier from a certain direction
	var/directional_blockage = FALSE
	//The list of directions to block a projectile from
	var/list/directional_list = list()

/obj/structure/barricade/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -40, 5)

/obj/structure/barricade/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		make_debris()
	qdel(src)

/obj/structure/barricade/proc/make_debris()
	if(stacktype)
		new stacktype(get_turf(src), drop_amount)

/obj/structure/barricade/welder_act(mob/user, obj/item/I)
	if(bar_material != METAL)
		return
	if(obj_integrity >= max_integrity)
		to_chat(user, span_notice("[src] does not need repairs."))
		return
	if(user.a_intent == INTENT_HARM)
		return
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_REPAIR_MESSAGE
	if(I.use_tool(src, user, 40, volume = I.tool_volume))
		WELDER_REPAIR_SUCCESS_MESSAGE
		update_integrity(clamp(obj_integrity + 20, 0, max_integrity))
		update_icon()
	return TRUE

/obj/structure/barricade/CanAllowThrough(atom/movable/mover, border_dir)//So bullets will fly over and stuff.
	. = ..()
	if(locate(/obj/structure/barricade) in get_turf(mover))
		return TRUE
	if(isprojectile(mover) && !checkpass(mover))
		if(!anchored)
			return TRUE
		var/obj/projectile/proj = mover
		if(directional_blockage)
			if(one_eighty_check(mover))
				return FALSE
		if(proj.firer && Adjacent(proj.firer))
			return TRUE
		if(prob(proj_pass_rate))
			return TRUE
		return FALSE
	if(!isitem(mover)) //thrown items with the dropwall
		return .
	if(!directional_blockage)
		return .
	if(one_eighty_check(mover))
		return FALSE

/obj/structure/barricade/proc/one_eighty_check(atom/movable/mover)
	return turn(mover.dir, 180) in directional_list

/obj/structure/barricade/attack_hand(mob/living/carbon/human/user)
	if(user.a_intent == INTENT_HARM && ishuman(user) && (user.dna.species.obj_damage + user.physiology.punch_obj_damage > 0))
		SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user)
		add_fingerprint(user)
		user.changeNext_move(CLICK_CD_MELEE)
		attack_generic(user, user.dna.species.obj_damage + user.physiology.punch_obj_damage)
		return
	else
		..()

/**
 * MARK: Wooden Barricade
 */
/obj/structure/barricade/wooden
	name = "wooden barricade"
	desc = "This space is blocked off by a wooden barricade."
	icon_state = "woodenbarricade"
	bar_material = WOOD
	stacktype = /obj/item/stack/sheet/wood

/obj/structure/barricade/wooden/attackby(obj/item/I, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I,/obj/item/stack/sheet/wood) && isturf(loc))
		add_fingerprint(user)
		var/obj/item/stack/sheet/wood/wood = I
		if(wood.get_amount() < 5)
			to_chat(user, span_warning("You need at least five wooden planks to make a wall!"))
			return ATTACK_CHAIN_PROCEED

		to_chat(user, span_notice("You start adding [I] to [src]..."))
		if(!do_after(user, 5 SECONDS, src) || QDELETED(wood) || !wood.use(5) || !isturf(loc))
			return ATTACK_CHAIN_PROCEED

		var/turf/our_turf = loc
		our_turf.ChangeTurf(/turf/simulated/wall/mineral/wood/nonmetal)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/structure/barricade/wooden/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(obj_flags & NODECONSTRUCT)
		return
	. = TRUE

	if(!I.tool_use_check(user, 0))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(!I.use_tool(src, user, 4 SECONDS, volume = I.tool_volume))
		return
	deconstruct(TRUE)
	TOOL_DISMANTLE_SUCCESS_MESSAGE

/obj/structure/barricade/wooden/crude
	name = "crude plank barricade"
	desc = "This space is blocked off by a crude assortment of planks."
	icon_state = "woodenbarricade-old"
	drop_amount = 1
	max_integrity = 50
	proj_pass_rate = 65

/obj/structure/barricade/wooden/crude/snow
	desc = "This space is blocked off by a crude assortment of planks. It seems to be covered in a layer of snow."
	icon_state = "woodenbarricade-snow-old"
	max_integrity = 75

/**
 * MARK: Sandbags
 */
/obj/structure/barricade/sandbags
	name = "sandbags"
	desc = "Bags of sand. Self explanatory."
	icon = 'icons/obj/smooth_structures/sandbags.dmi'
	icon_state = "sandbags"
	base_icon_state = "sandbags"
	max_integrity = 280
	proj_pass_rate = 20
	pass_flags_self = LETPASSTHROW
	bar_material = SAND
	climbable = TRUE
	smooth = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SANDBAGS
	canSmoothWith = SMOOTH_GROUP_SECURITY_BARRICADE + SMOOTH_GROUP_SANDBAGS + SMOOTH_GROUP_WALLS
	stacktype = null

/**
 * MARK: Security Barrier
 */
/obj/structure/barricade/security
	name = "security barrier"
	desc = "A deployable barrier. Provides good cover in fire fights."
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrier0"
	density = FALSE
	anchored = FALSE
	max_integrity = 180
	proj_pass_rate = 20
	armor = list(melee = 10, bullet = 50, laser = 50, energy = 50, bomb = 10, bio = 100, fire = 10, acid = 0)
	stacktype = null
	var/deploy_time = 40
	var/deploy_message = TRUE

/obj/structure/barricade/security/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(deploy)), deploy_time)

/obj/structure/barricade/security/proc/deploy()
	icon_state = "barrier1"
	set_density(TRUE)
	set_anchored(TRUE)
	if(deploy_message)
		visible_message(span_warning("[src] deploys!"))

/**
 * MARK: Mime
 */
/obj/structure/barricade/mime
	name = "floor"
	desc = "Is... this a floor?"
	icon = 'icons/effects/water.dmi'
	icon_state = "wet_floor_static"
	stacktype = /obj/item/stack/sheet/mineral/tranquillite

/obj/structure/barricade/mime/mrcd
	stacktype = null

/**
 * MARK: Dropwall
 */
/obj/structure/barricade/dropwall
	name = "dropwall"
	desc = "Временный энергетический щит, питаемый от небольшого генератора. \
			Уничтожение генератора приведёт к полному отключению всех привязанных к нему щитов."
	icon = 'icons/obj/dropwall.dmi'
	icon_state = "dropwall_dead" //sprite chosen in init
	armor = list(MELEE = 0, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 10, FIRE = 10, ACID = 0) // Copied from the security barrier, but no melee armor
	density = FALSE
	directional_blockage = TRUE
	max_integrity = 75 //3 shots from revolver
	proj_pass_rate = 100 //don't worry about it, covered by directional blockage.
	stacktype = null
	explosion_block = 8 //should be enough for a potasium water nade that isn't a maxcap. If you stand next to a maxcap with this however, it will end poorly
	/// This variable is used to tell the shield to ping it's owner when it is broke.
	var/core_shield = FALSE
	/// This variable is to tell the shield what it's source is.
	var/obj/structure/dropwall_generator/source = null

/obj/structure/barricade/dropwall/get_ru_names()
	return list(
		NOMINATIVE = "энергетический щит",
		GENITIVE = "энергетического щита",
		DATIVE = "энергетическому щиту",
		ACCUSATIVE = "энергетический щит",
		INSTRUMENTAL = "энергетическим щитом",
		PREPOSITIONAL = "энергетическом щите"
	)

/obj/structure/barricade/dropwall/Initialize(mapload, owner, core, dir_1, dir_2)
	. = ..()
	source = owner
	core_shield = core
	directional_list += dir_1
	directional_list += dir_2
	if(dir_2)
		icon_state = "[dir2text(dir_1 + dir_2)]"
	else
		icon_state = "[dir2text(dir_1)]"

/obj/structure/barricade/dropwall/Destroy()
	if(core_shield)
		source.protected = FALSE
	source = null
	return ..()

/obj/structure/barricade/dropwall/emp_act(severity)
	..()
	take_damage(40 / severity, BRUTE) //chances are the EMP will also hit the generator, we don't want it to double up too heavily

/obj/structure/barricade/dropwall/bullet_act(obj/projectile/P)
	if(P.shield_buster)
		qdel(src)
	else
		return ..()

/obj/item/grenade/barrier/dropwall
	name = "dropwall shield generator"
	desc = "Генератор энергетического щита, разработанный корпорацией \"Стальная Гвардия\". Используется для создания временного \
			укрытия, при этом позволяя вести безопасную стрельбу с внутренней стороны щита."
	actions_types = list(/datum/action/item_action/toggle_barrier_spread)
	icon = 'icons/obj/dropwall.dmi'
	icon_state = "dropwall"
	item_state = "grenade"
	mode = AUTO
	var/generator_type = /obj/structure/dropwall_generator
	var/uptime = DROPWALL_UPTIME
	/// If this is true we do not arm again, due to the sleep
	var/deployed = FALSE
	/// Mob who armed it. Needed for the get_dir proc
	var/armer

/obj/item/grenade/barrier/dropwall/get_ru_names()
	return list(
		NOMINATIVE = "граната энергощита",
		GENITIVE = "граната энергощита",
		DATIVE = "граната энергощита",
		ACCUSATIVE = "граната энергощита",
		INSTRUMENTAL = "граната энергощита",
		PREPOSITIONAL = "граната энергощита"
	)

/obj/item/grenade/barrier/dropwall/toggle_mode(mob/user)
	switch(mode)
		if(AUTO)
			mode = NORTH
		if(NORTH)
			mode = EAST
		if(EAST)
			mode = SOUTH
		if(SOUTH)
			mode = WEST
		if(WEST)
			mode = AUTO

	balloon_alert(user, "режим — \"[mode == AUTO ? mode : dir2rustext(mode)]\"")

/obj/item/grenade/barrier/dropwall/attack_self(mob/user)
	. = ..()
	armer = user

/obj/item/grenade/barrier/dropwall/end_throw()
	if(active)
		addtimer(CALLBACK(src, PROC_REF(prime)), 1) //Wait for the throw to fully end

/obj/item/grenade/barrier/dropwall/prime()
	if(deployed)
		return
	if(mode == AUTO)
		mode = angle2dir_cardinal(get_angle(armer, get_turf(src)))
	new generator_type(get_turf(loc), mode, uptime)
	deployed = TRUE
	armer = null
	qdel(src)

/obj/structure/dropwall_generator
	name = "deployed dropwall shield generator"
	desc = "Генератор энергетического щита, разработанный корпорацией \"Стальная гвардия\". Используется для создания временного \
			укрытия, при этом позволяя вести безопасную стрельбу со стороны генератора."
	icon = 'icons/obj/dropwall.dmi'
	icon_state = "dropwall_deployed"
	max_integrity = 25 // 2 shots
	var/list/connected_shields = list()
	/// This variable is used to prevent damage to it's core shield when it is up.
	var/protected = FALSE
	///The core shield that protects the generator
	var/obj/structure/barricade/dropwall/core_shield = null
	/// The type of dropwall
	var/barricade_type = /obj/structure/barricade/dropwall
	var/cycle

/obj/structure/dropwall_generator/get_ru_names()
	return list(
		NOMINATIVE = "генератор энергощита",
		GENITIVE = "генератора энергощита",
		DATIVE = "генератору энергощита",
		ACCUSATIVE = "генератор энергощита",
		INSTRUMENTAL = "генератором энергощита",
		PREPOSITIONAL = "генераторе энергощита"
	)

/obj/structure/dropwall_generator/Initialize(mapload, direction, uptime)
	. = ..()
	if(direction)
		deploy(direction, uptime)

/obj/structure/dropwall_generator/Destroy()
	QDEL_LIST(connected_shields)
	core_shield = null
	return ..()

/obj/structure/dropwall_generator/proc/deploy(direction, uptime)
	anchored = TRUE
	protected = TRUE
	addtimer(CALLBACK(src, PROC_REF(power_out)), uptime)
	timer_overlay_proc(uptime / 10)

	connected_shields += new barricade_type(get_turf(loc), src, TRUE, direction)
	core_shield = connected_shields[1]

	var/dir_left = turn(direction, -90)
	var/dir_right = turn(direction, 90)
	var/turf/target_turf = get_step(src, dir_left)
	if(!target_turf.is_blocked_turf())
		connected_shields += new barricade_type(target_turf, src, FALSE, direction, dir_left)

	var/turf/target_turf2 = get_step(src, dir_right)
	if(!target_turf2.is_blocked_turf())
		connected_shields += new barricade_type(target_turf2, src, FALSE, direction, dir_right)

/obj/structure/dropwall_generator/attackby(obj/item/I, mob/living/user, params) //No, you can not just go up to the generator and whack it. Central shield needs to go down first.
	if(!protected)
		return ..()
	visible_message(span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] поглощает удар!"))
	core_shield.take_damage(I.force, I.damtype, MELEE, TRUE)

/obj/structure/dropwall_generator/emp_act(severity)
	..()
	if(!protected)
		qdel(src)
		return

	for(var/obj/structure/barricade/dropwall/our_dropwall in connected_shields)
		our_dropwall.emp_act(severity)

/obj/structure/dropwall_generator/ex_act(severity)
	if(protected && severity > 1) //We would throw the explosion at the shield, but it is already getting hit
		return
	qdel(src)

/obj/structure/dropwall_generator/proc/power_out()
	visible_message(span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] выключается из-за нехватки энергии."))
	new /obj/item/used_dropwall(get_turf(src))
	qdel(src)

/obj/structure/dropwall_generator/proc/timer_overlay_proc(uptime) // This proc will make the timer on the generator tick down like a clock, over 12 equally sized portions (12 times over 12 seconds, every second by default)
	cycle = DROPWALL_UPTIME + 1 - uptime
	update_icon(UPDATE_OVERLAYS)
	if(cycle < 12)
		addtimer(CALLBACK(src, PROC_REF(timer_overlay_proc), uptime - 1), DROPWALL_UPTIME / 12 SECONDS)

/obj/structure/dropwall_generator/update_overlays()
	. = ..()
	. += "[cycle]"

/obj/item/used_dropwall
	name = "broken dropwall generator"
	desc = "Этот генератор вышел из строя и уже ни на что не сгодится."
	icon = 'icons/obj/dropwall.dmi'
	icon_state = "dropwall_dead"
	item_state = "grenade"
	materials = list(MAT_METAL = 500, MAT_GLASS = 300) //plasma burned up for power or something, plus not that much to reclaim

/obj/item/used_dropwall/get_ru_names()
	return list(
		NOMINATIVE = "сломанный генератор энергощита",
		GENITIVE = "сломанного генератора энергощита",
		DATIVE = "сломанному генератору энергощита",
		ACCUSATIVE = "сломанный генератор энергощита",
		INSTRUMENTAL = "сломанным генератором энергощита",
		PREPOSITIONAL = "сломанном генераторе энергощита"
	)

/obj/item/storage/box/syndie_kit/dropwall
	name = "dropwall generator box"

/obj/item/storage/box/syndie_kit/dropwall/get_ru_names()
	return list(
		NOMINATIVE = "коробка с генераторами энергощита",
		GENITIVE = "коробку с генераторами энергощита",
		DATIVE = "коробке с генераторами энергощита",
		ACCUSATIVE = "коробку с генераторами энергощита",
		INSTRUMENTAL = "коробке с генераторами энергощита",
		PREPOSITIONAL = "коробкой с генераторами энергощита"
	)

/obj/item/storage/box/syndie_kit/dropwall/populate_contents()
	for(var/I in 1 to 5)
		new /obj/item/grenade/barrier/dropwall(src)

/obj/item/grenade/barrier/dropwall/firewall
	name = "firewall shield generator"
	generator_type = /obj/structure/dropwall_generator/firewall

/obj/item/grenade/barrier/dropwall/firewall/weak
	generator_type = /obj/structure/dropwall_generator/firewall/weak
	uptime = 20 SECONDS

/obj/item/grenade/barrier/dropwall/firewall/strong
	generator_type = /obj/structure/dropwall_generator/firewall/strong
	uptime = 5 MINUTES

/obj/item/grenade/barrier/dropwall/firewall/get_ru_names()
	return list(
		NOMINATIVE = "граната огненного щита",
		GENITIVE = "граната огненного щита",
		DATIVE = "граната огненного щита",
		ACCUSATIVE = "граната огненного щита",
		INSTRUMENTAL = "граната огненного щита",
		PREPOSITIONAL = "граната огненного щита"
	)
/obj/structure/dropwall_generator/firewall
	name = "deployed firewall shield generator"
	barricade_type = /obj/structure/barricade/dropwall/firewall

/obj/structure/dropwall_generator/firewall/weak
	barricade_type = /obj/structure/barricade/dropwall/firewall/weak

/obj/structure/dropwall_generator/firewall/strong
	barricade_type = /obj/structure/barricade/dropwall/firewall/strong

/obj/structure/dropwall_generator/firewall/get_ru_names()
	return list(
		NOMINATIVE = "генератор огненного щита",
		GENITIVE = "генератора огненного щита",
		DATIVE = "генератору огненного щита",
		ACCUSATIVE = "генератор огненного щита",
		INSTRUMENTAL = "генератором огненного щита",
		PREPOSITIONAL = "генераторе огненного щита"
	)

/obj/structure/barricade/dropwall/firewall
	/// Can our dropwall inflict stamina damage in each shot?
	var/add_knockdown = FALSE
	/// Can our dropwall add penetration in each shot?
	var/add_penetration = TRUE

/obj/structure/barricade/dropwall/firewall/weak
	add_penetration = FALSE

/obj/structure/barricade/dropwall/firewall/strong
	add_knockdown = TRUE

/obj/structure/barricade/dropwall/firewall/Initialize(mapload, owner, core, dir_1, dir_2)
	. = ..()
	var/target_matrix = list(
		2, 0, 0, 0,
		0, 1, 0, 0,
		2, 0, 0, 0,
		0, 0, 0, 1
	)
	color = target_matrix
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/barricade/dropwall/firewall/proc/on_entered(datum/source, atom/movable/entered_atom)
	SIGNAL_HANDLER
	if(!isprojectile(entered_atom))
		return
	var/obj/projectile/projectile = entered_atom
	projectile.immolate++
	if(add_penetration)
		projectile.armour_penetration += 20
	if(add_knockdown)
		projectile.knockdown += 2 SECONDS

/obj/item/grenade/barrier/dropwall/syndie
	name = "bloodwall shield generator"
	generator_type = /obj/structure/dropwall_generator/syndie
	uptime = 20 SECONDS

/obj/structure/dropwall_generator/syndie
	name = "deployed firewall shield generator"
	barricade_type = /obj/structure/barricade/dropwall/bloodwall

/obj/structure/barricade/dropwall/bloodwall
	max_integrity = 125 //5 shots from revolver

/obj/structure/barricade/dropwall/bloodwall/Initialize(mapload, owner, core, dir_1, dir_2)
	. = ..() //unfortunatetly, normal coloring just don't work
	var/target_matrix = list(
		2, 0, 0, 0,
		0, 0, 0, 0,
		1, 0, 0, 0,
		0, 0, 0, 1
	)
	color = target_matrix

#undef METAL
#undef WOOD
#undef SAND

#undef DROPWALL_UPTIME

#undef AUTO
