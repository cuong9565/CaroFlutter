import { Inject, Injectable } from '@nestjs/common';
import { Socket } from 'socket.io';
import type { Database } from 'src/database/database.types';
import {
  BotRoomsType,
  Cell,
  MatchesType,
  MatchType,
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
import { UsersService } from 'src/users/users.service';

@Injectable()
export class GameService {
  private QueueGameOnline: QueueGameOnlineType = [];
  private RoomsOnlineGame: RoomsOnlineGameType = {};
  private Rooms: RoomsType = {};
  private TIME_LIMIT: number = 30 * 1000; // 30 giây
  private readonly DEFAULT_BOARD_SIZE = 5;
  private readonly MIN_BOARD_SIZE = 10;
  private readonly MAX_BOARD_SIZE = 50;
  private boardSizeCache = this.DEFAULT_BOARD_SIZE;
  private boardSizeLoadedAt = 0;

  private BotRooms: BotRoomsType = {};
  constructor(
    @Inject('POSTGRES_POOL')
    private readonly sql: Database,
    private readonly matchesPlayerService: MatchesPlayerService,
    private readonly matchService: MatchService,
    private readonly usersService: UsersService,
  ) { }

  getTurnTimeLimitMs(): number {
    return this.TIME_LIMIT;
  }

  async getBoardSize(): Promise<number> {
    const now = Date.now();
    if (now - this.boardSizeLoadedAt < 60_000) {
      return this.boardSizeCache;
    }

    try {
      const rows = await this.sql`
        select board_size
        from game_settings
        where board_size is not null
        limit 1
      `;
      const rawValue = rows?.[0]?.board_size;
      const parsed = Number(rawValue);
      if (
        Number.isInteger(parsed) &&
        parsed >= this.MIN_BOARD_SIZE &&
        parsed <= this.MAX_BOARD_SIZE
      ) {
        this.boardSizeCache = parsed;
      }
    } catch {
      // Fallback default when table/column does not exist yet.
    }

    this.boardSizeLoadedAt = now;
    return this.boardSizeCache;
  }

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
      'ONLINE',
    );

    const boardSize = await this.getBoardSize();
    const isUser1Playfirst = Math.random() < 0.5;
    this.RoomsOnlineGame[room['id']] = {
      firstUser: matches.firstUser,
      secondUser: matches.secondUser,
      isFirstUserMove: isUser1Playfirst,
      isX: isUser1Playfirst,
      board: Array.from({ length: boardSize }, () =>
        Array.from({ length: boardSize }, () => null),
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

    // Send win
    if (lines.length > 0) {
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
        lines: lines,
        lastTurn: {
          x: move.x,
          y: move.y,
        },
      };
    }

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
      'FRIEND',
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
          numMove: this.Rooms[idRoom].match.at(-1)?.numMove,
          lines: this.Rooms[idRoom].match.at(-1)?.lines,
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
          numMove: this.Rooms[idRoom].match.at(-1)?.numMove,
          lines: this.Rooms[idRoom].match.at(-1)?.lines,
        };
      }
      return {
        state: 'ERROR',
      };
    }
  }

  async RequestOnMove(data: RequestOnMove): Promise<ResponseOnMovePosition> {
    const idRoom = data.idRoom;
    const idUser = data.idUser;
    const x = data.x;
    const y = data.y;
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

    // Check valid board
    if (!this.Rooms[idRoom]) {
      return {
        state: 'ERROR',
      };
    }

    // Lấy trận đấu hiện tại
    const currentMatch = this.Rooms[idRoom].match.at(-1)!;

    if (currentMatch.stateGame !== -1) {
      return {
        state: 'ERROR',
      };
    }

    // Check valid user
    const turn = currentMatch.userTurn;
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

    // Xóa TIMEOUT cũ
    if (currentMatch.turnTimeout) clearTimeout(currentMatch.turnTimeout);

    // Update board
    this.Rooms[idRoom].match.at(-1)!.boards[x][y] = turn!;
    this.Rooms[idRoom].match.at(-1)!.numMove =
      this.Rooms[idRoom].match.at(-1)!.numMove + 1;

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
      lines.push({
        typeLine: 1,
        top: top,
        bottom: bottom,
      });
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
      lines.push({
        typeLine: 2,
        top: top,
        bottom: bottom,
      });
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
      lines.push({
        typeLine: 3,
        top: top,
        bottom: bottom,
      });
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
      lines.push({
        typeLine: 4,
        top: top,
        bottom: bottom,
      });
    }

    if (lines.length > 0) {
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
      this.Rooms[idRoom].match.at(-1)!.lines = lines;

      // Update match table in database
      const currMatch = this.Rooms[idRoom].match.at(-1)!;
      const idMatchUpdate = currMatch.id;
      const user0Id = this.Rooms[idRoom].user[0].idUser;
      const user1Id = this.Rooms[idRoom].user[1]!.idUser!;
      const winnerId = currMatch.userTurn === 0 ? user0Id : user1Id;
      this.matchService.updateMatchResult(idMatchUpdate, winnerId, false);

      // Update user stats
      if (currMatch.userTurn === 0) {
        this.usersService.updateUserStats(user0Id, 'WIN');
        this.usersService.updateUserStats(user1Id, 'LOOSE');
      } else {
        this.usersService.updateUserStats(user0Id, 'LOOSE');
        this.usersService.updateUserStats(user1Id, 'WIN');
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
        lines: lines,
        top: top,
        bottom: bottom,
        lastTurn: {
          x: x,
          y: y,
        },
      };
    }

    const currentBoard = this.Rooms[idRoom].match.at(-1)!.boards;
    const totalCells = currentBoard.length * currentBoard.length;
    const currentNumMove = this.Rooms[idRoom].match.at(-1)!.numMove;

    // Hòa trận khi bàn cờ đã đầy và không có đường thắng
    if (currentNumMove >= totalCells) {
      this.Rooms[idRoom].match.at(-1)!.stateGame = 2;
      this.Rooms[idRoom].match.at(-1)!.lines = [];
      this.Rooms[idRoom].ratio[0].draw++;
      this.Rooms[idRoom].ratio[1].draw++;

      // Update match table in database
      const currMatch = this.Rooms[idRoom].match.at(-1)!;
      this.matchService.updateMatchResult(currMatch.id, null, true);

      // Update user stats
      const user0Id = this.Rooms[idRoom].user[0].idUser;
      const user1Id = this.Rooms[idRoom].user[1]!.idUser!;
      this.usersService.updateUserStats(user0Id, 'DRAW');
      this.usersService.updateUserStats(user1Id, 'DRAW');

      return {
        state: 'ENDGAME',
        client1: {
          idUser: this.Rooms[idRoom].user[0].idUser,
          socket: this.Rooms[idRoom].user[0].socketUser,
          result: 2,
        },
        client2: {
          idUser: this.Rooms[idRoom].user[1]!.idUser!,
          socket: this.Rooms[idRoom].user[1]!.socketUser!,
          result: 2,
        },
        ratio: this.Rooms[idRoom].ratio,
        lines: [],
        lastTurn: {
          x: x,
          y: y,
        },
      };
    }

    // Đổi lượt chơi
    this.Rooms[idRoom].match.at(-1)!.userTurn = 1 - turn!;

    // SET TIMEOUT MỚI cho lượt tiếp theo
    const now = Date.now();
    currentMatch.turnTimeoutExpiresAt = now + this.TIME_LIMIT;

    currentMatch.turnTimeout = setTimeout(() => {
      this.handleTurnTimeout(idRoom, currentMatch);
    }, this.TIME_LIMIT);

    return {
      state: 'OK', // status: "OK" => Da di, "ERROR" => LOI
      socketUser:
        this.Rooms[idRoom].user[
          this.Rooms[idRoom].match.at(-1)!.userTurn === 0 ? 0 : 1
        ]?.socketUser,
      x: x,
      y: y,
      turnDeadlineMs: currentMatch.turnTimeoutExpiresAt,
    };
  }

  async StartGameWithBot(data: RequestPlayWithBotType): Promise<ResponseStartGameWithBotType> {
    const roomDB = await this.matchesPlayerService.createMatchesPlayerOnlyUser1(
      data.idUser,
      false,
      'AI',
    );
    const idRoom = roomDB.id;

    const matchDB = await this.matchService.createMatch(idRoom);

    this.BotRooms[idRoom] = {
      user: {
        idUser: data.idUser,
        socket: data.socketUser,
      },
      board: Array.from({ length: 16 }, () =>
        Array.from({ length: 16 }, () => -1),
      ),
      userTurn: 0,
      userX: 0,
      stateGame: -1,
      idMatchDB: matchDB.id,
    };

    return {
      state: 'PLAY',
      idRoom,
      yourTurn: true,
      yourX: true,
      board: this.BotRooms[idRoom].board,
    };
  }

  async RequestOnMoveWithBot(data: RequestOnMoveWithBot): Promise<ResponseOnMoveWithBotType> {
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
      if (room.idMatchDB) {
        this.matchService.updateMatchResult(room.idMatchDB, room.user.idUser, false);
        this.usersService.updateUserStats(room.user.idUser, 'WIN');
      }
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
      if (room.idMatchDB) {
        this.matchService.updateMatchResult(room.idMatchDB, null, true);
        this.usersService.updateUserStats(room.user.idUser, 'DRAW');
      }
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
      if (room.idMatchDB) {
        this.matchService.updateMatchResult(room.idMatchDB, null, false); // Bot wins, so winner_id = null
        this.usersService.updateUserStats(room.user.idUser, 'LOOSE');
      }
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
      if (room.idMatchDB) {
        this.matchService.updateMatchResult(room.idMatchDB, null, true);
        this.usersService.updateUserStats(room.user.idUser, 'DRAW');
      }
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

    return result.length > 0
      ? result
      : [{ x: Math.floor(n / 2), y: Math.floor(n / 2) }];
  }

  private EvaluateMove(
    board: number[][],
    x: number,
    y: number,
    value: 0 | 1,
  ): number {
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
    return (
      x >= 0 &&
      x < board.length &&
      y >= 0 &&
      y < board.length &&
      board[x][y] === -1
    );
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

  async RequestOutRoom(data: RequestStartGameType) {
    const idUser = data.idUser;
    const idRoom = data.idRoom;

    if (this.BotRooms[idRoom] && this.BotRooms[idRoom].user.idUser === idUser) {
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
          if (this.Rooms[idRoom].match.at(-1)?.stateGame === -1) {
            const currMatch = this.Rooms[idRoom].match.at(-1)!;
            const idMatchUpdate = currMatch.id;
            this.Rooms[idRoom].match.at(-1)!.stateGame = 0;
            const user0Id = this.Rooms[idRoom].user[0].idUser;
            const user1Id = this.Rooms[idRoom].user[1]!.idUser!;
            this.usersService.updateUserStats(user0Id, 'WIN');
            this.usersService.updateUserStats(user1Id, 'LOOSE');

            // Update match table in database
            this.matchService.updateMatchResult(idMatchUpdate, user0Id, false);
          }

          const socketUser = this.Rooms[idRoom].user[0].socketUser;
          // Xóa phòng chơi
          delete this.Rooms[idRoom];
          return {
            users: [socketUser],
          };
        } else {
          // Trận đáu chưa kết thúc thì 1 thắng
          if (this.Rooms[idRoom].match.at(-1)?.stateGame === -1) {
            const currMatch = this.Rooms[idRoom].match.at(-1)!;
            const idMatchUpdate = currMatch.id;
            this.Rooms[idRoom].match.at(-1)!.stateGame = 1;
            const user0Id = this.Rooms[idRoom].user[0].idUser;
            const user1Id = this.Rooms[idRoom].user[1]!.idUser!;

            this.usersService.updateUserStats(user0Id, 'LOOSE');
            this.usersService.updateUserStats(user1Id, 'WIN');

            // Update match table in database
            this.matchService.updateMatchResult(idMatchUpdate, user1Id, false);
          }

          const socketUser = this.Rooms[idRoom].user[1]!.socketUser;
          // Xóa phòng chơi
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
      turnTimeoutExpiresAt?: number;
    };
    userTurn?: 0 | 1;
    userX?: 0 | 1;
    numMove?: number;
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
    const room = this.Rooms[idRoom];
    if (!room) throw new Error('Room not found');

    const boardSize = await this.getBoardSize();
    const match = await this.matchService.createMatch(idRoom);
    const turn: 0 | 1 = Math.floor(Math.random() * 2) as 0 | 1;

    const now = Date.now();

    const newMatch = {
      id: match.id,
      userTurn: turn,
      userX: turn,
      numMove: 0,
      boards: Array.from({ length: boardSize }, () =>
        Array.from({ length: boardSize }, () => -1),
      ),
      lines: [],
      stateGame: -1,
      isU0Ready: 0,
      isU1Ready: 0,

      // Timeout
      turnTimeoutExpiresAt: now + this.TIME_LIMIT,
      turnTimeout: undefined as NodeJS.Timeout | undefined,
    };

    // Set timeout
    newMatch.turnTimeout = setTimeout(() => {
      this.handleTurnTimeout(idRoom, newMatch);
    }, this.TIME_LIMIT);

    room.match.push(newMatch);

    return {
      state: 'PLAY',
      user: this.Rooms[idRoom].user,
      match: this.Rooms[idRoom].match.at(-1)!,
      ratio: this.Rooms[idRoom].ratio,
      userTurn: turn, // Ai đi trước
      userX: turn, // Ai là X
      numMove: 0, // Số lượt đánh
    };
  }

  private async handleTurnTimeout(idRoom: string, match: MatchType) {
    if (match.stateGame !== -1) return;

    const room = this.Rooms[idRoom];
    if (!room) return;

    // Người thua
    const loser = match.userTurn;
    // Người thắng
    const winner = 1 - loser;

    // Update người thắng
    match.stateGame = winner;

    // Update ratio
    room.ratio[winner].win++;
    room.ratio[loser].loose++;

    // Update DB
    const winnerId = room.user[winner].idUser;
    this.matchService.updateMatchResult(match.id, winnerId, false);

    // Update user stats
    const userWinnerId = room.user[winner].idUser;
    const userLoserId = room.user[loser]!.idUser!;
    this.usersService.updateUserStats(userWinnerId, 'WIN');
    this.usersService.updateUserStats(userLoserId, 'LOOSE');

    // Emit kết quả về client
    const socketWinner = room.user[winner].socketUser;
    const socketLoser = room.user[loser]!.socketUser;

    socketWinner.emit('response-on-move', {
      state: 'TIMEOUT',
      result: 0,
      yourRation: room.ratio[winner],
      opponentRation: room.ratio[loser],
    });

    socketLoser!.emit('response-on-move', {
      state: 'TIMEOUT',
      result: 1,
      yourRation: room.ratio[winner],
      opponentRation: room.ratio[loser],
    });
  }
}
