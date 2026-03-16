import { Module } from '@nestjs/common';
import { DatabaseModule } from 'src/database/database.module';
import { ChatGateWay } from './chat.gateway';
import { ChatService } from './chat.service';
import { ChatController } from './chat.controller';

@Module({
  imports: [DatabaseModule],
  controllers: [ChatController],
  providers: [ChatGateWay, ChatService],
})
export class ChatModule { }