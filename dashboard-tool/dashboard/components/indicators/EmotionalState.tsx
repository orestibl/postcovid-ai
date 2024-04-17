import SentimentVerySatisfiedIcon from "@mui/icons-material/SentimentVerySatisfied";
import SentimentSatisfiedAltIcon from "@mui/icons-material/SentimentSatisfiedAlt";
import SentimentSatisfiedIcon from "@mui/icons-material/SentimentSatisfied";
import SentimentNeutralIcon from "@mui/icons-material/SentimentNeutral";
import SentimentDissatisfiedIcon from "@mui/icons-material/SentimentDissatisfied";
import SentimentVeryDissatisfiedIcon from "@mui/icons-material/SentimentVeryDissatisfied";
import MoodBadIcon from "@mui/icons-material/MoodBad";
import { CategoryIconProps } from "@/types/types";

export default function EmotionalState({
  color ,
  size,
  pos,
}: CategoryIconProps) {
  function getState() {
    const index = Math.floor(pos / 15);

    switch (index) {
      case 0:
        return <MoodBadIcon sx={{ fontSize: size, fill: color  }} />;
      case 1:
        return (
          <SentimentVeryDissatisfiedIcon
            sx={{ fontSize: size,  fill: color   }}
          />
        );
      case 2:
        return (
          <SentimentDissatisfiedIcon
            sx={{ fontSize: size, fill: color  }}
          />
        );
      case 3:
        return (
          <SentimentNeutralIcon sx={{ fontSize: size, fill: color  }} />
        );
      case 4:
        return (
          <SentimentSatisfiedIcon
            sx={{ fontSize: size, fill: color  }}
          />
        );
      case 5:
        return (
          <SentimentSatisfiedAltIcon
            sx={{ fontSize: size, fill: color  }}
          />
        );
      case 6:
        return (
          <SentimentVerySatisfiedIcon
            sx={{ fontSize: size, fill: color  }}
          />
        );
      default:
        return (
          <SentimentNeutralIcon sx={{ fontSize: size, fill: color  }} />
        );
    }
  }
  return getState();
}
