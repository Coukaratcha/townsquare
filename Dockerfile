FROM node:alpine AS build
WORKDIR /usr/src/app
COPY package.json ./
RUN npm install
COPY --parents public/ server/ src/ .eslintrc.js vue.config.js ./
RUN npm run build

FROM nginx:alpine
WORKDIR /usr/share/nginx/html
COPY --from=build /usr/src/app/dist ./
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]
