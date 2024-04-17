import { Entity, Column, PrimaryColumn, OneToMany, ManyToOne } from 'typeorm';
import { Indicator } from '../../indicator/entities/indicator.entity';
import { Study } from '../../study/entities/study.entity';

@Entity()
export class Participant {
  @PrimaryColumn()
  id: string;

  @Column({ type: 'date' })
  birth_date: Date;

  @Column()
  gender: string;

  @Column()
  income: string;

  @Column({ nullable: true, type: 'text' })
  zip_code: string;

  @OneToMany(() => Indicator, (indicator) => indicator.participant)
  indicators: Indicator[];

  @ManyToOne(() => Study, (study) => study.participants)
  study: Study;
}
