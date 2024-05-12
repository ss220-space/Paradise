/atom/movable/screen/plane_master/clickcatcher
	name = "Click Catcher"
	documentation = "Contains the screen object we use as a backdrop to catch clicks on portions of the screen that would otherwise contain nothing else. \
		<br>Will always be below almost everything else"
	plane = CLICKCATCHER_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	multiz_scaled = FALSE

/atom/movable/screen/plane_master/clickcatcher/Initialize(mapload, datum/plane_master_group/home, offset)
	. = ..()
	RegisterSignal(SSmapping, COMSIG_PLANE_OFFSET_INCREASE, .proc/offset_increased)
	offset_increased(SSmapping, 0, SSmapping.max_plane_offset)

/atom/movable/screen/plane_master/clickcatcher/proc/offset_increased(datum/source, old_off, new_off)
	SIGNAL_HANDLER
	// We only want need the lowest level
	// If my system better supported changing PM plane values mid op I'd do that, but I do NOT so
	if(new_off > offset)
		hide_plane(home?.our_hud?.mymob)

/atom/movable/screen/plane_master/parallax_white
	name = "Parallax whitifier"
	documentation = "Essentially a backdrop for the parallax plane. We're rendered just below it, so we'll be multiplied by its well, parallax.\
		<br>If you want something to look as if it has parallax on it, draw it to this plane."
	plane = PLANE_SPACE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR

///Contains space parallax
/atom/movable/screen/plane_master/parallax
	name = "Parallax"
	documentation = "Contains parallax, or to be more exact the screen objects that hold parallax.\
		<br>Note the BLEND_MULTIPLY. The trick here is how low our plane value is. Because of that, we draw below almost everything in the game.\
		<br>We abuse this to ensure we multiply against the Parallax whitifier plane, or space's plane. It's set to full white, so when you do the multiply you just get parallax out where it well, makes sense to be.\
		<br>Also notice that the parent parallax plane is mirrored down to all children. We want to support viewing parallax across all z levels at once."
	plane = PLANE_SPACE_PARALLAX
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	multiz_scaled = FALSE

/atom/movable/screen/plane_master/parallax/Initialize(mapload, datum/plane_master_group/home, offset)
	. = ..()
	if(offset != 0)
		// You aren't the source? don't change yourself
		return
	RegisterSignal(SSmapping, COMSIG_PLANE_OFFSET_INCREASE, .proc/on_offset_increase)
	offset_increase(0, SSmapping.max_plane_offset)

/atom/movable/screen/plane_master/parallax/proc/on_offset_increase(datum/source, old_offset, new_offset)
	SIGNAL_HANDLER
	offset_increase(old_offset, new_offset)

/atom/movable/screen/plane_master/parallax/proc/offset_increase(old_offset, new_offset)
	// Parallax will be mirrored down to any new planes that are added, so it will properly render across mirage borders
	for(var/offset in old_offset to new_offset)
		if(offset != 0)
			// Overlay so we don't multiply twice, and thus fuck up our rendering
			add_relay_to(GET_NEW_PLANE(plane, offset), BLEND_OVERLAY)

/atom/movable/screen/plane_master/gravpulse
	name = "Gravpulse"
	documentation = "Ok so this one's fun. Basically, we want to be able to distort the game plane when a grav annom is around.\
		<br>So we draw the pattern we want to use to this plane, and it's then used as a render target by a distortion filter on the game plane.\
		<br>Note the blend mode and lack of relay targets. This plane exists only to distort, it's never rendered anywhere."
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = GRAVITY_PULSE_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	blend_mode = BLEND_ADD
	render_target = GRAVITY_PULSE_RENDER_TARGET
	render_relay_planes = list()

/atom/movable/screen/plane_master/floor
	name = "Floor"
	documentation = "The well, floor. This is mostly used as a sorting mechanism, but it also lets us create a \"border\" around the game world plane, so its drop shadow will actually work."
	plane = FLOOR_PLANE

/atom/movable/screen/plane_master/game
	name = "Lower game world"
	documentation = "Holds anything that draws just above floor. Runes, crayons and etc."
	plane = GAME_PLANE
	render_relay_planes = list(RENDER_PLANE_GAME_WORLD)

/atom/movable/screen/plane_master/game_world_above
	name = "Upper Game"
	documentation = "For stuff you want to draw like the game plane, but not ever below its contents"
	plane = ABOVE_GAME_PLANE
	render_relay_planes = list(RENDER_PLANE_GAME_WORLD)

/**
 * Plane master handling byond internal blackness
 * vars are set as to replicate behavior when rendering to other planes
 * do not touch this unless you know what you are doing
 */
/atom/movable/screen/plane_master/blackness
	name = "Darkness"
	documentation = "This is quite fiddly, so bear with me. By default (in byond) everything in the game is rendered onto plane 0. It's the default plane. \
		<br>But, because we've moved everything we control off plane 0, all that's left is stuff byond internally renders. \
		<br>What we're doing here is using plane 0 to capture \"Blackness\", or the mask that hides tiles. Note, this only works if our mob has the SEE_PIXELS or SEE_BLACKNESS sight flags.\
		<br>We relay this plane master (on plane 0) down to other copies of itself, depending on the layer your mob is on at the moment.\
		<br>Of note: plane master blackness, and the blackness that comes from having nothing to display look similar, but are not the same thing,\
		mind yourself when you're working with this plane, you might have accidentially been trying to work with the wrong thing."
	plane = BLACKNESS_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	// Note: we don't set this to blend multiply because it just dies when its alpha is modified, because of fun byond bugs
	// Marked as multiz_scaled = FALSE because it should not scale, scaling lets you see "through" the floor
	multiz_scaled = FALSE

/atom/movable/screen/plane_master/blackness/show_to(mob/mymob)
	. = ..()
	if(!.)
		return
	if(offset != 0)
		// You aren't the source? don't change yourself
		return
	RegisterSignal(mymob, COMSIG_MOB_SIGHT_CHANGE, .proc/handle_sight_value)
	handle_sight_value(mymob, mymob.sight, 0)
	var/datum/hud/hud = home.our_hud
	if(hud)
		RegisterSignal(hud, COMSIG_HUD_OFFSET_CHANGED, .proc/on_offset_change)
	offset_change(0, hud?.current_plane_offset || 0)

/atom/movable/screen/plane_master/blackness/hide_from(mob/oldmob)
	. = ..()
	if(offset != 0)
		return
	UnregisterSignal(oldmob, COMSIG_MOB_SIGHT_CHANGE)
	var/datum/hud/hud = home.our_hud
	if(hud)
		UnregisterSignal(hud, COMSIG_HUD_OFFSET_CHANGED, .proc/on_offset_change)

/// Reacts to some new plane master value
/atom/movable/screen/plane_master/blackness/proc/handle_sight_value(datum/source, new_sight, old_sight)
	SIGNAL_HANDLER
	// Tryin to set a sight flag that cuts blackness eh?
	if(new_sight & BLACKNESS_CUTTING)
		// Better set alpha then, so it'll actually work
		// We just get the one because there is only one blackness PM, it's just mirrored around
		disable_alpha()
	else
		enable_alpha()

/atom/movable/screen/plane_master/blackness/proc/on_offset_change(datum/source, old_offset, new_offset)
	SIGNAL_HANDLER
	offset_change(old_offset, new_offset)

/atom/movable/screen/plane_master/blackness/proc/offset_change(old_offset, new_offset)
	// Basically, the rule here is the blackness we harvest from the mob using the SEE_BLACKNESS flag will be relayed to the darkness
	// Plane that we're actually on
	if(old_offset != 0) // If our old target wasn't just ourselves
		remove_relay_from(GET_NEW_PLANE(plane, old_offset))
	if(new_offset != 0)
		add_relay_to(GET_NEW_PLANE(plane, new_offset))

/atom/movable/screen/plane_master/area
	name = "Area"
	documentation = "Holds the areas themselves, which ends up meaning it holds any overlays/effects we apply to areas. NOT snow or rad storms, those go on above lighting"
	plane = AREA_PLANE

/atom/movable/screen/plane_master/massive_obj
	name = "Massive object"
	documentation = "Huge objects need to render above everything else on the game plane, otherwise they'd well, get clipped and look not that huge. This does that."
	plane = MASSIVE_OBJ_PLANE

/atom/movable/screen/plane_master/point
	name = "Point"
	documentation = "I mean like, what do you want me to say? Points draw over pretty much everything else, so they get their own plane. Remember we layer render relays to draw planes in their proper order on render plates."
	plane = POINT_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

///Contains all turf lighting
/atom/movable/screen/plane_master/lighting
	name = "lighting plane master"
	documentation = "Contains all lighting drawn to turfs. Not so complex, draws directly onto the lighting plate."
	plane = LIGHTING_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_relay_planes = list(RENDER_PLANE_LIGHTING)
	blend_mode_override = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/// This will not work through multiz, because of a byond bug with BLEND_MULTIPLY
/// Bug report is up, waiting on a fix
/atom/movable/screen/plane_master/o_light_visual
	name = "Overlight light visual"
	documentation = "Holds overlay lighting objects, or the sort of lighting that's a well, overlay stuck to something.\
		<br>Exists because lighting updating is really slow, and movement needs to feel smooth.\
		<br>We draw to the game plane, and mask out space for ourselves on the lighting plane so any color we have has the chance to display."
	plane = O_LIGHTING_VISUAL_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_target = O_LIGHTING_VISUAL_RENDER_TARGET
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blend_mode = BLEND_MULTIPLY

/**
 * Handles emissive overlays and emissive blockers.
 */
/atom/movable/screen/plane_master/emissive
	name = "Emissive"
	documentation = "This system works by exploiting BYONDs color matrix filter to use layers to handle emissive blockers.\
		<br>Emissive overlays are pasted with an atom color that converts them to be entirely some specific color.\
		<br>Emissive blockers are pasted with an atom color that converts them to be entirely some different color.\
		<br>Emissive overlays and emissive blockers are put onto the same plane (This one).\
		<br>The layers for the emissive overlays and emissive blockers cause them to mask eachother similar to normal BYOND objects.\
		<br>A color matrix filter is applied to the emissive plane to mask out anything that isn't whatever the emissive color is.\
		<br>This is then used to alpha mask the lighting plane."
	plane = EMISSIVE_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_target = EMISSIVE_RENDER_TARGET
	render_relay_planes = list()

/atom/movable/screen/plane_master/emissive/Initialize()
	. = ..()
	add_filter("em_block_masking", 1, color_matrix_filter(GLOB.em_mask_matrix))

/atom/movable/screen/plane_master/high_game
	name = "High Game"
	documentation = "Holds anything that wants to be displayed above the rest of the game plane, and doesn't want to be clickable. \
		<br>This includes atmos debug overlays, blind sound images, and mining scanners. \
		<br>Really only exists for its layering potential, we don't use this for any vfx"
	plane = HIGH_GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/plane_master/ghost
	name = "Ghost"
	documentation = "Ghosts draw here, so they don't get mixed up in the visuals of the game world. Note, this is not not how we HIDE ghosts from people, that's done with invisible and see_invisible."
	plane = GHOST_PLANE
	render_relay_planes = list(RENDER_PLANE_NON_GAME)

/atom/movable/screen/plane_master/runechat
	name = "Runechat"
	documentation = "Holds runechat images, that text that pops up when someone say something. Uses a dropshadow to well, look nice."
	plane = RUNECHAT_PLANE
	render_relay_planes = list(RENDER_PLANE_NON_GAME)

/atom/movable/screen/plane_master/runechat/show_to(mob/mymob)
	. = ..()
	if(!.)
		return
	remove_filter("AO")
	if(istype(mymob) && (mymob.client?.prefs.toggles & PREFTOGGLE_AMBIENT_OCCLUSION))
		add_filter("AO", 1, drop_shadow_filter(x = 0, y = -2, size = 4, color = "#04080FAA"))

/atom/movable/screen/plane_master/hud
	name = "HUD"
	documentation = "Contains anything that want to be rendered on the hud. Typically is just screen elements."
	plane = HUD_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_relay_planes = list(RENDER_PLANE_NON_GAME)
	allows_offsetting = FALSE

/atom/movable/screen/plane_master/above_hud
	name = "Above HUD"
	documentation = "Anything that wants to be drawn ABOVE the rest of the hud. Typically close buttons and other elements that need to be always visible. Think preventing draggable action button memes."
	plane = ABOVE_HUD_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_relay_planes = list(RENDER_PLANE_NON_GAME)
	allows_offsetting = FALSE

/atom/movable/screen/plane_master/splashscreen
	name = "Splashscreen"
	documentation = "Anything that's drawn above LITERALLY everything else. Think cinimatics and the well, spashscreen."
	plane = SPLASHSCREEN_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_relay_planes = list(RENDER_PLANE_NON_GAME)
	allows_offsetting = FALSE
