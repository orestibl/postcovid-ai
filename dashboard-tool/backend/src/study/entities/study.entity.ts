import {
  Entity,
  Column,
  OneToMany,
  PrimaryColumn,
  ManyToMany,
  JoinTable,
} from 'typeorm';
import { Indicator } from '../../indicator/entities/indicator.entity';
import { UserToStudy } from '../../user-to-study/entities/user-to-study.entity';
import { Participant } from '../../participant/entities/participant.entity';
import { Filter } from '../../filter/entities/filter.entity';

@Entity()
export class Study {
  @PrimaryColumn()
  id: string;

  @Column()
  name: string;

  @Column()
  description: string;

  @OneToMany(() => Indicator, (indicator) => indicator.study)
  indicators: Indicator[];

  @OneToMany(() => UserToStudy, (userToStudy) => userToStudy.study)
  public userToStudies: UserToStudy[];

  @OneToMany(() => Participant, (participant) => participant.id)
  participants: Participant[];

  @OneToMany(() => Filter, (filter) => filter.study)
  filters: Filter[];
}
