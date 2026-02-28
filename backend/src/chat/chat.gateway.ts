import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

type DataMessage = {
  senderId: string;
  message: string;
};

@WebSocketGateway({ cors: { origin: '*' } })
export class ChatGateWay implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  handleConnection(client: Socket) {
    console.log('Client connected', client.id);
  }

  handleDisconnect(client: Socket) {
    console.log('Client disconnected', client.id);
  }

  @SubscribeMessage('send_message')
  handleMessage(
    @MessageBody() data: DataMessage,
    @ConnectedSocket() client: Socket,
  ) {
    console.log('Received:', data);

    client.broadcast.emit('receive_message', {
      senderId: client.id,
      message: data.message,
    });
  }
}
