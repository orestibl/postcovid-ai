import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
} from '@nestjs/common';
import { ConfirmationTokenService } from './confirmation-token.service';
import { CreateConfirmationTokenDto } from './dto/create-confirmation-token.dto';
import { UpdateConfirmationTokenDto } from './dto/update-confirmation-token.dto';
import { Res } from '@nestjs/common';
import { UserService } from '../user/user.service';

@Controller('confirmation-token')
export class ConfirmationTokenController {
  constructor(
    private readonly confirmationTokenService: ConfirmationTokenService,
    private userService: UserService,
  ) {}

  @Post()
  create(@Body() createConfirmationTokenDto: CreateConfirmationTokenDto) {
    return this.confirmationTokenService.create(createConfirmationTokenDto);
  }

  @Get()
  findAll() {
    return this.confirmationTokenService.findAll();
  }

  @Get('/confirm/:token')
  async findOne(@Param('token') token: string, @Res() res) {
    const t = await this.confirmationTokenService.findOne(token);
    if (!t) return res.status(404).json({ message: 'Not found' });

    await this.confirmationTokenService.remove(t.id);

    await this.userService.enableByEmail(t.email);

    return res.json(t);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() updateConfirmationTokenDto: UpdateConfirmationTokenDto,
  ) {
    return this.confirmationTokenService.update(
      +id,
      updateConfirmationTokenDto,
    );
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.confirmationTokenService.remove(+id);
  }
}
