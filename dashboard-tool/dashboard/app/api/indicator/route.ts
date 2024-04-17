import { BACKEND_URL } from "@/lib/constants";
import { NextResponse } from "next/server";
import { getServerSession } from "next-auth";
import { authOptions } from "../auth/[...nextauth]/route";

export async function GET(req: Request) {
  const session = await getServerSession({ req, ...authOptions });

  const token = session?.tokens.access_token;

  const url = new URL(req.url, `http://${req.headers.get("host")}`);

  const study = url.searchParams.get("study");
  const dateLeft = url.searchParams.get("start");
  const dateRight = url.searchParams.get("end");

  if (!study) return new NextResponse(null, { status: 400 });

  const start =
    dateLeft === null || dateLeft === "Invalid Date"
      ? ""
      : `&start=${dateLeft}`;
  const end =
    dateRight === null || dateLeft === "Invalid Date"
      ? ""
      : `&end=${dateRight}`;

  const endpoint = `${
    process.env.BACKEND_URL
  }/indicator?study=${encodeURIComponent(study)}${start}${end}`;

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
    return NextResponse.error();
  }
}
