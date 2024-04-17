import Providers from "@/components/Providers";
import ThemeRegistry from "@/theme/ThemeRegistry";
import QueryProvider from "@/lib/QueryProvider";
import "./globals.css";
import { ReactNode } from "react";
import { NextIntlClientProvider, useMessages } from "next-intl";

interface RootLayoutProps {
  children: ReactNode;
  params: {
    locale: string;
  };
}

export default function RootLayout({ children }: RootLayoutProps) {
  const messages = useMessages();

  return (
    <html>
      <head>
        <title>POSTCOVID-AI</title>
        <link rel="icon" href="/favicon.ico" sizes="any" />
      </head>
      <Providers>
        <ThemeRegistry>
          <body>
            <QueryProvider>
              <NextIntlClientProvider messages={messages}>
                {children}
              </NextIntlClientProvider>
            </QueryProvider>
          </body>
        </ThemeRegistry>
      </Providers>
    </html>
  );
}
