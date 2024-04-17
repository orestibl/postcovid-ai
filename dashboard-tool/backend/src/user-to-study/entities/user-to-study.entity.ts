import {
  Entity,
  Column,
  OneToOne,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';

import { User } from '../../user/entities/user.entity';
import { Study } from '../../study/entities/study.entity';
import { Role } from '../../types/types';

@Entity()
export class UserToStudy {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'enum', enum: Role })
  role: Role;

  @ManyToOne(() => User, (user) => user.userToStudies)
  public user: User;

  @ManyToOne(() => Study, (study) => study.userToStudies)
  public study: Study;
}
