import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { UserService } from '../user/user.service';
import { UserModule } from '../user/user.module';
import { JwtModule, JwtService } from '@nestjs/jwt';
import { MailModule } from '../mail/mail.module';
import { StudyModule } from '../study/study.module';
import { UserToStudyModule } from '../user-to-study/user-to-study.module';

@Module({
  imports: [
    UserModule,
    MailModule,
    StudyModule,
    UserToStudyModule,
    JwtModule.register({
      secret:
        'otLegjKKk0xxNumOeAomfTBfMJ8r2HMFfszcdDVtCzUiAwCfiyvLFS8kgwzkYjszKh2qxImrTqrxZKsf0GNg', // replace with your secret key
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, UserService, JwtService],
})
export class AuthModule {}
