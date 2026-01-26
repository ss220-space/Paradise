/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createUuid } from 'common/uuid';

import { MESSAGE_TYPE_INTERNAL, MESSAGE_TYPES } from './constants';

import { type Page, type PageChunk, type Message, type Payload } from './types';

export const canPageAcceptType = (page, type) =>
  type.startsWith(MESSAGE_TYPE_INTERNAL) || page.acceptedTypes[type];

export const createPage = (obj?: PageChunk): Page => {
  let acceptedTypes = {};

  for (let typeDef of MESSAGE_TYPES) {
    acceptedTypes[typeDef.type] = !!typeDef.important;
  }

  return {
    isMain: false,
    id: createUuid(),
    name: 'New Tab',
    acceptedTypes: acceptedTypes,
    unreadCount: 0,
    hideUnreadCount: false,
    createdAt: Date.now(),
    ...obj,
  };
};

export const createMainPage = () => {
  const acceptedTypes = {};
  for (let typeDef of MESSAGE_TYPES) {
    acceptedTypes[typeDef.type] = true;
  }
  return createPage({
    isMain: true,
    name: 'Main',
    acceptedTypes,
  });
};

export const createMessage = (payload: Payload): Message => ({
  createdAt: Date.now(),
  pruned: false,
  ...payload,
});

export const serializeMessage = (message: Message): {} => ({
  type: message.type,
  text: message.text,
  html: message.html,
  times: message.times,
  createdAt: message.createdAt,
});

export const isSameMessage = (a: Message, b: Message) =>
  (typeof a.text === 'string' && a.text === b.text) ||
  (typeof a.html === 'string' && a.html === b.html);
