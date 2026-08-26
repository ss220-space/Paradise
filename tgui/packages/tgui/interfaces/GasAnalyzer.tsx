import { CSSProperties, Key } from 'react';
import { useBackend } from '../backend';
import { Button, LabeledList, Section, Box, Stack } from '../components';
import { Window } from '../layouts';
import { GASES } from '../constants';

type GasMix = {
  name: string;
  total_moles: number;
  temperature: number;
  volume: number;
  pressure: number;
  heat_capacity: number;
  thermal_energy: number;
};

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

          {GASES.map((gas, i) => {
            if (gasmixes[0][gas.tlv] <= 0.01) {
              return '';
            }
            return (
              <LabeledList.Item key={i} label={gas.label}>
                {gasmixes[0][gas.tlv].toFixed(2) +
                  ' mol (' +
                  (
                    (gasmixes[0][gas.tlv] / gasmixes[0].total_moles) *
                    100
                  ).toFixed(2) +
                  ' %)'}
              </LabeledList.Item>
            );
          })}
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
