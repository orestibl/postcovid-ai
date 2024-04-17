import { getServerSession } from "next-auth";
import { authOptions } from "@/app/api/auth/[...nextauth]/route";
import { BACKEND_URL } from "@/lib/constants";
import { NextResponse } from "next/server";

export async function POST(req: Request) {
  const session = await getServerSession({ req, ...authOptions });

  const token = session?.tokens.access_token;
  try {
    const body = await req.json();
    console.log("body", body);

    const response = await fetch(`${process.env.BACKEND_URL}/mail`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",

        authorization: `Bearer ${token}`,
      },
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    return new NextResponse(response.body);
  } catch (e) {
    console.error("Error saving entity:", e);
    return NextResponse.error();
  }
}
