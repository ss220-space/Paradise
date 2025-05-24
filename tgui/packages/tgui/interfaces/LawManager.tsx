import { useBackend } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  Section,
  NoticeBox,
  Table,
} from '../components';
import { Window } from '../layouts';

type LawManagerData = {
  isAdmin: boolean;
  isSlaved: boolean;
  isMalf: boolean;
  isAIMalf: boolean;
  view: boolean;
  ion_law_nr: string;
  channels: Channel[];
  channel: string;
  zeroth_law: string;
  ion_law: string;
  inherent_law: string;
  supplied_law: string;
  supplied_law_position: number;
  law_sets: Lawset[];
} & Laws;

type Lawset = {
  name: string;
  header: string;
  laws: Laws;
  ref: string;
};

type Laws = {
  has_zeroth_laws: boolean;
  zeroth_laws: Law[];
  has_ion_laws: boolean;
  ion_laws: Law[];
  has_inherent_laws: boolean;
  inherent_laws: Law[];
  has_supplied_laws: boolean;
  supplied_laws: Law[];
};

type Law = {
  index: string;
  law: string;
  state: boolean;
  ref: string;
};

type Channel = {
  channel: string;
};

export const LawManager = (props: unknown) => {
  const { act, data } = useBackend<LawManagerData>();
  const { isAdmin, isSlaved, isMalf, isAIMalf, view } = data;

  return (
    <Window width={800} height={isMalf ? 620 : 365}>
      <Window.Content scrollable>
        {!!(isAdmin && isSlaved) && (
          <NoticeBox>This unit is slaved to {isSlaved}.</NoticeBox>
        )}
        {!!(isMalf || isAIMalf) && (
          <Box>
            <Button
              selected={view}
              onClick={() => act('set_view', { set_view: 0 })}
            >
              Law Management
            </Button>
            <Button
              selected={view}
              onClick={() => act('set_view', { set_view: 1 })}
            >
              Lawsets
            </Button>
          </Box>
        )}
        {!view && <LawManagementView />}
        {view && <LawsetsView />}
      </Window.Content>
    </Window>
  );
};

const LawManagementView = (_props: unknown) => {
  const { act, data } = useBackend<LawManagerData>();
  const {
    has_zeroth_laws,
    zeroth_laws,
    has_ion_laws,
    ion_laws,
    ion_law_nr,
    has_inherent_laws,
    inherent_laws,
    has_supplied_laws,
    supplied_laws,
    channels,
    channel,
    isMalf,
    isAdmin,
    zeroth_law,
    ion_law,
    inherent_law,
    supplied_law,
    supplied_law_position,
  } = data;
  return (
    <>
      {!!has_zeroth_laws && (
        <LawTable title="ERR_NULL_VALUE" laws={zeroth_laws} />
      )}
      {!!has_ion_laws && <LawTable title={ion_law_nr} laws={ion_laws} />}
      {!!has_inherent_laws && (
        <LawTable title="Inherent" laws={inherent_laws} />
      )}
      {!!has_supplied_laws && (
        <LawTable title="Supplied" laws={supplied_laws} />
      )}
      <Section title="Statement Settings">
        <LabeledList>
          <LabeledList.Item label="Statement Channel">
            {channels.map((c) => (
              <Button
                key={c.channel}
                selected={c.channel === channel}
                onClick={() => act('law_channel', { law_channel: c.channel })}
              >
                {c.channel}
              </Button>
            ))}
          </LabeledList.Item>
          <LabeledList.Item label="State Laws">
            <Button onClick={() => act('state_laws')}>State Laws</Button>
          </LabeledList.Item>
          <LabeledList.Item label="Law Notification">
            <Button onClick={() => act('notify_laws')}>Notify</Button>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      {!!isMalf && (
        <Section title="Add Laws">
          <Table>
            <Table.Row header>
              <Table.Cell width="10%">Type</Table.Cell>
              <Table.Cell width="60%">Law</Table.Cell>
              <Table.Cell width="10%">Index</Table.Cell>
              <Table.Cell width="20%">Actions</Table.Cell>
            </Table.Row>
            {!!(isAdmin && !has_zeroth_laws) && (
              <Table.Row>
                <Table.Cell>Zero</Table.Cell>
                <Table.Cell>{zeroth_law}</Table.Cell>
                <Table.Cell>N/A</Table.Cell>
                <Table.Cell>
                  <Button
                    icon="pencil-alt"
                    onClick={() => act('change_zeroth_law')}
                  >
                    Edit
                  </Button>
                  <Button icon="plus" onClick={() => act('add_zeroth_law')}>
                    Add
                  </Button>
                </Table.Cell>
              </Table.Row>
            )}
            <Table.Row>
              <Table.Cell>Ion</Table.Cell>
              <Table.Cell>{ion_law}</Table.Cell>
              <Table.Cell>N/A</Table.Cell>
              <Table.Cell>
                <Button icon="pencil-alt" onClick={() => act('change_ion_law')}>
                  Edit
                </Button>
                <Button icon="plus" onClick={() => act('add_ion_law')}>
                  Add
                </Button>
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>Inherent</Table.Cell>
              <Table.Cell>{inherent_law}</Table.Cell>
              <Table.Cell>N/A</Table.Cell>
              <Table.Cell>
                <Button
                  icon="pencil-alt"
                  onClick={() => act('change_inherent_law')}
                >
                  Edit
                </Button>
                <Button icon="plus" onClick={() => act('add_inherent_law')}>
                  Add
                </Button>
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>Supplied</Table.Cell>
              <Table.Cell>{supplied_law}</Table.Cell>
              <Table.Cell>
                <Button onClick={() => act('change_supplied_law_position')}>
                  {supplied_law_position}
                </Button>
              </Table.Cell>
              <Table.Cell>
                <Button
                  icon="pencil-alt"
                  onClick={() => act('change_supplied_law')}
                >
                  Edit
                </Button>
                <Button icon="plus" onClick={() => act('add_supplied_law')}>
                  Add
                </Button>
              </Table.Cell>
            </Table.Row>
          </Table>
        </Section>
      )}
    </>
  );
};

const LawsetsView = (_props: unknown) => {
  const { act, data } = useBackend<LawManagerData>();
  const { law_sets } = data;
  return (
    <Box>
      {law_sets.map((l) => (
        <Section
          key={l.name}
          title={l.name + ' - ' + l.header}
          buttons={
            <Button
              icon="download"
              onClick={() => act('transfer_laws', { transfer_laws: l.ref })}
            >
              Load Laws
            </Button>
          }
        >
          <LabeledList>
            {!!l.laws.has_ion_laws &&
              l.laws.ion_laws.map((il) => (
                <LabeledList.Item key={il.index} label={il.index}>
                  {il.law}
                </LabeledList.Item>
              ))}
            {!!l.laws.has_zeroth_laws &&
              l.laws.zeroth_laws.map((zl) => (
                <LabeledList.Item key={zl.index} label={zl.index}>
                  {zl.law}
                </LabeledList.Item>
              ))}
            {!!l.laws.has_inherent_laws &&
              l.laws.inherent_laws.map((il) => (
                <LabeledList.Item key={il.index} label={il.index}>
                  {il.law}
                </LabeledList.Item>
              ))}
            {!!l.laws.has_supplied_laws &&
              l.laws.inherent_laws.map((sl) => (
                <LabeledList.Item key={sl.index} label={sl.index}>
                  {sl.law}
                </LabeledList.Item>
              ))}
          </LabeledList>
        </Section>
      ))}
    </Box>
  );
};

type LawTableProps = {
  title: string;
  laws: Law[];
};

const LawTable = (props: LawTableProps) => {
  const { act, data } = useBackend<LawManagerData>();
  const { isMalf } = data;
  return (
    <Section title={props.title + ' Laws'}>
      <Table>
        <Table.Row header>
          <Table.Cell width="10%">Index</Table.Cell>
          <Table.Cell width="69%">Law</Table.Cell>
          <Table.Cell width="21%">State?</Table.Cell>
        </Table.Row>
        {props.laws.map((l) => (
          <Table.Row key={l.law}>
            <Table.Cell>{l.index}</Table.Cell>
            <Table.Cell>{l.law}</Table.Cell>
            <Table.Cell>
              <Button
                selected={l.state}
                onClick={() =>
                  act('state_law', { ref: l.ref, state_law: l.state ? 0 : 1 })
                }
              >
                {l.state ? 'Yes' : 'No'}
              </Button>
              {!!isMalf && (
                <>
                  <Button
                    icon="pencil-alt"
                    onClick={() => act('edit_law', { edit_law: l.ref })}
                  >
                    Edit
                  </Button>
                  <Button
                    icon="trash"
                    color="red"
                    onClick={() => act('delete_law', { delete_law: l.ref })}
                  >
                    Delete
                  </Button>
                </>
              )}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
