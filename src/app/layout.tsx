import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Doomvision | Optical audio",
  description: "Transfer sound through six-color optical data packets.",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html
      lang="en"
      className="h-full antialiased"
    >
      <body className="min-h-full flex flex-col">{children}</body>
    </html>
  );
}
