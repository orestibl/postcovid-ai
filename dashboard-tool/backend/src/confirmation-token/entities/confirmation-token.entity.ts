import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";
import {IsEmail} from 'class-validator';

@Entity()
export class ConfirmationToken {

    @PrimaryGeneratedColumn()
    id: number;

    @Column()
    token: string;

    @IsEmail()
    @Column()
    email: string;
    
}
