import { Body, Controller, Post } from '@nestjs/common';
import { MatchesPlayerService } from './matches_player.service';

@Controller('matches-player')
export class MatchesPlayerController {
  constructor(private readonly matchesPlayerService: MatchesPlayerService) {}

  // /matches-player/create
  @Post('/create')
  async createMatchesPlayer(
    @Body('idUser1') idUser1: string,
    @Body('idUser2') idUser2: string,
    @Body('is_ranking') is_ranking: boolean,
  ) {
    return await this.matchesPlayerService.createMatchesPlayer(
      idUser1,
      idUser2,
      is_ranking,
    );
  }
}
