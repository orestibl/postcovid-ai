import dayjs from "dayjs";
import { useTranslations } from "next-intl";

interface CustomTooltipProps {
  active: boolean;
  payload: Array<any>;
  label: string;
}
export default function CustomTooltip({
  active,
  payload,
  label,
}: CustomTooltipProps) {
  if (active && payload && payload.length) {
    const isDate = dayjs(label).isValid();

    label = isDate ? dayjs(label).format("DD-MM-YYYY") : label;

    return (
      <div
        style={{
          backgroundColor: "rgba(206, 227, 232, 0.7)",
          //   border: "none",
          padding: "0.5rem",
          borderRadius: "0.2rem",
        }}
      >
        <p
          style={{
            fontSize: "0.8rem",
            marginBottom: "0.2rem",
            marginTop: "0.2rem",
          }}
        >
          {label}
        </p>

        {payload.map((el, index) => {
          return (
            <div
              key={`${el.name}${index}`}
              style={{
                color: el.color,
                fontSize: "0.8rem",
                marginBottom: "0.3rem",
              }}
            >{`${el.name}: ${
              Math.round((el.value as number) * 100) / 100
            }`}</div>
          );
        })}
      </div>
    );
  }

  return null;
}
