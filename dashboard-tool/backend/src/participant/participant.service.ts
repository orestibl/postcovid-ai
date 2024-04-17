import { Injectable } from '@nestjs/common';
import { CreateParticipantDto } from './dto/create-participant.dto';
import { UpdateParticipantDto } from './dto/update-participant.dto';
import { Between, Repository } from 'typeorm';
import { Participant } from './entities/participant.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { fakerES as faker } from '@faker-js/faker';
import { FilterToCriterionService } from 'src/filter-to-criterion/filter-to-criterion.service';
import { CriterionService } from 'src/criterion/criterion.service';
import { FilterService } from 'src/filter/filter.service';
import { Criterion } from 'src/criterion/entities/criterion.entity';
import { FilterToCriterion } from 'src/filter-to-criterion/entities/filter-to-criterion.entity';
import { StudyService } from 'src/study/study.service';
import { Filter } from 'src/filter/entities/filter.entity';

@Injectable()
export class ParticipantService {
  constructor(
    @InjectRepository(Participant, 'indicators')
    private participantRepository: Repository<Participant>, // ,
    // private studyService: StudyService,
  ) {}

  create(createParticipantDto: CreateParticipantDto) {
    const participant = this.participantRepository.create(createParticipantDto);
    return this.participantRepository.save(participant);
  }

  findAll() {
    return this.participantRepository.find();
  }

  findOne(id: string) {
    return this.participantRepository.findOne({ where: { id } });
  }

  async getNumberOfParticipantsByFilter(filter: Filter) {
    if (!filter) return null;

    const participants = await this.getCountParticipantsByFilters(
      filter.filterToCriterion,
      filter.study.id,
    );

    return participants;

    // return { participants: participants, length: participants.length };
  }

  async findParticipantsByFilters(
    criteria: FilterToCriterion[],
    studyId?: string,
  ) {
    const params = this.getParams(criteria);

    return this.participantRepository.find({
      where: { ...params, study: { id: studyId } },
    });
  }

  async getCountParticipantsByFilters(
    criteria: FilterToCriterion[],
    studyId: string,
  ) {
    const params = this.getParams(criteria);

    return this.participantRepository.count({
      where: { ...params, study: { id: studyId } },
    });
  }

  getParams(criteria: FilterToCriterion[]) {
    const params = {};

    if (!criteria || criteria.length == 0) return params;

    criteria.forEach((criterion) => {
      console.log('criterion', criterion);

      const {
        criterion: { name },
        value,
        lower_value,
        higher_value,
      } = criterion;
      if (name === 'zip_code') {
        params['zip_code'] = value;
      }
      if (name === 'income') {
        params['income'] = value;
      }
      if (name === 'gender') {
        params['gender'] = value;
      }
      if (name === 'age') {
        const currentDate = new Date();
        const currentYear = currentDate.getFullYear();
        const start_birth_year = currentYear - higher_value;
        const end_birth_year = currentYear - lower_value;
        const start_birth_date = new Date(
          currentDate.setFullYear(start_birth_year),
        );
        const end_birth_date = new Date(
          currentDate.setFullYear(end_birth_year),
        );
        params['birth_date'] = Between(start_birth_date, end_birth_date);
      }
    });

    return params;
  }

  update(id: number, updateParticipantDto: UpdateParticipantDto) {
    return `This action updates a #${id} participant`;
  }

  remove(id: number) {
    return `This action removes a #${id} participant`;
  }

  getAreas(studyId?: string) {
    return this.participantRepository.query(
      `SELECT DISTINCT zip_code FROM participant where participant."studyId" = '${studyId}' ORDER BY zip_code ASC`,
    );
  }

  getIncomeRange(studyId?: string) {
    return this.participantRepository.query(
      `SELECT DISTINCT income FROM participant where participant."studyId" = '${studyId}' ORDER BY income ASC`,
    );
  }
}
