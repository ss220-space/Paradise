/datum/action/item_action/advanced/ninja/ninjaheal
	name = "Восстановительный коктейль"
	desc = "Вводит в кровь 25 ед. химиката \"Чиюризин\", который лечит все виды травм и повреждений, очищает кровоток и восстанавливает части тела. \
			Действует путём прямого взаимодействия с пространственно-временным континуумом, что создаёт небольшой риск временного парадокса. \
			Порог передозировки: 30 единиц."
	check_flags = NONE
	charge_type = ADV_ACTION_TYPE_CHARGES
	charge_max = 3
	button_icon_state = "chem_injector"
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green_active"
	action_initialisation_text = "Integrated Restorative Cocktail Mixer"

/datum/action/item_action/advanced/ninja/ninjaheal/Grant(mob/living/carbon/human/ninja)
	var/obj/item/clothing/suit/space/space_ninja/ninja_suit = target
	if(ninja_suit && istype(ninja_suit))
		ninja_suit.heal_chems = src
	return ..()

/datum/action/item_action/advanced/ninja/ninjaheal/Remove(mob/living/carbon/human/ninja)
	var/obj/item/clothing/suit/space/space_ninja/ninja_suit = target
	if(ninja_suit && istype(ninja_suit))
		ninja_suit.heal_chems = null
	return ..()

/obj/item/clothing/suit/space/space_ninja/proc/ninjaheal()
	if(ninjacost(0,N_HEAL))
		return
	var/mob/living/carbon/human/ninja = affecting
	ninja.reagents.add_reagent("chiyurizine", 25)	//The 25 dose is important. Reagent won't work if you add less. And it will overdose if you add 30 or more
	balloon_alert(ninja, "чиюризин введён")
	atom_say("Spider-OS напоминает вам, вы можете отслеживать количество реагента в крови с помощью встроенных сканеров.")
	add_attack_logs(ninja, null, "Activated healing chems.")
	var/datum/action/item_action/advanced/ninja/ninjaheal/ninjaheal = locate() in ninja.actions
	ninjaheal.use_action()
	if(!ninjaheal.charge_counter)
		ninjaheal.action_ready = FALSE
		ninjaheal.toggle_button_on_off()

// A reality rift designated to contain our ninja inside it.
// Created via the "chiyurizine" reagent.
/obj/effect/temp_visual/ninja_rend
	name = "A somewhat stable rend in reality"
	desc = "Невероятно... но абсурдно. Кто может выйти из этого?"
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "green_rift"
	var/mob/living/carbon/human/occupant	//mob holder
	duration = 1 MINUTES
	var/duration_min = 5 SECONDS
	var/duration_max = 20 SECONDS
	randomdir = FALSE
	light_power = 5
	light_range = 3
	light_color = "#55ff63"

/obj/effect/temp_visual/ninja_rend/get_ru_names()
	return alist(
		NOMINATIVE = "разлом реальности",
		GENITIVE = "разлома реальности",
		DATIVE = "разлому реальности",
		ACCUSATIVE = "разлом реальности",
		INSTRUMENTAL = "разломом реальности",
		PREPOSITIONAL = "разломе реальности",
	)

/obj/effect/temp_visual/ninja_rend/Initialize(mapload)
	for(var/obj/effect/temp_visual/ninja_rend/other_rend in src.loc.contents)
		if(other_rend!=src)
			qdel(other_rend)	//Only one on a turf!
	duration = rand(duration_min, duration_max)
	. = ..()

/obj/effect/temp_visual/ninja_rend/Destroy()
	if(occupant)
		occupant.forceMove(get_turf(src))
		occupant.SetSleeping(0)
		occupant = null
	. = ..()

/obj/effect/temp_visual/ninja_rend/proc/GetOccupant(mob/living/carbon/human/rend_occupant)
	if(!istype(rend_occupant))
		return
	occupant = rend_occupant
	//Check below gets them out of most machines safelly
	if(isobj(rend_occupant.loc))
		var/obj/O = rend_occupant.loc
		O.force_eject_occupant(rend_occupant)
	occupant.forceMove(src)
	occupant.SetSleeping(duration)
	to_chat(occupant, span_danger("Вы попали в пространственно временной парадокс... "))
