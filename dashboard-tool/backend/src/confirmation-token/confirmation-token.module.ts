import { Module } from '@nestjs/common';
import { ConfirmationTokenService } from './confirmation-token.service';
import { ConfirmationTokenController } from './confirmation-token.controller';
import { ConfirmationToken } from './entities/confirmation-token.entity';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserService } from '../user/user.service';
import { UserModule } from '../user/user.module';
import { StudyModule } from '../study/study.module';
import { CriterionModule } from '../criterion/criterion.module';
import { FilterToCriterionModule } from '../filter-to-criterion/filter-to-criterion.module';
import { UserToStudyModule } from '../user-to-study/user-to-study.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([ConfirmationToken], 'indicators'),
    StudyModule,
    UserModule,
    CriterionModule,
    FilterToCriterionModule,
    UserToStudyModule,
  ],
  controllers: [ConfirmationTokenController],
  providers: [ConfirmationTokenService, UserService],
  exports: [ConfirmationTokenService],
})
export class ConfirmationTokenModule {}
