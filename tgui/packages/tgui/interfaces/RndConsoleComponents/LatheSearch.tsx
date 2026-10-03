import { Box, Input } from 'tgui-core/components';
import { useBackend } from '../../backend';

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
