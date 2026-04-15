import { Body, Controller, Post, Put } from '@nestjs/common';
import { MatchService } from './match.service';

@Controller('match')
export class MatchController {
  constructor(private readonly matchService: MatchService) {}

  // /match/create
  @Post('/create')
  async createMatch(@Body('idMatchesPlayer') idMatchesPlayer: string) {
    return await this.matchService.createMatch(idMatchesPlayer);
  }
}
