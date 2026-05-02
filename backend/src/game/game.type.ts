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
  lines?: {
    typeLine: number;
    top: {
      x: number;
      y: number;
    };
    bottom: {
      x: number;
      y: number;
    };
  }[];
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

export type RequestCreateRoomType = {
  idRoom?: string;
  idUser: string;
  socketUser: Socket;
};

export type RoomsType = {
  [idRoom: string]: {
    user: {
      0: {
        idUser: string;
        socketUser: Socket;
      };
      1?: {
        idUser?: string;
        socketUser?: Socket;
      };
    };
    match: {
      id: string;
      userTurn: number; // 0 || 1
      userX: number; // 0 || 1
      numMove: number;
      boards: number[][]; // -1: null, 0: X, 1: O
      stateGame: number; // -1: Chưa đấu xong, 0 => U0Thắng, 1 => U0Thua, 2 => U0Hòa
      isU0Ready: number; // 0: Chưa sẵn sàng, 1: Đã sẵn sàng, 2: Đã out
      isU1Ready: number;
      lines: {
        typeLine: number;
        top: {
          x: number;
          y: number;
        };
        bottom: {
          x: number;
          y: number;
        };
      }[];
      turnTimeout?: NodeJS.Timeout;
      turnTimeoutExpiresAt?: number;
    }[];
    ratio: {
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
  };
};

export type MatchType = {
  id: string;
  userTurn: number; // 0 || 1
  userX: number; // 0 || 1
  numMove: number;
  boards: number[][]; // -1: null, 0: X, 1: O
  stateGame: number; // -1: Chưa đấu xong, 0 => U0Thắng, 1 => U0Thua, 2 => U0Hòa
  isU0Ready: number; // 0: Chưa sẵn sàng, 1: Đã sẵn sàng, 2: Đã out
  isU1Ready: number;
  lines: {
    typeLine: number;
    top: {
      x: number;
      y: number;
    };
    bottom: {
      x: number;
      y: number;
    };
  }[];
  turnTimeout?: NodeJS.Timeout;
  turnTimeoutExpiresAt?: number;
};

export type RequestStartGameType = {
  idRoom: string;
  idUser: string;
};

export type RequestParamStartGameType = {
  idRoom: string;
  idUser: string;
  socketUser: Socket;
};

export type ResponseStartGameType = {
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
    userTurn: number; // 0 || 1
    userX: number; // 0 || 1
    boards: number[][];
    stateGame: number; // -1: Chưa đấu xong, 0 => U0Thắng, 1 => U0Thua, 2 => U0Hòa
    isU0Ready: number; // 0: Chưa sẵn sàng, 1: Đã sẵn sàng, 2: Đã out
    isU1Ready: number;
    turnTimeoutExpiresAt?: number;
  };
  userTurn?: number;
  userX?: number;
  numMove?: number;
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
  lines?: {
    typeLine: number;
    top: {
      x: number;
      y: number;
    };
    bottom: {
      x: number;
      y: number;
    };
  }[];
};

export type RequestOnMove = {
  idRoom: string;
  idUser: string;
  x: number;
  y: number;
};

export type BotRoomsType = {
  [idRoom: string]: {
    user: UserRequestType;
    board: number[][];
    userTurn: 0 | 1; // 0: user, 1: bot
    userX: 0 | 1; // 0: user is X, 1: user is O
    stateGame: number; // -1: playing, 0: user win, 1: user lose, 2: draw
  };
};

export type RequestPlayWithBotType = {
  idUser: string;
  socketUser: Socket;
};

export type RequestOnMoveWithBot = {
  idRoom: string;
  idUser: string;
  x: number;
  y: number;
};

export type ResponseStartGameWithBotType = {
  state: 'PLAY' | 'ERROR';
  idRoom?: string;
  yourTurn?: boolean;
  yourX?: boolean;
  board?: number[][];
};

export type ResponseOnMoveWithBotType = {
  state: 'OK' | 'ENDGAME' | 'ERROR';
  x?: number;
  y?: number;
  result?: number; // 0 => user win, 1 => user lose, 2 => draw
  lastTurn?: Cell;
};

export type ResponseOnMovePosition = {
  state: string;
  socketUser?: Socket;
  x?: number;
  y?: number;
  turnDeadlineMs?: number;
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
  lines?: {
    typeLine: number;
    top: {
      x: number;
      y: number;
    };
    bottom: {
      x: number;
      y: number;
    };
  }[];
  top?: Cell;
  bottom?: Cell;
  lastTurn?: Cell;
};
