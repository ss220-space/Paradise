/datum/devil_bane
	var/name

	var/desc
	var/law

	var/mob/living/carbon/owner
	var/datum/antagonist/devil/devil

	var/bonus_damage = 1

/datum/devil_bane/Destroy(force)
	remove_bane()

	owner = null
	devil = null

	return ..()

/datum/devil_bane/proc/remove_bane()
	return

/datum/devil_bane/proc/link_bane(mob/living/carbon/carbon)
	owner = carbon
	devil = owner.mind?.has_antag_datum(/datum/antagonist/devil)

/datum/devil_bane/proc/init_bane()
	return

/datum/devil_bane/toolbox
	name = BANE_TOOLBOX

	law = "По какой-то причине ящики с инструментами крайне опасны для вас."
	desc = "То, что хранит средства творения, служит также и средством уничтожения дьявола."

	bonus_damage = BANE_TOOLBOX_DAMAGE_MODIFIER

/datum/devil_bane/toolbox/init_bane()
	RegisterSignal(owner, COMSIG_PARENT_ATTACKBY, PROC_REF(toolbox_attack))

/datum/devil_bane/toolbox/remove_bane()
	UnregisterSignal(owner, COMSIG_PARENT_ATTACKBY)

/datum/devil_bane/toolbox/proc/toolbox_attack(datum/source, obj/item/item, mob/attacker, params)
	SIGNAL_HANDLER

	if(!istype(item, /obj/item/storage/toolbox))
		return

	owner.apply_damage(item.force * bonus_damage)
	attacker.visible_message(
		span_warning("На этот раз [item.declent_ru(NOMINATIVE)] кажется необычайно робастным."),
		span_notice("[capitalize(item.declent_ru(NOMINATIVE))] уничтожа[pluralize_ru(item.gender,"ет","ют")] [owner.declent_ru(ACCUSATIVE)]!"))

/datum/devil_bane/whiteclothes
	name = BANE_WHITECLOTHES

	desc = "Ношение чистой белой одежды поможет отпугнуть этого дьявола."
	law = "Те, кто облачен в безупречно белые одежды, наводят на вас ужас."

/datum/devil_bane/whiteclothes/init_bane()
	RegisterSignal(owner, COMSIG_PARENT_ATTACKBY, PROC_REF(whiteclothes_attack))

/datum/devil_bane/whiteclothes/remove_bane()
	UnregisterSignal(owner, COMSIG_PARENT_ATTACKBY)

/datum/devil_bane/whiteclothes/proc/whiteclothes_attack(datum/source, obj/item/item, mob/attacker, params)
	SIGNAL_HANDLER

	if(!ishuman(attacker))
		return

	var/mob/living/carbon/human/hunter = attacker
	if(!istype(hunter.w_uniform, /obj/item/clothing/under))
		return

	var/obj/item/clothing/under/uniform = hunter.w_uniform
	if(!GLOB.whiteness[uniform.type])
		return

	owner.apply_damage(bonus_damage * (item.force * (GLOB.whiteness[uniform.type] + 1)))
	attacker.visible_message(span_warning("[capitalize(owner.declent_ru(NOMINATIVE))], кажется, получает вред от одежды [attacker.declent_ru(GENITIVE)]."),
	span_notice("Незапятнанная белая одежда вредит [owner.declent_ru(GENITIVE)]."))

/datum/devil_bane/harvest
	name = BANE_HARVEST

	law = "Плоды урожая станут вашим падением."
	desc = "Вид трудов урожая нарушит планы дьявола."

	bonus_damage = BANE_HARVEST_DAMAGE_MULTIPLIER

/datum/devil_bane/harvest/init_bane()
	RegisterSignal(owner, COMSIG_PARENT_ATTACKBY, PROC_REF(harvest_attack))

/datum/devil_bane/harvest/remove_bane()
	UnregisterSignal(owner, COMSIG_PARENT_ATTACKBY)

/datum/devil_bane/harvest/proc/harvest_attack(datum/source, obj/item/item, mob/attacker, params)
	SIGNAL_HANDLER

	if(!istype(item, /obj/item/reagent_containers/food/snacks/grown) || !istype(item, /obj/item/grown))
		return

	owner.apply_damage(item.force * bonus_damage)
	attacker.visible_message(
		span_warning("Духи урожая помогают в изгнании."),
		span_notice("Духи урожая вредят [owner.declent_ru(DATIVE)]."))

	qdel(item)

/datum/devil_bane/light
	name = BANE_LIGHT

	desc = "Яркие вспышки дезориентируют дьявола и, вероятно, заставят его сбежать."
	law = "Ослепляющий свет на время лишит вас возможности использовать атакующие способности."

/datum/devil_bane/light/init_bane()
	RegisterSignal(owner, COMSIG_LIVING_EARLY_FLASH_EYES, PROC_REF(flash_eyes))

/datum/devil_bane/light/remove_bane()
	UnregisterSignal(owner, COMSIG_LIVING_EARLY_FLASH_EYES)

/datum/devil_bane/light/proc/flash_eyes(datum/source, intensity, override_blindness_check, affect_silicon, visual, type)
	SIGNAL_HANDLER

	var/damage = intensity - owner.check_eye_prot()

	if(!damage)
		owner.mind?.disrupt_spells(0)
		return

	owner.mind?.disrupt_spells(-500)

/datum/devil_bane/silver
	name = BANE_SILVER

	desc = "Похоже, серебро наносит этому дьяволу серьёзные раны."
	law = "Серебро во всех его формах станет вашим падением."
	bonus_damage = BANE_SILVER_DAMAGE_MULTIPLIER

/datum/devil_bane/silver/init_bane()
	RegisterSignal(owner.reagents, COMSIG_EARLY_REAGENT_ADDED, PROC_REF(check_reagents))

/datum/devil_bane/silver/remove_bane()
	UnregisterSignal(owner.reagents, COMSIG_EARLY_REAGENT_ADDED)

/datum/devil_bane/silver/proc/check_reagents(
	datum/source,
	reagent_id,
	amount,
	data,
	reagtemp,
	no_react,
	chem_temp
	)
	SIGNAL_HANDLER

	if(reagent_id != "silver")
		return

	owner.reagents?.add_reagent(/datum/reagent/toxin, amount * bonus_damage)

/datum/devil_bane/iron
	name = BANE_IRON

	desc = "Железо будет медленно ранить дьявола, пока оно не выйдет из его тела."
	law = "Железо станет для вас ядом."

	bonus_damage = BANE_IRON_DAMAGE_MODIFIER

/datum/devil_bane/iron/init_bane()
	RegisterSignal(owner.reagents, COMSIG_EARLY_REAGENT_ADDED, PROC_REF(check_reagents))

/datum/devil_bane/iron/remove_bane()
	UnregisterSignal(owner.reagents, COMSIG_EARLY_REAGENT_ADDED)

/datum/devil_bane/iron/proc/check_reagents(
	datum/source,
	reagent_id,
	amount,
	data,
	reagtemp,
	no_react,
	chem_temp
	)
	SIGNAL_HANDLER

	if(reagent_id != "iron")
		return

	owner.reagents?.add_reagent(/datum/reagent/toxin, amount * bonus_damage)
