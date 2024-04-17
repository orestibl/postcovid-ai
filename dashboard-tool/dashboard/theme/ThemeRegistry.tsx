"use client";

import { createTheme, ThemeOptions, ThemeProvider } from "@mui/material/styles";
import CssBaseline from "@mui/material/CssBaseline";
import { Ubuntu } from "next/font/google";

const ubuntu = Ubuntu({
  weight: ["300", "400", "500", "700"],
  style: ["normal", "italic"],
  subsets: ["latin"],
});

const themeOptions: ThemeOptions = {
  typography: {
    fontFamily: ubuntu.style.fontFamily,
    fontSize: 13,
  },

  palette: {
    primary: {
      main: "#5f868f",
      dark: "#517d87",
      light: "#689fab",
      contrastText: "#fff",
    },
    secondary: {
      main: "#6f94aa",
    },
    error: {
      main: "#e57373",
    },
  },
};

const theme = createTheme(themeOptions);

export default function ThemeRegistry({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      {children}
    </ThemeProvider>
  );
}
