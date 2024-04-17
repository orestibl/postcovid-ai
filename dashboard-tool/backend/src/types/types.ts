import { Filter } from '../filter/entities/filter.entity';
import { Study } from '../study/entities/study.entity';

export type IndicatorQuery = {
  filters: Filter[];
  study: Study;
};

export type CriterionDetail = {
  id: number;
  lower_value: number | null;
  higher_value: number | null;
  value: string;
};

export enum Role {
  'ADMIN',
  'USER',
  'STUDY_ADMIN',
}
