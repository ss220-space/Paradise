import { useBackend } from '../backend';
import { Box, Button, LabeledList, ProgressBar, Section } from '../components';
import { Window } from '../layouts';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

export const APC = (props: unknown) => {
  return (
    <Window width={510} height={435}>
      <Window.Content>
        <ApcContent />
      </Window.Content>
    </Window>
  );
};

const powerStatusMap = {
  2: {
    color: 'good',
    externalPowerText: 'External Power',
    chargingText: 'Fully Charged',
  },
  1: {
    color: 'average',
    externalPowerText: 'Low External Power',
    chargingText: 'Charging',
  },
  0: {
    color: 'bad',
    externalPowerText: 'No External Power',
    chargingText: 'Not Charging',
  },
};

const malfMap = {
  1: {
    icon: 'terminal',
    content: 'Override Programming',
    action: 'hack',
  },
  2: {
    icon: 'caret-square-down',
    content: 'Shunt Core Process',
    action: 'occupy',
  },
  3: {
    icon: 'caret-square-left',
    content: 'Return to Main Core',
    action: 'deoccupy',
  },
  4: {
    icon: 'caret-square-down',
    content: 'Shunt Core Process',
    action: 'occupy',
  },
};

type APCData = {
  locked: boolean;
  isOperating: boolean;
  siliconUser: boolean;
  chargeMode: boolean;
  malfStatus: number;
  externalPower: number;
  chargingStatus: number;
  powerCellStatus: number;
  totalLoad: number;
  coverLocked: boolean;
  nightshiftLights: boolean;
  emergencyLights: boolean;
  powerChannels: Channel[];
};

type Channel = {
  title: string;
  status: number;
  powerLoad: number;
  topicParams: TopicParams;
};

type TopicParams = {
  on: object;
  off: object;
  auto: object;
};

const ApcContent = (props: unknown) => {
  const { act, data } = useBackend<APCData>();
  const locked = data.locked && !data.siliconUser;
  const externalPowerStatus =
    powerStatusMap[data.externalPower] || powerStatusMap[0];
  const chargingStatus =
    powerStatusMap[data.chargingStatus] || powerStatusMap[0];
  const channelArray = data.powerChannels || [];
  const malfStatus = malfMap[data.malfStatus] || malfMap[0];
  const adjustedCellChange = data.powerCellStatus / 100;

  return (
    <>
      <InterfaceLockNoticeBox />
      <Section title="Power Status">
        <LabeledList>
          <LabeledList.Item
            label="Main Breaker"
            color={externalPowerStatus.color}
            buttons={
              <Button
                icon={data.isOperating ? 'power-off' : 'times'}
                selected={data.isOperating && !locked}
                color={data.isOperating ? '' : 'bad'}
                disabled={locked}
                onClick={() => act('breaker')}
              >
                {data.isOperating ? 'On' : 'Off'}
              </Button>
            }
          >
            [ {externalPowerStatus.externalPowerText} ]
          </LabeledList.Item>
          <LabeledList.Item label="Power Cell">
            <ProgressBar color="good" value={adjustedCellChange} />
          </LabeledList.Item>
          <LabeledList.Item
            label="Charge Mode"
            color={chargingStatus.color}
            buttons={
              <Button
                icon={data.chargeMode ? 'sync' : 'times'}
                selected={data.chargeMode}
                disabled={locked}
                onClick={() => act('charge')}
              >
                {data.chargeMode ? 'Auto' : 'Off'}
              </Button>
            }
          >
            [ {chargingStatus.chargingText} ]
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Power Channels">
        <LabeledList>
          {channelArray.map((channel) => {
            const { topicParams } = channel;
            return (
              <LabeledList.Item
                key={channel.title}
                label={channel.title}
                buttons={
                  <>
                    <Box
                      inline
                      mx={2}
                      color={channel.status >= 2 ? 'good' : 'bad'}
                    >
                      {channel.status >= 2 ? 'On' : 'Off'}
                    </Box>
                    <Button
                      icon="sync"
                      selected={
                        !locked &&
                        (channel.status === 1 || channel.status === 3)
                      }
                      disabled={locked}
                      onClick={() => act('channel', topicParams.auto)}
                    >
                      Auto
                    </Button>
                    <Button
                      icon="power-off"
                      selected={!locked && channel.status === 2}
                      disabled={locked}
                      onClick={() => act('channel', topicParams.on)}
                    >
                      On
                    </Button>
                    <Button
                      icon="times"
                      selected={!locked && channel.status === 0}
                      disabled={locked}
                      onClick={() => act('channel', topicParams.off)}
                    >
                      Off
                    </Button>
                  </>
                }
              >
                {channel.powerLoad} W
              </LabeledList.Item>
            );
          })}
          <LabeledList.Item label="Total Load">
            <b>{data.totalLoad} W</b>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Misc"
        buttons={
          !!data.siliconUser && (
            <>
              {!!data.malfStatus && (
                <Button
                  icon={malfStatus.icon}
                  color="bad"
                  onClick={() => act(malfStatus.action)}
                >
                  {malfStatus.content}
                </Button>
              )}
              <Button icon="lightbulb-o" onClick={() => act('overload')}>
                Overload
              </Button>
            </>
          )
        }
      >
        <LabeledList>
          <LabeledList.Item
            label="Cover Lock"
            buttons={
              <Button
                mb={0.4}
                icon={data.coverLocked ? 'lock' : 'unlock'}
                disabled={locked}
                onClick={() => act('cover')}
              >
                {data.coverLocked ? 'Engaged' : 'Disengaged'}
              </Button>
            }
          />
          <LabeledList.Item
            label="Night Shift Lighting"
            buttons={
              <Button
                icon="lightbulb-o"
                onClick={() => act('toggle_nightshift')}
              >
                {data.nightshiftLights ? 'Enabled' : 'Disabled'}
              </Button>
            }
          />
          <LabeledList.Item
            label="Emergency Lighting Fallback"
            buttons={
              <Button
                mt={0.4}
                icon="lightbulb-o"
                disabled={locked}
                onClick={() => act('emergency_lighting')}
              >
                {data.emergencyLights ? 'Engaged' : 'Disengaged'}
              </Button>
            }
          />
        </LabeledList>
      </Section>
    </>
  );
};
