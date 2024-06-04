import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Flex, Input, LabeledList, NumberInput} from '../components';
import { Window } from '../layouts';
import { FlexItem } from '../components/Flex';

export const PassportSet = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    ownerInfo,
    nation
  } = data;

  const [
    settedName,
    setName,
  ] = useLocalState(context, 'Name', ownerInfo.name);

  const [
    settedStation,
    setStation,
  ] = useLocalState(context, 'Station', ownerInfo.work["station"]);

  const [
    settedCommand,
    setCommand,
  ] = useLocalState(context, 'Command', ownerInfo.work["command"]);

  const [
    settedSystem,
    setSystem,
  ] = useLocalState(context, 'System', ownerInfo.work["system"]);

  const [
    settedYear,
    setYear,
  ] = useLocalState(context, 'Year', ownerInfo.year);

  return (
    <Window resizable>
      <Window.Content scrollable>
        <Flex>
          <FlexItem grow="1">
            <Section title="Info">
              <LabeledList>
                <LabeledList.Item label="Имя">
                  <Box>
                    <Input
                      width="80%"
                      placeholder="Имя"
                      onInput={(e, v) => setName(v)}
                    />
                    <Button
                      icon="pencil-alt"
                      onClick={() => act("set", {
                        type: 'Name',
                        content: settedName,
                        auto: false,
                      })}
                    />
                    <Button
                      icon="sync"
                      onClick={() => act("set", {
                        type: 'Name',
                        content: "",
                        auto: true,
                      })}
                    />
                  </Box>
                </LabeledList.Item>
                <LabeledList.Item label="Пол">
                  <Button
                    content="Выбрать"
                    onClick={() => act("set", {
                      type: 'Gender',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Раса">
                  <Button
                    content="Выбрать"
                    onClick={() => act("set", {
                      type: 'Race',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Год рождения">
                  <Input
                    width="80%"
                    onInput={(e, v) => setYear(v)}
                  />
                  <Button
                    icon="pencil-alt"
                    onClick={() => act("set", {
                      type: 'Age',
                      content: settedYear,
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Работа">
                  <Box>
                  <Input
                      width="80%"
                      placeholder="Станция"
                      onInput={(e, v) => setStation(v)}
                    />
                    <Button
                      icon="pencil-alt"
                      onClick={() => act("set", {
                        type: 'Station',
                        content: settedStation,
                        auto: false,
                      })}
                    />
                    <Button
                      icon="sync"
                      onClick={() => act("set", {
                        type: 'Station',
                        content: "",
                        auto: true,
                      })}
                    />
                  </Box>
                  <Box>
                    <Input
                      width="80%"
                      placeholder="Командование"
                      onInput={(e, v) => setCommand(v)}
                    />
                    <Button
                      icon="pencil-alt"
                      onClick={() => act("set", {
                        type: 'Command',
                        content: settedCommand,
                        auto: false,
                      })}
                    />
                    <Button
                      icon="sync"
                      onClick={() => act("set", {
                        type: 'Command',
                        content: "",
                        auto: true,
                      })}
                    />
                  </Box>
                  <Box>
                    <Input
                      width="80%"
                      placeholder="Система"
                      onInput={(e, v) => setSystem(v)}
                    />
                    <Button
                      icon="pencil-alt"
                      onClick={() => act("set", {
                        type: 'System',
                        content: settedSystem,
                        auto: false,
                      })}
                    />
                    <Button
                      icon="sync"
                      onClick={() => act("set", {
                        type: 'System',
                        content: "",
                        auto: true,
                      })}
                    />
                  </Box>
                </LabeledList.Item>
                <LabeledList.Item label="Мусор">
                  <Button
                    content="Генерировать"
                    onClick={() => act("set", {
                      type: 'Rand',
                    })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Государство">
                  <Button
                    content="Выбрать"
                    onClick={() => act("set", {
                      type: 'Nation',
                    })}
                  />
                </LabeledList.Item>
              </LabeledList>
              <p/>
              <Box textAlign="center">
                <Button
                  content="Завершить"
                  textAlign="center"
                  selected={true}
                  onClick={() => act("Finish")}
                />
              </Box>
            </Section>
          </FlexItem>
          <FlexItem grow="1">
            <Section title="Preview"
              buttons={
                <Button
                  icon="camera"
                  onClick={() => act("set", {
                    type: 'Photo',
                  })}
                />}>
              <LabeledList>
                <LabeledList.Item label="Фото">
                  <Section width="200px" textAlign="center" className="picture">
                    <img
                      height="96px"
                      width="96px"
                      src={`data:image/jpeg;base64,${ownerInfo.front}`}
                      style={{
                        "margin-left": "-6px",
                        "-ms-interpolation-mode": "nearest-neighbor",
                      }} />
                    <img
                      height="96px"
                      width="96px"
                      src={`data:image/jpeg;base64,${ownerInfo.side}`}
                      style={{
                        "margin-left": "-6px",
                        "-ms-interpolation-mode": "nearest-neighbor",
                      }} />
                  </Section>
                </LabeledList.Item>
                <LabeledList.Item label="Имя">
                  <Box>{ownerInfo.name}</Box>
                </LabeledList.Item>
                <LabeledList.Item label="Пол">
                  <Box>{ownerInfo.gender}</Box>
                </LabeledList.Item>
                <LabeledList.Item label="Раса">
                  <Box>{ownerInfo.race}</Box>
                </LabeledList.Item>
                <LabeledList.Item label="Год рождения">
                  <Box>{ownerInfo.year}</Box>
                </LabeledList.Item>
                <LabeledList.Item label="Работа">
                  <Box>{ownerInfo.work["station"]}</Box>
                  <Box>{ownerInfo.work["command"]}</Box>
                  <Box>{ownerInfo.work["system"]}</Box>
                </LabeledList.Item>
                <LabeledList.Item label="Мусор">
                  <Box>{ownerInfo.rand}</Box>
                </LabeledList.Item>
                <LabeledList.Item label="Государство">
                  <Box>{nation}</Box>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </FlexItem>
        </Flex>
      </Window.Content>
    </Window>
  );
};
