import { Test, TestingModule } from '@nestjs/testing';
import { UserToStudyService } from './user-to-study.service';

describe('UserToStudyService', () => {
  let service: UserToStudyService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [UserToStudyService],
    }).compile();

    service = module.get<UserToStudyService>(UserToStudyService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
