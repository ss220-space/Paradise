import { Fragment } from 'inferno';

import { useBackend } from '../../backend';
import { Box, Button, Section, Stack } from '../../components';
import { EFFECTS_ALL, POD_GREY } from './constants';
import { useCompact } from './hooks';
import { PodEffect, PodLauncherData } from './types';

export const PodStatusPage = (props, context) => {
  const [compact] = useCompact(context);

  return (
    <Section fill>
      <Stack>
        {EFFECTS_ALL.map((effectType, typeIdx) => (
          <Fragment key={typeIdx}>
            <Stack.Item>
              <Box bold color="label" mb={1}>
                {!compact && (effectType.alt_label || effectType.label)}:
              </Box>
              <Box>
                {effectType.list.map((effect, effectIdx) => (
                  <EffectDisplay
                    effect={effect}
                    hasMargin={effectType.list.length > 1}
                    index={effectIdx}
                    key={effectIdx}
                  />
                ))}
              </Box>
            </Stack.Item>
            {typeIdx < EFFECTS_ALL.length && <Stack.Divider />}
            {typeIdx === EFFECTS_ALL.length - 1 && <Extras />}
          </Fragment>
        ))}
      </Stack>
    </Section>
  );
};

const EffectDisplay = (props, context) => {
  const { effect, hasMargin, index } = props;
  const { act, data } = useBackend<PodLauncherData>(context);
  const { effectShrapnel, payload, shrapnelMagnitude, shrapnelType } = data;

  if (effect.divider || !('icon' in effect)) {
    return (
      <span style={POD_GREY}>
        <b>|</b>
      </span>
    );
  }

  return (
    <Button
      icon={effect.icon}
      onClick={() =>
        payload ? act(effect.act, effect.payload) : act(effect.act)
      }
      selected={
        effect.soloSelected
          ? data[effect.soloSelected]
          : data[effect.selected as string] === effect.choiceNumber
      }
      style={{
        'border-radius': '5px',
        'margin-left': index !== 0 ? '1px' : '0px',
        'margin-right': hasMargin ? '1px' : '0px',
        'vertical-align': 'middle',
      }}
      tooltip={
        effect.details
          ? effectShrapnel
            ? effect.title +
              '\n' +
              shrapnelType +
              '\nРазмер:' +
              shrapnelMagnitude
            : effect.title
          : effect.title
      }
      tooltipPosition={effect.tooltipPosition}
    >
      {effect.content}
    </Button>
  );
};

const Extras = (props, context) => {
  const { act } = useBackend(context);
  const [compact, setCompact] = useCompact(context);

  return (
    <Stack.Item>
      <Box color="label" mb={1}>
        <b>Экстра:</b>
      </Box>
      <Box>
        <Button
          color="transparent"
          icon="list-alt"
          inline
          m={0}
          onClick={() => act('gamePanel')}
          tooltip="Гейм панель"
          tooltipPosition="top-start"
        />
        <Button
          color="transparent"
          icon="hammer"
          inline
          m={0}
          onClick={() => act('buildMode')}
          tooltip="Билд мод"
          tooltipPosition="top-start"
        />
        <Button
          color="transparent"
          icon={compact ? 'expand' : 'compress'}
          inline
          m={0}
          onClick={() => {
            setCompact(!compact);
            compact && act('refreshView');
          }}
          tooltip={compact ? 'Расширенный режим' : 'Компактный режим'}
          tooltipPosition="top-start"
        />
      </Box>
    </Stack.Item>
  );
};
