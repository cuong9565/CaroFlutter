import {
  Controller,
  Get,
  Param,
  Post,
  Delete,
  Put,
  Query,
} from '@nestjs/common';
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

  @Post('/create-user-email')
  async createUserEmail(@Query('username') username: string) {
    await this.usersService.createUserEmail(username);
  }

  @Post('/create-user-gmail')
  async createUserGmail(
    @Query('username') username: string,
    @Query('photoUrl') photoUrl: string,
  ) {
    await this.usersService.createUserGmail(username, photoUrl);
  }

  @Get('/get-user-email')
  async getUserEmail(@Query('username') username: string) {
    const data = await this.usersService.getUserByUsername(username);
    return { id: data };
  }

  // /users/get
  @Get('/get/:id')
  async getUser(@Param('id') id: string) {
    const dataUser = await this.usersService.getUser(id);
    return {
      user: dataUser,
    };
  }

  @Delete('/delete-user/:id')
  async deleteUser(@Param('id') id: string) {
    const dataUser = await this.usersService.deleteUser(id);
    return {
      user: dataUser,
    };
  }

  @Put('/update-user/:id')
  async updateUser(
    @Param('id') id: string,
    @Query('username') username: string,
    @Query('photoUrl') photoUrl: string,
  ) {
    await this.usersService.updateUser(id, username, photoUrl);
  }
}
