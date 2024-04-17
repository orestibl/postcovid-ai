// import { Test, TestingModule } from '@nestjs/testing';
// import { UserController } from './user.controller';
// import { UserService } from './user.service';
// import { CreateUserDto } from './dto/create-user.dto';
// import { UpdateUserDto } from './dto/update-user.dto';

// describe('UserController', () => {
//   let userController: UserController;
//   let userService: UserService;
//   let mockUserService: jest.Mocked<UserService>;

//   beforeEach(async () => {
//     const module: TestingModule = await Test.createTestingModule({
//       controllers: [UserController],
//       providers: [
//         {
//           provide: UserService,
//           useValue: {
//             create: jest.fn(),
//             findAll: jest.fn(),
//             findOne: jest.fn(),
//             update: jest.fn(),
//             remove: jest.fn(),
//           },
//         },
//       ],
//     }).compile();

//     userController = module.get<UserController>(UserController);
//     userService = module.get<UserService>(UserService);
//   });

//   // Reset mocks before each test
// beforeEach(() => {
//   mockUserService.create.mockReset();
//   mockUserService.findAll.mockReset();
//   mockUserService.findOne.mockReset();
//   mockUserService.update.mockReset();
//   mockUserService.remove.mockReset();
// });

//   it('should be defined', () => {
//     expect(userController).toBeDefined();
//   });

//   // ...
// describe('create', () => {
//   it('should create a user', async () => {
//     const createUserDto = new CreateUserDto();
//     mockUserService.create.mockResolvedValue(createUserDto);
//     expect(await userController.create(createUserDto)).toBe(createUserDto);
//   });
// });
// // ...

//   describe('findAll', () => {
//     it('should return an array of users', async () => {
//       const result = [];
//       mockUserService.findAll.mockResolvedValue(result);
//       expect(await userController.findAll()).toBe(result);
//     });
//   });

//   describe('findOne', () => {
//     it('should retrieve a single user by id', async () => {
//       const userId = '1';
//       const result = {};
//       mockUserService.findOne.mockResolvedValue(result);
//       expect(await userController.findOne(userId)).toBe(result);
//     });
//   });

//   describe('update', () => {
//     it('should update a user', async () => {
//       const userId = '1';
//       const updateUserDto = new UpdateUserDto();
//       mockUserService.update.mockResolvedValue(updateUserDto);
//       expect(await userController.update(userId, updateUserDto)).toBe(updateUserDto);
//     });
//   });

//   describe('remove', () => {
//     it('should delete a user', async () => {
//       const userId = 1;
//       mockUserService.remove.mockResolvedValue(userId);
//       expect(await userController.remove(userId)).toBe(userId);
//     });
//   });
// });