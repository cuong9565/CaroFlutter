export type MatchType = {
  id: string;
  id_matches_player: string;
  state_userrequest?: number;
  winner_id?: string | null;
  is_draw?: boolean;
  is_ai_win?: boolean;
};
