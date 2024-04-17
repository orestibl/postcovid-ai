import { FilterToCriterion } from '../../filter-to-criterion/entities/filter-to-criterion.entity';
import {
  Entity,
  Column,
  PrimaryColumn,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';

@Entity()
export class Criterion {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @Column()
  nature: number;

  @OneToMany(
    () => FilterToCriterion,
    (filterToCriterion) => filterToCriterion.criterion,
  )
  public filterToCriterion: FilterToCriterion[];
}
