import NoStars from "./icons/stars/NoStars";
import OneStar from "./icons/stars/OneStar";
import TwoStars from "./icons/stars/TwoStars";
import ThreeStars from "./icons/stars/ThreeStars";
import FourStars from "./icons/stars/FourStars";
import FiveStars from "./icons/stars/FiveStars";
import type { CategoryIconProps } from "@/types/types";

export default function OverallWellbeing({
  color ,
  size,
  pos,
}: CategoryIconProps) {
  function getState() {
    const index = Math.floor(pos / 15);
    switch (index) {
      case 0:
        return <NoStars sx={{ fontSize: size, fill: color   }} />;
      case 1:
        return <OneStar sx={{ fontSize: size, fill: color   }} />;
      case 2:
        return <TwoStars sx={{ fontSize: size, fill: color   }} />;
      case 3:
        return <ThreeStars sx={{ fontSize: size, fill: color   }} />;
      case 4:
        return <FourStars sx={{ fontSize: size, fill: color   }} />;
      case 5:
        return <FourStars sx={{ fontSize: size, fill: color   }} />;
      case 6:
        return <FiveStars sx={{ fontSize: size, fill: color   }} />;
      default:
        return <FiveStars sx={{ fontSize: size, fill: color   }} />;
    }
  }
  return getState();
}
