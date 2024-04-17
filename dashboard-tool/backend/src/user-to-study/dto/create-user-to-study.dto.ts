import { Study } from '../../study/entities/study.entity';
import { Role } from '../../types/types';
import { User } from '../../user/entities/user.entity';

export class CreateUserToStudyDto {
  user: User;
  study: Study;
  role: Role;
}
