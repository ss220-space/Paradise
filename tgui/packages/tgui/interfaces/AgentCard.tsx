import { useBackend } from '../backend';
import { Key, useState } from 'react';
import {
  Button,
  LabeledList,
  Section,
  Tabs,
  Icon,
  Box,
  ImageButton,
} from '../components';
import { Window } from '../layouts';

export const AgentCard = (props: unknown) => {
  const [tabIndex, setTabIndex] = useState(0);
  const decideTab = (index: number) => {
    switch (index) {
      case 0:
        return <AgentCardInfo />;
      case 1:
        return <AgentCardAppearances />;
      case 2:
        return <AgentCardSLSlots />;
      default:
        return <AgentCardInfo />;
    }
  };

  return (
    <Window width={500} height={475} theme="syndicate">
      <Window.Content>
        <Box fillPositionedParent overflow="hidden">
          <Tabs>
            <Tabs.Tab
              key="Card Info"
              selected={0 === tabIndex}
              onClick={() => setTabIndex(0)}
            >
              <Icon name="table" /> Card Info
            </Tabs.Tab>
            <Tabs.Tab
              key="Appearance"
              selected={1 === tabIndex}
              onClick={() => setTabIndex(1)}
            >
              <Icon name="id-card" /> Appearance
            </Tabs.Tab>
            <Tabs.Tab
              key="Save/Load Card Info"
              selected={2 === tabIndex}
              onClick={() => setTabIndex(2)}
            >
              <Icon name="arrow-down" /> Save/Load Card Info
            </Tabs.Tab>
          </Tabs>
          {decideTab(tabIndex)}
        </Box>
      </Window.Content>
    </Window>
  );
};

type CartData = {
  registered_name: string;
  sex: string;
  age: number;
  assignment: string;
  associated_account_number: number;
  blood_type: string;
  dna_hash: string;
  fingerprint_hash: string;
  photo: boolean;
  ai_tracking: boolean;
};

export const AgentCardInfo = (props: unknown) => {
  const { act, data } = useBackend<CartData>();
  const {
    registered_name,
    sex,
    age,
    assignment,
    associated_account_number,
    blood_type,
    dna_hash,
    fingerprint_hash,
    photo,
    ai_tracking,
  } = data;

  return (
    <>
      <Section title="Card Info">
        <LabeledList>
          <LabeledList.Item label="Name">
            <Button onClick={() => act('change_name')}>
              {registered_name || '[UNSET]'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Sex">
            <Button iconPosition="left" onClick={() => act('change_sex')}>
              {sex || '[UNSET]'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Age">
            <Button onClick={() => act('change_age')}>
              {age || '[UNSET]'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Rank">
            <Button onClick={() => act('change_occupation')}>
              {assignment || '[UNSET]'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Fingerprints">
            <Button onClick={() => act('change_fingerprints')}>
              {fingerprint_hash || '[UNSET]'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Blood Type">
            <Button onClick={() => act('change_blood_type')}>
              {blood_type || '[UNSET]'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="DNA Hash">
            <Button onClick={() => act('change_dna_hash')}>
              {dna_hash || '[UNSET]'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Money Account">
            <Button onClick={() => act('change_money_account')}>
              {associated_account_number || '[UNSET]'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Photo">
            <Button onClick={() => act('change_photo')}>
              {photo ? 'Update' : '[UNSET]'}
            </Button>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Card Settings">
        <LabeledList>
          <LabeledList.Item label="Card Info">
            <Button onClick={() => act('delete_info')}>Delete Card Info</Button>
          </LabeledList.Item>
          <LabeledList.Item label="Access">
            <Button onClick={() => act('clear_access')}>Reset Access</Button>
          </LabeledList.Item>
          <LabeledList.Item label="AI Tracking">
            <Button onClick={() => act('change_ai_tracking')}>
              {ai_tracking ? 'Untrackable' : 'Trackable'}
            </Button>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </>
  );
};

type CardAppearancesData = {
  appearances: string[];
  id_icon: string;
  seleced_appearance: string;
};

export const AgentCardAppearances = (props: unknown) => {
  const { act, data } = useBackend<CardAppearancesData>();
  const { appearances, id_icon, seleced_appearance } = data;
  const [selectedAppearance, setSelectedAppearance] =
    useState(seleced_appearance);

  return (
    <Section fill height={'92%'} title="Card Appearance" overflowY={'scroll'}>
      {appearances.map((appearance) => (
        <ImageButton
          key={appearance}
          dmIcon={id_icon}
          dmIconState={appearance}
          imageSize={64}
          selected={appearance === selectedAppearance}
          tooltip={appearance}
          m={'1px'}
          style={{
            opacity: (appearance === selectedAppearance && '1') || '0.5',
          }}
          onClick={() => {
            setSelectedAppearance(appearance);
            act('change_appearance_new', {
              new_appearance: appearance,
            });
          }}
        />
      ))}
    </Section>
  );
};

type CardSLSlotsData = {
  saved_info: SavedInfo[];
};

type SavedInfo = { id: string } & CartData;

export const AgentCardSLSlots = (props: unknown) => {
  const { act, data } = useBackend<CardSLSlotsData>();
  const { saved_info } = data;
  return (
    <Section title="Save/Load Manager" style={{ lineHeight: '25px' }}>
      <LabeledList>
        {saved_info.map((save_slot) => (
          <LabeledList.Item
            key={save_slot.id}
            label={
              save_slot.registered_name
                ? save_slot.registered_name + ', ' + save_slot.assignment
                : 'Slot ' + save_slot.id
            }
            buttons={
              <>
                <Button
                  onClick={() => act('clear_slot', { slot: save_slot.id })}
                >
                  Clear
                </Button>
                <Button
                  onClick={() => act('save_slot', { slot: save_slot.id })}
                >
                  Save
                </Button>
                <Button
                  disabled={!save_slot.registered_name}
                  onClick={() => act('load_slot', { slot: save_slot.id })}
                >
                  Load
                </Button>
              </>
            }
          />
        ))}
      </LabeledList>
    </Section>
  );
};
