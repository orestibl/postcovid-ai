"use client";
import React, { useEffect, useRef } from "react";
import Button from "@mui/material/Button";
import Dialog from "@mui/material/Dialog";
import AppBar from "@mui/material/AppBar";
import Toolbar from "@mui/material/Toolbar";
import IconButton from "@mui/material/IconButton";
import Typography from "@mui/material/Typography";
import CloseIcon from "@mui/icons-material/Close";
import Slide from "@mui/material/Slide";
import { TransitionProps } from "@mui/material/transitions";
import AddCircleOutlineIcon from "@mui/icons-material/AddCircleOutline";
import Stack from "@mui/material/Stack";
import FilterOptions from "./FilterOptions";
import { CriterionDetail, FilterData, UpdateFilterDto } from "@/types/types";
import { useSession } from "next-auth/react";
import { Alert, CircularProgress } from "@mui/material";
import { useQuery } from "react-query";
import { Criterion } from "@/types/types";
import Backdrop from "@mui/material/Backdrop";

import revalidateData, { addFilter, getCriteria } from "@/app/action";
import { useTranslations } from "next-intl";
import { useReloadStore } from "@/store/reload";

const Transition = React.forwardRef(function Transition(
  props: TransitionProps & {
    children: React.ReactElement;
  },
  ref: React.Ref<unknown>
) {
  return <Slide direction="up" ref={ref} {...props} />;
});

function FilterModal() {
  const t = useTranslations("filters");

  const [open, setOpen] = React.useState(false);
  const filterOptionsRef = useRef<{ getFilterData: () => any }>(null);
  const { data: session } = useSession();
  const [error, setError] = React.useState<string>("");
  const [saving, setSaving] = React.useState<boolean>(false);

  const updateFetching = useReloadStore((state) => state.updateFetching);
  const fetching = useReloadStore((state) => state.fetching);

  const switchState = useReloadStore((state) => state.switchState);

  const useCriterion = () => {
    return useQuery("criterion", () => {
      const res = getCriteria();
      return res
        .then((response) => {
          console.log("response", response);
          return response;
        })
        .catch((error) => {
          throw new Error("Network response was not ok", error);
        });
    });
  };

  const { data, isLoading, isSuccess } = useCriterion();

  const criteria = data ? (data as Criterion[]) : [];

  const handleClickOpen = () => {
    setOpen(true);
  };

  const handleClose = () => {
    setOpen(false);
  };

  const validateForm = () => {
    if (filterOptionsRef.current) {
      const filterData: FilterData = filterOptionsRef.current.getFilterData();
      if (!filterData.name || !filterData.hex) {
        setError("Validation failed: Missing required fields");
        return false;
      }
      if (
        filterData.ageEnabled &&
        (!filterData.age || filterData.age.length !== 2)
      ) {
        setError("Validation failed: Age should be an array of two numbers");
        return false;
      }
      if (
        filterData.incomeEnabled &&
        (!filterData.income || filterData.income === "")
      ) {
        setError(
          "Validation failed: income should be one of the options available"
        );
        return false;
      }
      if (typeof filterData.gender !== "string" || filterData.gender === "") {
        setError("Validation failed: Gender is required and must be a string");
        return false;
      }
      if (filterData.areaEnabled && filterData.area === "") {
        setError("Validation failed: Area is required ");
        return false;
      }

      if (!filterData.hex || !filterData.hex.match(/^#[0-9A-F]{6}$/i)) {
        setError("Validation failed: Hex must be a valid color code");
        return false;
      }

      return true;
    }
    return false;
  };

  const handleSave = () => {
    if (validateForm()) {
      setError("");
      submitFilter();
    }
  };

  const parseFilterData = (
    filterData: FilterData,
    criteria: Criterion[]
  ): CriterionDetail[] => {
    const c: CriterionDetail[] = [];

    if (filterData.ageEnabled) {
      c.push({
        id: criteria.filter((c) => c.name === "age")[0].id,
        lower_value: filterData.age[0],
        higher_value: filterData.age[1],
        value: null,
      });
    }
    if (filterData.incomeEnabled) {
      c.push({
        id: criteria.filter((c) => c.name === "income")[0].id,
        lower_value: null,
        higher_value: null,
        value: filterData.income,
      });
    }
    if (filterData.genderEnabled) {
      c.push({
        id: criteria.filter((c) => c.name === "gender")[0].id,
        lower_value: null,
        higher_value: null,
        value: filterData.gender,
      });
    }
    if (filterData.areaEnabled) {
      c.push({
        id: criteria.filter((c) => c.name === "zip_code")[0].id,
        lower_value: null,
        higher_value: null,
        value: filterData.area,
      });
    }

    return c;
  };

  const submitFilter = () => {
    if (filterOptionsRef.current) {
      updateFetching(true);
      const filterData: FilterData = filterOptionsRef.current.getFilterData();

      const id = session?.user.userToStudies[0].study.id || "";

      fetch(`/postcovid-dashboard/api/filter`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          name: filterData.name,
          color: filterData.hex,
          studyId: id,
          criteria: data
            ? parseFilterData(filterData, data as Criterion[])
            : [],
        }),
      })
        .then((data) => {
          revalidateData();
          switchState();
        })
        .catch((error) => {
          console.log(error);
        });
    }
  };

  useEffect(() => {
    if (!fetching) handleClose();
  }, [fetching]);

  // const updateFilter = async (filterId: number, payload: UpdateFilterDto) => {
  //   if (filterOptionsRef.current) {
  //     fetch(`/postcovid-dashboard/api/filter/${filterId}`, {
  //       method: "PATCH",
  //       headers: {
  //         "Content-Type": "application/json",
  //       },
  //       body: JSON.stringify(payload),
  //     })
  //       .then((response) => response.json())
  //       .then((data) => {})
  //       .catch((error) => {
  //         console.error("Error:", error);
  //       });
  //   }
  // };

  return (
    <React.Fragment>
      <Stack direction="row" spacing={1}>
        <IconButton aria-label="add" onClick={handleClickOpen}>
          <AddCircleOutlineIcon sx={{ fontSize: 30 }} />
        </IconButton>
      </Stack>
      <Dialog
        fullScreen
        open={open}
        onClose={handleClose}
        TransitionComponent={Transition}
      >
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
        <AppBar sx={{ position: "relative" }}>
          <Toolbar>
            <IconButton
              edge="start"
              color="inherit"
              onClick={handleClose}
              aria-label="close"
            >
              <CloseIcon />
            </IconButton>
            <Typography sx={{ ml: 2, flex: 1 }} variant="h6" component="div">
              {t("add")}
            </Typography>

            <Button autoFocus color="inherit" onClick={handleSave}>
              save
            </Button>
          </Toolbar>
        </AppBar>
        <FilterOptions ref={filterOptionsRef} />
        {error && (
          <Alert sx={{ alignSelf: "center" }} severity="error">
            {error}
          </Alert>
        )}
      </Dialog>
    </React.Fragment>
  );
}

export default FilterModal;
