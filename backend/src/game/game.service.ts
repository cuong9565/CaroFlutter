import { Injectable } from '@nestjs/common';
import { Socket } from 'socket.io';
import {
  BotRoomsType,
  Cell,
  MatchesType,
  MovePosition,
  QueueGameOnlineType,
  RequestCreateRoomType,
  RequestOnMove,
  RequestOnMoveWithBot,
  RequestParamStartGameType,
  RequestPlayWithBotType,
  RequestStartGameType,
  ResponseMovePosition,
  ResponseOnMoveWithBotType,
  ResponseOnMovePosition,
  ResponseOutRoom,
  ResponseStartGameWithBotType,
  ResponseStartGameType,
  RoomsOnlineGameType,
  RoomsType,
  UserOutRoom,
  UserRequestType,
} from './game.type';
import { MatchesPlayerService } from 'src/matches_player/matches_player.service';
import { MatchService } from 'src/match/match.service';

@Injectable()
export class GameService {
  private QueueGameOnline: QueueGameOnlineType = [];
  private RoomsOnlineGame: RoomsOnlineGameType = {};
  private Rooms: RoomsType = {};
  private BotRooms: BotRoomsType = {};
  constructor(
    private readonly matchesPlayerService: MatchesPlayerService,
    private readonly matchService: MatchService,
  ) {}

  AddToQueue(user: UserRequestType) {
    this.QueueGameOnline.push(user);
    if (this.QueueGameOnline.length >= 2) {
      const firstUser: UserRequestType = this.QueueGameOnline[0];
      const secondUser: UserRequestType = this.QueueGameOnline[1];
      this.QueueGameOnline.splice(0, 2);

      return {
        firstUser: firstUser,
        secondUser: secondUser,
      };
    }
    return null;
  }

  OutRoom(socket: Socket) {
    this.QueueGameOnline = this.QueueGameOnline.filter(
      (item) => item.socket !== socket,
    );

    for (const idRoom of Object.keys(this.BotRooms)) {
      if (this.BotRooms[idRoom].user.socket === socket) {
        delete this.BotRooms[idRoom];
      }
    }
  }

  async StartGameOnline(matches: MatchesType) {
    const room = await this.matchesPlayerService.createMatchesPlayer(
      matches.firstUser.idUser,
      matches.secondUser.idUser,
      true,
    );

    const isUser1Playfirst = Math.random() < 0.5;
    this.RoomsOnlineGame[room['id']] = {
      firstUser: matches.firstUser,
      secondUser: matches.secondUser,
      isFirstUserMove: isUser1Playfirst,
      isX: isUser1Playfirst,
      board: Array.from({ length: 16 }, () =>
        Array.from({ length: 16 }, () => null),
      ),
    };

    return {
      roomId: room['id'],
      isUser1Playfirst: isUser1Playfirst,
    };
  }

  OnMove(move: MovePosition): ResponseMovePosition {
    // Update board
    this.RoomsOnlineGame[move.roomId].board[move.x][move.y] = this
      .RoomsOnlineGame[move.roomId].isX
      ? 1
      : 0;

    const oldData = this.RoomsOnlineGame[move.roomId];
    const lines: {
      typeLine: number;
      top: {
        x: number;
        y: number;
      };
      bottom: {
        x: number;
        y: number;
      };
    }[] = [];
    let top: Cell, bottom: Cell;
    const type: number = oldData.isX ? 1 : 0;
    const n = oldData.board.length;
    // Đường dọc
    let line1 = 1;
    top = { x: move.x, y: move.y };
    bottom = { x: move.x, y: move.y };
    for (let i = move.x - 1, j = move.y; i >= 0; i--) {
      if (oldData.board[i][j] === type) {
        line1 = line1 + 1;
        top = { x: i, y: j };
      } else break;
    }
    for (let i = move.x + 1, j = move.y; i < n; i++) {
      if (oldData.board[i][j] === type) {
        line1 = line1 + 1;
        bottom = { x: i, y: j };
      } else break;
    }
    if (line1 >= 5) {
      lines.push({
        typeLine: 1,
        top: top,
        bottom: bottom,
      });
    }
    if (line1 >= 5)
      return {
        status: true,
        client1: {
          idUser: oldData.firstUser.idUser,
          socket: oldData.firstUser.socket,
          result: oldData.isFirstUserMove ? 0 : 1, // 0 => Thắng, 1 => Thua, 2 => Hòa
        },
        client2: {
          idUser: oldData.secondUser.idUser,
          socket: oldData.secondUser.socket,
          result: !oldData.isFirstUserMove ? 0 : 1, // 0 => Thắng, 1 => Thua, 2 => Hòa
        },
        typeLine: 1,
        top: top,
        bottom: bottom,
        lastTurn: {
          x: move.x,
          y: move.y,
        },
      };

    // // Đường ngang
    let line2 = 1;
    top = { x: move.x, y: move.y };
    bottom = { x: move.x, y: move.y };
    for (let i = move.x, j = move.y - 1; j >= 0; j--) {
      if (oldData.board[i][j] === type) {
        line2 = line2 + 1;
        top = { x: i, y: j };
      } else break;
    }
    for (let i = move.x, j = move.y + 1; j < n; j++) {
      if (oldData.board[i][j] === type) {
        line2 = line2 + 1;
        bottom = { x: i, y: j };
      } else break;
    }
    if (line2 >= 5) {
      lines.push({
        typeLine: 2,
        top: top,
        bottom: bottom,
      });
    }
    if (line2 >= 5)
      return {
        status: true,
        client1: {
          idUser: oldData.firstUser.idUser,
          socket: oldData.firstUser.socket,
          result: oldData.isFirstUserMove ? 0 : 1, // 0 => Thắng, 1 => Thua, 2 => Hòa
        },
        client2: {
          idUser: oldData.secondUser.idUser,
          socket: oldData.secondUser.socket,
          result: !oldData.isFirstUserMove ? 0 : 1, // 0 => Thắng, 1 => Thua, 2 => Hòa
        },
        typeLine: 2,
        top: top,
        bottom: bottom,
        lastTurn: {
          x: move.x,
          y: move.y,
        },
      };

    // // Đường chéo huyền
    let line3 = 1;
    top = { x: move.x, y: move.y };
    bottom = { x: move.x, y: move.y };
    for (let i = move.x - 1, j = move.y - 1; i >= 0 && j >= 0; i--, j--) {
      if (oldData.board[i][j] === type) {
        line3 = line3 + 1;
        top = { x: i, y: j };
      } else break;
    }
    for (let i = move.x + 1, j = move.y + 1; i < n && j < n; i++, j++) {
      if (oldData.board[i][j] === type) {
        line3 = line3 + 1;
        bottom = { x: i, y: j };
      } else break;
    }
    if (line3 >= 5) {
      lines.push({
        typeLine: 3,
        top: top,
        bottom: bottom,
      });
    }
    if (line3 >= 5)
      return {
        status: true,
        client1: {
          idUser: oldData.firstUser.idUser,
          socket: oldData.firstUser.socket,
          result: oldData.isFirstUserMove ? 0 : 1, // 0 => Thắng, 1 => Thua, 2 => Hòa
        },
        client2: {
          idUser: oldData.secondUser.idUser,
          socket: oldData.secondUser.socket,
          result: !oldData.isFirstUserMove ? 0 : 1, // 0 => Thắng, 1 => Thua, 2 => Hòa
        },
        typeLine: 3,
        top: top,
        bottom: bottom,
        lastTurn: {
          x: move.x,
          y: move.y,
        },
      };

    // // Đường chéo sắc
    let line4 = 1;
    top = { x: move.x, y: move.y };
    bottom = { x: move.x, y: move.y };
    for (let i = move.x - 1, j = move.y + 1; i >= 0 && j < n; i--, j++) {
      if (oldData.board[i][j] === type) {
        line4 = line4 + 1;
        top = { x: i, y: j };
      } else break;
    }
    for (let i = move.x + 1, j = move.y - 1; i < n && j >= 0; i++, j--) {
      if (oldData.board[i][j] === type) {
        line4 = line4 + 1;
        bottom = { x: i, y: j };
      } else break;
    }
    if (line4 >= 5) {
      lines.push({
        typeLine: 4,
        top: top,
        bottom: bottom,
      });
    }

    if (line4 >= 5)
      return {
        status: true,
        client1: {
          idUser: oldData.firstUser.idUser,
          socket: oldData.firstUser.socket,
          result: oldData.isFirstUserMove ? 0 : 1, // 0 => Thắng, 1 => Thua, 2 => Hòa
        },
        client2: {
          idUser: oldData.secondUser.idUser,
          socket: oldData.secondUser.socket,
          result: !oldData.isFirstUserMove ? 0 : 1, // 0 => Thắng, 1 => Thua, 2 => Hòa
        },
        typeLine: 4,
        top: top,
        bottom: bottom,
        lastTurn: {
          x: move.x,
          y: move.y,
        },
      };

    // Đổi lượt chơi
    this.RoomsOnlineGame[move.roomId].isFirstUserMove =
      !oldData.isFirstUserMove;
    this.RoomsOnlineGame[move.roomId].isX = !oldData.isX;

    // Lấy dữ liệu mới
    const newData = this.RoomsOnlineGame[move.roomId];
    return {
      status: false, // status: false => Choi tiep, true: Ket thuc
      client: newData.isFirstUserMove ? newData.firstUser : newData.secondUser,
      x: move.x,
      y: move.y,
    };
  }

  OnOutRoom(data: UserOutRoom): ResponseOutRoom {
    const idRoom = data.roomId;
    const room = this.RoomsOnlineGame[idRoom];
    const userLose = data.userLose;
    const userWin =
      room.firstUser.idUser === userLose.idUser
        ? room.secondUser
        : room.firstUser;
    return {
      roomId: idRoom,
      userLose: userLose,
      userWin: userWin,
    };
  }

  async RequestCreateRoom(
    data: RequestCreateRoomType,
  ): Promise<RequestCreateRoomType> {
    const idUser = data.idUser;
    const socketUser = data.socketUser;

    const room = await this.matchesPlayerService.createMatchesPlayerOnlyUser1(
      idUser,
      false,
    );

    this.Rooms[room.id] = {
      user: {
        0: {
          idUser: idUser,
          socketUser: socketUser,
        },
      },
      match: [],
      ratio: {
        0: {
          win: 0,
          loose: 0,
          draw: 0,
        },
        1: {
          win: 0,
          loose: 0,
          draw: 0,
        },
      },
    };

    return {
      idRoom: room.id,
      idUser: room.iduser_request,
      socketUser: socketUser,
    };
  }

  async RequestStartGame(
    data: RequestParamStartGameType,
  ): Promise<ResponseStartGameType> {
    const idRoom = data.idRoom;
    const idUser = data.idUser;
    const socketUser = data.socketUser;

    if (!this.Rooms[idRoom]) {
      return {
        state: 'ERROR',
      };
    }
    const room = this.Rooms[idRoom];
    if (!room.user[1]) {
      // Nếu phòng chưa đủ người
      if (idUser === room.user[0].idUser) {
        this.Rooms[idRoom].user[0].socketUser = data.socketUser;
        // Đúng user 1
        return {
          state: 'QR',
        };
      } else {
        this.Rooms[idRoom].user[1] = {
          idUser: idUser,
          socketUser: socketUser,
        };
        await this.matchesPlayerService.updateMatchesPlayerUser(idRoom, idUser);
        return await this.CreateNewMatch(idRoom);
      }
    } else {
      // Nếu phòng đã đủ người
      if (idUser === room.user[0].idUser) {
        this.Rooms[idRoom].user[0].socketUser = data.socketUser;
        return {
          state: 'LOAD',
          user: this.Rooms[idRoom].user,
          match: this.Rooms[idRoom].match.at(-1),
          ratio: this.Rooms[idRoom].ratio,
          userTurn: this.Rooms[idRoom].match.at(-1)?.userTurn,
          userX: this.Rooms[idRoom].match.at(-1)?.userX,
        };
      } else if (idUser === room.user[1].idUser) {
        this.Rooms[idRoom].user[1]!.socketUser = data.socketUser;
        return {
          state: 'LOAD',
          user: this.Rooms[idRoom].user,
          match: this.Rooms[idRoom].match.at(-1),
          ratio: this.Rooms[idRoom].ratio,
          userTurn: this.Rooms[idRoom].match.at(-1)?.userTurn,
          userX: this.Rooms[idRoom].match.at(-1)?.userX,
        };
      }
      return {
        state: 'ERROR',
      };
    }
  }

  RequestOnMove(data: RequestOnMove): ResponseOnMovePosition {
    const idRoom = data.idRoom;
    const idUser = data.idUser;
    const x = data.x;
    const y = data.y;

    // Check valid board
    if (!this.Rooms[idRoom]) {
      return {
        state: 'ERROR',
      };
    }

    // Check valid user
    const turn = this.Rooms[idRoom].match.at(-1)?.userTurn;
    if (this.Rooms[idRoom].user[turn === 0 ? 0 : 1]!.idUser != idUser) {
      return {
        state: 'ERROR',
      };
    }

    // Check valid move
    if (this.Rooms[idRoom].match.at(-1)!.boards[x][y] !== -1) {
      return {
        state: 'ERROR',
      };
    }

    // Update board
    this.Rooms[idRoom].match.at(-1)!.boards[x][y] = turn!;

    let top: Cell, bottom: Cell;
    const n = this.Rooms[idRoom].match.at(-1)!.boards.length;

    // Đường dọc
    let line1 = 1;
    top = { x: x, y: y };
    bottom = { x: x, y: y };
    for (let i = x - 1, j = y; i >= 0; i--) {
      if (this.Rooms[idRoom].match.at(-1)!.boards[i][j] === turn) {
        line1 = line1 + 1;
        top = { x: i, y: j };
      } else break;
    }
    for (let i = x + 1, j = y; i < n; i++) {
      if (this.Rooms[idRoom].match.at(-1)!.boards[i][j] === turn) {
        line1 = line1 + 1;
        bottom = { x: i, y: j };
      } else break;
    }
    if (line1 >= 5) {
      this.Rooms[idRoom].match.at(-1)!.stateGame =
        this.Rooms[idRoom].match.at(-1)?.userTurn === 0 ? 0 : 1;
      const userTurn = this.Rooms[idRoom].match.at(-1)?.userTurn;
      if (userTurn === 0) {
        this.Rooms[idRoom].ratio[0].win++;
        this.Rooms[idRoom].ratio[1].loose++;
      } else {
        this.Rooms[idRoom].ratio[1].win++;
        this.Rooms[idRoom].ratio[0].loose++;
      }
      return {
        state: 'ENDGAME',
        client1: {
          idUser: this.Rooms[idRoom].user[0].idUser,
          socket: this.Rooms[idRoom].user[0].socketUser,
          result: this.Rooms[idRoom].match.at(-1)?.userTurn === 0 ? 0 : 1, // 0 => Thắng, 1 => Thua, 2 => Hòa
        },
        client2: {
          idUser: this.Rooms[idRoom].user[1]!.idUser!,
          socket: this.Rooms[idRoom].user[1]!.socketUser!,
          result: this.Rooms[idRoom].match.at(-1)?.userTurn === 1 ? 0 : 1, // 0 => Thắng, 1 => Thua, 2 => Hòa
        },
        ratio: this.Rooms[idRoom].ratio,
        typeLine: 1,
        top: top,
        bottom: bottom,
        lastTurn: {
          x: x,
          y: y,
        },
      };
    }

    // // Đường ngang
    let line2 = 1;
    top = { x: x, y: y };
    bottom = { x: x, y: y };
    for (let i = x, j = y - 1; j >= 0; j--) {
      if (this.Rooms[idRoom].match.at(-1)!.boards[i][j] === turn) {
        line2 = line2 + 1;
        top = { x: i, y: j };
      } else break;
    }
    for (let i = x, j = y + 1; j < n; j++) {
      if (this.Rooms[idRoom].match.at(-1)!.boards[i][j] === turn) {
        line2 = line2 + 1;
        bottom = { x: i, y: j };
      } else break;
    }
    if (line2 >= 5) {
      this.Rooms[idRoom].match.at(-1)!.stateGame =
        this.Rooms[idRoom].match.at(-1)?.userTurn === 0 ? 0 : 1;
      const userTurn = this.Rooms[idRoom].match.at(-1)?.userTurn;
      if (userTurn === 0) {
        this.Rooms[idRoom].ratio[0].win++;
        this.Rooms[idRoom].ratio[1].loose++;
      } else {
        this.Rooms[idRoom].ratio[1].win++;
        this.Rooms[idRoom].ratio[0].loose++;
      }
      return {
        state: 'ENDGAME',
        client1: {
          idUser: this.Rooms[idRoom].user[0].idUser,
          socket: this.Rooms[idRoom].user[0].socketUser,
          result: this.Rooms[idRoom].match.at(-1)?.userTurn === 0 ? 0 : 1, // 0 => Thắng, 1 => Thua, 2 => Hòa
        },
        client2: {
          idUser: this.Rooms[idRoom].user[1]!.idUser!,
          socket: this.Rooms[idRoom].user[1]!.socketUser!,
          result: this.Rooms[idRoom].match.at(-1)?.userTurn === 1 ? 0 : 1, // 0 => Thắng, 1 => Thua, 2 => Hòa
        },
        ratio: this.Rooms[idRoom].ratio,
        typeLine: 2,
        top: top,
        bottom: bottom,
        lastTurn: {
          x: x,
          y: y,
        },
      };
    }

    // // Đường chéo huyền
    let line3 = 1;
    top = { x: x, y: y };
    bottom = { x: x, y: y };
    for (let i = x - 1, j = y - 1; i >= 0 && j >= 0; i--, j--) {
      if (this.Rooms[idRoom].match.at(-1)!.boards[i][j] === turn) {
        line3 = line3 + 1;
        top = { x: i, y: j };
      } else break;
    }
    for (let i = x + 1, j = y + 1; i < n && j < n; i++, j++) {
      if (this.Rooms[idRoom].match.at(-1)!.boards[i][j] === turn) {
        line3 = line3 + 1;
        bottom = { x: i, y: j };
      } else break;
    }
    if (line3 >= 5) {
      this.Rooms[idRoom].match.at(-1)!.stateGame =
        this.Rooms[idRoom].match.at(-1)?.userTurn === 0 ? 0 : 1;
      const userTurn = this.Rooms[idRoom].match.at(-1)?.userTurn;
      if (userTurn === 0) {
        this.Rooms[idRoom].ratio[0].win++;
        this.Rooms[idRoom].ratio[1].loose++;
      } else {
        this.Rooms[idRoom].ratio[1].win++;
        this.Rooms[idRoom].ratio[0].loose++;
      }
      return {
        state: 'ENDGAME',
        client1: {
          idUser: this.Rooms[idRoom].user[0].idUser,
          socket: this.Rooms[idRoom].user[0].socketUser,
          result: this.Rooms[idRoom].match.at(-1)?.userTurn === 0 ? 0 : 1, // 0 => Thắng, 1 => Thua, 2 => Hòa
        },
        client2: {
          idUser: this.Rooms[idRoom].user[1]!.idUser!,
          socket: this.Rooms[idRoom].user[1]!.socketUser!,
          result: this.Rooms[idRoom].match.at(-1)?.userTurn === 1 ? 0 : 1, // 0 => Thắng, 1 => Thua, 2 => Hòa
        },
        ratio: this.Rooms[idRoom].ratio,
        typeLine: 3,
        top: top,
        bottom: bottom,
        lastTurn: {
          x: x,
          y: y,
        },
      };
    }

    // // Đường chéo sắc
    let line4 = 1;
    top = { x: x, y: y };
    bottom = { x: x, y: y };
    for (let i = x - 1, j = y + 1; i >= 0 && j < n; i--, j++) {
      if (this.Rooms[idRoom].match.at(-1)!.boards[i][j] === turn) {
        line4 = line4 + 1;
        top = { x: i, y: j };
      } else break;
    }
    for (let i = x + 1, j = y - 1; i < n && j >= 0; i++, j--) {
      if (this.Rooms[idRoom].match.at(-1)!.boards[i][j] === turn) {
        line4 = line4 + 1;
        bottom = { x: i, y: j };
      } else break;
    }
    if (line4 >= 5) {
      this.Rooms[idRoom].match.at(-1)!.stateGame =
        this.Rooms[idRoom].match.at(-1)?.userTurn === 0 ? 0 : 1;
      const userTurn = this.Rooms[idRoom].match.at(-1)?.userTurn;
      if (userTurn === 0) {
        this.Rooms[idRoom].ratio[0].win++;
        this.Rooms[idRoom].ratio[1].loose++;
      } else {
        this.Rooms[idRoom].ratio[1].win++;
        this.Rooms[idRoom].ratio[0].loose++;
      }
      return {
        state: 'ENDGAME',
        client1: {
          idUser: this.Rooms[idRoom].user[0].idUser,
          socket: this.Rooms[idRoom].user[0].socketUser,
          result: this.Rooms[idRoom].match.at(-1)?.userTurn === 0 ? 0 : 1, // 0 => Thắng, 1 => Thua, 2 => Hòa
        },
        client2: {
          idUser: this.Rooms[idRoom].user[1]!.idUser!,
          socket: this.Rooms[idRoom].user[1]!.socketUser!,
          result: this.Rooms[idRoom].match.at(-1)?.userTurn === 1 ? 0 : 1, // 0 => Thắng, 1 => Thua, 2 => Hòa
        },
        ratio: this.Rooms[idRoom].ratio,
        typeLine: 4,
        top: top,
        bottom: bottom,
        lastTurn: {
          x: x,
          y: y,
        },
      };
    }

    // Đổi lượt chơi
    this.Rooms[idRoom].match.at(-1)!.userTurn = 1 - turn!;

    return {
      state: 'OK', // status: "OK" => Da di, "ERROR" => LOI
      socketUser:
        this.Rooms[idRoom].user[
          this.Rooms[idRoom].match.at(-1)!.userTurn === 0 ? 0 : 1
        ]?.socketUser,
      x: x,
      y: y,
    };
  }

  StartGameWithBot(
    data: RequestPlayWithBotType,
  ): ResponseStartGameWithBotType {
    const idRoom =
      'bot-' + Date.now().toString(36) + '-' + Math.random().toString(36).slice(2, 8);

    this.BotRooms[idRoom] = {
      user: {
        idUser: data.idUser,
        socket: data.socketUser,
      },
      board: Array.from({ length: 16 }, () => Array.from({ length: 16 }, () => -1)),
      userTurn: 0,
      userX: 0,
      stateGame: -1,
    };

    return {
      state: 'PLAY',
      idRoom,
      yourTurn: true,
      yourX: true,
      board: this.BotRooms[idRoom].board,
    };
  }

  RequestOnMoveWithBot(data: RequestOnMoveWithBot): ResponseOnMoveWithBotType {
    const room = this.BotRooms[data.idRoom];
    if (!room || room.user.idUser !== data.idUser || room.stateGame !== -1) {
      return {
        state: 'ERROR',
      };
    }

    if (room.userTurn !== 0) {
      return {
        state: 'ERROR',
      };
    }

    if (
      data.x < 0 ||
      data.x >= room.board.length ||
      data.y < 0 ||
      data.y >= room.board.length ||
      room.board[data.x][data.y] !== -1
    ) {
      return {
        state: 'ERROR',
      };
    }

    room.board[data.x][data.y] = 0;
    if (this.IsWinningMove(room.board, data.x, data.y, 0)) {
      room.stateGame = 0;
      return {
        state: 'ENDGAME',
        result: 0,
        lastTurn: {
          x: data.x,
          y: data.y,
        },
      };
    }

    if (this.IsBoardFull(room.board)) {
      room.stateGame = 2;
      return {
        state: 'ENDGAME',
        result: 2,
      };
    }

    room.userTurn = 1;
    const botMove = this.GetBestBotMove(room.board);
    room.board[botMove.x][botMove.y] = 1;

    if (this.IsWinningMove(room.board, botMove.x, botMove.y, 1)) {
      room.stateGame = 1;
      return {
        state: 'ENDGAME',
        result: 1,
        lastTurn: {
          x: botMove.x,
          y: botMove.y,
        },
      };
    }

    if (this.IsBoardFull(room.board)) {
      room.stateGame = 2;
      return {
        state: 'ENDGAME',
        result: 2,
        lastTurn: {
          x: botMove.x,
          y: botMove.y,
        },
      };
    }

    room.userTurn = 0;
    return {
      state: 'OK',
      x: botMove.x,
      y: botMove.y,
    };
  }

  private GetBestBotMove(board: number[][]): Cell {
    const candidates = this.GetCandidateMoves(board);
    for (const move of candidates) {
      if (this.IsWinningMove(board, move.x, move.y, 1)) {
        return move;
      }
    }

    for (const move of candidates) {
      if (this.IsWinningMove(board, move.x, move.y, 0)) {
        return move;
      }
    }

    let bestScore = -1;
    let bestMove = candidates[0];
    for (const move of candidates) {
      const attackScore = this.EvaluateMove(board, move.x, move.y, 1);
      const defendScore = this.EvaluateMove(board, move.x, move.y, 0);
      const score = attackScore * 2 + defendScore;
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    return bestMove;
  }

  private GetCandidateMoves(board: number[][]): Cell[] {
    const n = board.length;
    const set = new Set<string>();
    const result: Cell[] = [];

    let hasStone = false;
    for (let i = 0; i < n; i++) {
      for (let j = 0; j < n; j++) {
        if (board[i][j] !== -1) {
          hasStone = true;
          for (let dx = -1; dx <= 1; dx++) {
            for (let dy = -1; dy <= 1; dy++) {
              if (dx === 0 && dy === 0) continue;
              const nx = i + dx;
              const ny = j + dy;
              if (
                nx >= 0 &&
                nx < n &&
                ny >= 0 &&
                ny < n &&
                board[nx][ny] === -1
              ) {
                const key = nx + ':' + ny;
                if (!set.has(key)) {
                  set.add(key);
                  result.push({ x: nx, y: ny });
                }
              }
            }
          }
        }
      }
    }

    if (!hasStone) {
      const center = Math.floor(n / 2);
      return [{ x: center, y: center }];
    }

    return result.length > 0 ? result : [{ x: Math.floor(n / 2), y: Math.floor(n / 2) }];
  }

  private EvaluateMove(board: number[][], x: number, y: number, value: 0 | 1): number {
    if (board[x][y] !== -1) return -1;

    const directions = [
      [1, 0],
      [0, 1],
      [1, 1],
      [1, -1],
    ];
    let score = 0;

    for (const [dx, dy] of directions) {
      const left = this.CountInDirection(board, x, y, dx, dy, value);
      const right = this.CountInDirection(board, x, y, -dx, -dy, value);
      const total = left + right + 1;

      const open1x = x + (left + 1) * dx;
      const open1y = y + (left + 1) * dy;
      const open2x = x - (right + 1) * dx;
      const open2y = y - (right + 1) * dy;
      const openEnds =
        (this.IsEmptyCell(board, open1x, open1y) ? 1 : 0) +
        (this.IsEmptyCell(board, open2x, open2y) ? 1 : 0);

      score += this.GetPatternScore(total, openEnds);
    }

    return score;
  }

  private GetPatternScore(total: number, openEnds: number): number {
    if (total >= 5) return 1000000;
    if (total === 4 && openEnds === 2) return 200000;
    if (total === 4 && openEnds === 1) return 50000;
    if (total === 3 && openEnds === 2) return 12000;
    if (total === 3 && openEnds === 1) return 3000;
    if (total === 2 && openEnds === 2) return 600;
    if (total === 2 && openEnds === 1) return 120;
    return 10;
  }

  private CountInDirection(
    board: number[][],
    x: number,
    y: number,
    dx: number,
    dy: number,
    value: 0 | 1,
  ): number {
    let count = 0;
    let nx = x + dx;
    let ny = y + dy;
    while (
      nx >= 0 &&
      nx < board.length &&
      ny >= 0 &&
      ny < board.length &&
      board[nx][ny] === value
    ) {
      count++;
      nx += dx;
      ny += dy;
    }
    return count;
  }

  private IsEmptyCell(board: number[][], x: number, y: number): boolean {
    return x >= 0 && x < board.length && y >= 0 && y < board.length && board[x][y] === -1;
  }

  private IsWinningMove(
    board: number[][],
    x: number,
    y: number,
    value: 0 | 1,
  ): boolean {
    const directions = [
      [1, 0],
      [0, 1],
      [1, 1],
      [1, -1],
    ];

    for (const [dx, dy] of directions) {
      let line = 1;
      line += this.CountInDirection(board, x, y, dx, dy, value);
      line += this.CountInDirection(board, x, y, -dx, -dy, value);
      if (line >= 5) {
        return true;
      }
    }
    return false;
  }

  private IsBoardFull(board: number[][]): boolean {
    for (let i = 0; i < board.length; i++) {
      for (let j = 0; j < board.length; j++) {
        if (board[i][j] === -1) {
          return false;
        }
      }
    }
    return true;
  }

  RequestOutRoom(data: RequestStartGameType) {
    const idUser = data.idUser;
    const idRoom = data.idRoom;

    if (
      this.BotRooms[idRoom] &&
      this.BotRooms[idRoom].user.idUser === idUser
    ) {
      delete this.BotRooms[idRoom];
      return {
        users: [],
      };
    }

    if (!this.Rooms[idRoom]) {
      return {
        users: [],
      };
    }
    // Chỉ có user 0
    if (!this.Rooms[idRoom].user[1]) {
      if (this.Rooms[idRoom].user[0].idUser === idUser) {
        delete this.Rooms[idRoom];
      }
      return {
        users: [],
      };
    }
    // Có u0 và u1
    else {
      if (
        this.Rooms[idRoom].user[0].idUser !== idUser &&
        this.Rooms[idRoom].user[1].idUser !== idUser
      ) {
        return {
          users: [],
        };
      } else {
        // Không phải người out room
        if (this.Rooms[idRoom].user[0].idUser !== idUser) {
          // Trận đáu chưa kết thúc thì 0 thắng
          if (this.Rooms[idRoom].match.at(-1)?.stateGame === -1)
            this.Rooms[idRoom].match.at(-1)!.stateGame = 0;
          const socketUser = this.Rooms[idRoom].user[0].socketUser;
          delete this.Rooms[idRoom];
          return {
            users: [socketUser],
          };
        } else {
          // Trận đáu chưa kết thúc thì 1 thắng
          if (this.Rooms[idRoom].match.at(-1)?.stateGame === -1)
            this.Rooms[idRoom].match.at(-1)!.stateGame = 1;
          const socketUser = this.Rooms[idRoom].user[1].socketUser;
          delete this.Rooms[idRoom];
          return {
            users: [socketUser],
          };
        }
      }
    }
  }

  async RequestPlayagain(data: RequestStartGameType): Promise<{
    state: string;
    user?: {
      0: {
        idUser: string;
        socketUser: Socket;
      };
      1?: {
        idUser?: string;
        socketUser?: Socket;
      };
    };
    match?: {
      id: string;
      userTurn: number;
      userX: number;
      boards: number[][];
      stateGame: number;
      isU0Ready: number;
      isU1Ready: number;
    };
    userTurn?: 0 | 1;
    userX?: 0 | 1;
    socket?: Socket;
    ratio?: {
      0: {
        win: number;
        loose: number;
        draw: number;
      };
      1: {
        win: number;
        loose: number;
        draw: number;
      };
    };
  }> {
    const idUser = data.idUser;
    const idRoom = data.idRoom;

    if (!this.Rooms[idRoom]) {
      return {
        state: 'ERROR',
      };
    }
    // Mặc định luôn có idUser
    if (!this.Rooms[idRoom].user[1]) {
      return {
        state: 'ERROR',
      };
    }
    // Có u0 và u1
    else {
      if (
        this.Rooms[idRoom].user[0].idUser !== idUser &&
        this.Rooms[idRoom].user[1].idUser !== idUser
      ) {
        return {
          state: 'ERROR',
        };
      } else {
        // Nếu người gửi là user0
        if (this.Rooms[idRoom].user[0].idUser === idUser)
          this.Rooms[idRoom].match.at(-1)!.isU0Ready = 1;
        // Nếu người gửi là user1
        else if (this.Rooms[idRoom].user[1].idUser === idUser)
          this.Rooms[idRoom].match.at(-1)!.isU1Ready = 1;

        // Nếu cả 2 cùng accept
        if (
          this.Rooms[idRoom].match.at(-1)!.isU0Ready === 1 &&
          this.Rooms[idRoom].match.at(-1)!.isU1Ready === 1
        )
          return await this.CreateNewMatch(idRoom);
        // Nếu chỉ mới có 1 accept
        if (this.Rooms[idRoom].match.at(-1)!.isU0Ready === 1) {
          return {
            state: 'ALERT',
            socket: this.Rooms[idRoom].user[1].socketUser,
          };
        } else {
          return {
            state: 'ALERT',
            socket: this.Rooms[idRoom].user[0].socketUser,
          };
        }
      }
    }
  }

  async CreateNewMatch(idRoom: string) {
    const match = await this.matchService.createMatch(idRoom);
    const turn: 0 | 1 = Math.floor(Math.random() * 2) as 0 | 1;

    this.Rooms[idRoom].match.push({
      id: match.id,
      userTurn: turn,
      userX: turn,
      boards: Array.from({ length: 16 }, () =>
        Array.from({ length: 16 }, () => -1),
      ),
      stateGame: -1,
      isU0Ready: 0,
      isU1Ready: 0,
    });

    return {
      state: 'PLAY',
      user: this.Rooms[idRoom].user,
      match: this.Rooms[idRoom].match.at(-1)!,
      ratio: this.Rooms[idRoom].ratio,
      userTurn: turn,
      userX: turn,
    };
  }
}
