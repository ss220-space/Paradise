export const formatMetricDistance = (metres: number) =>
  Math.abs(metres) >= 1000
    ? `${Number((metres / 1000).toFixed(2))} км`
    : `${Math.round(metres)} м`;

export const galacticLightYears = (chartUnits: number) => chartUnits / 1000;
export const formatGalacticCoordinate = (chartUnits: number) =>
  Number(galacticLightYears(chartUnits).toPrecision(6));
export const formatGalacticDistance = (chartUnits: number) =>
  `${Number(galacticLightYears(chartUnits).toPrecision(3))} св. лет`;
