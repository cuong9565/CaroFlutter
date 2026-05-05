import {
  ConnectedSocket,
  MessageBody,
  OnGatewayInit,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import {ChatService} from './chat.service';

type DataMessage = {
  senderId: string;
  message: string;
};

@WebSocketGateway({ cors: { origin: '*' } })
export class ChatGateWay implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server!: Server;

  constructor(private readonly chatService : ChatService){}
  afterInit(server: Server){
    console.log('websocket ininting ');
  }
  handleConnection(client: Socket) {
    console.log('Client connected', client.id);
  }

  handleDisconnect(client: Socket) {
    console.log('Client disconnected', client.id);
  }

  @SubscribeMessage('join_conversation')
   async handleJoinConversation(
    @MessageBody() data: {conversationId : string },
    @ConnectedSocket() client: Socket,
  ) {
      client.join(data.conversationId);
      const message = await this.chatService.getRecentMessages(data.conversationId);
      client.emit('conversation_history', message);
      
  }

  @SubscribeMessage('send_message')
  async handleSendMessage(
    @MessageBody() data : {conversationId : string; content : string; senderId: string; timestamp: string} ,
    @ConnectedSocket() client : Socket,
  ) {
    const userId = data.senderId;
    const convId = parseInt(data.conversationId);
    const message = await this.chatService.createMessage(
      convId,
      userId,
      data.content,
      data.timestamp,
    );
    client.broadcast.to(data.conversationId).emit('new_message' , message);
     await this.chatService.updateConversationLastMessage(data.conversationId, message);


  }

  @SubscribeMessage('typing')
  handleTyping (
    @MessageBody() data : { conversationId : string , isTyping : boolean, senderId: string},
    @ConnectedSocket() client : Socket ,
  ){
    const userId = data.senderId;
    client.to(data.conversationId).emit('user_typing' , {userId, isTyping: data.isTyping});

  }

  @SubscribeMessage('leave_conversation')
  handleLeaveConversation(
    @MessageBody() data: { conversationId: string },
    @ConnectedSocket() client: Socket,
  ) {
    client.leave(data.conversationId);
    console.log(`User left conversation: ${data.conversationId}`);
  }
}
