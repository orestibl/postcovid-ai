"use client";
import React from "react";
import DashboardIcon from "@mui/icons-material/Dashboard";
import LineAxisIcon from "@mui/icons-material/LineAxis";
import TuneIcon from "@mui/icons-material/Tune";
import AccountCircleIcon from "@mui/icons-material/AccountCircle";
import AdminPanelSettingsIcon from "@mui/icons-material/AdminPanelSettings";
import { useRouter, usePathname } from "../navigation";
import SideBarLinkItem from "./SideBarLinkItem";
import Image from "next/image";
import { useSession } from "next-auth/react";
import { LangProps, Role } from "@/types/types";
import FolderSpecialIcon from "@mui/icons-material/FolderSpecial";
import Select, { SelectChangeEvent } from "@mui/material/Select";
import { FormControl, InputLabel, MenuItem } from "@mui/material";
import StudySelector from "./StudySelector";

const menuItems = [
  {
    name: "main",
    icon: <DashboardIcon fontSize="large" />,
    path: "/dashboard/charts/main",
  },
  {
    name: "advanced",
    icon: <LineAxisIcon fontSize="large" />,
    path: "/dashboard/charts/advanced",
  },
  {
    name: "filters",
    icon: <TuneIcon fontSize="large" />,
    path: "/dashboard/filters",
  },
  {
    name: "admin",
    icon: <AdminPanelSettingsIcon fontSize="large" />,
    path: "/dashboard/admin",
  },
  {
    name: "studies",
    icon: <FolderSpecialIcon fontSize="large" />,
    path: "/dashboard/studies",
  },
];

function SideNavBar() {
  const { data: session } = useSession();

  const [study, setStudy] = React.useState("");

  const handleChange = (event: SelectChangeEvent) => {
    setStudy(event.target.value);
  };

  const items =
    session?.user?.role != Role.ADMIN && session?.user?.role != Role.STUDY_ADMIN
      ? menuItems.filter((item) => item.name !== "admin")
      : menuItems;

  const pathname = usePathname();

  const cleanPathname = pathname.replace(/^\/[a-z]{2}\//, "/");

  return (
    <div className="min-h-screen py-8 flex flex-col items-center">
      <div className="flex items-center mb-20">
        <div className="relative h-7 w-7 lg:h-9 lg:w-9 2xl:w-12 2xl:h-12">
          <Image
            unoptimized
            src="/postcovid-dashboard/images/logo.png"
            fill
            alt="logo"
          />
        </div>
        <span className="lg:text-[17px] 2xl:text-2xl font-bold text-[#5f868f] text-transform: uppercase ml-3">
          postcovid-ai
        </span>
      </div>

      <div className="flex justify-start items-center mb-10 w-full">
        <div className="ml-7">
          <AccountCircleIcon sx={{ fontSize: 45 }} />
        </div>
        <div className="flex flex-col items-start ml-3">
          <span className="text-primary-main font-bold text-transform: capitalize">
            {`${session?.user?.name}`}
          </span>
          <span className="text-primary-main text-[12px] ">
            {`${session?.user?.email} `}
          </span>
        </div>
      </div>

      <div className="mb-5 mt-5">
        {/* <FormControl sx={{ m: 1, minWidth: 80 }}>
          <InputLabel id="demo-simple-select-autowidth-label">Study</InputLabel>
          <Select
            labelId="demo-simple-select-autowidth-label"
            id="demo-simple-select-autowidth"
            value={study}
            onChange={handleChange}
            autoWidth
            label="Study"
          >
            <MenuItem value={10}>Estudio Piloto</MenuItem>
            <MenuItem value={21}>Estudio 1</MenuItem>
            <MenuItem value={22}>Estudio 2</MenuItem>
          </Select>
        </FormControl> */}
        <StudySelector value={study} setValue={setStudy} />
      </div>

      {items.map((item, index) => (
        <SideBarLinkItem
          key={index}
          active={cleanPathname === item.path}
          path={item.path}
          icon={item.icon}
          name={item.name}
        />
      ))}
    </div>
  );
}

export default SideNavBar;
