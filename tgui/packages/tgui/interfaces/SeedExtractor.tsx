import { classes } from '../../common/react';
import { useBackend } from '../backend';
import React, { ReactNode, useState } from 'react';
import {
  Button,
  Icon,
  Image,
  Input,
  Section,
  Stack,
  Table,
} from '../components';
import { Window } from '../layouts';
import { ComplexModal } from './common/ComplexModal';

export const SeedExtractor = (_properties) => {
  const [searchText, setSearchText] = useState('');
  const [vendAmount, setVendAmount] = useState(1);
  return (
    <Window theme="hydroponics" width={800} height={400}>
      <ComplexModal />
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <SeedExtractorActions
              setSearchText={setSearchText}
              setVendAmount={setVendAmount}
            />
          </Stack.Item>
          <SeedList searchText={searchText} vendAmount={vendAmount} />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const eq = (actual: number, test: number) => actual === test;
const ge = (actual: number, test: number) => actual >= test;
const le = (actual: number, test: number) => actual <= test;

const seedFilter = (searchText: string) => {
  let terms = searchText.split(' ');
  let filters = [];
  for (let term of terms) {
    let parts = term.split(':');
    if (parts.length === 0) {
      continue;
    }
    if (parts.length === 1) {
      filters.push((seed: Seed) =>
        (seed.name + ' (' + seed.variant + ')')
          .toLocaleLowerCase()
          .includes(parts[0].toLocaleLowerCase())
      );
      continue;
    }
    if (parts.length > 2) {
      return (_) => false;
    }
    let searchVal: number;
    let cmp = eq;
    if (parts[1][parts[1].length - 1] === '-') {
      cmp = le;
      searchVal = Number(parts[1].substring(0, parts[1].length - 1));
    } else if (parts[1][parts[1].length - 1] === '+') {
      cmp = ge;
      searchVal = Number(parts[1].substring(0, parts[1].length - 1));
    } else {
      searchVal = Number(parts[1]);
    }
    if (isNaN(searchVal)) {
      return (_) => false;
    }
    switch (parts[0].toLocaleLowerCase()) {
      case 'l':
      case 'life':
      case 'lifespan':
        filters.push((seed: Seed) => cmp(seed.lifespan, searchVal));
        break;
      case 'e':
      case 'end':
      case 'endurance':
        filters.push((seed: Seed) => cmp(seed.endurance, searchVal));
        break;
      case 'm':
      case 'mat':
      case 'maturation':
        filters.push((seed: Seed) => cmp(seed.maturation, searchVal));
        break;
      case 'pr':
      case 'prod':
      case 'production':
        filters.push((seed: Seed) => cmp(seed.production, searchVal));
        break;
      case 'y':
      case 'yield':
        filters.push((seed: Seed) => cmp(seed.yield, searchVal));
        break;
      case 'po':
      case 'pot':
      case 'potency':
        filters.push((seed: Seed) => cmp(seed.potency, searchVal));
        break;
      case 's':
      case 'stock':
      case 'c':
      case 'count':
      case 'a':
      case 'amount':
        filters.push((seed: Seed) => cmp(seed.amount, searchVal));
        break;
      default:
        return (_) => false;
    }
  }
  return (seed: Seed) => {
    for (let filter of filters) {
      if (!filter(seed)) {
        return false;
      }
    }
    return true;
  };
};

type SeedExtractorData = {
  seeds: Seed[];
};

type Seed = {
  id: string;
  name: string;
  variant: string;
  image: string;
  lifespan: number;
  endurance: number;
  maturation: number;
  production: number;
  yield: number;
  potency: number;
  amount: number;
};

const SeedList = (properties: VendAmountProps & SearchTextProps) => {
  const { act, data } = useBackend<SeedExtractorData>();
  const { seeds } = data;
  const [sortId, setSortId] = useState('name');
  const [sortOrder, setSortOrder] = useState(true);

  const { searchText, vendAmount } = properties;
  return (
    <Stack.Item grow mt={0.5}>
      <Section fill scrollable>
        <Table className="SeedExtractor__list">
          <Table.Row bold>
            <SortButton
              id="name"
              sortId={sortId}
              setSortId={setSortId}
              sortOrder={sortOrder}
              setSortOrder={setSortOrder}
            >
              Name
            </SortButton>
            <SortButton
              id="lifespan"
              sortId={sortId}
              setSortId={setSortId}
              sortOrder={sortOrder}
              setSortOrder={setSortOrder}
            >
              Lifespan
            </SortButton>
            <SortButton
              id="endurance"
              sortId={sortId}
              setSortId={setSortId}
              sortOrder={sortOrder}
              setSortOrder={setSortOrder}
            >
              Endurance
            </SortButton>
            <SortButton
              id="maturation"
              sortId={sortId}
              setSortId={setSortId}
              sortOrder={sortOrder}
              setSortOrder={setSortOrder}
            >
              Maturation
            </SortButton>
            <SortButton
              id="production"
              sortId={sortId}
              setSortId={setSortId}
              sortOrder={sortOrder}
              setSortOrder={setSortOrder}
            >
              Production
            </SortButton>
            <SortButton
              id="yield"
              sortId={sortId}
              setSortId={setSortId}
              sortOrder={sortOrder}
              setSortOrder={setSortOrder}
            >
              Yield
            </SortButton>
            <SortButton
              id="potency"
              sortId={sortId}
              setSortId={setSortId}
              sortOrder={sortOrder}
              setSortOrder={setSortOrder}
            >
              Potency
            </SortButton>
            <SortButton
              id="amount"
              sortId={sortId}
              setSortId={setSortId}
              sortOrder={sortOrder}
              setSortOrder={setSortOrder}
            >
              Stock
            </SortButton>
          </Table.Row>
          {!seeds
            ? 'No seeds present.'
            : seeds
                .filter(seedFilter(searchText))
                .sort((a, b) => {
                  const i = sortOrder ? 1 : -1;
                  if (typeof a[sortId] === 'number') {
                    return (a[sortId] - b[sortId]) * i;
                  }
                  return a[sortId].localeCompare(b[sortId]) * i;
                })
                .map((seed) => (
                  <Table.Row
                    key={seed.id}
                    onClick={() =>
                      act('vend', {
                        seed_id: seed.id,
                        seed_variant: seed.variant,
                        vend_amount: vendAmount,
                      })
                    }
                  >
                    <Table.Cell>
                      <Image
                        className={classes(['seeds32x32', seed.image])}
                        style={{
                          verticalAlign: 'middle',
                          width: '32px',
                          margin: '0px',
                          marginLeft: '0px',
                        }}
                      />
                      {seed.name}
                    </Table.Cell>
                    <Table.Cell>{seed.lifespan}</Table.Cell>
                    <Table.Cell>{seed.endurance}</Table.Cell>
                    <Table.Cell>{seed.maturation}</Table.Cell>
                    <Table.Cell>{seed.production}</Table.Cell>
                    <Table.Cell>{seed.yield}</Table.Cell>
                    <Table.Cell>{seed.potency}</Table.Cell>
                    <Table.Cell>{seed.amount}</Table.Cell>
                  </Table.Row>
                ))}
        </Table>
      </Section>
    </Stack.Item>
  );
};

type SortButtonProps = {
  id: string;
  children: ReactNode;
} & SortOrderProps &
  SordIdProps;

const SortButton = (properties: SortButtonProps) => {
  const { sortId, setSortId, sortOrder, setSortOrder } = properties;
  const { id, children } = properties;
  return (
    <Table.Cell>
      <Button
        color={sortId !== id && 'transparent'}
        fluid
        onClick={() => {
          if (sortId === id) {
            setSortOrder(!sortOrder);
          } else {
            setSortId(id);
            setSortOrder(true);
          }
        }}
      >
        {children}
        {sortId === id && (
          <Icon name={sortOrder ? 'sort-up' : 'sort-down'} ml="0.25rem;" />
        )}
      </Button>
    </Table.Cell>
  );
};

type VendAmountProps = {
  vendAmount?: number;
  setVendAmount?: React.Dispatch<React.SetStateAction<number>>;
};

const SeedExtractorActions = (
  properties: VendAmountProps & SearchTextProps
) => {
  const { setSearchText, setVendAmount } = properties;
  return (
    <Stack fill>
      <Stack.Item grow>
        <Input
          placeholder="Search by name, variant, potency:70+, production:3-, ..."
          fluid
          onInput={(e, value) => setSearchText(value)}
        />
      </Stack.Item>
      <Stack.Item>
        Vend amount:
        <Input
          placeholder="1"
          onChange={(e, value) =>
            setVendAmount(Number(value) >= 1 ? Number(value) : 1)
          }
        />
      </Stack.Item>
    </Stack>
  );
};
