import { Study } from "@/types/types";
import { create } from "zustand";

type StudyState = {
  study: Study | null;
  updateStudy: (study: StudyState["study"] | null) => void;
};

const useStudyStore = create<StudyState>((set) => ({
  study: null,
  updateStudy: (study) => set(() => ({ study: study })),
}));

export default useStudyStore;
