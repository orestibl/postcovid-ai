import { Injectable } from '@nestjs/common';
import { CreateCriterionDto } from './dto/create-criterion.dto';
import { UpdateCriterionDto } from './dto/update-criterion.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Criterion } from './entities/criterion.entity';
import { CriterionType } from '../lib/utils';

@Injectable()
export class CriterionService {
  constructor(
    @InjectRepository(Criterion, 'indicators')
    private criterionRepository: Repository<Criterion>,
  ) {}

  create(createCriterionDto: CreateCriterionDto) {
    return this.criterionRepository.save(createCriterionDto);
  }

  findAll() {
    return this.criterionRepository.find();
  }

  findOne(id: number) {
    return this.criterionRepository.findOne({ where: { id } });
  }

  update(id: number, updateCriterionDto: UpdateCriterionDto) {
    return `This action updates a #${id} criterion`;
  }

  remove(id: number) {
    return `This action removes a #${id} criterion`;
  }

  async seed() {
    const criteria = [
      { name: 'gender', nature: CriterionType.VALUE } as Criterion,
      { name: 'income', nature: CriterionType.VALUE } as Criterion,
      { name: 'zip_code', nature: CriterionType.VALUE } as Criterion,
      { name: 'age', nature: CriterionType.RANGE } as Criterion,
    ];
    try {
      for (const criterion of criteria) {
        await this.criterionRepository.save(criterion);
      }
      return 'seeded';
    } catch (err) {
      return 'failed';
    }
  }
}
