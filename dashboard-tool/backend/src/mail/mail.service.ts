import { MailerService } from '@nestjs-modules/mailer';
import { Injectable } from '@nestjs/common';
import { EmailDto } from './dto/email.dto';
import { ConfirmationTokenService } from '../confirmation-token/confirmation-token.service';
import * as path from 'path';

@Injectable()
export class MailService {
  constructor(
    private mailerService: MailerService,
    private confirmationTokenService: ConfirmationTokenService,
  ) {}

  async sendUserConfirmation(email: EmailDto) {
    const randomBytes = require('crypto').randomBytes;
    const token = randomBytes(24).toString('hex');

    this.confirmationTokenService.create({
      token: token,
      email: email.email,
    });

    // const url = `https://projects.ugr.es/postcovid-dashboard/confirm/${token}`;
    const url = `http://localhost:3000/postcovid-dashboard/confirm/${token}`;

    const templatePath = path.join(__dirname, './templates/confirmation');

    console.log('__dirname', __dirname);

    try {
      await this.mailerService.sendMail({
        to: email.email,
        // from: '"Support Team" <support@example.com>', // override default from
        subject: 'Welcome to Postcovid-AI! Confirm your Email',
        template: templatePath, // `.hbs` extension is appended automatically
        context: {
          // ✏️ filling curly brackets with content
          name: email.name,
          url,
        },
      });
    } catch (error) {
      console.error('Error sending confirmation email to', email.email, error);
      return new Error('Error sending confirmation email');
    }
  }
}
