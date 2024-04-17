import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  Req,
  UseGuards,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { IndicatorService } from './indicator.service';
import { CreateIndicatorDto } from './dto/create-indicator.dto';
import { UpdateIndicatorDto } from './dto/update-indicator.dto';
import { Request } from 'express';
import { JwtService } from '@nestjs/jwt';
import { IndicatorQuery } from '../types/types';
import { UserService } from '../user/user.service';
import { JwtGuard } from '../auth/guards/jwt.guard';
import { getUserFromHeaders } from '../lib/utils';
import { StudyService } from '../study/study.service';
import { Filter } from 'src/filter/entities/filter.entity';

@Controller('indicator')
export class IndicatorController {
  constructor(
    private readonly indicatorService: IndicatorService,
    private jwtService: JwtService,
    private userService: UserService,
    private studyService: StudyService,
  ) {}

  @Post()
  create(@Body() createIndicatorDto: CreateIndicatorDto) {
    return this.indicatorService.create(createIndicatorDto);
  }

  @UseGuards(JwtGuard)
  @Get()
  async findAll(@Req() request: Request, @Query('study') studyId?: string) {
    const user = await getUserFromHeaders(
      request,
      this.jwtService,
      this.userService,
    );

    if (!user) throw new HttpException('User not found', HttpStatus.NOT_FOUND);

    const study = await this.studyService.findOne(studyId);

    if (!study)
      throw new HttpException('Study not found', HttpStatus.NOT_FOUND);

    const filterAll = {
      id: 0,
      name: 'All',
      color: '#009688',
      filterToCriterion: [],
    } as Filter;

    const query: IndicatorQuery = {
      filters: [...user.filters, filterAll],
      study: study,
    };

    return this.indicatorService.findAll(query);
  }

  @Get('seed')
  seed() {
    return this.indicatorService.seed();
  }
  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.indicatorService.findOne(+id);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() updateIndicatorDto: UpdateIndicatorDto,
  ) {
    return this.indicatorService.update(+id, updateIndicatorDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.indicatorService.remove(+id);
  }
}
