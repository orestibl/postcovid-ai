import { Test, TestingModule } from '@nestjs/testing';
import { CriterionController } from './criterion.controller';
import { CriterionService } from './criterion.service';

describe('CriterionController', () => {
  let controller: CriterionController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [CriterionController],
      providers: [CriterionService],
    }).compile();

    controller = module.get<CriterionController>(CriterionController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
