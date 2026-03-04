import { Socket } from 'socket.io';

export type QueueGameOnlineType = UserRequestType[];

export type UserRequestType = {
  idUser: string;
  socket: Socket;
};

export type UserIdType = {
  idUser: string;
};

export type MatchesType = {
  firstUser: UserRequestType;
  secondUser: UserRequestType;
};

export type RoomsOnlineGameType = {
  [roomId: string]: {
    firstUser: UserRequestType;
    secondUser: UserRequestType;
    isFirstUserMove: boolean;
    isX: boolean;
    board: CellValue[][];
  };
};

export type CellValue = null | number;

export type MovePosition = {
  roomId: string;
  x: number;
  y: number;
};

export type ResponseMovePosition = {
  status: boolean;
  client?: UserRequestType;
  x?: number;
  y?: number;
  client1?: {
    idUser: string;
    socket: Socket;
    result: number; // 0 => Thắng, 1 => Thua, 2 => Hòa
  };
  client2?: {
    idUser: string;
    socket: Socket;
    result: number; // 0 => Thắng, 1 => Thua, 2 => Hòa
  };
  typeLine?: number;
  top?: Cell;
  bottom?: Cell;
  lastTurn?: Cell;
};

export type Cell = {
  x: number;
  y: number;
};

export type UserOutRoom = {
  roomId: string;
  userLose: UserRequestType;
};

export type ResponseOutRoom = {
  roomId: string;
  userWin: UserRequestType;
  userLose: UserRequestType;
};

export type DataSendOnOutRoom = {
  roomId: string;
  idUserLose: string;
};
