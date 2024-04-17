import { PartialType } from '@nestjs/mapped-types';
import { CreateUserToStudyDto } from './create-user-to-study.dto';

export class UpdateUserToStudyDto extends PartialType(CreateUserToStudyDto) {}
