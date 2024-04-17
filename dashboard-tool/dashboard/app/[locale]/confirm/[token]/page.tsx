"use client";
import { useParams } from "next/navigation";
import React, { useEffect, useState } from "react";
import Link from "next/link";
import { CircularProgress } from "@mui/material";
import { useTokens } from "@/store/confirmation_token";

type UserVerifiedProps = {
  ok: number;
};

const UserVerified = ({ ok }: UserVerifiedProps) => {
  return ok == 2 ? (
    <div className="w-full h-full flex flex-col items-center justify-center">
      <h2>User correctly verified</h2>
      <Link href={"/login"}>Please Login</Link>
    </div>
  ) : (
    <div className="w-full h-full flex items-center justify-center">
      <h2>User could not be verified</h2>
    </div>
  );
};

export default function Confirm() {
  const token = useParams().token;

  const [ok, setOk] = useState(1);

  const verifyToken = (token: string | string[]) => {
    const path = `/postcovid-dashboard/api/confirmation/${token}`;

    fetch(path)
      .then((response) => {
        setOk(2);
      })
      .catch((error) => {
        console.log("Response error", error);
        setOk(0);
      });
  };

  useEffect(() => {
    verifyToken(token);
  }, [token]);

  return ok === 1 ? (
    <div className="w-full h-full flex items-center justify-center">
      <CircularProgress />
    </div>
  ) : (
    <UserVerified ok={ok} />
  );
}
