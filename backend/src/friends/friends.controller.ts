import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { FriendService } from './friends.service';

@Controller('friends')
export class FriendController {
	constructor(private readonly friendService: FriendService) {}

	// /friends/request-by-uuid
	@Post('/request-by-uuid')
	async requestByUuid(
		@Body('requesterId') requesterId: string,
		@Body('targetUuid') targetUuid: string,
	) {
		const friend = await this.friendService.requestByUuid(
			requesterId,
			targetUuid,
		);
		return { friend };
	}

	// /friends/list/:userId
	@Get('/list/:userId')
	async listFriends(@Param('userId') userId: string) {
		const friends = await this.friendService.listFriends(userId);
		return { friends };
	}

	// /friends/requests/:userId
	@Get('/requests/:userId')
	async listFriendRequests(@Param('userId') userId: string) {
		const requests = await this.friendService.listFriendRequests(userId);
		return { requests };
	}

	// /friends/accept
	@Post('/accept')
	async acceptRequest(
		@Body('friendRecordId') friendRecordId: string,
		@Body('userId') userId: string,
	) {
		const friend = await this.friendService.acceptRequest(
			friendRecordId,
			userId,
		);
		return { friend };
	}

	// /friends/reject
	@Post('/reject')
	async rejectRequest(
		@Body('friendRecordId') friendRecordId: string,
		@Body('userId') userId: string,
	) {
		const friend = await this.friendService.rejectRequest(
			friendRecordId,
			userId,
		);
		return { friend };
	}

	// /friends/remove
	@Post('/remove')
	async removeFriend(
		@Body('friendRecordId') friendRecordId: string,
		@Body('userId') userId: string,
	) {
		const friend = await this.friendService.removeFriend(
			friendRecordId,
			userId,
		);
		return { friend };
	}
}