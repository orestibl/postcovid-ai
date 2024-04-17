import { PartialType } from '@nestjs/mapped-types';
import { CreateFilterToCriterionDto } from './create-filter-to-criterion.dto';

export class UpdateFilterToCriterionDto extends PartialType(CreateFilterToCriterionDto) {}
