"use client";
import React, { useEffect } from "react";
import MenuItem from "@mui/material/MenuItem";
import FormHelperText from "@mui/material/FormHelperText";
import FormControl from "@mui/material/FormControl";
import Select, { SelectChangeEvent } from "@mui/material/Select";
import { useQuery } from "react-query";
import { useSession } from "next-auth/react";

type Props = {
  value: string;
  setValue: (value: string) => void;
  disabled: boolean;
};

function IncomeSelector({ value, setValue, disabled }: Props) {
  const { data: session } = useSession();

  const useIncome = () => {
    return useQuery("income", async () => {
      const response = await fetch(
        `/postcovid-dashboard/api/income?study=${session?.user.userToStudies[0].study.id}`,
        {
          method: "GET",
          headers: {
            "Content-Type": "application/json",
          },
        }
      );

      const json = await response.json();

      return json;
    });
  };

  const { data, isLoading, error, isSuccess, isRefetching } = useIncome();

  if (isLoading) return <div>Loading...</div>;

  if (error) return <div>Error loading zip codes</div>;

  const onChange = (event: SelectChangeEvent) => {
    setValue(event.target.value);
  };

  return (
    <Select
      value={value}
      onChange={onChange}
      disabled={disabled}
      sx={{ width: "40%" }}
    >
      {data &&
        data?.map((income: { income: string }, index: number) => {
          return (
            <MenuItem key={index} value={income.income}>
              {income.income}
            </MenuItem>
          );
        })}
    </Select>
  );
}

export default IncomeSelector;
