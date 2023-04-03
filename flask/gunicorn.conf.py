wsgi_app = 'app:app'
bind = '0.0.0.0:8000'
accesslog = '-'
errorlog = '-'
loglevel = 'debug'

# self-signed ssl certificate path
certfile = '/home/andrew/ssl/cert.pem'
keyfile = '/home/andrew/ssl/key.pem'
