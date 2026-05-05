import { Body, Controller, Post, Put } from '@nestjs/common';
import { MatchService } from './match.service';

@Controller('match')
export class MatchController {
  constructor(private readonly matchService: MatchService) {}
}
