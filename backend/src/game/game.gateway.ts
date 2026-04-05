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
import type {
  DataSendOnOutRoom,
  MovePosition,
  RequestOnMoveWithBot,
  RequestCreateRoomType,
  RequestOnMove,
  RequestStartGameType,
  UserIdType,
} from './game.type';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
export class GameGateWay implements OnGatewayConnection, OnGatewayDisconnect {
  constructor(private readonly gameService: GameService) {}
  @WebSocketServer()
  server!: Server;

  private async delay(ms: number): Promise<void> {
    await new Promise((resolve) => setTimeout(resolve, ms));
  }

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

  @SubscribeMessage('request-play-with-bot')
  requestPlayWithBot(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: UserIdType,
  ) {
    const response = this.gameService.StartGameWithBot({
      idUser: data.idUser,
      socketUser: client,
    });

    client.emit('response-start-game-with-bot', response);
  }

  @SubscribeMessage('request-on-move-with-bot')
  async requestOnMoveWithBot(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: RequestOnMoveWithBot,
  ) {
    const response = this.gameService.RequestOnMoveWithBot(data);

    const isBotResponse =
      response.state === 'OK' ||
      (response.state === 'ENDGAME' &&
        (response.result === 1 ||
          (response.result === 2 && response.lastTurn !== undefined)));

    if (isBotResponse) {
      await this.delay(1000);
    }

    client.emit('response-on-move-with-bot', response);
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
        lastTurn: resPonseData.lastTurn,
      });
      resPonseData.client2!.socket.emit('your-turn-move', {
        status: resPonseData.status,
        result: resPonseData.client2?.result,
        typeLine: resPonseData.typeLine,
        top: resPonseData.top,
        bottom: resPonseData.bottom,
        lastTurn: resPonseData.lastTurn,
      });
    }
  }

  @SubscribeMessage('on-out-room')
  onOutRoom(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: DataSendOnOutRoom,
  ) {
    const requestOutRoom = this.gameService.OnOutRoom({
      roomId: data.roomId,
      userLose: {
        idUser: data.idUserLose,
        socket: client,
      },
    });
    requestOutRoom.userWin.socket.emit('opponent-out-room', {});
  }

  @SubscribeMessage('request-create-room')
  async requestCreateRoom(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: RequestCreateRoomType,
  ) {
    const request = await this.gameService.RequestCreateRoom({
      idUser: data.idUser,
      socketUser: client,
    });
    client.emit('response-create-room', {
      idRoom: request.idRoom,
    });
  }

  @SubscribeMessage('request-start-game')
  async requestStartGame(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: RequestStartGameType,
  ) {
    const request = await this.gameService.RequestStartGame({
      idRoom: data.idRoom,
      idUser: data.idUser,
      socketUser: client,
    });
    if (request.state !== 'PLAY' && request.state !== 'LOAD') {
      client.emit('response-start-game', {
        state: request.state,
      });
      return;
    }

    if (request.state === 'PLAY') {
      request.user![0].socketUser.emit('response-start-game', {
        state: request.state,
        yourTurn: request.userTurn === 0 ? true : false,
        yourX: request.userX === 0 ? true : false,
        board: request.match?.boards,
        stateGame: request.match?.stateGame,
        isUserReady: request.match?.isU1Ready,
        isYouReady: request.match?.isU0Ready,
        yourRation: request.ratio?.[0],
        opponentRation: request.ratio?.[1],
      });
      request.user![1]!.socketUser!.emit('response-start-game', {
        state: request.state,
        yourTurn: request.userTurn === 1 ? true : false,
        yourX: request.userX === 1 ? true : false,
        board: request.match?.boards,
        stateGame: request.match?.stateGame,
        isUserReady: request.match?.isU0Ready,
        isYouReady: request.match?.isU1Ready,
        yourRation: request.ratio?.[1],
        opponentRation: request.ratio?.[0],
      });
    } else if (request.state === 'LOAD') {
      if (request.user?.[0].idUser === data.idUser) {
        client.emit('response-start-game', {
          state: request.state,
          yourTurn: request.userTurn === 0 ? true : false,
          yourX: request.userX === 0 ? true : false,
          board: request.match?.boards,
          stateGame:
            request.match?.stateGame === -1
              ? -1
              : request.match?.stateGame === 2
                ? 2
                : request.match?.stateGame === 0
                  ? 0
                  : 1,
          isUserReady: request.match?.isU1Ready,
          isYouReady: request.match?.isU0Ready,
          yourRation: request.ratio?.[0],
          opponentRation: request.ratio?.[1],
        });
      } else if (request.user![1]!.idUser! === data.idUser) {
        client.emit('response-start-game', {
          state: request.state,
          yourTurn: request.userTurn === 1 ? true : false,
          yourX: request.userX === 1 ? true : false,
          board: request.match?.boards,
          stateGame:
            request.match?.stateGame === -1
              ? -1
              : request.match?.stateGame === 2
                ? 2
                : request.match?.stateGame === 0
                  ? 1
                  : 0,
          isUserReady: request.match?.isU0Ready,
          isYouReady: request.match?.isU1Ready,
          yourRation: request.ratio?.[1],
          opponentRation: request.ratio?.[0],
        });
      }
    }
  }

  @SubscribeMessage('request-on-move')
  requestOnMove(@MessageBody() data: RequestOnMove) {
    const resPonseData = this.gameService.RequestOnMove(data);
    if (resPonseData.state === 'OK') {
      resPonseData.socketUser!.emit('response-on-move', {
        x: resPonseData.x,
        y: resPonseData.y,
      });
    } else if (resPonseData.state === 'ENDGAME') {
      resPonseData.client1!.socket.emit('response-on-move', {
        state: resPonseData.state,
        result: resPonseData.client1?.result,
        typeLine: resPonseData.typeLine,
        top: resPonseData.top,
        bottom: resPonseData.bottom,
        lastTurn: resPonseData.lastTurn,
        yourRation: resPonseData.ratio?.[0],
        opponentRation: resPonseData.ratio?.[1],
      });
      resPonseData.client2!.socket.emit('response-on-move', {
        state: resPonseData.state,
        result: resPonseData.client2?.result,
        typeLine: resPonseData.typeLine,
        top: resPonseData.top,
        bottom: resPonseData.bottom,
        lastTurn: resPonseData.lastTurn,
        yourRation: resPonseData.ratio?.[1],
        opponentRation: resPonseData.ratio?.[0],
      });
    }
  }

  @SubscribeMessage('request-out-room')
  requestOutRoom(@MessageBody() data: RequestStartGameType) {
    const response = this.gameService.RequestOutRoom(data);
    for (let i = 0; i < response.users.length; i++) {
      response?.users[i]?.emit('response-out-room');
    }
  }

  @SubscribeMessage('request-playagain')
  async requestPlayagain(@MessageBody() data: RequestStartGameType) {
    const request = await this.gameService.RequestPlayagain(data);
    if (request.state === 'PLAY') {
      request.user![0].socketUser.emit('response-start-game', {
        state: request.state,
        yourTurn: request.userTurn === 0 ? true : false,
        yourX: request.userX === 0 ? true : false,
        board: request.match?.boards,
        stateGame: request.match?.stateGame,
        isUserReady: request.match?.isU1Ready,
        isYouReady: request.match?.isU0Ready,
        yourRation: request.ratio?.[0],
        opponentRation: request.ratio?.[1],
      });
      request.user![1]!.socketUser!.emit('response-start-game', {
        state: request.state,
        yourTurn: request.userTurn === 1 ? true : false,
        yourX: request.userX === 1 ? true : false,
        board: request.match?.boards,
        stateGame: request.match?.stateGame,
        isUserReady: request.match?.isU0Ready,
        isYouReady: request.match?.isU1Ready,
        yourRation: request.ratio?.[1],
        opponentRation: request.ratio?.[0],
      });
    } else if (request.state === 'ALERT') {
      request.socket?.emit('response-playagain', {
        state: request.state,
      });
    }
  }
}
