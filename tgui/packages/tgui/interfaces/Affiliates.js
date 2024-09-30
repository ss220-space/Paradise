import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { createSearch, decodeHtmlEntities } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Icon, Input, Section, Tabs } from '../components';
import { Countdown } from '../components/Countdown';
import { FlexItem } from '../components/Flex';
import { Window } from '../layouts';
import {
  ComplexModal,
  modalAnswer,
  modalOpen,
  modalRegisterBodyOverride,
} from './common/ComplexModal';

export const Affiliates = (props, context) => {
  const { act, data } = useBackend(context);
  const { affiliates } = data;

  return (
    <Window width={900} height={800} title="Выбор подрядчика">
      <ComplexModal />
      <Window.Content scrollable>
        <ExploitableInfoPage affiliates={affiliates} />
      </Window.Content>
    </Window>
  );
};

const ExploitableInfoPage = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { affiliates } = data;

  return (
    <Section title="Affiliates">
      <Flex>
        {affiliates.map((i) => (
          <Flex.Item grow={1} basis={0} key={i.name}>
            <Section title={i.name}>
              <Box>{i.desc}</Box>
            </Section>
            <Button
              content="Выбрать подрядчика"
              onClick={() => act('SelectAffiliate', { path: i.path })}
            />
          </Flex.Item>
        ))}
      </Flex>
    </Section>
  );
};
