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
	list("негр", "нигер", "ниггер", "нига", "nigger") = "чёрный",
	list("негра", "нигера", "ниггера", "ниги", "нигу", "ниггу") = "чёрного",
	list("негру", "нигеру", "ниггеру", "ниге") = "чёрному",
	list("негром", "нигером", "ниггером", "нигой") = "чёрным",
	list("негре", "нигере", "ниггере") = "чёрном",

	list("пидор", "пидорас", "педик", "гомик", "петух", "faggot") = "козёл",
	list("пидора", "пидораса", "педика", "гомика", "петуха") = "козла",
	list("пидору", "пидорасу", "педику", "гомику", "петуху") = "козлу",
	list("пидором", "пидорасом", "педиком", "гомиком", "петухом") = "козлом",
	list("пидоре", "пидорасе", "педике", "гомике", "петухе") = "козле",


))
