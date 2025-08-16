import { sortBy } from 'common/collections';
import { ReactNode, useState } from 'react';
import {
  Box,
  Button,
  Stack,
  LabeledList,
  Section,
  Tabs,
  Divider,
} from '../../components';

const diffMap = {
  0: {
    icon: 'times-circle',
    color: 'bad',
  },
  1: {
    icon: 'stop-circle',
    color: null,
  },
  2: {
    icon: 'check-circle',
    color: 'good',
  },
};
export type Access = {
  name: string;
  desc: string;
  accesses: Access[];
  regid: number;
  ref: number;
};

type AccessListProps = Partial<{
  sectionButtons?: ReactNode[];
  usedByRcd: boolean;
  rcdButtons?: ReactNode[];
  accesses: Access[];
  selectedList: number[];
  grantableList: number[];
  grantAll: () => void;
  denyAll: () => void;
  accessMod: (n: number) => void;
  grantDep: (n: number) => void;
  denyDep: (n: number) => void;
}>;

export const AccessList = (props: AccessListProps) => {
  const {
    sectionButtons = null,
    usedByRcd,
    rcdButtons,
    accesses = [],
    selectedList = [],
    grantableList = [],
    accessMod,
    grantAll,
    denyAll,
    grantDep,
    denyDep,
  } = props;
  const [selectedAccessName, setSelectedAccessName] = useState(
    accesses[0]?.name
  );
  const selectedAccess = accesses.find(
    (access) => access.name === selectedAccessName
  );
  const selectedAccessEntries = sortBy<Access>(
    selectedAccess?.accesses || [],
    (entry) => entry.desc
  );

  const checkAccessIcon = (accesses: Access[]) => {
    let oneAccess = false;
    let oneInaccess = false;
    for (let element of accesses) {
      if (selectedList?.includes(element.ref)) {
        oneAccess = true;
      } else {
        oneInaccess = true;
      }
    }
    if (!oneAccess && oneInaccess) {
      return 0;
    } else if (oneAccess && oneInaccess) {
      return 1;
    } else {
      return 2;
    }
  };

  return (
    <Section
      fill
      scrollable
      title="Access"
      buttons={
        <>
          <Button icon="check-double" color="good" onClick={() => grantAll()}>
            Select All
          </Button>
          <Button icon="undo" color="bad" onClick={() => denyAll()}>
            Deselect All
          </Button>
          {sectionButtons}
        </>
      }
    >
      <Stack>
        <Stack.Item grow basis="25%">
          <Tabs vertical>
            {accesses.map((access) => {
              const entries = access.accesses || [];
              const icon = diffMap[checkAccessIcon(entries)].icon;
              const color = diffMap[checkAccessIcon(entries)].color;
              return (
                <Tabs.Tab
                  key={access.name}
                  color={color}
                  icon={icon}
                  selected={access.name === selectedAccessName}
                  onClick={() => setSelectedAccessName(access.name)}
                >
                  {access.name}
                </Tabs.Tab>
              );
            })}
          </Tabs>
        </Stack.Item>
        <Stack.Item>
          <Divider vertical />
        </Stack.Item>
        <Stack.Item grow basis="80%">
          <Stack mb={1}>
            <Stack.Item grow>
              <Button
                fluid
                icon="check"
                color="good"
                onClick={() => grantDep(selectedAccess.regid)}
              >
                Select All In Region
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                icon="times"
                color="bad"
                onClick={() => denyDep(selectedAccess.regid)}
              >
                Deselect All In Region
              </Button>
            </Stack.Item>
          </Stack>
          {!!usedByRcd && (
            <Box my={1.5}>
              <LabeledList>
                <LabeledList.Item label="Require">
                  {rcdButtons}
                </LabeledList.Item>
              </LabeledList>
            </Box>
          )}
          {selectedAccessEntries.map((entry) => (
            <Button.Checkbox
              fluid
              key={entry.desc}
              disabled={
                grantableList?.length > 0 &&
                !grantableList.includes(entry.ref) &&
                !selectedList?.includes(entry.ref)
              }
              checked={selectedList?.includes(entry.ref)}
              onClick={() => accessMod(entry.ref)}
            >
              {entry.desc}
            </Button.Checkbox>
          ))}
        </Stack.Item>
      </Stack>
    </Section>
  );
};
