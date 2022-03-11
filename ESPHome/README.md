# Theme for ESPhome

Create a directory on your Home Assistant server to host the .css file
```
homeAssistant/www/ESPHome
```

In your esphome .yaml config
```
web_server:
  port: 80
  css_url: http://192.168.1.6:8123/local/ESPHome/webserver-night.min.css
```

***Theme 1:***
![Final Installation](./night.png "Theme Installation")
***Theme 2:***
![Final Installation](./v1-night.png "Theme Installation")

***More documentation:***

https://esphome.io/components/web_server.html