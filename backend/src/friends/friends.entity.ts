import { Column, Entity, PrimaryColumn } from "typeorm";

Entity()
export class Friend {
    @PrimaryColumn()
    id: string

    @Column()
    iduser_request: string

    @Column()
    iduser_reponse: string

    @Column()
    status: string
}