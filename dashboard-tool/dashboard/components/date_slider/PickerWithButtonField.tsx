import * as React from "react";
import dayjs, { Dayjs } from "dayjs";

import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { DatePicker, DatePickerProps } from "@mui/x-date-pickers/DatePicker";
import { UseDateFieldProps } from "@mui/x-date-pickers/DateField";
import { CalendarIcon } from "@mui/x-date-pickers";
import {
  BaseSingleInputFieldProps,
  DateValidationError,
  FieldSection,
} from "@mui/x-date-pickers/models";

interface ButtonFieldProps
  extends UseDateFieldProps<Dayjs>,
    BaseSingleInputFieldProps<
      Dayjs | null,
      Dayjs,
      FieldSection,
      DateValidationError
    > {
  setOpen?: React.Dispatch<React.SetStateAction<boolean>>;
  setAnchorEl?: React.Dispatch<React.SetStateAction<HTMLElement>>;
}

function ButtonField(props: ButtonFieldProps) {
  const { setOpen, setAnchorEl } = props;

  const handleClick = (event: React.MouseEvent) => {
    setOpen?.((prev) => !prev);
    if (event.currentTarget.parentElement)
      setAnchorEl?.(event.currentTarget.parentElement);
  };

  return <CalendarIcon sx={{ color: "#5f868f" }} onClick={handleClick} />;
}
type PickerWithButtonFieldProps = {
  update: (date: Dayjs) => void;
  minDate: Dayjs;
  maxDate: Dayjs;
  value: Dayjs;
};

function ButtonDatePicker(
  props: Omit<DatePickerProps<Dayjs>, "open" | "onOpen" | "onClose">
) {
  const [open, setOpen] = React.useState(false);

  const [anchorEl, setAnchorEl] = React.useState<HTMLElement | null>(null);

  return (
    <DatePicker
      slots={{ field: ButtonField, ...props.slots }}
      slotProps={{
        field: { setOpen, setAnchorEl } as any,
        popper: { anchorEl } as any,
      }}
      {...props}
      open={open}
      onClose={() => setOpen(false)}
      onOpen={() => setOpen(true)}
    />
  );
}

export default function PickerWithButtonField({
  update,
  minDate,
  maxDate,
  value,
}: PickerWithButtonFieldProps) {
  return (
    <div className="flex flex-col items-center">
      <LocalizationProvider dateAdapter={AdapterDayjs}>
        <ButtonDatePicker
          minDate={minDate}
          maxDate={maxDate}
          value={value}
          onChange={(newValue) => update(newValue || dayjs())}
        />
      </LocalizationProvider>
      <div className="text-xs mt-2">
        {dayjs(value).format("DD/MM/YYYY").toString()}
      </div>
    </div>
  );
}
