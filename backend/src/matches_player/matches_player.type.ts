export type MatchesPlayerType = {
  id: string;
  iduser_request: string;
  iduser_response?: string;
  is_ranking: boolean;
  game_mode: 'FRIEND' | 'AI' | 'ONLINE';
};
