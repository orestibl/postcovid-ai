import { Test, TestingModule } from '@nestjs/testing';
import { IndicatorNameController } from './indicator-name.controller';
import { IndicatorNameService } from './indicator-name.service';

describe('IndicatorNameController', () => {
  let controller: IndicatorNameController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [IndicatorNameController],
      providers: [IndicatorNameService],
    }).compile();

    controller = module.get<IndicatorNameController>(IndicatorNameController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
