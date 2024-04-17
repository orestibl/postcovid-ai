import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  OneToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { UserPreference } from '../../user_preferences/entities/user_preference.entity';
import { UserToStudy } from '../../user-to-study/entities/user-to-study.entity';
import { Filter } from '../../filter/entities/filter.entity';
import { Role } from '../../types/types';

@Entity()
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  email: string;

  @Column()
  password: string;

  @Column()
  name: string;

  @Column()
  lastname: string;

  @Column()
  verified: boolean;

  @Column({ type: 'enum', enum: Role })
  role: Role;

  @OneToMany(() => UserPreference, (userPreference) => userPreference.user)
  public preferences: UserPreference[];

  @OneToMany(() => UserToStudy, (userToStudy) => userToStudy.user)
  public userToStudies: UserToStudy[];

  @OneToMany(() => Filter, (filter) => filter.user)
  public filters: Filter[];
}
