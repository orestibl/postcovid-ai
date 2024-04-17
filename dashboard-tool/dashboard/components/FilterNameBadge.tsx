import React from "react";
import Badge, { BadgeProps } from "@mui/material/Badge";
import { styled } from "@mui/material/styles";

const StyledBadge = styled(Badge)<BadgeProps>(({ theme }) => ({
  "& .MuiBadge-badge": {
    // right: -3,
    left: 10,
    top: -6,
    // border: `1px solid ${theme.palette.background.paper}`,
    fontSize: "9px",
  },
}));

type FilterNameBadgeProps = {
  name: string;
  color: string;
  count: number;
};

export default function FilterNameBadge({
  name,
  color,
  count,
}: FilterNameBadgeProps) {
  return (
    <StyledBadge
      badgeContent={count}
      max={9999}
      color="primary"
      anchorOrigin={{
        vertical: "top",
        horizontal: "left",
      }}
    >
      <div
        className={`ml-1 pl-1 pr-1 mr-1 rounded-md text-white`}
        style={{ backgroundColor: color }}
      >
        {name}
      </div>
    </StyledBadge>
  );
}
