FROM node:20-alpine AS build

# restore front end
WORKDIR /frontend

COPY frontend/package.json /frontend/package.json
COPY frontend/package-lock.json /frontend/package-lock.json
RUN npm install

# restore back end
WORKDIR /backend

COPY backend/package.json /backend/package.json
COPY backend/package-lock.json /backend/package-lock.json
RUN npm install

# build front end
WORKDIR /frontend
COPY frontend/ /frontend/
RUN npm run build

# build back end
WORKDIR /backend
COPY backend/ /backend/
RUN npm run build

FROM node:20-alpine as run

COPY --from=build /backend /backend
COPY --from=build /frontend/build /frontend

# write production env variables
RUN echo "PORT=8000" > /backend/.env
RUN echo "STATIC_ROOT=/frontend/" >> /backend/.env

ENV PORT 8000

# run the server
WORKDIR /backend
CMD npm start