import { Module, forwardRef } from '@nestjs/common';
import { UserToStudyService } from './user-to-study.service';
import { UserToStudyController } from './user-to-study.controller';
import { UserToStudy } from './entities/user-to-study.entity';
import { TypeOrmModule } from '@nestjs/typeorm';
import { StudyModule } from '../study/study.module';
import { UserModule } from '../user/user.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([UserToStudy], 'indicators'),
    StudyModule,
    forwardRef(() => UserModule),
  ],
  controllers: [UserToStudyController],
  providers: [UserToStudyService],
  exports: [UserToStudyService, TypeOrmModule],
})
export class UserToStudyModule {}
