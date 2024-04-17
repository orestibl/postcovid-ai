import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { UserToStudyService } from './user-to-study.service';
import { CreateUserToStudyDto } from './dto/create-user-to-study.dto';
import { UpdateUserToStudyDto } from './dto/update-user-to-study.dto';

@Controller('user-to-study')
export class UserToStudyController {
  constructor(private readonly userToStudyService: UserToStudyService) {}

  @Post()
  create(@Body() createUserToStudyDto: CreateUserToStudyDto) {
    return this.userToStudyService.create(createUserToStudyDto);
  }

  @Get()
  findAll() {
    return this.userToStudyService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.userToStudyService.findOne(+id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateUserToStudyDto: UpdateUserToStudyDto) {
    return this.userToStudyService.update(+id, updateUserToStudyDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.userToStudyService.remove(+id);
  }
}
