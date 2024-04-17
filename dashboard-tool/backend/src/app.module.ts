import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ParticipantModule } from './participant/participant.module';
import { TypeOrmModule } from '@nestjs/typeorm';
import { IndicatorModule } from './indicator/indicator.module';
import { StudyModule } from './study/study.module';
import { IndicatorNameModule } from './indicator-name/indicator-name.module';
import { UserModule } from './user/user.module';
import { FilterModule } from './filter/filter.module';
import { CriterionModule } from './criterion/criterion.module';
import { UserPreferencesModule } from './user_preferences/user_preferences.module';
import { UserToStudyModule } from './user-to-study/user-to-study.module';
import { FilterToCriterionModule } from './filter-to-criterion/filter-to-criterion.module';
import { AuthModule } from './auth/auth.module';
import { MailModule } from './mail/mail.module';
import { ConfirmationTokenModule } from './confirmation-token/confirmation-token.module';
import { dataSource } from './datasource';
require('dotenv').config();

const { subscribers, migrations, ...typeormCompatibleOptions } = dataSource;

const indicators_database = TypeOrmModule.forRoot({
  ...typeormCompatibleOptions.options,
  autoLoadEntities: true,
});

@Module({
  imports: [
    indicators_database,
    ParticipantModule,
    IndicatorModule,
    StudyModule,
    IndicatorNameModule,
    UserModule,
    FilterModule,
    CriterionModule,
    UserPreferencesModule,
    UserToStudyModule,
    FilterToCriterionModule,
    AuthModule,
    MailModule,
    ConfirmationTokenModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
