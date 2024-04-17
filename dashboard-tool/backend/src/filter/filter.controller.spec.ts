import { Test, TestingModule } from '@nestjs/testing';
import { FilterController } from './filter.controller';
import { FilterService } from './filter.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Filter } from './entities/filter.entity';
import { CriterionService } from '../criterion/criterion.service';
import { FilterToCriterionService } from '../filter-to-criterion/filter-to-criterion.service';
import { JwtService } from '@nestjs/jwt';
import { StudyService } from '../study/study.service';
import { UserService } from '../user/user.service';
import { User } from '../user/entities/user.entity';

describe('FilterController', () => {
  let controller: FilterController;

  // Mock repository and services
  const mockRepository = {};
  const mockCriterionService = {};
  const mockFilterToCriterionService = {};
  const mockJwtService = {};
  const studyService = {};
  const userService = {};
  const filterService = {
    findAll: jest.fn().mockResolvedValue([]), // Add a mock implementation of findAll
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [FilterController],
      providers: [
        FilterService,
        {
          provide: getRepositoryToken(Filter, 'indicators'), // Use the correct token and connection name
          useValue: mockRepository,
        },
        {
          provide: CriterionService,
          useValue: mockCriterionService,
        },
        {
          provide: FilterToCriterionService,
          useValue: mockFilterToCriterionService,
        },
        {
          provide: JwtService,
          useValue: mockJwtService,
        },
        {
          provide: StudyService,
          useValue: studyService,
        },
        {
          provide: UserService,
          useValue: userService,
        },
        {
          provide: FilterService,
          useValue: filterService,
        },
      ],
    }).compile();

    controller = module.get<FilterController>(FilterController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('findAll', () => {
    it('should return an array of filters', async () => {
      const result = [
        // Example filters
        {
          id: 1,
          name: 'Filter 1',
          description: 'First example filter',
          filterToCriterion: [],
        },
        {
          id: 2,
          name: 'Filter 2',
          description: 'Second example filter',
          filterToCriterion: [],
        },
      ];
      jest
        .spyOn(filterService, 'findAll')
        .mockImplementation(async () => result);
      // const user: User = { id: 1, email: '', password: '', role: '' };

      expect(await controller.findAll(null)).toBe([]);
    });
  });

  // ... other tests
});
