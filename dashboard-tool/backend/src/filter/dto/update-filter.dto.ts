import { PartialType } from '@nestjs/mapped-types';
import { CreateFilterDto } from './create-filter.dto';
import { CriterionDetail } from '../../types/types';

export class UpdateFilterDto extends PartialType(CreateFilterDto) {
  name: string;
  color: string;
  criteria: CriterionDetail[];
}
