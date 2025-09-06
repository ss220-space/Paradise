GLOBAL_DATUM_INIT(stun_words, /regex, regex("stop|wait|stand still|hold on|halt|стой|стоп|не двигайся|замри|стой|оглушись"))
GLOBAL_DATUM_INIT(weaken_words, /regex, regex("drop|fall|trip|упади|ослабни|пади"))
GLOBAL_DATUM_INIT(sleep_words, /regex, regex("sleep|slumber|засни|усни|спать|спи"))
GLOBAL_DATUM_INIT(vomit_words, /regex, regex("vomit|throw up|рви|блюй"))
GLOBAL_DATUM_INIT(silence_words, /regex, regex("shut up|silence|ssh|quiet|hush|заткнись|молчать|тишина|тихо"))
GLOBAL_DATUM_INIT(hallucinate_words, /regex, regex("see the truth|hallucinate|увидь истину|галлюцинируй"))
GLOBAL_DATUM_INIT(wakeup_words, /regex, regex("wake up|awaken|проснись|очнись"))
GLOBAL_DATUM_INIT(heal_words, /regex, regex("live|heal|survive|mend|heroes never die|живи|исцелись|выживи|залечись"))
GLOBAL_DATUM_INIT(hurt_words, /regex, regex("die|suffer|умри|страдай|познай боль"))
GLOBAL_DATUM_INIT(bleed_words, /regex, regex("bleed|кровоточи"))
GLOBAL_DATUM_INIT(burn_words, /regex, regex("burn|ignite|гори|воспламенись|загорись"))
GLOBAL_DATUM_INIT(repulse_words, /regex, regex("shoo|go away|leave me alone|begone|flee|fus ro dah|прочь|уйди|отстань|исчезни|отвали"))
GLOBAL_DATUM_INIT(whoareyou_words, /regex, regex("who are you|say your name|state your name|identify|кто ты|назовись|представься"))
GLOBAL_DATUM_INIT(saymyname_words, /regex, regex("say my name|скажи моё имя"))
GLOBAL_DATUM_INIT(knockknock_words, /regex, regex("knock knock|тук-тук"))
GLOBAL_DATUM_INIT(statelaws_words, /regex, regex("state laws|state your laws|озвучь законы|перечисли законы"))
GLOBAL_DATUM_INIT(move_words, /regex, regex("move|двигайся|иди|ступай"))
GLOBAL_DATUM_INIT(walk_words, /regex, regex("walk|slow down|ходи|медленнее"))
GLOBAL_DATUM_INIT(run_words, /regex, regex("run|беги"))
GLOBAL_DATUM_INIT(helpintent_words, /regex, regex("help|помогай|помоги"))
GLOBAL_DATUM_INIT(disarmintent_words, /regex, regex("disarm|обезоружь"))
GLOBAL_DATUM_INIT(grabintent_words, /regex, regex("grab|схвати|хватай"))
GLOBAL_DATUM_INIT(harmintent_words, /regex, regex("harm|fight|атакуй|дерись|навреди"))
GLOBAL_DATUM_INIT(throwmode_words, /regex, regex("throw|catch|бросай|лови|брось|поймай"))
GLOBAL_DATUM_INIT(flip_words, /regex, regex("flip|rotate|revolve|roll|somersault|крутись|вертись|перевернись|кувыркнись"))
GLOBAL_DATUM_INIT(rest_words, /regex, regex("rest|отдыхай"))
GLOBAL_DATUM_INIT(getup_words, /regex, regex("get up|встань|вставай"))
GLOBAL_DATUM_INIT(sit_words, /regex, regex("sit|садись|сядь"))
GLOBAL_DATUM_INIT(stand_words, /regex, regex("stand|стой|встань"))
GLOBAL_DATUM_INIT(dance_words, /regex, regex("dance|танцуй"))
GLOBAL_DATUM_INIT(jump_words, /regex, regex("jump|прыгай"))
GLOBAL_DATUM_INIT(salute_words, /regex, regex("salute|отдай честь|салютуй"))
GLOBAL_DATUM_INIT(deathgasp_words, /regex, regex("play dead|притворись мёртвым"))
GLOBAL_DATUM_INIT(clap_words, /regex, regex("clap|applaud|хлопай|аплодируй"))
GLOBAL_DATUM_INIT(honk_words, /regex, regex("ho+nk|хонк")) //hooooooonk
GLOBAL_DATUM_INIT(multispin_words, /regex, regex("like a record baby|как пластинка, детка"))

/obj/item/organ/internal/vocal_cords //organs that are activated through speech with the :x channel
	name = "vocal cords"
	ru_names = list(
		NOMINATIVE = "голосовые связки",
		GENITIVE = "голосовых связок",
		DATIVE = "голосовым связкам",
		ACCUSATIVE = "голосовые связки",
		INSTRUMENTAL = "голосовыми связками",
		PREPOSITIONAL = "голосовых связках"
	)
	icon_state = "appendix"
	slot = INTERNAL_ORGAN_VOCALCORDS
	parent_organ_zone = BODY_ZONE_PRECISE_MOUTH
	var/spans = null

/obj/item/organ/internal/vocal_cords/proc/can_speak_with() //if there is any limitation to speaking with these cords
	return TRUE

/obj/item/organ/internal/vocal_cords/proc/speak_with(message) //do what the organ does
	return

/obj/item/organ/internal/vocal_cords/proc/handle_speech(list/message_pieces) //change the message
	return message_pieces

/obj/item/organ/internal/adamantine_resonator
	name = "adamantine resonator"
	desc = "Частицы адамантина присутствуют во всех големах, унаследованные от их магической природы. Позволяют \"слышать\" послания своих создателей."
	ru_names = list(
		NOMINATIVE = "адамантиновый резонатор",
		GENITIVE = "адамантинового резонатора",
		DATIVE = "адамантиновому резонатору",
		ACCUSATIVE = "адамантиновый резонатор",
		INSTRUMENTAL = "адамантиновым резонатором",
		PREPOSITIONAL = "адамантиновом резонаторе"
	)
	parent_organ_zone = BODY_ZONE_HEAD
	slot = INTERNAL_ORGAN_RESONATOR
	icon_state = "adamantine_resonator"

/obj/item/organ/internal/vocal_cords/adamantine
	name = "adamantine vocal cords"
	desc = "При резонансе адамантина все ближайшие частицы входят в синхронизацию. Големы используют это для передачи сообщений сородичам."
	ru_names = list(
		NOMINATIVE = "адамантиновые голосовые связки",
		GENITIVE = "адамантиновых голосовых связок",
		DATIVE = "адамантиновым голосовым связкам",
		ACCUSATIVE = "адамантиновые голосовые связки",
		INSTRUMENTAL = "адамантиновыми голосовыми связками",
		PREPOSITIONAL = "адамантиновых голосовых связках"
	)
	actions_types = list(/datum/action/item_action/organ_action/use/adamantine_vocal_cords)
	icon_state = "adamantine_cords"

/datum/action/item_action/organ_action/use/adamantine_vocal_cords/Trigger(left_click = TRUE)
	if(!IsAvailable())
		return
	var/message = tgui_input_text(owner, "Отправить резонирующее сообщение всем ближайшим големам.", "Резонанс")
	if(QDELETED(src) || QDELETED(owner) || !message)
		return
	owner.say(".~[message]")

/obj/item/organ/internal/vocal_cords/adamantine/handle_speech(list/message_pieces)
	var/msg = span_resonate(span_name(owner.real_name) [span_message("резонирует: \"[capitalize(multilingual_to_message(message_pieces))]\"")])
	for(var/m in GLOB.player_list)
		if(iscarbon(m))
			var/mob/living/carbon/C = m
			if(C.get_organ_slot(INTERNAL_ORGAN_RESONATOR))
				to_chat(C, msg)

//Colossus drop, forces the listeners to obey certain commands
/obj/item/organ/internal/vocal_cords/colossus
	name = "divine vocal cords"
	desc = "Они несут глас древнего бога."
	ru_names = list(
		NOMINATIVE = "связки бога",
		GENITIVE = "связок бога",
		DATIVE = "связкам бога",
		ACCUSATIVE = "связки бога",
		INSTRUMENTAL = "связками бога",
		PREPOSITIONAL = "связках бога"
	)
	icon_state = "voice_of_god"
	actions_types = list(/datum/action/item_action/organ_action/colossus)
	var/next_command = 0
	var/cooldown_stun = 1200
	var/cooldown_damage = 600
	var/cooldown_meme = 300
	var/cooldown_none = 150
	var/base_multiplier = 1
	spans = "colossus yell"

/datum/action/item_action/organ_action/colossus
	name = "Глас Божий"
	var/obj/item/organ/internal/vocal_cords/colossus/cords = null

/datum/action/item_action/organ_action/colossus/New()
	..()
	cords = target


/datum/action/item_action/organ_action/colossus/IsAvailable()
	. = ..()
	if(!.)
		return .
	if(world.time < cords.next_command)
		return FALSE
	if(!owner.can_speak())
		return FALSE


/datum/action/item_action/organ_action/colossus/Trigger(left_click = TRUE)
	. = ..()
	if(!IsAvailable())
		if(world.time < cords.next_command)
			to_chat(owner, span_notice("Вы должны подождать ещё [(cords.next_command - world.time)/10] сек. перед следующим Словом."))
		return
	var/command = tgui_input_text(owner, "Изречь Глас Божий", "Команда")
	if(!command)
		return
	owner.say(".~[command]")

/obj/item/organ/internal/vocal_cords/colossus/prepare_eat()
	return

/obj/item/organ/internal/vocal_cords/colossus/can_speak_with()
	if(world.time < next_command)
		to_chat(owner, span_notice("Вы должны подождать [(next_command - world.time)/10] секунд[declension_ru((next_command - world.time)/10, "у", "ы", "")] перед следующим Словом."))
		return FALSE
	if(!owner)
		return FALSE
	if(!owner.can_speak())
		to_chat(owner, span_warning("Вы не можете говорить!"))
		return FALSE
	if(owner.stat)
		return FALSE
	return TRUE


/obj/item/organ/internal/vocal_cords/colossus/handle_speech(list/message_pieces)
	return ..(message_to_multilingual(uppertext(multilingual_to_message(message_pieces)), GLOB.all_languages[LANGUAGE_ANGEL]))


/obj/item/organ/internal/vocal_cords/colossus/speak_with(message)
	var/log_message = uppertext(message)
	message = lowertext(message)
	playsound(get_turf(owner), 'sound/magic/invoke_general.ogg', 300, TRUE, 5)

	var/list/mob/living/listeners = list()
	for(var/mob/living/L in get_mobs_in_view(8, owner, TRUE, FALSE))
		if(L.can_hear() && !L.null_rod_check() && L != owner && L.stat != DEAD)
			if(ishuman(L))
				var/mob/living/carbon/human/H = L
				if(H.check_ear_prot() >= HEARING_PROTECTION_TOTAL)
					continue
			listeners += L

	if(!listeners.len)
		next_command = world.time + cooldown_none
		return

	var/power_multiplier = base_multiplier

	if(owner.mind)
		//Holy characters are very good at speaking with the voice of god
		if(owner.mind.isholy)
			power_multiplier *= 2
		//Command staff has authority
		if(owner.mind.assigned_role in GLOB.command_positions)
			power_multiplier *= 1.4
		//Why are you speaking
		if(owner.mind.assigned_role == JOB_TITLE_MIME)
			power_multiplier *= 0.5

	//Cultists are closer to their gods and are more powerful, but they'll give themselves away
	if(iscultist(owner))
		power_multiplier *= 2

	//Try to check if the speaker specified a name or a job to focus on
	var/list/specific_listeners = list()
	var/found_string = null

	for(var/V in listeners)
		var/mob/living/L = V
		var/datum/antagonist/devil/devilinfo = L.mind?.has_antag_datum(/datum/antagonist/devil)

		if(devilinfo && findtext(message, devilinfo?.info.truename))
			var/start = findtext(message, devilinfo.info.truename)
			listeners = list(L) // let's be honest you're never going to find two devils with the same name
			power_multiplier *= 5 // if you're a devil and god himself addressed you, you fucked up
			// Cut out the name so it doesn't trigger commands
			message = copytext(message, 0, start)+copytext(message, start + length(devilinfo.info.truename), LAZYLEN(message) + 1)

		if(findtext(message, L.real_name) == 1)
			specific_listeners += L //focus on those with the specified name
			//Cut out the name so it doesn't trigger commands
			found_string = L.real_name

		else if(L.mind && findtext(message, L.mind.assigned_role) == 1)
			specific_listeners += L //focus on those with the specified job
			//Cut out the job so it doesn't trigger commands
			found_string = L.mind.assigned_role

	if(specific_listeners.len)
		listeners = specific_listeners
		power_multiplier *= (1 + (1/specific_listeners.len)) //2x on a single guy, 1.5x on two and so on
		message = copytext(message, 0, 1)+copytext(message, 1 + length(found_string), length(message) + 1)

	//STUN
	if(findtext(message, GLOB.stun_words))
		for(var/V in listeners)
			var/mob/living/L = V
			L.Stun(6 SECONDS * power_multiplier)
		next_command = world.time + cooldown_stun

	//WEAKEN
	else if(findtext(message, GLOB.weaken_words))
		for(var/V in listeners)
			var/mob/living/L = V
			L.Weaken(6 SECONDS * power_multiplier)
		next_command = world.time + cooldown_stun

	//SLEEP
	else if((findtext(message, GLOB.sleep_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.Sleeping(4 SECONDS * power_multiplier)
		next_command = world.time + cooldown_stun

	//VOMIT
	else if((findtext(message, GLOB.vomit_words)))
		for(var/mob/living/carbon/C in listeners)
			C.vomit(10 * power_multiplier)
		next_command = world.time + cooldown_stun

	//SILENCE
	else if((findtext(message, GLOB.silence_words)))
		for(var/mob/living/carbon/C in listeners)
			if(owner.mind && (owner.mind.assigned_role == JOB_TITLE_LIBRARIAN || owner.mind.assigned_role == JOB_TITLE_MIME))
				power_multiplier *= 3
			C.AdjustSilence(20 SECONDS * power_multiplier)
		next_command = world.time + cooldown_stun

	//HALLUCINATE
	else if((findtext(message, GLOB.hallucinate_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			new /obj/effect/hallucination/delusion(get_turf(L),L,duration=150 * power_multiplier,skip_nearby=0)
		next_command = world.time + cooldown_meme

	//WAKE UP
	else if((findtext(message, GLOB.wakeup_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.SetSleeping(0)
		next_command = world.time + cooldown_damage

	//HEAL
	else if((findtext(message, GLOB.heal_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.heal_overall_damage(10 * power_multiplier, 10 * power_multiplier, TRUE, 0, 0)
		next_command = world.time + cooldown_damage

	//BRUTE DAMAGE
	else if((findtext(message, GLOB.hurt_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.apply_damage(15 * power_multiplier, def_zone = BODY_ZONE_CHEST)
		next_command = world.time + cooldown_damage

	//BLEED
	else if((findtext(message, GLOB.bleed_words)))
		for(var/mob/living/carbon/human/H in listeners)
			H.bleed_rate += (5 * power_multiplier)
		next_command = world.time + cooldown_damage

	//FIRE
	else if((findtext(message, GLOB.burn_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.adjust_fire_stacks(1 * power_multiplier)
			L.IgniteMob()
		next_command = world.time + cooldown_damage

	//REPULSE
	else if((findtext(message, GLOB.repulse_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			var/throwtarget = get_edge_target_turf(owner, get_dir(owner, get_step_away(L, owner)))
			L.throw_at(throwtarget, 3 * power_multiplier, 1)
		next_command = world.time + cooldown_damage

	//WHO ARE YOU?
	else if((findtext(message, GLOB.whoareyou_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			/*if(L.mind && L.mind.devilinfo)
				L.say("[L.mind.devilinfo.truename]")
			else*/
			L.say("[L.real_name]")
		next_command = world.time + cooldown_meme

	//SAY MY NAME
	else if((findtext(message, GLOB.saymyname_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.say("[owner.name]!") //"Unknown!"
		next_command = world.time + cooldown_meme

	//KNOCK KNOCK
	else if((findtext(message, GLOB.knockknock_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.say("Who's there?")
		next_command = world.time + cooldown_meme

	//STATE LAWS
	else if((findtext(message, GLOB.statelaws_words)))
		for(var/mob/living/silicon/S in listeners)
			S.statelaws(S.laws)
		next_command = world.time + cooldown_stun

	//MOVE
	else if((findtext(message, GLOB.move_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			step(L, pick(GLOB.cardinal))
		next_command = world.time + cooldown_meme

	//WALK
	else if((findtext(message, GLOB.walk_words)))
		for(var/mob/living/listener as anything in listeners)
			listener.toggle_move_intent(MOVE_INTENT_WALK)
		next_command = world.time + cooldown_meme

	//RUN
	else if((findtext(message, GLOB.run_words)))
		for(var/mob/living/listener as anything in listeners)
			listener.toggle_move_intent(MOVE_INTENT_RUN)
		next_command = world.time + cooldown_meme

	//HELP INTENT
	else if((findtext(message, GLOB.helpintent_words)))
		for(var/mob/living/carbon/human/H in listeners)
			H.a_intent_change(INTENT_HELP)
		next_command = world.time + cooldown_meme

	//DISARM INTENT
	else if((findtext(message, GLOB.disarmintent_words)))
		for(var/mob/living/carbon/human/H in listeners)
			H.a_intent_change(INTENT_DISARM)
		next_command = world.time + cooldown_meme

	//GRAB INTENT
	else if((findtext(message, GLOB.grabintent_words)))
		for(var/mob/living/carbon/human/H in listeners)
			H.a_intent_change(INTENT_GRAB)
		next_command = world.time + cooldown_meme

	//HARM INTENT
	else if((findtext(message, GLOB.harmintent_words)))
		for(var/mob/living/carbon/human/H in listeners)
			H.a_intent_change(INTENT_HARM)
		next_command = world.time + cooldown_meme

	//THROW/CATCH
	else if((findtext(message, GLOB.throwmode_words)))
		for(var/mob/living/carbon/C in listeners)
			C.throw_mode_on()
		next_command = world.time + cooldown_meme

	//FLIP
	else if((findtext(message, GLOB.flip_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("flip")
		next_command = world.time + cooldown_meme

	//REST
	else if((findtext(message, GLOB.rest_words)))
		for(var/mob/living/listener as anything in listeners)
			listener.set_resting(TRUE, instant = TRUE)
		next_command = world.time + cooldown_meme

	//GET UP
	else if((findtext(message, GLOB.getup_words)))
		for(var/mob/living/listener as anything in listeners)
			listener.SetStunned(0)
			listener.SetWeakened(0)
			listener.SetKnockdown(0)
			listener.SetParalysis(0) //i said get up i don't care if you're being tazed
			listener.set_resting(FALSE, instant = TRUE)
			listener.get_up(instant = TRUE)
		next_command = world.time + cooldown_damage

	//SIT
	else if((findtext(message, GLOB.sit_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			for(var/obj/structure/chair/chair in get_turf(L))
				chair.buckle_mob(L)
				break
		next_command = world.time + cooldown_meme

	//STAND UP
	else if((findtext(message, GLOB.stand_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			if(L.buckled && istype(L.buckled, /obj/structure/chair))
				L.buckled.unbuckle_mob(L)
		next_command = world.time + cooldown_meme

	//DANCE
	else if((findtext(message, GLOB.dance_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("dance")
		next_command = world.time + cooldown_meme

	//JUMP
	else if((findtext(message, GLOB.jump_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.say("НАСКОЛЬКО ВЫСОКО?!!")
			L.emote("jump")
		next_command = world.time + cooldown_meme

	//SALUTE
	else if((findtext(message, GLOB.salute_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("salute")
		next_command = world.time + cooldown_meme

	//PLAY DEAD
	else if((findtext(message, GLOB.deathgasp_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("deathgasp")
		next_command = world.time + cooldown_meme

	//PLEASE CLAP
	else if((findtext(message, GLOB.clap_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("clap")
		next_command = world.time + cooldown_meme

	//HONK
	else if((findtext(message, GLOB.honk_words)))
		spawn(25)
			playsound(get_turf(owner), 'sound/items/bikehorn.ogg', 300, TRUE)
		if(owner.mind && owner.mind.assigned_role == JOB_TITLE_CLOWN)
			for(var/mob/living/carbon/C in listeners)
				C.slip(14 SECONDS * power_multiplier)
			next_command = world.time + cooldown_stun
		else
			next_command = world.time + cooldown_meme

	//RIGHT ROUND
	else if((findtext(message, GLOB.multispin_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.SpinAnimation(speed = 10, loops = 5)
		next_command = world.time + cooldown_meme

	else
		next_command = world.time + cooldown_none

	message_admins("[ADMIN_LOOKUPFLW(owner)] has said '[log_message]' with a Voice of God, affecting [english_list(listeners)], with a power multiplier of [power_multiplier].")
	add_game_logs("has said '[log_message]' with a Voice of God, affecting [english_list(listeners)], with a power multiplier of [power_multiplier].", owner)
