import { Controller, Get, Post, Body, Param, Query } from '@nestjs/common';
import { ChatService } from './chat.service';

@Controller('chat')
export class ChatController {
  constructor(private readonly chatService: ChatService) { }

  @Post('conversations')
  async createConversation(@Body() body: { participants: string[] }) {
    try {
      // Check if conversation already exists between these participants
      const existing = await this.chatService.findConversationByParticipants(body.participants);
      if (existing) {
        return existing;
      }
      return await this.chatService.createConversation(body.participants);
    } catch (error) {
      console.error('Error in createConversation:', error);
      throw error;
    }
  }

  @Get('conversations')
  async getConversations(@Query('userId') userId: string) {
    try {
      return await this.chatService.getUserConversationsFormatted(userId);
    } catch (error) {
      console.error('Error in getConversations:', error);
      throw error;
    }
  }

  @Get('conversations/:id/messages')
  async getMessages(@Param('id') conversationId: string) {
    try {
      return await this.chatService.getMessages(conversationId);
    } catch (error) {
      console.error('Error in getMessages:', error);
      throw error;
    }
  }
}