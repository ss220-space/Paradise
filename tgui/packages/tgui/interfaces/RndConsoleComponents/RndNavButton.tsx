import { computeBoxProps } from 'common/ui';
import { useBackend } from '../../backend';
import { Button } from '../../components';
import { ButtonProps } from '../../components/Button';

type RndNavButtonProps = RndRouteData & ButtonProps;

export const RndNavButton = (properties: RndNavButtonProps) => {
  const { icon, children, disabled, content } = properties;
  const { data, act } = useBackend<RndData>();
  const { menu, submenu } = data;

  let nextMenu = menu;
  let nextSubmenu = submenu;

  if (properties.menu !== null && properties.menu !== undefined) {
    nextMenu = properties.menu;
  }
  if (properties.submenu !== null && properties.submenu !== undefined) {
    nextSubmenu = properties.submenu;
  }

  // const active = data.menu === menu && data.submenu === submenu;

  return (
    <Button
      content={content}
      icon={icon}
      disabled={disabled}
      onClick={() => {
        act('nav', { menu: nextMenu, submenu: nextSubmenu });
      }}
      {...computeBoxProps(properties)}
    >
      {children}
    </Button>
  );
};
