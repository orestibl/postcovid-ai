import { PartialType } from '@nestjs/mapped-types';
import { CreateConfirmationTokenDto } from './create-confirmation-token.dto';

export class UpdateConfirmationTokenDto extends PartialType(CreateConfirmationTokenDto) {}
