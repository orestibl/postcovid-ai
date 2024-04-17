/* eslint-disable react-hooks/exhaustive-deps */
"use client";
import React, { useEffect, useState } from "react";
import SideNavBar from "@/components/SideNavBar";
import NavBar from "@/components/NavBar";
import { getFilters, getIndicators } from "@/app/action";
import { useFilterStore } from "@/store/filters";
import { useReloadStore } from "@/store/reload";
import { useIndicatorStore } from "@/store/indicators";
import { useDateSliderStore } from "@/store/store";
import { useDateRangeStore } from "@/store/date_range_store";
import { getDates } from "@/lib/getDates";
import { Backdrop, CircularProgress } from "@mui/material";
import { Indicator } from "@/types/types";
import { useCategoryStore } from "@/store/categories";
import { extractCategories } from "@/lib/util";
export default function Layout({ children }: { children: React.ReactNode }) {
  const [checked, setChecked] = React.useState<boolean>(false);

  const reload = useReloadStore((state) => state.reload);
  const updateFilters = useFilterStore((state) => state.updateFilters);
  const updateCategories = useCategoryStore((state) => state.updateCategories);
  const updateIndicators = useIndicatorStore((state) => state.updateIndicators);
  const updateDateLeft = useDateSliderStore((state) => state.updateDateLeft);
  const updateDateRight = useDateSliderStore((state) => state.updateDateRight);
  const updateCurrentDate = useDateSliderStore(
    (state) => state.updateCurrentDate
  );

  const updateLimitLeft = useDateRangeStore((state) => state.updateLimitLeft);
  const updateLimitRight = useDateRangeStore((state) => state.updateLimitRight);

  const dateLeft = useDateSliderStore((state) => state.dateLeft);
  const dateRight = useDateSliderStore((state) => state.dateRight);
  const currentDate = useDateSliderStore((state) => state.currentDate);

  const updateFetching = useReloadStore((state) => state.updateFetching);
  const fetching = useReloadStore((state) => state.fetching);

  const load = async () => {
    const indicators = await getIndicators(null, null);
    updateIndicators(indicators);
    const filters = await getFilters();
    updateFilters(filters);
    console.log("Filters useeffect", indicators, filters);
    if (!indicators.length) return;

    // Get indicator filter wich is not empty
    const ind = indicators.filter((i: Indicator[] | []) => i.length > 0);

    const dates = getDates(ind[0]);

    console.log("dates", dates);

    updateLimitLeft(dates.lowerDate);
    updateLimitRight(dates.higherDate);

    const cat = extractCategories(ind[ind.length - 1][0]);

    updateCategories(cat);

    if (dateLeft === null || dateRight === null || currentDate == null) {
      updateDateLeft(dates.lowerDate);
      updateCurrentDate(dates.lowerDate);
      updateDateRight(dates.higherDate);
    }

    updateFetching(false);
  };

  useEffect(() => {
    if (!fetching) {
      updateFetching(true);
    }
    load();
  }, [reload]);

  useEffect(() => {
    load();
  }, []);

  return (
    <div className="flex">
      <input
        id="menu__toggle"
        type="checkbox"
        checked={checked}
        onChange={(e) => setChecked(!checked)}
      />
      <label className="menu__btn" htmlFor="menu__toggle">
        <span></span>
      </label>
      <div
        className={`fixed w-3/6 
        left-[${checked ? 0 : "-100%"}]
        z-10  md:left-0 md:block md:w-1/6 bg-slate-50`}
      >
        <SideNavBar />
      </div>

      <main className="flex-1 h-[100vh] overflow-hidden">
        <div className="sticky top-0 w-full z-10 h-[7vh]">
          <NavBar />
        </div>

        {children}
      </main>
    </div>
  );
}
