import { Column, Entity, PrimaryColumn } from 'typeorm';

@Entity()
export class User {
  @PrimaryColumn()
  id: string;

  @Column()
  username: string;

  @Column()
  type_login: number;

  @Column()
  avatar_url: string | undefined;

  @Column()
  rating: number;

  @Column()
  total_matches: number;

  @Column()
  total_wins: number;

  @Column()
  total_draws: number;

  @Column()
  total_losses: number;
}
