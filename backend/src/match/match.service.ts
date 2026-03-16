import { Inject, Injectable } from '@nestjs/common';
import type { Database } from 'src/database/database.types';
import { MatchType } from './match.type';

@Injectable()
export class MatchService {
  constructor(
    @Inject('POSTGRES_POOL')
    private readonly sql: Database,
  ) {}

  async createMatch(createMatch: string): Promise<MatchType> {
    const data = await this.sql`
      insert into match(id_matches_player)
      values(${createMatch})
      returning *
    `;
    return data[0] as MatchType;
  }
}
