import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { Box, Button, Section } from 'tgui-core/components';

type Data = { xcoord: number; ycoord: number; zcoord: number };

export const Binoculars = () => {
  const { data } = useBackend<Data>();

  const x_coord = data.xcoord;
  const y_coord = data.ycoord;
  const z_coord = data.zcoord;

  const coordinatesString = `ДОЛГОТА: ${x_coord}, ШИРОТА: ${y_coord}, ВЫСОТА: ${z_coord}`;

  return (
    <Window width={450} height={300}>
      <Window.Content scrollable>
        <Section
          fill
          title="УПРОЩЁННЫЕ КООРДИНАТЫ ЦЕЛИ"
          textAlign="center"
          fontSize="15px"
        >
          <Box fontSize="30px" mb={2}>
            ДОЛГОТА : {x_coord}, ШИРОТА : {y_coord}, ВЫСОТА : {z_coord}
          </Box>
          <Button
            align="center"
            minWidth="70%"
            icon="clipboard"
            tooltip="Копирует записанные координаты в буфер обмена"
            fontSize="20px"
            onClick={() => navigator.clipboard.writeText(coordinatesString)}
          >
            Скопировать координаты
          </Button>
        </Section>
      </Window.Content>
    </Window>
  );
};
