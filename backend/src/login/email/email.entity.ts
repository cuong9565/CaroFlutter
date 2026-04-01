import { Column, Entity, PrimaryColumn } from 'typeorm'

@Entity()
export class Email {
    @PrimaryColumn()
    id: string;

    @Column()
    user_id: string;

    @Column()
    email: string;

    @Column()
    hash_password: string
}