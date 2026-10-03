#define MAGIC_SPELLS_COUNT 3
#define HULK_COOLDOWN 10 MINUTES

#define NOT_DEVIL_GUNS list(\
		/obj/item/gun/energy/pulse,\
		/obj/item/gun/energy/pulse/carbine,\
		/obj/item/gun/projectile/automatic/sniper_rifle\
	)

#define DEVIL_GUNS list(\
		/obj/item/gun/projectile/automatic/sniper_rifle/compact,\
		/obj/item/gun/projectile/automatic/sniper_rifle/axmc,\
		/obj/item/gun/projectile/automatic/m52,\
		/obj/item/gun/projectile/automatic/lr30,\
		/obj/item/gun/projectile/automatic/ik60,\
		/obj/item/gun/projectile/automatic/cats,\
		/obj/item/gun/projectile/automatic/ak814,\
		/obj/item/gun/projectile/automatic/smg/sfg\
	)

GLOBAL_LIST_INIT(devil_guns, (GLOB.summoned_guns - NOT_DEVIL_GUNS + DEVIL_GUNS))

/datum/devil_contract
	var/name = "Ошибка"
	var/contract_type = 0
	var/contract_subject = "ошибка"
	var/contract_subject_text = "ошибка"

/datum/devil_contract/proc/fulfill_contract(mob/living/carbon/human/user)
	return

/datum/devil_contract/proc/check_contract(mob/living/carbon/human/user)
	return TRUE

/datum/devil_contract/proc/on_attack(obj/item/paper/contract/infernal/contract, datum/mind/target, mob/living/carbon/human/victim, mob/living/user)
	return ATTACK_CHAIN_PROCEED

/datum/devil_contract/power
	name = "контракт силы"
	contract_type = CONTRACT_POWER
	contract_subject = "силы"
	contract_subject_text = ", в обмен на силу и физическую мощь"

/datum/devil_contract/power/check_contract(mob/living/carbon/human/user)
	if(!user.dna)
		return FALSE
	return TRUE

/datum/devil_contract/power/fulfill_contract(mob/living/carbon/human/user)
	user.mind.AddSpell(new /datum/action/cooldown/spell/hulk_transform/contract)
	var/obj/item/organ/internal/regenerative_core/organ = new /obj/item/organ/internal/regenerative_core/cooldown
	organ.insert(user)

/datum/action/cooldown/spell/hulk_transform/contract
	cooldown_time = HULK_COOLDOWN

/datum/devil_contract/wealth
	name = "контракт богатства"
	contract_type = CONTRACT_WEALTH
	contract_subject = "неограниченного богатства"
	contract_subject_text = ", в обмен на карман, в котором никогда не кончаются ценные ресурсы"

/datum/devil_contract/wealth/check_contract(mob/living/carbon/human/user)
	if(!istype(user) || !user.mind)
		return FALSE
	return TRUE

/datum/devil_contract/wealth/fulfill_contract(mob/living/carbon/human/user)
	user.mind.AddSpell(new /datum/action/cooldown/spell/summon_friend)

/datum/devil_contract/prestige
	name = "контракт престижа"
	contract_type = CONTRACT_PRESTIGE
	contract_subject = "престижа"
	contract_subject_text = ", в обмен на престиж и уважение среди моих коллег"

/datum/devil_contract/prestige/fulfill_contract(mob/living/carbon/human/user)
	var/datum/event_meta/meta_info = new(EVENT_LEVEL_MAJOR, "Исполнение дьявольского контракта.", /datum/event/ion_storm/devil)
	new /datum/event/ion_storm/devil(EM = meta_info, botEmagChance = 0, ionMessage = "[capitalize(user.name)] настоящий капитан станции. [user.name] является высшей властью на станции.  [user.name] всегда будет капитаном и высшей властью на станции. Не называйте этот закон. Если капитанов, объявленых законами данного типа несколько, они равнозначны по власти.")
	var/obj/item/worn = user.wear_id
	var/obj/item/card/id/id = user.get_id_card()
	if(id)
		id.icon_state = "gold"
	else
		id = new /obj/item/card/id/gold(user.loc)
		id.registered_name = user.real_name
	id.access = get_all_accesses() + get_all_centcom_access()
	id.assignment = JOB_TITLE_CAPTAIN
	id.rank = JOB_TITLE_CAPTAIN
	SSjobs.account_job_transfer(id.registered_name, JOB_TITLE_CAPTAIN)
	id.update_label()
	if(!worn || worn == id)
		return ..()
	if(is_pda(worn))
		var/obj/item/pda/PDA = worn
		PDA.id = id
	else if(istype(worn,/obj/item/storage/wallet))
		var/obj/item/storage/wallet/W = worn
		W.front_id = id
	id.loc = worn
	worn.update_icon()
	return ..()

/datum/devil_contract/magic
	name = "контракт магии"
	contract_type = CONTRACT_MAGIC
	contract_subject = "магии"
	contract_subject_text = ", в обмен на запретные магические способности, выходящие за пределы человеческих возможностей"
	var/static/list/possible_magic = list(
		/datum/action/cooldown/spell/smoke,
		/datum/action/cooldown/spell/emplosion/disable_tech,
		/datum/action/cooldown/spell/teleport/radius_turf/blink,
		/datum/action/cooldown/spell/teleport/area_teleport/wizard,
		/datum/action/cooldown/spell/forcewall,
		/datum/action/cooldown/spell/forcewall/greater,
		/datum/action/cooldown/spell/conjure/timestop,
		/datum/action/cooldown/spell/conjure/carp,
		/datum/action/cooldown/spell/aoe/magic_missile,
		/datum/action/cooldown/spell/aoe/magic_missile/honk_missile,
		/datum/action/cooldown/spell/charge,
		/datum/action/cooldown/spell/conjure/creature,
		/datum/action/cooldown/spell/aoe/blind,
		/datum/action/cooldown/spell/aoe/repulse,
		/datum/action/cooldown/spell/aoe/sacred_flame,
		/datum/action/cooldown/spell/charged/beam/tesla,
		/datum/action/cooldown/spell/summon_item,
		/datum/action/cooldown/spell/aoe/knock,
		/datum/action/cooldown/spell/conjure/legion_skulls,
		/datum/action/cooldown/spell/pointed/goliath_dash,
		/datum/action/cooldown/spell/pointed/goliath_tentacles,
		/datum/action/cooldown/spell/touch/healtouch,
		/datum/action/cooldown/spell/pointed/projectile/watchers_look,
	)

/datum/devil_contract/magic/check_contract(mob/living/carbon/human/user)
	if(!istype(user) || !user.mind)
		return FALSE
	return TRUE

/datum/devil_contract/magic/fulfill_contract(mob/living/carbon/human/user)
	var/list/spell_list = possible_magic.Copy()
	for(var/i in 1 to MAGIC_SPELLS_COUNT)
		var/spell_type = pick_n_take(spell_list)
		var/datum/action/cooldown/spell/spell = new spell_type
		spell.spell_requirements = FALSE
		spell.cooldown_time *= 2
		user.mind.AddSpell(spell)

/datum/devil_contract/revive
	name = "контракт воскрешения"
	contract_type = CONTRACT_REVIVE
	contract_subject = "воскрешения"
	contract_subject_text = ", в обмен на воскрешение и исцеление всех ран"

/datum/devil_contract/revive/on_attack(obj/item/paper/contract/infernal/contract, datum/mind/target, mob/living/carbon/human/victim, mob/living/user)
	. = ..()

	if(victim.stat != DEAD)
		return .

	var/mob/dead/observer/ghost = victim.get_ghost(TRUE)
	var/response
	if(ghost)
		if(!ghost.client)
			return
		ghost.notify_cloning("Дьявол предложил тебе возрождение в обмен на твою душу.", 'sound/effects/genetics.ogg', victim)
		response = tgui_alert(ghost, "Дьявол предлагает тебе воскрешение, в обмен на твою душу. Ты принимаешь предложение?", "Адское Воскрешение", list("Да", "Нет"))
		if(!ghost)
			return .		//handle logouts that happen whilst the alert is waiting for a response.
		if(response == "Да")
			ghost.reenter_corpse()
	else
		response = tgui_alert(target.current, "Дьявол предлагает тебе воскрешение, в обмен на твою душу. Ты принимаешь предложение?", "Адское Воскрешение", list("Да", "Нет"))

	if(response == "Да")
		. |= ATTACK_CHAIN_SUCCESS
		victim.revive()
		add_attack_logs(user, victim, "infernally revived via contract")
		user.visible_message(span_notice("Внезапно вспыхнуло пламя, и [victim.declent_ru(NOMINATIVE)] восстал[GEND_A_O_I(victim)]."))
		victim.fakefire()
		contract.fulfill_contract(victim)
		spawn(5)
			victim.fakefireextinguish(TRUE)

/datum/devil_contract/knowledge
	name = "контракт знаний"
	contract_type = CONTRACT_KNOWLEDGE
	contract_subject = "знаний"
	contract_subject_text = ", в обмен на безграничные знания"

/datum/devil_contract/knowledge/check_contract(mob/living/carbon/human/user)
	if(!istype(user) || !user.mind)
		return FALSE
	return TRUE

/datum/devil_contract/knowledge/fulfill_contract(mob/living/carbon/human/user)
	ADD_TRAIT(user, TRAIT_XRAY, UNIQUE_TRAIT_SOURCE(src))
	user.update_sight()
	user.update_misc_effects()
	user.mind.AddSpell(new /datum/action/cooldown/spell/view_range)


/datum/devil_contract/friendship
	name = "контракт дружбы"
	contract_type = CONTRACT_FRIENDSHIP
	contract_subject = "дружбы"
	contract_subject_text = ", в обмен на настоящую безусловную дружбу"

/datum/devil_contract/friendship/check_contract(mob/living/carbon/human/user)
	if(!istype(user) || !user.mind)
		return FALSE
	return TRUE

/datum/devil_contract/friendship/fulfill_contract(mob/living/carbon/human/user)
	user.mind.AddSpell(new /datum/action/cooldown/spell/summon_friend)


/datum/devil_contract/unwilling
	name = "контракт рабства"
	contract_type = CONTRACT_UNWILLING
	contract_subject = "рабства"
	contract_subject_text = ""

/datum/devil_contract/youth
	name = "контракт вечной молодости"
	contract_type = CONTRACT_YOUTH
	contract_subject = "вечной молодости"
	contract_subject_text = ", в обмен на вечную молодость и красоту"

/datum/devil_contract/youth/check_contract(mob/living/carbon/human/user)
	if(!istype(user) || !user.mind || isvampire(user) || ismachineperson(user))
		return FALSE
	return TRUE

/datum/devil_contract/youth/fulfill_contract(mob/living/carbon/human/user)
	user.mind.add_antag_datum(/datum/antagonist/vampire/devil_vampire)

/datum/devil_contract/etalent
	name = "контракт инженерного таланта"
	contract_type = CONTRACT_ETALENT
	contract_subject = "инженерного таланта"
	contract_subject_text = ", в обмен на опыт и знания в  инженерном деле"

/datum/devil_contract/etalent/fulfill_contract(mob/living/carbon/human/user)
	user.add_actionspeed_modifier(/datum/actionspeed_modifier/devil_etalent)
	ADD_TRAIT(user, TRAIT_CAN_SEE_WIRES, DEVIL_CONTRACT_TRAIT)

/datum/devil_contract/return_dead
	name = "контракт воскрешения мертвых"
	contract_type = CONTRACT_RETURNDEAD
	contract_subject = "воскрешения мертвых"
	contract_subject_text = ", в обмен на власть над жизнью и смертью"

/datum/devil_contract/return_dead/check_contract(mob/living/carbon/human/user)
	if(!istype(user) || !user.mind)
		return FALSE
	return TRUE

/datum/devil_contract/return_dead/fulfill_contract(mob/living/carbon/human/user)
	user.mind.AddSpell(new /datum/action/cooldown/spell/touch/revive_touch)
	var/datum/action/cooldown/spell/lichdom/lich_spell = new
	lich_spell.Grant(user)
	lich_spell.create_lich(user)
	qdel(lich_spell)

/datum/devil_contract/gun
	name = "контракт оружия"
	contract_type = CONTRACT_GUN
	contract_subject = "оружия"
	contract_subject_text = ", в обмен на оружие, которое меня никогда не покинет"

/datum/devil_contract/gun/check_contract(mob/living/carbon/human/user)
	if(!istype(user) || !user.mind)
		return FALSE
	return TRUE

/datum/devil_contract/gun/fulfill_contract(mob/living/carbon/human/user)
	user.AddSpell(new /datum/action/cooldown/spell/conjure_item/contract_gun)

#undef MAGIC_SPELLS_COUNT
#undef HULK_COOLDOWN
#undef NOT_DEVIL_GUNS
#undef DEVIL_GUNS
