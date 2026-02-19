import { rad2deg } from 'common/math';

import { useBackend } from '../backend';
import { useState } from 'react';
import {
  Box,
  Button,
  Flex,
  Icon,
  Input,
  LabeledList,
  Section,
  Table,
} from '../components';
import { Window } from '../layouts';
import { SectionProps } from '../components/Section';

const vectorText = (vector: number[]) =>
  vector ? '(' + vector.join(', ') + ')' : 'ERROR';

const distanceToPoint = (from: number[], to: number[], upgr: boolean) => {
  if (!from || !to) {
    return;
  }

  // Different Z-level or not UP
  if (from[2] !== to[2] || !upgr) {
    return null;
  }

  const angle = Math.atan2(to[1] - from[1], to[0] - from[0]);
  const dist = Math.sqrt(
    Math.pow(to[1] - from[1], 2) + Math.pow(to[0] - from[0], 2)
  );
  return { angle: rad2deg(angle), distance: dist };
};

type GPSData = {
  emped: boolean;
  active: boolean;
  area: string;
  position: number[];
  saved: number[];
};

export const GPS = (properties) => {
  const { data } = useBackend<GPSData>();
  const { emped, active, area, position, saved } = data;
  return (
    <Window width={450} height={700}>
      <Window.Content scrollable>
        <Flex direction="column" height="100%">
          {emped ? (
            <Flex.Item grow="1" basis="0">
              <TurnedOff emp />
            </Flex.Item>
          ) : (
            <>
              <Flex.Item>
                <Settings />
              </Flex.Item>
              {active ? (
                <>
                  <Flex.Item mt="0.5rem">
                    <Position area={area} position={position} />
                  </Flex.Item>
                  {saved && (
                    <Flex.Item mt="0.5rem">
                      <Position title="Saved Position" position={saved} />
                    </Flex.Item>
                  )}
                  <Flex.Item mt="0.5rem" grow="1" basis="0">
                    <Signals height="100%" />
                  </Flex.Item>
                </>
              ) : (
                <TurnedOff />
              )}
            </>
          )}
        </Flex>
      </Window.Content>
    </Window>
  );
};

type TurnedOffProps = {
  emp?: boolean;
};

const TurnedOff = ({ emp }: TurnedOffProps) => {
  return (
    <Section mt="0.5rem" width="100%" height="100%" stretchContents>
      <Box width="100%" height="100%" color="label" textAlign="center">
        <Flex height="100%">
          <Flex.Item grow="1" align="center" color="label">
            <Icon name={emp ? 'ban' : 'power-off'} mb="0.5rem" size={5} />
            <br />
            {emp
              ? 'ERROR: Device temporarily lost signal.'
              : 'Device is disabled.'}
          </Flex.Item>
        </Flex>
      </Box>
    </Section>
  );
};

type SettingsData = {
  active: boolean;
  tag: string;
  same_z: boolean;
};

const Settings = (properties) => {
  const { act, data } = useBackend<SettingsData>();
  const { active, tag, same_z } = data;
  const [newTag, setNewTag] = useState(tag);
  return (
    <Section
      title="Settings"
      buttons={
        <Button
          selected={active}
          icon={active ? 'toggle-on' : 'toggle-off'}
          onClick={() => act('toggle')}
        >
          {active ? 'On' : 'Off'}
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Tag">
          <Input
            width="5rem"
            value={tag}
            onEnter={() => act('tag', { newtag: newTag })}
            expensive
            onChange={setNewTag}
          />
          <Button
            disabled={tag === newTag}
            width="20px"
            mb="0"
            ml="0.25rem"
            onClick={() => act('tag', { newtag: newTag })}
          >
            <Icon name="pen" />
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Range">
          <Button
            selected={!same_z}
            icon={same_z ? 'compress' : 'expand'}
            onClick={() => act('same_z')}
          >
            {same_z ? 'Local Sector' : 'Global'}
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

type PositionProps = {
  title?: string;
  area?: string;
  position: number[];
};

const Position = ({ title, area, position }: PositionProps) => {
  return (
    <Section title={title || 'Position'}>
      <Box fontSize="1.5rem">
        {area && (
          <>
            {area}
            <br />
          </>
        )}
        {vectorText(position)}
      </Box>
    </Section>
  );
};

type SignalsData = {
  position: number[];
  signals: Signal[];
  upgraded: boolean;
};

type Signal = {
  tag: string;
  area: string;
  position: number[];
};

const Signals = (properties: SectionProps) => {
  const { data } = useBackend<SignalsData>();
  const { position, signals, upgraded } = data;
  return (
    <Section title="Signals" {...properties} overflow="auto">
      <Table>
        {signals
          .map((signal) => ({
            ...signal,
            ...distanceToPoint(position, signal.position, upgraded),
          }))
          .map((signal, i) => (
            <Table.Row
              key={i}
              backgroundColor={i % 2 === 0 && 'rgba(255, 255, 255, 0.05)'}
            >
              <Table.Cell
                width="30%"
                verticalAlign="middle"
                color="label"
                p="0.25rem"
                bold
              >
                {signal.tag}
              </Table.Cell>
              <Table.Cell verticalAlign="middle" color="grey">
                {signal.area}
              </Table.Cell>
              <Table.Cell verticalAlign="middle" collapsing>
                {signal.distance !== undefined && (
                  <Box
                    opacity={Math.max(
                      1 - Math.min(signal.distance, 100) / 100,
                      0.5
                    )}
                  >
                    <Icon
                      name={signal.distance > 0 ? 'arrow-right' : 'circle'}
                      rotation={-signal.angle}
                    />
                    &nbsp;
                    {Math.floor(signal.distance) + 'm'}
                  </Box>
                )}
              </Table.Cell>
              <Table.Cell verticalAlign="middle" pr="0.25rem" collapsing>
                {vectorText(signal.position)}
              </Table.Cell>
            </Table.Row>
          ))}
      </Table>
    </Section>
  );
};
