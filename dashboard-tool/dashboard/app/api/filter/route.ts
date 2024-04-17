import { BACKEND_URL } from "@/lib/constants";
import { NextResponse } from "next/server";
import { getServerSession } from "next-auth";
import { authOptions } from "@/app/api/auth/[...nextauth]/route";
import { revalidatePath } from "next/cache";

export async function GET(req: Request) {
  const session = await getServerSession({ req, ...authOptions });

  const token = session?.tokens.access_token;

  const url = new URL(req.url, `http://${req.headers.get("host")}`);

  const study = url.searchParams.get("study");

  if (!study) return new NextResponse(null, { status: 400 });

  const endpoint = `${
    process.env.BACKEND_URL
  }/filter?study=${encodeURIComponent(study)}`;

  try {
    const response = await fetch(endpoint, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        authorization: `Bearer ${token}`,
      },
    });

    return new NextResponse(response.body);
  } catch (e) {
    console.error("Error fetching filters on route filter", e);
    return NextResponse.error();
  }
}

export async function POST(req: Request) {
  const session = await getServerSession({ req, ...authOptions });

  const token = session?.tokens.access_token;
  try {
    const body = await req.json();

    const response = await fetch(`${process.env.BACKEND_URL}/filter`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        // Assuming authorization is needed, as with the GET method
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
