import type { PropsWithChildren, ReactNode } from 'react';
import { Box } from './Box';

type Props = Partial<{
  style: Record<string, any>;
  textStyle: Record<string, any>;
  title: ReactNode;
  titleStyle: Record<string, any>;
  titleSubtext: string;
}> &
  PropsWithChildren;

// The cost of flexibility and prettiness.
export const StyleableSection = (props: Props) => {
  const { children, titleStyle, titleSubtext, title, textStyle, style } = props;

  return (
    <Box style={style}>
      {/* Yes, this box (line above) is missing the "Section" class. This is very intentional, as the layout looks *ugly* with it.*/}
      <Box className="Section__title" style={titleStyle}>
        <Box className="Section__titleText" style={textStyle}>
          {title}
        </Box>
        <div className="Section__buttons">{titleSubtext}</div>{' '}
      </Box>
      <Box className="Section__rest">
        <Box className="Section__content">{children}</Box>
      </Box>
    </Box>
  );
};
