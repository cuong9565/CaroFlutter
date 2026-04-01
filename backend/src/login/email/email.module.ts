import { Module } from "@nestjs/common";
import { DatabaseModule } from "src/database/database.module";
import { EmailController } from "./email.controller";
import { EmailService } from "./email.service";
import { UsersModule } from "src/users/users.module";

@Module({
    imports: [DatabaseModule, UsersModule],
    controllers: [EmailController],
    providers: [EmailService],
    exports: [EmailService],
})
export class EmailModule { }