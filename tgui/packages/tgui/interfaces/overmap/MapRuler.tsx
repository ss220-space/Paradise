export const MapRuler = ({
  label,
  width = 120,
}: {
  label: string;
  width?: number;
}) => (
  <div className="OvermapRadar__ruler">
    <div className="OvermapRadar__rulerBar" style={{ width }}>
      <span className="OvermapRadar__rulerTick" />
      <span className="OvermapRadar__rulerLine" />
      <span className="OvermapRadar__rulerTick" />
    </div>
    <span className="OvermapRadar__rulerLabel">{label}</span>
  </div>
);
