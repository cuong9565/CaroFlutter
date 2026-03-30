import { Module } from "@nestjs/common";
import { DatabaseModule } from "src/database/database.module";
import { UsersModule } from "src/users/users.module";
import { GmailController } from "./gmail.controller";
import { GmailService } from "./gmail.service";

@Module({
    imports: [DatabaseModule, UsersModule],
    controllers: [GmailController],
    providers: [GmailService],
    exports: [GmailService]
})
export class GmailModule { }