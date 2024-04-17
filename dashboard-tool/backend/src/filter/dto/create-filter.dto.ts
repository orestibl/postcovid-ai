import { CriterionDetail } from '../../types/types';
export class CreateFilterDto {
  name: string;
  color: string;
  studyId: string;
  criteria: CriterionDetail[];
}
