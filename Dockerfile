FROM node:alpine3.21
WORKDIR /app
ADD /application/ .
RUN npm install
EXPOSE 3000
CMD ["node","app.js"] 