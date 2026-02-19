import { useBackend } from '../backend';
import {
  Button,
  Flex,
  Section,
  Tooltip,
  ProgressBar,
  NoticeBox,
  Image,
} from '../components';
import { Window } from '../layouts';

export const NinjaBloodScan = (props: unknown) => {
  return (
    <Window width={500} height={400} theme="spider_clan">
      <Window.Content className="Layout__content--flexColumn">
        <BloodScanMenu />
        <FakeLoadBar />
      </Window.Content>
    </Window>
  );
};

type BloodScanData = {
  vialIcons: string[];
  noVialIcon: string;
  bloodOwnerNames: string[];
  bloodOwnerSpecies: string[];
  bloodOwnerTypes: string[];
  blockButtons: boolean;
  scanStates: string[];
  progressBar: number;
};

const BloodScanMenu = (props: unknown) => {
  const { act, data } = useBackend<BloodScanData>();
  const {
    vialIcons,
    noVialIcon,
    bloodOwnerNames,
    bloodOwnerSpecies,
    bloodOwnerTypes,
    blockButtons,
    scanStates,
  } = data;
  let rowStyles = {
    blue: 'Button_blue',
    green: 'Button_green',
    red: 'Button_red',
    disabled: 'Button_disabled',
  };
  const noticeBoxStyles = ['NoticeBox_red', 'NoticeBox', 'NoticeBox_blue'];
  const flexColumns = [1, 2, 3];
  return (
    <Flex direction="column" shrink={1} alignContent="center">
      <Section
        title={'Образцы'}
        backgroundColor="rgba(0, 0, 0, 0.4)"
        buttons={
          <Button
            tooltip={
              'Добавьте три образца крови. \
          Машина настроена на работу с кровью существ и условиями которые поставил вам клан. \
          Реагенты им не соответствующие не примутся или сканирование не будет успешным'
            }
            tooltipPosition="bottom-start"
          >
            ?
          </Button>
        }
      >
        <Flex direction="row" shrink={1} alignContent="center">
          {flexColumns.map((x, i) => (
            <Flex.Item direction="column" width="33.3%" ml={i ? 2 : 0} key={i}>
              <Section
                title={bloodOwnerNames[i] ? 'Кровь' : 'Нет реагента'}
                style={{
                  textAlign: 'left',
                  background: 'rgba(53, 94, 163, 0.5)',
                }}
              />
              <NoticeBox
                className={noticeBoxStyles[scanStates[i]]}
                align="center"
              >
                <Button
                  className={
                    !blockButtons ? rowStyles.blue : rowStyles.disabled
                  }
                  height="100%"
                  width="100%"
                  disabled={blockButtons}
                  onClick={() => act('vial_out', { button_num: i + 1 })}
                >
                  <Image
                    height="128px"
                    width="128px"
                    src={`data:image/jpeg;base64,${vialIcons[i] || noVialIcon}`}
                    style={{
                      marginLeft: '3px',
                    }}
                  />
                  <Tooltip
                    content={
                      `Раса: ${bloodOwnerSpecies[i] || ' - '}` +
                      '\n' +
                      `Тип крови: ${bloodOwnerTypes[i] || ' - '}`
                    }
                    position="bottom"
                  >
                    {bloodOwnerNames[i] || ' - '}
                  </Tooltip>
                </Button>
              </NoticeBox>
            </Flex.Item>
          ))}
        </Flex>
        <NoticeBox className="NoticeBox_red" align="center">
          <Button
            className={!blockButtons ? '' : 'Button_disabled'}
            width="250px"
            textAlign="center"
            disabled={blockButtons}
            tooltip={
              'Сканирует кровь и пересылает полученную информацию клану.'
            }
            tooltipPosition="bottom"
            onClick={() => act('scan_blood')}
          >
            Начать сканирование
          </Button>
        </NoticeBox>
      </Section>
    </Flex>
  );
};

const FakeLoadBar = (properties) => {
  const { data } = useBackend<BloodScanData>();
  const { progressBar } = data;
  return (
    <Section stretchContents>
      <ProgressBar
        color="green"
        value={progressBar}
        minValue={0}
        maxValue={100}
      >
        <center>
          <NoticeBox className={'NoticeBox_green'} mt={1}>
            {progressBar ? `Загрузка ${progressBar + '%'}` : `Режим ожидания`}
          </NoticeBox>
        </center>
      </ProgressBar>
    </Section>
  );
};
