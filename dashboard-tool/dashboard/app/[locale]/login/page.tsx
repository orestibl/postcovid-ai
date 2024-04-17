"use client"

import React from 'react'
import LoginForm from '@/components/LoginForm'

type Props = {
    searchParams?: Record<"callbackUrl" | "error", string>   
}

function Login(props: Props) {
    
    return <LoginForm error={props.searchParams?.error} callbackUrl={props.searchParams?.callbackUrl} />
}

export default Login