import { Component } from 'react';
import { useBackend } from '../backend';
import { Button, Input, Section, Stack, Table } from '../components';
import { Window } from '../layouts';
import { createSearch } from 'common/string';

type StaticReagentInformation = {
  name: string;
};

type VolatileReagentInformation = {
  volume: number | null;
  uid: string;
};

type FilteredReagentInformation = StaticReagentInformation & {
  id: string;
} & Partial<VolatileReagentInformation>;

type StaticData = {
  reagentsInformation: Record<string, StaticReagentInformation>;
};

type VolatileData = {
  reagents: Record<string, VolatileReagentInformation>;
};

type ReagentsEditorData = StaticData & VolatileData;

type ReagentsEditorState = {
  searchText: string;
};

// The linter is raising false-positives for unused state

export class ReagentsEditor extends Component<{}, ReagentsEditorState> {
  constructor(props: {}) {
    super(props);
    this.state = {
      searchText: '',
    };
  }

  handleSearchChange = (value: string) => {
    this.setState({ searchText: value });
  };

  override render() {
    const {
      act,
      data: { reagentsInformation, reagents: reagentsInContainer },
    } = useBackend<ReagentsEditorData>();

    const { searchText } = this.state;

    let reagents = Object.entries(reagentsInContainer)
      .map(
        ([reagentID, reagent]): FilteredReagentInformation => ({
          ...reagent,
          ...reagentsInformation[reagentID],
          id: reagentID,
        })
      )
      .sort((a, b) => a.name.localeCompare(b.name));

    if (searchText !== '') {
      reagents = reagents.concat(
        Object.entries(reagentsInformation)
          .filter(([reagentID]) => reagentsInContainer[reagentID] === undefined)
          .map(
            ([reagentID, reagent]): FilteredReagentInformation => ({
              ...reagent,
              id: reagentID,
            })
          )
          .sort((a, b) => a.name.localeCompare(b.name))
      );
    }

    const reagentsRows = reagents
      .filter(({ id: reagentID, name }) =>
        createSearch(searchText, () => `${reagentID}|${name}`)({})
      )
      .map((reagent) => {
        const { volume, uid } = reagent;
        return volume === undefined ? (
          <AbsentReagentRow key={uid ?? reagent.id} reagent={reagent} />
        ) : (
          <PresentReagentRow key={uid ?? reagent.id} reagent={reagent} />
        );
      });

    return (
      <Window width={400} height={480} title={'Реагенты атома'}>
        <Window.Content>
          <Section fill>
            <Stack fill vertical>
              <Stack.Item>
                <Stack fill>
                  <Stack.Item grow>
                    <Input
                      fluid
                      value={searchText}
                      expensive
                      onChange={this.handleSearchChange}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="plus"
                      tooltip="Добавляет новый реагент"
                      onClick={() => act('add_new_reagent')}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="sync"
                      tooltip="Обновляет список реагентов"
                      onClick={() => act('update_total')}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="fire-alt"
                      tooltip="Форсирует реакцию реагентов"
                      onClick={() => act('react_reagents')}
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item grow>
                <Table className="reagents-table">{reagentsRows}</Table>
              </Stack.Item>
            </Stack>
          </Section>
        </Window.Content>
      </Window>
    );
  }
}

// Row for a reagent with non-zero volume
const PresentReagentRow = ({
  reagent: { id: reagentID, name, uid, volume },
}: {
  reagent: FilteredReagentInformation;
}) => {
  const { act } = useBackend<ReagentsEditorData>();
  return (
    <Table.Row className="reagent-row">
      <Table.Cell>
        {name} (ID: {reagentID})
      </Table.Cell>
      <Table.Cell className="volume-cell">
        <div className="volume-actions-wrapper">
          <Button
            className="condensed-button"
            icon="syringe"
            iconColor="green"
            color="none"
            mr="0.5em"
            onClick={() =>
              act('edit_volume', {
                uid,
              })
            }
          />
          <Button.Confirm
            className="condensed-button"
            icon="trash-alt"
            confirmIcon="question"
            iconColor="red"
            confirmContent=""
            color="none"
            confirmColor="none"
            onClick={() =>
              act('delete_reagent', {
                uid,
              })
            }
            mr="0.5em"
          />
        </div>
        <span className="volume-label">
          {volume === null ? `NULL` : `${volume}u`}
        </span>
      </Table.Cell>
    </Table.Row>
  );
};

// Row for a reagent with zero volume
const AbsentReagentRow = ({
  reagent: { id: reagentID, name },
}: {
  reagent: FilteredReagentInformation;
}) => {
  const { act } = useBackend<ReagentsEditorData>();
  return (
    <Table.Row className="reagent-row absent-row">
      <Table.Cell className="reagent-absent-name-cell">
        {reagentID} ({name})
      </Table.Cell>
      <Table.Cell className="volume-cell">
        <Button
          className="condensed-button add-reagent-button"
          icon="fill-drip"
          color="none"
          onClick={() => act('add_reagent', { reagentID })}
        />
      </Table.Cell>
    </Table.Row>
  );
};
