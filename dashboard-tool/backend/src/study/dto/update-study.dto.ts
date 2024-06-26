import { PartialType } from '@nestjs/mapped-types';
import { CreateStudyDto } from './create-study.dto';

export class UpdateStudyDto extends PartialType(CreateStudyDto) {
    id: string;
    name: string;
    description: string;
}
