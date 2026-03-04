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
import { GameService } from './game.service';
import type { MovePosition, UserIdType } from './game.type';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
export class GameGateWay implements OnGatewayConnection, OnGatewayDisconnect {
  constructor(private readonly gameService: GameService) {}
  @WebSocketServer()
  server: Server;

  handleConnection(client: Socket) {
    console.log(client.id, 'Connected');
  }

  handleDisconnect(client: Socket) {
    this.gameService.OutRoom(client);
  }

  @SubscribeMessage('out-room')
  handleOutRoom(@ConnectedSocket() client: Socket) {
    this.gameService.OutRoom(client);
  }

  @SubscribeMessage('request-play-game-online')
  async handleMessage(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: UserIdType,
  ) {
    const requestAddQueue = this.gameService.AddToQueue({
      idUser: data.idUser,
      socket: client,
    });
    if (requestAddQueue !== null) {
      const data = await this.gameService.StartGameOnline(requestAddQueue);

      requestAddQueue.firstUser.socket.emit('join-room', {
        idRoom: data.roomId,
        isYourTurn: data.isUser1Playfirst,
      });
      requestAddQueue.secondUser.socket.emit('join-room', {
        idRoom: data.roomId,
        isYourTurn: !data.isUser1Playfirst,
      });
    }
  }

  @SubscribeMessage('on-move')
  handleMessageOnMove(@MessageBody() data: MovePosition) {
    const resPonseData = this.gameService.OnMove(data);
    if (resPonseData.status === false) {
      resPonseData.client!.socket.emit('your-turn-move', {
        status: resPonseData.status,
        x: resPonseData.x,
        y: resPonseData.y,
      });
    } else {
      resPonseData.client1!.socket.emit('your-turn-move', {
        status: resPonseData.status,
        result: resPonseData.client1?.result,
        typeLine: resPonseData.typeLine,
        top: resPonseData.top,
        bottom: resPonseData.bottom,
      });
      resPonseData.client2!.socket.emit('your-turn-move', {
        status: resPonseData.status,
        result: resPonseData.client2?.result,
        typeLine: resPonseData.typeLine,
        top: resPonseData.top,
        bottom: resPonseData.bottom,
      });
    }
  }
}
