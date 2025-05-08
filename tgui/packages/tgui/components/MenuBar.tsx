import { type ReactNode, type RefObject, useRef } from 'react';
import { classes } from 'common/react';
import { Box, type BoxProps } from './Box';
import { Icon } from './Icon';
import { Popper } from './Popper';

type MenuBarProps = {
  children: ReactNode;
};

export const MenuBar = (props: MenuBarProps) => {
  const { children } = props;
  return <Box className="MenuBar">{children}</Box>;
};

type MenuProps = {
  children: any;
  width: string;
};

const Menu = (props: MenuProps) => {
  const { children, width } = props;

  return (
    <div
      className="Menubar__menu"
      style={{
        width,
      }}
    >
      {children}
    </div>
  );
};

type MenuBarDropdownProps = {
  disabled?: boolean;
  display: any;
  onMouseOver: () => void;
  onOutsideClick: () => void;
  open: boolean;
  openWidth: string;
} & BoxProps;

const MenuBarButton = (props: MenuBarDropdownProps) => {
  const {
    children,
    className,
    disabled,
    display,
    onClick,
    onMouseOver,
    open,
    openWidth,
    onOutsideClick,
    ...rest
  } = props;

  const menuRef = useRef<HTMLDivElement>(null);

  return (
    <div ref={menuRef}>
      <Box
        className={classes([
          'MenuBar__MenuBarButton',
          'MenuBar__font',
          'MenuBar__hover',
          className,
        ])}
        {...rest}
        onClick={disabled ? () => null : onClick}
        onMouseOver={onMouseOver}
      >
        <span className="MenuBar__MenuBarButton-text">{display}</span>
      </Box>
      <Popper
        onClickOutside={onOutsideClick}
        placement="bottom-start"
        content={<Menu width={openWidth}>{children}</Menu>}
        isOpen={open}
      />
    </div>
  );
};

type MenuBarItemProps = {
  children: ReactNode;
  className?: string;
  disabled?: boolean;
  display: ReactNode;
  entry: string;
  openMenuBar: string | null;
  openOnHover: boolean;
  openWidth: string;
  setOpenMenuBar: (entry: string | null) => void;
  setOpenOnHover: (flag: boolean) => void;
};

const Dropdown = (props: MenuBarItemProps) => {
  const {
    entry,
    children,
    openWidth,
    display,
    setOpenMenuBar,
    openMenuBar,
    setOpenOnHover,
    openOnHover,
    disabled,
    className,
  } = props;

  return (
    <MenuBarButton
      openWidth={openWidth}
      display={display}
      disabled={disabled}
      open={openMenuBar === entry}
      className={className}
      onClick={() => {
        const open = openMenuBar === entry ? null : entry;
        setOpenMenuBar(open);
        setOpenOnHover(!openOnHover);
      }}
      onOutsideClick={() => {
        setOpenMenuBar(null);
        setOpenOnHover(false);
      }}
      onMouseOver={() => {
        if (openOnHover) {
          setOpenMenuBar(entry);
        }
      }}
    >
      {children}
    </MenuBarButton>
  );
};

const MenuItemToggle = (props) => {
  const { value, displayText, onClick, checked } = props;
  return (
    <Box
      className={classes([
        'MenuBar__font',
        'MenuBar__MenuItem',
        'MenuBar__MenuItemToggle',
        'MenuBar__hover',
      ])}
      onClick={() => onClick(value)}
    >
      <div className="MenuBar__MenuItemToggle__check">
        <Icon size={1.3} name={checked ? 'check' : ''} />
      </div>
      {displayText}
    </Box>
  );
};

Dropdown.MenuItemToggle = MenuItemToggle;

type MenuItemProps = Partial<{
  value: any;
  displayText: string;
  onClick: (value: any) => void;
}>;

const MenuItem = (props: MenuItemProps) => {
  const { value, displayText, onClick } = props;
  return (
    <Box
      className={classes([
        'MenuBar__font',
        'MenuBar__MenuItem',
        'MenuBar__hover',
      ])}
      onClick={() => onClick?.(value)}
    >
      {displayText}
    </Box>
  );
};

const Separator = () => {
  return <div className="MenuBar__Separator" />;
};

MenuBar.Dropdown = Dropdown;

Dropdown.MenuItem = MenuItem;

Dropdown.Separator = Separator;
