import { Injectable } from '@nestjs/common';
import { CreateUserPreferenceDto } from './dto/create-user_preference.dto';
import { UpdateUserPreferenceDto } from './dto/update-user_preference.dto';
import { Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { UserPreference } from './entities/user_preference.entity';

@Injectable()
export class UserPreferencesService {

  constructor(
    @InjectRepository(UserPreference, 'indicators')
    private userPreferencesServiceRepository: Repository<UserPreference>,
  ) {}

  create(createUserPreferenceDto: CreateUserPreferenceDto) {
    return this.userPreferencesServiceRepository.save(createUserPreferenceDto);
  }

  findAll() {
    return `This action returns all userPreferences`;
  }

  findOne(id: number) {
    return `This action returns a #${id} userPreference`;
  }

  update(id: number, updateUserPreferenceDto: UpdateUserPreferenceDto) {
    return `This action updates a #${id} userPreference`;
  }

  remove(id: number) {
    return `This action removes a #${id} userPreference`;
  }
}
