"use client";

import React, { useEffect, useState } from "react";

import { signIn } from "next-auth/react";
import Avatar from "@mui/material/Avatar";
import Button from "@mui/material/Button";
import TextField from "@mui/material/TextField";
import Link from "@mui/material/Link";
import Grid from "@mui/material/Grid";
import Box from "@mui/material/Box";
import LockOutlinedIcon from "@mui/icons-material/LockOutlined";
import Typography from "@mui/material/Typography";
import Container from "@mui/material/Container";
import Alert from "@mui/material/Alert";
// import StudySelector from "@/components/StudySelector";
import { useTranslations } from "next-intl";

function RegisterForm() {
  const usernameRef = React.useRef("");
  const passwordRef = React.useRef("");
  const repeatPasswordRef = React.useRef("");
  const nameRef = React.useRef("");
  const lastNameRef = React.useRef("");

  const [error, setError] = useState<string>("");

  // const [study, setStudy] = useState<string>("");

  const register = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    if (!validateForm()) {
      return;
    }

    try {
      const response = await fetch("/postcovid-dashboard/api/register", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email: usernameRef.current,
          password: passwordRef.current,
          name: nameRef.current,
          lastname: lastNameRef.current,
          // study: study,
        }),
      });

      if (response.status === 200) {
        signIn();
      } else {
        setError(response.statusText);
      }
    } catch (error) {
      console.log(error);
    }
  };

  const validateForm = () => {
    const email = usernameRef.current;
    const password = passwordRef.current;
    const repeatPassword = repeatPasswordRef.current;
    const name = nameRef.current;
    const lastName = lastNameRef.current;

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    const isEmailValid = emailRegex.test(email);

    if (
      !email ||
      !password ||
      !repeatPassword ||
      !name ||
      !lastName
      // !study
    ) {
      setError("All fields are required.");
      return false;
    }

    if (password !== repeatPassword) {
      setError("Passwords do not match.");
      return false;
    }

    if (!isEmailValid) {
      setError("Invalid email address.");
      return false;
    }

    setError("");
    return true;
  };

  // useEffect(() => {}, [study]);

  const t = useTranslations("register");

  return (


    <Container component="main" maxWidth="xs">
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
        <Box component="form" noValidate onSubmit={register} sx={{ mt: 3 }}>
          <Grid container spacing={2}>
            <Grid item xs={12} sm={6}>
              <TextField
                autoComplete="given-name"
                name="first_name"
                required
                fullWidth
                id="firstName"
                label={t("first_name")}
                onChange={(e) => (nameRef.current = e.target.value)}
                autoFocus
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                required
                fullWidth
                id="lastName"
                label={t("last_name")}
                name="last_name"
                onChange={(e) => (lastNameRef.current = e.target.value)}
                autoComplete="family-name"
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                required
                fullWidth
                id="email"
                label={t("email")}
                name="email"
                autoComplete="email"
                onChange={(e) => (usernameRef.current = e.target.value)}
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                required
                fullWidth
                name="password"
                label={t("password")}
                type="password"
                id="password"
                autoComplete="new-password"
                onChange={(e) => (passwordRef.current = e.target.value)}
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                required
                fullWidth
                name="repeat_password"
                label={t('password_confirmation')}
                type="password"
                id="repeat_password"
                autoComplete="new-password"
                onChange={(e) => (repeatPasswordRef.current = e.target.value)}
              />
            </Grid>
            {/* <Grid item xs={12}>
              <StudySelector value={study} setValue={setStudy} />
            </Grid> */}
          </Grid>
          <Button
            type="submit"
            fullWidth
            variant="contained"
            sx={{ mt: 3, mb: 2 }}
          >
            {t('title')}
          </Button>
          <Grid container justifyContent="flex-end">
            <Grid item>
              <Link href="/postcovid-dashboard/login" variant="body2">
              {t('already_have_account')}
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

export default RegisterForm;
