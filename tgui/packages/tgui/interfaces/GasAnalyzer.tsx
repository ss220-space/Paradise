import { CSSProperties, Key } from 'react';
import { useBackend } from '../backend';
import { Button, Flex, LabeledList, Section, Box, Stack } from '../components';
import { Window } from '../layouts';

type GasMix = {
  name: string;
  oxygen: number;
  nitrogen: number;
  carbon_dioxide: number;
  toxins: number;
  sleeping_agent: number;
  agent_b: number;
  total_moles: number;
  temperature: number;
  volume: number;
  pressure: number;
  heat_capacity: number;
  thermal_energy: number;
} & Key;

type GasAnalyzerData = {
  gasmixes: GasMix[];
  autoUpdating: boolean;
};

export const GasAnalyzerContent = (props: unknown) => {
  const { act, data } = useBackend<GasAnalyzerData>();
  const { gasmixes, autoUpdating } = data;
  return (
    <Section
      title={gasmixes[0].name}
      key={gasmixes[0]}
      buttons={
        <Button
          icon={autoUpdating ? 'unlock' : 'lock'}
          onClick={() => act('autoscantoggle')}
          tooltip={
            autoUpdating ? 'Auto-Update Enabled' : 'Auto-Update Disabled'
          }
          fluid
          textAlign="center"
          selected={autoUpdating}
        />
      }
    >
      {!gasmixes[0].total_moles ? (
        <Box nowrap italic mb="10px">
          {'No Gas Detected!'}
        </Box>
      ) : (
        <LabeledList>
          <LabeledList.Item label={'Total Moles'}>
            {(gasmixes[0].total_moles ? gasmixes[0].total_moles : '-') + ' mol'}
          </LabeledList.Item>
          {gasmixes[0].oxygen ? (
            <LabeledList.Item label={'Oxygen'}>
              {gasmixes[0].oxygen.toFixed(2) +
                ' mol (' +
                ((gasmixes[0].oxygen / gasmixes[0].total_moles) * 100).toFixed(
                  2
                ) +
                ' %)'}
            </LabeledList.Item>
          ) : (
            ''
          )}
          {gasmixes[0].nitrogen ? (
            <LabeledList.Item label={'Nitrogen'}>
              {gasmixes[0].nitrogen.toFixed(2) +
                ' mol (' +
                (
                  (gasmixes[0].nitrogen / gasmixes[0].total_moles) *
                  100
                ).toFixed(2) +
                ' %)'}
            </LabeledList.Item>
          ) : (
            ''
          )}
          {gasmixes[0].carbon_dioxide ? (
            <LabeledList.Item label={'Carbon Dioxide'}>
              {gasmixes[0].carbon_dioxide.toFixed(2) +
                ' mol (' +
                (
                  (gasmixes[0].carbon_dioxide / gasmixes[0].total_moles) *
                  100
                ).toFixed(2) +
                ' %)'}
            </LabeledList.Item>
          ) : (
            ''
          )}
          {gasmixes[0].toxins ? (
            <LabeledList.Item label={'Plasma'}>
              {gasmixes[0].toxins.toFixed(2) +
                ' mol (' +
                ((gasmixes[0].toxins / gasmixes[0].total_moles) * 100).toFixed(
                  2
                ) +
                ' %)'}
            </LabeledList.Item>
          ) : (
            ''
          )}
          {gasmixes[0].sleeping_agent ? (
            <LabeledList.Item label={'Nitrous Oxide'}>
              {gasmixes[0].sleeping_agent.toFixed(2) +
                ' mol (' +
                (
                  (gasmixes[0].sleeping_agent / gasmixes[0].total_moles) *
                  100
                ).toFixed(2) +
                ' %)'}
            </LabeledList.Item>
          ) : (
            ''
          )}
          {gasmixes[0].agent_b ? (
            <LabeledList.Item label={'Agent B'}>
              {gasmixes[0].agent_b.toFixed(2) +
                ' mol (' +
                ((gasmixes[0].agent_b / gasmixes[0].total_moles) * 100).toFixed(
                  2
                ) +
                ' %)'}
            </LabeledList.Item>
          ) : (
            ''
          )}
          <LabeledList.Item label={'Temperature'}>
            {(gasmixes[0].total_moles
              ? (gasmixes[0].temperature - 273.15).toFixed(2)
              : '-') +
              ' °C (' +
              (gasmixes[0].total_moles
                ? gasmixes[0].temperature.toFixed(2)
                : '-') +
              ' K)'}
          </LabeledList.Item>
          <LabeledList.Item label={'Volume'}>
            {(gasmixes[0].total_moles ? gasmixes[0].volume : '-') + ' L'}
          </LabeledList.Item>
          <LabeledList.Item label={'Pressure'}>
            {(gasmixes[0].total_moles ? gasmixes[0].pressure.toFixed(2) : '-') +
              ' kPa'}
          </LabeledList.Item>
          <LabeledList.Item label={'Heat Capacity'}>
            {gasmixes[0].heat_capacity + ' / K'}
          </LabeledList.Item>
          <LabeledList.Item label={'Thermal Energy'}>
            {gasmixes[0].thermal_energy}
          </LabeledList.Item>
        </LabeledList>
      )}
    </Section>
  );
};

type HistoryData = {
  historyGasmixes: GasMix[];
  historyViewMode: string;
  historyIndex: number;
};

export const GasAnalyzerHistory = (props: unknown) => {
  const { act, data } = useBackend<HistoryData>();
  const { historyGasmixes, historyViewMode, historyIndex } = data;
  return (
    <Section
      fill
      title="Scan History"
      buttons={
        <Button
          icon={'trash'}
          tooltip="Clear History"
          onClick={() => act('clearhistory')}
          textAlign="center"
          disabled={historyGasmixes.length === 0}
        />
      }
    >
      <LabeledList.Item label="Mode">
        <Stack fill width="50%">
          <Stack.Item>
            <Button
              onClick={() => act('modekpa')}
              textAlign="center"
              selected={historyViewMode === 'kpa'}
            >
              kPa
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              onClick={() => act('modemol')}
              textAlign="center"
              selected={historyViewMode === 'mol'}
            >
              mol
            </Button>
          </Stack.Item>
        </Stack>
      </LabeledList.Item>
      <Stack vertical>
        {historyGasmixes.map((historyGasmix, index) => (
          <Stack.Item key={historyGasmix[0]}>
            <Button
              onClick={() => act('input', { target: index + 1 })}
              textAlign="left"
              selected={index + 1 === historyIndex}
              fluid
            >
              {index +
                1 +
                '. ' +
                (historyViewMode === 'mol'
                  ? historyGasmix[0].total_moles.toFixed(2)
                  : historyGasmix[0].pressure.toFixed(2)) +
                ` ${historyViewMode}`}
            </Button>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

export const GasAnalyzer = (props: unknown) => {
  const styleLeftDiv: CSSProperties = {
    float: 'left',
    width: '67%',
  };
  const styleRightDiv: CSSProperties = {
    float: 'right',
    width: '33%',
  };
  return (
    <Window width={500} height={500}>
      <Window.Content scrollable>
        {/* Left Column */}
        <div style={styleLeftDiv}>
          <Section flexGrow>
            <GasAnalyzerContent />
          </Section>
        </div>
        {/* Right Column */}
        <div style={styleRightDiv}>
          <Section width={'160px'}>
            <GasAnalyzerHistory />
          </Section>
        </div>
      </Window.Content>
    </Window>
  );
};
