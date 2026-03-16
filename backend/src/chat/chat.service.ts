import { Inject, Injectable } from '@nestjs/common';
import type { Database } from 'src/database/database.types';
import { Message } from './message.entity';
import { Conversation } from './conversations.entity';
import { User } from '../users/users.entity';

@Injectable()
export class ChatService {
  constructor(
    @Inject('POSTGRES_POOL')
    private readonly sql: Database,
  ) {}

  async createMessage(conversationId: number, senderId: string, content: string): Promise<Message> {
    const data = await this.sql`
      insert into messages(conversation_id, sender_id, content)
      values(${conversationId}, ${senderId}, ${content})
      returning id, conversation_id as "conversationId", sender_id as "senderId", content, timestamp, is_read as "isRead"
    `;
    const messageData = data[0];

    // Get sender info
    const senderData = await this.sql`
      select id, username, type_login, avartar_url, rating, total_matches, total_wins, total_draws, total_losses
      from users
      where id = ${senderId}
      limit 1
    `;
    const sender = senderData[0] as User;

    // Update conversation last message
    await this.sql`
      update conversations
      set last_message_id = ${messageData.id}, updated_at = now()
      where id = ${conversationId}
    `;

    return {
      ...messageData,
      id: messageData.id.toString(),
      conversationId: messageData.conversationId.toString(),
      sender,
      timestamp: new Date(messageData.timestamp),
    } as Message;
  }

  async getRecentMessages(conversationId: string, limit: number = 50): Promise<Message[]> {
    const convId = parseInt(conversationId);
    const data = await this.sql`
      select m.id, m.conversation_id as "conversationId", m.sender_id as "senderId", m.content, m.timestamp, m.is_read as "isRead",
             u.id as "sender.id", u.username as "sender.username", u.type_login as "sender.type_login", u.avartar_url as "sender.avartar_url",
             u.rating as "sender.rating", u.total_matches as "sender.total_matches", u.total_wins as "sender.total_wins",
             u.total_draws as "sender.total_draws", u.total_losses as "sender.total_losses"
      from messages m
      join users u on m.sender_id = u.id
      where m.conversation_id = ${convId}
      order by m.timestamp desc
      limit ${limit}
    `;
    return data.map(row => ({
      id: row.id.toString(),
      conversationId: row.conversationId.toString(),
      senderId: row.senderId,
      content: row.content,
      timestamp: new Date(row.timestamp),
      isRead: row.isRead,
      sender: {
        id: row['sender.id'],
        username: row['sender.username'],
        type_login: row['sender.type_login'],
        avartar_url: row['sender.avartar_url'],
        rating: row['sender.rating'],
        total_matches: row['sender.total_matches'],
        total_wins: row['sender.total_wins'],
        total_draws: row['sender.total_draws'],
        total_losses: row['sender.total_losses'],
      } as User,
    })) as Message[];
  }

  async updateConversationLastMessage(conversationId: string, message: Message): Promise<void> {
    // Already handled in createMessage
  }

  async findConversationByParticipants(participants: string[]): Promise<Conversation | null> {
    if (participants.length !== 2) return null;
    const [user1, user2] = participants.sort(); // Sort to ensure consistent order

    const data = await this.sql`
      select c.id
      from conversations c
      where exists (
        select 1 from conversation_participants cp1 where cp1.conversation_id = c.id and cp1.user_id = ${user1}
      ) and exists (
        select 1 from conversation_participants cp2 where cp2.conversation_id = c.id and cp2.user_id = ${user2}
      ) and not exists (
        select 1 from conversation_participants cp3 where cp3.conversation_id = c.id and cp3.user_id not in (${user1}, ${user2})
      )
      limit 1
    `;

    if (data.length === 0) return null;

    // Return full conversation
    return (await this.getUserConversations(user1)).find(c => c.id === data[0].id.toString()) || null;
  }

  async createConversation(participants: string[]): Promise<Conversation> {
    // Insert conversation
    const convData = await this.sql`
      insert into conversations(updated_at)
      values(now())
      returning id
    `;
    const convId = convData[0].id;

    // Insert participants
    for (const userId of participants) {
      await this.sql`
        insert into conversation_participants(conversation_id, user_id)
        values(${convId}, ${userId})
      `;
    }

    // Return the conversation (will be empty initially)
    return {
      id: convId.toString(),
      participants: [], // Will be populated when fetched
      message: [],
      lastMessage: {} as Message,
      unreadCount: 0,
      updateAt: new Date(),
    } as Conversation;
  }

  async getUserConversations(userId: string): Promise<Conversation[]> {
    console.log('getUserConversations called with userId:', userId);
    // Get conversations with participants and last message
    const data = await this.sql`
      select c.id, c.updated_at as "updateAt",
             lm.id as "lastMessage.id", lm.conversation_id as "lastMessage.conversationId", lm.sender_id as "lastMessage.senderId",
             lm.content as "lastMessage.content", lm.timestamp as "lastMessage.timestamp", lm.is_read as "lastMessage.isRead",
             lm_u.id as "lastMessage.sender.id", lm_u.username as "lastMessage.sender.username", lm_u.type_login as "lastMessage.sender.type_login",
             lm_u.avartar_url as "lastMessage.sender.avartar_url", lm_u.rating as "lastMessage.sender.rating",
             lm_u.total_matches as "lastMessage.sender.total_matches", lm_u.total_wins as "lastMessage.sender.total_wins",
             lm_u.total_draws as "lastMessage.sender.total_draws", lm_u.total_losses as "lastMessage.sender.total_losses",
             p.user_id as "participant.id", p_u.username as "participant.username", p_u.type_login as "participant.type_login",
             p_u.avartar_url as "participant.avartar_url", p_u.rating as "participant.rating",
             p_u.total_matches as "participant.total_matches", p_u.total_wins as "participant.total_wins",
             p_u.total_draws as "participant.total_draws", p_u.total_losses as "participant.total_losses"
      from conversations c
      left join messages lm on c.last_message_id = lm.id
      left join users lm_u on lm.sender_id = lm_u.id
      inner join conversation_participants cp on c.id = cp.conversation_id and cp.user_id = ${userId}
      inner join conversation_participants p on c.id = p.conversation_id
      inner join users p_u on p.user_id = p_u.id
      order by c.updated_at desc
    `;
    console.log('Raw data rows:', data.length);
    console.log('Conversation IDs:', data.map(row => row.id).join(', '));

    // Group by conversation
    const convMap = new Map();
    for (const row of data) {
      const convId = row.id;
      if (!convMap.has(convId)) {
        convMap.set(convId, {
          id: convId.toString(),
          participants: [],
          message: [],
          lastMessage: row['lastMessage.id'] ? {
            id: row['lastMessage.id'].toString(),
            conversationId: row['lastMessage.conversationId'].toString(),
            senderId: row['lastMessage.senderId'],
            content: row['lastMessage.content'],
            timestamp: new Date(row['lastMessage.timestamp']),
            isRead: row['lastMessage.isRead'],
            sender: {
              id: row['lastMessage.sender.id'],
              username: row['lastMessage.sender.username'],
              type_login: row['lastMessage.sender.type_login'],
              avartar_url: row['lastMessage.sender.avartar_url'],
              rating: row['lastMessage.sender.rating'],
              total_matches: row['lastMessage.sender.total_matches'],
              total_wins: row['lastMessage.sender.total_wins'],
              total_draws: row['lastMessage.sender.total_draws'],
              total_losses: row['lastMessage.sender.total_losses'],
            } as User,
          } : null,
          unreadCount: 0,
          updateAt: new Date(row.updateAt),
        });
      }
      // Add participant
      const participant = {
        id: row['participant.id'],
        username: row['participant.username'],
        type_login: row['participant.type_login'],
        avartar_url: row['participant.avartar_url'],
        rating: row['participant.rating'],
        total_matches: row['participant.total_matches'],
        total_wins: row['participant.total_wins'],
        total_draws: row['participant.total_draws'],
        total_losses: row['participant.total_losses'],
      } as User;
      if (!convMap.get(convId).participants.some((p: User) => p.id === participant.id)) {
        convMap.get(convId).participants.push(participant);
      }
    }

    return Array.from(convMap.values()) as Conversation[];
  }

  async getUserConversationsFormatted(userId: string): Promise<{ count: number; conversations: { id: string; participants: string[]; lastMessage: any; messages: any[] }[] }> {
    const conversations = await this.getUserConversations(userId);
    const formattedConversations = await Promise.all(conversations.map(async c => {
      const messages = await this.getMessages(c.id);
      return {
        id: c.id,
        participants: c.participants.map(p => p.username),
        lastMessage: c.lastMessage ? {
          id: c.lastMessage.id,
          senderId: c.lastMessage.senderId,
          content: c.lastMessage.content,
          timestamp: c.lastMessage.timestamp,
          isRead: c.lastMessage.isRead,
          sender: c.lastMessage.sender.username
        } : null,
        messages: messages.map(m => ({
          id: m.id,
          senderId: m.senderId,
          content: m.content,
          timestamp: m.timestamp,
          isRead: m.isRead,
          sender: m.sender.username
        }))
      };
    }));
    return {
      count: conversations.length,
      conversations: formattedConversations,
    };
  }

  async getMessages(conversationId: string): Promise<Message[]> {
    const convId = parseInt(conversationId);
    const data = await this.sql`
      select m.id, m.conversation_id as "conversationId", m.sender_id as "senderId", m.content, m.timestamp, m.is_read as "isRead",
             u.id as "sender.id", u.username as "sender.username", u.type_login as "sender.type_login", u.avartar_url as "sender.avartar_url",
             u.rating as "sender.rating", u.total_matches as "sender.total_matches", u.total_wins as "sender.total_wins",
             u.total_draws as "sender.total_draws", u.total_losses as "sender.total_losses"
      from messages m
      join users u on m.sender_id = u.id
      where m.conversation_id = ${convId}
      order by m.timestamp asc
    `;
    return data.map(row => ({
      id: row.id.toString(),
      conversationId: row.conversationId.toString(),
      senderId: row.senderId,
      content: row.content,
      timestamp: new Date(row.timestamp),
      isRead: row.isRead,
      sender: {
        id: row['sender.id'],
        username: row['sender.username'],
        type_login: row['sender.type_login'],
        avartar_url: row['sender.avartar_url'],
        rating: row['sender.rating'],
        total_matches: row['sender.total_matches'],
        total_wins: row['sender.total_wins'],
        total_draws: row['sender.total_draws'],
        total_losses: row['sender.total_losses'],
      } as User,
    })) as Message[];
  }
}