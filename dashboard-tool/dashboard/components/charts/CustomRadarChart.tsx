import React, { useEffect, useState } from "react";
import { DailyIndicator, Filter, Indicator } from "@/types/types";
import {
  Radar,
  RadarChart,
  PolarGrid,
  PolarAngleAxis,
  PolarRadiusAxis,
  ResponsiveContainer,
  Tooltip,
} from "recharts";
import CustomTooltip from "./CustomTooltip";
import { useTranslations } from "next-intl";

type RadarChartsProps = {
  dailyIndicators: Indicator[];

  categories: string[];
};

type RadarData = {
  category: string;
  [key: string]: number | string;
};

export default function CustomRadarChart({
  dailyIndicators,

  categories,
}: RadarChartsProps) {
  const [labelShow, setLabelShow] = useState<number>(0.8);

  const t = useTranslations("indicator_names");

  const data: RadarData[] = [];

  categories.forEach((category) => {
    const obj: RadarData = {
      category: t(category),
    };

    dailyIndicators.forEach((ind: Indicator, index) => {
      const value = dailyIndicators[index][category];

      obj[ind.filter_name as string] =
        value instanceof Date ? value.getTime() : value;
    });

    data.push(obj);
  });

  return (
    <div className="w-full h-[400px]">
      <ResponsiveContainer width="100%" height="85%">
        <RadarChart cx="50%" cy="50%" outerRadius="80%" data={data}>
          <PolarGrid />
          <Tooltip
            contentStyle={{ fontSize: ".8rem" }}
            content={<CustomTooltip active={false} payload={[]} label={""} />}
          />
          <PolarAngleAxis
            style={{ fontSize: `${labelShow}rem` }}
            dataKey="category"
          />
          <PolarRadiusAxis
            style={{ fontSize: ".8rem" }}
            type="number"
            domain={[0, 100]}
          />
          {dailyIndicators.map((indicator: Indicator, index) => (
            <Radar
              key={index}
              // name={filter.name}
              dataKey={indicator.filter_name as string}
              stroke={indicator?.color as string}
              fill={indicator?.color as string}
              fillOpacity={0.3}
            />
          ))}
        </RadarChart>
      </ResponsiveContainer>
    </div>
  );
}
