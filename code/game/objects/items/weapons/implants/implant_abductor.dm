/obj/item/implant/abductor
	name = "recall bio-chip"
	desc = "Returns you to the mothership."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "implant"
	implant_state = "implant-alien"
	origin_tech = "materials=2;biotech=7;magnets=4;bluespace=4;abductor=5"
	activated = BIOCHIP_ACTIVATED_ACTIVE
	implant_data = /datum/implant_fluff/abductor
	COOLDOWN_DECLARE(abductor_recall_cooldown)
	var/obj/machinery/abductor/pad/home
	var/cooldown = 30 SECONDS


/obj/item/implant/abductor/activate()
	if(COOLDOWN_FINISHED(src, abductor_recall_cooldown))
		home?.Retrieve(imp_in)
		COOLDOWN_START(src, abductor_recall_cooldown, cooldown)
	else
		to_chat(imp_in, span_warning("You must wait [round(COOLDOWN_TIMELEFT(src, abductor_recall_cooldown) / 10)] seconds to use [src] again!"))


/obj/item/implant/abductor/implant(mob/living/carbon/human/source, mob/user, force = FALSE)
	. = ..()
	if(!.)
		return

	var/obj/machinery/abductor/console/console
	if(ishuman(source) && isabductor(source))
		var/datum/species/abductor/species = source.dna.species
		console = get_team_console(species.team)
		home = console.pad

	if(!home)
		console = get_team_console(pick(1, 2, 3, 4))
		home = console.pad


/obj/item/implant/abductor/proc/get_team_console(team)
	var/obj/machinery/abductor/console/console
	for(var/obj/machinery/abductor/console/check in GLOB.abductor_equipment)
		if(check.team == team)
			console = check
			break
	return console


/obj/item/implanter/abductor
	name = "bio-chip implanter (abductor)"
	imp = /obj/item/implant/abductor


/obj/item/implantcase/abductor
	name = "bio-chip case - 'abductor'"
	desc = "A glass case containing an abductor bio-chip."
	imp = /obj/item/implant/abductor

