
import { CanActivate, ExecutionContext, Injectable, UnauthorizedException } from "@nestjs/common";
import {JwtService} from '@nestjs/jwt';
import { Request } from 'express';
require('dotenv').config();


@Injectable()
export class RefreshJwtGuard implements CanActivate  {

    constructor(private jwtService: JwtService) {}

    async canActivate(context: ExecutionContext): Promise<boolean>  {
        
        const req = context.switchToHttp().getRequest();
        
        const token = this.getTokenFromHeader(req);

        if (!token) {
            throw new UnauthorizedException()
        }

        try{
            
        const payload = await this.jwtService.verifyAsync(token, {secret: process.env.JWT_SECRET_REFRESH});

        req.user = payload;

        }catch(e) {
            throw new UnauthorizedException()
        }

        return true;

    }   

    private getTokenFromHeader(req: Request) {
        const authHeader = req.headers.authorization;

        const [type, token] = authHeader.split(' ') ?? [];

        return type === 'Refresh' ? token : undefined;
    }
}