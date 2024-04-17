import { BACKEND_URL } from "@/lib/constants";
import { NextResponse } from "next/server";

export async function GET(req: Request) {
  const url = new URL(req.url, `http://${req.headers.get("host")}`);

  const study = url.searchParams.get("study");

  const response = await fetch(
    `${process.env.BACKEND_URL}/participant/areas?study=${study}`,
    {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    }
  );
  return new NextResponse(response.body);
}
