import { Test, TestingModule } from '@nestjs/testing';
import { ConfirmationTokenController } from './confirmation-token.controller';
import { ConfirmationTokenService } from './confirmation-token.service';

describe('ConfirmationTokenController', () => {
  let controller: ConfirmationTokenController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ConfirmationTokenController],
      providers: [ConfirmationTokenService],
    }).compile();

    controller = module.get<ConfirmationTokenController>(ConfirmationTokenController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
