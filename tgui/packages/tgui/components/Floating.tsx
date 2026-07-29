import { type BooleanLike, classes } from 'common/react';
import {
  autoUpdate,
  FloatingPortal,
  flip,
  offset,
  type Placement,
  safePolygon,
  shift,
  size,
  useClick,
  useDismiss,
  useFloating,
  useHover,
  useInteractions,
  useTransitionStatus,
} from '@floating-ui/react';
import {
  type CSSProperties,
  cloneElement,
  forwardRef,
  isValidElement,
  type ReactElement,
  type ReactNode,
  useEffect,
  useImperativeHandle,
  useState,
} from 'react';

type Props = {
  /** Interacting with this element will open the floating element. */
  children: ReactNode;
  /** The content to display like floating. */
  content: ReactNode;
} & Partial<{
  /**
   * Where the content will be displayed, relative to children.
   * - See [Placement](https://floating-ui.com/docs/useFloating#placement)
   * @default 'bottom'
   */
  placement: Placement;
  /** Classes with will be applied to the content. */
  contentClasses: string;
  /** Inline styles with will be applied to the content. */
  contentStyles: CSSProperties;
  /** Use calculated by Floating UI children width as content width. */
  contentAutoWidth: boolean;
  /**
   * Indentation of content element from children.
   * @default 6
   */
  contentOffset: number;
  /** Disables all interactions. */
  disabled: BooleanLike;
  /**
   * How long the animation takes in ms.
   * - If specified, default animation will be disabled.
   * - Fully disables animations if 0
   * @default 200
   */
  animationDuration: number;
  /** Direct content open state control. */
  handleOpen: boolean;
  /** Content will open when you hover over children. */
  hoverOpen: boolean;
  /**
   * Delay in ms before opening and closing the content.
   * - Works only if used `hoverOpen` prop.
   * @default 200
   */
  hoverDelay: number;
  /**
   * Content will not close if the mouse moves out of the children while
   * trying to move into the content.
   * - Works only if used `hoverOpen` prop.
   */
  hoverSafePolygon: boolean;
  /**
   * Whitelisted classes.
   * Used to allow to add some secured classes,
   * click on which will not close the content.
   * - Classes must be sent like this: `".class1, .class2"`
   */
  allowedOutsideClasses: string;
  /** Do not wrap content in FloatingPortal, thus preventing it from moving into the body */
  preventPortal: true;
  /** Stops event propagation on children. */
  stopChildPropagation: boolean;
  /** Close the content after interaction with it. */
  closeAfterInteract: boolean;
  /**
   * Called when the open state changes.
   * Returns the new open state.
   * Can be used this way:
   * ```tsx
   * onOpenChange={open ? makeThingsOnOpen : makeThingsOnClose}
   * ```
   */
  onOpenChange: (open: boolean) => void;
  /**
   * Called when mounted
   */
  onMounted: () => void;
}>;

export type FloatingHandle = {
  /** Imperatively close the floating element. */
  close: () => void;
};

/**
 * ## Floating
 *
 *  Floating lets you position elements so that they don't go out of the bounds of the window.
 *
 * - [Documentation](https://floating-ui.com/docs/react) for more information.
 */
export const Floating = forwardRef<FloatingHandle, Props>((props, ref) => {
  const {
    allowedOutsideClasses,
    animationDuration,
    children,
    closeAfterInteract,
    content,
    contentAutoWidth,
    contentClasses,
    contentOffset = 6,
    contentStyles,
    disabled,
    hoverDelay,
    hoverOpen,
    hoverSafePolygon,
    handleOpen,
    onMounted,
    placement,
    preventPortal,
    stopChildPropagation,
    onOpenChange,
  } = props;

  const [isOpen, setIsOpen] = useState(false);
  const { refs, floatingStyles, context } = useFloating({
    middleware: [
      offset(contentOffset),
      flip({ padding: 6 }),
      shift(),
      contentAutoWidth &&
        size({
          apply({ rects, elements }) {
            elements.floating.style.width = `${rects.reference.width}px`;
          },
        }),
    ],
    onOpenChange(isOpen) {
      setIsOpen(isOpen);
      onOpenChange?.(isOpen);
    },
    open: isOpen,
    placement: placement || 'bottom',
    transform: false, // More expensive but allows to use transform for animations
    whileElementsMounted: (reference, floating, update) => {
      if (onMounted !== undefined) {
        onMounted();
      }
      return autoUpdate(reference, floating, update, {
        ancestorResize: false,
        ancestorScroll: false,
        elementResize: false, // ResizeObserver crashes in multiple cases, disabled for now
      });
    },
  });

  useImperativeHandle(ref, () => ({
    close: () => context.onOpenChange(false),
  }));

  const { isMounted, status } = useTransitionStatus(context, {
    duration: animationDuration || 200,
  });

  const dismiss = useDismiss(context, {
    ancestorScroll: true,
    outsidePress: (event) =>
      !allowedOutsideClasses
        ? true
        : event.target instanceof Element &&
          !event.target.closest(allowedOutsideClasses),
  });

  const click = useClick(context, { enabled: !disabled });
  const hover = useHover(context, {
    enabled: !disabled,
    restMs: hoverDelay || 200,
    handleClose: hoverSafePolygon
      ? safePolygon({
          requireIntent: false,
        })
      : null,
  });

  const openHandled = handleOpen !== undefined;
  const interactions = openHandled ? [] : [dismiss, hoverOpen ? hover : click];
  const { getReferenceProps, getFloatingProps } = useInteractions(interactions);

  const referenceProps = getReferenceProps({
    ref: refs.setReference,
    ...(stopChildPropagation && {
      onClick: (event) => event.stopPropagation(),
    }),
  });

  const floatingProps = getFloatingProps({
    onClick: () => {
      if (closeAfterInteract) {
        context.onOpenChange(false);
      }
    },
    ref: refs.setFloating,
  });

  useEffect(() => {
    if (openHandled) {
      context.onOpenChange(handleOpen);
    }
  }, [handleOpen]);

  // Generate our children which will be used as reference
  let floatingChildren: ReactElement;
  if (isValidElement(children)) {
    floatingChildren = cloneElement(children as ReactElement, referenceProps);
  } else {
    floatingChildren = <div {...referenceProps}>{children}</div>;
  }

  const floatingContent = (
    <div
      className={classes([
        'Floating',
        !animationDuration && 'Floating--animated',
        contentClasses,
      ])}
      data-position={context.placement}
      data-transition={status}
      style={{ ...floatingStyles, ...contentStyles }}
      {...floatingProps}
    >
      {content}
    </div>
  );

  return (
    <>
      {floatingChildren}
      {isMounted &&
        !!content &&
        (preventPortal ? (
          floatingContent
        ) : (
          <FloatingPortal id="tgui-root">{floatingContent}</FloatingPortal>
        ))}
    </>
  );
});
