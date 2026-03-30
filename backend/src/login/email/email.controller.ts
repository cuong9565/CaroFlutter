import { Controller, Delete, Get, Param, Post, Query } from '@nestjs/common'
import { EmailService } from './email.service';

@Controller('emails')
export class EmailController {
    constructor(private readonly emailSerivce: EmailService) { }

    @Post('/create-email')
    async createEmail(@Query('username') username: string, @Query('email') email: string, @Query('hash_password') hash_password: string) {
        await this.emailSerivce.createEmail(username, email, hash_password);
    }

    @Get('/get-password')
    async getPassword(@Query('username') username: string) {
        const password = await this.emailSerivce.getPassword(username)
        return { password: password }
    }

    @Get('/get-email')
    async getEmail(@Query('id') id: string) {
        const email = await this.emailSerivce.getEmail(id)
        return { email: email }
    }

    @Delete('/delete-email/:id')
    async deleteEmail(@Param('id') id: string) {
        await this.emailSerivce.deleteEmail(id);
    }
}