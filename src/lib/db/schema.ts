import { pgTable, uuid, text, timestamp, boolean, integer, decimal, jsonb, index } from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';

// Users table (extends NextAuth.js users)
export const users = pgTable('users', {
  id: uuid('id').primaryKey().defaultRandom(),
  email: text('email').unique().notNull(),
  name: text('name'),
  image: text('image'),
  emailVerified: timestamp('email_verified', { mode: 'date' }),
  // Social login providers
  googleId: text('google_id').unique(),
  facebookId: text('facebook_id').unique(),
  // Profile data
  username: text('username').unique(),
  profileName: text('profile_name'),
  isPremium: boolean('is_premium').default(false),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
}, (table) => ({
  emailIdx: index('users_email_idx').on(table.email),
  usernameIdx: index('users_username_idx').on(table.username),
}));

// Profiles table (extended user profile with social-fi features)
export const profiles = pgTable('profiles', {
  id: uuid('id').primaryKey().defaultRandom(),
  userId: uuid('user_id').references(() => users.id, { onDelete: 'cascade' }).notNull(),
  // Profile valuation algorithm fields
  totalSteps: integer('total_steps').default(0),
  questsCompleted: integer('quests_completed').default(0),
  solanaCollected: decimal('solana_collected', { precision: 18, scale: 9 }).default('0'),
  ogFollowing: integer('og_following').default(0),
  highValueFollowers: integer('high_value_followers').default(0),
  highValueFriends: integer('high_value_friends').default(0),
  ownedPoiNfts: integer('owned_poi_nfts').default(0),
  visitedPois: integer('visited_pois').default(0),
  poiValueAdded: integer('poi_value_added').default(0),
  // Profile status
  hasGraduated: boolean('has_graduated').default(false),
  profileValuation: decimal('profile_valuation', { precision: 18, scale: 4 }).default('0'),
  // Token launch data
  tokenAddress: text('token_address'),
  tokenLaunchDate: timestamp('token_launch_date'),
  // Wallet information
  walletAddress: text('wallet_address'),
  walletCreated: boolean('wallet_created').default(false),
  // Profile settings
  isPublic: boolean('is_public').default(true),
  allowFriendRequests: boolean('allow_friend_requests').default(true),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
}, (table) => ({
  userIdIdx: index('profiles_user_id_idx').on(table.userId),
  valuationIdx: index('profiles_valuation_idx').on(table.profileValuation),
  tokenAddressIdx: index('profiles_token_address_idx').on(table.tokenAddress),
}));

// Friendships table (tokenized friendships)
export const friendships = pgTable('friendships', {
  id: uuid('id').primaryKey().defaultRandom(),
  requesterId: uuid('requester_id').references(() => profiles.id).notNull(),
  addresseeId: uuid('addressee_id').references(() => profiles.id).notNull(),
  status: text('status').notNull().default('pending'), // pending, accepted, rejected, blocked
  // Friendship token data
  isTokenized: boolean('is_tokenized').default(false),
  friendshipTokenAddress: text('friendship_token_address'),
  friendshipTokenSupply: integer('friendship_token_supply').default(0),
  friendshipValue: decimal('friendship_value', { precision: 18, scale: 4 }).default('0'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
}, (table) => ({
  requesterIdx: index('friendships_requester_idx').on(table.requesterId),
  addresseeIdx: index('friendships_addressee_idx').on(table.addresseeId),
  statusIdx: index('friendships_status_idx').on(table.status),
}));

// Points of Interest (POI) table
export const pois = pgTable('pois', {
  id: uuid('id').primaryKey().defaultRandom(),
  name: text('name').notNull(),
  description: text('description'),
  latitude: decimal('latitude', { precision: 10, scale: 8 }).notNull(),
  longitude: decimal('longitude', { precision: 11, scale: 8 }).notNull(),
  // POI creator and ownership
  creatorId: uuid('creator_id').references(() => profiles.id),
  ownerId: uuid('owner_id').references(() => profiles.id),
  // POI data
  category: text('category'), // trail, viewpoint, water, camping, etc.
  difficulty: text('difficulty'), // easy, moderate, hard
  elevation: integer('elevation'), // in meters
  // NFT data
  isNft: boolean('is_nft').default(false),
  nftAddress: text('nft_address'),
  nftMetadata: jsonb('nft_metadata'),
  // Social features
  visitCount: integer('visit_count').default(0),
  likeCount: integer('like_count').default(0),
  rating: decimal('rating', { precision: 3, scale: 2 }).default('0'),
  // Media
  images: jsonb('images'), // array of image URLs/metadata
  // Status
  isVerified: boolean('is_verified').default(false),
  isActive: boolean('is_active').default(true),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
}, (table) => ({
  locationIdx: index('pois_location_idx').on(table.latitude, table.longitude),
  creatorIdx: index('pois_creator_idx').on(table.creatorId),
  categoryIdx: index('pois_category_idx').on(table.category),
}));

// POI Visits table
export const poiVisits = pgTable('poi_visits', {
  id: uuid('id').primaryKey().defaultRandom(),
  poiId: uuid('poi_id').references(() => pois.id, { onDelete: 'cascade' }).notNull(),
  visitorId: uuid('visitor_id').references(() => profiles.id).notNull(),
  visitDate: timestamp('visit_date').defaultNow().notNull(),
  duration: integer('duration'), // in minutes
  stepsAtPoi: integer('steps_at_poi'),
  notes: text('notes'),
  rating: integer('rating'), // 1-5 stars
  images: jsonb('images'), // photos taken at POI
  createdAt: timestamp('created_at').defaultNow().notNull(),
}, (table) => ({
  poiIdx: index('poi_visits_poi_idx').on(table.poiId),
  visitorIdx: index('poi_visits_visitor_idx').on(table.visitorId),
  visitDateIdx: index('poi_visits_date_idx').on(table.visitDate),
}));

// Quests table
export const quests = pgTable('quests', {
  id: uuid('id').primaryKey().defaultRandom(),
  title: text('title').notNull(),
  description: text('description').notNull(),
  type: text('type').notNull(), // individual, friendly, poi, time_based
  category: text('category'), // steps, distance, poi_visit, social, etc.
  // Quest requirements
  requirements: jsonb('requirements').notNull(), // flexible JSON for different quest types
  // Rewards
  rewards: jsonb('rewards').notNull(), // SOL, tokens, NFTs, etc.
  // Quest settings
  isActive: boolean('is_active').default(true),
  startDate: timestamp('start_date'),
  endDate: timestamp('end_date'),
  maxParticipants: integer('max_participants'),
  // Quest tiers for friendly quests
  tier: text('tier'), // low, mid, high (friend count tiers)
  minFriendCount: integer('min_friend_count').default(0),
  maxFriendCount: integer('max_friend_count'),
  // Creator and sponsorship
  creatorId: uuid('creator_id').references(() => profiles.id),
  sponsorId: uuid('sponsor_id').references(() => users.id), // for sponsored quests
  sponsorName: text('sponsor_name'),
  sponsorWebsite: text('sponsor_website'),
  // Donation/sponsorship info
  isSponsored: boolean('is_sponsored').default(false),
  donationGoal: decimal('donation_goal', { precision: 18, scale: 9 }),
  currentDonations: decimal('current_donations', { precision: 18, scale: 9 }).default('0'),
  // Quest statistics
  participantCount: integer('participant_count').default(0),
  completionCount: integer('completion_count').default(0),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
}, (table) => ({
  typeIdx: index('quests_type_idx').on(table.type),
  categoryIdx: index('quests_category_idx').on(table.category),
  activeIdx: index('quests_active_idx').on(table.isActive),
  endDateIdx: index('quests_end_date_idx').on(table.endDate),
}));

// Quest Participants table
export const questParticipants = pgTable('quest_participants', {
  id: uuid('id').primaryKey().defaultRandom(),
  questId: uuid('quest_id').references(() => quests.id, { onDelete: 'cascade' }).notNull(),
  participantId: uuid('participant_id').references(() => profiles.id).notNull(),
  joinedAt: timestamp('joined_at').defaultNow().notNull(),
  completedAt: timestamp('completed_at'),
  progress: jsonb('progress'), // quest-specific progress data
  isWinner: boolean('is_winner').default(false),
  rewardClaimed: boolean('reward_claimed').default(false),
  rewardTxHash: text('reward_tx_hash'),
}, (table) => ({
  questIdx: index('quest_participants_quest_idx').on(table.questId),
  participantIdx: index('quest_participants_participant_idx').on(table.participantId),
  completedIdx: index('quest_participants_completed_idx').on(table.completedAt),
}));

// Posts/Timeline table
export const posts = pgTable('posts', {
  id: uuid('id').primaryKey().defaultRandom(),
  authorId: uuid('author_id').references(() => profiles.id).notNull(),
  content: text('content'),
  // Post types
  type: text('type').notNull().default('text'), // text, route, poi, photo, health_data
  // Media content
  images: jsonb('images'),
  routeData: jsonb('route_data'), // GPS coordinates, distance, elevation
  poiData: jsonb('poi_data'), // linked POI information
  healthData: jsonb('health_data'), // steps, distance, calories from health apps
  // Social features
  isPublic: boolean('is_public').default(true),
  isFriendsOnly: boolean('is_friends_only').default(false),
  likeCount: integer('like_count').default(0),
  commentCount: integer('comment_count').default(0),
  shareCount: integer('share_count').default(0),
  // Location data
  latitude: decimal('latitude', { precision: 10, scale: 8 }),
  longitude: decimal('longitude', { precision: 11, scale: 8 }),
  locationName: text('location_name'),
  // Engagement tracking
  engagementScore: decimal('engagement_score', { precision: 5, scale: 2 }).default('0'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
}, (table) => ({
  authorIdx: index('posts_author_idx').on(table.authorId),
  typeIdx: index('posts_type_idx').on(table.type),
  publicIdx: index('posts_public_idx').on(table.isPublic),
  createdAtIdx: index('posts_created_at_idx').on(table.createdAt),
  locationIdx: index('posts_location_idx').on(table.latitude, table.longitude),
}));

// Post Likes table
export const postLikes = pgTable('post_likes', {
  id: uuid('id').primaryKey().defaultRandom(),
  postId: uuid('post_id').references(() => posts.id, { onDelete: 'cascade' }).notNull(),
  likerId: uuid('liker_id').references(() => profiles.id).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
}, (table) => ({
  postIdx: index('post_likes_post_idx').on(table.postId),
  likerIdx: index('post_likes_liker_idx').on(table.likerId),
  uniqueLike: index('post_likes_unique_idx').on(table.postId, table.likerId),
}));

// Comments table
export const comments = pgTable('comments', {
  id: uuid('id').primaryKey().defaultRandom(),
  postId: uuid('post_id').references(() => posts.id, { onDelete: 'cascade' }).notNull(),
  authorId: uuid('author_id').references(() => profiles.id).notNull(),
  content: text('content').notNull(),
  likeCount: integer('like_count').default(0),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
}, (table) => ({
  postIdx: index('comments_post_idx').on(table.postId),
  authorIdx: index('comments_author_idx').on(table.authorId),
  createdAtIdx: index('comments_created_at_idx').on(table.createdAt),
}));

// Followers/Following table
export const follows = pgTable('follows', {
  id: uuid('id').primaryKey().defaultRandom(),
  followerId: uuid('follower_id').references(() => profiles.id).notNull(),
  followingId: uuid('following_id').references(() => profiles.id).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
}, (table) => ({
  followerIdx: index('follows_follower_idx').on(table.followerId),
  followingIdx: index('follows_following_idx').on(table.followingId),
  uniqueFollow: index('follows_unique_idx').on(table.followerId, table.followingId),
}));

// Wallets table (for Solana wallet management)
export const wallets = pgTable('wallets', {
  id: uuid('id').primaryKey().defaultRandom(),
  profileId: uuid('profile_id').references(() => profiles.id, { onDelete: 'cascade' }).notNull(),
  address: text('address').notNull().unique(),
  encryptedPrivateKey: text('encrypted_private_key'), // for managed wallets
  isManaged: boolean('is_managed').default(true), // platform-managed vs user-managed
  balance: decimal('balance', { precision: 18, scale: 9 }).default('0'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
}, (table) => ({
  profileIdx: index('wallets_profile_idx').on(table.profileId),
  addressIdx: index('wallets_address_idx').on(table.address),
}));

// Transactions table (for Solana transaction tracking)
export const transactions = pgTable('transactions', {
  id: uuid('id').primaryKey().defaultRandom(),
  walletId: uuid('wallet_id').references(() => wallets.id).notNull(),
  signature: text('signature').notNull().unique(),
  type: text('type').notNull(), // send, receive, mint, burn, etc.
  amount: decimal('amount', { precision: 18, scale: 9 }),
  tokenAddress: text('token_address'),
  toAddress: text('to_address'),
  fee: decimal('fee', { precision: 18, scale: 9 }),
  status: text('status').notNull().default('pending'), // pending, confirmed, failed
  blockTime: timestamp('block_time'),
  metadata: jsonb('metadata'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
}, (table) => ({
  walletIdx: index('transactions_wallet_idx').on(table.walletId),
  signatureIdx: index('transactions_signature_idx').on(table.signature),
  typeIdx: index('transactions_type_idx').on(table.type),
  statusIdx: index('transactions_status_idx').on(table.status),
}));

// Define relations
export const usersRelations = relations(users, ({ one, many }) => ({
  profile: one(profiles, {
    fields: [users.id],
    references: [profiles.userId],
  }),
  sponsoredQuests: many(quests, {
    relationName: 'sponsor',
  }),
}));

export const profilesRelations = relations(profiles, ({ one, many }) => ({
  user: one(users, {
    fields: [profiles.userId],
    references: [users.id],
  }),
  friendships: many(friendships, {
    relationName: 'requester',
  }),
  friendRequests: many(friendships, {
    relationName: 'addressee',
  }),
  createdPois: many(pois, {
    relationName: 'creator',
  }),
  ownedPois: many(pois, {
    relationName: 'owner',
  }),
  createdQuests: many(quests, {
    relationName: 'creator',
  }),
  questParticipations: many(questParticipants),
  posts: many(posts),
  wallet: one(wallets),
}));

export const friendshipsRelations = relations(friendships, ({ one }) => ({
  requester: one(profiles, {
    fields: [friendships.requesterId],
    references: [profiles.id],
    relationName: 'requester',
  }),
  addressee: one(profiles, {
    fields: [friendships.addresseeId],
    references: [profiles.id],
    relationName: 'addressee',
  }),
}));

export const poisRelations = relations(pois, ({ one, many }) => ({
  creator: one(profiles, {
    fields: [pois.creatorId],
    references: [profiles.id],
    relationName: 'creator',
  }),
  owner: one(profiles, {
    fields: [pois.ownerId],
    references: [profiles.id],
    relationName: 'owner',
  }),
  visits: many(poiVisits),
}));

export const poiVisitsRelations = relations(poiVisits, ({ one }) => ({
  poi: one(pois, {
    fields: [poiVisits.poiId],
    references: [pois.id],
  }),
  visitor: one(profiles, {
    fields: [poiVisits.visitorId],
    references: [profiles.id],
  }),
}));

export const questsRelations = relations(quests, ({ one, many }) => ({
  creator: one(profiles, {
    fields: [quests.creatorId],
    references: [profiles.id],
    relationName: 'creator',
  }),
  sponsor: one(users, {
    fields: [quests.sponsorId],
    references: [users.id],
    relationName: 'sponsor',
  }),
  participants: many(questParticipants),
}));

export const questParticipantsRelations = relations(questParticipants, ({ one }) => ({
  quest: one(quests, {
    fields: [questParticipants.questId],
    references: [quests.id],
  }),
  participant: one(profiles, {
    fields: [questParticipants.participantId],
    references: [profiles.id],
  }),
}));

export const postsRelations = relations(posts, ({ one, many }) => ({
  author: one(profiles, {
    fields: [posts.authorId],
    references: [profiles.id],
  }),
  likes: many(postLikes),
  comments: many(comments),
}));

export const postLikesRelations = relations(postLikes, ({ one }) => ({
  post: one(posts, {
    fields: [postLikes.postId],
    references: [posts.id],
  }),
  liker: one(profiles, {
    fields: [postLikes.likerId],
    references: [profiles.id],
  }),
}));

export const commentsRelations = relations(comments, ({ one }) => ({
  post: one(posts, {
    fields: [comments.postId],
    references: [posts.id],
  }),
  author: one(profiles, {
    fields: [comments.authorId],
    references: [profiles.id],
  }),
}));

export const followsRelations = relations(follows, ({ one }) => ({
  follower: one(profiles, {
    fields: [follows.followerId],
    references: [profiles.id],
  }),
  following: one(profiles, {
    fields: [follows.followingId],
    references: [profiles.id],
  }),
}));

export const walletsRelations = relations(wallets, ({ one, many }) => ({
  profile: one(profiles, {
    fields: [wallets.profileId],
    references: [profiles.id],
  }),
  transactions: many(transactions),
}));

export const transactionsRelations = relations(transactions, ({ one }) => ({
  wallet: one(wallets, {
    fields: [transactions.walletId],
    references: [wallets.id],
  }),
}));
