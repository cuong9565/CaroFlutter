import { Controller, Get, Param, Post } from '@nestjs/common';
import { UsersService } from './users.service';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  // /users/create-guest
  @Post('/create-guest')
  async createGuest() {
    const dataUser = await this.usersService.createGuest();
    return {
      user: dataUser,
    };
  }

  // /users/get
  @Get('/get/:id')
  async getUser(@Param('id') id: string) {
    const dataUser = await this.usersService.getUser(id);
    return {
      user: dataUser,
    };
  }
}
