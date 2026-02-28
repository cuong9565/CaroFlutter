import { Controller, Get } from '@nestjs/common';
import { TestdbService } from './testdb.service';

@Controller('testdb')
export class TestdbController {
  constructor(private readonly testdbService: TestdbService) {}

  // Get /testdb
  @Get()
  async getAll() {
    return await this.testdbService.getAll();
  }
}
