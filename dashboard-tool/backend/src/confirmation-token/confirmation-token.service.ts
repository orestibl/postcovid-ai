import { Injectable } from '@nestjs/common';
import { CreateConfirmationTokenDto } from './dto/create-confirmation-token.dto';
import { UpdateConfirmationTokenDto } from './dto/update-confirmation-token.dto';
import { Repository } from 'typeorm';
import { ConfirmationToken } from './entities/confirmation-token.entity';
import { InjectRepository } from '@nestjs/typeorm';

@Injectable()
export class ConfirmationTokenService {
  constructor(
    @InjectRepository(ConfirmationToken, 'indicators')
    private confirmationTokenRepository: Repository<ConfirmationToken>,
  ) {}

  create(createConfirmationTokenDto: CreateConfirmationTokenDto) {
    return this.confirmationTokenRepository.save(createConfirmationTokenDto);
  }

  findAll() {
    return `This action returns all confirmationToken`;
  }

  findOne(token: string) {
    return this.confirmationTokenRepository.findOne({ where: { token } });
  }

  update(id: number, updateConfirmationTokenDto: UpdateConfirmationTokenDto) {
    return `This action updates a #${id} confirmationToken`;
  }

  remove(id: number) {
    return this.confirmationTokenRepository.delete(id);
  }
}
