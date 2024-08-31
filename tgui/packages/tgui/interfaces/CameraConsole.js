import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { classes } from 'common/react';
import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import {
  Button,
  ByondUi,
  Input,
  Section,
  Stack,
  Box,
  NanoMap,
  Tabs,
  Icon,
} from '../components';
import { Window } from '../layouts';

/**
 * A crutch which, after selecting a camera in the list,
 * allows you to scroll further,
 * as the focus does not shift to the button using overflow.
 * Please, delete that shit if there's a better way.
 */
String.prototype.trimLongStr = function (length) {
  return this.length > length ? this.substring(0, length) + '...' : this;
};

/**
 * Returns previous and next camera names relative to the currently
 * active camera.
 */
const prevNextCamera = (cameras, activeCamera) => {
  if (!activeCamera) {
    return [];
  }
  const index = cameras.findIndex(
    (camera) => camera.name === activeCamera.name
  );
  return [cameras[index - 1]?.name, cameras[index + 1]?.name];
};

/**
 * Camera selector.
 *
 * Filters cameras, applies search terms and sorts the alphabetically.
 */
const selectCameras = (cameras, searchText = '') => {
  const testSearch = createSearch(searchText, (camera) => camera.name);
  return flow([
    // Null camera filter
    filter((camera) => camera?.name),
    // Optional search term
    searchText && filter(testSearch),
    // Slightly expensive, but way better than sorting in BYOND
    sortBy((camera) => camera.name),
  ])(cameras);
};

export const CameraConsole = (props, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const decideTab = (index) => {
    switch (index) {
      case 0:
        return <CameraConsoleMapContent />;
      case 1:
        return <CameraConsoleOldContent />;
      default:
        return "WE SHOULDN'T BE HERE!";
    }
  };

  return (
    <Window width={1250} height={600}>
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
          {decideTab(tabIndex)}
        </Box>
      </Window.Content>
    </Window>
  );
};

export const CameraConsoleMapContent = (props, context) => {
  const { act, data } = useBackend(context);
  const cameras = selectCameras(data.cameras);
  const [zoom, setZoom] = useLocalState(context, 'zoom', 1);
  const { mapRef, activeCamera, stationLevelNum, stationLevelName } = data;
  const [z_current, setZCurrent] = useLocalState(
    context,
    'z_current',
    stationLevelNum[0]
  );
  const [prevCameraName, nextCameraName] = prevNextCamera(
    cameras,
    activeCamera
  );

  return (
    <Box height="100%" display="flex">
      <div className="CameraConsole__left">
        <Box height="100%" display="flex">
          <NanoMap
            onZoom={(v) => setZoom(v)}
            zLevels={stationLevelNum}
            zNames={stationLevelName}
            z_current={z_current}
            setZCurrent={setZCurrent}
          >
            {cameras.map((cm) => (
              <NanoMap.Marker
                key={cm.ref}
                x={cm.x}
                y={cm.y}
                z={cm.z}
                z_current={z_current}
                zoom={zoom}
                icon={'box'}
                tooltip={cm.name}
                color={cm.status ? 'blue' : 'red'}
                bordered
                onClick={() =>
                  act('switch_camera', {
                    name: cm.name,
                  })
                }
              />
            ))}
          </NanoMap>
        </Box>
      </div>
      <div className="CameraConsole__right">
        <div className="CameraConsole__toolbar">
          <b>Camera: </b>
          {(activeCamera && activeCamera.name) || '—'}
        </div>
        <div className="CameraConsole__toolbarRight">
          <Button
            icon="chevron-left"
            disabled={!prevCameraName}
            onClick={() =>
              act('switch_camera', {
                name: prevCameraName,
              })
            }
          />
          <Button
            icon="chevron-right"
            disabled={!nextCameraName}
            onClick={() =>
              act('switch_camera', {
                name: nextCameraName,
              })
            }
          />
        </div>
        <ByondUi
          className="CameraConsole__map"
          params={{
            id: mapRef,
            type: 'map',
          }}
        />
      </div>
    </Box>
  );
};

export const CameraConsoleOldContent = (props, context) => {
  const { act, data, config } = useBackend(context);
  const { mapRef, activeCamera } = data;
  const [searchText] = useLocalState(context, 'searchText', '');
  const cameras = selectCameras(data.cameras, searchText);
  const [prevCameraName, nextCameraName] = prevNextCamera(
    cameras,
    activeCamera
  );
  return (
    <Box>
      <div className="CameraConsole__left">
        <Window.Content>
          <Stack fill vertical>
            <CameraConsoleListContent />
          </Stack>
        </Window.Content>
      </div>
      <div className="CameraConsole__right">
        <div className="CameraConsole__toolbar">
          <b>Camera: </b>
          {(activeCamera && activeCamera.name) || '—'}
        </div>
        <div className="CameraConsole__toolbarRight">
          <Button
            icon="chevron-left"
            disabled={!prevCameraName}
            onClick={() =>
              act('switch_camera', {
                name: prevCameraName,
              })
            }
          />
          <Button
            icon="chevron-right"
            disabled={!nextCameraName}
            onClick={() =>
              act('switch_camera', {
                name: nextCameraName,
              })
            }
          />
        </div>
        <ByondUi
          className="CameraConsole__map"
          params={{
            id: mapRef,
            type: 'map',
          }}
        />
      </div>
    </Box>
  );
};

export const CameraConsoleListContent = (props, context) => {
  const { act, data } = useBackend(context);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const { activeCamera } = data;
  const cameras = selectCameras(data.cameras, searchText);
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Input
          fluid
          placeholder="Search for a camera"
          onInput={(e, value) => setSearchText(value)}
        />
      </Stack.Item>
      <Stack.Item grow m={0}>
        <Section fill scrollable>
          {cameras.map((camera) => (
            // We're not using the component here because performance
            // would be absolutely abysmal (50+ ms for each re-render).
            <div
              key={camera.name}
              title={camera.name}
              className={classes([
                'Button',
                'Button--fluid',
                'Button--color--transparent',
                activeCamera &&
                  camera.name === activeCamera.name &&
                  'Button--selected',
              ])}
              onClick={() =>
                act('switch_camera', {
                  name: camera.name,
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
