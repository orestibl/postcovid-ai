import dayjs, { Dayjs } from "dayjs";
import { Indicator } from "@/types/types";
import { create } from "zustand";

type State = {
  indicators: Indicator[][];
  updateIndicators: (indicators: Indicator[][]) => void;
};

export const useIndicatorStore = create<State>((set) => ({
  indicators: [],
  updateIndicators: (indicators) => set(() => ({ indicators: indicators })),
}));
