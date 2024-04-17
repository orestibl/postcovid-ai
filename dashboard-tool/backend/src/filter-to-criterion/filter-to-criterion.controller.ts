import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { FilterToCriterionService } from './filter-to-criterion.service';
import { CreateFilterToCriterionDto } from './dto/create-filter-to-criterion.dto';
import { UpdateFilterToCriterionDto } from './dto/update-filter-to-criterion.dto';

@Controller('filter-to-criterion')
export class FilterToCriterionController {
  constructor(private readonly filterToCriterionService: FilterToCriterionService) {}

  @Post()
  create(@Body() createFilterToCriterionDto: CreateFilterToCriterionDto) {
    return this.filterToCriterionService.create(createFilterToCriterionDto);
  }

  @Get()
  findAll() {
    return this.filterToCriterionService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.filterToCriterionService.findOne(+id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateFilterToCriterionDto: UpdateFilterToCriterionDto) {
    return this.filterToCriterionService.update(+id, updateFilterToCriterionDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.filterToCriterionService.remove(+id);
  }
}
