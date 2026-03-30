import { Inject, Injectable } from "@nestjs/common";
import type { Database } from "src/database/database.types";
import { UsersService } from "src/users/users.service";

@Injectable()
export class EmailService {
    constructor(
        @Inject('POSTGRES_POOL')
        private readonly sql: Database,
        private readonly usersService: UsersService
    ) { }

    async createEmail(username: string, email: string, hash_password: string) {
        // const uuid = generateUUID();
        this.usersService.createUserEmail(username);
        const user = await this.usersService.getUserByUsername(username);
        const user_id = user['id'];
        await this.sql`
            insert into login_by_email(idUser, email, hash_password)
            values(${user_id}, ${email}, ${hash_password})`;
    }

    async getPassword(username: string) {
        const user = await this.usersService.getUserByUsername(username);
        if (!user) {
            return null;
        }
        const user_id = user['id'];
        const data = await this.sql`
            select * from login_by_email
            where idUser = ${user_id}`;
        if (data.length === 0) {
            return null;
        }
        return data[0]['hash_password'] ?? null;
    }


    async getEmail(id: string) {
        const data = await this.sql`
            select * from login_by_email
            where idUser = ${id}`;
        if (data.length === 0) {
            return null;
        }
        return data[0] ?? null;
    }

    async deleteEmail(id: string) {
        await this.sql`delete from login_by_email where idUser = ${id}`
    }
}

// function generateUUID(): string {
//     return 'xxxxyxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
//         const r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
//         return v.toString(16);
//     });
// }