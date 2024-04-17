import { Filter } from "@/types/types";
import { create } from "zustand";

interface ReloadState {
  reload: boolean;
  fetching: boolean;
  switchState: () => void;
  updateFetching: (isFetching: boolean) => void;
}

export const useReloadStore = create<ReloadState>()((set) => ({
  reload: false,
  fetching: false,
  switchState: () => set((state) => ({ reload: !state.reload })),
  updateFetching: (isFetching) => set(() => ({ fetching: isFetching })),
}));
