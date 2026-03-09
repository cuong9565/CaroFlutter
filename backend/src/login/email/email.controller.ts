import { Controller, Get, Param, Post, Query } from '@nestjs/common'
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
}