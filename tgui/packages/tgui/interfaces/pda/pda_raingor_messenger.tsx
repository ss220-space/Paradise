import { useState, useEffect } from 'react';
import { useBackend } from '../../backend';
import { Box, Button, Icon, Image, Section, Stack } from '../../components';
import { Window } from '../../layouts';
import { SearchableDropdown } from '../../components/SearchableDropdown';

type RaingorMessengerData = {
  can_login: boolean;
  owner_messenger_account: MessengerAccount;
  chats: Chat[];
  targets: string[];
};

type MessengerAccount = {
  name: string;
  account_number: number;
  photo: string;
};

type Chat = {
  chat_id: number;
  name_chat: string;
  description_chat: string;
  can_reply: boolean;
  is_group: boolean;
  is_private: boolean;
  message_draft?: string;
  owner_chat?: MessengerAccount;
  chat_admins?: MessengerAccount[];
  chat_members: MessengerAccount[];
  messages?: Message[];
};

type Message = {
  message_id: number;
  text_message: string;
  outgoing: boolean;
  photo_name?: string;
  timestamp: number;
  sender_name: string;
};

type PageProps = { setPage: (page: Page) => void; data: RaingorMessengerData };
type MainPageProps = {
  setPage: (page: Page) => void;
  data: RaingorMessengerData;
  setChatId: (chatId: number) => void;
};
type ChatPageProps = {
  setPage: (page: Page) => void;
  data: RaingorMessengerData;
  chatId: number | null;
};
type PageBaseProps = { setPage: (page: Page) => void };
type Page = 'main' | 'chat' | 'about';

// ==================== ВСПОМОГАТЕЛЬНЫЕ КОМПОНЕНТЫ ====================
// отрисовка аватара
export const Avatar = ({ account_photo }) => {
  return (
    <Box
      width="48px"
      height="48px"
      overflow="hidden"
      position="relative"
      style={{
        borderRadius: '50%',
      }}
    >
      <Image
        src={account_photo}
        width="72px"
        height="72px"
        ml="-12px"
        mt="-2px"
      />
    </Box>
  );
};

// отрисовка сообщения
const MessageBubble = ({ msg }: { msg: Message }) => {
  const isOutgoing = !!msg.outgoing;
  const isOnRight = !isOutgoing;
  return (
    <Box
      mb={1}
      style={{
        display: 'flex',
        justifyContent: isOnRight ? 'flex-end' : 'flex-start',
        alignItems: 'flex-end',
        gap: '6px',
      }}
    >
      {!isOutgoing && <Avatar account_photo={msg.photo_name} />}

      <Box
        p={1}
        style={{
          maxWidth: '75%',
          borderRadius: '12px',
          backgroundColor: isOutgoing ? '#2b5278' : '#333333',
          borderBottomRightRadius: isOutgoing ? '4px' : '12px',
          borderBottomLeftRadius: isOutgoing ? '12px' : '4px',
        }}
      >
        <Box fontSize="11px" color="label" mb={0.5}>
          {msg.sender_name} • {msg.timestamp}
        </Box>
        <Box fontSize="13px">{msg.text_message}</Box>
      </Box>

      {isOutgoing && <Avatar account_photo={msg.photo_name} />}
    </Box>
  );
};

// ==================== ГЛАВНЫЙ КОМПОНЕНТ (РОУТЕР) ====================

export const pda_raingor_messenger = () => {
  const [page, setPage] = useState<Page>('main');
  const [activeChatId, setActiveChatId] = useState<number | null>(null);
  const { data } = useBackend<RaingorMessengerData>();
  const accountName = data?.owner_messenger_account?.name;

  // Экран блокировки: нет ID-карты в слоте КПК
  if (!data.can_login) {
    return (
      <Window width={600} height={850}>
        <Window.Content>
          <Stack fill vertical align="center" justify="center">
            <Section textAlign="center" width="100%">
              <Icon name="id-card" size={3} color="blue" mb={2} />
              <Box fontSize="18px" bold mb={1}>
                {accountName && accountName !== 'unknown'
                  ? `Добрый день, ${accountName}!`
                  : 'Добро пожаловать'}
              </Box>
              <Box color="label" fontSize="14px">
                Для доступа к мессенджеру InCrew вставьте ID-карту в слот КПК.
              </Box>
            </Section>
          </Stack>
        </Window.Content>
      </Window>
    );
  }

  // Простой роутер страниц
  let PageContent;
  switch (page) {
    case 'main':
      PageContent = (
        <MainMenuPage
          setPage={setPage}
          setChatId={setActiveChatId}
          data={data}
        />
      );
      break;
    case 'chat':
      PageContent = (
        <ChatView setPage={setPage} chatId={activeChatId} data={data} />
      );
      break;
    default:
      PageContent = <UUErrorPage setPage={setPage} />;
  }

  return (
    <Window width={600} height={950}>
      <Window.Content scrollable>
        <Stack fill vertical>
          {PageContent}
        </Stack>
      </Window.Content>
    </Window>
  );
};

// ==================== СТРАНИЦА: СПИСОК ЧАТОВ ====================

const MainMenuPage = ({ setPage, setChatId, data }: MainPageProps) => {
  const { owner_messenger_account, chats, targets } = data;
  const { act } = useBackend();
  const [target, setTarget] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const createChat = () => {
    if (!target) return;
    act('create_private_chat', { target });
    setTarget(null);
    setLoading(true);
  };

  const openChat = (id: number) => {
    setChatId(id);
    setPage('chat');
  };

  return (
    <Box style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      {/* Шапка профиля */}
      <Section mb={2}>
        <Stack align="center">
          <Avatar account_photo={owner_messenger_account.photo} />
          <Stack.Item grow>
            <Box bold fontSize="14px">
              {owner_messenger_account.name || 'Неизвестно'}
            </Box>
            <Box fontSize="11px" color="label">
              ID: {owner_messenger_account.account_number}
            </Box>
          </Stack.Item>
          <Icon name="cog" size={1.2} color="label" />
        </Stack>
      </Section>

      {/* Поиск/Создание нового чата */}
      <Section mb={2}>
        <Stack vertical>
          <SearchableDropdown
            options={targets}
            value={target || ''}
            onChange={(t) => {
              setTarget(t);
              setLoading(false);
            }}
            placeholder="Поиск сотрудника..."
          />
          <Button
            fluid
            disabled={loading || !target}
            onClick={createChat}
            icon="plus"
            color="blue"
          >
            Начать диалог
          </Button>
        </Stack>
      </Section>

      {/* Список чатов */}
      <Box style={{ flex: 1, overflowY: 'auto' }}>
        {chats.length === 0 ? (
          <Box textAlign="center" color="label" p={3} italic>
            <Icon name="comments" size={2} mb={1} />
            Нет активных диалогов
          </Box>
        ) : (
          chats.map((chat) => (
            <Box
              key={chat.chat_id}
              p={1}
              mb={1}
              style={{
                cursor: 'pointer',
                borderRadius: '8px',
                backgroundColor: 'rgba(255,255,255,0.03)',
                transition: 'background 0.2s',
              }}
              onClick={() => openChat(chat.chat_id)}
            >
              <Stack align="center">
                <Avatar account_photo={chat.owner_chat?.photo} />
                <Stack.Item grow>
                  <Box bold fontSize="13px">
                    {chat.name_chat}
                  </Box>
                  <Box
                    fontSize="11px"
                    color="label"
                    style={{
                      whiteSpace: 'nowrap',
                      overflow: 'hidden',
                      textOverflow: 'ellipsis',
                      maxWidth: '200px',
                    }}
                  >
                    {chat.description_chat || 'Нет описания'}
                  </Box>
                </Stack.Item>
                <Icon name="chevron-right" color="label" size={1} />
              </Stack>
            </Box>
          ))
        )}
      </Box>
    </Box>
  );
};

// ==================== СТРАНИЦА: ПРОСМОТР ЧАТА ====================

const ChatView = ({ setPage, data, chatId }: ChatPageProps) => {
  const { chats } = data;
  const { act } = useBackend();
  const chat =
    chatId !== null ? chats.find((c) => c.chat_id === chatId) : undefined;

  // Локальный черновик ввода. Сбрасывается при смене чата.
  const [messageDraft, setMessageDraft] = useState<string>('');
  useEffect(() => {
    setMessageDraft(chat?.message_draft || '');
  }, [chatId]);

  const deleteChat = () => {
    act('delete_chat', { chatId });
    setPage('main');
  };

  const sendMessage = () => {
    if (!messageDraft.trim()) return;
    act('send_message', { sendedMessage: messageDraft, chatId });
    setMessageDraft('');
  };

  if (!chat) {
    return (
      <Box textAlign="center" p={3}>
        <Icon name="exclamation-circle" size={2} mb={2} color="red" />
        <Box mb={2}>Чат не найден или данные ещё загружаются</Box>
        <Button fluid icon="arrow-left" onClick={() => setPage('main')}>
          Вернуться в меню
        </Button>
      </Box>
    );
  }

  return (
    <Box style={{ display: 'flex', flexDirection: 'column', height: '90%' }}>
      {/* Шапка чата с кнопкой назад */}
      <Section mb={1}>
        <Stack align="center">
          <Button icon="arrow-left" onClick={() => setPage('main')} mr={1} />
          <Avatar account_photo={chat.owner_chat?.photo} />
          <Stack.Item grow>
            <Box bold fontSize="14px">
              {chat.name_chat}
            </Box>
            <Box fontSize="11px" color="label">
              {chat.is_group
                ? `Группа • ${chat.chat_members.length} уч.`
                : 'Личный чат'}
            </Box>
          </Stack.Item>
          <Button
            icon="trash"
            color="red"
            onClick={deleteChat}
            tooltip="Удалить чат"
          />
        </Stack>
      </Section>

      {/* Область сообщений (скроллится отдельно) */}
      <Box
        p={1}
        style={{
          flex: 1,
          overflowY: 'auto',
          backgroundColor: 'rgba(0,0,0,0.2)',
          borderRadius: '8px',
          marginBottom: '8px',
        }}
      >
        {chat.messages && chat.messages.length > 0 ? (
          chat.messages.map((msg) => (
            <MessageBubble key={msg.message_id} msg={msg} />
          ))
        ) : (
          <Box textAlign="center" color="label" mt={3} italic>
            Нет сообщений. Начните диалог!
          </Box>
        )}
      </Box>

      {/* Панель ввода (прижата к низу) */}
      {chat.can_reply && (
        <Section>
          <Stack align="center">
            <Stack.Item grow>
              <input
                type="text"
                value={messageDraft}
                onChange={(e) => setMessageDraft(e.target.value)}
                onKeyDown={(e) => e.key === 'Enter' && sendMessage()}
                placeholder="Введите сообщение..."
                style={{
                  width: '100%',
                  padding: '8px 12px',
                  borderRadius: '20px',
                  border: '1px solid #444',
                  backgroundColor: '#222',
                  color: '#fff',
                  fontSize: '13px',
                  outline: 'none',
                }}
              />
            </Stack.Item>
            <Button
              icon="paper-plane"
              color="blue"
              disabled={!messageDraft.trim()}
              onClick={sendMessage}
              circular
            />
          </Stack>
        </Section>
      )}
    </Box>
  );
};

// ==================== СТРАНИЦА: ОШИБКА ====================

const UUErrorPage = ({ setPage }: PageBaseProps) => {
  return (
    <Box textAlign="center" p={3}>
      <Icon name="exclamation-triangle" size={3} color="red" mb={2} />
      <Box bold fontSize="16px" mb={1}>
        Ошибка навигации
      </Box>
      <Box color="label" mb={3}>
        Произошла непредвиденная ошибка. Вернитесь в главное меню.
      </Box>
      <Button
        fluid
        icon="arrow-left"
        color="red"
        onClick={() => setPage('main')}
      >
        Вернуться в меню
      </Button>
    </Box>
  );
};
