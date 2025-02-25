import { DmIcon, Icon, Image } from '../../components';
import { SearchItem } from './types';

type Props = {
  item: SearchItem;
};

export const IconDisplay = (props: Props) => {
  const {
    item: { icon, icon_state },
  } = props;

  const fallback = <Icon name="spinner" size={1.5} spin color="gray" />;

  if (!icon) {
    return fallback;
  }

  if (icon === 'n/a') {
    return <Icon name="dumpster-fire" size={1.5} color="gray" />;
  }

  if (icon_state) {
    return <DmIcon fallback={fallback} icon={icon} icon_state={icon_state} />;
  }

  return <Image fixErrors src={icon} />;
};
