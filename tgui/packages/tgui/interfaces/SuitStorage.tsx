import { ReactNode } from 'react';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Dimmer,
  Flex,
  Icon,
  LabeledList,
  Section,
} from '../components';
import { Window } from '../layouts';

type SuitStorageData = {
  uv: boolean;
  helmet: string;
  suit: string;
  magboots: string;
  mask: string;
  storage: string;
  open: boolean;
  locked: boolean;
};

export const SuitStorage = (_props: unknown) => {
  const { data } = useBackend<SuitStorageData>();
  const { uv } = data;
  return (
    <Window width={402} height={268}>
      <Window.Content className="Layout__content--flexColumn">
        {!!uv && (
          <Dimmer backgroundColor="black" opacity={0.85}>
            <Flex>
              <Flex.Item bold textAlign="center" mb={2}>
                <Icon name="spinner" spin={1} size={4} mb={4} />
                <br />
                Disinfection of contents in progress...
              </Flex.Item>
            </Flex>
          </Dimmer>
        )}
        <StoredItems />
        <Disinfect />
      </Window.Content>
    </Window>
  );
};

const StoredItems = (_props: unknown) => {
  const { act, data } = useBackend<SuitStorageData>();
  const { helmet, suit, magboots, mask, storage, open, locked } = data;
  return (
    <Section
      title="Stored Items"
      flexGrow
      buttons={
        <>
          <Button
            icon={locked ? 'unlock' : 'lock'}
            disabled={open}
            onClick={() => act('toggle_lock')}
          >
            {locked ? 'Unlock' : 'Lock'}
          </Button>
          <Button
            icon={open ? 'times-circle' : 'expand'}
            color={open ? 'red' : 'green'}
            disabled={locked}
            onClick={() => act('toggle_open')}
          >
            {open ? 'Close unit' : 'Open unit'}
          </Button>
        </>
      }
    >
      {open && !locked ? (
        <LabeledList>
          <ItemRow
            object={helmet}
            label="Helmet"
            missingText="helmet"
            eject="dispense_helmet"
          />
          <ItemRow
            object={suit}
            label="Suit"
            missingText="suit"
            eject="dispense_suit"
          />
          <ItemRow
            object={magboots}
            label="Magboots"
            missingText="magboots"
            eject="dispense_magboots"
          />
          <ItemRow
            object={mask}
            label="Breathmask"
            missingText="mask"
            eject="dispense_mask"
          />
          <ItemRow
            object={storage}
            label="Storage"
            missingText="storage item"
            eject="dispense_storage"
          />
        </LabeledList>
      ) : (
        <Flex height="100%">
          <Flex.Item
            bold
            grow="1"
            textAlign="center"
            align="center"
            color="label"
          >
            <Icon
              name={locked ? 'lock' : 'exclamation-circle'}
              size={5}
              mb={3}
            />
            <br />
            {locked ? 'The unit is locked.' : 'The unit is closed.'}
          </Flex.Item>
        </Flex>
      )}
    </Section>
  );
};

type ItemRowProps = {
  object: string;
  label: string;
  missingText: string;
  eject: string;
};

const ItemRow = (props: ItemRowProps) => {
  const { act } = useBackend();
  const { object, label, missingText, eject } = props;
  return (
    <LabeledList.Item label={label}>
      <Box my={0.5}>
        {object ? (
          <Button my={-1} icon="eject" onClick={() => act(eject)}>
            {object}
          </Button>
        ) : (
          <Box color="silver" bold>
            No {missingText} found.
          </Box>
        )}
      </Box>
    </LabeledList.Item>
  );
};

const Disinfect = (_props: unknown) => {
  const { act, data } = useBackend<SuitStorageData>();
  return (
    <Section>
      <Button
        fluid
        icon="cog"
        textAlign="center"
        disabled={data.locked}
        onClick={() => act('cook')}
      >
        Start Disinfection Cycle
      </Button>
    </Section>
  );
};
