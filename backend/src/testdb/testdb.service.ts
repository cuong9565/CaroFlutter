import { Inject, Injectable } from '@nestjs/common';
import type { Database } from 'src/database/database.types';

@Injectable()
export class TestdbService {
  constructor(
    @Inject('POSTGRES_POOL')
    private readonly sql: Database,
  ) {}

  async getAll() {
    const items = await this.sql`
      select * from testdb
    `;
    return items;
  }
}
