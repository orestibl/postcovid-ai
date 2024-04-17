import { Test, TestingModule } from '@nestjs/testing';
import { StudyController } from './study.controller';
import { StudyService } from './study.service';

describe('StudyController', () => {
  let controller: StudyController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [StudyController],
      providers: [StudyService],
    }).compile();

    controller = module.get<StudyController>(StudyController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
