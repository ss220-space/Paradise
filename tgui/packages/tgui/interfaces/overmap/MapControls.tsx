import type { ReactNode } from 'react';

export const MapControls = ({
  onIn,
  onOut,
  onBand,
  bandTitle,
  band,
  children,
}: {
  onIn: () => void;
  onOut: () => void;
  onBand?: () => void;
  bandTitle?: string;
  band?: string;
  children?: ReactNode;
}) => (
  <div className="OvermapRadar__zoom">
    <button
      type="button"
      className="OvermapRadar__zoomButton"
      title="Приблизить"
      onClick={onIn}
    >
      +
    </button>
    <button
      type="button"
      className="OvermapRadar__zoomButton"
      title="Отдалить"
      onClick={onOut}
    >
      −
    </button>
    {!!onBand && (
      <button
        type="button"
        className="OvermapRadar__zoomButton OvermapRadar__zoomButton--band"
        title={bandTitle}
        onClick={onBand}
      >
        {band}
      </button>
    )}
    {children}
  </div>
);
