FROM node:18-alpine

WORKDIR /app

ENV JWT_SECRET=otLegjKKk0xxNumOeAomfTBfMJ8r2HMFfszcdDVtCzUiAwCfiyvLFS8kgwzkYjszKh2qxImrTqrxZKsf0GNg
ENV JWT_SECRET_REFRESH=DUODkSDT5ZJBz9cQMuTYTANK4784q4XyLw0PsWzB5elGaUmhxtaUEfAN0w8GbNWATBtMPXjL5os9maHWzLQ

COPY package*.json .

RUN npm install

COPY . .

ENTRYPOINT  [ "npm", "run","start" ]



