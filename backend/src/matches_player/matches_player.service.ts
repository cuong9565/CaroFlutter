import { Inject, Injectable } from '@nestjs/common';
import type { Database } from 'src/database/database.types';
import { MatchesPlayerType } from './matches_player.type';

@Injectable()
export class MatchesPlayerService {
  constructor(
    @Inject('POSTGRES_POOL')
    private readonly sql: Database,
  ) {}

  async createMatchesPlayer(
    idUser1: string,
    idUser2: string,
    is_ranking: boolean,
    game_mode: 'FRIEND' | 'AI' | 'ONLINE' = 'FRIEND',
  ): Promise<MatchesPlayerType> {
    const data = await this.sql`
      insert into matches_player(iduser_request, iduser_response, is_ranking, game_mode)
      values(${idUser1}, ${idUser2}, ${is_ranking}, ${game_mode})
      returning *
    `;
    return data[0] as MatchesPlayerType;
  }

  async createMatchesPlayerOnlyUser1(
    idUser1: string,
    is_ranking: boolean,
    game_mode: 'FRIEND' | 'AI' | 'ONLINE' = 'FRIEND',
  ): Promise<MatchesPlayerType> {
    const data = await this.sql`
      insert into matches_player(iduser_request, is_ranking, game_mode)
      values(${idUser1}, ${is_ranking}, ${game_mode})
      returning *
    `;
    return data[0] as MatchesPlayerType;
  }

  async updateMatchesPlayerUser(
    id: string,
    iduser_response: string,
  ): Promise<void> {
    await this.sql`
      update matches_player
      set iduser_response = ${iduser_response}
      where id = ${id}
    `;
  }
}
