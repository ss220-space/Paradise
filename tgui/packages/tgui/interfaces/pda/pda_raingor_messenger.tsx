import { useState, useEffect } from 'react';
import { useBackend } from '../../backend';
import { Box, Button, Icon, Image, Section, Stack } from '../../components';
import { Window } from '../../layouts';
import { SearchableDropdown } from '../../components/SearchableDropdown';

// ==================== ТИПЫ ДАННЫХ ====================
type RaingorMessengerData = {
  can_login: boolean;
  owner_messenger_account: MessengerAccount;
  chats: Chat[];
  targets: string[];
};

type MessengerAccount = { name: string; account_number: number; photo: string };
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
type Page = 'main' | 'chat' | 'about' | 'create_group';

// ==================== ВСПОМОГАТЕЛЬНЫЕ КОМПОНЕНТЫ ====================
export const Avatar = ({ account_photo }: { account_photo?: string }) => {
  return (
    <Box
      width={3.5}
      height={3.5}
      overflow="hidden"
      position="relative"
      style={{ borderRadius: '50%', flexShrink: 0, backgroundColor: '#2a2a2a' }}
    >
      <Image
        src={account_photo || ''}
        width={5}
        height={5}
        style={{ position: 'absolute', top: '-0.6rem', left: '-0.6rem' }}
      />
    </Box>
  );
};

const MessageBubble = ({ msg }: { msg: Message }) => {
  const isOutgoing = !!msg.outgoing;
  const isOnRight = isOutgoing;

  return (
    <Box
      mb={1}
      style={{
        display: 'flex',
        justifyContent: isOnRight ? 'flex-end' : 'flex-start',
        alignItems: 'flex-end',
        gap: '0.5rem',
      }}
    >
      {!isOutgoing && <Avatar account_photo={msg.photo_name} />}

      <Box
        p={1}
        style={{
          maxWidth: '75%',
          borderRadius: '0.9rem',
          backgroundColor: isOutgoing ? '#2b5278' : '#333333',
          borderBottomRightRadius: isOutgoing ? '0.3rem' : '0.9rem',
          borderBottomLeftRadius: isOutgoing ? '0.9rem' : '0.3rem',
        }}
      >
        <Box fontSize={0.9} color="label" mb={0.5}>
          {msg.sender_name} • {msg.timestamp}
        </Box>
        <Box fontSize={1.05}>{msg.text_message}</Box>
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

  if (!data.can_login) {
    return (
      <Window width={600} height={850}>
        <Window.Content>
          <Stack fill vertical align="center" justify="center">
            <Section textAlign="center" width="100%">
              <Icon name="id-card" size={3} color="blue" mb={2} />
              <Box fontSize={1.5} bold mb={1}>
                {accountName && accountName !== 'unknown'
                  ? `Добрый день, ${accountName}!`
                  : 'Добро пожаловать'}
              </Box>
              <Box color="label" fontSize={1.15}>
                Для доступа к мессенджеру InCrew вставьте ID-карту в слот КПК.
              </Box>
            </Section>
          </Stack>
        </Window.Content>
      </Window>
    );
  }

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
    case 'create_group':
      PageContent = <CreateGroupPage setPage={setPage} data={data} />;
      break;
    default:
      PageContent = <UUErrorPage setPage={setPage} />;
  }

  return (
    <Window width={600} height={950}>
      <Window.Content>
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
    <Box
      style={{
        position: 'relative',
        display: 'flex',
        flexDirection: 'column',
        height: '100%',
      }}
    >
      <Section mb={2}>
        <Stack align="center">
          <Avatar account_photo={owner_messenger_account.photo} />
          <Stack.Item grow>
            <Box bold fontSize={1.15}>
              {owner_messenger_account.name || 'Неизвестно'}
            </Box>
          </Stack.Item>
          <Icon name="cog" size={1.2} color="label" />
        </Stack>
      </Section>

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

      <Box style={{ flex: 1, overflowY: 'auto', minHeight: 0 }}>
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
                borderRadius: '0.6rem',
                backgroundColor: 'rgba(255,255,255,0.03)',
                transition: 'background 0.2s',
              }}
              onClick={() => openChat(chat.chat_id)}
            >
              <Stack align="center">
                <Avatar account_photo={chat.owner_chat?.photo} />
                <Stack.Item grow>
                  <Box bold fontSize={1.05}>
                    {chat.name_chat}
                  </Box>
                  <Box
                    fontSize={0.9}
                    color="label"
                    style={{
                      whiteSpace: 'nowrap',
                      overflow: 'hidden',
                      textOverflow: 'ellipsis',
                      maxWidth: '70%',
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

      {/* FAB-кнопка: все px → rem, позиционирование в %/rem */}
      <Box
        onClick={() => setPage('create_group')}
        style={{
          position: 'absolute',
          bottom: '10%',
          right: '1.2rem',
          width: '3.5rem',
          height: '3.5rem',
          borderRadius: '50%',
          backgroundColor: '#2b5278',
          color: '#fff',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          fontSize: '1.5rem',
          zIndex: 100,
          boxShadow: '0 0.15rem 0.5rem rgba(0,0,0,0.5)',
          cursor: 'pointer',
          userSelect: 'none',
        }}
      >
        <Icon name="plus" />
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
    <Box style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      <Section mb={1}>
        <Stack align="center">
          <Button icon="arrow-left" onClick={() => setPage('main')} mr={1} />
          <Avatar account_photo={chat.owner_chat?.photo} />
          <Stack.Item grow>
            <Box bold fontSize={1.15}>
              {chat.name_chat}
            </Box>
            <Box fontSize={0.9} color="label">
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

      <Box
        p={1}
        style={{
          flex: 1,
          overflowY: 'auto',
          backgroundColor: 'rgba(0,0,0,0.2)',
          borderRadius: '0.6rem',
          marginBottom: '0.6rem',
          minHeight: 0,
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

      {chat.can_reply && (
        <Section
          style={{
            marginBottom: '12%',
          }}
        >
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
                  padding: '0.6rem 0.9rem',
                  borderRadius: '1.5rem',
                  border: '1px solid #444',
                  backgroundColor: '#222',
                  color: '#fff',
                  fontSize: '1rem',
                  outline: 'none',
                  boxSizing: 'border-box',
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
const UUErrorPage = ({ setPage }: PageBaseProps) => (
  <Box textAlign="center" p={3}>
    <Icon name="exclamation-triangle" size={3} color="red" mb={2} />
    <Box bold fontSize={1.3} mb={1}>
      Ошибка навигации
    </Box>
    <Box color="label" mb={3}>
      Произошла непредвиденная ошибка. Вернитесь в главное меню.
    </Box>
    <Button fluid icon="arrow-left" color="red" onClick={() => setPage('main')}>
      Вернуться в меню
    </Button>
  </Box>
);

// ==================== СТРАНИЦА: СОЗДАНИЕ ГРУППЫ ====================
const CreateGroupPage = ({ setPage, data }: PageProps) => {
  const { act } = useBackend();
  const [groupName, setGroupName] = useState('');
  const [groupDesc, setGroupDesc] = useState('');
  const [isPublic, setIsPublic] = useState(true);
  const [members, setMembers] = useState<string[]>([]);
  const [dropdownVal, setDropdownVal] = useState<string>('');

  const addMember = (target: string) => {
    if (target && !members.includes(target)) setMembers([...members, target]);
    setDropdownVal('');
  };
  const removeMember = (target: string) =>
    setMembers(members.filter((m) => m !== target));
  const handleCreate = () => {
    if (!groupName.trim()) return;
    act('create_group_chat', {
      name: groupName,
      description: groupDesc,
      is_public: isPublic ? 1 : 0,
      members,
    });
    setPage('main');
  };

  const inputStyle: React.CSSProperties = {
    width: '100%',
    padding: '0.6rem 0.8rem',
    borderRadius: '0.5rem',
    border: '1px solid #444',
    backgroundColor: '#1e1e1e',
    color: '#fff',
    fontSize: '1rem',
    outline: 'none',
    boxSizing: 'border-box',
  };

  return (
    <Stack fill vertical>
      <Section>
        <Stack align="center" mb={2}>
          <Button icon="arrow-left" onClick={() => setPage('main')} mr={1} />
          <Box bold fontSize={1.25}>
            Создание группового чата
          </Box>
        </Stack>

        <Stack vertical>
          <Box>
            <Box fontSize={0.95} color="label" mb={0.5}>
              Название чата
            </Box>
            <input
              type="text"
              value={groupName}
              onChange={(e) => setGroupName(e.target.value)}
              placeholder="Введите название..."
              style={inputStyle}
            />
          </Box>

          <Box>
            <Box fontSize={0.95} color="label" mb={0.5}>
              Описание
            </Box>
            <textarea
              value={groupDesc}
              onChange={(e) => setGroupDesc(e.target.value)}
              placeholder="О чём этот чат?"
              rows={3}
              style={{
                ...inputStyle,
                resize: 'vertical',
                fontFamily: 'inherit',
              }}
            />
          </Box>

          <Box>
            <Box fontSize={0.95} color="label" mb={0.5}>
              Доступ
            </Box>
            <Stack>
              <Button
                fluid
                color={isPublic ? 'green' : 'dark'}
                onClick={() => setIsPublic(true)}
                icon="globe"
              >
                Открытый
              </Button>
              <Button
                fluid
                color={!isPublic ? 'red' : 'dark'}
                onClick={() => setIsPublic(false)}
                icon="lock"
              >
                Закрытый
              </Button>
            </Stack>
          </Box>

          <Box>
            <Box fontSize={0.95} color="label" mb={0.5}>
              Участники ({members.length})
            </Box>
            <Stack mb={1}>
              <Stack.Item grow>
                <SearchableDropdown
                  options={data.targets}
                  value={dropdownVal}
                  onChange={setDropdownVal}
                  placeholder="Поиск сотрудника..."
                />
              </Stack.Item>
              <Button
                icon="plus"
                disabled={!dropdownVal || members.includes(dropdownVal)}
                onClick={() => addMember(dropdownVal)}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '0.4rem',
                  padding: '0 0.8rem',
                  lineHeight: '1',
                  minHeight: '2.2rem',
                }}
              >
                Добавить
              </Button>
            </Stack>

            {members.length > 0 && (
              <Box
                style={{
                  maxHeight: '7rem',
                  overflowY: 'auto',
                  backgroundColor: 'rgba(0,0,0,0.2)',
                  borderRadius: '0.5rem',
                  padding: '0.5rem',
                }}
              >
                {members.map((m) => (
                  <Stack key={m} align="center" mb={0.5}>
                    <Stack.Item grow>
                      <Box fontSize={0.95}>{m}</Box>
                    </Stack.Item>
                    <Button
                      icon="times"
                      color="red"
                      onClick={() => removeMember(m)}
                    />
                  </Stack>
                ))}
              </Box>
            )}
          </Box>

          <Button
            fluid
            color="blue"
            icon="check"
            disabled={!groupName.trim()}
            onClick={handleCreate}
            mt={2}
          >
            Создать чат
          </Button>
        </Stack>
      </Section>
    </Stack>
  );
};
