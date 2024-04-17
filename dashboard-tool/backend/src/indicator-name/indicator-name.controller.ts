import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { IndicatorNameService } from './indicator-name.service';
import { CreateIndicatorNameDto } from './dto/create-indicator-name.dto';
import { UpdateIndicatorNameDto } from './dto/update-indicator-name.dto';


@Controller('indicator-name')
export class IndicatorNameController {
  constructor(private readonly indicatorNameService: IndicatorNameService) {}

  @Post()
  create(@Body() createIndicatorNameDto: CreateIndicatorNameDto) {
    return this.indicatorNameService.create(createIndicatorNameDto);
  }

  @Get()
  findAll() {
    return this.indicatorNameService.findAll();
  }

  @Get('seed')
  seed() {
    return this.indicatorNameService.seed();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.indicatorNameService.findOne(+id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateIndicatorNameDto: UpdateIndicatorNameDto) {
    return this.indicatorNameService.update(+id, updateIndicatorNameDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.indicatorNameService.remove(+id);
  }
}
