import React from "react";

import { authOptions } from "@/app/api/auth/[...nextauth]/route";
import { BACKEND_URL } from "@/lib/constants";
import { getServerSession } from "next-auth/next";

async function UserInfo() {
  const getUserInfo = async () => {
    const session = await getServerSession(authOptions);

    if (session && session.user)
      return await fetchUser(session.user.id, session?.tokens?.access_token);
    else return null;
  };

  const fetchUser = async (id: number, access_token: string) => {
    const res = await fetch(`${process.env.BACKEND_URL}/user/${id}`, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${access_token}`,
      },
    });

    const json = await res.json();

    if (res.ok) return json;

    throw new Error(json.message);
  };

  const user = await getUserInfo();

  return (
    <div>
      <p>{user?.name}</p>
    </div>
  );
}

export default UserInfo;
