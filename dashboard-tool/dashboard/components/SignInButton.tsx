"use client";
import { useSession } from "next-auth/react";
import Link from "next/link";
import React from "react";

const SignInButton = () => {
  const { data: session, status } = useSession();

  if (status === "loading") {
    return <p>Loading...</p>;
  }

  if (status === "authenticated") {
    if (session && session.user)
      return (
        <div className="flex gap-4 ml-auto">
          <p className="text-sky-600">{session?.user?.name}</p>
          <Link href={"/api/auth/signout"} className="flex gap-4 ml-auto">
            Sign Out
          </Link>
        </div>
      );
  } else {
    return (
      <div className="flex gap-4 ml-auto items-center">
        <Link
          href={"/api/auth/signin"}
          className="flex gap-4 ml-auto text-green-600"
        >
          Sign In
        </Link>
        <Link
          href={"/signup"}
          className="flex gap-4 ml-auto bg-green-600 text-green-200"
        >
          Sign Up
        </Link>
      </div>
    );
  }
};

export default SignInButton;
