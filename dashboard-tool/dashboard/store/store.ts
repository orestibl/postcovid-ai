import dayjs, { Dayjs } from "dayjs";
import { create } from "zustand";

type State = {
  dateLeft: Dayjs | null;
  dateRight: Dayjs | null;
  currentDate: Dayjs | null;
};

type Action = {
  updateDateLeft: (dateLeft: State["dateLeft"]) => void;
  updateDateRight: (dateRight: State["dateRight"]) => void;
  updateCurrentDate: (currentDate: State["currentDate"]) => void;
};

export const useDateSliderStore = create<State & Action>((set) => ({
  dateLeft: null,
  dateRight: null,
  currentDate: null,
  updateDateLeft: (date) => set(() => ({ dateLeft: date })),
  updateDateRight: (date) => set(() => ({ dateRight: date })),
  updateCurrentDate: (date) => set(() => ({ currentDate: date })),
}));
