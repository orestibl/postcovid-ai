import { Module } from '@nestjs/common';
import { UserService } from './user.service';
import { UserController } from './user.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from './entities/user.entity';
import { JwtService } from '@nestjs/jwt';
import { StudyModule } from '../study/study.module';
import { StudyService } from '../study/study.service';
import { UserToStudyModule } from '../user-to-study/user-to-study.module';
import { forwardRef } from '@nestjs/common';

@Module({
  imports: [
    TypeOrmModule.forFeature([User], 'indicators'),
    StudyModule,
    forwardRef(() => UserToStudyModule),
  ],
  controllers: [UserController],
  providers: [UserService, JwtService, StudyService],
  exports: [TypeOrmModule, UserService],
})
export class UserModule {}
