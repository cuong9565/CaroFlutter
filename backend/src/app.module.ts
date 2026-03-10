import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigModule } from '@nestjs/config';
import { TestdbModule } from './testdb/testdb.module';
import { UsersModule } from './users/users.module';
import { B2Module } from './b2/b2.module';
import { MatchesPlayerModule } from './matches_player/matches_player.module';
import { GameModule } from './game/game.module';
<<<<<<< HEAD
import { EmailModule } from './login/email/email.module';
=======
import { MatchModule } from './match/match.module';
>>>>>>> 8bb4c0dc234d87d605ff3dff8909888970b345cd

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
<<<<<<< HEAD
    EmailModule,
=======
    MatchModule,
>>>>>>> 8bb4c0dc234d87d605ff3dff8909888970b345cd
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }
