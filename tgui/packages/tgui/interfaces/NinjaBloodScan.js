import { useBackend } from '../backend';
import { Box, Button, Flex, LabeledList, Section, Tooltip, Table, NoticeBox } from '../components';
import { FlexItem } from '../components/Flex';
import { Window } from '../layouts';

export const NinjaBloodScan = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window resizable theme="spider_clan">
      <Window.Content className="Layout__content--flexColumn">
        <BloodScanMenu />
      </Window.Content>
    </Window>
  );
};

const BloodScanMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    vialIcons,
    noVialIcon,
    bloodOwnerNames,
    bloodOwnerSpecies,
    bloodOwnerTypes,
    blockButtons,
  } = data;
  let rowStyles = { blue: "Button_blue", green: "Button_green", red: "Button_red", disabled: "Button_disabled" };
  const flexColumns = [1, 2, 3]
  return (
    <Flex
      direction="column"
      shrink={1}
      alignContent="center">
      <Section title={"Образцы"}
        backgroundColor="rgba(0, 0, 0, 0.4)"
        buttons={<Button
          content="?"
          tooltip={"Добавьте три образца необходимого реагента. \
          Машина настроена на работу с реагентами и условиями которые поставил вам клан. \
          Реагенты им не подходящие не примутся или сканирование не будет успешным"}
          tooltipPosition="bottom-left" />}>

        <Flex
          direction="row"
          shrink={1}
          alignContent="center">
          {flexColumns.map((x, i) =>
          (<FlexItem
            direction="column"
            width="33.3%"
            ml={i ? 2 : 0}>

            <Section title={bloodOwnerNames[i] ? "Кровь" : "Нет реагента"}
              style={{ "text-align": "left", "background": "rgba(53, 94, 163, 0.5)" }}>
            </Section>
            <NoticeBox className="NoticeBox_blue" success={0} danger={0} align="center">
              <Button
                className={!blockButtons ? rowStyles.blue : rowStyles.disabled}
                height="100%"
                width="100%"
                disabled={blockButtons}
                onClick={() => act("vial_out", { button_num: i })}>
                <img
                  height="128px"
                  width="128px"
                  src={`data:image/jpeg;base64,${vialIcons[i] || noVialIcon}`}
                  style={{
                    "margin-left": "3px",
                    "-ms-interpolation-mode": "nearest-neighbor",
                  }} />
                <Tooltip
                  title={bloodOwnerNames[i] || " - "}
                  content={`Раса: ${bloodOwnerSpecies[i] || " - "}` + "\n" + `Тип крови: ${bloodOwnerTypes[i] || " - "}`}
                  position="bottom" />
              </Button>
            </NoticeBox>
          </FlexItem>)
          )}

        </Flex>
        <NoticeBox className="NoticeBox_red"
          success={0}
          danger={0}
          align="center">
          <Button
            className={blockButtons === 0 ? "" : "Button_disabled"}
            content="Начать сканирование"
            width="250px"
            textAlign="center"
            disabled={blockButtons}
            tooltip={"Сканирует реагенты и пересылает полученную информацию клану."}
            tooltipPosition="bottom"
            onClick={() => act('scan_blood')} />
        </NoticeBox>
      </Section>
    </Flex >
  );
};
