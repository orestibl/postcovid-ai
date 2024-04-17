"use client";

import { signOut } from "next-auth/react";
import LogoutIcon from "@mui/icons-material/Logout";

import { useRouter, usePathname } from "../navigation";

import { useLocale } from "next-intl";
import { useFilterStore } from "@/store/filters";
import { Backdrop, CircularProgress } from "@mui/material";
import { useState } from "react";
import FilterNameBadge from "./FilterNameBadge";
function NavBar() {
  const [loading, setLoading] = useState(false);
  const filters = useFilterStore((state) => state.filters);
  const router = useRouter();
  const pathname = usePathname();

  const locale = useLocale();

  const handleLogout = async () => {
    setLoading(true);
    const data = await signOut({ redirect: false, callbackUrl: "/login" });
    const url = new URL("https://projects.ugr.es/postcovid-dashboard/login");
    router.push(url.pathname);
    setLoading(false);
  };

  console.log("filters", filters);

  return (
    <nav className="flex flex-col items-center w-full">
      <Backdrop
        open={loading}
        sx={{
          color: "#fff",
          zIndex: (theme) => theme.zIndex.drawer + 1,
          position: "absolute",
          width: "100vw",
          height: "100vh",
        }}
      >
        <CircularProgress color="inherit" />
      </Backdrop>
      <div className="flex justify-end items-center mt-2 mr-3 w-full">
        <div className="mr-3">
          <select
            defaultValue={locale}
            onChange={(e) => {
              router.replace(pathname, { locale: e.target.value });
            }}
            className="bg-transparent text-primary-main"
          >
            <option value="en">English</option>
            <option value="es">Español</option>
          </select>
        </div>

        <span className="text-primary-main mr-3">Logout</span>
        <div className="flex items-center rounded-full bg-slate-300 p-1 cursor-pointer hover:bg-[#5f868f] ">
          <LogoutIcon
            onClick={handleLogout}
            className="appearance-none"
            sx={{ "&:hover": { color: "primary" } }}
          />
        </div>
      </div>
      {!pathname.includes("admin") && (
        <div className="text-sm flex ">
          {filters &&
            filters.map((filter) => {
              return (
                <FilterNameBadge
                  key={filter.id}
                  name={filter.name}
                  color={filter.color}
                  count={filter.number_participants}
                />
              );
            })}
        </div>
      )}
    </nav>
  );
}

export default NavBar;
