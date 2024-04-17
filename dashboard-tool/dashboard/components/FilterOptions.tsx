"use client";
import Circle from "@uiw/react-color-circle";
import React, { useEffect } from "react";
import TextField from "@mui/material/TextField";
import Card from "@mui/material/Card";
import RangeSlider from "./RangeSlider";
import Checkbox from "@mui/material/Checkbox";
import Select, { SelectChangeEvent } from "@mui/material/Select";
import { MenuItem } from "@mui/material";
import AreaSelector from "./AreaSelector";
import { FilterData } from "@/types/types";
import IncomeSelector from "./IncomeSelector";

const FilterOptions = React.forwardRef((props, ref) => {
  const [hex, setHex] = React.useState("#ff6961");
  const [age, setAge] = React.useState<number[]>([28, 50]);
  const [salary, setSalary] = React.useState<string>("");
  const [gender, setGender] = React.useState("male");
  const [ageEnabled, setAgeDisabled] = React.useState(true);
  const [salaryEnabled, setSalaryDisabled] = React.useState(true);
  const [genderEnabled, setGenderDisabled] = React.useState(true);
  const [areaEnabled, setAreaDisabled] = React.useState(true);
  const [area, setArea] = React.useState("");
  const [name, setName] = React.useState("");

  React.useImperativeHandle(ref, () => ({
    getFilterData(): FilterData {
      // Logic to gather data from fields
      // Replace with actual data gathering logic
      const data = {
        hex: hex,
        age: age,
        income: salary,
        gender: gender,
        ageEnabled: ageEnabled,
        incomeEnabled: salaryEnabled,
        genderEnabled: genderEnabled,
        areaEnabled: areaEnabled,
        area: area,
        name: name,
      };

      return data as FilterData;
    },
  }));

  const handleChange = (event: SelectChangeEvent) => {
    setGender(event.target.value as string);
  };

  return (
    <div className="w-full flex flex-col items-center">
      <div className="w-full lg:w-3/5 xl:w-2/5 mt-20">
        <Card sx={{ padding: 5 }}>
          <div className="flex  items-center ">
            <div className="flex flex-col">
              <span className="text-lg font-bold mb-3">Filter name</span>
              <TextField
                required
                value={name}
                onChange={(e) => setName(e.target.value)}
                id="outlined-required"
                label="Fiter name"
                placeholder="Filter name"
              />
            </div>
            <div className="ml-10 w-[40%] flex flex-col items-center">
              <div className="mb-2">
                <span>Pick a color</span>
              </div>

              <Circle
                colors={[
                  "#2196F3",
                  "#000000",
                  "#9C27B0",
                  "#FFC107",
                  "#FF5722",
                  "#8BC34A",
                  "#960018",
                  "#3F51B5",
                ]}
                color={hex}
                onChange={(color) => {
                  setHex(color.hex);
                }}
              />

              <div
                className="w-full rounded-md h-1"
                style={{ backgroundColor: hex }}
              ></div>
            </div>
          </div>
        </Card>
      </div>
      <div className="w-full lg:w-3/5 xl:w-2/5 mt-10">
        <Card sx={{ padding: 5 }}>
          <div className="flex bg-slate-100 rounded-md p-2 items-center">
            <Checkbox
              defaultChecked
              onChange={(e) => {
                setAgeDisabled(e.target.checked);
              }}
            />
            <div className="w-2/5 flex justify-center">
              <span className="text-lg font-bold ">Age</span>
            </div>
            <RangeSlider
              rangeMin={18}
              rangeMax={90}
              value={age}
              setValue={setAge}
              disabled={!ageEnabled}
            />
          </div>
          <div className="flex bg-slate-100 rounded-md p-2 items-center">
            <Checkbox
              defaultChecked
              onChange={(e) => {
                setSalaryDisabled(e.target.checked);
              }}
            />
            <div className="w-2/5 flex justify-center">
              <span className="text-lg font-bold ">Salary</span>
            </div>
            {/* <RangeSlider
              rangeMin={18000}
              rangeMax={90000}
              value={salary}
              setValue={setSalary}
              disabled={!salaryEnabled}
            /> */}
            <IncomeSelector
              disabled={!salaryEnabled}
              value={salary}
              setValue={setSalary}
            />
          </div>
          <div className="flex bg-slate-100 rounded-md p-2 items-center">
            <Checkbox
              defaultChecked
              onChange={(e) => {
                setGenderDisabled(e.target.checked);
              }}
            />
            <div className="w-2/5 flex justify-center">
              <span className="text-lg font-bold ">Gender</span>
            </div>
            <Select
              sx={{ width: "40%" }}
              value={gender}
              disabled={!genderEnabled}
              label="Age"
              onChange={handleChange}
            >
              <MenuItem value={"male"}>Male</MenuItem>
              <MenuItem value={"female"}>Female</MenuItem>
            </Select>
          </div>
          <div className="flex bg-slate-100 rounded-md p-2 items-center">
            <Checkbox
              defaultChecked
              onChange={(e) => {
                setAreaDisabled(e.target.checked);
              }}
            />
            <div className="w-2/5 flex justify-center">
              <span className="text-lg font-bold ">Area</span>
            </div>
            <AreaSelector
              disabled={!areaEnabled}
              value={area}
              setValue={setArea}
            />
          </div>
        </Card>
      </div>
    </div>
  );
});

FilterOptions.displayName = "FilterOptions";

export default FilterOptions;
