import { Injectable } from '@nestjs/common';
import { CreateUserToStudyDto } from './dto/create-user-to-study.dto';
import { UpdateUserToStudyDto } from './dto/update-user-to-study.dto';
import { User } from '../user/entities/user.entity';
import { Study } from '../study/entities/study.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { UserToStudy } from './entities/user-to-study.entity';
import { Repository } from 'typeorm';

@Injectable()
export class UserToStudyService {
  constructor(
    @InjectRepository(UserToStudy, 'indicators')
    private userToStudyRepository: Repository<UserToStudy>,
  ) {}

  async create(createUserToStudyDto: CreateUserToStudyDto) {
    return this.userToStudyRepository.save(createUserToStudyDto);
  }

  findOne(id: number) {
    return this.userToStudyRepository.findOne({ where: { id } });
  }

  findAll() {
    return `This action returns all userToStudy`;
  }

  findOneByUserAndStudy(user: User, study: Study) {
    return this.userToStudyRepository.findOne({
      where: { user: user, study: study },
    });
  }

  findAllByUser(user: User) {
    return this.userToStudyRepository.find({ where: { user: user } });
  }

  update(id: number, updateUserToStudyDto: UpdateUserToStudyDto) {
    return `This action updates a #${id} userToStudy`;
  }

  remove(id: number) {
    return `This action removes a #${id} userToStudy`;
  }
}
