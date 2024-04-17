import { Body, Controller, Param, Post, UseGuards } from '@nestjs/common';
import { JwtGuard } from '../auth/guards/jwt.guard';
import { MailService } from './mail.service';
import { EmailDto } from './dto/email.dto';

@Controller('mail')
export class MailController {
  constructor(private readonly mailService: MailService) {}

  @UseGuards(JwtGuard)
  @Post()
  public async sendConfirmationMail(@Body() email: EmailDto) {
    return this.mailService.sendUserConfirmation(email);
  }
}
