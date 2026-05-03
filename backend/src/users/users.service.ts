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

  async createUserEmail(username: string) {
    await this.sql`
      insert into users(username, type_login)
      values(${username}, 1)`;
  }

  async createUserGmail(username: string, photoUrl: string) {
    await this.sql`
      insert into users(username, avatar_url, type_login)
      values(${username}, ${photoUrl}, 2)`;
  }

  async getUserByUsername(username: string) {
    const data = await this.sql`
      select * from users where username = ${username}`;
    return data[0] ?? null;
  }

  async getUser(id: string) {
    const data = await this.sql`
      select u.*, coalesce(le.email, lg.email) as email
      from users u
      left join login_by_email le on u.id = le.iduser
      left join login_by_gg lg on u.id = lg.iduser
      where u.id = ${id}
      limit 1
    `;
    return data[0] ?? null;
  }

  async updateUser(id: string, username: string, photoUrl: string) {
    await this.sql`
      update users 
      set username = ${username}, avatar_url = ${photoUrl} 
      where id = ${id}
    `;
  }

  async deleteUser(id: string) {
    const data = await this.sql`delete from users where id = ${id}`;
    return data[0] ?? null;
  }
}
