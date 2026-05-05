import {
    BadRequestException,
    Inject,
    Injectable,
    NotFoundException,
} from '@nestjs/common';
import type { Database } from 'src/database/database.types';

@Injectable()
export class FriendService {
    constructor(
        @Inject('POSTGRES_POOL')
        private readonly sql: Database
    ) { }

    async requestByUuid(requesterId: string, targetUuid: string) {
        if (!requesterId || !targetUuid) {
            throw new BadRequestException('Missing requesterId or targetUuid');
        }
        if (requesterId === targetUuid) {
            throw new BadRequestException('Cannot add yourself as a friend');
        }

        const requester = await this.sql`
      select id from users where id = ${requesterId} limit 1
    `;
        if (!requester[0]) {
            throw new NotFoundException('Requester not found');
        }

        const target = await this.sql`
      select id from users where id = ${targetUuid} limit 1
    `;
        if (!target[0]) {
            throw new NotFoundException('Target user not found');
        }

        const existing = await this.sql`
      select * from friends
      where (iduser_request = ${requesterId} and iduser_response = ${targetUuid})
         or (iduser_request = ${targetUuid} and iduser_response = ${requesterId})
      limit 1
    `;
        if (existing[0]) {
            throw new BadRequestException('Friend request already exists');
        }

        const created = await this.sql`
      insert into friends(iduser_request, iduser_response, status)
      values(${requesterId}, ${targetUuid}, 'pending')
      returning *
    `;

        return created[0] ?? null;
    }

        async listFriends(userId: string) {
                if (!userId) {
                        throw new BadRequestException('Missing userId');
                }

                const friends = await this.sql`
            select
                f.id as friend_record_id,
                f.status,
                case when f.iduser_request = ${userId} then u2.id else u1.id end as friend_id,
                case when f.iduser_request = ${userId} then u2.username else u1.username end as username,
                case when f.iduser_request = ${userId} then u2.avatar_url else u1.avatar_url end as avatar_url,
                case when f.iduser_request = ${userId} then u2.rating else u1.rating end as rating,
                case when f.iduser_request = ${userId} then u2.total_matches else u1.total_matches end as total_matches,
                case when f.iduser_request = ${userId} then u2.total_wins else u1.total_wins end as total_wins,
                case when f.iduser_request = ${userId} then u2.total_draws else u1.total_draws end as total_draws,
                case when f.iduser_request = ${userId} then u2.total_losses else u1.total_losses end as total_losses
            from friends f
            join users u1 on u1.id = f.iduser_request
            join users u2 on u2.id = f.iduser_response
            where (f.iduser_request = ${userId} or f.iduser_response = ${userId})
                and f.status = 'accepted'
            order by username
        `;

                return friends;
        }

        async listFriendRequests(userId: string) {
                if (!userId) {
                        throw new BadRequestException('Missing userId');
                }

                const requests = await this.sql`
            select
                f.id as friend_record_id,
                f.status,
                u.id as requester_id,
                u.username,
                u.avatar_url,
                u.rating,
                u.total_matches,
                u.total_wins,
                u.total_draws,
                u.total_losses
            from friends f
            join users u on u.id = f.iduser_request
            where f.iduser_response = ${userId}
                and f.status = 'pending'
            order by f.id
        `;

                return requests;
        }

        async acceptRequest(friendRecordId: string, userId: string) {
                if (!friendRecordId || !userId) {
                        throw new BadRequestException('Missing friendRecordId or userId');
                }

                const updated = await this.sql`
            update friends
            set status = 'accepted'
            where id = ${friendRecordId}
                and iduser_response = ${userId}
                and status = 'pending'
            returning *
        `;

                if (!updated[0]) {
                        throw new NotFoundException('Friend request not found');
                }

                return updated[0];
        }

        async rejectRequest(friendRecordId: string, userId: string) {
                if (!friendRecordId || !userId) {
                        throw new BadRequestException('Missing friendRecordId or userId');
                }

                const updated = await this.sql`
            update friends
            set status = 'blocked'
            where id = ${friendRecordId}
                and iduser_response = ${userId}
                and status = 'pending'
            returning *
        `;

                if (!updated[0]) {
                        throw new NotFoundException('Friend request not found');
                }

                return updated[0];
        }

            async removeFriend(friendRecordId: string, userId: string) {
                if (!friendRecordId || !userId) {
                    throw new BadRequestException('Missing friendRecordId or userId');
                }

                const removed = await this.sql`
                delete from friends
                where id = ${friendRecordId}
                and (iduser_request = ${userId} or iduser_response = ${userId})
                and status = 'accepted'
                returning *
            `;

                if (!removed[0]) {
                    throw new NotFoundException('Friend record not found');
                }

                return removed[0];
            }
}