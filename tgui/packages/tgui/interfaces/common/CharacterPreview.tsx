import { ByondUi } from 'tgui-core/components';

/**
 * A live character preview rendered through a ByondUi map element.
 * The `id` is the assigned map name of an /atom/movable/screen/map_view
 * registered for the viewing client (see character_preview.dm).
 */
export const CharacterPreview = (props: {
  height: string;
  id: string;
}) => {
  return (
    <ByondUi
      width="220px"
      height={props.height}
      params={{
        id: props.id,
        type: 'map',
      }}
    />
  );
};
