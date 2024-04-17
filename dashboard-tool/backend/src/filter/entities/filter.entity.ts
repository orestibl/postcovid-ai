import { FilterToCriterion } from '../../filter-to-criterion/entities/filter-to-criterion.entity';
import { Study } from '../../study/entities/study.entity';
import { User } from '../../user/entities/user.entity';
import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  OneToMany,
  ManyToOne,
  OneToOne,
} from 'typeorm';

@Entity()
export class Filter {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @Column()
  color: string;

  @OneToMany(
    () => FilterToCriterion,
    (filterToCriterion) => filterToCriterion.filter,
  )
  public filterToCriterion: FilterToCriterion[];

  @ManyToOne(() => User, (user) => user.filters, { nullable: false })
  user: User;

  @ManyToOne(() => Study, (study) => study.filters, { nullable: false })
  study: Study;
}
