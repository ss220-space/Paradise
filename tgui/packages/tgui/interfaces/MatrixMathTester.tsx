import { useBackend } from '../backend';
import { useState } from 'react';
import { NumberInput, Section, Button, Table } from '../components';
import { toFixed } from 'common/math';
import { Window } from '../layouts';

const MatrixMathTesterInput = (props: { value: number; varName: string }) => {
  const { act } = useBackend();
  return (
    <NumberInput
      value={props.value}
      minValue={-Infinity}
      maxValue={+Infinity}
      step={0.005}
      format={(value) => toFixed(value, 3)}
      width={'100%'}
      onChange={(value) =>
        act('change_var', { var_name: props.varName, var_value: value })
      }
    />
  );
};

type MatrixData = {
  matrix_a: number;
  matrix_b: number;
  matrix_c: number;
  matrix_d: number;
  matrix_e: number;
  matrix_f: number;
  pixelated: boolean;
};

export const MatrixMathTester = (props: unknown) => {
  const { act, data } = useBackend<MatrixData>();
  const {
    matrix_a,
    matrix_b,
    matrix_c,
    matrix_d,
    matrix_e,
    matrix_f,
    pixelated,
  } = data;
  const [scaleX, setScaleX] = useState(1);
  const [scaleY, setScaleY] = useState(1);
  const [translateX, setTranslateX] = useState(0);
  const [translateY, setTranslateY] = useState(0);
  const [shearX, setShearX] = useState(0);
  const [shearY, setShearY] = useState(0);
  const [angle, setAngle] = useState(0);
  return (
    <Window title="Transform Editor" width={290} height={270}>
      <Window.Content>
        <Section fill>
          <Table>
            <Table.Row header>
              <Table.Cell width={'30%'} />
              <Table.Cell width={'25%'}>X</Table.Cell>
              <Table.Cell width={'25%'}>Y</Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell header>Position(c, f)</Table.Cell>
              <Table.Cell>
                <MatrixMathTesterInput value={matrix_c} varName="c" />
              </Table.Cell>
              <Table.Cell>
                <MatrixMathTesterInput value={matrix_f} varName="f" />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell header>Incline(b, d)</Table.Cell>
              <Table.Cell>
                <MatrixMathTesterInput value={matrix_b} varName="b" />
              </Table.Cell>
              <Table.Cell>
                <MatrixMathTesterInput value={matrix_d} varName="d" />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell header>Scale(a,e)</Table.Cell>
              <Table.Cell>
                <MatrixMathTesterInput value={matrix_a} varName="a" />
              </Table.Cell>
              <Table.Cell>
                <MatrixMathTesterInput value={matrix_e} varName="e" />
              </Table.Cell>
            </Table.Row>
          </Table>
          <Table
            style={{
              borderCollapse: 'separate',
              borderSpacing: '0 1px',
            }}
          >
            <Table.Row header>
              <Table.Cell>Action</Table.Cell>
              <Table.Cell>X</Table.Cell>
              <Table.Cell>Y</Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>
                <Button
                  icon={'up-right-and-down-left-from-center'}
                  width={'100%'}
                  onClick={() => act('scale', { x: scaleX, y: scaleY })}
                >
                  Scale
                </Button>
              </Table.Cell>
              <Table.Cell>
                <NumberInput
                  value={scaleX}
                  minValue={-Infinity}
                  maxValue={+Infinity}
                  step={0.05}
                  format={(value) => toFixed(value, 2)}
                  width={'100%'}
                  onChange={(value) => setScaleX(value)}
                />
              </Table.Cell>
              <Table.Cell>
                <NumberInput
                  value={scaleY}
                  minValue={-Infinity}
                  maxValue={+Infinity}
                  step={0.05}
                  format={(value) => toFixed(value, 2)}
                  width={'100%'}
                  onChange={(value) => setScaleY(value)}
                />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>
                <Button
                  icon={'arrow-right'}
                  width={'100%'}
                  onClick={() =>
                    act('translate', { x: translateX, y: translateY })
                  }
                >
                  Translate
                </Button>
              </Table.Cell>
              <Table.Cell>
                <NumberInput
                  value={translateX}
                  minValue={-Infinity}
                  maxValue={+Infinity}
                  step={1}
                  format={(value) => toFixed(value, 0)}
                  width={'100%'}
                  onChange={(value) => setTranslateX(value)}
                />
              </Table.Cell>
              <Table.Cell>
                <NumberInput
                  value={translateY}
                  minValue={-Infinity}
                  maxValue={+Infinity}
                  step={1}
                  format={(value) => toFixed(value, 0)}
                  width={'100%'}
                  onChange={(value) => setTranslateY(value)}
                />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>
                <Button
                  icon={'maximize'}
                  width={'100%'}
                  onClick={() => act('shear', { x: shearX, y: shearY })}
                >
                  Shear
                </Button>
              </Table.Cell>
              <Table.Cell>
                <NumberInput
                  value={shearX}
                  minValue={-Infinity}
                  maxValue={+Infinity}
                  step={0.005}
                  format={(value) => toFixed(value, 3)}
                  width={'100%'}
                  onChange={(value) => setShearX(value)}
                />
              </Table.Cell>
              <Table.Cell>
                <NumberInput
                  value={shearY}
                  minValue={-Infinity}
                  maxValue={+Infinity}
                  step={0.005}
                  format={(value) => toFixed(value, 3)}
                  width={'100%'}
                  onChange={(value) => setShearY(value)}
                />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>
                <Button
                  icon={'rotate-right'}
                  width={'100%'}
                  onClick={() => act('turn', { angle: angle })}
                >
                  Rotate
                </Button>
              </Table.Cell>
              <Table.Cell>
                <NumberInput
                  value={angle}
                  step={0.5}
                  maxValue={360}
                  minValue={-360}
                  format={(value) => toFixed(value, 1)}
                  width={'100%'}
                  onChange={(value) => setAngle(value)}
                />
              </Table.Cell>
              <Table.Cell>
                <Button
                  icon={'dog'}
                  color={'bad'}
                  selected={pixelated}
                  tooltip={'Pixel Enhanced Transforming'}
                  tooltipPosition={'bottom'}
                  width={'100%'}
                  onClick={() => act('toggle_pixel')}
                >
                  PET
                </Button>
              </Table.Cell>
            </Table.Row>
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
