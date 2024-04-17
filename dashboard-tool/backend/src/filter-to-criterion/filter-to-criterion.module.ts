import { Module } from '@nestjs/common';
import { FilterToCriterionService } from './filter-to-criterion.service';
import { FilterToCriterionController } from './filter-to-criterion.controller';
import { FilterToCriterion } from './entities/filter-to-criterion.entity';
import { TypeOrmModule } from '@nestjs/typeorm';


@Module({
  imports: [TypeOrmModule.forFeature([FilterToCriterion], 'indicators')],
  controllers: [FilterToCriterionController],
  providers: [FilterToCriterionService],
  exports: [FilterToCriterionService, TypeOrmModule]
})
export class FilterToCriterionModule {}
