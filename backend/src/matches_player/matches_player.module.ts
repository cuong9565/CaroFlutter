import { Module } from '@nestjs/common';
import { MatchesPlayerController } from './matches_player.controller';
import { MatchesPlayerService } from './matches_player.service';
import { DatabaseModule } from 'src/database/database.module';

@Module({
  imports: [DatabaseModule],
  controllers: [MatchesPlayerController],
  providers: [MatchesPlayerService],
  exports: [MatchesPlayerService],
})
export class MatchesPlayerModule {}
