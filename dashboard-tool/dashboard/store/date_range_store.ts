import dayjs, { Dayjs } from "dayjs"
import {create} from "zustand"

type State = {
    limitLeft: Dayjs | null
    limitRight: Dayjs | null
    updateLimitLeft: (limitLeft: State['limitLeft']) => void
    updateLimitRight: (limitRight: State['limitRight']) => void
}

export const useDateRangeStore = create<State>((set) => ({
    limitLeft: null,
    limitRight: null,
    updateLimitLeft: (limitLeft) => set(() => ({ limitLeft: limitLeft })),
    updateLimitRight: (limitRight) => set(() => ({ limitRight: limitRight})),
}))