import { PartialType } from '@nestjs/mapped-types';
import { CreateParticipantDto } from './create-participant.dto';

export class UpdateParticipantDto extends PartialType(CreateParticipantDto) {
  id: string;
  birth_date: Date;
  gender: string;
  salary: number;
  zip_code: number;
}
