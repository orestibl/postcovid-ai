import { Test, TestingModule } from '@nestjs/testing';
import { CriterionService } from './criterion.service';

describe('CriterionService', () => {
  let service: CriterionService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [CriterionService],
    }).compile();

    service = module.get<CriterionService>(CriterionService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
