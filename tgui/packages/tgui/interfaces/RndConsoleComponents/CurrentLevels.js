import { useBackend } from '../../backend';
import { Box, Divider } from '../../components';

export const CurrentLevels = (properties) => {
  const { data } = useBackend();

  const { tech_levels } = data;

  return (
    <Box>
      <h3>Current Research Levels:</h3>
      {tech_levels.map((techLevel, i) => {
        const { name, level, desc } = techLevel;
        return (
          <Box key={name}>
            {i > 0 ? <Divider /> : null}
            <Box>{name}</Box>
            <Box>* Level: {level}</Box>
            <Box>* Summary: {desc}</Box>
          </Box>
        );
      })}
    </Box>
  );
};
