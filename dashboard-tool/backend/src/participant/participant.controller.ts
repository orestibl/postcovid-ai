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
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { ParticipantService } from './participant.service';
import { CreateParticipantDto } from './dto/create-participant.dto';
import { UpdateParticipantDto } from './dto/update-participant.dto';
import { FilterService } from 'src/filter/filter.service';

@Controller('participant')
export class ParticipantController {
  constructor(
    private readonly participantService: ParticipantService,
    private filterService: FilterService,
  ) {}

  @Post()
  create(@Body() createParticipantDto: CreateParticipantDto) {
    return this.participantService.create(createParticipantDto);
  }

  @Get()
  findAll() {
    return this.participantService.findAll();
  }

  @Get('areas')
  getAreas(@Req() request: Request, @Query('study') studyId?: string) {
    if (!studyId)
      throw new HttpException('Study not found', HttpStatus.NOT_FOUND);
    return this.participantService.getAreas(studyId);
  }

  @Get('income')
  getIncome(@Req() request: Request, @Query('study') studyId?: string) {
    if (!studyId)
      throw new HttpException('Study not found', HttpStatus.NOT_FOUND);
    return this.participantService.getIncomeRange(studyId);
  }

  @Get('info/:filterId')
  async getParticipants(@Param('filterId') filterId: number) {
    const filter = await this.filterService.findOne(filterId);
    return this.participantService.getNumberOfParticipantsByFilter(filter);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.participantService.findOne(id);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() updateParticipantDto: UpdateParticipantDto,
  ) {
    return this.participantService.update(+id, updateParticipantDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.participantService.remove(+id);
  }
}
