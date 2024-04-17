import { Injectable, Response, UnauthorizedException } from '@nestjs/common';
import { LoginDto } from './dto/auth.dto';
import { UserService } from '../user/user.service';
import { compare } from 'bcrypt';
import { JwtService } from '@nestjs/jwt';
import { MailService } from '../mail/mail.service';
import { CreateUserDto } from '../user/dto/create-user.dto';
require('dotenv').config();

// const expiresIn = 3600 * 1000;
const expiresIn = 3600 * 1000;

@Injectable()
export class AuthService {
  constructor(
    private userService: UserService,
    private jwtService: JwtService,
    private mailService: MailService,
  ) {}

  async register(dto: CreateUserDto) {
    const user = await this.userService.create(dto);

    this.mailService.sendUserConfirmation({"email": user.email, "name": user.name});

    return user;
  }

  async login(dto: LoginDto) {
    const user = await this.validateUser(dto);

    const payload = {
      username: user.email,
      sub: {
        name: user.name,
      },
    };

    return {
      user,
      tokens: {
        access_token: await this.jwtService.signAsync(payload, {
          expiresIn: '1h',
          secret: process.env.JWT_SECRET,
        }),
        refresh_token: await this.jwtService.signAsync(payload, {
          expiresIn: '7d',
          secret: process.env.JWT_SECRET_REFRESH,
        }),
        expires_in: new Date().setTime(new Date().getTime() + expiresIn),
      },
    };
  }

  async validateUser(dto: LoginDto) {
    const user = await this.userService.findOneByEmail(dto.email);

    console.log('User', user);

    if (!user?.verified) {
      console.log('User not verified', user);

      throw new UnauthorizedException();
    }

    if (user && (await compare(dto.password, user.password))) {
      const { password, ...result } = user;
      return result;
    }

    throw new UnauthorizedException();
  }

  async refreshToken(user: any) {
    const payload = {
      username: user.username,
      sub: user.sub,
    };

    return {
      tokens: {
        access_token: await this.jwtService.signAsync(payload, {
          expiresIn: '1h',
          secret: process.env.JWT_SECRET,
        }),
        refresh_token: await this.jwtService.signAsync(payload, {
          expiresIn: '7d',
          secret: process.env.JWT_SECRET_REFRESH,
        }),
        expires_in: new Date().setTime(new Date().getTime() + expiresIn),
      },
    };
  }
}
