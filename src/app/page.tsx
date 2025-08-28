import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Separator } from "@/components/ui/separator"
import Link from "next/link"
import {
  ArrowRightIcon,
  MapPinIcon,
  TrophyIcon,
  UsersIcon,
  TrendingUpIcon,
  StarIcon,
  CheckCircleIcon,
  ZapIcon
} from "lucide-react"

export default function Home() {
  return (
    <div className="space-y-0">
      {/* Hero Section */}
      <section className="hero-jumbotron">
        <div className="relative z-10 text-center">
          <h1 className="hero-title">
            Connect. Compete. Conquer.
          </h1>
          <p className="hero-subtitle max-w-3xl mx-auto">
            Join the social-fi revolution for runners and explorers. Build your profile, form tokenized friendships,
            complete epic quests, and monetize your outdoor adventures on Solana blockchain.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center mt-8">
            <Button size="lg" className="bg-white text-primary hover:bg-gray-100">
              Start Your Journey
              <ArrowRightIcon className="ml-2 w-4 h-4" />
            </Button>
            <Button size="lg" variant="outline" className="border-white text-white hover:bg-white hover:text-primary">
              Watch Demo
            </Button>
          </div>

          {/* Feature highlights */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-16 max-w-4xl mx-auto">
            <div className="flex items-center justify-center space-x-3 text-white/90">
              <CheckCircleIcon className="w-6 h-6 text-green-400" />
              <span>Zero-Knowledge Wallets</span>
            </div>
            <div className="flex items-center justify-center space-x-3 text-white/90">
              <CheckCircleIcon className="w-6 h-6 text-green-400" />
              <span>Tokenized Friendships</span>
            </div>
            <div className="flex items-center justify-center space-x-3 text-white/90">
              <CheckCircleIcon className="w-6 h-6 text-green-400" />
              <span>Solana Integration</span>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 bg-background">
        <div className="layout-main">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold mb-4">
              Why Choose <span className="text-gradient">Ontrail</span>?
            </h2>
            <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
              Experience the future of outdoor activities with blockchain-powered social features
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            <Card className="profile-card">
              <CardHeader>
                <div className="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center mb-4">
                  <UsersIcon className="w-6 h-6 text-primary" />
                </div>
                <CardTitle>Tokenized Friendships</CardTitle>
                <CardDescription>
                  Form meaningful connections with blockchain-verified friendships and shared rewards
                </CardDescription>
              </CardHeader>
            </Card>

            <Card className="profile-card">
              <CardHeader>
                <div className="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center mb-4">
                  <TrophyIcon className="w-6 h-6 text-primary" />
                </div>
                <CardTitle>Epic Quests</CardTitle>
                <CardDescription>
                  Complete challenges, earn rewards, and unlock exclusive opportunities
                </CardDescription>
              </CardHeader>
            </Card>

            <Card className="profile-card">
              <CardHeader>
                <div className="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center mb-4">
                  <MapPinIcon className="w-6 h-6 text-primary" />
                </div>
                <CardTitle>POI Discovery</CardTitle>
                <CardDescription>
                  Explore points of interest, mint NFTs, and build your digital trophy case
                </CardDescription>
              </CardHeader>
            </Card>
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="py-16 bg-muted/50">
        <div className="layout-main">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8 text-center">
            <div>
              <div className="text-3xl font-bold text-primary mb-2">10K+</div>
              <div className="text-muted-foreground">Active Runners</div>
            </div>
            <div>
              <div className="text-3xl font-bold text-primary mb-2">500+</div>
              <div className="text-muted-foreground">Quests Completed</div>
            </div>
            <div>
              <div className="text-3xl font-bold text-primary mb-2">50M+</div>
              <div className="text-muted-foreground">Steps Tracked</div>
            </div>
            <div>
              <div className="text-3xl font-bold text-primary mb-2">100+</div>
              <div className="text-muted-foreground">POI Locations</div>
            </div>
          </div>
        </div>
      </section>

      {/* User Showcase Section */}
      <section className="py-20 bg-background">
        <div className="layout-main">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold mb-4">
              Meet Our <span className="text-gradient">Trailblazers</span>
            </h2>
            <p className="text-xl text-muted-foreground">
              Discover the most active and valued members of our community
            </p>
          </div>

          {/* Newest Users */}
          <div className="mb-16">
            <h3 className="text-2xl font-semibold mb-8 flex items-center">
              <ZapIcon className="w-6 h-6 mr-3 text-primary" />
              Newest Explorers
            </h3>
            <div className="user-showcase">
              {[
                { name: "Alex Chen", username: "alex_trails", steps: "25,430", joinDate: "2 days ago", avatar: "/avatars/alex.jpg" },
                { name: "Sarah Johnson", username: "sarah_runner", steps: "18,920", joinDate: "1 week ago", avatar: "/avatars/sarah.jpg" },
                { name: "Mike Rodriguez", username: "mike_explore", steps: "32,150", joinDate: "3 days ago", avatar: "/avatars/mike.jpg" },
                { name: "Emma Wilson", username: "emma_adventure", steps: "28,740", joinDate: "5 days ago", avatar: "/avatars/emma.jpg" },
              ].map((user, index) => (
                <Card key={index} className="user-card">
                  <CardHeader className="text-center pb-3">
                    <Avatar className="w-16 h-16 mx-auto mb-3">
                      <AvatarImage src={user.avatar} alt={user.name} />
                      <AvatarFallback>{user.name.split(' ').map(n => n[0]).join('')}</AvatarFallback>
                    </Avatar>
                    <CardTitle className="text-lg">{user.name}</CardTitle>
                    <CardDescription>@{user.username}</CardDescription>
                  </CardHeader>
                  <CardContent className="text-center pt-0">
                    <div className="space-y-2">
                      <div className="flex items-center justify-between text-sm">
                        <span className="text-muted-foreground">Steps Today</span>
                        <span className="font-semibold">{user.steps}</span>
                      </div>
                      <div className="flex items-center justify-between text-sm">
                        <span className="text-muted-foreground">Joined</span>
                        <span className="font-semibold">{user.joinDate}</span>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          </div>

          {/* Most Valued Users */}
          <div>
            <h3 className="text-2xl font-semibold mb-8 flex items-center">
              <StarIcon className="w-6 h-6 mr-3 text-primary" />
              Most Valued Profiles
            </h3>
            <div className="user-showcase">
              {[
                { name: "David Park", username: "david_ultra", valuation: "2.4M", rank: "#1", badge: "Legend", avatar: "/avatars/david.jpg" },
                { name: "Lisa Thompson", username: "lisa_summit", valuation: "1.8M", rank: "#2", badge: "Elite", avatar: "/avatars/lisa.jpg" },
                { name: "James Kim", username: "james_trail", valuation: "1.6M", rank: "#3", badge: "Pro", avatar: "/avatars/james.jpg" },
                { name: "Anna Petrov", username: "anna_expedition", valuation: "1.4M", rank: "#4", badge: "Expert", avatar: "/avatars/anna.jpg" },
              ].map((user, index) => (
                <Card key={index} className="user-card">
                  <CardHeader className="text-center pb-3">
                    <div className="relative">
                      <Avatar className="w-16 h-16 mx-auto mb-3">
                        <AvatarImage src={user.avatar} alt={user.name} />
                        <AvatarFallback>{user.name.split(' ').map(n => n[0]).join('')}</AvatarFallback>
                      </Avatar>
                      <Badge className="absolute -top-2 -right-2 bg-gradient-to-r from-yellow-400 to-orange-500">
                        {user.rank}
                      </Badge>
                    </div>
                    <CardTitle className="text-lg">{user.name}</CardTitle>
                    <CardDescription>@{user.username}</CardDescription>
                  </CardHeader>
                  <CardContent className="text-center pt-0">
                    <div className="space-y-2">
                      <div className="flex items-center justify-between text-sm">
                        <span className="text-muted-foreground">Valuation</span>
                        <span className="font-semibold text-primary">{user.valuation}</span>
                      </div>
                      <div className="flex items-center justify-between text-sm">
                        <span className="text-muted-foreground">Status</span>
                        <Badge variant="secondary">{user.badge}</Badge>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-primary text-primary-foreground">
        <div className="layout-main text-center">
          <h2 className="text-3xl md:text-4xl font-bold mb-4">
            Ready to Start Your Adventure?
          </h2>
          <p className="text-xl opacity-90 mb-8 max-w-2xl mx-auto">
            Join thousands of runners and explorers who are already building their digital legacy on Ontrail
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Button size="lg" variant="secondary" asChild>
              <Link href="/register">
                Create Your Profile
                <ArrowRightIcon className="ml-2 w-4 h-4" />
              </Link>
            </Button>
            <Button size="lg" variant="outline" className="border-primary-foreground text-primary-foreground hover:bg-primary-foreground hover:text-primary">
              Learn More
            </Button>
          </div>
        </div>
      </section>
    </div>
  )
}
