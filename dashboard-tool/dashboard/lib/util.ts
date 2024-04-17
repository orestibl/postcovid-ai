import { Filter, Indicator } from "@/types/types";
import dayjs, { Dayjs } from "dayjs";

export const extractCategories = (indicator: Indicator) => {
  if (indicator == null) return [];

  const map = new Map<string, boolean>();

  Object.keys(indicator).forEach((key) => {
    map.set(key, true);
  });

  return Array.from(map.keys()).filter(
    (key) => key != "date" && key != "color" && key != "filter_name"
  );
};

export const normalize = (pos: number) => {
  if (pos <= 100) return pos;

  let newValue = pos;

  const max = 8496;
  const min = 0;

  const oldRange = max - min;
  const newRange = 100 - 0;
  newValue = ((pos - min) * newRange) / oldRange + 0;

  return newValue;
};

function getDates(inds: Indicator[][]) {
  const indicators = inds[inds.length - 1];

  const dates = indicators.map((indicator) => {
    return dayjs(indicator.date).format("YYYY-MM-DD");
  });

  const sortedDates = dates.sort((a, b) => {
    return dayjs(a).isBefore(dayjs(b)) ? -1 : 1;
  });

  return {
    lowerDate: dayjs(sortedDates[0]),
    higherDate: dayjs(sortedDates[sortedDates.length - 1]),
  };
}

export function getDailyIndicator(
  ind: Indicator[][],
  filters: Filter[],
  currentDate: Dayjs | null
) {
  const arr: Indicator[] = [];
  filters?.forEach((filter, index) => {
    const dailyInd = ind[index].filter((indicator: Indicator) => {
      return dayjs(indicator.date).isSame(currentDate, "day");
    });
    if (ind[index].length > 0)
      arr.push({
        ...dailyInd[0],
        filter_name: filter.name,
        color: filter.color,
      });
  });
  return arr;
}
