import { type ReactNode, useLayoutEffect, useRef, useState } from 'react';

export const RadarViewport = ({ children }: { children: ReactNode }) => {
  const viewport = useRef<HTMLDivElement>(null);
  const [size, setSize] = useState<number>();
  useLayoutEffect(() => {
    const node = viewport.current;
    if (!node) {
      return;
    }
    const measure = () => {
      const toolbar = node.querySelector('.OvermapRadar__bands');
      const toolbarHeight = toolbar?.getBoundingClientRect().height || 0;
      setSize(
        Math.max(
          0,
          Math.min(node.clientWidth, node.clientHeight - toolbarHeight) - 2,
        ),
      );
    };
    const observer = new ResizeObserver(measure);
    observer.observe(node);
    if (node.firstElementChild) {
      observer.observe(node.firstElementChild);
    }
    measure();
    return () => observer.disconnect();
  }, []);
  return (
    <div className="OvermapRadarViewport" ref={viewport}>
      <div className="OvermapRadarViewport__display" style={{ width: size }}>
        {children}
      </div>
    </div>
  );
};
