import { BooleanLike } from 'common/react';
import { toTitleCase } from 'common/string';

import { useBackend } from '../backend';
import {
  Button,
  Icon,
  Image,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type Data = {
  hasItem: BooleanLike;
  isOnCooldown: BooleanLike;
  isServerConnected: BooleanLike;
  availableExperiments: Experiment[];
  loadedItem: Item;
  isCloning: BooleanLike;
};

type Experiment = {
  id: string;
  name: string;
  fa_icon: string;
};

type Item = {
  name: string;
  icon: string;
  associatedNodes: Node[];
};

type Node = {
  name: string;
  current_tech: number;
  added_tech: number;
};

export const Experimentator = (_props: unknown) => {
  const { act, data } = useBackend<Data>();
  const {
    hasItem,
    isOnCooldown,
    isServerConnected,
    isCloning,
    loadedItem,
    availableExperiments = [],
  } = data;

  return (
    <Window width={550} height={350} title="E.X.P.E.R.I-MENTOR">
      <Window.Content>
        {isServerConnected ? (
          hasItem && loadedItem ? (
            <>
              {!!isCloning && (
                <Stack.Item grow>
                  <NoticeBox warning>
                    Cloning mode activated! Experements blocked until cloning
                    procces end/
                  </NoticeBox>
                </Stack.Item>
              )}
              <ExperimentScreen
                item={loadedItem}
                experiments={availableExperiments}
                isOnCooldown={isOnCooldown}
                isCloning={isCloning}
                onEject={() => act('eject')}
                onExperiment={(id) => act('experiment', { id: id })}
              />
            </>
          ) : (
            <NoticeBox danger textAlign="center">
              No item present in experimentation chamber. Please insert one.
            </NoticeBox>
          )
        ) : (
          <NoticeBox danger textAlign="center">
            Not connected to a server. RND console must be nearby.
          </NoticeBox>
        )}
      </Window.Content>
    </Window>
  );
};

type ExperimentScreenProps = {
  item: Item;
  experiments: Experiment[];
  isOnCooldown: BooleanLike;
  isCloning: BooleanLike;
  onEject: () => void;
  onExperiment: (id: string) => void;
};

const ExperimentScreen = (props: ExperimentScreenProps) => {
  const { item, experiments, isOnCooldown, isCloning, onEject, onExperiment } =
    props;
  const { name, icon, associatedNodes } = item;

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item grow>
            <ItemPreview name={name} icon={icon} onEject={onEject} />
          </Stack.Item>
          <Stack.Item grow>
            <NodePreview nodes={associatedNodes} />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <ExperimentButtons
          disabled={isOnCooldown || isCloning}
          experiments={experiments}
          onExperiment={onExperiment}
        />
      </Stack.Item>
    </Stack>
  );
};

type ItemPreviewProps = {
  name: string;
  icon: string;
  onEject: () => void;
};

const ItemPreview = (props: ItemPreviewProps) => {
  const { name, icon, onEject } = props;

  return (
    <Stack fill vertical align="center">
      <Stack.Item align="stretch">
        <Stack fill>
          <Stack.Item>
            <Button
              fluid
              color="bad"
              icon="eject"
              height="100%"
              fontSize={1.5}
              tooltip="Eject"
              textAlign="center"
              onClick={() => onEject()}
              verticalAlignContent="middle"
            />
          </Stack.Item>
          <Stack.Item grow>
            <Section fill bold textAlign="center">
              {toTitleCase(name)}
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill vertical align="center" justify="center">
          <Stack.Item>
            <Image
              width="128px"
              height="128px"
              src={`data:image/jpeg;base64,${icon}`}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

type NodePreviewProps = {
  nodes: Node[];
};

const NodePreview = (props: NodePreviewProps) => {
  const { nodes } = props;

  return (
    <Section fill title="Research Tech">
      {nodes.length > 0 ? (
        <LabeledList>
          {nodes.map((node, index) => (
            <LabeledList.Item
              key={index}
              label={node.name}
              color={node.added_tech ? 'good' : 'bad'}
            >
              {node.current_tech +
                (node.added_tech ? ' + ' + node.added_tech : '')}
            </LabeledList.Item>
          ))}
        </LabeledList>
      ) : (
        <Stack fill vertical align="center" justify="center">
          <Stack.Item className="hypertorus__unselectable">
            <Icon
              fontSize={4}
              name="circle-question"
              className={'FabricatorRecipe__Title--disabled'}
            />
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};

type ExperimentButtonsProps = {
  disabled: BooleanLike;
  experiments: Experiment[];
  onExperiment: (id: string) => void;
};

const ExperimentButtons = (props: ExperimentButtonsProps) => {
  const { disabled, experiments, onExperiment } = props;

  return (
    <Section fill>
      <Stack fill>
        {experiments.map((exp) => (
          <Stack.Item key={exp.id}>
            <Button
              width={3}
              height={3}
              fontSize={1.6}
              textAlign="center"
              disabled={disabled}
              tooltip={exp.name}
              verticalAlignContent="middle"
              icon={exp.fa_icon}
              onClick={() => onExperiment(exp.id)}
            />
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};
