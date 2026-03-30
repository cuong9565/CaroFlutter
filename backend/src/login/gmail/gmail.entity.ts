import { Column, Entity, PrimaryColumn } from "typeorm";

@Entity()
export class Gmail {
    @PrimaryColumn()
    id: string

    @Column()
    user_id: string

    @Column()
    email: string
}