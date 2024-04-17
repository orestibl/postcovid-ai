import { PartialType } from '@nestjs/mapped-types';
import { CreateUserDto } from './create-user.dto';
import { Role } from '../../types/types';

export class UpdateUserStudyDto extends PartialType(CreateUserDto) {
  studyId?: string;
  role?: Role;
}
