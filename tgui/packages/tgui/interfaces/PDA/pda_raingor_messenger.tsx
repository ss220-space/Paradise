import { useState } from 'react';
import { useBackend } from '../../backend';
import {
  Box,
  Button,
  Dropdown,
  Icon,
  Input,
  LabeledList,
  NumberInput,
  Section,
  Stack,
  TextArea,
} from '../../components';

import { Window } from '../../layouts';
import { SearchableDropdown } from '../../components/SearchableDropdown';
import { SearchableDropdown } from '../../components/SearchableDropdown';

type RaingorMessengerData = {
  can_login: boolean;
  owner_messenger_account: MessengerAccount;
  chats: Chat[];
  targets: string[];
  targets: string[];
};

type MessengerAccount = {
  name: string;
  account_number: number;
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

type PageProps = {
  setPage: (page: Page) => void;
  data: RaingorMessengerData;
};

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

type PageBaseProps = {
  setPage: (page: Page) => void;
};

type Page = 'main' | 'chat' | 'about';

export const pda_raingor_messenger = (props: unknown) => {
  const [page, setPage] = useState<Page>('main');
  const [activeChatId, setActiveChatId] = useState<number | null>(null);
  const { data } = useBackend<RaingorMessengerData>();
  const accountName = data?.owner_messenger_account?.name;

  if (!data.can_login) {
    return (
      <Window width={600} height={850}>
        <Window.Content>
          <Stack fill vertical>
            <Section
              title={
                <Box fontSize="22px" bold textAlign="center">
                  <Icon name="university" color="blue" mr={1} />
                  Raingor Interstellar Company
                </Box>
              }
            >
              <Box fontSize="20px" bold mb={1} textAlign="center">
                {accountName && accountName !== '' && accountName !== 'unknown'
                  ? `Добрый день, ${accountName}!`
                  : 'Добро пожаловать'}
              </Box>
              <Stack fill vertical align="center" justify="center">
                <Box textAlign="center" color="label" fontSize="18px" bold>
                  Для доступа к мессенджеру InCrew
                  <br />
                  вставьте ID-карту в слот КПК.
                </Box>
              </Stack>
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
    default:
      PageContent = <UUErrorPage setPage={setPage} />;
  }

  return (
    <Window width={600} height={950}>
      <Window.Content>
        <Stack fill vertical>
          <Section fill scrollable>
            {PageContent}
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MainMenuPage = ({ setPage, setChatId, data }: MainPageProps) => {
  const { owner_messenger_account, chats, targets } = data;
  const { act } = useBackend();
  const [target, setTarget] = useState<string | null>(null);
  const createChat = () => {
    act('create_private_chat', { target });
  };
  const openChat = (id: number) => {
    setChatId(id);
    setPage('chat');
  };
  return (
    <Box>
      <Section>
        <Stack vertical p={3}>
          <Icon name="user-circle" className="text-gold" size={3} mb={2} />
          <Box
            fontSize="15px"
            bold
            className="text-gold"
            mb={2}
            style={{ letterSpacing: '1.5px' }}
          >
            Информация о пользователе
          </Box>
          <Box>{owner_messenger_account.name || 'Неизвестно'}</Box>
        </Stack>
      </Section>

      <Section>
        {chats.length === 0 ? (
          <Box italic className="text-muted" textAlign="center" p={3}>
            <Icon name="info" size={2} mb={2} />
            <Box>У вас нет активных чатов</Box>
          </Box>
        ) : (
          chats.map((e) => (
            <Box key={e.name_chat} className="card" mb={2}>
              <Box className="subscription-title">
                <Icon name="bookmark" size={1} />
                {e.description_chat}
              </Box>
              <Button onClick={() => openChat(e.chat_id)}>Открыть чат</Button>
            </Box>
          ))
        )}
      </Section>

      <Section>
        <SearchableDropdown
          options={targets}
          value={target}
          onChange={(t) => setTarget(t)}
          placeholder="Введите имя аккаунта..."
        />
        <Button onClick={createChat} disabled={target === null}>
          Выбери с кем хочешь начать диалог
        </Button>
      </Section>
    </Box>
  );
};

const ChatView = ({ setPage, data, chatId }: ChatPageProps) => {
  const { chats } = data;
  const { act } = useBackend();
  const chat =
    chatId !== null ? chats.find((c) => c.chat_id === chatId) : undefined;
  const [messageDraft, setMessageDraft] = useState<string>('');

  if (!chat) {
    return (
      <Box textAlign="center" p={3}>
        <Icon name="exclamation-circle" size={2} mb={2} />
        <Box>Чат не найден или ещё не загружен</Box>
        <Button
          fluid
          className="btn-bank"
          onClick={() => setPage('main')}
          mt={2}
        >
          <Icon name="step-backward" className="text-gold" mr={1} />
          <span className="text-white">Вернуться в меню</span>
        </Button>
      </Box>
    );
  }

  const members = chat.chat_members;
  return (
    <Box>
      <Section>
        <Box textAlign="center" mb={3}>
          <Button fluid className="btn-bank" onClick={() => setPage('main')}>
            <Icon name="step-backward" className="text-gold" mr={1} />
            <span className="text-white">Вернуться в меню</span>
          </Button>
        </Box>
      </Section>

      <Section title={chat.name_chat}>
        <Box>Описание чата: {chat.description_chat}</Box>
        <Box mt={2}>
          <Box bold mb={1}>
            Участники чата:
          </Box>

          {members.length > 0 ? (
            members.map((member) => (
              <Box key={member.account_number} ml={2} mb={1}>
                <Icon name="user" mr={1} />
                {member.name}
              </Box>
            ))
          ) : (
            <Box ml={2} color="label">
              Нет участников
            </Box>
          )}
        </Box>
      </Section>

      <Section>
        <Box>список сообщений</Box>
        <Box>
          {chat.messages?.map((e) => (
            <Box key={e.message_id}>
              <Box>{e.timestamp}</Box>
              <Box> Типа аватарка, а сбоку его имя: {e.sender_name}</Box>
              <Box>{e.text_message} </Box>
            </Box>
          ))}
        </Box>
      </Section>

      <Section>
        тип тут ввод
        <input
          type="text"
          value={messageDraft}
          onChange={(e) => setMessageDraft(e.target.value)}
        />
        <Button
          onClick={() =>
            act('sendMessage', {
              'sendedMessage': messageDraft,
              'chatId': chatId,
            })
          }
        >
          отравить сообщение
        </Button>
      </Section>
    </Box>
  );
};

// I don't know how, but if he gets an error, he can go to the main folder.
// Last hope
const UUErrorPage = ({ setPage }: PageBaseProps) => {
  return (
    <Box>
      {/* Error Card */}
      <Box className="card card--error">
        <Box className="error-icon" textAlign="center">
          <Icon name="exclamation-triangle" />
        </Box>
        <Box className="error-title" textAlign="center">
          Ошибка
        </Box>
        <Box className="divider" />
        <Box className="error-message" textAlign="center">
          Произошла непредвиденная ошибка при обработке запроса.
          <br />
          Пожалуйста, попробуйте снова или вернитесь в главное меню.
        </Box>
        <Box className="divider" />
        <Button
          fluid
          className="btn-bank btn-bank--danger"
          onClick={() => setPage('main')}
          p={3}
        >
          <Stack align="center" justify="center">
            <Icon name="step-backward" mr={2} className="text-white" />
            <Box fontSize="14px" className="text-white">
              Вернуться в меню
            </Box>
          </Stack>
        </Button>
      </Box>

      {/* Footer Notice */}
      <Box textAlign="center" mt={3} className="text-muted" fontSize={0.9}>
        <Icon name="info-circle" mr={0.5} />
        Если ошибка повторяется, обратитесь в службу поддержки Raingor
      </Box>
    </Box>
  );
};
