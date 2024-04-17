import { ConflictException, Injectable } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { hash } from 'bcrypt';
import { UserPreferencesService } from '../user_preferences/user_preferences.service';
import { StudyService } from '../study/study.service';
import { UserToStudyService } from '../user-to-study/user-to-study.service';
import { UpdateUserStudyDto } from './dto/update-user-study.dto';
import { Role } from '../types/types';

@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User, 'indicators')
    private userRepository: Repository<User>,
    private studyService: StudyService,
    private userToStudyService: UserToStudyService,
  ) {}

  async create(createUserDto: CreateUserDto) {

    console.log('createUserDto', createUserDto);

    if (!createUserDto.email || createUserDto.email.trim() === '') {
      throw new ConflictException('Email cannot be empty');
    }
    if (!createUserDto.password || createUserDto.password.trim() === '') {
      throw new ConflictException('Password cannot be empty');
    }
    if (!createUserDto.name || createUserDto.name.trim() === '') {
      throw new ConflictException('Name cannot be empty');
    }
    if (!createUserDto.lastname || createUserDto.lastname.trim() === '') {
      throw new ConflictException('Lastname cannot be empty');
    }

    const user = await this.userRepository.findOneBy({
      email: createUserDto.email,
    });

    console.log('user', user);

    if (user) throw new ConflictException('Email duplicated');

    const hashedPassword = await hash(createUserDto.password, 10);

    const newUser = this.userRepository.create({
      ...createUserDto,
      password: hashedPassword,
      role: Role.USER,
      verified: false,
      // preferences: userPreference,
    });
    // newUser.addPreferences(userPreference);

    await this.userRepository.save(newUser);

    // await this.updateRoleStudy(newUser.id, {
    //   studyId: createUserDto.study,
    //   role: Role.USER,
    // });

    const { password, ...result } = newUser;

    return result;
  }

  async findUsersByStudy(id: string) {
    const study = await this.studyService.findOne(id);

    const users = await this.userRepository.find({
      select: ['id', 'email', 'name', 'lastname', 'role', 'verified'],
      relations: {
        userToStudies: true,
      },
      where: {
        userToStudies: {
          study: study,
        },
        verified: false,
      },
    });

    return users;
  }

  async findOneByEmail(email: string) {
    const user = await this.userRepository.findOne({
      where: { email: email },
      relations: {
        filters: {
          filterToCriterion: {
            criterion: true,
          },
        },
        userToStudies: {
          study: true,
        },
      },
    });
    return user;
  }

  async findOneByEmailandSudy(email: string, studyId: number) {
    const user = await this.userRepository.findOne({
      where: { email: email },
      relations: {
        filters: {
          filterToCriterion: {
            criterion: true,
          },
        },
      },
    });

    return user;
  }

  async findById(id: number) {
    const user = await this.userRepository.findOne({
      where: { id: id },
      relations: {
        filters: {
          filterToCriterion: {
            criterion: true,
          },
        },
      },
    });

    return user;
  }

  findAll() {
    return `This action returns all user`;
  }

  findOne(id: number) {
    return `This action returns a #${id} user`;
  }

  async enableByEmail(email: string) {
    const user = await this.userRepository.findOne({
      where: { email: email },
    });

    if (user) {
      user.verified = true;
      return this.userRepository.update(user.id, { verified: true });
    }
    if (!user) {
      throw new Error(`User  not found`);
    }
  }

  async updateRoleStudy(id: number, updateUserStudyDto: UpdateUserStudyDto) {
    const study = updateUserStudyDto.studyId
      ? await this.studyService.findOne(updateUserStudyDto.studyId)
      : null;
    const user = await this.userRepository.findOne({ where: { id } });

    if (!user) {
      throw new Error(`User with ID ${id} not found`);
    }

    return this.userToStudyService.create({
      user: user,
      study: study,
      role: updateUserStudyDto.role,
    });
  }

  async update(id: number, updateUserDto: UpdateUserDto) {
    const user = await this.userRepository.findOne({ where: { id } });

    if (!user) {
      throw new Error(`User with ID ${id} not found`);
    }

    this.userRepository.save({
      ...user,
      ...updateUserDto,
    });
  }

  remove(id: number) {
    return this.userRepository.delete(id);
  }
}
