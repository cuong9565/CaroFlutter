import { Controller, Get, Param, Query } from '@nestjs/common';
import { HistoryService } from './history.service';

@Controller('history')
export class HistoryController {
  constructor(private readonly historyService: HistoryService) {}

  @Get('stats')
  async getOverallStats(@Query('userId') userId: string) {
    return this.historyService.getOverallStats(userId);
  }

  @Get('rooms')
  async getMatchHistory(@Query('userId') userId: string) {
    return this.historyService.getMatchHistory(userId);
  }

  @Get('rooms/:roomId/matches')
  async getRoomMatches(@Param('roomId') roomId: string, @Query('userId') userId: string) {
    return this.historyService.getRoomMatches(roomId, userId);
  }
}
