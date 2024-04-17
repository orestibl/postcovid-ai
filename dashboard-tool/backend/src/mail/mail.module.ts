import { MailerModule } from '@nestjs-modules/mailer';
import { HandlebarsAdapter } from '@nestjs-modules/mailer/dist/adapters/handlebars.adapter';
import { Module } from '@nestjs/common';
import { MailService } from './mail.service';
import { join } from 'path';
import { MailController } from './mail.controller';
import { JwtService } from '@nestjs/jwt';
import { ConfirmationTokenModule } from '../confirmation-token/confirmation-token.module';
require('dotenv').config();

@Module({
  imports: [
    MailerModule.forRoot({
      transport: {
        host: 'smtp.sendgrid.net',
        secure: true,
        port: 465,
        auth: {
          user: 'apikey',
          pass: process.env.SENDGRID_API_KEY_PASSWORD,
        },
      },
      defaults: {
        from: 'postcovid.ai@gmail.com',
      },
      template: {
        dir: join(__dirname, '../src/mail', 'templates'),
        adapter: new HandlebarsAdapter(),
        options: {
          strict: true,
        },
      },
    }),
    ConfirmationTokenModule,
  ],
  providers: [MailService, JwtService],
  controllers: [MailController],
  exports: [MailService], // 👈 export for DI
})
export class MailModule {}
