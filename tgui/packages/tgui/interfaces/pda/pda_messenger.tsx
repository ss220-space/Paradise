import { filter } from 'common/collections';
import { useBackend } from '../../backend';
import { useState } from 'react';
import {
  Box,
  Button,
  Icon,
  Input,
  LabeledList,
  Section,
  Stack,
} from '../../components';

export const pda_messenger = (props: unknown) => {
  const { data } = useBackend<MessenderData>();
  const { active_convo } = data;

  if (active_convo) {
    return <ActiveConversation {...data} />;
  }
  return <MessengerList {...data} />;
};

export type Conversation = {
  convo_device: string;
  messages: Message[];
  active_convo: string;
};

export type Messenger = {
  convopdas: PDA[];
  pdas: PDA[];
  charges: number;
  silent: boolean;
  toff: boolean;
  plugins: Plugin[];
};

export type MessenderData = Conversation & Messenger;

type Message = { sent: boolean; target: string; message: string };

type PDA = { uid: string; Name: string };

type Plugin = {
  uid: string;
  icon: string;
  name: string;
};

export const ActiveConversation = (props: Conversation) => {
  const { act } = useBackend();

  const { convo_device, messages, active_convo } = props;

  const [clipboardMode, setClipboardMode] = useState(false);

  let body = (
    <Section
      fill
      scrollable
      title={convo_device}
      buttons={
        <>
          <Button
            icon="eye"
            selected={clipboardMode}
            tooltip="Войти в режим буфера обмена"
            tooltipPosition="bottom-start"
            onClick={() => setClipboardMode(!clipboardMode)}
          />
          <Button
            icon="comment"
            onClick={() => act('Message', { 'target': active_convo })}
          >
            Ответить
          </Button>
        </>
      }
    >
      {filter(messages, (im) => im.target === active_convo).map((im, i) => (
        <Box
          textAlign={im.sent ? 'right' : 'left'}
          position="relative"
          mb={1}
          key={i}
        >
          <Icon
            fontSize={2.5}
            color={im.sent ? '#4d9121' : '#cd7a0d'}
            position="absolute"
            left={im.sent ? null : '0px'}
            right={im.sent ? '0px' : null}
            bottom="-4px"
            style={{
              zIndex: '0',
              transform: im.sent ? 'scale(-1, 1)' : null,
            }}
            name="comment"
          />
          <Box
            inline
            backgroundColor={im.sent ? '#4d9121' : '#cd7a0d'}
            p={1}
            maxWidth="100%"
            position="relative"
            textAlign={im.sent ? 'left' : 'right'}
            style={{
              zIndex: '1',
              borderRadius: '10px',
              wordBreak: 'normal',
            }}
          >
            {im.sent ? 'Вы:' : 'Them:'} {im.message}
          </Box>
        </Box>
      ))}
    </Section>
  );

  if (clipboardMode) {
    body = (
      <Section
        fill
        scrollable
        title={'Диалог с ' + convo_device + ' '}
        buttons={
          <>
            <Button
              icon="eye"
              selected={clipboardMode}
              tooltip="Выйти из режима буфера обмена"
              tooltipPosition="bottom-start"
              onClick={() => setClipboardMode(!clipboardMode)}
            />
            <Button
              icon="comment"
              onClick={() => act('Message', { 'target': active_convo })}
            >
              Ответить
            </Button>
          </>
        }
      >
        {filter(messages, (im) => im.target === active_convo).map((im, i) => (
          <Box
            key={i}
            color={im.sent ? '#4d9121' : '#cd7a0d'}
            style={{
              wordBreak: 'normal',
            }}
          >
            {im.sent ? 'Вы:' : 'Them:'} <Box inline>{im.message}</Box>
          </Box>
        ))}
      </Section>
    );
  }

  return (
    <Stack fill vertical>
      <Stack.Item mb={0.5}>
        <LabeledList>
          <LabeledList.Item label="Функции мессенджера">
            <Button.Confirm
              confirmContent="Вы уверены?"
              icon="trash"
              confirmIcon="trash"
              onClick={() => act('Clear', { option: 'Convo' })}
            >
              Удалить диалоги
            </Button.Confirm>
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
      {body}
    </Stack>
  );
};

type MessengerListProps = {
  convopdas: PDA[];
  pdas: PDA[];
  charges: number;
  silent: boolean;
  toff: boolean;
  plugins: Plugin[];
};

export const MessengerList = (props: MessengerListProps) => {
  const { act } = useBackend();

  const { convopdas, pdas, charges, silent, toff, plugins } = props;

  const [searchTerm, setSearchTerm] = useState('');

  return (
    <Stack fill vertical>
      <Stack.Item mb={5}>
        <LabeledList>
          <LabeledList.Item label="Функции мессенджера">
            <Button
              selected={!silent}
              icon={silent ? 'volume-mute' : 'volume-up'}
              onClick={() => act('Toggle Ringer')}
            >
              Звук: {silent ? 'Выключить' : 'Включить'}
            </Button>
            <Button
              color={toff ? 'bad' : 'green'}
              icon="power-off"
              onClick={() => act('Toggle Messenger')}
            >
              Мессенджер: {toff ? 'Выключить' : 'Включить'}
            </Button>
            <Button icon="bell" onClick={() => act('Ringtone')}>
              Установить рингтон
            </Button>
            <Button
              icon="trash"
              color="bad"
              onClick={() => act('Clear', { option: 'All' })}
            >
              Удалить все диалоги
            </Button>
          </LabeledList.Item>
        </LabeledList>
        {(!toff && (
          <Box>
            {!!charges && (
              <Box mt={0.5} mb={1}>
                <LabeledList>
                  <LabeledList.Item label="Специальная функция картриджа">
                    {charges} зарядов осталось.
                  </LabeledList.Item>
                </LabeledList>
              </Box>
            )}
            {(!convopdas.length && !pdas.length && (
              <Box>Диалоги отсутствуют</Box>
            )) || (
              <Box>
                Поиск:{' '}
                <Input
                  mt={0.5}
                  value={searchTerm}
                  onInput={(e, value) => {
                    setSearchTerm(value);
                  }}
                />
              </Box>
            )}
          </Box>
        )) || <Box color="bad">Мессенджер отключен.</Box>}
      </Stack.Item>
      <PDAList
        title="Текущие диалоги"
        msgAct="Выбрать диалог"
        searchTerm={searchTerm}
        pdas={convopdas}
      />
      <PDAList
        title="Другие КПК"
        msgAct="Сообщение"
        pdas={pdas}
        searchTerm={searchTerm}
        charges={charges}
        plugins={plugins}
      />
    </Stack>
  );
};

type PDAProps = Partial<{
  title: string;
  msgAct: string;
  searchTerm: string;
  pdas: PDA[];
  charges: number;
  plugins: Plugin[];
}>;

const PDAList = (props: PDAProps) => {
  const { act } = useBackend();

  const { pdas, title, msgAct, searchTerm, charges, plugins } = props;

  if (!pdas || !pdas.length) {
    return <Section title={title}>КПК не найдены.</Section>;
  }

  return (
    <Section fill scrollable title={title}>
      {pdas
        .filter((pda) => {
          return pda.Name.toLowerCase().includes(searchTerm.toLowerCase());
        })
        .map((pda) => (
          <Stack key={pda.uid} m={0.5}>
            <Stack.Item grow>
              <Button
                fluid
                icon="arrow-circle-down"
                onClick={() => act(msgAct, { target: pda.uid })}
              >
                {pda.Name}
              </Button>
            </Stack.Item>
            <Stack.Item>
              {!!charges &&
                plugins.map((plugin) => (
                  <Button
                    key={plugin.uid}
                    icon={plugin.icon}
                    onClick={() =>
                      act('Messenger Plugin', {
                        plugin: plugin.uid,
                        target: pda.uid,
                      })
                    }
                  >
                    {plugin.name}
                  </Button>
                ))}
            </Stack.Item>
          </Stack>
        ))}
    </Section>
  );
};
