import { useBackend, useLocalState } from '../backend';
import { Button, LabeledList, Section, Tabs, Icon, Box, Fragment } from '../components';
import { Window } from '../layouts';

export const AgentCard = (props, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const decideTab = index => {
    switch (index) {
      case 0:
        return <AgentCardInfo />;
      case 1:
        return <AgentCardAppearances />;
      default:
        return <AgentCardInfo />;
    }
  };

  return (
    <Window resizable theme="syndicate">
      <Window.Content>
        <Box fillPositionedParent overflow="hidden">
          <Tabs>
            <Tabs.Tab
              key="Card Info"
              selected={0 === tabIndex}
              onClick={() => setTabIndex(0)}>
              <Icon name="table" /> Card Info
            </Tabs.Tab>
            <Tabs.Tab
              key="Appearance"
              selected={1 === tabIndex}
              onClick={() => setTabIndex(1)}>
              <Icon name="id-card" /> Appearance
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
    <Fragment>
      <Section title="Card Info">
        <LabeledList>
          <LabeledList.Item
            label="Name"
            buttons={
              <Button
                content={registered_name ? registered_name : '[UNSET]'}
                onClick={() => act('change_name')}
              />
            }
          />
          <LabeledList.Item
            label="Sex"
            buttons={
              <Button
                iconRight={false}
                content={sex ? sex : '[UNSET]'}
                onClick={() => act('change_sex')}
              />
            }
          />
          <LabeledList.Item
            label="Age"
            buttons={
              <Button
                content={age ? age : '[UNSET]'}
                onClick={() => act('change_age')}
              />
            }
          />
          <LabeledList.Item
            label="Rank"
            buttons={
              <Button
                content={assignment ? assignment : '[UNSET]'}
                onClick={() => act('change_occupation')}
              />
            }
          />
          <LabeledList.Item
            label="Fingerprints"
            buttons={
              <Button
                content={fingerprint_hash ? fingerprint_hash : '[UNSET]'}
                onClick={() => act('change_fingerprints')}
              />
            }
          />
          <LabeledList.Item
            label="Blood Type"
            buttons={
              <Button
                content={blood_type ? blood_type : '[UNSET]'}
                onClick={() => act('change_blood_type')}
              />
            }
          />
          <LabeledList.Item
            label="DNA Hash"
            buttons={
              <Button
                content={dna_hash ? dna_hash : '[UNSET]'}
                onClick={() => act('change_dna_hash')}
              />
            }
          />
          <LabeledList.Item
            label="Money Account"
            buttons={
              <Button
                content={
                  associated_account_number
                    ? associated_account_number
                    : '[UNSET]'
                }
                onClick={() => act('change_money_account')}
              />
            }
          />
          <LabeledList.Item
            label="Photo"
            buttons={
              <Button
                content={photo ? 'Update' : '[UNSET]'}
                onClick={() => act('change_photo')}
              />
            }
          />
        </LabeledList>
      </Section>
      <Section title="Card Settings">
        <LabeledList>
          <LabeledList.Item
            label="Card Info"
            buttons={
              <Button
                content="Delete Card Info"
                onClick={() => act('delete_info')}
              />
            }
          />
          <LabeledList.Item
            label="Access"
            buttons={
              <Button
                content="Reset Access"
                onClick={() => act('clear_access')}
              />
            }
          />
          <LabeledList.Item
            label="AI Tracking"
            buttons={
              <Button
                content={ai_tracking ? 'Untrackable' : 'Trackable'}
                onClick={() => act('change_ai_tracking')}
              />
            }
          />
        </LabeledList>
      </Section>
    </Fragment>
  );
};

export const AgentCardAppearances = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    appearances,
  } = data;
  return (
    <Section title="Card Appearance">
      {appearances.map(appearance_unit => (
        <img key={appearance_unit.name}
          src={`data:image/jped;base64,${
            appearance_unit.image
          }`}
          style={{
            'vertical-align': 'middle',
            width: '64px',
            margin: '0px',
            'margin-left': '0px',
          }}
          onclick={() => act('change_appearance_new', { new_appearance: appearance_unit.name })}
        />
      ))}
    </Section>
  );
};
