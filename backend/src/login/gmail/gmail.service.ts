import { Inject, Injectable } from "@nestjs/common";
import type { Database } from "src/database/database.types";
import { UsersService } from "src/users/users.service";

@Injectable()
export class GmailService {
    constructor(
        @Inject('POSTGRES_POOL')
        private readonly sql: Database,
        private readonly userService: UsersService,
    ) { }

    async createGmail(username: string, gmail: string, photoUrl: string) {
        this.userService.createUserGmail(username, photoUrl);
        const user = await this.userService.getUserByUsername(username);
        const user_id = user['id'];
        await this.sql`
            insert into login_by_gg (iduser, email)
            values(${user_id}, ${gmail})`;
    }

    async getGmail(id: string) {
        const data = await this.sql`
            select * from login_by_gg
            where idUser = ${id}`;
        if (data.length === 0) {
            return null;
        }
        return data[0] ?? null;
    }

    async deleteGmail(id: string) {
        await this.sql`delete from login_by_gg where idUser = ${id}`
    }
}