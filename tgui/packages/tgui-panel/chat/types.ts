export type Page = {
  isMain: boolean;
  id: string;
  name: string;
  acceptedTypes: Record<string, boolean>;
  unreadCount: number;
  hideUnreadCount: boolean;
  createdAt: number;
};

export type Message = {
  createdAt: number;
  node?: HTMLElement;
  pruned: boolean;
  avoidHighlighting?: boolean;
} & Payload;

export type Payload = {
  type: string;
  text?: string;
  html?: string;
  times?: number;
};

export type PageChunk = {
  isMain: boolean;
  name: string;
  acceptedTypes: {};
};
