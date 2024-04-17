import { Module } from '@nestjs/common';
import { IndicatorNameService } from './indicator-name.service';
import { IndicatorNameController } from './indicator-name.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { IndicatorName } from './entities/indicator-name.entity';

@Module({
  imports: [TypeOrmModule.forFeature([IndicatorName], 'indicators')],
  controllers: [IndicatorNameController],
  providers: [IndicatorNameService],
  exports: [TypeOrmModule, IndicatorNameService],
})
export class IndicatorNameModule {}
