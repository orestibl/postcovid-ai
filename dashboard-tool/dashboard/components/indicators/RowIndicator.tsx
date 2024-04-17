import RowState from "./RowState";

import { FilterResult } from "@/types/types";
import { useTranslations } from "next-intl";

interface RowIndicatorProps {
  items: FilterResult[];
  category: string;
}

export default function RowIndicator({ items, category }: RowIndicatorProps) {
  const t = useTranslations("indicator_names");

  return (
    <div className="w-11/12 lg:w-7/12 xl:w-7/12 2xl:w-5/12 h-[100px] relative flex flex-col items-center justify-between lg:mb-7 mt-5">
      <div className="h-[38px] font-bold text-lg text-[#5f868f]">
        {t(category)}
      </div>
      <div className="relative w-full h-[45px] ">
        {items.map((element, index) => (
          <div
            key={index}
            style={{
              position: "absolute",
              transition: `all .5s ease-in-out`,
              left: `${element.pos}%`,
              width: "2rem",
            }}
          >
            <RowState
              color={element.color}
              size={45}
              pos={element.pos}
              category={category}
            />
          </div>
        ))}
      </div>
      <div
        style={{
          borderRadius: "5vw",
          background: `linear-gradient(90deg, white, rgb(95, 134, 143))`,
          height: "12px",
          width: "100%",
        }}
      />
    </div>
  );
}
