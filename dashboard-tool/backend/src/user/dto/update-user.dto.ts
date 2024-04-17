import { PartialType } from '@nestjs/mapped-types';
import { CreateUserDto } from './create-user.dto';
import { Role } from '../../types/types';

export class UpdateUserDto extends PartialType(CreateUserDto) {
  name: string;
  lastname: string;
  verified?: boolean;
  role?: Role;
}
