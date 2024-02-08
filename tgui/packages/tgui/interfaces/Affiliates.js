import { filter, sortBy } from "common/collections";
import { flow } from "common/fp";
import { createSearch, decodeHtmlEntities } from "common/string";
import { Fragment } from "inferno";
import { useBackend, useLocalState } from "../backend";
import { Box, Button, Flex, Icon, Input, Section, Tabs } from "../components";
import { Countdown } from "../components/Countdown";
import { FlexItem } from "../components/Flex";
import { Window } from "../layouts";
import {
  ComplexModal,
  modalAnswer,
  modalOpen,
  modalRegisterBodyOverride,
} from "./common/ComplexModal";

export const Affiliates = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window theme="syndicate">
      <ComplexModal />
      <Window.Content scrollable>
        <ExploitableInfoPage />
      </Window.Content>
    </Window>
  );
};

const ExploitableInfoPage = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { affiliates } = data;
  // Default to first

  return (
    <Section title="Affiliates">
      <Flex>
        {affiliates.map(i =>
          <Flex.Item grow={1} basis={0} key={i.key}>
            <Section
            style={{ "text-align": "center" }}>
              <img
                height="256px"
                width="256px"
                src={`data:image/jpeg;base64,${i.icon}`}
                style={{
                  "margin-left": "0px",
                  "-ms-interpolation-mode": "nearest-neighbor",
                }} />
            </Section>
            <Section title={i.name}>
              <Box>{i.desc}</Box>
            </Section>
            <Button
              content = "Выбрать подрядчика"
              onClick={
                () => act('SelectAffiliate', { path: i.path })
              }/>
          </Flex.Item>)}
      </Flex>
    </Section>
  );
};
