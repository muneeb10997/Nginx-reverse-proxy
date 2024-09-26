#!/bin/bash
sudo apt update
sudo apt install python3-flask -y
sudo curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

mkdir flask-nginx
cd flask-nginx

mkdir app1
cd app1
echo "from flask import Flask

app1 = Flask(__name__)

@app1.route('/')
def home():
    return 'Hello from the home page of App1!'

if __name__ == '__main__':
    app1.run(debug=True, host='0.0.0.0', port=5000)" > main.py

echo 'FROM python:3.10.12

WORKDIR /app1-dir

COPY . .

RUN pip install flask

CMD [ "python", "main.py" ]' > Dockerfile

echo ".*
..*
Dockerfile" > .dockerignore

cd ..

mkdir app2
cd app2
echo "from flask import Flask

app2 = Flask(__name__)

@app2.route('/home')
def home():
    return 'Hello from the home page of App2!'

if __name__ == '__main__':
    app2.run(debug=True, host='0.0.0.0', port=5000)" > main.py

echo 'FROM python:3.10.12

WORKDIR /app2-dir

COPY . .

RUN pip install flask

CMD [ "python", "main.py" ]' > Dockerfile

echo ".*
..*
Dockerfile" > .dockerignore


cd ..

echo "version: '3'
services:
  app1-cont:
    build:
      context: /home/muneeb/Documents/Nginx-reverse-proxy/flask-nginx/app1
      dockerfile: Dockerfile 
    image: app1-img:1
  
    ports:
      - '5001:5000'
    container_name: app1-cont
    networks:
      - my_network
    volumes:
      - app1_volume:/app1-dir

  app2-cont:
    build:
      context: /home/muneeb/Documents/Nginx-reverse-proxy/flask-nginx/app2 
      dockerfile: Dockerfile  
    image: app2-img:1 
    ports:
      - '5002:5000'
    container_name: app2-cont
    networks:
      - my_network
    volumes:
      - app2_volume:/app2-dir

  nginx-cont:
    image: nginx:latest  
    container_name: nginx-cont
    ports:
      - '80:80'
    networks:
      - my_network
    volumes:
      - /home/muneeb/Documents/Nginx-reverse-proxy/nginx.conf:/etc/nginx/nginx.conf

networks:
  my_network:
    driver: bridge
    name: my_network

volumes:
  app1_volume:
    name: app1_volume
  app2_volume:
    name: app2_volume" > docker-compose.yml
cd ..
touch nginx.conf