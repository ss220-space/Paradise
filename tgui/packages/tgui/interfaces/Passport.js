import { Fragment } from "inferno";
import { useBackend } from "../backend";
import { Button, Box, Section, Flex, Icon, Divider } from "../components";
import { Window } from "../layouts";

export const Passport = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    ownerInfo,
    nation
  } = data;

  const stamps = new Map([
    ['tsf', 'large_stamp-solgov.png'],
    ['ussp', 'large_stamp-ussp.png']
  ])

  return (
    <Window theme={"passport"+nation}>
      <Window.Content scrollable>
        <Flex direction="column" height="100%">
          <Flex.Item basis="49%">
            <Flex direction="column">
              <Flex.Item grow="2">
                <Flex className="up_half">
                  <Flex.Item>
                    <Box className="gerb_place" height="100px" width="140px"/>
                  </Flex.Item>
                  <Flex.Item>
                    <Box className="stamp_place" height="100px" width="100%" textAlign="center">
                      <img src={stamps.get(nation)}
                      height="100%"
                      style={{
                        "-ms-interpolation-mode": "nearest-neighbor",
                      }} />
                    </Box>
                  </Flex.Item>
                </Flex>
              </Flex.Item>
              <Flex.Item Align="center">
                <Box class="work_place" textAlign="left" height="80px" width="99%">
                  <b>Авторизационная запись ОК Nanotrasen:</b><br/>
                  <b>Текущее место работы:</b>
                  {ownerInfo.work.station}<br/>
                  <b>Административный отдел:</b>
                  {ownerInfo.work.command}<br/>
                  <b>Система влияния:</b>
                  {ownerInfo.work.system}<br/>
                </Box>
              </Flex.Item>
            </Flex>
          </Flex.Item>
          <Flex.Item basis="2%" style={{"margin-bottom": "20px"}}><Divider/></Flex.Item>
          <Flex.Item basis="49%">
            <Flex direction="column" className="down_half">
              <Flex.Item>
                <Flex>
                  <Flex.Item>
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
                    </Flex.Item>
                    <Flex.Item style={{'margin-left': '20px', 'margin-top': '-10px'}}>
                      <b>Имя:</b> {ownerInfo.name}
                      <p/>
                      <b>Год рождения:</b> {ownerInfo.year}
                      <p/>
                      <b>Пол:</b> {ownerInfo.gender}
                      <p/>
                      <b>Вид:</b> {ownerInfo.race}
                      <p/>
                    </Flex.Item>
                  </Flex>
                </Flex.Item>
                <Flex.Item>
                  <Box className="rand">
                    {ownerInfo.rand}
                  </Box>
                </Flex.Item>
              </Flex>
            </Flex.Item>
          </Flex>
      </Window.Content>
    </Window>
  );
};
