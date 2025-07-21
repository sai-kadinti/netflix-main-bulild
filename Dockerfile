FROM nginx:alpine
RUN rm -rf /var/www/html/*
COPY /dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
