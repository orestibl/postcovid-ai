import * as React from "react";
import Box from "@mui/material/Box";
import Slider from "@mui/material/Slider";

function valuetext(value: number) {
  return `${value}°C`;
}

const minDistance = 0;

type Props = {
  rangeMin: number;
  rangeMax: number;
  value: number[];
  setValue: (value: number[]) => void;
  disabled: boolean;
};

export default function RangeSlider({
  rangeMin,
  rangeMax,
  value,
  setValue,
  disabled,
}: Props) {
  const handleChange1 = (
    event: Event,
    newValue: number | number[],
    activeThumb: number
  ) => {
    if (!Array.isArray(newValue)) {
      return;
    }

    if (activeThumb === 0) {
      setValue([Math.min(newValue[0], value[1] - minDistance), value[1]]);
    } else {
      setValue([value[0], Math.max(newValue[1], value[0] + minDistance)]);
    }
  };

  return (
    <Box sx={{ width: 300 }}>
      <div className="w-full flex flex-col">
        <Slider
          disabled={disabled}
          max={rangeMax}
          min={rangeMin}
          getAriaLabel={() => "Minimum distance"}
          value={value}
          onChange={handleChange1}
          valueLabelDisplay="auto"
          getAriaValueText={valuetext}
          disableSwap
        />
        <div className="flex justify-between">
          <span>{rangeMin}</span>
          <span>{rangeMax}</span>
        </div>
      </div>
    </Box>
  );
}
