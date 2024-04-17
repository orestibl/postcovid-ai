import React from "react";
import CustomTooltip from "./CustomTooltip";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import dayjs from "dayjs";
import { DailyIndicator, Filter, Indicator } from "@/types/types";
import { useTranslations } from "next-intl";

interface Accumulator {
  [key: string]: any;
}

type LineChartsProps = {
  indicators: Indicator[][];
  category: string;
  filters: Filter[];
};

export default function LineCharts({
  indicators,
  category,
  filters,
}: LineChartsProps) {
  const t = useTranslations("indicator_names");

  const combinedData = indicators.reduce((acc: Accumulator, array, index) => {
    const reduced = array.map((item) => {
      return { date: item.date, category: item[category] };
    });

    reduced.forEach((item) => {
      // Convert date to a string if it's a Date object
      const dateString: string =
        item.date instanceof Date
          ? item.date.toISOString().split("T")[0]
          : (item.date as string);
      // Initialize the object for the date if it doesn't exist
      if (!acc[dateString]) {
        acc[dateString] = { date: dateString };
      }
      // Add the value from the current array to the object for the date
      acc[dateString][`${filters[index].name}`] = Object.values(item).find(
        (val) => val !== dateString
      );
    });

    return acc;
  }, {});

  return (
    <div className="w-full md:w-3/5 h-[200px] md:h-[350px] flex flex-col items-center">
      <div>
        <span className=" text-lg font-bold text-[#5f868f] text-transform: capitalize">
          {t(category)}
        </span>
      </div>
      <ResponsiveContainer width="100%" height="80%">
        <LineChart data={Object.values(combinedData)}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis
            type="category"
            interval={6}
            style={{ fontSize: ".4rem" }}
            dataKey="date"
            tickFormatter={(tick) => {
              return dayjs(tick).format("DD-MM-YYYY");
            }}
          />
          <YAxis type="number" style={{ fontSize: ".8rem" }} />
          <Tooltip
            content={<CustomTooltip active={false} payload={[]} label={""} />}
            contentStyle={{ fontSize: ".8rem" }}
          />
          {filters.map((filter: Filter, index) => (
            <Line
              key={index}
              type="monotone"
              dataKey={filter?.name}
              stroke={filter.color ? filter.color : "#000"}
              strokeWidth={2}
              dot={false}
              activeDot={{ r: 4 }}
            />
          ))}
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}
