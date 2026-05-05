import { Module } from "@nestjs/common";
import { DatabaseModule } from "src/database/database.module";
import { FriendController } from "./friends.controller";
import { FriendService } from "./friends.service";
import { GameModule } from "src/game/game.module";

@Module({
    imports: [DatabaseModule, GameModule],
    controllers: [FriendController],
    providers: [FriendService],
    exports: [FriendService],
})
export class FriendModule { }