import { Test, TestingModule } from '@nestjs/testing';
import { UserToStudyController } from './user-to-study.controller';
import { UserToStudyService } from './user-to-study.service';

describe('UserToStudyController', () => {
  let controller: UserToStudyController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [UserToStudyController],
      providers: [UserToStudyService],
    }).compile();

    controller = module.get<UserToStudyController>(UserToStudyController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
