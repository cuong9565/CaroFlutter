import { Test, TestingModule } from '@nestjs/testing';
import { TestdbController } from './testdb.controller';
import { TestdbService } from './testdb.service';

describe('TestdbController', () => {
  let controller: TestdbController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [TestdbController],
      providers: [TestdbService],
    }).compile();

    controller = module.get<TestdbController>(TestdbController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
