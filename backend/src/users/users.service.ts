import { Inject, Injectable } from '@nestjs/common';
import type { Database } from 'src/database/database.types';

@Injectable()
export class UsersService {
  constructor(
    @Inject('POSTGRES_POOL')
    private readonly sql: Database,
  ) { }

  async createGuest() {
    const RandomId = Math.floor(1000 + Math.random() * 9000);
    const username = `GUEST${RandomId.toString()}`;
    const data = await this.sql`
      insert into users(username)
      values(${username})
      returning *
    `;
    return data[0] ?? null;
  }

  async createUserEmail(username: string, type_login: number) {
    const data = await this.sql`
      insert into users(username, type_login)
      values(${username}, ${type_login})`;
  }

  async getUserByUsername(username: string) {
    const data = await this.sql`
      select * from users where username = ${username}`;
    return data[0]['id'] ?? null;
  }

  async getUser(id: string) {
    const data = await this.sql`
      select * 
      from users 
      where id = ${id}
      limit 1
    `;
    return data[0] ?? null;
  }

  async deleteUser(id: String) {
    const data = await this.sql`delete from users where id = ${id}`
    return data[0] ?? null;
  }
}
