FROM node:alpine3.21
WORKDIR /app
COPY . .
RUN cd /app
RUN npm install
EXPOSE 3000
CMD ["node","app.js"] 