"use client";

import FilterModal from "@/components/FilterModal";

// import { useContext, useEffect, useState } from "react";
// import { DataContext } from "@/components/CommonState";
import FiltersCard from "@/components/FiltersCard";
import { useFilterStore } from "@/store/filters";
import { CircularProgress } from "@mui/material";

function Filters() {
  return (
    <div className="flex flex-col items-center w-full">
      <FiltersCard />
      <div className="flex items-center">
        <span>Add a filter</span>
        <FilterModal />
      </div>
    </div>
  );
}

export default Filters;
