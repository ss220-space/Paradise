import { useRef } from 'react';
import { computeBoxProps } from 'common/ui';
import type { BoxProps } from './Box';
import { ReactNode } from 'react';
import { Tooltip } from './Tooltip';

type Props = Partial<{
  className: string;
  /** True is default, this fixes an ie thing */
  fixBlur: boolean;
  /** False by default. Good if you're fetching images on UIs that do not auto update. This will attempt to fix the 'x' icon 5 times. */
  fixErrors: boolean;
  /** Fill is default. */
  objectFit: 'contain' | 'cover';
  /** Tooltip. */
  tooltip: ReactNode;
  src: string;
}> &
  BoxProps;

const maxAttempts = 5;

export type ImageProps = Props;

/**
 * ## Image
 * A wrapper for the `<img>` element.
 *
 * By default, it will attempt to fix broken images by fetching them again.
 *
 * It will also try to fix blurry images by rendering them pixelated.
 */
export const Image = (props: Props) => {
  const {
    fixBlur = true,
    fixErrors = false,
    objectFit = 'fill',
    src,
    tooltip,
    ...rest
  } = props;
  const attempts = useRef(0);

  const computedProps = computeBoxProps(rest);
  computedProps.style = {
    ...computedProps.style,
    imageRendering: fixBlur ? 'pixelated' : 'auto',
    objectFit,
  };

  const handleError = (event) => {
    if (fixErrors && attempts.current < maxAttempts) {
      const imgElement = event.currentTarget;

      setTimeout(() => {
        imgElement.src = `${src}?attempt=${attempts.current}`;
        attempts.current++;
      }, 1000);
    }
  };

  /* Use div instead img if used asset, cause img with class leaves white border on 516 */
  if (computedProps.className) {
    return <div onError={handleError} {...computedProps} />;
  }

  let content = (
    <img
      onError={handleError}
      src={
        src ||
        /** Use transparent base64 pixel if there is no src. So we don't get broken image icon when using assets */
        'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII='
      }
      {...computedProps}
      alt="dm icon"
    />
  );

  if (tooltip) {
    content = <Tooltip content={tooltip}>{content}</Tooltip>;
  }

  return content;
};
