import { Role, UserToStudy, Study } from "@/types/types";
import { JWT, Session } from "next-auth/jwt";
import {} from "@/types/types";

declare module "next-auth" {
  interface Session {
    user: {
      id: number;
      email: string;
      name: string;
      lastname: string;
      role: Role;
      verified: boolean;
      filters: Array<{}>;
      userToStudies: Array<UserToStudy>;
    };

    tokens: {
      access_token: string;
      refresh_token: string;
      expires_in: number;
    };
  }
}

declare module "next-auth/jwt" {
  interface JWT {
    user: {
      id: number;
      email: string;
      name: string;
      lastname: string;
      role: Role;
      verified: boolean;
      filters: Array<{}>;
      userToStudies: Array<UserToStudy>;
    };

    tokens: {
      access_token: string;
      refresh_token: string;
      expires_in: number;
    };
  }
}
