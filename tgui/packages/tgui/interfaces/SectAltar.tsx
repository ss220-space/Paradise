import { useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type Sect = {
  name: string;
  desc: string;
  type: string;
  preselected: boolean;
};

type Ritual = {
  id: string;
  name: string;
  desc: string;
  cost: number;
  target_desc: string;
  can_run: boolean;
  failure_reason: string;
  implemented: boolean;
};

type Sacrifice = {
  desc: string;
  target_name: string | null;
  value: number;
  can_sacrifice: boolean;
  failure_reason: string;
};

type Data = {
  activated: boolean;
  can_activate: boolean;
  preselected_sect: string | null;
  sects: Sect[];
  sect_name: string | null;
  sect_desc: string | null;
  deity_name: string | null;
  prana: number;
  rituals: Ritual[];
  sacrifice: Sacrifice | null;
};

export const SectAltar = (_properties) => {
  const { act, data } = useBackend<Data>();
  const { activated, sects } = data;
  const firstSect = sects.find((sect) => sect.preselected) || sects[0];
  const [selectedSect, setSelectedSect] = useState(firstSect?.type || '');
  const [deityName, setDeityName] = useState('Безымянный бог');

  return (
    <Window width={560} height={600}>
      <Window.Content scrollable>
        {!activated ? (
          <Section title="Основание веры">
            {!data.can_activate && (
              <NoticeBox color="bad">Алтарь не откликается.</NoticeBox>
            )}
            <LabeledList>
              <LabeledList.Item label="Имя бога">
                <Input
                  value={deityName}
                  width="100%"
                  maxLength={42}
                  onChange={setDeityName}
                />
              </LabeledList.Item>
            </LabeledList>
            <Section title="Специализация" mt={1}>
              <Stack vertical>
                {sects.map((sect) => (
                  <Stack.Item key={sect.type}>
                    <Button
                      fluid
                      selected={selectedSect === sect.type}
                      disabled={!!data.preselected_sect && !sect.preselected}
                      onClick={() => setSelectedSect(sect.type)}
                    >
                      {sect.name}
                    </Button>
                    <Box color="label" mt={0.5} mb={1}>
                      {sect.desc}
                    </Box>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
            <Button
              icon="church"
              disabled={!data.can_activate || !selectedSect}
              onClick={() =>
                act('activate', {
                  sect_type: selectedSect,
                  deity_name: deityName,
                })
              }
            >
              Закрепить веру
            </Button>
          </Section>
        ) : (
          <SectStatus />
        )}
      </Window.Content>
    </Window>
  );
};

const SectStatus = (_properties) => {
  const { act, data } = useBackend<Data>();
  const { rituals } = data;

  return (
    <>
      <Section title="Вера">
        <LabeledList>
          <LabeledList.Item label="Секта">{data.sect_name}</LabeledList.Item>
          <LabeledList.Item label="Бог">{data.deity_name}</LabeledList.Item>
          <LabeledList.Item label="Прана">{data.prana}</LabeledList.Item>
        </LabeledList>
        <Box color="label" mt={1}>
          {data.sect_desc}
        </Box>
      </Section>
      <Section
        title="Жертва"
        buttons={
          <Button
            icon="fire"
            disabled={!data.sacrifice?.can_sacrifice}
            tooltip={
              data.sacrifice?.failure_reason || data.sacrifice?.desc || ''
            }
            onClick={() => act('sacrifice')}
          >
            Принести
          </Button>
        }
      >
        <LabeledList>
          <LabeledList.Item label="Цель">
            {data.sacrifice?.target_name || 'Нет'}
          </LabeledList.Item>
          <LabeledList.Item label="Прана">
            {data.sacrifice?.value || 0}
          </LabeledList.Item>
        </LabeledList>
        <Box color="label" mt={1}>
          {data.sacrifice?.desc}
        </Box>
        {!!data.sacrifice?.failure_reason && (
          <Box color="bad" mt={0.5}>
            {data.sacrifice.failure_reason}
          </Box>
        )}
      </Section>
      <Section title="Ритуалы">
        {!rituals.length && <NoticeBox>Ритуалы недоступны.</NoticeBox>}
        <Stack vertical>
          {rituals.map((ritual) => (
            <Stack.Item key={ritual.id}>
              <Section
                title={`${ritual.name} - ${ritual.cost} праны`}
                buttons={
                  <Button
                    icon="play"
                    disabled={!ritual.can_run}
                    tooltip={ritual.failure_reason || ritual.target_desc}
                    onClick={() => act('run_ritual', { ritual_id: ritual.id })}
                  >
                    Запустить
                  </Button>
                }
              >
                <Box>{ritual.desc}</Box>
                <Box color="label" mt={0.5}>
                  Цель: {ritual.target_desc}
                </Box>
                {!!ritual.failure_reason && (
                  <Box color="bad" mt={0.5}>
                    {ritual.failure_reason}
                  </Box>
                )}
                {!ritual.implemented && !ritual.failure_reason && (
                  <Box color="average" mt={0.5}>
                    Эффект ритуала будет добавлен отдельно.
                  </Box>
                )}
              </Section>
            </Stack.Item>
          ))}
        </Stack>
      </Section>
    </>
  );
};
