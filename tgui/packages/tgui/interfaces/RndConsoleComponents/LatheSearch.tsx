import { useBackend } from '../../backend';
import { Box, Input } from '../../components';

export const LatheSearch = (_properties) => {
  const { act } = useBackend();
  return (
    <Box>
      <Input
        placeholder="Поиск..."
        onEnter={(value) => act('search', { to_search: value })}
      />
    </Box>
  );
};
