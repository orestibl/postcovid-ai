"use client";

import { ReactNode } from "react";
import { SessionProvider } from "next-auth/react";

interface ProvidersProps {
  children: ReactNode;
}

const Providers = ({ children }: ProvidersProps) => {
  return (
    <SessionProvider basePath="/postcovid-dashboard/api/auth">
      {children}
    </SessionProvider>
  );
};

export default Providers;
