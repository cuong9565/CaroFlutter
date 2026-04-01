import { Inject, Injectable } from "@nestjs/common";
import { DatabaseModule } from "src/database/database.module";

@Injectable()
export class FriendService {
    constructor(
        @Inject('POSTGRES_POOL')
        private readonly sql: DatabaseModule
    ) { }

    // async function (params:type) {

    // }
}