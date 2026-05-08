/*
IconProcs README

A BYOND library for manipulating icons and colors

by Lummox JR

version 1.0

The IconProcs library was made to make a lot of common icon operations much easier. BYOND's icon manipulation
routines are very capable but some of the advanced capabilities like using alpha transparency can be unintuitive to beginners.

CHANGING ICONS

Several new procs have been added to the /icon datum to simplify working with icons. To use them,
remember you first need to setup an /icon var like so:

GLOBAL_DATUM_INIT(my_icon, /icon, new('iconfile.dmi'))

icon/ChangeOpacity(amount = 1)
	A very common operation in DM is to try to make an icon more or less transparent. Making an icon more
	transparent is usually much easier than making it less so, however. This proc basically is a frontend
	for MapColors() which can change opacity any way you like, in much the same way that SetIntensity()
	can make an icon lighter or darker. If amount is 0.5, the opacity of the icon will be cut in half.
	If amount is 2, opacity is doubled and anything more than half-opaque will become fully opaque.
icon/GrayScale()
	Converts the icon to grayscale instead of a fully colored icon. Alpha values are left intact.
icon/ColorTone(tone)
	Similar to GrayScale(), this proc converts the icon to a range of black -> tone -> white, where tone is an
	RGB color (its alpha is ignored). This can be used to create a sepia tone or similar effect.
	See also the global ColorTone() proc.
icon/MinColors(icon)
	The icon is blended with a second icon where the minimum of each RGB pixel is the result.
	Transparency may increase, as if the icons were blended with ICON_ADD. You may supply a color in place of an icon.
icon/MaxColors(icon)
	The icon is blended with a second icon where the maximum of each RGB pixel is the result.
	Opacity may increase, as if the icons were blended with ICON_OR. You may supply a color in place of an icon.
icon/Opaque(background = COLOR_BLACK)
	All alpha values are set to 255 throughout the icon. Transparent pixels become black, or whatever background color you specify.
icon/BecomeAlphaMask()
	You can convert a simple grayscale icon into an alpha mask to use with other icons very easily with this proc.
	The black parts become transparent, the white parts stay white, and anything in between becomes a translucent shade of white.
icon/AddAlphaMask(mask)
	The alpha values of the mask icon will be blended with the current icon. Anywhere the mask is opaque,
	the current icon is untouched. Anywhere the mask is transparent, the current icon becomes transparent.
	Where the mask is translucent, the current icon becomes more transparent.
icon/UseAlphaMask(mask, mode)
	Sometimes you may want to take the alpha values from one icon and use them on a different icon.
	This proc will do that. Just supply the icon whose alpha mask you want to use, and src will change
	so it has the same colors as before but uses the mask for opacity.

COLOR MANAGEMENT AND HSV

RGB isn't the only way to represent color. Sometimes it's more useful to work with a model called HSV, which stands for hue, saturation, and value.

	* The hue of a color describes where it is along the color wheel. It goes from red to yellow to green to
	cyan to blue to magenta and back to red.
	* The saturation of a color is how much color is in it. A color with low saturation will be more gray,
	and with no saturation at all it is a shade of gray.
	* The value of a color determines how bright it is. A high-value color is vivid, moderate value is dark,
	and no value at all is black.

While rgb is typically stored in the #rrggbb" format (with optional "aa" on the end), HSV never needs to be displayed.
Most procs that work in HSV "space" will simply accept RGB inputs and convert them in place using rgb2num(color, space = COLORSPACE_HSV).

That said, if you want to manually modify these values rgb2hsv() will hand you back a list in the format list(hue, saturation, value, alpha).
Converting back is simple, just a hsv2rgb(hsv) call

Hue ranges from 0 to 360 (it's in degrees of a color wheel)
Saturation ranges from 0 to 100
Value ranges from 0 to 100

Knowing this, you can figure out that red is list(0, 100, 100) in HSV format, which is hue 0 (red), saturation 100 (as colorful as possible),
value 255 (as bright as possible). Green is list(120, 100, 100) and blue is list(240, 100, 100).

It is worth noting that while we do not have helpers for them currently, these same ideas apply to all of byond's color spaces
HSV (hue saturation value), HSL (hue satriation luminosity) and HCY (hue chroma luminosity)

Here are some procs you can use for color management:

BlendRGB(rgb1, rgb2, amount)
	Blends between two RGB or RGBA colors using regular RGB blending. If amount is 0, the first color is the result;
	if 1, the second color is the result. 0.5 produces an average of the two. Values outside the 0 to 1 range are allowed as well.
	Returns an RGB or RGBA string
BlendHSV(rgb1, rgb2, amount)
	Blends between two RGB or RGBA colors using HSV blending, which tends to produce nicer results than regular RGB
	blending because the brightness of the color is left intact. If amount is 0, the first color is the result; if 1,
	the second color is the result. 0.5 produces an average of the two. Values outside the 0 to 1 range are allowed as well.
	Returns an RGB or RGBA string
HueToAngle(hue)
	Converts a hue to an angle range of 0 to 360. Angle 0 is red, 120 is green, and 240 is blue.
AngleToHue(hue)
	Converts an angle to a hue in the valid range.
RotateHue(rgb, angle)
	Takes an RGB or RGBA value and rotates the hue forward through red, green, and blue by an angle from 0 to 360.
	(Rotating red by 60° produces yellow.)
	Returns an RGB or RGBA string
GrayScale(rgb)
	Takes an RGB or RGBA color and converts it to grayscale. Returns an RGB or RGBA string.
ColorTone(rgb, tone)
	Similar to GrayScale(), this proc converts an RGB or RGBA color to a range of black -> tone -> white instead of
	using strict shades of gray. The tone value is an RGB color; any alpha value is ignored.
*/

/*
Get Flat Icon DEMO by DarkCampainger

This is a test for the get flat icon proc, modified approprietly for icons and their states.
Probably not a good idea to run this unless you want to see how the proc works in detail.
mob
	icon = 'old_or_unused.dmi'
	icon_state = "green"

	Login()
		// Testing image underlays
		underlays += image(icon='old_or_unused.dmi',icon_state="red")
		underlays += image(icon='old_or_unused.dmi',icon_state="red", pixel_x = 32)
		underlays += image(icon='old_or_unused.dmi',icon_state="red", pixel_x = -32)

		// Testing image overlays
		add_overlay(image(icon='old_or_unused.dmi',icon_state="green", pixel_x = 32, pixel_y = -32))
		add_overlay(image(icon='old_or_unused.dmi',icon_state="green", pixel_x = 32, pixel_y = 32))
		add_overlay(image(icon='old_or_unused.dmi',icon_state="green", pixel_x = -32, pixel_y = -32))

		// Testing icon file overlays (defaults to mob's state)
		add_overlay('_flat_demoIcons2.dmi')

		// Testing icon_state overlays (defaults to mob's icon)
		add_overlay("white")

		// Testing dynamic icon overlays
		var/icon/I = icon('old_or_unused.dmi', icon_state="aqua")
		I.Shift(NORTH,16,1)
		add_overlay(I)

		// Testing dynamic image overlays
		I=image(icon=I,pixel_x = -32, pixel_y = 32)
		add_overlay(I)

		// Testing object types (and layers)
		add_overlay(/obj/effect/overlay_test)

		loc = locate (10,10,1)
	verb
		Browse_Icon()
			set name = "1. Browse Icon"
			// Give it a name for the cache
			var/iconName = "[ckey(src.name)]_flattened.dmi"
			// Send the icon to src's local cache
			src<<browse_rsc(getFlatIcon(src), iconName)
			// Display the icon in their browser
			src<<browse("<body bgcolor='#000000'><p><img src='[iconName]'></p></body>")

		Output_Icon()
			set name = "2. Output Icon"
			to_chat(src, "Icon is: [icon2base64html(getFlatIcon(src))]")

		Label_Icon()
			set name = "3. Label Icon"
			// Give it a name for the cache
			var/iconName = "[ckey(src.name)]_flattened.dmi"
			// Copy the file to the rsc manually
			var/icon/I = fcopy_rsc(getFlatIcon(src))
			// Send the icon to src's local cache
			src<<browse_rsc(I, iconName)
			// Update the label to show it
			winset(src,"imageLabel","image='[REF(I)]'");

		Add_Overlay()
			set name = "4. Add Overlay"
			add_overlay(image(icon='old_or_unused.dmi',icon_state="yellow",pixel_x = rand(-64,32), pixel_y = rand(-64,32))

		Stress_Test()
			set name = "5. Stress Test"
			for(var/i = 0 to 1000)
				// The third parameter forces it to generate a new one, even if it's already cached
				getFlatIcon(src,0,2)
				if(prob(5))
					Add_Overlay()
			Browse_Icon()

		Cache_Test()
			set name = "6. Cache Test"
			for(var/i = 0 to 1000)
				getFlatIcon(src)
			Browse_Icon()

/obj/effect/overlay_test
	icon = 'old_or_unused.dmi'
	icon_state = "blue"
	pixel_x = -24
	pixel_y = 24
	layer = TURF_LAYER // Should appear below the rest of the overlays

world
	view = "7x7"
	maxx = 20
	maxy = 20
	maxz = 1
*/

#define TO_HEX_DIGIT(n) ascii2text((n&15) + ((n&15)<10 ? 48 : 87))

/// Multiply all alpha values by this float
/icon/proc/ChangeOpacity(opacity = 1)
	MapColors(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,opacity, 0,0,0,0)

/// Convert to grayscale
/icon/proc/GrayScale()
	MapColors(0.3,0.3,0.3, 0.59,0.59,0.59, 0.11,0.11,0.11, 0,0,0)

/icon/proc/ColorTone(tone)
	GrayScale()

	var/list/TONE = rgb2num(tone)
	var/gray = round(TONE[1]*0.3 + TONE[2]*0.59 + TONE[3]*0.11, 1)

	var/icon/upper = (255-gray) ? new(src) : null

	if(gray)
		MapColors(255/gray,0,0, 0,255/gray,0, 0,0,255/gray, 0,0,0)
		Blend(tone, ICON_MULTIPLY)
	else SetIntensity(0)
	if(255-gray)
		upper.Blend(rgb(gray,gray,gray), ICON_SUBTRACT)
		upper.MapColors((255-TONE[1])/(255-gray),0,0,0, 0,(255-TONE[2])/(255-gray),0,0, 0,0,(255-TONE[3])/(255-gray),0, 0,0,0,0, 0,0,0,1)
		Blend(upper, ICON_ADD)

/// Take the minimum color of two icons; combine transparency as if blending with ICON_ADD
/icon/proc/MinColors(icon)
	var/icon/new_icon = new(src)
	new_icon.Opaque()
	new_icon.Blend(icon, ICON_SUBTRACT)
	Blend(new_icon, ICON_SUBTRACT)

/// Take the maximum color of two icons; combine opacity as if blending with ICON_OR
/icon/proc/MaxColors(icon)
	var/icon/new_icon
	if(isicon(icon))
		new_icon = new(icon)
	else
		// solid color
		new_icon = new(src)
		new_icon.Blend(COLOR_BLACK, ICON_OVERLAY)
		new_icon.SwapColor(COLOR_BLACK, null)
		new_icon.Blend(icon, ICON_OVERLAY)
	var/icon/blend_icon = new(src)
	blend_icon.Opaque()
	new_icon.Blend(blend_icon, ICON_SUBTRACT)
	Blend(new_icon, ICON_OR)

/// make this icon fully opaque--transparent pixels become black
/icon/proc/Opaque(background = COLOR_BLACK)
	SwapColor(null, background)
	MapColors(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,0, 0,0,0,1)

/// Change a grayscale icon into a white icon where the original color becomes the alpha
/// I.e., black -> transparent, gray -> translucent white, white -> solid white
/icon/proc/BecomeAlphaMask()
	SwapColor(null, "#000000ff") // don't let transparent become gray
	MapColors(0,0,0,0.3, 0,0,0,0.59, 0,0,0,0.11, 0,0,0,0, 1,1,1,0)

/icon/proc/UseAlphaMask(mask)
	Opaque()
	AddAlphaMask(mask)

/icon/proc/AddAlphaMask(mask)
	var/icon/mask_icon = new(mask)
	mask_icon.Blend("#ffffff", ICON_SUBTRACT)
	// apply mask
	Blend(mask_icon, ICON_ADD)

/// Converts an rgb color into a list storing hsva
/// Exists because it's useful to have a guaranteed alpha value
/proc/rgb2hsv(rgb)
	var/list/hsv = rgb2num(rgb, COLORSPACE_HSV)
	if(length(hsv) < 4)
		hsv += 255 // Max alpha, just to make life easy
	return hsv

/// Converts a list storing hsva into an rgb color
/proc/hsv2rgb(hsv)
	if(length(hsv) < 3)
		return COLOR_BLACK
	if(length(hsv) == 3)
		return rgb(hsv[1], hsv[2], hsv[3], space = COLORSPACE_HSV)
	return rgb(hsv[1], hsv[2], hsv[3], hsv[4], space = COLORSPACE_HSV)

/**
 * Smooth blend between RGB colors interpreted as HSV
 *
 * amount=0 is the first color
 * amount=1 is the second color
 * amount=0.5 is directly between the two colors
 *
 * amount<0 or amount>1 are allowed
 */
/proc/BlendHSV(hsv1, hsv2, amount)
	return hsv_gradient(amount, 0, hsv1, 1, hsv2, "loop")

/**
 * Smooth blend between RGB colors
 *
 * amount=0 is the first color
 * amount=1 is the second color
 * amount=0.5 is directly between the two colors
 *
 * amount<0 or amount>1 are allowed
 */
/proc/BlendRGB(rgb1, rgb2, amount)
	return rgb_gradient(amount, 0, rgb1, 1, rgb2, "loop")

/proc/HueToAngle(hue)
	// normalize hsv in case anything is screwy
	if(hue < 0 || hue >= 1536)
		hue %= 1536
	if(hue < 0)
		hue += 1536
	// Compress hue into easier-to-manage range
	hue -= hue >> 8
	return hue / (1530/360)

/proc/AngleToHue(angle)
	// normalize hsv in case anything is screwy
	if(angle < 0 || angle >= 360)
		angle -= 360 * round(angle / 360)
	var/hue = angle * (1530/360)
	// Decompress hue
	hue += round(hue / 255)
	return hue

/// Positive angle rotates forward through red->green->blue
/proc/RotateHue(rgb, angle)
	var/list/HSV = rgb2hsv(rgb)
	angle %= 360
	HSV[1] = round(HSV[1] + angle)
	HSV[1] %= 360
	if(HSV[1] < 0)
		HSV[1] += 360
	return hsv2rgb(HSV)

/// Convert an rgb color to grayscale
/proc/GrayScale(rgb)
	var/list/RGB = rgb2num(rgb)
	var/gray = RGB[1]*0.3 + RGB[2]*0.59 + RGB[3]*0.11
	return (length(RGB) > 3) ? rgb(gray, gray, gray, RGB[4]) : rgb(gray, gray, gray)

/// Change grayscale color to black->tone->white range
/proc/ColorTone(rgb, tone)
	var/list/RGB = rgb2num(rgb)
	var/list/TONE = rgb2num(tone)

	var/gray = RGB[1]*0.3 + RGB[2]*0.59 + RGB[3]*0.11
	var/tone_gray = TONE[1]*0.3 + TONE[2]*0.59 + TONE[3]*0.11

	if(gray <= tone_gray)
		return BlendRGB(COLOR_BLACK, tone, gray/(tone_gray || 1))
	else
		return BlendRGB(tone, "#ffffff", (gray-tone_gray)/((255-tone_gray) || 1))

/// Create a single [/icon] from a given [/atom] or [/image].
///
/// Very low-performance. Should usually only be used for HTML, where BYOND's
/// appearance system (overlays/underlays, etc.) is not available.
///
/// Only the first argument is required.
///
/proc/getFlatIcon(image/appearance, defdir, deficon, defstate, defblend, start = TRUE, no_anim = TRUE)
	// Loop through the underlays, then overlays, sorting them into the layers list
	#define PROCESS_OVERLAYS_OR_UNDERLAYS(flat, process, base_layer) \
		for(var/i in 1 to length(process)) { \
			var/image/current = process[i]; \
			if(!current) { \
				continue; \
			} \
			if(current.plane != FLOAT_PLANE && current.plane != appearance.plane) { \
				continue; \
			} \
			var/current_layer = current.layer; \
			if(current_layer < 0) { \
				if(current_layer <= -1000) { \
					return flat; \
				} \
				current_layer = base_layer + appearance.layer + current_layer / 1000; \
			} \
			for(var/index_to_compare_to in 1 to length(layers)) { \
				var/compare_to = layers[index_to_compare_to]; \
				if(current_layer < layers[compare_to]) { \
					layers.Insert(index_to_compare_to, current); \
					break; \
				} \
			} \
			layers[current] = current_layer; \
		}

	var/static/icon/flat_template = icon('icons/blanks/32x32.dmi', "nothing")

	if(!appearance || appearance.alpha <= 0)
		return icon(flat_template)

	if(start)
		if(!defdir)
			defdir = appearance.dir
		if(!deficon)
			deficon = appearance.icon
		if(!defstate)
			defstate = appearance.icon_state
		if(!defblend)
			defblend = appearance.blend_mode

	var/curicon = appearance.icon || deficon
	var/curstate = appearance.icon_state || defstate
	var/curdir = (!appearance.dir || appearance.dir == SOUTH) ? defdir : appearance.dir

	var/render_icon = curicon

	if(render_icon)
		var/curstates = icon_states_fast(curicon)
		if(!(icon_exists(curicon, curstate)))
			if("" in curstates)
				curstate = ""
			else
				render_icon = FALSE

	var/base_icon_dir //We'll use this to get the icon state to display if not null BUT NOT pass it to overlays as the dir we have

	//Try to remove/optimize this section ASAP, CPU hog.
	//Determines if there's directionals.
	if(render_icon && curdir != SOUTH)
		if(
			!length(icon_states_fast(icon(curicon, curstate, NORTH))) \
			&& !length(icon_states_fast(icon(curicon, curstate, EAST))) \
			&& !length(icon_states_fast(icon(curicon, curstate, WEST))) \
		)
			base_icon_dir = SOUTH

	if(!base_icon_dir)
		base_icon_dir = curdir

	var/curblend = appearance.blend_mode || defblend

	if(length(appearance.overlays) || length(appearance.underlays))
		var/icon/flat = icon(flat_template)
		// Layers will be a sorted list of icons/overlays, based on the order in which they are displayed
		var/list/layers = list()
		var/image/copy
		// Add the atom's icon itself, without pixel_x/y offsets.
		if(render_icon)
			copy = image(icon=curicon, icon_state=curstate, layer=appearance.layer, dir=base_icon_dir)
			copy.color = appearance.color
			copy.alpha = appearance.alpha
			copy.blend_mode = curblend
			layers[copy] = appearance.layer

		PROCESS_OVERLAYS_OR_UNDERLAYS(flat, appearance.underlays, 0)
		PROCESS_OVERLAYS_OR_UNDERLAYS(flat, appearance.overlays, 1)

		var/icon/add // Icon of overlay being added

		var/flatX1 = 1
		var/flatX2 = flat.Width()
		var/flatY1 = 1
		var/flatY2 = flat.Height()

		var/addX1 = 0
		var/addX2 = 0
		var/addY1 = 0
		var/addY2 = 0

		for(var/image/layer_image as anything in layers)
			if(layer_image.alpha == 0)
				continue

			if(layer_image == copy) // 'layer_image' is an /image based on the object being flattened.
				curblend = BLEND_OVERLAY
				add = icon(layer_image.icon, layer_image.icon_state, base_icon_dir)
			else // 'I' is an appearance object.
				add = getFlatIcon(image(layer_image), curdir, curicon, curstate, curblend, FALSE, no_anim)
			if(!add)
				continue

			// Find the new dimensions of the flat icon to fit the added overlay
			addX1 = min(flatX1, layer_image.pixel_x + layer_image.pixel_w + 1)
			addX2 = max(flatX2, layer_image.pixel_x + layer_image.pixel_w + add.Width())
			addY1 = min(flatY1, layer_image.pixel_y + layer_image.pixel_z + 1)
			addY2 = max(flatY2, layer_image.pixel_y + layer_image.pixel_z + add.Height())

			if(
				addX1 != flatX1 \
				&& addX2 != flatX2 \
				&& addY1 != flatY1 \
				&& addY2 != flatY2 \
			)
				// Resize the flattened icon so the new icon fits
				flat.Crop(
					addX1 - flatX1 + 1,
					addY1 - flatY1 + 1,
					addX2 - flatX1 + 1,
					addY2 - flatY1 + 1
				)

				flatX1 = addX1
				flatX2 = addY1
				flatY1 = addX2
				flatY2 = addY2

			// Blend the overlay into the flattened icon
			flat.Blend(add, blendMode2iconMode(curblend), layer_image.pixel_x + layer_image.pixel_w + 2 - flatX1, layer_image.pixel_y + layer_image.pixel_z + 2 - flatY1)

		if(appearance.color)
			if(islist(appearance.color))
				flat.MapColors(arglist(appearance.color))
			else
				flat.Blend(appearance.color, ICON_MULTIPLY)

		if(appearance.alpha < 255)
			flat.Blend(rgb(255, 255, 255, appearance.alpha), ICON_MULTIPLY)

		if(no_anim)
			//Clean up repeated frames
			var/icon/cleaned = new /icon()
			cleaned.Insert(flat, "", SOUTH, 1, 0)
			return cleaned
		else
			return icon(flat, "", SOUTH)
	else if(render_icon) // There's no overlays.
		var/icon/final_icon = icon(icon(curicon, curstate, base_icon_dir), "", SOUTH, no_anim ? TRUE : null)

		if(appearance.alpha < 255)
			final_icon.Blend(rgb(255,255,255, appearance.alpha), ICON_MULTIPLY)

		if(appearance.color)
			if(islist(appearance.color))
				final_icon.MapColors(arglist(appearance.color))
			else
				final_icon.Blend(appearance.color, ICON_MULTIPLY)

		return final_icon

	#undef PROCESS_OVERLAYS_OR_UNDERLAYS

/proc/getIconMask(atom/atom_to_mask)//By yours truly. Creates a dynamic mask for a mob/whatever. /N
	var/icon/alpha_mask = new(atom_to_mask.icon, atom_to_mask.icon_state)//So we want the default icon and icon state of atom_to_mask.
	for(var/iterated_image in atom_to_mask.overlays)//For every image in overlays. var/image/image will not work, don't try it.
		var/image/image = iterated_image
		if(image.layer > atom_to_mask.layer)
			continue//If layer is greater than what we need, skip it.
		var/icon/image_overlay = new(image.icon, image.icon_state)//Blend only works with icon objects.
		//Also, icons cannot directly set icon_state. Slower than changing variables but whatever.
		alpha_mask.Blend(image_overlay, ICON_OR)//OR so they are lumped together in a nice overlay.
	return alpha_mask//And now return the mask.

/**
 * Helper proc to generate a cutout alpha mask out of an icon.
 *
 * Why is it a helper if it's so simple?
 *
 * Because BYOND's documentation is hot garbage and I don't trust anyone to actually
 * figure this out on their own without sinking countless hours into it. Yes, it's that
 * simple, now enjoy.
 *
 * But why not use filters?
 *
 * Filters do not allow for masks that are not the exact same on every dir. An example of a
 * need for that can be found in [/proc/generate_left_leg_mask()].
 *
 * Arguments:
 * * icon_to_mask - The icon file you want to generate an alpha mask out of.
 * * icon_state_to_mask - The specific icon_state you want to generate an alpha mask out of.
 *
 * Returns an `/icon` that is the alpha mask of the provided icon and icon_state.
 */
/proc/generate_icon_alpha_mask(icon_to_mask, icon_state_to_mask)
	var/icon/mask_icon = icon(icon_to_mask, icon_state_to_mask)
	// I hate the MapColors documentation, so I'll explain what happens here.
	// Basically, what we do here is that we invert the mask by using none of the original
	// colors, and then the fourth group of number arguments is actually the alpha values of
	// each of the original colors, which we multiply by 255 and subtract a value of 255 to the
	// result for the matching pixels, while starting with a base color of white everywhere.
	mask_icon.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 255,255,255,-255, 1,1,1,1)
	return mask_icon

/proc/getHologramIcon(icon/holo_icon, safety = TRUE, opacity = 0.5)//If safety is on, a new icon is not created.
	var/icon/flat_icon = safety ? holo_icon : new(holo_icon)//Has to be a new icon to not constantly change the same icon.
	var/icon/alpha_mask
	flat_icon.ColorTone(rgb(125,180,225))//Let's make it bluish.
	flat_icon.ChangeOpacity(opacity)//Make it half transparent.
	if(holo_icon.Height() == 64)
		alpha_mask = new('icons/mob/ancient_machine.dmi', "scanline2")//Scaline for tall icons.
	else
		alpha_mask = new('icons/effects/effects.dmi', "scanline")//Scanline effect.
	flat_icon.AddAlphaMask(alpha_mask)//Finally, let's mix in a distortion effect.
	return flat_icon

/proc/adjust_brightness(color, value)
	if(!color)
		return "#FFFFFF"
	if(!value)
		return color

	var/list/RGB = rgb2num(color)
	RGB[1] = clamp(RGB[1] + value, 0, 255)
	RGB[2] = clamp(RGB[2] + value, 0, 255)
	RGB[3] = clamp(RGB[3] + value, 0, 255)
	return rgb(RGB[1], RGB[2], RGB[3])

// Hook, override to run code on- wait this is images
// Images have dir without being an atom, so they get their own definition.
// Lame.
/image/proc/setDir(newdir)
	dir = newdir

/proc/rand_hex_color()
	var/list/colors = list("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f")
	var/color= ""
	for(var/i in 1 to 6)
		color = color + pick(colors)
	return "#[color]"

/// Imagine removing pixels from the main icon that are covered by pixels from the mask icon.
/// Standard behaviour is to cut pixels from the main icon that are covered by pixels from the mask icon unless passed mask_ready, see below.
/proc/get_icon_difference(icon/main, icon/mask, mask_ready)
	/*You should skip prep if the mask is already sprited properly. This significantly improves performance by eliminating most of the realtime icon work.
	e.g. A 'ready' mask is a mask where the part you want cut out is missing (no pixels, 0 alpha) from the sprite, and everything else is solid white.*/

	if(istype(main) && istype(mask))
		if(!mask_ready) //Prep the mask if we're using a regular old sprite and not a special-made mask.
			mask.Blend(rgb(255,255,255), ICON_SUBTRACT) //Make all pixels on the mask as black as possible.
			mask.Opaque(rgb(255,255,255)) //Make the transparent pixels (background) white.
			mask.BecomeAlphaMask() //Make all the black pixels vanish (fully transparent), leaving only the white background pixels.

		main.AddAlphaMask(mask) //Make the pixels in the main icon that are in the transparent zone of the mask icon also vanish (fully transparent).
		return main

/// Returns a list containing the width and height of an icon file
/proc/get_icon_dimensions(icon_path)
	if(istype(icon_path, /datum/universal_icon))
		var/datum/universal_icon/u_icon = icon_path
		icon_path = u_icon.icon_file
	// Icons can be a real file(), a rsc backed file(), a dynamic rsc (dyn.rsc) reference (known as a cache reference in byond docs), or an /icon which is pointing to one of those.
	// Runtime generated dynamic icons are an unbounded concept cache identity wise, the same icon can exist millions of ways and holding them in a list as a key can lead to unbounded memory usage if called often by consumers.
	// Check distinctly that this is something that has this unspecified concept, and thus that we should not cache.
	if(!istext(icon_path) && (!isfile(icon_path) || !length("[icon_path]")))
		var/icon/my_icon = icon(icon_path)
		return list("width" = my_icon.Width(), "height" = my_icon.Height())
	if(isnull(GLOB.icon_dimensions[icon_path]))
		// Used cached icon metadata
		var/list/metadata = icon_metadata(icon_path)
		var/list/result = null
		if(islist(metadata) && isnum(metadata["width"]) && isnum(metadata["height"]))
			result = list("width" = metadata["width"], "height" = metadata["height"])
		// Otherwise, we have to use the slower BYOND proc
		else
			var/icon/my_icon = icon(icon_path)
			result = list("width" = my_icon.Width(), "height" = my_icon.Height())
		GLOB.icon_dimensions[icon_path] = result

	return GLOB.icon_dimensions[icon_path]

/// Returns a list containing the width and height of an icon file, without using rustg for pure function calls
/proc/get_icon_dimensions_pure(icon_path)
	// Icons can be a real file(), a rsc backed file(), a dynamic rsc (dyn.rsc) reference (known as a cache reference in byond docs), or an /icon which is pointing to one of those.
	// Runtime generated dynamic icons are an unbounded concept cache identity wise, the same icon can exist millions of ways and holding them in a list as a key can lead to unbounded memory usage if called often by consumers.
	// Check distinctly that this is something that has this unspecified concept, and thus that we should not cache.
	if(!isfile(icon_path) || !length("[icon_path]"))
		var/icon/my_icon = icon(icon_path)
		return list("width" = my_icon.Width(), "height" = my_icon.Height())
	if(isnull(GLOB.icon_dimensions[icon_path]))
		var/icon/my_icon = icon(icon_path)
		GLOB.icon_dimensions[icon_path] = list("width" = my_icon.Width(), "height" = my_icon.Height())
	return GLOB.icon_dimensions[icon_path]

///Flickers an overlay on an atom
/atom/proc/flick_overlay_static(overlay_image, duration)
	set waitfor = FALSE
	if(!overlay_image)
		return
	add_overlay(overlay_image)
	sleep(duration)
	cut_overlay(overlay_image)

GLOBAL_LIST_EMPTY(bicon_cache)

/// Generates a filename for a given asset.
/// Like generate_asset_name(), except returns the rsc reference and the rsc file hash as well as the asset name (sans extension)
/// Used so that certain asset files dont have to be hashed twice
/proc/generate_and_hash_rsc_file(file, dmi_file_path)
	var/rsc_ref = fcopy_rsc(file)
	var/hash
	// If we have a valid dmi file path we can trust md5'ing the rsc file because we know it doesnt have the bug described in http://www.byond.com/forum/post/2611357
	if(dmi_file_path)
		hash = md5(rsc_ref)
	else // Otherwise, we need to do the expensive fcopy() workaround
		hash = md5asfile(rsc_ref)

	return list(rsc_ref, hash, "asset.[hash]")

/// Gets a dummy savefile for usage in icon generation.
/// Savefiles generated from this proc will be empty.
/proc/get_dummy_savefile(from_failure = FALSE)
	var/static/next_id = 0
	if(next_id++ > 9)
		next_id = 0
	var/savefile_path = "tmp/dummy-save-[next_id].sav"
	try
		if(fexists(savefile_path))
			fdel(savefile_path)
		return new /savefile(savefile_path)
	catch(var/exception/error)
		// if we failed to create a dummy once, try again; maybe someone slept somewhere they shouldnt have
		if(from_failure) // this *is* the retry, something fucked up
			CRASH("get_dummy_savefile failed to create a dummy savefile: '[error]'")
		return get_dummy_savefile(from_failure = TRUE)

/**
 * Converts an icon to base64. Operates by putting the icon in the iconCache savefile,
 * exporting it as text, and then parsing the base64 from that.
 * (This relies on byond automatically storing icons in savefiles as base64)
 */
/proc/icon2base64(icon/icon)
	if(!isicon(icon))
		return FALSE
	var/savefile/dummySave = get_dummy_savefile()
	WRITE_FILE(dummySave["dummy"], icon)
	var/iconData = dummySave.ExportText("dummy")
	var/list/partial = splittext(iconData, "{")
	return replacetext(copytext_char(partial[2], 3, -5), "\n", "")

/proc/icon2base64html(obj, use_class = TRUE)
	var/class = use_class ? "class='icon misc'" : null
	if(!obj)
		return

	if(isicon(obj))
		if(!GLOB.bicon_cache["\ref[obj]"]) // Doesn't exist yet, make it.
			GLOB.bicon_cache["\ref[obj]"] = icon2base64(obj)
		return "<img [class] src='data:image/png;base64,[GLOB.bicon_cache["\ref[obj]"]]'>"

	// Either an atom or somebody fucked up and is gonna get a runtime, which I'm fine with.
	var/atom/A = obj
	var/key = "[isicon(A.icon) ? "\ref[A.icon]" : A.icon]:[A.icon_state]"
	if(!GLOB.bicon_cache[key]) // Doesn't exist, make it.
		var/icon/I = icon(A.icon, A.icon_state, SOUTH, 1)
		if(ishuman(obj)) // Shitty workaround for a BYOND issue.
			var/icon/temp = I
			I = icon()
			I.Insert(temp, dir = SOUTH)
		GLOB.bicon_cache[key] = icon2base64(I)

	if(use_class)
		class = "class='icon [A.icon_state]'"

	return "<img [class] src='data:image/png;base64,[GLOB.bicon_cache[key]]'>"


/// Returns rustg-parsed metadata for an icon, universal icon, or DMI file, using cached values where possible
/// Returns null if passed object is not a filepath or icon with a valid DMI file
/proc/icon_metadata(file)
	var/static/list/icon_metadata_cache = list()
	if(istype(file, /datum/universal_icon))
		var/datum/universal_icon/u_icon = file
		file = u_icon.icon_file
	var/file_string = "[file]"
	if(!istext(file) && !(isfile(file) && length(file_string)))
		return null
	var/list/cached_metadata = icon_metadata_cache[file_string]
	if(islist(cached_metadata))
		return cached_metadata
	var/list/metadata_result = rustlib_dmi_read_metadata(file_string)
	if(!islist(metadata_result) || !length(metadata_result))
		CRASH("Error while reading DMI metadata for path '[file_string]': [metadata_result]")
	else
		icon_metadata_cache[file_string] = metadata_result
		return metadata_result

/// Checks whether a given icon state exists in a given icon file. If `file` and `state` both exist,
/// this will return `TRUE` - otherwise, it will return `FALSE`.
///
/// If you want a stack trace to be output when the given state/file doesn't exist, use
/// `/proc/icon_exists_or_scream()`.
/proc/icon_exists(file, state)
	if(isnull(file) || isnull(state))
		return FALSE //This is common enough that it shouldn't panic, imo.

	if(isnull(GLOB.icon_states_cache_lookup[file]))
		compile_icon_states_cache(file)
	return !isnull(GLOB.icon_states_cache_lookup[file][state])

/// Cached, rustg-based alternative to icon_states()
/proc/icon_states_fast(file)
	if(isnull(file))
		return null
	if(isnull(GLOB.icon_states_cache[file]))
		compile_icon_states_cache(file)
	return GLOB.icon_states_cache[file]

/proc/compile_icon_states_cache(file)
	GLOB.icon_states_cache[file] = list()
	GLOB.icon_states_cache_lookup[file] = list()
	// Try to use rustg first
	var/list/metadata = icon_metadata(file)
	if(islist(metadata) && islist(metadata["states"]))
		for(var/list/state_data as anything in metadata["states"])
			GLOB.icon_states_cache[file] += state_data["name"]
			GLOB.icon_states_cache_lookup[file][state_data["name"]] = TRUE
	else // Otherwise, we have to use the slower BYOND proc
		for(var/istate in icon_states(file))
			GLOB.icon_states_cache[file] += istate
			GLOB.icon_states_cache_lookup[file][istate] = TRUE

/// Functions the same as `/proc/icon_exists()`, but with the addition of a stack trace if the
/// specified file or state doesn't exist.
///
/// Stack traces will only be output once for each file.
/proc/icon_exists_or_scream(file, state)
	if(icon_exists(file, state))
		return TRUE

	var/static/list/screams = list()
	if(!isnull(screams[file]))
		screams[file] = TRUE
		stack_trace("State [state] in file [file] does not exist.")

	return FALSE

///given a text string, returns whether it is a valid dmi icons folder path
/proc/is_valid_dmi_file(icon_path)
	if(!istext(icon_path) || !length(icon_path))
		return FALSE

	var/is_in_icon_folder = findtextEx(icon_path, "icons/")
	var/is_dmi_file = findtextEx(icon_path, ".dmi")

	if(is_in_icon_folder && is_dmi_file)
		return TRUE
	return FALSE

/// Given an icon object, dmi file path, or atom/image/mutable_appearance, attempts to find and return an associated dmi file path.
/// A weird quirk about dm is that /icon objects represent both compile-time or dynamic icons in the rsc,
/// But stringifying rsc references returns a dmi file path
/// ONLY if that icon represents a completely unchanged dmi file from when the game was compiled.
/// So if the given object is associated with an icon that was in the rsc when the game was compiled, this returns a path. otherwise it returns ""
/proc/get_icon_dmi_path(icon/icon)
	/// The dmi file path we attempt to return if the given object argument is associated with a stringifiable icon
	/// If successful, this looks like "icons/path/to/dmi_file.dmi"
	var/icon_path = ""

	if(isatom(icon) || isimage(icon) || istype(icon, /mutable_appearance))
		var/atom/atom_icon = icon
		icon = atom_icon.icon
		// Atom icons compiled in from 'icons/path/to/dmi_file.dmi' are weird and not really icon objects that you generate with icon().
		// If theyre unchanged dmi's then they're stringifiable to "icons/path/to/dmi_file.dmi"

	if(isicon(icon) && isfile(icon))
		// Icons compiled in from 'icons/path/to/dmi_file.dmi' at compile time are weird and arent really /icon objects,
		// But they pass both isicon() and isfile() checks. theyre the easiest case since stringifying them gives us the path we want
		var/icon_ref = "\ref[icon]"
		var/locate_icon_string = "[locate(icon_ref)]"

		icon_path = locate_icon_string

	else if(isicon(icon) && "[icon]" == "/icon")
		// Icon objects generated from icon() at runtime are icons, but they ARENT files themselves, they represent icon files.
		// If the files they represent are compile time dmi files in the rsc, then
		// The rsc reference returned by fcopy_rsc() will be stringifiable to "icons/path/to/dmi_file.dmi"
		var/rsc_ref = fcopy_rsc(icon)

		var/icon_ref = "\ref[rsc_ref]"

		var/icon_path_string = "[locate(icon_ref)]"

		icon_path = icon_path_string

	else if(istext(icon))
		var/rsc_ref = fcopy_rsc(icon)
		// If its the text path of an existing dmi file, the rsc reference returned by fcopy_rsc() will be stringifiable to a dmi path

		var/rsc_ref_ref = "\ref[rsc_ref]"
		var/rsc_ref_string = "[locate(rsc_ref_ref)]"

		icon_path = rsc_ref_string

	if(is_valid_dmi_file(icon_path))
		return icon_path

	return FALSE

/// Generate a filename for this asset
/// The same asset will always lead to the same asset name
/// (Generated names do not include file extention.)
/proc/generate_asset_name(file)
	return "asset.[md5(fcopy_rsc(file))]"

/**
 * generate an asset for the given icon or the icon of the given appearance for [thing], and send it to any clients in target.
 * Arguments:
 * * thing - either a /icon object, or an object that has an appearance (atom, image, mutable_appearance).
 * * target - either a reference to or a list of references to /client's or mobs with clients
 * * icon_state - string to force a particular icon_state for the icon to be used
 * * dir - dir number to force a particular direction for the icon to be used
 * * frame - what frame of the icon_state's animation for the icon being used
 * * moving - whether or not to use a moving state for the given icon
 * * sourceonly - if TRUE, only generate the asset and send back the asset url, instead of tags that display the icon to players
 * * extra_clases - string of extra css classes to use when returning the icon string
 * * keyonly - if TRUE, only returns the asset key to use get_asset_url manually. Overrides sourceonly.
 */
/proc/icon2html(atom/thing, client/target, icon_state, dir = SOUTH, frame = 1, moving = FALSE, sourceonly = FALSE, extra_classes = null, keyonly = FALSE)
	if(!thing)
		return

	var/key
	var/icon/icon2collapse = thing

	if(!target)
		return
	if(target == world)
		target = GLOB.clients

	var/list/targets
	if(!islist(target))
		targets = list(target)
	else
		targets = target
	if(!length(targets))
		return

	//check if the given object is associated with a dmi file in the icons folder. if it is then we dont need to do a lot of work
	//for asset generation to get around byond limitations
	var/icon_path = get_icon_dmi_path(thing)

	if(!isicon(icon2collapse))
		if(isfile(thing)) //special snowflake
			var/name = "[generate_asset_name(thing)].png"
			if(!SSassets.cache[name])
				SSassets.transport.register_asset(name, thing)
			for(var/thing2 in targets)
				SSassets.transport.send_assets(thing2, name)
			if(keyonly)
				return name
			if(sourceonly)
				return SSassets.transport.get_asset_url(name)
			return "<img class='[extra_classes] icon icon-misc' src='[SSassets.transport.get_asset_url(name)]'>"

		//its either an atom, image, or mutable_appearance, we want its icon var
		icon2collapse = thing.icon

		if(isnull(icon_state))
			icon_state = thing.icon_state
			//Despite casting to atom, this code path supports mutable appearances, so let's be nice to them
			if(isnull(icon_state))
				icon_state = thing::post_init_icon_state || thing::icon_state
				if(isnull(dir))
					dir = thing::dir

		if(isnull(dir))
			dir = thing.dir

		// Commented out because this is seemingly our source of bad icon operations
		/* if(ishuman(thing)) // Shitty workaround for a BYOND issue.
			var/icon/temp = icon2collapse
			icon2collapse = icon()
			icon2collapse.Insert(temp, dir = SOUTH)
			dir = SOUTH*/
	else
		if(isnull(dir))
			dir = SOUTH
		if(isnull(icon_state))
			icon_state = ""

	icon2collapse = icon(icon2collapse, icon_state, dir, frame, moving)

	var/list/name_and_ref = generate_and_hash_rsc_file(icon2collapse, icon_path)//pretend that tuples exist

	var/rsc_ref = name_and_ref[1] //weird object thats not even readable to the debugger, represents a reference to the icons rsc entry
	var/file_hash = name_and_ref[2]
	key = "[name_and_ref[3]].png"

	if(!SSassets.cache[key])
		SSassets.transport.register_asset(key, rsc_ref, file_hash, icon_path)
	for(var/client_target in targets)
		SSassets.transport.send_assets(client_target, key)
	if(keyonly)
		return key
	if(sourceonly)
		return SSassets.transport.get_asset_url(key)
	return "<img class='[extra_classes] icon icon-[icon_state]' src='[SSassets.transport.get_asset_url(key)]'>"

//Costlier version of icon2html() that uses getFlatIcon() to account for overlays, underlays, etc. Use with extreme moderation, ESPECIALLY on mobs.
/proc/costly_icon2html(thing, target, sourceonly = FALSE)
	if(!thing)
		return

	if(isicon(thing))
		return icon2html(thing, target)

	return flat_icon2html(thing, target, sourceonly = FALSE)

/proc/flat_icon2html(thing, target, sourceonly = FALSE, name = md5("[thing]"))
	if(!thing)
		return
	var/icon/flat_icon = getFlatIcon(thing)
	return icon2html(flat_icon, target, sourceonly = sourceonly)

/proc/get_icon_from_uni_icon(datum/universal_icon/flat_icon, name, dmi_icon = FALSE)
	var/entries_json = json_encode(list(name = flat_icon.to_list()))
	var/data_out = rustlib_iconforge_generate("tmp/icons/", name, entries_json, FALSE, dmi_icon, TRUE)
	if(data_out == RUSTLIBS_JOB_ERROR)
		CRASH("Icon [name] JOB PANIC")
	else if(!findtext(data_out, "{", 1, 2))
		rustlib_file_write(entries_json, "[GLOB.log_directory]/spritesheet_debug_[name].json")
		CRASH("Icon [name] UNKNOWN ERROR: [data_out]")
	var/data = json_decode(data_out)
	var/list/sizes = data["sizes"]
	if(!length(sizes))
		CRASH("Icon [name] UNKNOWN ERROR: [data_out]")
	var/size = sizes[1]
	if(!size)
		CRASH("Icon [name] UNKNOWN ERROR: [data_out]")

	var/png_name = "[name]_[size].png"
	var/file_directory = "tmp/icons/[png_name]"
	return file(file_directory)


#define CACHED_WIDTH_INDEX "width"
#define CACHED_HEIGHT_INDEX "height"

/atom/proc/get_cached_width()
	if(isnull(icon))
		return 0
	var/list/dimensions = get_icon_dimensions(icon)
	return dimensions[CACHED_WIDTH_INDEX]

/atom/proc/get_cached_height()
	if(isnull(icon))
		return 0
	var/list/dimensions = get_icon_dimensions(icon)
	return dimensions[CACHED_HEIGHT_INDEX]

#undef CACHED_WIDTH_INDEX
#undef CACHED_HEIGHT_INDEX

/**
 * Center's an image. Only run this on float overlays and not physical
 * Requires:
 * The Image
 * The x dimension of the icon file used in the image
 * The y dimension of the icon file used in the image
 * eg: center_image(image_to_center, 32,32)
 * eg2: center_image(image_to_center, 96,96)
 */
/proc/center_image(image/image_to_center, x_dimension = 0, y_dimension = 0)
	if(!image_to_center)
		return

	if(!x_dimension || !y_dimension)
		return

	if((x_dimension == ICON_SIZE_X) && (y_dimension == ICON_SIZE_Y))
		return image_to_center

	//Offset the image so that its bottom left corner is shifted this many pixels
	//This makes it infinitely easier to draw larger inhands/images larger than world.iconsize
	//but still use them in game
	var/x_offset = -((x_dimension / ICON_SIZE_X) - 1) * (ICON_SIZE_X * 0.5)
	var/y_offset = -((y_dimension / ICON_SIZE_Y) - 1) * (ICON_SIZE_Y * 0.5)

	//Correct values under icon_size
	if(x_dimension < ICON_SIZE_X)
		x_offset *= -1
	if(y_dimension < ICON_SIZE_Y)
		y_offset *= -1

	image_to_center.pixel_w = x_offset
	image_to_center.pixel_z = y_offset

	return image_to_center

/// Fikou's fix for making toast alerts look nice - resets offsets, transforms to fit
/proc/get_small_overlay(atom/source)
	var/mutable_appearance/alert_overlay = new(source)
	alert_overlay.pixel_x = 0
	alert_overlay.pixel_y = 0
	alert_overlay.pixel_z = 0
	alert_overlay.pixel_w = 0

	var/scale = 1
	var/list/icon_dimensions = get_icon_dimensions(source.icon)
	var/width = icon_dimensions["width"]
	var/height = icon_dimensions["height"]

	if(width > ICON_SIZE_X)
		alert_overlay.pixel_w = -(ICON_SIZE_X / 2) * ((width - ICON_SIZE_X) / ICON_SIZE_X)
	if(height > ICON_SIZE_Y)
		alert_overlay.pixel_z = -(ICON_SIZE_Y / 2) * ((height - ICON_SIZE_Y) / ICON_SIZE_Y)
	if(width > ICON_SIZE_X || height > ICON_SIZE_Y)
		if(width >= height)
			scale = ICON_SIZE_X / width
		else
			scale = ICON_SIZE_Y / height
	alert_overlay.transform = alert_overlay.transform.Scale(scale)

	return alert_overlay

/// Perform a shake on an atom, resets its position afterwards
/atom/proc/Shake(pixelshiftx = 2, pixelshifty = 2, duration = 2.5 SECONDS, shake_interval = 0.02 SECONDS)
	var/initialpixelx = pixel_x
	var/initialpixely = pixel_y
	animate(src, pixel_x = initialpixelx + rand(-pixelshiftx, pixelshiftx), pixel_y = initialpixelx + rand(-pixelshifty, pixelshifty), time = shake_interval, flags = ANIMATION_PARALLEL)
	for(var/i in 3 to ((duration / shake_interval))) // Start at 3 because we already applied one, and need another to reset
		animate(pixel_x = initialpixelx + rand(-pixelshiftx, pixelshiftx), pixel_y = initialpixely + rand(-pixelshifty, pixelshifty), time = shake_interval)
	animate(pixel_x = initialpixelx, pixel_y = initialpixely, time = shake_interval)

/// Returns a list with pixel_shift values that will shift an object's icon one tile in the direction passed.
/proc/pixel_shift_dir(dir, amount_x = 32, amount_y = 32)
	amount_x = min(max(0, amount_x), 32) //No less than 0, no greater than 32.
	amount_y = min(max(0, amount_x), 32)
	var/list/shift = list("x" = 0, "y" = 0)
	switch(dir)
		if(NORTH)
			shift["y"] = amount_y
		if(SOUTH)
			shift["y"] = -amount_y
		if(EAST)
			shift["x"] = amount_x
		if(WEST)
			shift["x"] = -amount_x
		if(NORTHEAST)
			shift = list("x" = amount_x, "y" = amount_y)
		if(NORTHWEST)
			shift = list("x" = -amount_x, "y" = amount_y)
		if(SOUTHEAST)
			shift = list("x" = amount_x, "y" = -amount_y)
		if(SOUTHWEST)
			shift = list("x" = -amount_x, "y" = -amount_y)

	return shift
