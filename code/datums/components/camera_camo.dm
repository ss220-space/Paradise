/**
 * Camera-camo component — lock-heretic robes ("Shifting Guise").
 *
 * Makes the wearer invisible on (basic) security camera monitors WITHOUT hiding them from anyone's normal
 * eyes — i.e. the "feed only" behaviour. We redirect the mob's rendering onto CAMERA_CAMO_PLANE via a
 * render-target proxy: that plane renders normally (and lit) in every MAIN view, but the camera console
 * popup plane group force-hides it (see /datum/plane_master_group/popup/prep_plane_instance), so the wearer
 * simply isn't drawn in a security camera feed. In person they look and behave completely normally.
 *
 * How the pieces fit:
 * - parent.render_target = "*camera_camo[uid]" makes the body itself stop drawing directly, and instead get
 *   captured into a named buffer.
 * - `proxy` (in parent.vis_contents) has render_source = that buffer + VIS_INHERIT_ID|VIS_INHERIT_LAYER, and
 *   sits on CAMERA_CAMO_PLANE. So the live body is re-displayed on that plane for everyone, inheriting the
 *   body's click id (it stays clickable) and layer.
 *
 * The AI and the ADVANCED camera console render the world through their MAIN view (the AI's eye / the
 * operator's relocated perspective), NOT through a camera popup — so the plane-hide alone wouldn't hide the
 * wearer from them. For those we additionally blank the proxy with a per-client `override` image, distributed
 * by the existing [/datum/element/digitalcamo] machinery via GLOB.digitalcamo_images (the robe carries that
 * element too). The basic security console is the only viewer handled purely by the plane-hide, which is why
 * it no longer needs to register as a digitalcamo watcher.
 *
 * DATA-HUD MARKERS: the wearer's medical/security HUD markers (health doll, wanted/job/implant icons) are
 * SEPARATE images (mob.hud_list, loc = the mob, FLOAT_PLANE → they ride the mob's game plane), so the body's
 * render-target trick doesn't touch them and they'd otherwise float on a basic camera feed with no body under
 * them — a dead giveaway. We move those images onto CAMERA_CAMO_PLANE too, so the popup-hide swallows them on
 * basic monitors while they still show in person. (The HUD image objects are created once and reused, so a
 * one-shot plane swap sticks; we only re-apply on z-change for the multiz offset.) The AI's data HUDs are
 * already hidden by digitalcamo's hide_from_ai_huds, covering the AI/advanced-console side.
 */
/datum/component/camera_camo
	/// The proxy atom that re-displays our render-target capture onto CAMERA_CAMO_PLANE.
	var/atom/movable/proxy
	/// Blank override image (loc = proxy) fed into GLOB.digitalcamo_images so AIs / advanced-console watchers
	/// can't see the proxy either.
	var/image/blanker
	/// The mob's render_target before we hijacked it (restored on removal).
	var/initial_render_target
	/// Our unique render-target id.
	var/render_id

/// Medical + security data-HUD marker categories we relocate onto the camo plane so they vanish on basic monitors.
GLOBAL_LIST_INIT(camera_camo_hidden_huds, list(
	HEALTH_HUD,
	STATUS_HUD,
	STATUS_HUD_OOC,
	ID_HUD,
	WANTED_HUD,
	IMPMINDSHIELD_HUD,
	IMPCHEM_HUD,
	IMPTRACK_HUD,
))

/datum/component/camera_camo/Initialize()
	. = ..()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

	var/static/camo_uid = 0
	camo_uid++
	render_id = "*camera_camo[camo_uid]"

	proxy = new()
	proxy.name = "camera camo"
	// KEEP_APART so the proxy's appearance is its own thing; inherit id (clickable -> resolves to the body)
	// and layer, but NOT plane - we want it on the camo plane, not the body's game plane.
	// RESET_TRANSFORM: the wearer's transform is ALREADY baked into the render_target capture, and the proxy
	// lives in the wearer's vis_contents so it would otherwise inherit that same transform a SECOND time -
	// double-applying the 90° lying rotation and drawing the body upside-down (180°). Resetting it makes the
	// capture's baked transform the only one that lands.
	proxy.appearance_flags |= KEEP_APART | RESET_TRANSFORM
	proxy.vis_flags |= (VIS_INHERIT_ID|VIS_INHERIT_LAYER)
	proxy.render_source = render_id

	var/mob/wearer = parent
	SET_PLANE_EXPLICIT(proxy, CAMERA_CAMO_PLANE, wearer)

	initial_render_target = wearer.render_target
	wearer.render_target = render_id
	wearer.vis_contents += proxy

	blanker = image(loc = proxy)
	blanker.override = TRUE
	GLOB.digitalcamo_images |= blanker

	// Hide the wearer's data-HUD markers on basic monitors too (route them onto the camo plane).
	apply_hud_plane(wearer, CAMERA_CAMO_PLANE)

	// Keep the proxy (and HUD markers) on the correct (z-offset) camo plane as the wearer changes z-levels.
	RegisterSignal(wearer, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_z_changed))

/datum/component/camera_camo/Destroy(force)
	var/atom/movable/wearer = parent
	if(!QDELETED(wearer))
		UnregisterSignal(wearer, COMSIG_MOVABLE_Z_CHANGED)
		wearer.render_target = initial_render_target
		wearer.vis_contents -= proxy
		// Drop the HUD markers back onto the wearer's own plane so they show on monitors again.
		apply_hud_plane(wearer, FLOAT_PLANE)

	GLOB.digitalcamo_images -= blanker
	// Pull the proxy-blanker off anyone still holding it (AIs / advanced-console watchers), so the proxy
	// (and therefore the wearer) renders for them again at once.
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		ai.client?.images -= blanker
	for(var/mob/watcher as anything in GLOB.camera_console_watchers)
		watcher.client?.images -= blanker
	blanker = null

	QDEL_NULL(proxy)
	return ..()

/datum/component/camera_camo/proc/on_z_changed(atom/movable/source)
	SIGNAL_HANDLER
	SET_PLANE_EXPLICIT(proxy, CAMERA_CAMO_PLANE, source)
	apply_hud_plane(source, CAMERA_CAMO_PLANE)

/// Moves the wearer's medical/security HUD-marker images onto the given plane. CAMERA_CAMO_PLANE hides them on
/// basic camera monitors (popup-hidden) while keeping them in person; FLOAT_PLANE puts them back on the mob.
/datum/component/camera_camo/proc/apply_hud_plane(mob/wearer, target_plane)
	if(!islist(wearer.hud_list))
		return
	for(var/hud_category in GLOB.camera_camo_hidden_huds)
		var/image/hud_image = wearer.hud_list[hud_category]
		if(!istype(hud_image))
			continue
		if(target_plane == FLOAT_PLANE)
			hud_image.plane = FLOAT_PLANE
		else
			SET_PLANE_EXPLICIT(hud_image, target_plane, wearer)
