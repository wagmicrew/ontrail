# 🏃‍♂️ Ontrail: Where Running Meets Blockchain Magic 🪄

> *"Because who says you can't run from your problems AND make money while doing it?"*

![Ontrail Banner](https://img.shields.io/badge/Status-In%20Development-orange?style=for-the-badge&logo=react)
![Next.js](https://img.shields.io/badge/Next.js-14-black?style=for-the-badge&logo=next.js)
![Solana](https://img.shields.io/badge/Solana-Blockchain-purple?style=for-the-badge&logo=solana)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue?style=for-the-badge&logo=postgresql)

## 🚀 What is Ontrail?

Ontrail is the **social-fi platform** where runners and explorers level up their outdoor adventures with **blockchain superpowers**! 🦸‍♂️

Imagine this: You're pounding the pavement, conquering mountains, or discovering hidden trails... and getting **paid** for it! 💰

### 🎯 Core Features (Because Why Not Make Running Addictive?)

#### 🏆 Tokenized Friendships
```javascript
// Because friends are better when they're NFTs
const friendship = {
  requester: "You",
  friend: "ThatCoolRunner42",
  tokenValue: "1.5 SOL",
  benefits: ["Shared rewards", "Quest bonuses", "Emergency running buddy"]
}
```

#### 🎮 Epic Quests
- **Individual Quests**: "Run 10K steps today or no breakfast!"
- **Friendly Quests**: Compete with friends (but still be friends after losing)
- **POI Quests**: Discover locations and mint them as NFTs
- **Tiered Challenges**: Low/Mid/High friend count quests (fair play matters!)

#### 🗺️ Points of Interest (POI)
Find cool spots, add photos, leave reviews, and **mint them as NFTs**! Because why visit a waterfall when you can own a piece of it?

#### 💎 Profile Valuation Algorithm
Your profile worth is calculated based on:
- Steps taken (because movement is life)
- Quests completed (achievements unlocked!)
- SOL collected (show me the money!)
- Friend count (quality > quantity, but quantity helps)
- POI visits (explorer points!)

## 🛠️ Tech Stack (The Nerdy Bits)

| Component | Technology | Why We Chose It |
|-----------|------------|-----------------|
| **Frontend** | Next.js 14 + React | Because SSR is cooler than a polar bear's toenails |
| **Styling** | Tailwind CSS + ShadCN | Utility-first CSS that doesn't suck |
| **Database** | PostgreSQL + Drizzle ORM | SQL that doesn't make you cry |
| **Blockchain** | Solana | Fast, cheap, and won't bankrupt you on gas fees |
| **Auth** | NextAuth.js | Login with Google/Facebook because passwords are 2023 |
| **Maps** | Google Maps API | Because "turn left at the big tree" isn't precise enough |

## 🎮 Getting Started (Developer Mode Activated!)

### Prerequisites
- Node.js 18+ (because we're not savages)
- PostgreSQL 14+ (local or cloud, your choice)
- A GitHub account (for that sweet, sweet collaboration)
- Optional: A sense of humor

### Installation (The Quick Way)

```bash
# Clone the repo (once it's on GitHub)
git clone https://github.com/yourusername/ontrail2025.git
cd ontrail2025/webApp

# Install dependencies (this might take a while, grab coffee)
npm install

# Set up environment variables
cp .env.example .env.local
# Edit .env.local with your secrets

# Set up the database
npm run db:generate
npm run db:migrate

# Start the development server
npm run dev
```

### Environment Variables (Don't Commit These!)

```env
# Database
DATABASE_URL="postgresql://username:password@localhost:5432/ontrail_db"

# NextAuth
NEXTAUTH_URL="http://localhost:3000"
NEXTAUTH_SECRET="your-secret-key-here"

# Solana
SOLANA_RPC_URL="https://api.mainnet-beta.solana.com"
SOLANA_NETWORK="mainnet-beta"

# Google OAuth
GOOGLE_CLIENT_ID="your-google-client-id"
GOOGLE_CLIENT_SECRET="your-google-client-secret"

# And more... check .env.example
```

## 🏗️ Project Structure (Because Organization is Key)

```
ontrail2025/
├── webApp/                    # Main Next.js application
│   ├── src/
│   │   ├── app/              # Next.js 14 App Router pages
│   │   │   ├── (auth)/       # Authentication pages
│   │   │   ├── community/    # Community features
│   │   │   ├── quests/       # Quest system
│   │   │   └── profile/      # User profiles
│   │   ├── components/       # Reusable UI components
│   │   │   ├── ui/          # ShadCN components
│   │   │   └── ...          # Custom components
│   │   └── lib/             # Utilities and configurations
│   │       ├── db/          # Database schemas and connections
│   │       └── ...          # Other utilities
│   ├── public/              # Static assets
│   └── ...
├── app/                     # Documentation and planning
│   ├── PRD_Ontrail_SocialFi.md
│   ├── Design_Document_Ontrail.md
│   └── ...
└── ubuntu_postgres_setup.sh  # Server setup script
```

## 🎯 Development Workflow (How We Roll)

### 1. Pick a Quest (Issue)
```bash
# Check available quests
gh issue list

# Claim a quest
gh issue develop <issue-number>
```

### 2. Create Feature Branch
```bash
git checkout -b feature/amazing-new-feature
# Or for bug fixes
git checkout -b fix/that-annoying-bug
```

### 3. Code Like a Boss
- Follow the existing patterns
- Use TypeScript (no `any` types, please!)
- Write tests (eventually...)
- Keep commits small and meaningful

### 4. Test Your Changes
```bash
# Run the app
npm run dev

# Check for linting issues
npm run lint

# Type checking
npm run build
```

### 5. Create Pull Request
```bash
# Push your branch
git push origin feature/amazing-new-feature

# Create PR via GitHub or CLI
gh pr create --title "Add amazing new feature" --body "This feature will blow your mind!"
```

## 🤝 Contributing (Join the Adventure!)

We welcome contributions! Here's how to join the Ontrail development team:

### For Code Contributors
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

### For Non-Code Contributors
- **Testers**: Help us find bugs by using the app
- **Designers**: Improve our UI/UX
- **Writers**: Help with documentation and content
- **Community Managers**: Grow our awesome community

### Code of Conduct
- Be respectful and inclusive
- No drama, just code and good vibes
- Help newcomers learn and contribute
- Have fun! This is supposed to be enjoyable

## 🎉 Fun Facts & Easter Eggs

- 🏃‍♀️ **Fun Fact**: The first version was built during a coding marathon fueled by energy drinks and trail mix
- 🎯 **Hidden Feature**: Try typing "konami code" in the search bar (just kidding... or are we?)
- 🐛 **Bug Bounty**: Find a bug? Report it and we'll name a quest after you!
- 🎨 **Theme**: We have light and dark themes because staring at bright screens in the dark is masochistic

## 📈 Roadmap (What's Next?)

### Phase 1: Core Features ✅
- [x] Basic app structure
- [x] User authentication
- [x] Profile system
- [x] Database setup

### Phase 2: Social Features 🚧 (Current)
- [ ] Friendships and tokenization
- [ ] Quest system
- [ ] POI discovery
- [ ] Basic social feed

### Phase 3: Blockchain Integration 🔮
- [ ] Solana wallet integration
- [ ] Token launches
- [ ] NFT minting
- [ ] DEX integration

### Phase 4: Advanced Features 🚀
- [ ] Mobile app
- [ ] Health app integrations
- [ ] Advanced analytics
- [ ] Marketplace features

## 🤝 Sponsors & Partners

Shoutout to our amazing sponsors who believe in the vision:

- **Trail Running Magazine** - For believing in our crazy idea
- **Solana Labs** - For the awesome blockchain infrastructure
- **Our Coffee Machine** - For keeping us awake during development

## 📞 Support & Community

- **Discord**: Join our community chat
- **Twitter**: Follow for updates and memes
- **GitHub Issues**: Report bugs or request features
- **Email**: hello@ontrail.tech

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Made with ❤️, ☕, and way too much trail mix by the Ontrail Team**

> "The best way to predict the future is to create it." - Peter Drucker
>
> Also, "The best way to run faster is to have friends betting on you." - Ontrail Team

---

<div align="center">
  <img src="https://forthebadge.com/images/badges/built-with-love.svg" alt="Built with Love">
  <img src="https://forthebadge.com/images/badges/powered-by-coffee.svg" alt="Powered by Coffee">
  <img src="https://forthebadge.com/images/badges/uses-badges.svg" alt="Uses Badges">
</div>