import ManIcon from "@mui/icons-material/Man";
import DirectionsWalkIcon from "@mui/icons-material/DirectionsWalk";
import DirectionsRunIcon from "@mui/icons-material/DirectionsRun";
import DirectionsBikeIcon from "@mui/icons-material/DirectionsBike";
import DownhillSkiingIcon from "@mui/icons-material/DownhillSkiing";
import Reading from "./icons/Reading";
import RunningFast from "./icons/RunningFast";
import type { CategoryIconProps } from "@/types/types";

export default function PhysicalActivity({
  color,
  size,
  pos,
}: CategoryIconProps) {
  function getState() {
    const index = Math.floor(pos / 15);
  
    switch (index) {
      case 0:
        return <Reading sx={{ fontSize: size, fill: color    }} />;
      case 1:
        return <ManIcon sx={{ fontSize: size, fill: color    }} />;
      case 2:
        return (
          <DirectionsWalkIcon sx={{ fontSize: size, fill: color    }} />
        );
      case 3:
        return (
          <DirectionsRunIcon sx={{ fontSize: size, fill: color    }} />
        );
      case 4:
        return <RunningFast sx={{ fontSize: size, fill: color    }} />;
      case 5:
        return (
          <DirectionsBikeIcon sx={{ fontSize: size, fill: color    }} />
        );
      case 6:
        return (
          <DownhillSkiingIcon sx={{ fontSize: size, fill: color    }} />
        );
      default:
        return (
          <DownhillSkiingIcon sx={{ fontSize: size, fill: color    }} />
        );
    }
  }
  return getState();
}
