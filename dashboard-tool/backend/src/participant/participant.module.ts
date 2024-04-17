import { Module, forwardRef } from '@nestjs/common';
import { ParticipantService } from './participant.service';
import { ParticipantController } from './participant.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Participant } from './entities/participant.entity';
import { FilterModule } from 'src/filter/filter.module';
import { FilterToCriterionModule } from 'src/filter-to-criterion/filter-to-criterion.module';
import { CriterionModule } from 'src/criterion/criterion.module';
import { UserToStudyModule } from 'src/user-to-study/user-to-study.module';
import { StudyModule } from 'src/study/study.module';
import { UserModule } from 'src/user/user.module';
import { IndicatorModule } from 'src/indicator/indicator.module';
import { CriterionService } from 'src/criterion/criterion.service';
import { FilterToCriterionService } from 'src/filter-to-criterion/filter-to-criterion.service';
import { FilterService } from 'src/filter/filter.service';
import { IndicatorService } from 'src/indicator/indicator.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([Participant], 'indicators'),
    CriterionModule,
    FilterToCriterionModule,
    forwardRef(() => IndicatorModule),
    forwardRef(() => FilterModule),
  ],
  controllers: [ParticipantController],
  providers: [
    ParticipantService,
    FilterService,
    IndicatorService,
    CriterionService,
    FilterToCriterionService,
  ],
  exports: [TypeOrmModule, ParticipantService],
})
export class ParticipantModule {}
