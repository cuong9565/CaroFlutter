import { Module } from '@nestjs/common';
import { GameGateWay } from './game.gateway';
import { GameService } from './game.service';
import { MatchesPlayerModule } from 'src/matches_player/matches_player.module';

@Module({
  imports: [MatchesPlayerModule],
  providers: [GameGateWay, GameService],
})
export class GameModule {}
