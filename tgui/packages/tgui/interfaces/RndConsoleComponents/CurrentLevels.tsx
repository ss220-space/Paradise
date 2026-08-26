import { useBackend } from '../../backend';
import { Box, Divider } from '../../components';

export const CurrentLevels = (properties) => {
  const { data } = useBackend<RndData>();

  const { tech_levels } = data;

  return (
    <Box>
      <h3>Текущие уровни технологий:</h3>
      {tech_levels.map((techLevel, i) => {
        const { name, level, desc } = techLevel;
        return (
          <Box key={name}>
            {i > 0 ? <Divider /> : null}
            <Box>{name}</Box>
            <Box>- Уровень: {level}</Box>
            <Box>- Суммарно: {desc}</Box>
          </Box>
        );
      })}
    </Box>
  );
};
