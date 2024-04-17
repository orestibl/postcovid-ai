import { NextResponse } from "next/server";
import { BACKEND_URL } from "@/lib/constants";

export async function GET(
  req: Request,
  { params }: { params: { token: string } }
) {
  const token = params.token;

  const response = await fetch(
    `${process.env.BACKEND_URL}/confirmation-token/confirm/${token}`,
    {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    }
  );

  return response;
}
