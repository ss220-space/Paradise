import { useBackend } from '../backend';
import { LabeledList, Section, ProgressBar, Button, Box, Icon } from '../components';
import { Window } from '../layouts';

const status_table = {
  0: "OFF",
  1: "NO_RIFTS",
  2: "SOME_RIFTS",
  3: "DANGER",
};

export const BluespaceRiftServer = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    emagged,
    pointsPerProbe,
    goals,
    servers,
    scanners,
  } = data;

  const goal = goalData => {
    const {
      riftId,
      riftName,
      targetResearchPoints,
      researchPoints,
      probePoints,
      rewardGiven,
    } = goalData;
    const percentage = Math.floor((researchPoints / targetResearchPoints) * 100);
    const probesLeft = Math.floor(probePoints / pointsPerProbe);
    const pointsPerProbeMessage = emagged ? ("@?%%!№@" + pointsPerProbe) : pointsPerProbe;
    const enoughProbePoints = probePoints >= pointsPerProbe;
    return (
      <Section title="Исследование Разлома">
        <Box
          color="silver"
          bold>
          {riftName}
        </Box>
        <ProgressBar
          color={percentage === 0 ? "bad" : (percentage < 100 ? "average" : "good")}
          value={researchPoints}
          maxValue={targetResearchPoints}
          mt={1} mb={2}>
          {percentage} %
        </ProgressBar>
        <Box>
          {"Данные для зондирования: "}
          <Box
            color={probePoints ? (enoughProbePoints ? "good" : "average") : "bad"}
            as="span">
            {Math.floor(probePoints)}
          </Box>
          <Button
            icon="atom"
            tooltip={"Для генерации одного зондирующего импульса нужно собрать " + pointsPerProbeMessage + " данных."}
            content={"Зондировать разлом (" + probesLeft + ")"}
            disabled={!enoughProbePoints}
            onClick={() => act('probe', {
              rift_id: riftId,
            })}
            mx={2}
          />
          <br />
          <Button
            fluid
            textAlign="center"
            content="Получить результат исследований"
            disabled={rewardGiven || (percentage < 100)}
            onClick={() => act('reward', {
              rift_id: riftId,
            })}
            mt={1.4}
          />
        </Box>
      </Section>
    );
  };
  
  const server = serverData => {
    const {
      servName,
      servData,
    } = serverData;
    return (
      <LabeledList.Item label={servName}>
        <Box>
          {servData.riftName} — {Math.floor(servData.probePoints)} данных.
        </Box>
      </LabeledList.Item>
    );
  };
  
  const scanner = scannerData => {
    const {
      scannerId,
      scannerName,
      scanStatus,
      canSwitch,
      switching,
    } = scannerData;
  
    const scanStatusTxt = status_table[scanStatus];
  
    const getStatusText = () => {
      if (scanStatusTxt === "OFF") {
        return [" ", "silver"];
      } else if (scanStatusTxt === "NO_RIFTS") {
        return ["Нет разломов", "silver"];
      } else if (scanStatusTxt === "SOME_RIFTS") {
        return ["Сканирует", "good"];
      } else if (scanStatusTxt === "DANGER") {
        return ["Опасность! Выключите сканер!", "bad"];
      }
    };
  
    const statusText = getStatusText();
  
    return (
      <LabeledList.Item label={scannerName}>
        {switching ? (
          <Icon 
            name="circle-notch"
            color="silver"
            spin
            ml={1.85} mr={1.79} my={0.83}
          />
        ) : (
          canSwitch ? (
            <Button
              icon="power-off"
              color={scanStatusTxt === "OFF" ? "bad" : "good"}
              onClick={() => act('toggle_scanner', {
                scanner_id: scannerId,
              })}
              ml={1} mr={1}
            />
          ) : (
            <Icon 
              name="power-off"
              color={scanStatusTxt === "OFF" ? "bad" : "good"}
              ml={1.85} mr={1.79}
            />
          )
        )}
        {(scanStatusTxt !== "OFF") && (
          <Box
            as="span"
            color={statusText[1]}>
            {statusText[0]}
          </Box>
        )}
      </LabeledList.Item>
    );
  };

  return (
    <Window resizable>
      <Window.Content scrollable>
        {goals && goals.map(goalData => (
          goal(goalData)
        ))}
        <Section title="Сканеры в сети">
          <LabeledList>
            {scanners && scanners.map(scannerData => (
              scanner(scannerData)
            ))}
          </LabeledList>
        </Section>
        <Section title="Серверы в сети">
          <LabeledList>
            {servers && servers.map(serverData => (
              server(serverData)
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
