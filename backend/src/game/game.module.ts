import { Module } from '@nestjs/common';
import { GameGateWay } from './game.gateway';
import { GameService } from './game.service';
import { MatchesPlayerModule } from 'src/matches_player/matches_player.module';
import { MatchModule } from 'src/match/match.module';
import { UsersModule } from 'src/users/users.module';
import { DatabaseModule } from 'src/database/database.module';

@Module({
  imports: [DatabaseModule, MatchesPlayerModule, MatchModule, UsersModule],
  providers: [GameGateWay, GameService],
  exports: [GameGateWay],
})
export class GameModule {}
