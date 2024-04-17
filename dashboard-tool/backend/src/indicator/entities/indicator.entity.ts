import { Entity, Column, PrimaryGeneratedColumn, ManyToOne } from 'typeorm';
import { IndicatorName } from '../../indicator-name/entities/indicator-name.entity';
import { Participant } from '../../participant/entities/participant.entity';
import {Study} from '../../study/entities/study.entity';
@Entity()
export class Indicator {
    @PrimaryGeneratedColumn()
    id: number

    @Column()
    date: Date;

    @Column("float", { nullable: true })
    weighting: number;

    @ManyToOne(() => IndicatorName, indicatorName => indicatorName.indicators)
    indicatorName: IndicatorName;

    @ManyToOne(() => Study, study => study.indicators)
    study: Study;

    @ManyToOne(() => Participant, participant => participant.indicators)
    participant: Participant;

    @Column({ nullable: true })
    value: number;

}
