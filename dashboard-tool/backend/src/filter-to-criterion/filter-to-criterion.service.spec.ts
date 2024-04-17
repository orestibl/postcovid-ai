import { Test, TestingModule } from '@nestjs/testing';
import { FilterToCriterionService } from './filter-to-criterion.service';

describe('FilterToCriterionService', () => {
  let service: FilterToCriterionService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [FilterToCriterionService],
    }).compile();

    service = module.get<FilterToCriterionService>(FilterToCriterionService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
