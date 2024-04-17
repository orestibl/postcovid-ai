// import createMiddleware from "next-intl/middleware";
// import { withAuth } from "next-auth/middleware";
// import { NextRequest, NextResponse } from "next/server";

// export const locales = ["en", "es"] as const;

// const intlMiddleware = createMiddleware({
//   locales: locales,
//   defaultLocale: "es",
//   localeDetection: true,
// });

// const authMiddleware = withAuth(function onSuccess(req) {
//   return intlMiddleware(req);
// });

// export default async function middleware(req: NextRequest) {
//   const excludePattern = "^(/(" + locales.join("|") + "))?/dashboard/?.*?$";
//   const publicPathnameRegex = RegExp(excludePattern, "i");
//   const isPublicPage = !publicPathnameRegex.test(req.nextUrl.pathname);

//   if (isPublicPage) {
//     return intlMiddleware(new NextRequest(req));
//   } else {
//     return (authMiddleware as any)(req);
//   }
// }

// export const config = {
//   // matcher: ["/((?!api|_next|.*\\..*).*)"],
//   matcher: ["/", "/(es|en)/:path*"],
// };
import { NextRequest } from "next/server";
import { withAuth } from "next-auth/middleware";
import createIntlMiddleware from "next-intl/middleware";
import { locales } from "@/navigation";

const publicPages = ["/", "/login", "/signup", "/confirm/.*$"];

const intlMiddleware = createIntlMiddleware({
  locales,
  localePrefix: "always",
  defaultLocale: "es",
});

const authMiddleware = withAuth(
  // Note that this callback is only invoked if
  // the `authorized` callback has returned `true`
  // and not for pages listed in `pages`.
  (req) => intlMiddleware(req),
  {
    callbacks: {
      authorized: ({ token }) => token != null,
    },
    pages: {
      signIn: "/login",
    },
  }
);

export default function middleware(req: NextRequest) {
  const publicPathnameRegex = RegExp(
    `^(/(${locales.join("|")}))?(${publicPages
      .flatMap((p) => (p === "/" ? ["", "/"] : p))
      .join("|")})/?$`,
    "i"
  );

  const isPublicPage = publicPathnameRegex.test(req.nextUrl.pathname);

  if (isPublicPage) {
    return intlMiddleware(req);
  } else {
    return (authMiddleware as any)(req);
  }
}

export const config = {
  // Skip all paths that should not be internationalized
  matcher: ["/((?!api|_next|.*\\..*).*)"],
};
