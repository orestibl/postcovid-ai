import { Injectable } from '@nestjs/common';
import { CreateFilterDto } from './dto/create-filter.dto';
import { UpdateFilterDto } from './dto/update-filter.dto';
import { Filter } from './entities/filter.entity';
import { Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { Study } from '../study/entities/study.entity';
import { User } from '../user/entities/user.entity';
import { CriterionService } from '../criterion/criterion.service';
import { FilterToCriterionService } from '../filter-to-criterion/filter-to-criterion.service';
import { ParticipantService } from 'src/participant/participant.service';

@Injectable()
export class FilterService {
  constructor(
    @InjectRepository(Filter, 'indicators')
    private filterRepository: Repository<Filter>,
    private criterionService: CriterionService,
    private filterToCriterionService: FilterToCriterionService,
    private participantService: ParticipantService,
  ) {}

  async create(createFilterDto: CreateFilterDto, study: Study, user: User) {
    const filter = await this.filterRepository.save({
      name: createFilterDto.name,
      color: createFilterDto.color,
      study: study,
      user: user,
    });

    for (const item of createFilterDto.criteria) {
      const criterion = await this.criterionService.findOne(item.id);

      this.filterToCriterionService.create({
        criterion: criterion,
        filter: filter,
        lower_value: item.lower_value,
        higher_value: item.higher_value,
        value: item.value,
      });
    }

    return filter;
  }

  findOne(id: number) {
    return this.filterRepository.findOne({
      where: { id },
      relations: {
        study: true,
        filterToCriterion: {
          criterion: true,
        },
      },
    });
  }

  async update(id: number, updateFilterDto: UpdateFilterDto) {
    let filter = await this.filterRepository.findOne({ where: { id } });

    if (!filter) {
      throw new Error(`Filter with ID ${id} not found`);
    }

    for (const item of updateFilterDto.criteria) {
      const criterion = await this.criterionService.findOne(item.id);
      this.filterToCriterionService.create({
        criterion: criterion,
        filter: filter,
        lower_value: item.lower_value,
        higher_value: item.higher_value,
        value: item.value,
      });
    }

    filter = { ...filter, ...updateFilterDto };

    return this.filterRepository.save(filter);
  }

  async remove(id: number) {
    const filter = await this.filterRepository.findOne({
      where: { id },
      relations: ['filterToCriterion'],
    });
    if (!filter) {
      throw new Error(`Filter with ID ${id} not found`);
    }

    await this.filterToCriterionService.removeByFilterId(id);
    return this.filterRepository.remove(filter);
  }

  async findAll(user: User, study: Study) {
    const filters = await this.filterRepository.find({
      where: { user, study },
      relations: {
        filterToCriterion: {
          criterion: true,
        },
      },
    });

    const filterAll = {
      id: 0,
      name: 'All',
      color: '#009688',
      filterToCriterion: [],
    } as Filter;

    const f = [...filters, filterAll];

    const res = [];

    f.map((filter) => {
      res.push(
        this.participantService.getCountParticipantsByFilters(
          filter.filterToCriterion,
          study.id,
        ),
      );
    });

    const participants = await Promise.all(res);

    console.log('participants', participants);

    return f.map((filter, index) => {
      return {
        ...filter,
        number_participants: participants[index],
      };
    });
  }
}
