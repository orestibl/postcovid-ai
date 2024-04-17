import { IsString, IsNotEmpty } from 'class-validator';

export class CreateStudyDto {
    
    @IsNotEmpty() @IsString()
    id: string;

    @IsNotEmpty() @IsString()
    name: string;

    @IsNotEmpty() @IsString()
    description: string;
}
