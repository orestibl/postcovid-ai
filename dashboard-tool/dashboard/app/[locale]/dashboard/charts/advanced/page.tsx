"use client";

import { getFilters } from "@/app/action";
import { useFilterStore } from "@/store/filters";
import { useIndicatorStore } from "@/store/indicators";

import { Filter } from "@/types/types";
import { useCallback, useEffect, useState } from "react";

import LineCharts from "@/components/charts/LineCharts";
import CustomRadarChart from "@/components/charts/CustomRadarChart";
import { CircularProgress } from "@mui/material";
import { useDateSliderStore } from "@/store/store";
import { Indicator } from "@/types/types";
import dayjs, { Dayjs } from "dayjs";
import { extractCategories, getDailyIndicator } from "@/lib/util";
import { useCategoryStore } from "@/store/categories";

function Advanced() {
  const filters = useFilterStore((state) => state.filters);
  const indicators = useIndicatorStore((state) => state.indicators);

  const categories = useCategoryStore((state) => state.categories);

  const [loading, setLoading] = useState(false);
  const [ind, setInd] = useState<Indicator[][]>([]);

  const dateLeft = useDateSliderStore((state) => state.dateLeft);
  const dateRight = useDateSliderStore((state) => state.dateRight);
  const currentDate = useDateSliderStore((state) => state.currentDate);

  const getIndicators = useCallback(
    (ind: Indicator[][], dateLeft: Dayjs | null, dateRight: Dayjs | null) => {
      const indicators = [] as Indicator[][];

      ind?.forEach((d: Indicator[]) => {
        const arr = d.filter((indicator: Indicator) => {
          return (
            dayjs(indicator.date).isAfter(dateLeft) &&
            dayjs(indicator.date).isBefore(dateRight)
          );
        });
        indicators.push(arr);
      });

      return indicators;
    },
    []
  );

  useEffect(() => {
    const i = getIndicators(indicators, dateLeft, dateRight);
    setInd(i);
  }, [dateLeft, dateRight, indicators]);

  return (
    <div className="w-full flex flex-col items-center">
      <CustomRadarChart
        dailyIndicators={getDailyIndicator(indicators, filters, currentDate)}
        categories={categories}
      />

      {categories.map((category) => {
        return (
          <LineCharts
            key={category}
            category={category}
            indicators={ind}
            filters={filters}
          />
        );
      })}
    </div>
  );
}

export default Advanced;
