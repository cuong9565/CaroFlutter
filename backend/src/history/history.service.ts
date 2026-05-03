import { Inject, Injectable } from '@nestjs/common';
import type { Database } from 'src/database/database.types';

@Injectable()
export class HistoryService {
  constructor(
    @Inject('POSTGRES_POOL')
    private readonly sql: Database,
  ) {}

  async getOverallStats(userId: string) {
    const stats = await this.sql`
      SELECT 
        game_mode,
        COUNT(*) FILTER (WHERE m.winner_id = ${userId}) as wins,
        COUNT(*) FILTER (WHERE m.winner_id IS NOT NULL AND m.winner_id != ${userId}) as losses,
        COUNT(*) FILTER (WHERE m.is_draw = true) as draws
      FROM matches_player mp
      JOIN match m ON mp.id = m.id_matches_player
      WHERE mp.iduser_request = ${userId} OR mp.iduser_response = ${userId}
      GROUP BY game_mode
    `;

    const totalStats = {
      total_games: 0,
      FRIEND: { wins: 0, losses: 0, draws: 0 },
      AI: { wins: 0, losses: 0, draws: 0 },
      ONLINE: { wins: 0, losses: 0, draws: 0 },
    };

    stats.forEach((s: any) => {
      const mode = s.game_mode as 'FRIEND' | 'AI' | 'ONLINE';
      const wins = parseInt(s.wins || '0');
      const losses = parseInt(s.losses || '0');
      const draws = parseInt(s.draws || '0');
      
      totalStats[mode] = { wins, losses, draws };
      totalStats.total_games += wins + losses + draws;
    });

    return totalStats;
  }

  async getMatchHistory(userId: string) {
    const rooms = await this.sql`
      SELECT 
        mp.id,
        mp.game_mode,
        mp.time_create,
        u_req.username as request_username,
        u_res.username as response_username,
        mp.iduser_request,
        mp.iduser_response,
        COUNT(*) FILTER (WHERE m.winner_id = ${userId}) as wins,
        COUNT(*) FILTER (WHERE m.winner_id IS NOT NULL AND m.winner_id != ${userId}) as losses,
        COUNT(*) FILTER (WHERE m.is_draw = true) as draws
      FROM matches_player mp
      LEFT JOIN users u_req ON mp.iduser_request = u_req.id
      LEFT JOIN users u_res ON mp.iduser_response = u_res.id
      JOIN match m ON mp.id = m.id_matches_player
      WHERE mp.iduser_request = ${userId} OR mp.iduser_response = ${userId}
      GROUP BY mp.id, mp.game_mode, mp.time_create, u_req.username, u_res.username, mp.iduser_request, mp.iduser_response
      ORDER BY mp.time_create DESC
    `;

    return rooms.map((r: any) => ({
      id: r.id,
      gameMode: r.game_mode,
      timeCreate: r.time_create,
      opponent: r.game_mode === 'AI' ? 'Computer' : (r.iduser_request === r.iduser_response ? 'Self' : (r.iduser_request === userId ? r.response_username : r.request_username)),
      wins: parseInt(r.wins || '0'),
      losses: parseInt(r.losses || '0'),
      draws: parseInt(r.draws || '0'),
    }));
  }

  async getRoomMatches(roomId: string, userId: string) {
    const matches = await this.sql`
      SELECT 
        m.id,
        m.time_create,
        m.winner_id,
        m.is_draw
      FROM match m
      WHERE m.id_matches_player = ${roomId}
      ORDER BY m.time_create ASC
    `;

    return matches.map((m: any) => {
      let result = 'PLAYING';
      if (m.is_draw) {
        result = 'DRAW';
      } else if (m.winner_id === userId) {
        result = 'WIN';
      } else if (m.winner_id !== null || (m.winner_id === null && !m.is_draw && m.time_create < new Date(Date.now() - 5000))) {
        // Nếu winner_id khác null (người khác thắng) HOẶC winner_id null nhưng không phải hòa (AI thắng)
        // Lưu ý: Thêm điều kiện thời gian để tránh hiển thị LOOSE ngay khi vừa tạo trận
        result = 'LOOSE';
      }
      return {
        id: m.id,
        timeCreate: m.time_create,
        result: result,
      };
    });
  }
}
