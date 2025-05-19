import { resolveAsset } from '../assets';
import { Fragment } from 'react';
import { useBackend } from '../backend';
import { Box, Button, Icon, Section, Image } from '../components';
import { Window } from '../layouts';

type SafeData = {
  dial: number;
  open: boolean;
  locked: boolean;
  contents: Item[];
};

type Item = {
  sprite: string;
  name: string;
};

export const Safe = (_properties) => {
  const { data } = useBackend<SafeData>();
  const { dial, open } = data;
  return (
    <Window theme="safe" width={600} height={800}>
      <Window.Content>
        <Box className="Safe--engraving">
          <Dialer />
          <Box>
            <Box className="Safe--engraving--hinge" top="25%" />
            <Box className="Safe--engraving--hinge" top="75%" />
          </Box>
          <Icon
            className="Safe--engraving--arrow"
            name="long-arrow-alt-down"
            size={3}
          />
          <br />
          {open ? (
            <Contents />
          ) : (
            <Image
              src={resolveAsset('safe_dial.png')}
              fixBlur
              style={{
                transform: 'rotate(-' + 3.6 * dial + 'deg)',
                zIndex: 0,
              }}
            />
          )}
        </Box>
        {!open && <Help />}
      </Window.Content>
    </Window>
  );
};

const Dialer = (_properties) => {
  const { act, data } = useBackend<SafeData>();
  const { dial, open, locked } = data;
  const dialButton = (amount: number, right?: boolean) => {
    return (
      <Button
        key={amount}
        disabled={open || (right && !locked)}
        icon={'arrow-' + (right ? 'right' : 'left')}
        iconPosition={right ? 'right' : ''}
        onClick={() =>
          act(!right ? 'turnright' : 'turnleft', {
            num: amount,
          })
        }
        style={{
          zIndex: 10,
        }}
      >
        {amount}
      </Button>
    );
  };
  return (
    <Box className="Safe--dialer">
      <Button
        disabled={locked}
        icon={open ? 'lock' : 'lock-open'}
        mb="0.5rem"
        onClick={() => act('open')}
      >
        {open ? 'Закрыть' : 'Открыть'}
      </Button>
      <br />
      <Box position="absolute">
        {[dialButton(50), dialButton(10), dialButton(1)]}
      </Box>
      <Box className="Safe--dialer--right" position="absolute" right="5px">
        {[dialButton(1, true), dialButton(10, true), dialButton(50, true)]}
      </Box>
      <Box className="Safe--dialer--number">{dial}</Box>
    </Box>
  );
};

const Contents = (_properties) => {
  const { act, data } = useBackend<SafeData>();
  const { contents } = data;
  return (
    <Box className="Safe--contents" overflow="auto">
      {contents.map((item, index) => (
        <Fragment key={item.name}>
          <Button
            mb="0.5rem"
            onClick={() =>
              act('retrieve', {
                index: index + 1,
              })
            }
          >
            <Image
              src={item.sprite + '.png'}
              verticalAlign="middle"
              ml="-6px"
              mr="0.5rem"
            />
            {item.name}
          </Button>
          <br />
        </Fragment>
      ))}
    </Box>
  );
};

const Help = (_properties) => {
  return (
    <Section
      className="Safe--help"
      title="Инструкция по открытию сейфа. (потому что вы всё время забываете)"
    >
      <Box>
        1. Поверните циферблат влево на первую цифру.
        <br />
        2. Поверните циферблат вправо на вторую цифру.
        <br />
        3. Продолжайте так для каждого числа, поворачивая сначало налево, затем
        направо.
        <br />
        4. Откройте сейф.
      </Box>
      <Box bold>
        Чтобы полностью запереть сейф, после закрытия поверните циферблат влево.
      </Box>
    </Section>
  );
};
