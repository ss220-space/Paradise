import { BooleanLike } from 'common/react';
import { Component } from 'react';
import { useBackend, useSharedState } from '../backend';
import {
  Button,
  LabeledList,
  NumberInput,
  Section,
  Dropdown,
  Box,
  Flex,
} from '../components';
import { Window } from '../layouts';

type LightningBoltData = {
  x_coord: number;
  y_coord: number;
  z_coord: number;
  mode: string;
  damage: number;
  radius: number;
  delay: number;
  ckey: string;
  players: Record<string, string>;
  pointing: BooleanLike;
};

interface DropLightningBoltProps {
  act: (action: string, params?: any) => void;
  data: LightningBoltData;
}

interface DropLightningBoltState {
  mode: string;
  autoupdate: boolean;
}

class DropLightningBoltComponent extends Component<
  DropLightningBoltProps,
  DropLightningBoltState
> {
  private readonly availableModes: string[] = [
    'По игроку',
    'По координатам',
    'По указателю',
  ];

  constructor(props: DropLightningBoltProps) {
    super(props);
    this.state = {
      mode: '',
      autoupdate: true,
    };
  }

  private handleModeChange = (selectedMode: string): void => {
    this.setState({ mode: selectedMode });
    this.props.act('set_mode', { mode: selectedMode });

    if (selectedMode === 'По координатам') {
      const { x_coord, y_coord, z_coord } = this.props.data;
      this.props.act('set_coords', {
        x_coord,
        y_coord,
        z_coord,
      });
    }
  };

  private handleDamageChange = (damage: number): void => {
    this.props.act('set_damage', { damage });
  };

  private handleRadiusChange = (radius: number): void => {
    this.props.act('set_radius', { radius });
  };

  private handleDelayChange = (delay: number): void => {
    this.props.act('set_delay', { delay });
  };

  private handlePlayerSelect = (selectedPlayer: string): void => {
    const { players } = this.props.data;
    const selectedCkey = Object.keys(players).find(
      (key) => players[key] === selectedPlayer
    );
    this.props.act('pickPlayer', { ckey: selectedCkey });
  };

  private handleAutoupdateToggle = (): void => {
    this.setState((prevState) => {
      const newValue = !prevState.autoupdate;
      this.props.act('set_autoupdate', { val: newValue });
      return { autoupdate: newValue };
    });
  };

  private handleCoordinateChange = (
    coord: 'x' | 'y' | 'z',
    value: number
  ): void => {
    const { x_coord, y_coord, z_coord } = this.props.data;
    const coords = {
      x_coord: coord === 'x' ? value : x_coord,
      y_coord: coord === 'y' ? value : y_coord,
      z_coord: coord === 'z' ? value : z_coord,
    };
    this.props.act('set_coords', coords);
  };

  private handlePointingToggle = (): void => {
    const { pointing } = this.props.data;
    this.props.act('set_pointing', { val: !pointing });
  };

  private handleDropLightning = (): void => {
    this.props.act('drop');
  };

  private renderPlayerMode(): JSX.Element {
    const { players, ckey } = this.props.data;

    return (
      <LabeledList>
        <LabeledList.Item
          label="Игрок"
          buttons={
            <Dropdown
              width="150px"
              options={Object.values(players)}
              selected={players[ckey] || ckey}
              onSelected={this.handlePlayerSelect}
            />
          }
        />
      </LabeledList>
    );
  }

  private renderCoordinateMode(): JSX.Element {
    const { x_coord, y_coord, z_coord } = this.props.data;
    const { autoupdate } = this.state;

    return (
      <LabeledList>
        <LabeledList.Item label="Автообновление">
          <Button
            icon={autoupdate ? 'toggle-on' : 'toggle-off'}
            selected={autoupdate}
            onClick={this.handleAutoupdateToggle}
          />
        </LabeledList.Item>
        <LabeledList.Item label="X">
          <NumberInput
            maxValue={255}
            minValue={0}
            step={1}
            value={x_coord}
            onChange={(val) => this.handleCoordinateChange('x', val)}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Y">
          <NumberInput
            maxValue={255}
            minValue={0}
            step={1}
            value={y_coord}
            onChange={(val) => this.handleCoordinateChange('y', val)}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Z">
          <NumberInput
            maxValue={255}
            minValue={0}
            step={1}
            value={z_coord}
            onChange={(val) => this.handleCoordinateChange('z', val)}
          />
        </LabeledList.Item>
      </LabeledList>
    );
  }

  private renderPointerMode(): JSX.Element {
    const { pointing } = this.props.data;

    return (
      <Button
        width="100%"
        tooltip="При статусе «Не готов» — нажмите на кнопку.
            После нажатия и при последующих кликах не по кнопке — вы будете дропать молнии на тайл/моба,
            на которого указывает курсор мыши."
        textAlign="center"
        selected={pointing}
        onClick={this.handlePointingToggle}
      >
        {pointing ? 'Готов' : 'Не готов'}
      </Button>
    );
  }

  private renderModeContent(): JSX.Element | null {
    const { mode } = this.state;

    switch (mode) {
      case 'По игроку':
        return this.renderPlayerMode();
      case 'По координатам':
        return this.renderCoordinateMode();
      case 'По указателю':
        return this.renderPointerMode();
      default:
        return null;
    }
  }

  private isDropButtonDisabled(): boolean {
    const { mode } = this.state;
    return !mode || mode === 'По указателю';
  }

  render(): JSX.Element {
    const { data } = this.props;
    const { damage, radius, delay } = data;
    const { mode } = this.state;

    return (
      <Window width={300} height={340} title="Вызов молнии">
        <Window.Content>
          <Section
            scrollable
            title="Настройка"
            buttons={
              <Dropdown
                width="150px"
                options={this.availableModes}
                selected={mode}
                onSelected={this.handleModeChange}
              />
            }
          >
            <LabeledList>
              <LabeledList.Item label="Урон молнии">
                <NumberInput
                  maxValue={600}
                  minValue={0}
                  step={1}
                  value={damage}
                  onChange={this.handleDamageChange}
                />
              </LabeledList.Item>

              <LabeledList.Item
                label="Радиус поражения"
                tooltip="Включая центр, без снижения урона с отдалением от центра"
              >
                <NumberInput
                  maxValue={30}
                  minValue={0}
                  step={1}
                  value={radius}
                  onChange={this.handleRadiusChange}
                />
              </LabeledList.Item>

              <LabeledList.Item
                label="Задержка перед ударом"
                tooltip="В секундах"
              >
                <NumberInput
                  maxValue={60}
                  minValue={0}
                  step={1}
                  value={delay}
                  onChange={this.handleDelayChange}
                />
              </LabeledList.Item>
            </LabeledList>
          </Section>

          <Section title={mode}>{this.renderModeContent()}</Section>

          <Section>
            <Box textAlign="center">
              <Button
                icon="bolt"
                color="red"
                disabled={this.isDropButtonDisabled()}
                onClick={this.handleDropLightning}
              >
                Вызвать молнию
              </Button>
            </Box>
          </Section>
        </Window.Content>
      </Window>
    );
  }
}

// Wrapper функция для совместимости с хуками
export const DropLightningBolt = (props: unknown) => {
  const { act, data } = useBackend<LightningBoltData>();

  return <DropLightningBoltComponent act={act} data={data} />;
};
