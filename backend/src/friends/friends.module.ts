import { Module } from "@nestjs/common";
import { DatabaseModule } from "src/database/database.module";
import { FriendController } from "./friends.controller";
import { FriendService } from "./friends.service";

@Module({
    imports: [DatabaseModule],
    controllers: [FriendController],
    providers: [FriendService],
    exports: [FriendService],
})
export class FriendModule { }