import { useBackend } from '../../backend';
import { Box, Flex, LabeledList, Section, Button } from '../../components';
import { RndNavButton } from './index';
import { MENU, SUBMENU } from '../RndConsole';
import { left } from '@popperjs/core';

export const MainMenu = (properties) => {
  const { data } = useBackend<RndData>();

  const {
    disk_type,
    linked_destroy,
    linked_lathe,
    linked_imprinter,
    tech_levels,
  } = data;

  return (
    <Section title="Главное меню">
      <Flex
        className="RndConsole__MainMenu__Buttons"
        direction="column"
        align="flex-start"
      >
        <RndNavButton
          disabled={!disk_type}
          menu={MENU.DISK}
          submenu={SUBMENU.MAIN}
          icon="save"
        >
          Операции с дискетами
        </RndNavButton>
        <RndNavButton
          disabled={!linked_destroy}
          menu={MENU.DESTROY}
          submenu={SUBMENU.MAIN}
          icon="unlink"
        >
          Деструктивный анализатор
        </RndNavButton>
        <RndNavButton
          disabled={!linked_lathe}
          menu={MENU.LATHE}
          submenu={SUBMENU.MAIN}
          icon="print"
        >
          Протолат
        </RndNavButton>
        <RndNavButton
          disabled={!linked_imprinter}
          menu={MENU.IMPRINTER}
          submenu={SUBMENU.MAIN}
          icon="print"
        >
          Принтер плат
        </RndNavButton>
        <RndNavButton menu={MENU.SETTINGS} submenu={SUBMENU.MAIN} icon="cog">
          Настройки
        </RndNavButton>
      </Flex>

      <Box mt="12px" />
      <h3>Локальные уровни технологий:</h3>
      <LabeledList>
        {tech_levels.map(({ name, level, desc }) => (
          <LabeledList.Item
            label={
              <Button color="transparent" tooltip={desc}>
                {name}:
              </Button>
            }
            key={name}
          >
            {level}
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};
