import type { Metadata } from "next";
import { Montserrat, Ubuntu_Mono, Merriweather } from "next/font/google";
import "./globals.css";
import { ThemeProvider } from "@/components/theme-provider";
import { Navigation } from "@/components/navigation";
import { Footer } from "@/components/footer";

const montserrat = Montserrat({
  subsets: ["latin"],
  variable: "--font-montserrat",
});

const ubuntuMono = Ubuntu_Mono({
  subsets: ["latin"],
  variable: "--font-ubuntu-mono",
  weight: "400",
});

const merriweather = Merriweather({
  subsets: ["latin"],
  variable: "--font-merriweather",
  weight: "400",
});

export const metadata: Metadata = {
  title: "Ontrail - Social-Fi for Runners & Explorers",
  description: "Connect with fellow trail runners and explorers on Solana blockchain. Build your profile, form tokenized friendships, complete quests, and monetize your outdoor activities.",
  keywords: ["trail running", "outdoor exploration", "social-fi", "solana", "blockchain", "fitness", "running", "quests", "NFT", "tokenized friendships"],
  authors: [{ name: "Ontrail Team" }],
  creator: "Ontrail",
  publisher: "Ontrail",
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  metadataBase: new URL("https://ontrail.tech"),
  alternates: {
    canonical: "/",
  },
  openGraph: {
    title: "Ontrail - Social-Fi for Runners & Explorers",
    description: "Connect with fellow trail runners and explorers on Solana blockchain",
    url: "https://ontrail.tech",
    siteName: "Ontrail",
    images: [
      {
        url: "/og-image.jpg",
        width: 1200,
        height: 630,
        alt: "Ontrail - Social-Fi for Runners & Explorers",
      },
    ],
    locale: "en_US",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Ontrail - Social-Fi for Runners & Explorers",
    description: "Connect with fellow trail runners and explorers on Solana blockchain",
    images: ["/og-image.jpg"],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-video-preview": -1,
      "max-image-preview": "large",
      "max-snippet": -1,
    },
  },
  icons: {
    icon: "/favicon.ico",
    shortcut: "/favicon-16x16.png",
    apple: "/apple-touch-icon.png",
  },
  manifest: "/manifest.json",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={`${montserrat.variable} ${ubuntuMono.variable} ${merriweather.variable} font-sans antialiased min-h-screen bg-background text-foreground`}>
        <ThemeProvider
          attribute="class"
          defaultTheme="light"
          enableSystem
          disableTransitionOnChange
        >
          <div className="relative flex min-h-screen flex-col">
            <Navigation />
            <main className="flex-1">
              {children}
            </main>
            <Footer />
          </div>
        </ThemeProvider>
      </body>
    </html>
  );
}
