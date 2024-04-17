"use client";
import React, { useState } from "react";
import { Card, CircularProgress, IconButton } from "@mui/material";
import { Filter } from "@/types/types";
import EditIcon from "@mui/icons-material/Edit";
import DeleteIcon from "@mui/icons-material/Delete";
import { useReloadStore } from "@/store/reload";
import { useFilterStore } from "@/store/filters";
import Backdrop from "@mui/material/Backdrop";
import revalidateData from "@/app/action";

export default function FiltersCard() {
  const filters = useFilterStore((state) => state.filters);

  const updateFetching = useReloadStore((state) => state.updateFetching);
  const fetching = useReloadStore((state) => state.fetching);

  const switchState = useReloadStore((state) => state.switchState);

  const removeFilter = (id: number) => {
    updateFetching(true);
    try {
      fetch(`/postcovid-dashboard/api/filter/${id}`, {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
        },
      }).then((res) => {
        revalidateData();
        switchState();
      });
    } catch (e) {
      console.log(e);
    }
  };

  const handleIconClick = (
    event: React.MouseEvent<HTMLElement>,
    id: number
  ) => {
    removeFilter(id);
  };

  return (
    <div className="flex flex-col  w-full items-center">
      <Backdrop
        open={fetching}
        sx={{
          color: "#fff",
          zIndex: (theme) => theme.zIndex.drawer + 1,
          position: "absolute",
          width: "100vw",
        }}
      >
        <CircularProgress color="inherit" />
      </Backdrop>
      <h1 className="mb-10">Filters</h1>
      <div className="w-[90%] lg:w-2/5">
        <Card
          sx={{
            padding: 5,
            display: "flex",
            alignItems: "center",
            flexDirection: "column",
          }}
        >
          {filters?.map((filter: Filter, index) => {
            return filter.name === "All" ? (
              ""
            ) : (
              <div
                key={filter.id}
                className="flex items-center bg-slate-200 m-2 w-full lg:w-4/6 p-2 rounded-md"
              >
                <div className="w-4/6 flex justify-center" key={index}>
                  {filter.name}
                </div>
                <div>
                  <IconButton>
                    <EditIcon sx={{ color: filter.color }} />
                  </IconButton>
                  <IconButton
                    onClick={(event) => handleIconClick(event, filter.id)}
                  >
                    <DeleteIcon sx={{ color: filter.color }} />
                  </IconButton>
                </div>
              </div>
            );
          })}
        </Card>
      </div>
    </div>
  );
}
