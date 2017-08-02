FROM armhf/node

MAINTAINER SilentProtest

RUN npm install -g mocha grunt-cli bower karma-cli

RUN git clone --depth 1 --recursive https://github.com/linagora/hublin.git /src

RUN cd /src && npm install --production --unsafe-perm

RUN cd /src/modules/hublin-easyrtc-connector && npm install --production

RUN cp /src/config/db.json.docker /src/config/db.json

ENV HUBLIN_REDIS_HOST redis
ENV HUBLIN_REDIS_PORT 6379
ENV HUBLIN_MONGO_HOST video_mongo
ENV HUBLIN_MONGO_PORT 27017

RUN sed -i "s|mongodb://db:27017/hublin|mongodb://${HUBLIN_MONGO_HOST}:${HUBLIN_MONGO_PORT}/hublin|g" /src/config/db.json

EXPOSE  8080

WORKDIR /src
CMD ["npm", "start"]
