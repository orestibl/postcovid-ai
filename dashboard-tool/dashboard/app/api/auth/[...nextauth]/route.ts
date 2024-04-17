import { NextAuthOptions } from "next-auth";
import CredentialsProvider from "next-auth/providers/credentials";
import { BACKEND_URL } from "@/lib/constants";
import NextAuth from "next-auth/next";
import { JWT } from "next-auth/jwt";
require("dotenv").config();

async function refreshToken(token: JWT): Promise<JWT> {
  const res = await fetch(`${process.env.BACKEND_URL}/auth/refresh`, {
    method: "POST",
    headers: {
      authorization: `Refresh ${token.tokens.refresh_token}`,
    },
  });

  if (res.status === 401) {
    return token;
  }

  const data = await res.json();

  if (res.ok && data) return { ...token, tokens: { ...data.tokens } };
  return token;
}

export const authOptions: NextAuthOptions = {
  providers: [
    CredentialsProvider({
      name: "Credentials",
      credentials: {
        username: { label: "Email", type: "text", placeholder: "Email" },
        password: { label: "Password", type: "password" },
      },
      async authorize(credentials, req) {
        if (!credentials?.username || !credentials?.password) return null;

        const { username, password } = credentials;

        const res = await fetch(`${process.env.BACKEND_URL}/auth/login`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            email: username,
            password,
          }),
        });

        if (res.status === 401) {
          return null;
        }

        const user = await res.json();

        if (res.ok && user) {
          return user; // Return the user object upon successful authentication
        } else {
          return null; // Return null if authentication fails
        }
      },
    }),
  ],

  callbacks: {
    async jwt({ token, user }) {
      if (user) return { ...token, ...user };

      if (new Date().getTime() < token.tokens.expires_in) return token;
      return await refreshToken(token);
    },

    async session({ session, token }) {
      session.user = token.user;
      session.tokens = { ...token.tokens };

      return session;
    },
  },

  pages: {
    signIn: "/postcovid-dashboard/login",
  },
};

const handler = NextAuth(authOptions);

export { handler as GET, handler as POST };
