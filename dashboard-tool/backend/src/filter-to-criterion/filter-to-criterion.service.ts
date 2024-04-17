import { Injectable } from '@nestjs/common';
import { CreateFilterToCriterionDto } from './dto/create-filter-to-criterion.dto';
import { UpdateFilterToCriterionDto } from './dto/update-filter-to-criterion.dto';
import { FilterToCriterion } from './entities/filter-to-criterion.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

@Injectable()
export class FilterToCriterionService {
  constructor(
    @InjectRepository(FilterToCriterion, 'indicators')
    private filterToCriterionRepository: Repository<FilterToCriterion>,
  ) {}

  create(createFilterToCriterionDto: CreateFilterToCriterionDto) {
    return this.filterToCriterionRepository.save(createFilterToCriterionDto);
  }

  findAll() {
    return this.filterToCriterionRepository.find();
  }

  findOne(id: number) {
    return this.filterToCriterionRepository.findOne({ where: { id } });
  }

  update(id: number, updateFilterToCriterionDto: UpdateFilterToCriterionDto) {
    return this.filterToCriterionRepository.update(
      id,
      updateFilterToCriterionDto,
    );
  }

  remove(id: number) {
    return this.filterToCriterionRepository.delete(id);
  }

  removeByFilterId(filterId: number) {
    return this.filterToCriterionRepository.delete({
      filter: { id: filterId },
    });
  }
}
