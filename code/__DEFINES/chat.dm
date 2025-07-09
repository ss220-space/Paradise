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


GLOBAL_LIST_INIT(twitch_bad_words, list(
	list("негра", "нигера", "ниггера", "ниги", "нигу", "ниггу") = "чёрного",
	list("негру", "нигеру", "ниггеру", "ниге") = "чёрному",
	list("негром", "нигером", "ниггером", "нигой") = "чёрным",
	list("негре", "нигере", "ниггере") = "чёрном",
	list("негр", "нигер", "ниггер", "нига", "nigger") = "чёрный",

	list("пидора", "пидораса", "педика", "гомика", "петуха") = "голубка",
	list("пидору", "пидорасу", "педику", "гомику", "петуху") = "голубку",
	list("пидором", "пидорасом", "педиком", "гомиком", "петухом") = "голубком",
	list("пидоре", "пидорасе", "педике", "гомике", "петухе") = "голубке",
	list("пидор", "пидорас", "педик", "гомик", "петух", "faggot") = "голубок",

	list("даун", "аутист") = "дурак", // The declension by cases will be preserved.

	list("куколд") = "наблюдатель",
	list("куколда") = "наблюдателя",
	list("куколду") = "наблюдателю",
	list("куколдом") = "наблюдателем",
	list("куколде") = "наблюдателе",

	list("ватник") = "дурак", // The declension by cases will be preserved.

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
))
