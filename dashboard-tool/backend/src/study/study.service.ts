import { Injectable } from '@nestjs/common';
import { CreateStudyDto } from './dto/create-study.dto';
import { UpdateStudyDto } from './dto/update-study.dto';
import { Repository } from 'typeorm';
import { Study } from './entities/study.entity';
import { InjectRepository } from '@nestjs/typeorm';

@Injectable()
export class StudyService {
  constructor(
    @InjectRepository(Study, 'indicators')
    private studyRepository: Repository<Study>,
  ) {}

  create(createStudyDto: CreateStudyDto) {
    return this.studyRepository.save(createStudyDto);
  }

  findAll() {
    return this.studyRepository.find();
  }

  findOne(id: string) {
    return this.studyRepository.findOneBy({ id });
  }

  update(id: string, updateStudyDto: UpdateStudyDto) {
    return this.studyRepository.upsert({ ...updateStudyDto }, ['id']);
  }

  remove(id: string) {
    return this.studyRepository.delete({ id });
  }

  seed() {
    const studies = [
      {
        id: 'H39eC',
        name: 'Estudio 1',
        description: 'Estudio 1',
      } as Study,
      {
        id: 'aFeH8',
        name: 'Estudio 2',
        description: 'Estudio 2',
      } as Study,
    ];

    try {
      for (const study of studies) {
        this.studyRepository.save(study);
      }
    } catch (err) {
      console.log(err);
    }
    return 'Studies seeded';
  }
}
