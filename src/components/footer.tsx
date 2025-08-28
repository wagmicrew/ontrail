import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Separator } from "@/components/ui/separator"
import {
  FacebookIcon,
  TwitterIcon,
  InstagramIcon,
  YoutubeIcon,
  MailIcon,
  MapPinIcon,
  PhoneIcon
} from "lucide-react"

export function Footer() {
  const currentYear = new Date().getFullYear()

  return (
    <footer className="bg-card border-t border-border">
      <div className="layout-main py-12">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
          {/* Company Info */}
          <div className="space-y-4">
            <div className="flex items-center space-x-2">
              <div className="w-8 h-8 bg-primary rounded-lg flex items-center justify-center">
                <span className="text-primary-foreground font-bold text-sm">OT</span>
              </div>
              <span className="font-bold text-xl text-gradient">Ontrail</span>
            </div>
            <p className="text-muted-foreground text-sm">
              The social-fi platform for runners and explorers. Connect, compete, and monetize your outdoor adventures on Solana blockchain.
            </p>
            <div className="flex space-x-4">
              <Button variant="ghost" size="icon" className="btn-icon">
                <FacebookIcon className="w-4 h-4" />
              </Button>
              <Button variant="ghost" size="icon" className="btn-icon">
                <TwitterIcon className="w-4 h-4" />
              </Button>
              <Button variant="ghost" size="icon" className="btn-icon">
                <InstagramIcon className="w-4 h-4" />
              </Button>
              <Button variant="ghost" size="icon" className="btn-icon">
                <YoutubeIcon className="w-4 h-4" />
              </Button>
            </div>
          </div>

          {/* Platform */}
          <div className="space-y-4">
            <h3 className="font-semibold">Platform</h3>
            <div className="space-y-2">
              <Link href="/quests" className="block text-sm text-muted-foreground hover:text-foreground transition-colors">
                Quests
              </Link>
              <Link href="/community" className="block text-sm text-muted-foreground hover:text-foreground transition-colors">
                Community
              </Link>
              <Link href="/leaderboard" className="block text-sm text-muted-foreground hover:text-foreground transition-colors">
                Leaderboard
              </Link>
              <Link href="/marketplace" className="block text-sm text-muted-foreground hover:text-foreground transition-colors">
                Marketplace
              </Link>
            </div>
          </div>

          {/* Resources */}
          <div className="space-y-4">
            <h3 className="font-semibold">Resources</h3>
            <div className="space-y-2">
              <Link href="/docs" className="block text-sm text-muted-foreground hover:text-foreground transition-colors">
                Documentation
              </Link>
              <Link href="/api" className="block text-sm text-muted-foreground hover:text-foreground transition-colors">
                API Reference
              </Link>
              <Link href="/support" className="block text-sm text-muted-foreground hover:text-foreground transition-colors">
                Support Center
              </Link>
              <Link href="/blog" className="block text-sm text-muted-foreground hover:text-foreground transition-colors">
                Blog
              </Link>
            </div>
          </div>

          {/* Contact */}
          <div className="space-y-4">
            <h3 className="font-semibold">Contact</h3>
            <div className="space-y-2">
              <div className="flex items-center space-x-2 text-sm text-muted-foreground">
                <MailIcon className="w-4 h-4" />
                <span>hello@ontrail.tech</span>
              </div>
              <div className="flex items-center space-x-2 text-sm text-muted-foreground">
                <MapPinIcon className="w-4 h-4" />
                <span>Remote First</span>
              </div>
              <div className="flex items-center space-x-2 text-sm text-muted-foreground">
                <PhoneIcon className="w-4 h-4" />
                <span>+1 (555) 123-4567</span>
              </div>
            </div>
          </div>
        </div>

        <Separator className="my-8" />

        <div className="flex flex-col md:flex-row justify-between items-center space-y-4 md:space-y-0">
          <div className="text-sm text-muted-foreground">
            © {currentYear} Ontrail. All rights reserved.
          </div>
          <div className="flex space-x-6 text-sm">
            <Link href="/privacy" className="text-muted-foreground hover:text-foreground transition-colors">
              Privacy Policy
            </Link>
            <Link href="/terms" className="text-muted-foreground hover:text-foreground transition-colors">
              Terms of Service
            </Link>
            <Link href="/cookies" className="text-muted-foreground hover:text-foreground transition-colors">
              Cookie Policy
            </Link>
          </div>
        </div>
      </div>
    </footer>
  )
}
