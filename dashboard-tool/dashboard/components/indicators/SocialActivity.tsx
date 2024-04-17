import People from "./icons/People";
import People1 from "./icons/people/People1";
import People2 from "./icons/people/People2";
import People3 from "./icons/people/People3";
import People4 from "./icons/people/People4";
import People5 from "./icons/people/People5";
import People6 from "./icons/people/People6";
import People8 from "./icons/people/People8";
import type { CategoryIconProps } from "@/types/types";

export default function SocialActivity({
  color,
  size,
  pos,
}: CategoryIconProps) {
  function getState() {
    const index = Math.floor(pos / 15);

    switch (index) {
      case 0:
        return <People1 sx={{ fontSize: size, fill: color }} />;
      case 1:
        return <People2 sx={{ fontSize: size, fill: color  }} />;
      case 2:
        return <People3 sx={{ fontSize: size, fill: color  }} />;
      case 3:
        return <People4 sx={{ fontSize: size, fill: color  }} />;
      case 4:
        return <People5 sx={{ fontSize: size, fill: color  }} />;
      case 5:
        return <People6 sx={{ fontSize: size, fill: color  }} />;
      case 6:
        return <People8 sx={{ fontSize: size, fill: color  }} />;
      default:
        return <People sx={{ fontSize: size, fill: color  }} />;
    }
  }
  return getState();
}
