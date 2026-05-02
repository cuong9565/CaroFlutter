import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity()
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  username: string;

  @Column()
  type_login: number;

  @Column({ nullable: true })
  avatar_url: string;

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
