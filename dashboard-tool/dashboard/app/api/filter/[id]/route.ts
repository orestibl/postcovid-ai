import { BACKEND_URL } from "@/lib/constants";
import { NextResponse } from "next/server";
import { getServerSession } from "next-auth";
import { authOptions } from "../../auth/[...nextauth]/route";

export async function PATCH(
  req: Request,
  { params }: { params: { id: string } }
) {
  const id = params.id;

  const session = await getServerSession({ req, ...authOptions });

  const token = session?.tokens.access_token;

  const body = await req.json();

  const response = await fetch(`${process.env.BACKEND_URL}/filter/${id}`, {
    method: "PATCH",
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
}

export async function DELETE(
  req: Request,
  { params }: { params: { id: string } }
) {
  const id = params.id;

  const session = await getServerSession({ req, ...authOptions });

  const token = session?.tokens.access_token;

  const response = await fetch(`${process.env.BACKEND_URL}/filter/${id}`, {
    method: "DELETE",
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
