// dashboard/app/api/register/route.ts
import { BACKEND_URL } from "@/lib/constants";
import type { NextApiRequest, NextApiResponse } from "next";
import { NextResponse } from "next/server";

export async function POST(req: Request) {
  const body = await req.json();

  const { email, password, name, lastname, study } = body;

  try {
    const response = await fetch(BACKEND_URL + "/auth/register", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email,
        password,
        name,
        lastname,
        study,
      }),
    });

    if (response.status === 201) {
      return new NextResponse(
        JSON.stringify({ message: "User registered successfully" })
      );
    } else {
      return new NextResponse(
        JSON.stringify({ message: "Registration failed" }),
        { status: response.status }
      );
    }
  } catch (error) {
    console.error(error);
    return new NextResponse(
      JSON.stringify({ message: "Internal Server Error" }),
      { status: 500 }
    );
  }
}
