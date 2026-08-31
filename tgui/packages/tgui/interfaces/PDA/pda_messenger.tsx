import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Icon,
  Input,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';
import { useBackend } from '../../backend';

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
  ringtone_list: Record<string, string>;
  ringtone: string;
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
            tooltip="Enter Clipboard Mode"
            tooltipPosition="bottom-start"
            onClick={() => setClipboardMode(!clipboardMode)}
          />
          <Button
            icon="comment"
            onClick={() => act('Message', { target: active_convo })}
          >
            Reply
          </Button>
        </>
      }
    >
      {messages
        .filter((im) => im.target === active_convo)
        .map((im, i) => (
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
                transform: im.sent ? 'scale(-1, 1)' : undefined,
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
              {im.sent ? 'You:' : 'Them:'} {im.message}
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
        title={`Conversation with ${convo_device} `}
        buttons={
          <>
            <Button
              icon="eye"
              selected={clipboardMode}
              tooltip="Exit Clipboard Mode"
              tooltipPosition="bottom-start"
              onClick={() => setClipboardMode(!clipboardMode)}
            />
            <Button
              icon="comment"
              onClick={() => act('Message', { target: active_convo })}
            >
              Reply
            </Button>
          </>
        }
      >
        {messages
          .filter((im) => im.target === active_convo)
          .map((im, i) => (
            <Box
              key={i}
              color={im.sent ? '#4d9121' : '#cd7a0d'}
              style={{
                wordBreak: 'normal',
              }}
            >
              {im.sent ? 'You:' : 'Them:'} <Box inline>{im.message}</Box>
            </Box>
          ))}
      </Section>
    );
  }

  return (
    <Stack fill vertical>
      <Stack.Item mb={0.5}>
        <LabeledList>
          <LabeledList.Item label="Messenger Functions">
            <Button.Confirm
              confirmContent="Are you sure?"
              icon="trash"
              confirmIcon="trash"
              onClick={() => act('Clear', { option: 'Convo' })}
            >
              Delete Conversations
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
  ringtone_list: Record<string, string>; // добавлено
  ringtone: string;
};

export const MessengerList = (props: MessengerListProps) => {
  const { act } = useBackend();

  const {
    convopdas,
    pdas,
    charges,
    silent,
    toff,
    plugins,
    ringtone_list,
    ringtone,
  } = props;

  const [searchTerm, setSearchTerm] = useState('');

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Stack>
          <Stack.Item>
            <span>Messenger Functions:</span>
          </Stack.Item>
          <Stack.Item>
            <Button
              selected={!silent}
              icon={silent ? 'volume-mute' : 'volume-up'}
              onClick={() => act('Toggle Ringer')}
            >
              Ringer: {silent ? 'Off' : 'On'}
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              color={toff ? 'bad' : 'green'}
              icon="power-off"
              onClick={() => act('Toggle Messenger')}
            >
              Messenger: {toff ? 'Off' : 'On'}
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="trash"
              color="bad"
              onClick={() => act('Clear', { option: 'All' })}
            >
              Delete All Conversations
            </Button>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item mb={5}>
        <Stack>
          <Stack.Item>
            <Button icon="bell" onClick={() => act('Ringtone')}>
              Set Custom Ringtone
            </Button>
          </Stack.Item>
          <Stack.Item grow={1}>
            <Dropdown
              selected={ringtone}
              fluid
              options={Object.keys(ringtone_list)}
              onSelected={(value) =>
                act('Available_Ringtones', { selected_ringtone: value })
              }
            />
          </Stack.Item>
        </Stack>

        {(!toff && (
          <Box>
            {!!charges && (
              <Box mt={0.5} mb={1}>
                <LabeledList>
                  <LabeledList.Item label="Cartridge Special Function">
                    {charges} charges left.
                  </LabeledList.Item>
                </LabeledList>
              </Box>
            )}
            {(!convopdas.length && !pdas.length && (
              <Box>No current conversations</Box>
            )) || (
              <Box>
                Search:{' '}
                <Input
                  mt={0.5}
                  value={searchTerm}
                  expensive
                  onChange={setSearchTerm}
                />
              </Box>
            )}
          </Box>
        )) || <Box color="bad">Messenger Offline.</Box>}
      </Stack.Item>
      <PDAList
        title="Current Conversations"
        msgAct="Select Conversation"
        searchTerm={searchTerm}
        pdas={convopdas}
      />
      <PDAList
        title="Other PDAs"
        msgAct="Message"
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

  if (!pdas?.length) {
    return <Section title={title}>No PDAs found.</Section>;
  }

  return (
    <Section fill scrollable title={title}>
      {pdas
        .filter((pda) => {
          return searchTerm
            ? pda.Name.toLowerCase().includes(searchTerm.toLowerCase())
            : true;
        })
        .map((pda) => (
          <Stack key={pda.uid} m={0.5}>
            <Stack.Item grow>
              <Button
                fluid
                icon="arrow-circle-down"
                onClick={() => msgAct && act(msgAct, { target: pda.uid })}
              >
                {pda.Name}
              </Button>
            </Stack.Item>
            <Stack.Item>
              {!!charges &&
                plugins?.map((plugin) => (
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
