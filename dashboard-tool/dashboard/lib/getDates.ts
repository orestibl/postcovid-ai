import dayjs from "dayjs";
import { Indicator } from "@/types/types";

export function getDates(indicators: Indicator[]) {
  if (!indicators) return { lowerDate: null, higherDate: null };

  let lowerDate = dayjs(
    Math.min(
      ...indicators.map((indicator) => new Date(indicator.date).getTime())
    )
  );
  let higherDate = dayjs(
    Math.max(
      ...indicators.map((indicator) => new Date(indicator.date).getTime())
    )
  );

  return { lowerDate, higherDate };
}
