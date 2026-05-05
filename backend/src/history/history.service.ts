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
      mp.game_mode,

      COUNT(*) FILTER (
        WHERE m.winner_id = ${userId}
      ) as wins,

      COUNT(*) FILTER (
        WHERE m.winner_id IS NOT NULL 
        AND m.winner_id != ${userId}
        AND m.is_ai_win = false
      ) as losses,

      COUNT(*) FILTER (
        WHERE m.is_draw = true
      ) as draws,

      COUNT(*) FILTER (
        WHERE m.is_ai_win = true
      ) as ai_losses,

      COUNT(*) as total

    FROM match m
    JOIN matches_player mp 
      ON m.id_matches_player = mp.id

    WHERE 
      mp.iduser_request = ${userId} 
      OR mp.iduser_response = ${userId}

    GROUP BY mp.game_mode
  `;

  const result = {
    total_games: 0,
    FRIEND: { wins: 0, losses: 0, draws: 0 },
    AI: { wins: 0, losses: 0, draws: 0 },
    ONLINE: { wins: 0, losses: 0, draws: 0 },
  };

  stats.forEach((s: any) => {
    const mode = s.game_mode;

    const wins = Number(s.wins);
    const draws = Number(s.draws);

    let losses = 0;

    if (mode === 'AI') {
      losses = Number(s.ai_losses); // AI thắng
    } else {
      losses = Number(s.losses);
    }

    result[mode] = { wins, losses, draws };
    result.total_games += Number(s.total);
  });

  return result;
}

async getMatchHistory(userId: string) {
  const rooms = await this.sql`
    SELECT 
      mp.id,
      mp.game_mode,
      mp.time_create,

      COALESCE(u_req.username, 'Unknown') as request_username,
      COALESCE(u_res.username, 'Unknown') as response_username,

      mp.iduser_request,
      mp.iduser_response,

      COUNT(*) FILTER (WHERE m.winner_id = ${userId}) as wins,

      COUNT(*) FILTER (
        WHERE m.winner_id IS NOT NULL 
        AND m.winner_id != ${userId}
        AND m.is_ai_win = false
      ) as losses,

      COUNT(*) FILTER (WHERE m.is_draw = true) as draws,

      COUNT(*) FILTER (WHERE m.is_ai_win = true) as ai_losses,

      COUNT(*) as total_matches

    FROM matches_player mp

    LEFT JOIN users u_req 
      ON mp.iduser_request = u_req.id

    LEFT JOIN users u_res 
      ON mp.iduser_response = u_res.id

    JOIN match m 
      ON mp.id = m.id_matches_player

    WHERE 
      mp.iduser_request = ${userId} 
      OR mp.iduser_response = ${userId}

    GROUP BY 
      mp.id, mp.game_mode, mp.time_create,
      u_req.username, u_res.username,
      mp.iduser_request, mp.iduser_response

    ORDER BY mp.time_create DESC
  `;

  return rooms.map((r: any) => {
    const isAI = r.game_mode === 'AI';

    return {
      id: r.id,
      gameMode: r.game_mode,
      timeCreate: r.time_create,

      opponent: isAI
        ? 'Computer'
        : (r.iduser_request === r.iduser_response
            ? 'Self'
            : (r.iduser_request === userId
                ? r.response_username
                : r.request_username)),

      wins: Number(r.wins),
      losses: isAI ? Number(r.ai_losses) : Number(r.losses),
      draws: Number(r.draws),

      totalMatches: Number(r.total_matches),
    };
  });
}

  async getRoomMatches(roomId: string, userId: string) {
    const matches = await this.sql`
      SELECT 
        m.id,
        m.time_create,
        m.winner_id,
        m.is_draw,
        m.is_ai_win
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
      } else if (m.is_ai_win || (m.winner_id !== null && m.winner_id !== userId)) {
        // AI thắng hoặc người khác thắng
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
