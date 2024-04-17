import { Filter } from "@/types/types";
import { create } from "zustand";

interface FilterState {
  filters: Filter[];
  updateFilters: (payload: Filter[]) => void;
}

export const useFilterStore = create<FilterState>()((set) => ({
  filters: [],
  updateFilters: (payload) => set(() => ({ filters: payload })),
}));
