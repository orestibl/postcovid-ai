import { Test, TestingModule } from '@nestjs/testing';
import { ConfirmationTokenService } from './confirmation-token.service';

describe('ConfirmationTokenService', () => {
  let service: ConfirmationTokenService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ConfirmationTokenService],
    }).compile();

    service = module.get<ConfirmationTokenService>(ConfirmationTokenService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
