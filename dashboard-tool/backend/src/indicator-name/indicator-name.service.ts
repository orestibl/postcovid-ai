import { Injectable } from '@nestjs/common';
import { CreateIndicatorNameDto } from './dto/create-indicator-name.dto';
import { UpdateIndicatorNameDto } from './dto/update-indicator-name.dto';
import { Repository } from 'typeorm';
import {IndicatorName} from './entities/indicator-name.entity';
import { InjectRepository } from '@nestjs/typeorm';

@Injectable()
export class IndicatorNameService {

  constructor(
    @InjectRepository(IndicatorName, 'indicators')
    private indicatorNameRepository: Repository<IndicatorName>,
  ) {}

  create(createIndicatorNameDto: CreateIndicatorNameDto) {
    return this.indicatorNameRepository.save(createIndicatorNameDto);
  }

  findAll() {
    return this.indicatorNameRepository.find();
  }

  findOne(id: number) {
    return `This action returns a #${id} indicatorName`;
  }

  update(id: number, updateIndicatorNameDto: UpdateIndicatorNameDto) {
    return `This action updates a #${id} indicatorName`;
  }

  remove(id: number) {
    return `This action removes a #${id} indicatorName`;
  }

  seed() {
    const indicatorNames = [
      { name: 'social_interaction'} as IndicatorName,
      { name: 'physical_activity'} as IndicatorName,
      { name: 'emmotional_state'} as IndicatorName,
      { name: 'overall_wellbeing'} as IndicatorName,
    ]
    try {
      for (const indicatorName of indicatorNames) {
        this.indicatorNameRepository.save(indicatorName);
      }
    }catch (err) {
      console.log(err);
    }
    return 'seeded';
  }

}
