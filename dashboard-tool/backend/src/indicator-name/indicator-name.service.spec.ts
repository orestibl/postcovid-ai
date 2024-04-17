import { Test, TestingModule } from '@nestjs/testing';
import { IndicatorNameService } from './indicator-name.service';

describe('IndicatorNameService', () => {
  let service: IndicatorNameService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [IndicatorNameService],
    }).compile();

    service = module.get<IndicatorNameService>(IndicatorNameService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
