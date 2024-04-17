import { Module, forwardRef } from '@nestjs/common';
import { FilterService } from './filter.service';
import { FilterController } from './filter.controller';
import { Filter } from './entities/filter.entity';
import { TypeOrmModule } from '@nestjs/typeorm';
import { StudyModule } from '../study/study.module';
import { StudyService } from '../study/study.service';
import { JwtService } from '@nestjs/jwt';
import { UserService } from '../user/user.service';
import { UserModule } from '../user/user.module';
import { CriterionModule } from '../criterion/criterion.module';
import { CriterionService } from '../criterion/criterion.service';
import { FilterToCriterionModule } from '../filter-to-criterion/filter-to-criterion.module';
import { UserToStudyModule } from '../user-to-study/user-to-study.module';
import { ParticipantModule } from 'src/participant/participant.module';
import { IndicatorModule } from 'src/indicator/indicator.module';
import { FilterToCriterionService } from 'src/filter-to-criterion/filter-to-criterion.service';
import { ParticipantService } from 'src/participant/participant.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([Filter], 'indicators'),
    StudyModule,
    UserModule,
    CriterionModule,
    FilterToCriterionModule,
    UserToStudyModule,
    forwardRef(() => ParticipantModule),
  ],

  controllers: [FilterController],
  providers: [FilterService, ParticipantService, JwtService],
  exports: [TypeOrmModule, FilterService],
})
export class FilterModule {}
