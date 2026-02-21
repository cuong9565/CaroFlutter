import { Controller, Get, Inject } from '@nestjs/common';
import { TestdbService } from './testdb.service';
import type { Database } from 'src/database/database.types';

@Controller('testdb')
export class TestdbController {
  constructor(
    private readonly testdbService: TestdbService,
    @Inject('POSTGRES_POOL')
    private readonly sql: Database,
  ) {}

  // Get /testdb
  @Get()
  async getAll() {
    return this.testdbService.getAll();
  }
}
