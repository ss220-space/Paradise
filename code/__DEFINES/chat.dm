/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/// How many chat payloads to keep in history
#define CHAT_RELIABILITY_HISTORY_SIZE 5
/// How many resends to allow before giving up
#define CHAT_RELIABILITY_MAX_RESENDS 3

#define MESSAGE_TYPE_SYSTEM "system"
#define MESSAGE_TYPE_LOCALCHAT "localchat"
#define MESSAGE_TYPE_RADIO "radio"
#define MESSAGE_TYPE_INFO "info"
#define MESSAGE_TYPE_WARNING "warning"
#define MESSAGE_TYPE_DEADCHAT "deadchat"
#define MESSAGE_TYPE_OOC "ooc"
#define MESSAGE_TYPE_ADMINPM "adminpm"
#define MESSAGE_TYPE_MENTORPM "mentorpm"
#define MESSAGE_TYPE_COMBAT "combat"
#define MESSAGE_TYPE_ADMINCHAT "adminchat"
#define MESSAGE_TYPE_MENTORCHAT "mentorchat"
#define MESSAGE_TYPE_DEVCHAT "devchat"
#define MESSAGE_TYPE_EVENTCHAT "eventchat"
#define MESSAGE_TYPE_ADMINLOG "adminlog"
#define MESSAGE_TYPE_ATTACKLOG "attacklog"
#define MESSAGE_TYPE_DEBUG "debug"


GLOBAL_LIST_INIT(twitch_bad_words_lazy, list(
	"негр", "ниге", "нигге", "нигу", "ниггу", "ниги", "нигги", "nig",
	"пидор", "педик", "гомик", "fag",
	"даун", "аутист", "ватни",
	"кукол",
	"моска",
	"хох",
	"хач",
	"жид",
	"симп",
	"инце",
	"девств",
	"хиджаб",
))

/*
GLOBAL_LIST_INIT(twitch_bad_words, list(
	list("негра", "нигера", "ниггера", "ниги", "нигу", "ниггу") = "чёрнокожего",
	list("негру", "нигеру", "ниггеру", "ниге") = "чёрнокожему",
	list("негром", "нигером", "ниггером", "нигой") = "чёрнокожим",
	list("негре", "нигере", "ниггере") = "чёрнокожем",
	list("негр", "нигер", "ниггер", "нига", "nigger") = "чёрнокожий",

	list("пидора", "пидораса", "педика", "гомика", "петуха") = "мужеложца",
	list("пидору", "пидорасу", "педику", "гомику", "петуху") = "мужеложцу",
	list("пидором", "пидорасом", "педиком", "гомиком", "петухом") = "мужеложцем",
	list("пидоре", "пидорасе", "педике", "гомике", "петухе") = "мужеложце",
	list("пидор", "пидорас", "педик", "гомик", "петух", "faggot") = "мужеложец",

	list("даун", "аутист", "ватник") = "дурак", // The declension by cases will be preserved.

	list("куколд") = "наблюдатель",
	list("куколда") = "наблюдателя",
	list("куколду") = "наблюдателю",
	list("куколдом") = "наблюдателем",
	list("куколде") = "наблюдателе",

	list("москаль") = "русский",
	list("москаля") = "русского",
	list("москалю") = "русскому",
	list("москалем", "москалём") = "русским",
	list("москале") = "русском",

	list("хохол") = "украинец",
	list("хохла") = "украинца",
	list("хохлу") = "украинцу",
	list("хохлом") = "украинцем",
	list("хохле") = "украинеце",

	list("хача") = "кавказца",
	list("хачу") = "кавказцу",
	list("хачем", "хачём", "хачом") = "кавказец",
	list("хаче") = "кавказце",
	list("хач") = "кавказец",

	list("жида") = "еврея",
	list("жиду") = "еврею",
	list("жидом") = "евреем",
	list("жиде") = "еврее",
	list("жид") = "еврей",

	list("симпа") = "последователя",
	list("симпу") = "последователю",
	list("симпом") = "последователем",
	list("симпе") = "последователе",
	list("симп") = "последователь",

	list("инцела") = "соблюдающего целибат",
	list("инцелу") = "соблюдающему целибат",
	list("инцелом") = "соблюдающим целибат",
	list("инцел") = "соблюдающий целибат",

	list("девственника", "девственика") = "юноши ни с кем не спавшим",
	list("девственнику", "девственику") = "юноше ни с кем не спавшим",
	list("девственником", "девствеником") = "юношой ни с кем не спавшим",
	list("девственнике", "девственике") = "юноше ни с кем не спавшим",
	list("девственник", "девственик") = "юноша ни с кем не спавший",

	list("девственници", "девственици") = "девушки ни с кем не спавшей",
	list("девственнице", "девственице") = "девушке ни с кем не спавшей",
	list("девственницу", "девственицу") = "девушку ни с кем не спавшей",
	list("девственницей", "девственицей") = "девушкой ни с кем не спавшей",
	list("девственница", "девственица") = "девушка ни с кем не спавшая",

	list("хиджаба") = "накидка мусульманских женщин",
	list("хиджабе", "хиджабу") = "накидке мусульманских женщин",
	list("хиджабом") = "накидкой мусульманских женщин",
	list("хиджаб") = "накидка мусульманских женщин",
))
*/
