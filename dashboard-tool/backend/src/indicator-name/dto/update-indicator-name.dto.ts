import { PartialType } from '@nestjs/mapped-types';
import { CreateIndicatorNameDto } from './create-indicator-name.dto';

export class UpdateIndicatorNameDto extends PartialType(CreateIndicatorNameDto) {
    name: string;
}
