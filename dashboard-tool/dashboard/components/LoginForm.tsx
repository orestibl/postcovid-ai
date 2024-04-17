"use client";

import React from "react";
import Avatar from "@mui/material/Avatar";
import Button from "@mui/material/Button";
import CssBaseline from "@mui/material/CssBaseline";
import TextField from "@mui/material/TextField";
import FormControlLabel from "@mui/material/FormControlLabel";
import Checkbox from "@mui/material/Checkbox";
import Link from "@mui/material/Link";
import Grid from "@mui/material/Grid";
import Box from "@mui/material/Box";
import LockOutlinedIcon from "@mui/icons-material/LockOutlined";
import Typography from "@mui/material/Typography";
import Container from "@mui/material/Container";
import { signIn } from "next-auth/react";
import Alert from "@mui/material/Alert";
import { useRouter } from "next/navigation";
import { useTranslations } from "next-intl";

type Props = {
  callbackUrl?: string;
  error?: string;
};

function LoginForm(props: Props) {
  const router = useRouter();

  const t = useTranslations("login");

  const usernameRef = React.useRef("");
  const passwordRef = React.useRef("");

  const [error, setError] = React.useState<string>("");

  const validateForm = () => {
    const username = usernameRef.current;
    const password = passwordRef.current;
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!username || !password) {
      setError("Username and password are required.");
      return false;
    } else if (!emailRegex.test(username)) {
      setError("Please enter a valid email address.");
      return false;
    }
    return true;
  };

  const login = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    if (!validateForm()) {
      return;
    }

    const res = await signIn("credentials", {
      username: usernameRef.current,
      password: passwordRef.current,
      redirect: false,
      callbackUrl: "/dashboard/charts/main",
    });

    if (res?.ok) {
      router.push("/dashboard/charts/main");
    } else if (res?.status === 401) {
      setError("Unauthorized");
    }
  };

  return (
    <Container component="main" maxWidth="xs">
      <CssBaseline />
      <Box
        sx={{
          marginTop: 8,
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
        }}
      >
        <Avatar sx={{ m: 1, bgcolor: "secondary.main" }}>
          <LockOutlinedIcon />
        </Avatar>
        <Typography component="h1" variant="h5">
          {t('title')}
        </Typography>
        <Box component="form" onSubmit={login} noValidate sx={{ mt: 1 }}>
          <TextField
            margin="normal"
            required
            fullWidth
            id="email"
            label={t('email')}
            name="email"
            autoComplete="email"
            autoFocus
            onChange={(e) => (usernameRef.current = e.target.value)}
          />
          <TextField
            margin="normal"
            required
            fullWidth
            name="password"
            label={t('password')}
            type="password"
            onChange={(e) => (passwordRef.current = e.target.value)}
            id="password"
            autoComplete="current-password"
          />
          <FormControlLabel
            control={<Checkbox value="remember" color="primary" />}
            label="Remember me"
          />
          <Button
            type="submit"
            fullWidth
            variant="contained"
            color="primary"
            sx={{ mt: 3, mb: 2 }}
          >
            {t('title')}
          </Button>
          <Grid container>
            <Grid item xs>
              <Link href="#" variant="body2">
                Forgot password?
              </Link>
            </Grid>
            <Grid item>
              <Link href="/postcovid-dashboard/signup" variant="body2">
                {t('dont_have_account')}
              </Link>
            </Grid>
          </Grid>
        </Box>
      </Box>

      {error && (
        <Box sx={{ mt: 2 }}>
          <Alert severity="error">{error}</Alert>
        </Box>
      )}
    </Container>
  );
}

export default LoginForm;
