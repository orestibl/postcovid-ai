"use client";

import PickerWithButtonField from "./PickerWithButtonField";
import SliderIndicator from "./SliderIndicator";
import dayjs from "dayjs";
import { useDateSliderStore } from "@/store/store";
import { useDateRangeStore } from "@/store/date_range_store";

function DateSlider() {
  const updateDateLeft = useDateSliderStore((state) => state.updateDateLeft);
  const updateDateRight = useDateSliderStore((state) => state.updateDateRight);

  const limitLeft = useDateRangeStore((state) => state.limitLeft);
  const limitRight = useDateRangeStore((state) => state.limitRight);

  const dateLeft = useDateSliderStore((state) => state.dateLeft);
  const dateRight = useDateSliderStore((state) => state.dateRight);
  const currentDate = useDateSliderStore((state) => state.currentDate);

  const steps =
    dateRight?.diff(dateLeft, "days") == 0
      ? 1
      : dateRight?.diff(dateLeft, "days");

  return (
    <div className="flex min-w-fit flex-col items-center">
      <div className="flex w-fit mb-[-7px] text-sm rounded-md justify-center bg-white/80 ">
        {currentDate?.format("DD-MM-YYYY").toString()}
      </div>
      <div className="flex min-w-fit">
        <PickerWithButtonField
          update={updateDateLeft}
          value={dateLeft || dayjs()}
          minDate={limitLeft || dayjs()}
          maxDate={dayjs(dateRight) || dayjs()}
        />
        {steps && <SliderIndicator steps={steps} />}
        <PickerWithButtonField
          update={updateDateRight}
          value={dateRight || dayjs()}
          minDate={dateLeft || dayjs()}
          maxDate={limitRight || dayjs()}
        />
      </div>
    </div>
  );
}

export default DateSlider;
