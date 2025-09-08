#define MAGIC_SPELLS_COUNT 3
#define HULK_COOLDOWN 10 MINUTES

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
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/hulk_transform/contract(null))
	var/obj/item/organ/internal/regenerative_core/organ = new /obj/item/organ/internal/regenerative_core/cooldown
	organ.insert(user)

/obj/effect/proc_holder/spell/hulk_transform/contract
	base_cooldown = HULK_COOLDOWN

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
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/summon_wealth(null))

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
	if(istype(worn,/obj/item/pda))
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
		/obj/effect/proc_holder/spell/smoke,
		/obj/effect/proc_holder/spell/emplosion,
		/obj/effect/proc_holder/spell/turf_teleport/blink,
		/obj/effect/proc_holder/spell/area_teleport/teleport,
		/obj/effect/proc_holder/spell/forcewall,
		/obj/effect/proc_holder/spell/forcewall/greater,
		/obj/effect/proc_holder/spell/aoe/conjure/timestop,
		/obj/effect/proc_holder/spell/aoe/conjure/carp,
		/obj/effect/proc_holder/spell/projectile/magic_missile,
		/obj/effect/proc_holder/spell/projectile/honk_missile,
		/obj/effect/proc_holder/spell/charge,
		/obj/effect/proc_holder/spell/aoe/conjure/creature,
		/obj/effect/proc_holder/spell/trigger/blind,
		/obj/effect/proc_holder/spell/aoe/repulse,
		/obj/effect/proc_holder/spell/sacred_flame,
		/obj/effect/proc_holder/spell/charge_up/bounce/lightning,
		/obj/effect/proc_holder/spell/summonitem,
		/obj/effect/proc_holder/spell/aoe/knock,
		/obj/effect/proc_holder/spell/aoe/conjure/legion_skulls,
		/obj/effect/proc_holder/spell/goliath_dash,
		/obj/effect/proc_holder/spell/goliath_tentacles,
		/obj/effect/proc_holder/spell/touch/healtouch/advanced,
		/obj/effect/proc_holder/spell/watchers_look,
	)

/datum/devil_contract/magic/check_contract(mob/living/carbon/human/user)
	if(!istype(user) || !user.mind)
		return FALSE
	return TRUE

/datum/devil_contract/magic/fulfill_contract(mob/living/carbon/human/user)
	var/list/spell_list = possible_magic.Copy()
	for(var/i = 1; i <= MAGIC_SPELLS_COUNT; i++)
		var/spell_type = pick_n_take(spell_list)
		var/obj/effect/proc_holder/spell/spell = new spell_type(null)
		spell.clothes_req = FALSE
		spell.cooldown_min *= 2
		spell.base_cooldown *= 2
		QDEL_NULL(spell.cooldown_handler)
		spell.cooldown_handler = spell.create_new_cooldown()
		spell.cooldown_handler.cooldown_init(spell)
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
		user.visible_message(span_notice("Внезапно вспыхнуло пламя, и [victim.declent_ru(NOMINATIVE)] [genderize_ru(victim.gender, "восстал", "восстала", "восстало", "восстали")]."))
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
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/view_range(null))

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
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/summon_friend(null))

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
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/touch/revive_touch(null))
	var/obj/effect/proc_holder/spell/lichdom/spell = new(null)
	spell.create_lich(user)
	qdel(spell)


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
	var/gun_type = safepick(GLOB.devil_guns)
	var/spell = new /obj/effect/proc_holder/spell/conjure_item/contract_gun(null, gun_type)
	user.mind.AddSpell(spell)


#undef MAGIC_SPELLS_COUNT
