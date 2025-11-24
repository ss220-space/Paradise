import {
  Section,
  Button,
  Dropdown,
  Stack,
  Input,
  NoticeBox,
} from '../../components';
import { Component } from 'react';
import { shallowDiffers } from 'common/react';
import { fetchRetry } from 'common/https';
import { resolveAsset } from '../../assets';
import { DisplayComponent } from './DisplayComponent';
import { DEFAULT_COMPONENT_MENU_LIMIT } from './constants';
import { ComponentMenuProps, ComponentMenuState } from './types';

// Cache response so it's only sent once
let fetchServerData;

export class ComponentMenu extends Component<
  ComponentMenuProps,
  ComponentMenuState
> {
  constructor(props) {
    super(props);
    this.state = {
      selectedTab: 'Всё',
      currentLimit: DEFAULT_COMPONENT_MENU_LIMIT,
      currentSearch: '',
    };
  }

  componentDidMount() {
    this.populateServerData();
  }

  async populateServerData() {
    if (!fetchServerData) {
      fetchServerData = fetchRetry(
        resolveAsset('circuit_components.json')
      ).then((response) => response.json());
    }

    const circuitData = await fetchServerData;

    this.setState({
      componentData: circuitData.sort(
        (a, b) => a.name.toLowerCase() < b.name.toLowerCase()
      ),
    });
  }

  shouldComponentUpdate(nextProps, nextState) {
    if (shallowDiffers(this.state, nextState)) {
      return true;
    }
    if (shallowDiffers(this.props.components, nextProps.components)) {
      return true;
    }
    return false;
  }

  render() {
    const {
      components = [],
      showAll = false,
      onMouseDownComponent,
      onClose,
      ...rest
    } = this.props;
    const {
      selectedTab,
      componentData = [],
      currentLimit,
      currentSearch,
    } = this.state;

    const tabs = ['Всё'];
    let shownComponents = componentData.filter((val) => {
      let shouldShow = showAll || components.includes(val.type);
      if (shouldShow) {
        if (!tabs.includes(val.category)) {
          tabs.push(val.category);
        }
        if (currentSearch !== '') {
          const result = val.name
            .toLowerCase()
            .includes(currentSearch.toLowerCase());
          return result !== false;
        }
        return selectedTab === 'Всё' || selectedTab === val.category;
      }
      return false;
    });

    const trueLength = shownComponents.length;

    // Limit the maximum amount of shown components to prevent a lagspike
    // when you open the menu
    shownComponents.length = currentLimit;
    return (
      <Section
        title="Меню компонентов"
        {...rest}
        fill
        buttons={
          <Button icon="times" color="transparent" mr={2} onClick={onClose} />
        }
        onMouseUp={(event) => {
          event.preventDefault();
        }}
        scrollable
      >
        <Stack vertical>
          <Stack.Item>
            <Dropdown
              width="100%"
              options={tabs}
              onSelected={(value) =>
                this.setState({
                  selectedTab: value,
                  currentSearch: '',
                  currentLimit: DEFAULT_COMPONENT_MENU_LIMIT,
                })
              }
              selected={selectedTab}
              placeholder="Категория"
              color="transparent"
              className="IntegratedCircuit__BlueBorder"
            />
          </Stack.Item>
          <Stack.Item>
            <Input
              placeholder="Поиск..."
              value={currentSearch}
              width="100%"
              fluid
              onChange={(val) =>
                this.setState({
                  currentSearch: val,
                  selectedTab: 'Всё',
                  currentLimit: DEFAULT_COMPONENT_MENU_LIMIT,
                })
              }
            />
          </Stack.Item>
          <Stack.Item>
            <Stack vertical fill>
              {trueLength === 0 && (
                <Stack.Item mt={1} fontSize={1}>
                  <NoticeBox info>
                    Вы можете подключить эту интегральную схему к принтеру плат,
                    что позволит вам удаленно создавать и добавлять компоненты в
                    схему.
                  </NoticeBox>
                </Stack.Item>
              )}
              {shownComponents.map((val) => (
                <Stack.Item
                  key={val.type}
                  mt={1}
                  onMouseDown={(e) => onMouseDownComponent(e, val)}
                >
                  <DisplayComponent component={val} fixedSize />
                </Stack.Item>
              ))}
              {trueLength > currentLimit && (
                <Stack.Item mt={1}>
                  <Button
                    height="32px"
                    textAlign="center"
                    py={1}
                    mb={1}
                    onClick={() =>
                      this.setState({
                        currentLimit: currentLimit + 5,
                      })
                    }
                    fluid
                  >
                    Показать больше
                  </Button>
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
        </Stack>
      </Section>
    );
  }
}
