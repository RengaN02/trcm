import { DmIcon, Icon, Image } from 'tgui/components';

import type { SearchItem } from './types';

type Props = {
  readonly item: SearchItem;
};

export function IconDisplay(props: Props) {
  const {
    item: { icon, icon_state },
  } = props;

  const fallback = <Icon name="spinner" size={2.2} spin color="gray" />;

  if (!icon) {
    return fallback;
  }

  if (icon_state) {
    return (
      <DmIcon
        fallback={fallback}
        icon={icon}
        icon_state={icon_state}
        height={3}
        width={3}
      />
    );
  }

  return <Image fixErrors src={icon} height={3} width={3} />;
}
