import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigModule } from '@nestjs/config';
import { TestdbModule } from './testdb/testdb.module';
import { UsersModule } from './users/users.module';
import { B2Module } from './b2/b2.module';
import { MatchesPlayerModule } from './matches_player/matches_player.module';
import { GameModule } from './game/game.module';
import { EmailModule } from './login/email/email.module';
import { MatchModule } from './match/match.module';
import { GmailModule } from './login/gmail/gmail.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    TestdbModule,
    UsersModule,
    B2Module,
    GameModule,
    MatchesPlayerModule,
    EmailModule,
    MatchModule,
    GmailModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }
