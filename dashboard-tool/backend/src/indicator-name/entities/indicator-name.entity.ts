import { Entity, Column, PrimaryColumn, OneToMany, PrimaryGeneratedColumn } from 'typeorm';
import { Indicator } from '../../indicator/entities/indicator.entity';
@Entity()
export class IndicatorName {
    @PrimaryGeneratedColumn()
    id: number;

    @Column()
    name: string;

    @OneToMany(() => Indicator, indicator => indicator.indicatorName)
    indicators: Indicator[];
}
