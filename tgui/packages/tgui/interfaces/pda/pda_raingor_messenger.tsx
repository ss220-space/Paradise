import { useState } from 'react';
import { useBackend } from '../../backend';
import {
  Box,
  Button,
  Dropdown,
  Icon,
  LabeledList,
  NumberInput,
  Section,
  Stack,
  TextArea,
} from '../../components';

import { Window } from '../../layouts';

type RaingorMessengerData = {
  can_login: boolean;
  owner_messenger_account: MessengerAccount;
  chats: Chat[];
};

type MessengerAccount = {
  name: string;
  account_number: number;
};

type Chat = {
  name_chat: string;
  description_chat: string;
  can_reply: boolean;
  is_group: boolean;
  is_private: boolean;
  message_draft: string;
  owner_chat: MessengerAccount;
  chat_admins: MessengerAccount[];
  chat_members: MessengerAccount[];
};

type PageProps = {
  setPage: (page: Page) => void;
  data: RaingorMessengerData;
};

type PageBaseProps = {
  setPage: (page: Page) => void;
};

type Page = 'main' | 'chat' | 'about';

export const pda_raingor_messenger = (props: unknown) => {
  const [page, setPage] = useState<Page>('main');
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
      PageContent = <MainMenuPage setPage={setPage} data={data} />;
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

const MainMenuPage = ({ setPage, data }: PageProps) => {
  const { owner_messenger_account, chats } = data;
  const { act } = useBackend();
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
            <Box>У вас активных чатов</Box>
          </Box>
        ) : (
          chats.map((e) => (
            <Box key={e.name_chat} className="card" mb={2}>
              <Box className="subscription-title">
                <Icon name="bookmark" size={1} />
                {e.description_chat}
              </Box>
            </Box>
          ))
        )}
      </Section>
      <Section>
        <Button>Выбери с кем хочешь начать диалог</Button>
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
