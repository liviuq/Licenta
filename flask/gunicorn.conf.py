wsgi_app = 'app:app'
bind = '0.0.0.0:8000'
accesslog = '-'
errorlog = '-'
loglevel = 'debug'
timeout = 60

# self-signed ssl certificate path
certfile = '/home/andrew/ssl/cert.pem'
keyfile = '/home/andrew/ssl/key.pem'
