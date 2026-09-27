/client/proc/referral_code_available()
	return SSdbcore.IsConnected() && has_persistent_identity() && isnum(player_age) && player_age <= REFERRAL_CODE_MAX_PLAYER_AGE_DAYS

/proc/referral_tier_by_invites(invites)
	return clamp(round(invites / REFERRAL_INVITES_PER_TIER) + DONATOR_TIER_I, DONATOR_TIER_I, DONATOR_LEVEL_MAX)

/proc/referral_rewarded_invites(referrer_ckey)
	. = 0
	var/datum/db_query/query = SSdbcore.NewQuery({"
		SELECT COUNT(*) FROM [format_table_name("referral")]
		WHERE referrer_ckey = :ckey AND rewarded = TRUE AND revoked = FALSE
	"}, list("ckey" = referrer_ckey))
	if(!query.warn_execute())
		qdel(query)
		return
	if(query.NextRow())
		. = text2num(query.item[1])
	qdel(query)

/client/proc/referral_reward_tier()
	if(!SSdbcore.IsConnected())
		return NO_DONATOR_TIER
	var/datum/db_query/query = SSdbcore.NewQuery({"
		SELECT id FROM [CONFIG_GET(string/utility_database)].[format_table_name("budget")]
		WHERE ckey = :ckey AND source = '[REFERRAL_BUDGET_SOURCE]' AND is_valid = TRUE AND date_start <= NOW() AND NOW() < date_end
		LIMIT 1
	"}, list("ckey" = account_ckey))
	if(!query.warn_execute())
		qdel(query)
		return NO_DONATOR_TIER
	var/active = query.NextRow()
	qdel(query)
	if(!active)
		return NO_DONATOR_TIER
	return referral_tier_by_invites(referral_rewarded_invites(account_ckey))

/client/proc/referral_playtime_progress()
	. = list("minutes" = 0, "days" = 0)
	var/datum/db_query/query = SSdbcore.NewQuery({"
		SELECT CAST(COALESCE(SUM(time_living), 0) AS UNSIGNED INTEGER), COUNT(*)
		FROM [format_table_name("playtime_history")]
		WHERE ckey = :ckey AND time_living > 0
	"}, list("ckey" = account_ckey))
	if(!query.warn_execute())
		qdel(query)
		return
	if(query.NextRow())
		.["minutes"] = text2num(query.item[1])
		.["days"] = text2num(query.item[2])
	qdel(query)

/client/proc/referral_shares_hardware(other_ckey)
	var/datum/db_query/query = SSdbcore.NewQuery({"
		SELECT mine.id
		FROM [format_table_name("connection_log")] AS mine
		INNER JOIN [format_table_name("connection_log")] AS theirs ON mine.ip = theirs.ip OR mine.computerid = theirs.computerid
		WHERE mine.ckey = :ckey AND theirs.ckey = :other_ckey
		LIMIT 1
	"}, list("ckey" = account_ckey, "other_ckey" = other_ckey))
	if(!query.warn_execute())
		qdel(query)
		return TRUE
	. = query.NextRow()
	qdel(query)

/client/proc/apply_referral_code(referral_key)
	if(!COOLDOWN_FINISHED(src, referral_apply_cooldown))
		return "Слишком часто, подождите немного."
	COOLDOWN_START(src, referral_apply_cooldown, 5 SECONDS)
	if(!referral_code_available())
		return "Код принимается только в первые [REFERRAL_CODE_MAX_PLAYER_AGE_DAYS] дней после первого захода на сервер."
	if(!prefs?.discord_id || length(prefs.discord_id) == 32)
		return "Сначала привяжите аккаунт Discord."
	var/referrer_ckey = ckey(referral_key)
	if(!referrer_ckey)
		return "Введите код приглашения."
	if(referrer_ckey == account_ckey)
		return "Нельзя пригласить самого себя."

	var/datum/db_query/query_used = SSdbcore.NewQuery({"
		SELECT referred_ckey FROM [format_table_name("referral")]
		WHERE referred_ckey = :ckey OR referred_discord_id = :discord_id
		LIMIT 1
	"}, list("ckey" = account_ckey, "discord_id" = prefs.discord_id))
	if(!query_used.warn_execute())
		qdel(query_used)
		return "Ошибка базы данных, попробуйте позже."
	if(query_used.NextRow())
		var/used_by_self = query_used.item[1] == account_ckey
		qdel(query_used)
		return used_by_self ? "Вы уже воспользовались реферальным кодом." : "Этот аккаунт Discord уже участвовал в реферальной программе."
	qdel(query_used)

	var/datum/db_query/query_referrer = SSdbcore.NewQuery({"
		SELECT
			(SELECT CAST(COALESCE(SUM(time_living), 0) AS UNSIGNED INTEGER) FROM [format_table_name("playtime_history")] WHERE ckey = :referrer_ckey),
			(SELECT COUNT(*) FROM [format_table_name("referral")] WHERE referrer_ckey = :referrer_ckey AND `date` > NOW() - INTERVAL [REFERRAL_LIMIT_PERIOD_DAYS] DAY)
		FROM [format_table_name("player")] WHERE ckey = :referrer_ckey
	"}, list("referrer_ckey" = referrer_ckey))
	if(!query_referrer.warn_execute())
		qdel(query_referrer)
		return "Ошибка базы данных, попробуйте позже."
	if(!query_referrer.NextRow())
		qdel(query_referrer)
		return "Игрок с таким кодом не найден."
	var/referrer_minutes = text2num(query_referrer.item[1])
	var/referrer_invites = text2num(query_referrer.item[2])
	qdel(query_referrer)
	if(referrer_minutes < REFERRAL_REFERRER_MIN_MINUTES)
		return "Этот игрок наиграл слишком мало времени, чтобы приглашать других."
	if(referrer_invites >= REFERRAL_LIMIT_PER_PERIOD)
		return "Этот игрок исчерпал лимит приглашений на этот месяц."

	var/datum/db_query/query_alts = SSdbcore.NewQuery({"
		SELECT ckey FROM [format_table_name("connection_log")]
		WHERE computerid = :computerid AND ckey != :ckey
		LIMIT 1
	"}, list("computerid" = computer_id, "ckey" = account_ckey))
	if(!query_alts.warn_execute())
		qdel(query_alts)
		return "Ошибка базы данных, попробуйте позже."
	if(query_alts.NextRow())
		qdel(query_alts)
		return "С этого компьютера уже заходили под другим аккаунтом, код недоступен."
	qdel(query_alts)

	if(referral_shares_hardware(referrer_ckey))
		return "Пригласивший и приглашённый не могут играть с одного компьютера или адреса."

	var/datum/db_query/query_insert = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("referral")] (referred_ckey, referrer_ckey, referred_ip, referred_computerid, referred_discord_id)
		VALUES (:ckey, :referrer_ckey, :ip, :computerid, :discord_id)
	"}, list(
		"ckey" = account_ckey,
		"referrer_ckey" = referrer_ckey,
		"ip" = address,
		"computerid" = computer_id,
		"discord_id" = prefs.discord_id
	))
	if(!query_insert.warn_execute())
		qdel(query_insert)
		return "Ошибка базы данных, попробуйте позже."
	qdel(query_insert)
	log_game("[key_name(src)] entered the referral code of [referrer_ckey].")
	return null

/client/proc/referral_payout_check()
	if(!SSdbcore.IsConnected() || !has_persistent_identity())
		return
	var/datum/db_query/query_pending = SSdbcore.NewQuery({"
		SELECT referrer_ckey FROM [format_table_name("referral")]
		WHERE referred_ckey = :ckey AND rewarded = FALSE AND revoked = FALSE
	"}, list("ckey" = account_ckey))
	if(!query_pending.warn_execute())
		qdel(query_pending)
		return
	var/referrer_ckey
	if(query_pending.NextRow())
		referrer_ckey = query_pending.item[1]
	qdel(query_pending)
	if(!referrer_ckey)
		return

	var/list/progress = referral_playtime_progress()
	if(progress["minutes"] < REFERRAL_REQUIRED_MINUTES || progress["days"] < REFERRAL_REQUIRED_DAYS)
		return

	if(referral_shares_hardware(referrer_ckey))
		var/datum/db_query/query_revoke = SSdbcore.NewQuery({"
			UPDATE [format_table_name("referral")] SET revoked = TRUE
			WHERE referred_ckey = :ckey AND rewarded = FALSE
		"}, list("ckey" = account_ckey))
		query_revoke.warn_execute()
		qdel(query_revoke)
		log_admin("Referral: [key_name(src)] shares a computer or address with [referrer_ckey], reward denied.")
		message_admins("Referral: [key_name_admin(src)] shares a computer or address with [referrer_ckey], reward denied.")
		return

	var/datum/db_query/query_claim = SSdbcore.NewQuery({"
		UPDATE [format_table_name("referral")] SET rewarded = TRUE, reward_date = NOW()
		WHERE referred_ckey = :ckey AND rewarded = FALSE AND revoked = FALSE
	"}, list("ckey" = account_ckey))
	if(!query_claim.warn_execute() || !query_claim.affected)
		qdel(query_claim)
		return
	qdel(query_claim)

	if(!grant_referral_reward(referrer_ckey))
		log_debug("referral_payout_check: failed to grant the reward of [account_ckey] to [referrer_ckey]")
		return
	log_admin("Referral: [key_name(src)] earned a subscription tier for [referrer_ckey].")
	message_admins("Referral: [key_name_admin(src)] earned a subscription tier for [referrer_ckey].")
	to_chat(src, custom_boxed_message("green_box", span_darkmblue("Вы наиграли достаточно времени — пригласивший вас <b>[referrer_ckey]</b> получил уровень подписки. Спасибо, что остались с нами!")), confidential = TRUE)

/proc/grant_referral_reward(referrer_ckey)
	var/invites = referral_rewarded_invites(referrer_ckey)
	var/tier = referral_tier_by_invites(invites)
	var/tier_up = tier > referral_tier_by_invites(invites - 1)

	var/datum/db_query/query_active = SSdbcore.NewQuery({"
		SELECT id FROM [CONFIG_GET(string/utility_database)].[format_table_name("budget")]
		WHERE ckey = :ckey AND source = '[REFERRAL_BUDGET_SOURCE]' AND is_valid = TRUE AND NOW() < date_end
		ORDER BY date_end DESC
		LIMIT 1
	"}, list("ckey" = referrer_ckey))
	if(!query_active.warn_execute())
		qdel(query_active)
		return FALSE
	var/reward_id
	if(query_active.NextRow())
		reward_id = query_active.item[1]
	qdel(query_active)

	var/datum/db_query/query_reward
	if(!reward_id)
		query_reward = SSdbcore.NewQuery({"
			INSERT INTO [CONFIG_GET(string/utility_database)].[format_table_name("budget")] (ckey, amount, source, date_start, date_end)
			VALUES (:ckey, 0, '[REFERRAL_BUDGET_SOURCE]', NOW(), NOW() + INTERVAL [REFERRAL_REWARD_DAYS] DAY)
		"}, list("ckey" = referrer_ckey))
	else if(tier_up)
		query_reward = SSdbcore.NewQuery({"
			UPDATE [CONFIG_GET(string/utility_database)].[format_table_name("budget")]
			SET date_start = NOW(), date_end = NOW() + INTERVAL [REFERRAL_REWARD_DAYS] DAY
			WHERE id = :id
		"}, list("id" = reward_id))
	else
		query_reward = SSdbcore.NewQuery({"
			UPDATE [CONFIG_GET(string/utility_database)].[format_table_name("budget")]
			SET date_end = LEAST(date_end + INTERVAL [REFERRAL_REWARD_DAYS] DAY, NOW() + INTERVAL [REFERRAL_REWARD_MAX_DAYS] DAY)
			WHERE id = :id
		"}, list("id" = reward_id))
	. = query_reward.warn_execute()
	qdel(query_reward)
	if(!.)
		return

	var/client/referrer = GLOB.directory[referrer_ckey]
	if(!referrer)
		return
	referrer.donator_check()
	var/reward_message = "Вам начислено [REFERRAL_REWARD_DAYS] дней подписки [tier] уровня."
	if(tier_up)
		reward_message = "Ваш уровень подписки повышен до <b>[tier]</b>!<br>Срок начислен заново — [REFERRAL_REWARD_DAYS] дней."
	to_chat(referrer, custom_boxed_message("green_box", span_darkmblue("Приглашённый вами игрок освоился на станции!<br>[reward_message]")), confidential = TRUE)

/client/proc/referral_stats()
	referral_payout_check()
	. = list(
		"code" = account_ckey,
		"can_enter" = referral_code_available(),
		"discord_linked" = !!(prefs?.discord_id && length(prefs.discord_id) != 32),
		"referrer" = null,
		"rewarded" = FALSE,
		"revoked" = FALSE,
		"minutes" = 0,
		"days" = 0,
		"invited" = 0,
		"invited_rewarded" = 0,
		"active_until" = null,
		"required_minutes" = REFERRAL_REQUIRED_MINUTES,
		"required_days" = REFERRAL_REQUIRED_DAYS,
		"max_player_age" = REFERRAL_CODE_MAX_PLAYER_AGE_DAYS,
		"reward_days" = REFERRAL_REWARD_DAYS,
		"referrer_min_hours" = round(REFERRAL_REFERRER_MIN_MINUTES / 60),
		"invites_per_tier" = REFERRAL_INVITES_PER_TIER,
		"tier" = NO_DONATOR_TIER
	)

	var/datum/db_query/query_mine = SSdbcore.NewQuery({"
		SELECT referrer_ckey, rewarded, revoked FROM [format_table_name("referral")]
		WHERE referred_ckey = :ckey
	"}, list("ckey" = account_ckey))
	if(query_mine.warn_execute() && query_mine.NextRow())
		.["referrer"] = query_mine.item[1]
		.["rewarded"] = !!text2num(query_mine.item[2])
		.["revoked"] = !!text2num(query_mine.item[3])
	qdel(query_mine)

	if(.["referrer"] && !.["rewarded"] && !.["revoked"])
		var/list/progress = referral_playtime_progress()
		.["minutes"] = progress["minutes"]
		.["days"] = progress["days"]

	var/datum/db_query/query_invited = SSdbcore.NewQuery({"
		SELECT COUNT(*), CAST(COALESCE(SUM(rewarded), 0) AS UNSIGNED INTEGER) FROM [format_table_name("referral")]
		WHERE referrer_ckey = :ckey AND revoked = FALSE
	"}, list("ckey" = account_ckey))
	if(query_invited.warn_execute() && query_invited.NextRow())
		.["invited"] = text2num(query_invited.item[1])
		.["invited_rewarded"] = text2num(query_invited.item[2])
		if(.["invited_rewarded"])
			.["tier"] = referral_tier_by_invites(.["invited_rewarded"])
	qdel(query_invited)

	var/datum/db_query/query_reward = SSdbcore.NewQuery({"
		SELECT DATE_FORMAT(MAX(date_end), '%d.%m.%Y') FROM [CONFIG_GET(string/utility_database)].[format_table_name("budget")]
		WHERE ckey = :ckey AND source = '[REFERRAL_BUDGET_SOURCE]' AND is_valid = TRUE AND NOW() < date_end
	"}, list("ckey" = account_ckey))
	if(query_reward.warn_execute() && query_reward.NextRow())
		.["active_until"] = query_reward.item[1]
	qdel(query_reward)

GAME_VERB_DESC(/client, referral_panel, "Реферальная система", "Пригласить друга на сервер и получить за это уровень подписки.", VERB_CATEGORY_SPECIALVERBS)
	if(!SSdbcore.IsConnected())
		to_chat(usr, span_warning("База данных недоступна, попробуйте позже."), confidential = TRUE)
		return
	if(!has_persistent_identity())
		to_chat(usr, span_warning("Гостевой аккаунт не может участвовать в реферальной программе."), confidential = TRUE)
		return
	var/datum/ui_module/referrals/panel = new()
	panel.ui_interact(usr)
