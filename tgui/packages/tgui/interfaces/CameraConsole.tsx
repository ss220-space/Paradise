import { filter, sort } from 'common/collections';
import { ReactNode, useState } from 'react';
import {
  Button,
  ByondUi,
  Input,
  NoticeBox,
  NanoMap,
  Section,
  Stack,
  Box,
  Tabs,
  Icon,
} from 'tgui/components';
import { BooleanLike, classes } from 'common/react';
import { createSearch } from 'common/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  activeCamera: Camera;
  cameras: Camera[];
  mapRef: string;
  stationLevelNum: number[];
  stationLevelName: string[];
};

type Camera = {
  name: string;
  x: number;
  y: number;
  z: number;
  ref: string;
  status: BooleanLike;
};

/**
 * Returns previous and next camera names relative to the currently
 * active camera.
 */
const prevNextCamera = (
  cameras: Camera[],
  activeCamera: Camera & { status: BooleanLike }
) => {
  if (!activeCamera || cameras.length < 2) {
    return [];
  }

  const index = cameras.findIndex((camera) => camera.ref === activeCamera.ref);

  switch (index) {
    case -1: // Current camera is not in the list
      return [cameras[cameras.length - 1].ref, cameras[0].ref];

    case 0: // First camera
      if (cameras.length === 2) return [cameras[1].ref, cameras[1].ref]; // Only two

      return [cameras[cameras.length - 1].ref, cameras[index + 1].ref];

    case cameras.length - 1: // Last camera
      if (cameras.length === 2) return [cameras[0].ref, cameras[0].ref];

      return [cameras[index - 1].ref, cameras[0].ref];

    default:
      // Middle camera
      return [cameras[index - 1].ref, cameras[index + 1].ref];
  }
};

/**
 * Camera selector.
 *
 * Filters cameras, applies search terms and sorts the alphabetically.
 */
const selectCameras = (cameras: Camera[], searchText = ''): Camera[] => {
  let queriedCameras = filter(cameras, (camera: Camera) => !!camera.name);
  if (searchText) {
    const testSearch = createSearch(
      searchText,
      (camera: Camera) => camera.name
    );
    queriedCameras = filter(queriedCameras, testSearch);
  }
  queriedCameras = sort(queriedCameras);

  return queriedCameras;
};

export const CameraConsole = (props) => {
  const [tabIndex, setTabIndex] = useState(0);
  return (
    <Window width={1000} height={750}>
      <Window.Content>
        <Box fillPositionedParent overflow="hidden">
          <Tabs>
            <Tabs.Tab
              key="Map"
              selected={0 === tabIndex}
              onClick={() => setTabIndex(0)}
            >
              <Icon name="map-marked-alt" /> Map
            </Tabs.Tab>
            <Tabs.Tab
              key="List"
              selected={1 === tabIndex}
              onClick={() => setTabIndex(1)}
            >
              <Icon name="table" /> List
            </Tabs.Tab>
          </Tabs>
          <CameraContent tabIndex={tabIndex} />
        </Box>
      </Window.Content>
    </Window>
  );
};

type CameraContentProps = {
  tabIndex: number;
};

export const CameraContent = (props: CameraContentProps) => {
  const [searchText, setSearchText] = useState('');

  let selector: ReactNode = '';
  switch (props.tabIndex) {
    case 0:
      selector = <CameraSelectorMap />;
      break;
    case 1:
      selector = (
        <CameraSelector searchText={searchText} setSearchText={setSearchText} />
      );
      break;
  }

  return (
    <Stack fill m={1}>
      <Stack.Item width="45%">{selector}</Stack.Item>
      <Stack.Item width="55%">
        <CameraControls searchText={searchText} />
      </Stack.Item>
    </Stack>
  );
};

const CameraSelector = (props) => {
  const { act, data } = useBackend<Data>();
  const { searchText, setSearchText } = props;
  const { activeCamera } = data;
  const cameras = selectCameras(data.cameras, searchText);

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Input
          autoFocus
          expensive
          fluid
          mt={1}
          placeholder="Search for a camera"
          onChange={setSearchText}
          value={searchText}
        />
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          {cameras.map((camera) => (
            // We're not using the component here because performance
            // would be absolutely abysmal (50+ ms for each re-render).
            <div
              key={camera.ref}
              title={camera.name}
              className={classes([
                'Button',
                'Button--fluid',
                'Button--color--transparent',
                'Button--ellipsis',
                activeCamera?.ref === camera.ref
                  ? 'Button--selected'
                  : 'candystripe',
              ])}
              onClick={() =>
                act('switch_camera', {
                  camera: camera.ref,
                })
              }
            >
              {camera.name}
            </div>
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const CameraSelectorMap = (props) => {
  const { act, data } = useBackend<Data>();
  const cameras = selectCameras(data.cameras);
  const [zoom, setZoom] = useState(1);
  const { activeCamera, stationLevelNum, stationLevelName } = data;
  const [z_current, setZCurrent] = useState(stationLevelNum[0]);

  return (
    <Box height="100%" style={{ display: 'flex' }} m={2}>
      <NanoMap
        onZoom={(e, v) => setZoom(v)}
        zLevels={stationLevelNum}
        zNames={stationLevelName}
        zCurrent={z_current}
        setZCurrent={setZCurrent}
      >
        {cameras.map((camera, index) => (
          <NanoMap.MarkerIcon
            key={index}
            x={camera.x}
            y={camera.y}
            z={camera.z}
            z_current={z_current}
            zoom={zoom}
            icon={'box'}
            tooltip={camera.name}
            tooltipPosition={camera.x > 255 / 2 ? 'bottom' : 'right'}
            color={
              camera.status
                ? camera.ref === activeCamera?.ref
                  ? 'green'
                  : 'blue'
                : 'red'
            }
            bordered
            onClick={() =>
              act('switch_camera', {
                camera: camera.ref,
              })
            }
          />
        ))}
      </NanoMap>
    </Box>
  );
};

const CameraControls = (props: { searchText: string }) => {
  const { act, data } = useBackend<Data>();
  const { activeCamera, mapRef } = data;
  const { searchText } = props;

  const cameras = selectCameras(data.cameras, searchText);

  const [prevCamera, nextCamera] = prevNextCamera(cameras, activeCamera);

  return (
    <Section fill>
      <Stack fill vertical>
        <Stack.Item>
          <Stack fill>
            <Stack.Item grow>
              {activeCamera?.status ? (
                <NoticeBox info>{activeCamera.name}</NoticeBox>
              ) : (
                <NoticeBox danger>No input signal</NoticeBox>
              )}
            </Stack.Item>

            <Stack.Item>
              <Button
                icon="chevron-left"
                disabled={!prevCamera}
                onClick={() =>
                  act('switch_camera', {
                    camera: prevCamera,
                  })
                }
              />
            </Stack.Item>

            <Stack.Item>
              <Button
                icon="chevron-right"
                disabled={!nextCamera}
                onClick={() =>
                  act('switch_camera', {
                    camera: nextCamera,
                  })
                }
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item grow>
          <ByondUi
            height="95%"
            width="100%"
            params={{
              id: mapRef,
              type: 'map',
            }}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};
