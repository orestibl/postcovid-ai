import { IndicatorName } from 'src/indicator-name/entities/indicator-name.entity';
import { User } from '../../user/entities/user.entity';
import { Entity, Column, PrimaryGeneratedColumn, ManyToOne } from 'typeorm';
import { Study } from 'src/study/entities/study.entity';

@Entity()
export class UserPreference {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  min: number;

  @Column()
  max: number;

  @ManyToOne(() => User, (user) => user.preferences)
  user: User;

  @ManyToOne(() => IndicatorName)
  indicatorName: IndicatorName;

  @ManyToOne(() => Study)
  study: Study;
}
