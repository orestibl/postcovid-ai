import { Module } from '@nestjs/common';
import { CriterionService } from './criterion.service';
import { CriterionController } from './criterion.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Criterion } from './entities/criterion.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Criterion], 'indicators')],
  controllers: [CriterionController],
  providers: [CriterionService],
  exports: [CriterionService, TypeOrmModule],
})
export class CriterionModule {}
