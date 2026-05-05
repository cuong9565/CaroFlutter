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
import { UsersService } from 'src/users/users.service';
import type {
  DataSendOnOutRoom,
  MovePosition,
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
  constructor(
    private readonly gameService: GameService,
    private readonly usersService: UsersService,
  ) {}
  @WebSocketServer()
  server!: Server;

  private onlineUsers = new Map<string, Socket>();
  private pendingChallenges = new Map<
    string,
    { requesterId: string; targetId: string }
  >();

  private async delay(ms: number): Promise<void> {
    await new Promise((resolve) => setTimeout(resolve, ms));
  }

  handleConnection(client: Socket) {
    console.log(client.id, 'Connected');
    const userId = client.handshake?.auth?.userId;
    if (typeof userId === 'string' && userId.trim().length > 0) {
      this.onlineUsers.set(userId, client);
    }
  }

  handleDisconnect(client: Socket) {
    console.log(client.id, 'Disconnected');
    this.gameService.OutRoom(client);
    const userId = client.handshake?.auth?.userId;
    if (typeof userId === 'string' && userId.trim().length > 0) {
      this.onlineUsers.delete(userId);
    }
    // Xóa user
  }

  @SubscribeMessage('challenge-request')
  async handleChallengeRequest(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { requesterId: string; targetId: string },
  ) {
    const requesterId = data?.requesterId;
    const targetId = data?.targetId;
    if (!requesterId || !targetId || requesterId == targetId) {
      client.emit('challenge-error', {
        message: 'Thong tin thach dau khong hop le',
      });
      return;
    }

    const targetSocket = this.onlineUsers.get(targetId);
    if (!targetSocket) {
      client.emit('challenge-error', {
        message: 'Nguoi choi khong online',
      });
      return;
    }

    const request = await this.gameService.RequestCreateRoom({
      idUser: requesterId,
      socketUser: client,
    });

    if (!request.idRoom) {
      client.emit('challenge-error', {
        message: 'Khong tao duoc phong',
      });
      return;
    }

    this.pendingChallenges.set(request.idRoom, {
      requesterId,
      targetId,
    });

    const requester = await this.usersService.getUser(requesterId);

    targetSocket.emit('challenge-received', {
      roomId: request.idRoom,
      requesterId,
      requesterName: requester?.username,
    });

    client.emit('challenge-requested', {
      roomId: request.idRoom,
      targetId,
    });
  }

  @SubscribeMessage('challenge-accept')
  async handleChallengeAccept(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { roomId: string },
  ) {
    const roomId = data?.roomId;
    if (!roomId || !this.pendingChallenges.has(roomId)) {
      client.emit('challenge-error', {
        message: 'Loi moi thach dau khong ton tai',
      });
      return;
    }

    const pending = this.pendingChallenges.get(roomId)!;
    const targetSocket = this.onlineUsers.get(pending.targetId);
    if (!targetSocket || targetSocket.id !== client.id) {
      client.emit('challenge-error', {
        message: 'Người nhận thách đấu đã offline',
      });
      this.pendingChallenges.delete(roomId);
      return;
    }

    const requesterSocket = this.onlineUsers.get(pending.requesterId);
    if (!requesterSocket) {
      client.emit('challenge-error', {
        message: 'Nguoi gui thach dau da offline',
      });
      this.pendingChallenges.delete(roomId);
      return;
    }

    requesterSocket.emit('challenge-start', { roomId });
    client.emit('challenge-start', { roomId });
    this.pendingChallenges.delete(roomId);
  }

  @SubscribeMessage('challenge-reject')
  async handleChallengeReject(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { roomId: string },
  ) {
    const roomId = data?.roomId;
    if (!roomId || !this.pendingChallenges.has(roomId)) {
      client.emit('challenge-error', {
        message: 'Loi moi thach dau khong ton tai',
      });
      return;
    }

    const pending = this.pendingChallenges.get(roomId)!;
    const requesterSocket = this.onlineUsers.get(pending.requesterId);
    if (requesterSocket) {
      requesterSocket.emit('challenge-rejected', {
        roomId,
        targetId: pending.targetId,
      });
    }
    this.pendingChallenges.delete(roomId);
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
      const response_create_room = await this.gameService.RequestCreateRoom({
        idUser: requestAddQueue.firstUser.idUser,
        socketUser: client,
        gameMode: 'ONLINE',
      });
      
      requestAddQueue.firstUser.socket.emit('response-create-room', {
        idRoom: response_create_room.idRoom,
        gameMode: 'ONLINE',
      });
      
      requestAddQueue.secondUser.socket.emit('response-create-room', {
        idRoom: response_create_room.idRoom,
        gameMode: 'ONLINE',
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
        lastTurn: resPonseData.lastTurn,
      });
      resPonseData.client2!.socket.emit('your-turn-move', {
        status: resPonseData.status,
        result: resPonseData.client2?.result,
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
    const gameMode = data.gameMode || 'FRIEND';
    const request = await this.gameService.RequestCreateRoom({
      idUser: data.idUser,
      socketUser: client,
      gameMode: gameMode,
    });
    client.emit('response-create-room', {
      idRoom: request.idRoom,
      gameMode: gameMode,
    });
  }

  @SubscribeMessage('request-start-game')
  async requestStartGame(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: RequestStartGameType,
  ) {
    const gameMode = data.gameMode || 'FRIEND';
    if (gameMode == 'FRIEND' || gameMode == 'ONLINE') {
      const request = await this.gameService.RequestStartGame({
        idRoom: data.idRoom,
        idUser: data.idUser,
        socketUser: client,
      });

      let user0Profile: {
        id?: string;
        username?: string;
        avatar_url?: string;
      } | null = null;
      let user1Profile: {
        id?: string;
        username?: string;
        avatar_url?: string;
      } | null = null;
      if (
        (request.state === 'PLAY' || request.state === 'LOAD') &&
        request.user?.[0].idUser &&
        request.user?.[1]?.idUser
      ) {
        [user0Profile, user1Profile] = await Promise.all([
          this.usersService.getUser(request.user[0].idUser),
          this.usersService.getUser(request.user[1].idUser!),
        ]);
      }

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
          isUser0X: request.userX === 0 ? true : false,
          board: request.match?.boards,
          stateGame: request.match?.stateGame,
          isUserReady: request.match?.isU1Ready,
          isYouReady: request.match?.isU0Ready,
          yourRation: request.ratio?.[0],
          opponentRation: request.ratio?.[1],
          opponent: {
            id: user1Profile?.id,
            username: user1Profile?.username,
            avatarUrl: user1Profile?.avatar_url,
          },
          you: {
            id: user0Profile?.id,
            username: user0Profile?.username,
            avatarUrl: user0Profile?.avatar_url,
          },
          turnDurationMs: this.gameService.getTurnTimeLimitMs(),
          turnDeadlineMs: request.match?.turnTimeoutExpiresAt,
          boardSize: request.match?.boards?.length,
          lines: [],
        });
        request.user![1]!.socketUser!.emit('response-start-game', {
          state: request.state,
          yourTurn: request.userTurn === 1 ? true : false,
          yourX: request.userX === 1 ? true : false,
          isUser0X: request.userX === 0 ? true : false,
          board: request.match?.boards,
          stateGame: request.match?.stateGame,
          isUserReady: request.match?.isU0Ready,
          isYouReady: request.match?.isU1Ready,
          yourRation: request.ratio?.[1],
          opponentRation: request.ratio?.[0],
          opponent: {
            id: user0Profile?.id,
            username: user0Profile?.username,
            avatarUrl: user0Profile?.avatar_url,
          },
          you: {
            id: user1Profile?.id,
            username: user1Profile?.username,
            avatarUrl: user1Profile?.avatar_url,
          },
          turnDurationMs: this.gameService.getTurnTimeLimitMs(),
          turnDeadlineMs: request.match?.turnTimeoutExpiresAt,
          boardSize: request.match?.boards?.length,
          lines: [],
        });
      } else if (request.state === 'LOAD') {
        if (request.user?.[0].idUser === data.idUser) {
          client.emit('response-start-game', {
            state: request.state,
            yourTurn: request.userTurn === 0 ? true : false,
            yourX: request.userX === 0 ? true : false,
            isUser0X: request.userX === 0 ? true : false,
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
            opponent: {
              id: user1Profile?.id,
              username: user1Profile?.username,
              avatarUrl: user1Profile?.avatar_url,
            },
            you: {
              id: user0Profile?.id,
              username: user0Profile?.username,
              avatarUrl: user0Profile?.avatar_url,
            },
            turnDurationMs: this.gameService.getTurnTimeLimitMs(),
            turnDeadlineMs: request.match?.turnTimeoutExpiresAt,
            boardSize: request.match?.boards?.length,
            lines: request.lines,
          });
        } else if (request.user![1]!.idUser! === data.idUser) {
          client.emit('response-start-game', {
            state: request.state,
            yourTurn: request.userTurn === 1 ? true : false,
            yourX: request.userX === 1 ? true : false,
            isUser0X: request.userX === 0 ? true : false,
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
            opponent: {
              id: user0Profile?.id,
              username: user0Profile?.username,
              avatarUrl: user0Profile?.avatar_url,
            },
            you: {
              id: user1Profile?.id,
              username: user1Profile?.username,
              avatarUrl: user1Profile?.avatar_url,
            },
            turnDurationMs: this.gameService.getTurnTimeLimitMs(),
            turnDeadlineMs: request.match?.turnTimeoutExpiresAt,
            boardSize: request.match?.boards?.length,
            lines: request.lines,
          });
        }
      }
      return;
    }

    if (gameMode == 'AI') {
      const request = await this.gameService.RequestStartGame({
        idRoom: data.idRoom,
        idUser: data.idUser,
        socketUser: client,
        gameMode: gameMode,
      });

      let user0Profile: {
        id?: string;
        username?: string;
        avatar_url?: string;
      } | null = null;
      let user1Profile: {
        id?: null;
        username?: null;
        avatar_url?: null;
      } | null = null;

      if (
        (request.state === 'PLAY' || request.state === 'LOAD') &&
        request.user?.[0].idUser
      ) {
        [user0Profile] = await Promise.all([
          this.usersService.getUser(request.user[0].idUser),
        ]);
      }

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
          isUser0X: request.userX === 0 ? true : false,
          board: request.match?.boards,
          stateGame: request.match?.stateGame,
          isUserReady: request.match?.isU1Ready,
          isYouReady: request.match?.isU0Ready,
          yourRation: request.ratio?.[0],
          opponentRation: request.ratio?.[1],
          opponent: {
            id: null,
            username: 'Bot',
            avatarUrl: null,
          },
          you: {
            id: user0Profile?.id,
            username: user0Profile?.username,
            avatarUrl: user0Profile?.avatar_url,
          },
          turnDurationMs: this.gameService.getTurnTimeLimitMs(),
          turnDeadlineMs: request.match?.turnTimeoutExpiresAt,
          boardSize: request.match?.boards?.length,
          lines: [],
        });

        // Nếu AI đi trước
        if (request.userTurn == 1) {
          const resPonseData = await this.gameService.process_ai_first_move(
            data.idRoom,
          );
          if (resPonseData.state === 'OK') {
            resPonseData.socketUser!.emit('response-on-move', {
              x: resPonseData.x,
              y: resPonseData.y,
              turnDurationMs: this.gameService.getTurnTimeLimitMs(),
              turnDeadlineMs: resPonseData.turnDeadlineMs,
            });
          } else if (resPonseData.state === 'ENDGAME') {
            resPonseData.client1!.socket.emit('response-on-move', {
              state: resPonseData.state,
              result: resPonseData.client1?.result,
              lines: resPonseData.lines,
              lastTurn: resPonseData.lastTurn,
              yourRation: resPonseData.ratio?.[0],
              opponentRation: resPonseData.ratio?.[1],
            });
          }
        }
      } else if (request.state === 'LOAD') {
        if (request.user?.[0].idUser === data.idUser) {
          client.emit('response-start-game', {
            state: request.state,
            yourTurn: request.userTurn === 0 ? true : false,
            yourX: request.userX === 0 ? true : false,
            isUser0X: request.userX === 0 ? true : false,
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
            opponent: {
              id: null,
              username: 'Bot',
              avatarUrl: null,
            },
            you: {
              id: user0Profile?.id,
              username: user0Profile?.username,
              avatarUrl: user0Profile?.avatar_url,
            },
            turnDurationMs: this.gameService.getTurnTimeLimitMs(),
            turnDeadlineMs: request.match?.turnTimeoutExpiresAt,
            boardSize: request.match?.boards?.length,
            lines: request.lines,
          });
        }
      }
      return;
    }
  }

  @SubscribeMessage('request-on-move')
  async requestOnMove(@MessageBody() data: RequestOnMove) {
    const gameMode = data.gameMode || 'FRIEND';
    if (gameMode == 'FRIEND' || gameMode == 'ONLINE') {
      const resPonseData = await this.gameService.RequestOnMove(data, gameMode);
      if (resPonseData.state === 'OK') {
        resPonseData.socketUser!.emit('response-on-move', {
          x: resPonseData.x,
          y: resPonseData.y,
          turnDurationMs: this.gameService.getTurnTimeLimitMs(),
          turnDeadlineMs: resPonseData.turnDeadlineMs,
        });
      } else if (resPonseData.state === 'ENDGAME') {
        resPonseData.client1!.socket.emit('response-on-move', {
          state: resPonseData.state,
          result: resPonseData.client1?.result,
          lines: resPonseData.lines,
          lastTurn: resPonseData.lastTurn,
          yourRation: resPonseData.ratio?.[0],
          opponentRation: resPonseData.ratio?.[1],
        });
        resPonseData.client2!.socket.emit('response-on-move', {
          state: resPonseData.state,
          result: resPonseData.client2?.result,
          lines: resPonseData.lines,
          lastTurn: resPonseData.lastTurn,
          yourRation: resPonseData.ratio?.[1],
          opponentRation: resPonseData.ratio?.[0],
        });
      }
    } else {
      const resPonseData = await this.gameService.RequestOnMove(data, 'AI');
      if (resPonseData.state === 'OK') {
        resPonseData.socketUser!.emit('response-on-move', {
          x: resPonseData.x,
          y: resPonseData.y,
          turnDurationMs: this.gameService.getTurnTimeLimitMs(),
          turnDeadlineMs: resPonseData.turnDeadlineMs,
        });
      } else if (resPonseData.state === 'ENDGAME') {
        resPonseData.client1!.socket.emit('response-on-move', {
          state: resPonseData.state,
          result: resPonseData.client1?.result,
          lines: resPonseData.lines,
          lastTurn: resPonseData.lastTurn,
          yourRation: resPonseData.ratio?.[0],
          opponentRation: resPonseData.ratio?.[1],
        });
      }
    }
  }

  @SubscribeMessage('request-out-room')
  async requestOutRoom(@MessageBody() data: RequestStartGameType) {
    const gameMode = data.gameMode || 'FRIEND';
    const response = await this.gameService.RequestOutRoom(data, gameMode);
    for (let i = 0; i < response.users.length; i++) {
      response?.users[i]?.emit('response-out-room');
    }
  }

  @SubscribeMessage('request-playagain')
  async requestPlayagain(@MessageBody() data: RequestStartGameType) {
    const gameMode = data.gameMode || 'FRIEND';
    if (gameMode == 'FRIEND' || gameMode == 'ONLINE') {
      const request = await this.gameService.RequestPlayagain(data, gameMode);
      if (request.state === 'PLAY') {
        const [user0Profile, user1Profile] = await Promise.all([
          this.usersService.getUser(request.user![0].idUser),
          this.usersService.getUser(request.user![1]!.idUser!),
        ]);

        request.user![0].socketUser.emit('response-start-game', {
          state: request.state,
          yourTurn: request.userTurn === 0 ? true : false,
          yourX: request.userX === 0 ? true : false,
          isUser0X: request.userX === 0 ? true : false,
          board: request.match?.boards,
          stateGame: request.match?.stateGame,
          isUserReady: request.match?.isU1Ready,
          isYouReady: request.match?.isU0Ready,
          yourRation: request.ratio?.[0],
          opponentRation: request.ratio?.[1],
          opponent: {
            id: user1Profile?.id,
            username: user1Profile?.username,
            avatarUrl: user1Profile?.avatar_url,
          },
          you: {
            id: user0Profile?.id,
            username: user0Profile?.username,
            avatarUrl: user0Profile?.avatar_url,
          },
          turnDurationMs: this.gameService.getTurnTimeLimitMs(),
          turnDeadlineMs: request.match?.turnTimeoutExpiresAt,
          boardSize: request.match?.boards?.length,
          lines: [],
        });
        request.user![1]!.socketUser!.emit('response-start-game', {
          state: request.state,
          yourTurn: request.userTurn === 1 ? true : false,
          yourX: request.userX === 1 ? true : false,
          isUser0X: request.userX === 0 ? true : false,
          board: request.match?.boards,
          stateGame: request.match?.stateGame,
          isUserReady: request.match?.isU0Ready,
          isYouReady: request.match?.isU1Ready,
          yourRation: request.ratio?.[1],
          opponentRation: request.ratio?.[0],
          opponent: {
            id: user0Profile?.id,
            username: user0Profile?.username,
            avatarUrl: user0Profile?.avatar_url,
          },
          you: {
            id: user1Profile?.id,
            username: user1Profile?.username,
            avatarUrl: user1Profile?.avatar_url,
          },
          turnDurationMs: this.gameService.getTurnTimeLimitMs(),
          turnDeadlineMs: request.match?.turnTimeoutExpiresAt,
          boardSize: request.match?.boards?.length,
          lines: [],
        });
      } else if (request.state === 'ALERT') {
        request.socket?.emit('response-playagain', {
          state: request.state,
        });
      }
    } else {
      const request = await this.gameService.RequestPlayagain(data, 'AI');
      if (request.state === 'PLAY') {
        const [user0Profile] = await Promise.all([
          this.usersService.getUser(request.user![0].idUser),
        ]);

        request.user![0].socketUser.emit('response-start-game', {
          state: request.state,
          yourTurn: request.userTurn === 0 ? true : false,
          yourX: request.userX === 0 ? true : false,
          isUser0X: request.userX === 0 ? true : false,
          board: request.match?.boards,
          stateGame: request.match?.stateGame,
          isUserReady: request.match?.isU1Ready,
          isYouReady: request.match?.isU0Ready,
          yourRation: request.ratio?.[0],
          opponentRation: request.ratio?.[1],
          opponent: {
            id: null,
            username: 'AI',
            avatarUrl: null,
          },
          you: {
            id: user0Profile?.id,
            username: user0Profile?.username,
            avatarUrl: user0Profile?.avatar_url,
          },
          turnDurationMs: this.gameService.getTurnTimeLimitMs(),
          turnDeadlineMs: request.match?.turnTimeoutExpiresAt,
          boardSize: request.match?.boards?.length,
          lines: [],
        });

        if (request.userTurn == 1) {
          const resPonseData = await this.gameService.process_ai_first_move(
            data.idRoom,
          );
          if (resPonseData.state === 'OK') {
            resPonseData.socketUser!.emit('response-on-move', {
              x: resPonseData.x,
              y: resPonseData.y,
              turnDurationMs: this.gameService.getTurnTimeLimitMs(),
              turnDeadlineMs: resPonseData.turnDeadlineMs,
            });
          } else if (resPonseData.state === 'ENDGAME') {
            resPonseData.client1!.socket.emit('response-on-move', {
              state: resPonseData.state,
              result: resPonseData.client1?.result,
              lines: resPonseData.lines,
              lastTurn: resPonseData.lastTurn,
              yourRation: resPonseData.ratio?.[0],
              opponentRation: resPonseData.ratio?.[1],
            });
          }
        }
      } else if (request.state === 'ALERT') {
        request.socket?.emit('response-playagain', {
          state: request.state,
        });
      }
    }
  }
}
