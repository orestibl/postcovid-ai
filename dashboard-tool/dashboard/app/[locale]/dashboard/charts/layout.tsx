"use client";

import { getFilters } from "@/app/action";
import { Filter } from "@/types/types";
import { useEffect, useState } from "react";
import DateSlider from "@/components/date_slider/DateSlider";
import { useFilterStore } from "@/store/filters";
import { useReloadStore } from "@/store/reload";
import { useIndicatorStore } from "@/store/indicators";
import { Backdrop, CircularProgress } from "@mui/material";

function Layout({ children }: { children: React.ReactNode }) {
  const fetching = useReloadStore((state) => state.fetching);

  return fetching ? (
    <div className="w-full h-full flex justify-center items-center">
      <CircularProgress />
    </div>
  ) : (
    <div className="w-full flex flex-col items-center h-[92vh] justify-between overflow-scroll">
      <div className="w-full ">{children}</div>
      <div className="fixed bottom-1">{<DateSlider />}</div>
    </div>
  );
}

export default Layout;
