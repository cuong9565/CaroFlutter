import { Controller, Delete, Get, Param, Post, Query } from "@nestjs/common";
import { GmailService } from "./gmail.service";

@Controller('gmails')
export class GmailController {
    constructor(private readonly gmailService: GmailService) { }

    @Post('/create-gmail')
    async createGmailUser(@Query('username') username: string, @Query('gmail') gmail: string, @Query('photoUrl') photoUrl: string) {
        await this.gmailService.createGmail(username, gmail, photoUrl);
    }

    @Get('/get-gmail')
    async getGmail(@Query('id') id: string) {
        const gmail = await this.gmailService.getGmail(id);
        return { 'gmail': gmail }
    }

    @Delete('/delete-gmail/:id')
    async deleteGmail(@Param('id') id: string) {
        await this.gmailService.deleteGmail(id);
    }
}