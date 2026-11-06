import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Doomvision | CalcGPT (Gemini AI)",
  description: "Connect your TI-84 Plus CE and chat with Gemini AI directly on your calculator over USB.",
};

export default function AiLayout({ children }: { children: React.ReactNode }) {
  return children;
}
