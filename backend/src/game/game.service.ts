import { Injectable } from '@nestjs/common';
import { Socket } from 'socket.io';
import {
  Cell,
  MatchesType,
  MovePosition,
  QueueGameOnlineType,
  ResponseMovePosition,
  RoomsOnlineGameType,
  UserRequestType,
} from './game.type';
import { MatchesPlayerService } from 'src/matches_player/matches_player.service';

@Injectable()
export class GameService {
  private QueueGameOnline: QueueGameOnlineType = [];
  private RoomsOnlineGame: RoomsOnlineGameType = {};
  constructor(private readonly matchesPlayerService: MatchesPlayerService) {}

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
      };

    console.log(this.RoomsOnlineGame[move.roomId].board);

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
}
