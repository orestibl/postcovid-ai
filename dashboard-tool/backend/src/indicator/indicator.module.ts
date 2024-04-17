import { Module, forwardRef } from '@nestjs/common';
import { IndicatorService } from './indicator.service';
import { IndicatorController } from './indicator.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Indicator } from './entities/indicator.entity';
import { JwtService } from '@nestjs/jwt';
import { UserModule } from '../user/user.module';
import { UserService } from '../user/user.service';
import { StudyService } from '../study/study.service';
import { StudyModule } from '../study/study.module';
import { UserToStudyModule } from '../user-to-study/user-to-study.module';
import { ParticipantModule } from 'src/participant/participant.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Indicator], 'indicators'),
    UserModule,
    StudyModule,
    UserToStudyModule,
    forwardRef(() => ParticipantModule),
  ],
  controllers: [IndicatorController],
  providers: [IndicatorService, JwtService, UserService, StudyService],
  exports: [TypeOrmModule, IndicatorService],
})
export class IndicatorModule {}
