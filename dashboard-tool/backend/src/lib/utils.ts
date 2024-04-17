import { JwtService } from '@nestjs/jwt';
import { Request } from 'express';
import { UserService } from '../user/user.service';

export const getUserFromHeaders = async (
  request: Request,
  jwtService: JwtService,
  userService: UserService,
) => {
  const authHeader = request.headers.authorization;

  if (!authHeader) {
    return;
  }

  const token = authHeader.split(' ')[1];

  const payload = await jwtService.verifyAsync(token, {
    secret: process.env.JWT_SECRET,
  });

  const user = await userService.findOneByEmail(payload.username);

  return user;
};

export enum CriterionType {
  'RANGE',
  'VALUE',
}
