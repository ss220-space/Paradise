/datum/action/item_action/advanced/ninja/ninjaheal
	name = "Restorative Cocktail"
	desc = "Injects a series of chemicals that will heal most of the user's injuries, cure internal damage and bones. \
			But healing comes with a price of sleeping while your body regenerates!"
	check_flags = NONE
	charge_type = ADV_ACTION_TYPE_CHARGES
	charge_max = 3
	use_itemicon = FALSE
	button_icon_state = "chem_injector"
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green_active"
	action_initialisation_text = "Integrated Restorative Cocktail Mixer"

/obj/item/clothing/suit/space/space_ninja/proc/ninjaheal()
	if(ninjacost(0,N_HEAL))
		return
	var/mob/living/carbon/human/ninja = affecting
	if(alert(ninja, "Вы уверены что хотите ввести себе лечащие реагенты? Это усыпит вас на время пока ваше тело регенерирует!",,"Да","Нет") == "Нет")
		return
	ninja.reagents.add_reagent("chiyurizine", 25)
	to_chat(ninja, span_notice("Реагенты успешно введены в пользователя."))
	add_attack_logs(ninja, null, "Activated healing chems.")
	for(var/datum/action/item_action/advanced/ninja/ninjaheal/ninja_action in actions)
		ninja_action.use_action()
		if(!ninja_action.charge_counter)
			ninja_action.action_ready = FALSE
			ninja_action.toggle_button_on_off()
		break
/*
	addtimer(CALLBACK(src, .proc/ninjaheal_after), 5 SECONDS)

/obj/item/clothing/suit/space/space_ninja/proc/ninjaheal_after()
	var/mob/living/carbon/human/ninja = affecting
	ninja.SetSleeping(60)
	var/obj/effect/temp_visual/ninja_rend/rend = new(get_turf(src))
	rend.occupant = ninja
	ninja.forceMove(rend)
*/
// Разрыв в реальности призванный удерживать там ниндзя c реагентом пока тот лечится
/obj/effect/temp_visual/ninja_rend
	name = "A somewhat stable rend in reality"
	desc = "Incredible... yet absurd thing. Who's gonna come out of it?"
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "green_rift"
	anchored = TRUE
	var/mob/living/carbon/human/occupant	//mob holder
	duration = 1 MINUTES
	var/duration_min = 5 SECONDS
	var/duration_max = 20 SECONDS
	randomdir = FALSE
	light_power = 5
	light_range = 3
	light_color = "#55ff63"

/obj/effect/temp_visual/ninja_rend/Initialize(mapload)
	for(var/obj/effect/temp_visual/ninja_rend/other_rend in src.loc.contents)
		if(other_rend!=src)
			qdel(other_rend)	//Не больше одного на тайле!
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
	occupant.forceMove(src)
	occupant.SetSleeping(duration)
	to_chat(occupant, span_danger("Вы попали в пространственно временной парадокс... "))
