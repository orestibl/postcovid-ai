import { Entity, Column, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';

import { Filter } from '../../filter/entities/filter.entity';
import { Criterion } from '../../criterion/entities/criterion.entity';

@Entity()
export class FilterToCriterion {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ nullable: true })
  lower_value: number;

  @Column({ nullable: true })
  higher_value: number;

  @Column({ nullable: true })
  value: string;

  @ManyToOne(() => Filter, (filter) => filter.filterToCriterion)
  public filter: Filter;

  @ManyToOne(() => Criterion, (criterion) => criterion.filterToCriterion)
  public criterion: Criterion;
}
