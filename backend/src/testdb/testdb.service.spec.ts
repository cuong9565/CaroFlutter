import { Test, TestingModule } from '@nestjs/testing';
import { TestdbService } from './testdb.service';

describe('TestdbService', () => {
  let service: TestdbService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [TestdbService],
    }).compile();

    service = module.get<TestdbService>(TestdbService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
