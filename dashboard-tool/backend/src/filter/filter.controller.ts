import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Req,
  Query,
} from '@nestjs/common';
import { FilterService } from './filter.service';
import { CreateFilterDto } from './dto/create-filter.dto';
import { UpdateFilterDto } from './dto/update-filter.dto';
import { StudyService } from '../study/study.service';
import { JwtGuard } from '../auth/guards/jwt.guard';
import { getUserFromHeaders } from '../lib/utils';
import { Request } from 'express';
import { JwtService } from '@nestjs/jwt';
import { UserService } from '../user/user.service';
import { ParticipantService } from 'src/participant/participant.service';

@Controller('filter')
export class FilterController {
  constructor(
    private readonly filterService: FilterService,
    private studyService: StudyService,
    private jwtService: JwtService,
    private userService: UserService,
    private participantService: ParticipantService,
  ) {}

  @UseGuards(JwtGuard)
  @Post()
  async create(
    @Req() request: Request,
    @Body() createFilterDto: CreateFilterDto,
  ) {
    const study = await this.studyService.findOne(createFilterDto.studyId);

    const user = await getUserFromHeaders(
      request,
      this.jwtService,
      this.userService,
    );

    return this.filterService.create(createFilterDto, study, user);
  }

  @UseGuards(JwtGuard)
  @Get()
  async findAll(@Req() request: Request, @Query('study') studyId?: string) {
    const user = await getUserFromHeaders(
      request,
      this.jwtService,
      this.userService,
    );

    const study = await this.studyService.findOne(studyId);

    return this.filterService.findAll(user, study);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.filterService.findOne(+id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateFilterDto: UpdateFilterDto) {
    return this.filterService.update(+id, updateFilterDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.filterService.remove(+id);
  }
}
