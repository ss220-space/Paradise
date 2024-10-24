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
    <Window width={900} height={670} title="Выбор подрядчика" theme="syndicate">
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
    <Flex>
      {affiliates.map((i) => (
        <Flex.Item grow={1} basis={0} key={i.name}>
          <Section style={{ 'text-align': 'center' }}>
            <img
              height="256px"
              width="256px"
              src={`data:image/jpeg;base64,${i.icon}`}
              style={{
                'margin-left': '0px',
                '-ms-interpolation-mode': 'nearest-neighbor',
              }}
            />
          </Section>
          <Section title={i.name}>
            {i.desc.map((j) => (
              <Flex.Item grow={1} basis={0} key={j}>
                <Box mx="0.5rem" mb="0.5rem">
                  {j}
                </Box>
              </Flex.Item>
            ))}
            <Button
              content="Выбрать подрядчика"
              onClick={() => act('SelectAffiliate', { path: i.path })}
            />
          </Section>
        </Flex.Item>
      ))}
    </Flex>
  );
};
