/* For employment contracts and infernal contracts */

/obj/item/paper/contract
	throw_range = 3
	throw_speed = 3
	var/signed = FALSE
	var/datum/mind/target
	item_flags = NOBLUDGEON

/obj/item/paper/contract/proc/update_text()
	return

/obj/item/paper/contract/update_icon_state()
	return


/obj/item/paper/contract/employment
	icon_state = "good_contract"
	signed = TRUE

/obj/item/paper/contract/employment/New(atom/loc, mob/living/nOwner)
	. = ..()
	if(!nOwner || !nOwner.mind)
		qdel(src)
		return -1
	target = nOwner.mind
	update_text()


/obj/item/paper/contract/employment/update_text()
	name = "Документ — Трудовой договор — [target]"
	info = "<center>Условия трудоустройства</center><br><br><br><br>Настоящий Договор заключён между [target] (в дальнейшем именуемый Раб) и корпорацией НаноТрейзен (в дальнейшем именуемой Вездесущим и полезным наблюдателем за человечеством). Договор вступает в силу с момента его подписания.\
	<br>Преамбула \
	<br>Раб, будучи рождённым естественным путём человеком (или иным гуманоидом), обладает навыками, которыми он может быть полезен Вездесущему и полезному наблюдателю за человечеством. Раб ищет трудоустройства в Вездесущем и полезном наблюдателе за человечеством.\
	<br>При этом Вездесущий и полезный наблюдатель за человечеством согласен иногда выплачивать Рабу вознаграждение, в обмен на его постоянную службу.\
	<br>Настоящим, принимая во внимание вышеперечисленные взаимные выгоды и прочие соображения, стороны взаимно договариваются о нижеследующем:\
	<br>В обмен на незначительные выплаты Раб соглашается работать на Вездесущего и полезного наблюдателя за человечеством до конца своей нынешней и всех своих будущих жизней.\
	<br>Кроме того, Раб соглашается передать право на владение своей душой отделу лояльности Вездесущего и полезного наблюдателя за человечеством.\
	<br>В случае, если передача души Раба невозможна, Раб вносит вместо неё залог.<br>Подписано,<br><i>[target]</i>"

/obj/item/paper/contract/infernal
	var/datum/devil_contract/contract
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/datum/antagonist/devil/devilinfo
	var/datum/mind/owner
	icon_state = "evil_contract"
	joinable = FALSE

/obj/item/paper/contract/infernal/Initialize(atom/mapload, mob/living/nTarget, datum/mind/nOwner, datum/devil_contract/contract)
	. = ..()
	devilinfo = nOwner.has_antag_datum(/datum/antagonist/devil)
	owner = nOwner
	target = nTarget
	src.contract = contract
	name = "адский контракт [contract.contract_subject]"
	ru_names = list(
		NOMINATIVE = "адский контракт [contract.contract_subject]",
		GENITIVE = "адского контракта [contract.contract_subject]",
		DATIVE = "адскому контракту [contract.contract_subject]",
		ACCUSATIVE = "адский контракт [contract.contract_subject]",
		INSTRUMENTAL = "адским контрактом [contract.contract_subject]",
		PREPOSITIONAL = "адском контракте [contract.contract_subject]"
	)
	update_text()

/obj/item/paper/contract/infernal/suicide_act(mob/user)
	if(signed && (user == target.current) && istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.forcesay("О, ВЕЛИКИЙ АД! Я ТРЕБУЮ, ЧТОБЫ ТЫ НЕМЕДЛЕННО ЗАБРАЛ СВОЮ НАГРАДУ!")
		H.visible_message(span_suicide("[H.declent_ru(NOMINATIVE)] поднимает контракт, заявляющий права на его душу, а затем сразу же загорается. Похоже, [genderize_ru(H.gender, "Он")] пытается покончить с собой!"))
		H.adjust_fire_stacks(20)
		H.IgniteMob()
		return FIRELOSS
	else
		..()


/obj/item/paper/contract/infernal/update_text()
	var/datum/asset/simple/namespaced/contracts/contracts_asset = get_asset_datum(/datum/asset/simple/namespaced/contracts)
	info = "\
	<a href='byond://?src=[UID()];close_contract=1' class='close-button'>✖</a>\
	<link rel='stylesheet' type='text/css' href='[contracts_asset.get_url_mappings()["contract_styles.css"]]'>\
	<div class='contract-container'>\
	<div class='contract-title'>Контракт [contract.contract_subject]</div>\
	<br><br>\
	<div class='contract-text'>\
		Я, <span id='target-name'>[target]</span>, будучи в здравом уме, добровольно отдаю свою душу в адские глубины через агента \
		<span id='devil-name'>[devilinfo.info.truename]</span>[contract.contract_subject_text]. \
		Я осознаю, что после моей смерти моя душа попадёт в адские глубины, а моё тело не может быть воскрешено, клонировано \
		или иным образом возвращено к жизни. \
		Я также понимаю, что это предотвратит использование моего мозга в MMI.\
	</div>\
	<br><br>Подписано, "
	if(signed)
		info += "<div class='contract-signature'>\
					<span id='signature'>[target ? target.name : "Анонимно"]</span>\
					</div>"
	else
		info += "<a href='byond://?src=[UID()];sign_contract=1' class='sign-button'>Подписать кровью</a>"
	info +=	"</div>"

/obj/item/paper/contract/infernal/show_content(mob/user, forceshow, forcestars, infolinks, view)
	var/datum/asset/simple/namespaced/contracts/contracts_asset = get_asset_datum(/datum/asset/simple/namespaced/contracts)
	contracts_asset.send(user)
	. = ..(user, forceshow, forcestars, infolinks, view, "can_minimize=0;auto_format=0;titlebar=0;can_resize=0;")
	if(!signed)
		balloon_alert(owner.current, "контракт не подписан!")

/obj/item/paper/contract/infernal/Topic(href, href_list)
	if(href_list["sign_contract"])
		if(tgui_alert(usr, "Вы действительно хотите подписать контракт?", "Подтверждение", list("Да", "Нет")) != "Да")
			close_window(usr, "Paper[UID()]")
			balloon_alert(owner.current, "контракт не подписан!")
			return
		if(do_after(usr, 1 SECONDS, src, DA_IGNORE_LYING) && usr.mind == target \
		&& usr.mind.hasSoul && usr.mind.soulOwner != owner && attempt_signature(usr, TRUE))
			usr.visible_message(
				span_danger("[usr.declent_ru(NOMINATIVE)] [genderize_ru(usr.gender, "разрезает", "разрезает", "разрезает", "разрезают")] своё запястье [declent_ru(INSTRUMENTAL)] и [genderize_ru(usr.gender, "выводит", "выводит", "выводит", "выводят")] своё имя кровью."),
				span_danger("Ты [genderize_ru(usr.gender, "разрезаешь", "разрезаешь", "разрезаешь", "разрезаете")] своё запястье и [genderize_ru(usr.gender, "выводишь", "выводишь", "выводишь", "выводите")] своё имя кровью."),
			)
			balloon_alert(owner.current, "контракт подписан!")
			if(ishuman(usr))
				var/mob/living/carbon/human/human = usr
				human.AdjustBlood(-100)
			close_window(usr, "Paper[UID()]")
			return
	if(href_list["close_contract"])
		close_window(usr, "Paper[UID()]")
		balloon_alert(owner.current, "контракт не подписан!")
		return
	. = ..()



/obj/item/paper/contract/infernal/attackby(obj/item/I, mob/user, params)

	if(istype(I, /obj/item/stamp))
		balloon_alert(user, "печать сразу же исчезает")
		return ATTACK_CHAIN_PROCEED

	if(I.get_heat())
		user.visible_message(
			span_danger("[user] brings [I] next to [src], but it does not catch a fire!"),
			span_danger("The [name] refuses to ignite!"),
		)
		return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK

	return ..()

/obj/item/paper/contract/infernal/stamp(obj/item/stamp/stamp, no_pixel_shift, special_stamped, special_icon_state)
	return FALSE

/obj/item/paper/contract/infernal/attack(mob/living/victim, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ishuman(victim) || target != victim.mind || !victim.mind.hasSoul || victim.mind.soulOwner != victim.mind)
		return .
	. = contract.on_attack(src, target, victim, user)
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.))
		return .


/obj/item/paper/contract/infernal/proc/attempt_signature(mob/living/carbon/human/user, blood = 0)
	add_fingerprint(user)
	if(!(user.IsAdvancedToolUser() && user.is_literate()))
		to_chat(user, "<span class='notice'>You don't know how to read or write.</span>")
		return FALSE

	if(user.mind != target)
		to_chat(user,"<span class='notice'>Your signature simply slides off the sheet, it seems this contract is not meant for you to sign.</span>")
		return FALSE

	if(!user.mind.hasSoul)
		to_chat(user, span_notice("У вас нет души для продажи!"))
		return FALSE

	if(HAS_TRAIT(user.mind, TRAIT_BAD_SOUL))
		to_chat(user, span_notice("Ваша душа искажена после возвращения и не может быть продана повторно!"))
		return FALSE

	if(user.mind.soulOwner == owner)
		to_chat(user, "<span class='notice'>This devil already owns your soul, you may not sell it to them again.</span>")
		return FALSE

	if(contract.contract_type == CONTRACT_REVIVE) // :eyes:
		to_chat(user,"<span class='notice'>You are already alive, this contract would do nothing.</span>")
		return FALSE

	if(signed)
		to_chat(user,"<span class='notice'>This contract has already been signed. It may not be signed again.</span>")
		return FALSE

	to_chat(user,"<span class='notice'>You quickly scrawl your name on the contract</span>")

	if(check_contract(target.current) <= 0)
		to_chat(user,"<span class='notice'>But it seemed to have no effect, perhaps even Hell itself cannot grant this boon?</span>")

	fulfill_contract(target.current)

	return TRUE

/obj/item/paper/contract/infernal/proc/check_contract(mob/living/carbon/human/user = target.current)
	if(!user.mind)
		return FALSE

	return contract.check_contract(user)

/obj/item/paper/contract/infernal/proc/fulfill_contract(mob/living/carbon/human/user = target.current)
	signed = TRUE

	user.mind.soulOwner = owner
	user.mind.damnation_type = contract.contract_type
	devilinfo?.add_soul(user.mind)


	update_text(user.real_name)
	to_chat(user, span_notice("A profound emptiness washes over you as you lose ownership of your soul."))
	to_chat(user, span_boldnotice("This does NOT make you an antagonist if you were not already."))

	contract.fulfill_contract(user)
