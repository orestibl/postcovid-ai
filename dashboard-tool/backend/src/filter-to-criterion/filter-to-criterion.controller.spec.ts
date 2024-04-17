import { Test, TestingModule } from '@nestjs/testing';
import { FilterToCriterionController } from './filter-to-criterion.controller';
import { FilterToCriterionService } from './filter-to-criterion.service';

describe('FilterToCriterionController', () => {
  let controller: FilterToCriterionController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [FilterToCriterionController],
      providers: [FilterToCriterionService],
    }).compile();

    controller = module.get<FilterToCriterionController>(FilterToCriterionController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
