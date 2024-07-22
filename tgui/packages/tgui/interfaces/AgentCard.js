import { classes } from '../../common/react';
import { useBackend, useLocalState } from '../backend';
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

export const AgentCard = (props, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const decideTab = (index) => {
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

export const AgentCardInfo = (props, context) => {
  const { act, data } = useBackend(context);
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
            <Button
              content={registered_name || '[UNSET]'}
              onClick={() => act('change_name')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Sex">
            <Button
              iconRight={false}
              content={sex || '[UNSET]'}
              onClick={() => act('change_sex')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Age">
            <Button
              content={age || '[UNSET]'}
              onClick={() => act('change_age')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Rank">
            <Button
              content={assignment || '[UNSET]'}
              onClick={() => act('change_occupation')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Fingerprints">
            <Button
              content={fingerprint_hash || '[UNSET]'}
              onClick={() => act('change_fingerprints')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Blood Type">
            <Button
              content={blood_type || '[UNSET]'}
              onClick={() => act('change_blood_type')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="DNA Hash">
            <Button
              content={dna_hash || '[UNSET]'}
              onClick={() => act('change_dna_hash')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Money Account">
            <Button
              content={associated_account_number || '[UNSET]'}
              onClick={() => act('change_money_account')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Photo">
            <Button
              content={photo ? 'Update' : '[UNSET]'}
              onClick={() => act('change_photo')}
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Card Settings">
        <LabeledList>
          <LabeledList.Item label="Card Info">
            <Button
              content="Delete Card Info"
              onClick={() => act('delete_info')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Access">
            <Button
              content="Reset Access"
              onClick={() => act('clear_access')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="AI Tracking">
            <Button
              content={ai_tracking ? 'Untrackable' : 'Trackable'}
              onClick={() => act('change_ai_tracking')}
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </>
  );
};

export const AgentCardAppearances = (props, context) => {
  const { act, data } = useBackend(context);
  const { appearances } = data;
  return (
    <Section fill title="Card Appearance">
      {appearances.map((appearance_unit) => (
        <ImageButton
          key={appearance_unit}
          tooltip={appearance_unit}
          vertical
          asset
          style={{ 'margin': '1px' }}
          image={appearance_unit}
          imageAsset={'id_card64x64'}
          onclick={() =>
            act('change_appearance_new', {
              new_appearance: appearance_unit,
            })
          }
        />
      ))}
    </Section>
  );
};

export const AgentCardSLSlots = (props, context) => {
  const { act, data } = useBackend(context);
  const { saved_info } = data;
  return (
    <Section title="Save/Load Manager" style={{ 'line-height': '25px' }}>
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
                  content="Clear"
                  onClick={() => act('clear_slot', { slot: save_slot.id })}
                />
                <Button
                  content="Save"
                  onClick={() => act('save_slot', { slot: save_slot.id })}
                />
                <Button
                  content="Load"
                  disabled={!save_slot.registered_name}
                  onClick={() => act('load_slot', { slot: save_slot.id })}
                />
              </>
            }
          />
        ))}
      </LabeledList>
    </Section>
  );
};
