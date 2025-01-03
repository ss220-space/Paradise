import { toFixed } from 'common/math';

import { useBackend } from '../../backend';
import { Knob, LabeledControls } from '../../components';
import { PodDelay, PodLauncherData } from './types';

type Props = {
  delay_list: PodDelay[];
  reverse?: boolean;
};

export const DelayHelper = (props, context) => {
  const { act, data } = useBackend<PodLauncherData>(context);
  const { delays, rev_delays } = data;
  const { delay_list, reverse = false } = props;

  return (
    <LabeledControls
      wrap
      style={{
        'flex-direction': 'column',
        'flex-wrap': 'wrap',
        'height': '7.5em',
        'justify-content': 'start',
      }}
    >
      {delay_list.map((delay, i) => (
        <LabeledControls.Item
          key={i}
          label={delay.title}
          style={{
            'flex-direction': 'column',
            'min-width': '0',
          }}
        >
          <Knob
            color={
              (reverse ? rev_delays[i + 1] : delays[i + 1]) / 10 > 10
                ? 'orange'
                : 'default'
            }
            format={(value) => toFixed(value, 2)}
            maxValue={10}
            minValue={0}
            inline
            onDrag={(e, value) => {
              act('editTiming', {
                reverse: reverse,
                timer: '' + (i + 1),
                value: Math.max(value, 0),
              });
            }}
            size={1}
            step={0.02}
            unclamped
            unit="s"
            value={(reverse ? rev_delays[i + 1] : delays[i + 1]) / 10}
          />
        </LabeledControls.Item>
      ))}
    </LabeledControls>
  );
};
