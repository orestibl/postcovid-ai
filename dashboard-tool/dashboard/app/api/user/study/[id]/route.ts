import { BACKEND_URL } from "@/lib/constants";
import { NextResponse } from "next/server";
import { getServerSession } from "next-auth";
import { authOptions } from "../../../auth/[...nextauth]/route";

export async function GET(
  req: Request,
  { params }: { params: { id: string } }
) {
  const id = params.id;

  const session = await getServerSession({ req, ...authOptions });

  const token = session?.tokens.access_token;

  console.log("Fetching users for study:", id);

  const response = await fetch(`${process.env.BACKEND_URL}/user/study/${id}`, {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
      authorization: `Bearer ${token}`,
    },
  });

  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }

  return new NextResponse(response.body);
}
