CREATE SCHEMA "public";
CREATE TABLE "conversation_participants" (
	"conversation_id" integer,
	"user_id" uuid,
	CONSTRAINT "conversation_participants_pkey" PRIMARY KEY("conversation_id","user_id")
);
CREATE TABLE "conversations" (
	"id" serial PRIMARY KEY,
	"updated_at" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"last_message_id" integer
);
CREATE TABLE "friends" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"iduser_request" uuid NOT NULL,
	"iduser_response" uuid NOT NULL,
	"status" varchar(255) DEFAULT 'pending' NOT NULL,
	CONSTRAINT "friends_status_check" CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'accepted'::character varying, 'blocked'::character varying])::text[])))
);
CREATE TABLE "login_by_email" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"iduser" uuid NOT NULL,
	"email" varchar(255) NOT NULL,
	"hash_password" varchar(255) NOT NULL
);
CREATE TABLE "login_by_gg" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"iduser" uuid NOT NULL,
	"email" varchar(255) NOT NULL
);
CREATE TABLE "match" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"id_matches_player" uuid NOT NULL,
	"time_create" timestamp with time zone DEFAULT now() NOT NULL,
	"winner_id" uuid,
	"is_draw" boolean DEFAULT false,
	"is_ai_win" boolean DEFAULT false
);
CREATE TABLE "matches_player" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"iduser_request" uuid NOT NULL,
	"iduser_response" uuid,
	"is_ranking" boolean NOT NULL,
	"time_create" timestamp DEFAULT now() NOT NULL,
	"game_mode" varchar(255) DEFAULT 'FRIEND' NOT NULL,
	CONSTRAINT "matches_player_game_mode_check" CHECK (((game_mode)::text = ANY ((ARRAY['FRIEND'::character varying, 'AI'::character varying, 'ONLINE'::character varying])::text[])))
);
CREATE TABLE "messages" (
	"id" serial PRIMARY KEY,
	"conversation_id" integer NOT NULL,
	"sender_id" uuid NOT NULL,
	"content" text NOT NULL,
	"timestamp" timestamp NOT NULL,
	"is_read" boolean DEFAULT false NOT NULL
);
CREATE TABLE "users" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"username" varchar(255) NOT NULL,
	"type_login" integer DEFAULT 0 NOT NULL,
	"avatar_url" text,
	"rating" numeric(8, 2) DEFAULT '0' NOT NULL,
	"total_matches" integer DEFAULT 0 NOT NULL,
	"total_wins" integer DEFAULT 0 NOT NULL,
	"total_draws" integer DEFAULT 0 NOT NULL,
	"total_losses" integer DEFAULT 0 NOT NULL
);
CREATE UNIQUE INDEX "conversation_participants_pkey" ON "conversation_participants" ("conversation_id","user_id");
CREATE INDEX "idx_cp_conversation_id" ON "conversation_participants" ("conversation_id");
CREATE INDEX "idx_cp_user_id" ON "conversation_participants" ("user_id");
CREATE UNIQUE INDEX "conversations_pkey" ON "conversations" ("id");
CREATE INDEX "idx_conversations_last_message_id" ON "conversations" ("last_message_id");
CREATE INDEX "idx_conversations_updated_at" ON "conversations" ("updated_at");
CREATE UNIQUE INDEX "friends_pkey" ON "friends" ("id");
CREATE UNIQUE INDEX "login_by_email_pkey" ON "login_by_email" ("id");
CREATE UNIQUE INDEX "login_by_gg_pkey" ON "login_by_gg" ("id");
CREATE UNIQUE INDEX "match_pkey" ON "match" ("id");
CREATE UNIQUE INDEX "matches_player_pkey" ON "matches_player" ("id");
CREATE INDEX "idx_messages_conversation_id" ON "messages" ("conversation_id");
CREATE INDEX "idx_messages_is_read" ON "messages" ("is_read");
CREATE INDEX "idx_messages_sender_id" ON "messages" ("sender_id");
CREATE INDEX "idx_messages_timestamp" ON "messages" ("timestamp");
CREATE UNIQUE INDEX "messages_pkey" ON "messages" ("id");
CREATE UNIQUE INDEX "users_pkey" ON "users" ("id");
ALTER TABLE "conversation_participants" ADD CONSTRAINT "fk_cp_conversation" FOREIGN KEY ("conversation_id") REFERENCES "conversations"("id") ON DELETE CASCADE;
ALTER TABLE "conversation_participants" ADD CONSTRAINT "fk_cp_user" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE;
ALTER TABLE "friends" ADD CONSTRAINT "friends_iduser_request_foreign" FOREIGN KEY ("iduser_request") REFERENCES "users"("id");
ALTER TABLE "friends" ADD CONSTRAINT "friends_iduser_response_foreign" FOREIGN KEY ("iduser_response") REFERENCES "users"("id");
ALTER TABLE "match" ADD CONSTRAINT "match_id_matches_player_fkey" FOREIGN KEY ("id_matches_player") REFERENCES "matches_player"("id");
ALTER TABLE "match" ADD CONSTRAINT "match_id_matches_player_foreign" FOREIGN KEY ("id_matches_player") REFERENCES "matches_player"("id");
ALTER TABLE "match" ADD CONSTRAINT "match_winner_id_fkey" FOREIGN KEY ("winner_id") REFERENCES "users"("id");
ALTER TABLE "matches_player" ADD CONSTRAINT "matches_player_iduser_request_foreign" FOREIGN KEY ("iduser_request") REFERENCES "users"("id");
ALTER TABLE "matches_player" ADD CONSTRAINT "matches_player_iduser_response_foreign" FOREIGN KEY ("iduser_response") REFERENCES "users"("id");
ALTER TABLE "messages" ADD CONSTRAINT "fk_messages_conversation" FOREIGN KEY ("conversation_id") REFERENCES "conversations"("id") ON DELETE CASCADE;
ALTER TABLE "messages" ADD CONSTRAINT "fk_messages_sender" FOREIGN KEY ("sender_id") REFERENCES "users"("id") ON DELETE CASCADE;