import { DataSource } from 'typeorm';
require('dotenv').config();

export const dataSource: DataSource = new DataSource({
  name: 'indicators',
  type: 'postgres',
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT),
  username: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  synchronize: true,
});
