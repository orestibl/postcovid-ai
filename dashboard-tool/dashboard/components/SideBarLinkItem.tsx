"use client";
import Link from "next/link";
import { useTranslations } from "next-intl";
import { useLocale } from "next-intl";

type SideBarLinkItemProps = {
  active: boolean;
  path: string;
  icon: React.ReactNode;
  name: string;
};

function SideBarLinkItem({ active, path, icon, name }: SideBarLinkItemProps) {
  const t = useTranslations("sidebar");
  const locale = useLocale();

  return (
    <Link
      locale={false}
      className="no-underline text-inherit w-11/12 my-1 "
      href={`/${locale}${path}`}
    >
      <div
        className={`flex items-center ${
          active ? "bg-[#5f868f] font-bold" : "hover:bg-[#5f868f]"
        } h-12 rounded`}
      >
        <div className="flex items-center ml-3">{icon}</div>
        <span className="text-transform: capitalize ml-3">{t(name)}</span>
      </div>
    </Link>
  );
}

export default SideBarLinkItem;
