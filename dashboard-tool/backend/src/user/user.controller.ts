import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
} from '@nestjs/common';
import { UserService } from './user.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { JwtGuard } from '../auth/guards/jwt.guard';
import { UpdateUserStudyDto } from './dto/update-user-study.dto';

@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @UseGuards(JwtGuard)
  @Get(':id')
  async getProfile(@Param('id') id: number) {
    return this.userService.findById(+id);
  }
  @UseGuards(JwtGuard)
  @Get('study/:id')
  async getUsersByStudy(@Param('id') id: string) {
    return this.userService.findUsersByStudy(id);
  }

  @UseGuards(JwtGuard)
  @Patch(':id')
  async update(@Param('id') id: string, @Body() updateUserDto: UpdateUserDto) {
    return this.userService.update(+id, updateUserDto);
  }

  @UseGuards(JwtGuard)
  @Patch('updateStudyRole/:id')
  async updateStudyRole(
    @Param('id') id: string,
    @Body() updateUserStudyDto: UpdateUserStudyDto,
  ) {
    return this.userService.updateRoleStudy(+id, updateUserStudyDto);
  }
}
