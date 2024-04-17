import { Dayjs } from "dayjs";

export enum Role {
  "ADMIN",
  "USER",
  "STUDY_ADMIN",
}

export type Study = {
  id: string;
  name: string;
  description: string;
};

export type UserToStudy = {
  id: number;
  role: Role;
  study: Study;
};

export type IndicatorName = {
  id: number;
  name: string;
};

export type Participant = {
  id: string;
  birth_date: Date;
  gender: string;
  income: number;
  area: number;
};

export type Indicator = {
  color: string;
  date: Date;
  filter_name: string;
  [key: string]: string | number | Date;
};

export type DateRange = {
  start: Dayjs | null;
  end: Dayjs | null;
};

export type CategoryIconProps = {
  color: string;
  size: number;
  pos: number;
};

export type RowStateProps = {
  color: string;
  size: number;
  pos: number;
  category: string;
};

export type FilterResult = {
  color: string;
  pos: number;
};

export type Criterion = {
  id: number;
  name: string;
  nature: CriterionType;
};

export type CriterionDetail = {
  id: number;
  lower_value: number | null;
  higher_value: number | null;
  value: string | number | null;
};

export type UpdateFilterDto = {
  name: string | null;
  color: string | null;
  criteria: CriterionDetail[];
};

export type FilterToCriterion = {
  id: number;
  lower_value: number | null;
  higher_value: number | null;
  value: string | number | null;
  criterion: Criterion;
};

export type Filter = {
  id: number;
  name: string;
  color: string;
  filterToCriterion: FilterToCriterion[];
  number_participants: number;
};

export enum CriterionType {
  "RANGE",
  "VALUE",
}

export type DailyIndicator = {
  [key: string]: string | number | Dayjs;
  filter_name: string;
};

export interface LangProps {
  params: {
    lang: string;
  };
}
export type FilterData = {
  name: string;
  hex: string;
  age: number[];
  income: string;
  gender: string;
  ageEnabled: boolean;
  incomeEnabled: boolean;
  genderEnabled: boolean;
  areaEnabled: boolean;
  area: number | string;
};
