import { create } from "zustand";

interface CategoryState {
  categories: string[];
  updateCategories: (payload: string[]) => void;
}

export const useCategoryStore = create<CategoryState>()((set) => ({
  categories: [],
  updateCategories: (payload) => set(() => ({ categories: payload })),
}));
