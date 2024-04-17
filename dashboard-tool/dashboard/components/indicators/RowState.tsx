import EmotionalState from "./EmotionalState";
import PhysicalActivity from "./PhysicalActivity";
import SocialActivity from "./SocialActivity";
import OverallWellbeing from "./OverallWellbeing";
import { EMOTIONAL, PHYSICAL, SOCIAL, WELLBEING } from "./categories";
import type { RowStateProps } from "@/types/types";

export default function RowState({
  color,
  size,
  pos,
  category,
}: RowStateProps) {
  switch (category) {
    case EMOTIONAL:
      return <EmotionalState color={color} size={size} pos={pos} />;
    case PHYSICAL:
      return <PhysicalActivity color={color} size={size} pos={pos} />;
    case SOCIAL:
      return <SocialActivity color={color} size={size} pos={pos} />;
    case WELLBEING:
      return <OverallWellbeing color={color} size={size} pos={pos} />;
    default:
      return <OverallWellbeing color={color} size={size} pos={pos} />;
  }
}
