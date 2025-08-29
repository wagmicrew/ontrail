CREATE TABLE "comments" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"post_id" uuid NOT NULL,
	"author_id" uuid NOT NULL,
	"content" text NOT NULL,
	"like_count" integer DEFAULT 0,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "follows" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"follower_id" uuid NOT NULL,
	"following_id" uuid NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "friendships" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"requester_id" uuid NOT NULL,
	"addressee_id" uuid NOT NULL,
	"status" text DEFAULT 'pending' NOT NULL,
	"is_tokenized" boolean DEFAULT false,
	"friendship_token_address" text,
	"friendship_token_supply" integer DEFAULT 0,
	"friendship_value" numeric(18, 4) DEFAULT '0',
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "poi_visits" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"poi_id" uuid NOT NULL,
	"visitor_id" uuid NOT NULL,
	"visit_date" timestamp DEFAULT now() NOT NULL,
	"duration" integer,
	"steps_at_poi" integer,
	"notes" text,
	"rating" integer,
	"images" jsonb,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "pois" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" text NOT NULL,
	"description" text,
	"latitude" numeric(10, 8) NOT NULL,
	"longitude" numeric(11, 8) NOT NULL,
	"creator_id" uuid,
	"owner_id" uuid,
	"category" text,
	"difficulty" text,
	"elevation" integer,
	"is_nft" boolean DEFAULT false,
	"nft_address" text,
	"nft_metadata" jsonb,
	"visit_count" integer DEFAULT 0,
	"like_count" integer DEFAULT 0,
	"rating" numeric(3, 2) DEFAULT '0',
	"images" jsonb,
	"is_verified" boolean DEFAULT false,
	"is_active" boolean DEFAULT true,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "post_likes" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"post_id" uuid NOT NULL,
	"liker_id" uuid NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "posts" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"author_id" uuid NOT NULL,
	"content" text,
	"type" text DEFAULT 'text' NOT NULL,
	"images" jsonb,
	"route_data" jsonb,
	"poi_data" jsonb,
	"health_data" jsonb,
	"is_public" boolean DEFAULT true,
	"is_friends_only" boolean DEFAULT false,
	"like_count" integer DEFAULT 0,
	"comment_count" integer DEFAULT 0,
	"share_count" integer DEFAULT 0,
	"latitude" numeric(10, 8),
	"longitude" numeric(11, 8),
	"location_name" text,
	"engagement_score" numeric(5, 2) DEFAULT '0',
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "profiles" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"total_steps" integer DEFAULT 0,
	"quests_completed" integer DEFAULT 0,
	"solana_collected" numeric(18, 9) DEFAULT '0',
	"og_following" integer DEFAULT 0,
	"high_value_followers" integer DEFAULT 0,
	"high_value_friends" integer DEFAULT 0,
	"owned_poi_nfts" integer DEFAULT 0,
	"visited_pois" integer DEFAULT 0,
	"poi_value_added" integer DEFAULT 0,
	"has_graduated" boolean DEFAULT false,
	"profile_valuation" numeric(18, 4) DEFAULT '0',
	"token_address" text,
	"token_launch_date" timestamp,
	"wallet_address" text,
	"wallet_created" boolean DEFAULT false,
	"is_public" boolean DEFAULT true,
	"allow_friend_requests" boolean DEFAULT true,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "quest_participants" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"quest_id" uuid NOT NULL,
	"participant_id" uuid NOT NULL,
	"joined_at" timestamp DEFAULT now() NOT NULL,
	"completed_at" timestamp,
	"progress" jsonb,
	"is_winner" boolean DEFAULT false,
	"reward_claimed" boolean DEFAULT false,
	"reward_tx_hash" text
);
--> statement-breakpoint
CREATE TABLE "quests" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"title" text NOT NULL,
	"description" text NOT NULL,
	"type" text NOT NULL,
	"category" text,
	"requirements" jsonb NOT NULL,
	"rewards" jsonb NOT NULL,
	"is_active" boolean DEFAULT true,
	"start_date" timestamp,
	"end_date" timestamp,
	"max_participants" integer,
	"tier" text,
	"min_friend_count" integer DEFAULT 0,
	"max_friend_count" integer,
	"creator_id" uuid,
	"sponsor_id" uuid,
	"sponsor_name" text,
	"sponsor_website" text,
	"is_sponsored" boolean DEFAULT false,
	"donation_goal" numeric(18, 9),
	"current_donations" numeric(18, 9) DEFAULT '0',
	"participant_count" integer DEFAULT 0,
	"completion_count" integer DEFAULT 0,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "transactions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"wallet_id" uuid NOT NULL,
	"signature" text NOT NULL,
	"type" text NOT NULL,
	"amount" numeric(18, 9),
	"token_address" text,
	"to_address" text,
	"fee" numeric(18, 9),
	"status" text DEFAULT 'pending' NOT NULL,
	"block_time" timestamp,
	"metadata" jsonb,
	"created_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "transactions_signature_unique" UNIQUE("signature")
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"email" text NOT NULL,
	"name" text,
	"image" text,
	"email_verified" timestamp,
	"google_id" text,
	"facebook_id" text,
	"username" text,
	"profile_name" text,
	"is_premium" boolean DEFAULT false,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "users_email_unique" UNIQUE("email"),
	CONSTRAINT "users_google_id_unique" UNIQUE("google_id"),
	CONSTRAINT "users_facebook_id_unique" UNIQUE("facebook_id"),
	CONSTRAINT "users_username_unique" UNIQUE("username")
);
--> statement-breakpoint
CREATE TABLE "wallets" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"profile_id" uuid NOT NULL,
	"address" text NOT NULL,
	"encrypted_private_key" text,
	"is_managed" boolean DEFAULT true,
	"balance" numeric(18, 9) DEFAULT '0',
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "wallets_address_unique" UNIQUE("address")
);
--> statement-breakpoint
ALTER TABLE "comments" ADD CONSTRAINT "comments_post_id_posts_id_fk" FOREIGN KEY ("post_id") REFERENCES "public"."posts"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "comments" ADD CONSTRAINT "comments_author_id_profiles_id_fk" FOREIGN KEY ("author_id") REFERENCES "public"."profiles"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "follows" ADD CONSTRAINT "follows_follower_id_profiles_id_fk" FOREIGN KEY ("follower_id") REFERENCES "public"."profiles"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "follows" ADD CONSTRAINT "follows_following_id_profiles_id_fk" FOREIGN KEY ("following_id") REFERENCES "public"."profiles"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "friendships" ADD CONSTRAINT "friendships_requester_id_profiles_id_fk" FOREIGN KEY ("requester_id") REFERENCES "public"."profiles"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "friendships" ADD CONSTRAINT "friendships_addressee_id_profiles_id_fk" FOREIGN KEY ("addressee_id") REFERENCES "public"."profiles"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "poi_visits" ADD CONSTRAINT "poi_visits_poi_id_pois_id_fk" FOREIGN KEY ("poi_id") REFERENCES "public"."pois"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "poi_visits" ADD CONSTRAINT "poi_visits_visitor_id_profiles_id_fk" FOREIGN KEY ("visitor_id") REFERENCES "public"."profiles"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "pois" ADD CONSTRAINT "pois_creator_id_profiles_id_fk" FOREIGN KEY ("creator_id") REFERENCES "public"."profiles"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "pois" ADD CONSTRAINT "pois_owner_id_profiles_id_fk" FOREIGN KEY ("owner_id") REFERENCES "public"."profiles"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "post_likes" ADD CONSTRAINT "post_likes_post_id_posts_id_fk" FOREIGN KEY ("post_id") REFERENCES "public"."posts"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "post_likes" ADD CONSTRAINT "post_likes_liker_id_profiles_id_fk" FOREIGN KEY ("liker_id") REFERENCES "public"."profiles"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "posts" ADD CONSTRAINT "posts_author_id_profiles_id_fk" FOREIGN KEY ("author_id") REFERENCES "public"."profiles"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "profiles" ADD CONSTRAINT "profiles_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quest_participants" ADD CONSTRAINT "quest_participants_quest_id_quests_id_fk" FOREIGN KEY ("quest_id") REFERENCES "public"."quests"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quest_participants" ADD CONSTRAINT "quest_participants_participant_id_profiles_id_fk" FOREIGN KEY ("participant_id") REFERENCES "public"."profiles"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quests" ADD CONSTRAINT "quests_creator_id_profiles_id_fk" FOREIGN KEY ("creator_id") REFERENCES "public"."profiles"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quests" ADD CONSTRAINT "quests_sponsor_id_users_id_fk" FOREIGN KEY ("sponsor_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "transactions" ADD CONSTRAINT "transactions_wallet_id_wallets_id_fk" FOREIGN KEY ("wallet_id") REFERENCES "public"."wallets"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "wallets" ADD CONSTRAINT "wallets_profile_id_profiles_id_fk" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "comments_post_idx" ON "comments" USING btree ("post_id");--> statement-breakpoint
CREATE INDEX "comments_author_idx" ON "comments" USING btree ("author_id");--> statement-breakpoint
CREATE INDEX "comments_created_at_idx" ON "comments" USING btree ("created_at");--> statement-breakpoint
CREATE INDEX "follows_follower_idx" ON "follows" USING btree ("follower_id");--> statement-breakpoint
CREATE INDEX "follows_following_idx" ON "follows" USING btree ("following_id");--> statement-breakpoint
CREATE INDEX "follows_unique_idx" ON "follows" USING btree ("follower_id","following_id");--> statement-breakpoint
CREATE INDEX "friendships_requester_idx" ON "friendships" USING btree ("requester_id");--> statement-breakpoint
CREATE INDEX "friendships_addressee_idx" ON "friendships" USING btree ("addressee_id");--> statement-breakpoint
CREATE INDEX "friendships_status_idx" ON "friendships" USING btree ("status");--> statement-breakpoint
CREATE INDEX "poi_visits_poi_idx" ON "poi_visits" USING btree ("poi_id");--> statement-breakpoint
CREATE INDEX "poi_visits_visitor_idx" ON "poi_visits" USING btree ("visitor_id");--> statement-breakpoint
CREATE INDEX "poi_visits_date_idx" ON "poi_visits" USING btree ("visit_date");--> statement-breakpoint
CREATE INDEX "pois_location_idx" ON "pois" USING btree ("latitude","longitude");--> statement-breakpoint
CREATE INDEX "pois_creator_idx" ON "pois" USING btree ("creator_id");--> statement-breakpoint
CREATE INDEX "pois_category_idx" ON "pois" USING btree ("category");--> statement-breakpoint
CREATE INDEX "post_likes_post_idx" ON "post_likes" USING btree ("post_id");--> statement-breakpoint
CREATE INDEX "post_likes_liker_idx" ON "post_likes" USING btree ("liker_id");--> statement-breakpoint
CREATE INDEX "post_likes_unique_idx" ON "post_likes" USING btree ("post_id","liker_id");--> statement-breakpoint
CREATE INDEX "posts_author_idx" ON "posts" USING btree ("author_id");--> statement-breakpoint
CREATE INDEX "posts_type_idx" ON "posts" USING btree ("type");--> statement-breakpoint
CREATE INDEX "posts_public_idx" ON "posts" USING btree ("is_public");--> statement-breakpoint
CREATE INDEX "posts_created_at_idx" ON "posts" USING btree ("created_at");--> statement-breakpoint
CREATE INDEX "posts_location_idx" ON "posts" USING btree ("latitude","longitude");--> statement-breakpoint
CREATE INDEX "profiles_user_id_idx" ON "profiles" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "profiles_valuation_idx" ON "profiles" USING btree ("profile_valuation");--> statement-breakpoint
CREATE INDEX "profiles_token_address_idx" ON "profiles" USING btree ("token_address");--> statement-breakpoint
CREATE INDEX "quest_participants_quest_idx" ON "quest_participants" USING btree ("quest_id");--> statement-breakpoint
CREATE INDEX "quest_participants_participant_idx" ON "quest_participants" USING btree ("participant_id");--> statement-breakpoint
CREATE INDEX "quest_participants_completed_idx" ON "quest_participants" USING btree ("completed_at");--> statement-breakpoint
CREATE INDEX "quests_type_idx" ON "quests" USING btree ("type");--> statement-breakpoint
CREATE INDEX "quests_category_idx" ON "quests" USING btree ("category");--> statement-breakpoint
CREATE INDEX "quests_active_idx" ON "quests" USING btree ("is_active");--> statement-breakpoint
CREATE INDEX "quests_end_date_idx" ON "quests" USING btree ("end_date");--> statement-breakpoint
CREATE INDEX "transactions_wallet_idx" ON "transactions" USING btree ("wallet_id");--> statement-breakpoint
CREATE INDEX "transactions_signature_idx" ON "transactions" USING btree ("signature");--> statement-breakpoint
CREATE INDEX "transactions_type_idx" ON "transactions" USING btree ("type");--> statement-breakpoint
CREATE INDEX "transactions_status_idx" ON "transactions" USING btree ("status");--> statement-breakpoint
CREATE INDEX "users_email_idx" ON "users" USING btree ("email");--> statement-breakpoint
CREATE INDEX "users_username_idx" ON "users" USING btree ("username");--> statement-breakpoint
CREATE INDEX "wallets_profile_idx" ON "wallets" USING btree ("profile_id");--> statement-breakpoint
CREATE INDEX "wallets_address_idx" ON "wallets" USING btree ("address");