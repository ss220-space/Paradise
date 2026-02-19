import { toFixed } from 'common/math';
import { useBackend } from '../../backend';
import { Button, LabeledList, NumberInput, Section } from '../../components';

export type SignalerProps = {
  code: number;
} & Frequency;

export const Signaler = (props: SignalerProps) => {
  const { act } = useBackend();
  const { code, frequency, minFrequency, maxFrequency } = props;
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Frequency">
          <NumberInput
            animated
            step={0.2}
            stepPixelSize={6}
            minValue={minFrequency / 10}
            maxValue={maxFrequency / 10}
            value={frequency / 10}
            format={(value) => toFixed(value, 1)}
            width="80px"
            onDrag={(value) =>
              act('freq', {
                freq: value,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Code">
          <NumberInput
            animated
            step={1}
            stepPixelSize={6}
            minValue={1}
            maxValue={100}
            value={code}
            width="80px"
            onDrag={(value) =>
              act('code', {
                code: value,
              })
            }
          />
        </LabeledList.Item>
      </LabeledList>
      <Button
        mt={1}
        fluid
        icon="arrow-up"
        textAlign="center"
        onClick={() => act('signal')}
      >
        Send Signal
      </Button>
    </Section>
  );
};
