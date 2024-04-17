"use client";

import { getFilters } from "@/app/action";
import { useFilterStore } from "@/store/filters";
import { useIndicatorStore } from "@/store/indicators";
import { Filter, Indicator } from "@/types/types";
import { useEffect, useState } from "react";
import { extractCategories, getDailyIndicator } from "@/lib/util";
// import { Filter, Indicator, LangProps } from "@/types/types";
import RowIndicator from "@/components/indicators/RowIndicator";
import { normalize } from "@/lib/util";

import { useDateSliderStore } from "@/store/store";
import dayjs from "dayjs";
import { CircularProgress } from "@mui/material";
import { useReloadStore } from "@/store/reload";
import { useCategoryStore } from "@/store/categories";

function Main() {
  const filters = useFilterStore((state) => state.filters);
  const indicators = useIndicatorStore((state) => state.indicators);

  const categories = useCategoryStore((state) => state.categories);

  const fetching = useReloadStore((state) => state.fetching);

  const [daily, setDaily] = useState<Indicator[]>([]);
  const currentDate = useDateSliderStore((state) => state.currentDate);

  useEffect(() => {
    const d = getDailyIndicator(indicators, filters, currentDate);
    setDaily(d);
  }, [indicators, filters, currentDate]);

  useEffect(() => {
    const d = getDailyIndicator(indicators, filters, currentDate);
    setDaily(d);
  }, [currentDate, indicators, filters]);

  return fetching ? (
    <div className="w-full flex items-center justify-items-center">
      <CircularProgress />
    </div>
  ) : (
    <div className="w-full flex flex-col items-center">
      {categories &&
        categories.map((category) => {
          return (
            <RowIndicator
              key={category}
              items={daily.map((indicator: Indicator) => {
                return {
                  color: String(indicator.color),
                  pos: normalize(indicator[category] as number),
                };
              })}
              category={category}
            />
          );
        })}
    </div>
  );
}
export default Main;
