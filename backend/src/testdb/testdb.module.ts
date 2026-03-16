import { Module } from '@nestjs/common';
import { TestdbService } from './testdb.service';
import { TestdbController } from './testdb.controller';
import { DatabaseModule } from 'src/database/database.module';

@Module({
  imports: [DatabaseModule],
  controllers: [TestdbController],
  providers: [TestdbService],
})
export class TestdbModule {}
