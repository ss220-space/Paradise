/**************
* AI-specific *
**************/
/datum/picture
	var/name = "image"
	var/list/fields = list()

/obj/item/camera/siliconcam
	var/in_camera_mode = 0
	var/photos_taken = 0
	var/list/aipictures = list()

/obj/item/camera/siliconcam/ai_camera //camera AI can take pictures with
	name = "AI photo camera"

/obj/item/camera/siliconcam/robot_camera //camera cyborgs can take pictures with
	name = "Cyborg photo camera"

/obj/item/camera/siliconcam/drone_camera //currently doesn't offer the verbs, thus cannot be used
	name = "Drone photo camera"

/obj/item/camera/siliconcam/proc/injectaialbum(datum/picture/P, sufix = "") //stores image information to a list similar to that of the datacore
	photos_taken++
	P.fields["name"] = "Image [photos_taken][sufix]"
	aipictures += P

/obj/item/camera/siliconcam/proc/injectmasteralbum(datum/picture/P) //stores image information to a list similar to that of the datacore
	var/mob/living/silicon/robot/C = src.loc
	if(C.connected_ai)
		var/mob/A = P.fields["author"]
		C.connected_ai.aiCamera.injectaialbum(P, " (taken by [A.name])")
		to_chat(C.connected_ai, span_unconscious("Image recorded and saved by [name]"))
		to_chat(usr, span_unconscious("Image recorded and saved to remote database"))//feedback to the Cyborg player that the picture was taken

	else
		injectaialbum(P)
		to_chat(usr, span_unconscious("Image recorded"))

/obj/item/camera/siliconcam/proc/selectpicture(obj/item/camera/siliconcam/cam)
	if(!cam)
		cam = getsource()

	var/list/nametemp = list()
	var/find
	if(length(cam.aipictures) == 0)
		to_chat(usr, span_userdanger("No images saved"))
		return
	for(var/datum/picture/t in cam.aipictures)
		nametemp += t.fields["name"]
	find = tgui_input_list(usr, "Select image (numbered in order taken)", "Pick Image", nametemp)

	for(var/datum/picture/q in cam.aipictures)
		if(q.fields["name"] == find)
			return q

/obj/item/camera/siliconcam/proc/viewpictures()
	var/datum/picture/selection = selectpicture()

	if(!selection)
		return

	var/obj/item/photo/P = new/obj/item/photo()
	P.construct(selection)
	P.show(usr)
	if(P.desc)
		to_chat(usr, P.desc)

	// TG uses a special garbage collector.. qdel(P)
	qdel(P) //so 10 thousand pictures items are not left in memory should an AI take them and then view them all.

/obj/item/camera/siliconcam/proc/deletepicture(obj/item/camera/siliconcam/cam)
	var/datum/picture/selection = selectpicture(cam)

	if(!selection)
		return

	cam.aipictures -= selection
	to_chat(usr, span_unconscious("Image deleted"))

/obj/item/camera/siliconcam/ai_camera/can_capture_turf(turf/T, mob/user)
	var/mob/living/silicon/ai = user
	return ai.TurfAdjacent(T)

/obj/item/camera/siliconcam/proc/toggle_camera_mode()
	if(in_camera_mode)
		camera_mode_off()
	else
		camera_mode_on()

/obj/item/camera/siliconcam/proc/camera_mode_off()
	src.in_camera_mode = 0
	to_chat(usr, "<b>Camera Mode deactivated</b>")

/obj/item/camera/siliconcam/proc/camera_mode_on()
	src.in_camera_mode = 1
	to_chat(usr, "<b>Camera Mode activated</b>")

/obj/item/camera/siliconcam/proc/toggle_camera_flash()
	flashing_lights = !flashing_lights
	to_chat(usr, span_notice("Camera flash [flashing_lights ? "activated" : "deactivated"]."))

/obj/item/camera/siliconcam/ai_camera/printpicture(mob/user, datum/picture/P)
	injectaialbum(P)
	to_chat(usr, span_unconscious("Image recorded"))

/obj/item/camera/siliconcam/robot_camera/printpicture(mob/user, datum/picture/P)
	injectmasteralbum(P)

GAME_VERB_SRC_DESC(/obj/item/camera/siliconcam/ai_camera, take_image, usr, "Сделать фото", "Takes an image", VERB_CATEGORY_SUBSYSTEMS)
	toggle_camera_mode()

GAME_VERB_SRC_DESC(/obj/item/camera/siliconcam/ai_camera, view_images, usr, "Посмотреть фото", "View images", VERB_CATEGORY_SUBSYSTEMS)
	viewpictures()

GAME_VERB_SRC_DESC(/obj/item/camera/siliconcam/ai_camera, delete_images, usr, "Удалить фото", "Delete image", VERB_CATEGORY_SUBSYSTEMS)
	deletepicture(src)

GAME_VERB_SRC_DESC(/obj/item/camera/siliconcam/ai_camera, toggle_camera_flash_verb, usr, "Вспышка камеры", "Toggle camera flashing", VERB_CATEGORY_SUBSYSTEMS)
	toggle_camera_flash(src)

GAME_VERB_SRC_DESC(/obj/item/camera/siliconcam/robot_camera, take_image, usr, "Сделать фото", "Takes an image", VERB_CATEGORY_SUBSYSTEMS)
	toggle_camera_mode()

GAME_VERB_SRC_DESC(/obj/item/camera/siliconcam/robot_camera, view_images, usr, "Посмотреть фото", "View images", VERB_CATEGORY_SUBSYSTEMS)
	viewpictures()

GAME_VERB_SRC_DESC(/obj/item/camera/siliconcam/robot_camera, delete_images, usr, "Удалить фото", "Delete a local image", VERB_CATEGORY_SUBSYSTEMS)
	deletepicture(src)

GAME_VERB_SRC_DESC(/obj/item/camera/siliconcam/robot_camera, toggle_camera_flash_verb, usr, "Вспышка камеры", "Toggle camera flash", VERB_CATEGORY_SUBSYSTEMS)
	toggle_camera_flash(src)

/obj/item/camera/siliconcam/proc/getsource()
	if(isAI(src.loc))
		return src

	var/mob/living/silicon/robot/C = src.loc
	var/obj/item/camera/siliconcam/Cinfo
	if(C.connected_ai)
		Cinfo = C.connected_ai.aiCamera
	else
		Cinfo = src
	return Cinfo
