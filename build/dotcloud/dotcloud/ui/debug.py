import socket
import time
import wsgiref.handlers

from ..client.client import RESTClient

# Monkey patch socket.create_connection to track the IP address, port,
# and timestamp of TCP connections that we create.
# What we really want to know is which API endpoint was contacted, and
# when, to report it when an error occurs.
# WARNING: this is absolutely not thread- or async- safe. Yuck!
# However, requests/urllib3 do not expose the necessary hooks to get
# this information cleanly and reliably.
_real_create_connection = socket.create_connection
def _fake_create_connection(*args, **kwargs):
    global_endpoint_info.clear()
    sock = _real_create_connection(*args, **kwargs)
    remotehost, remoteport = sock.getpeername()
    localtimestamp = wsgiref.handlers.format_date_time(time.time())
    global_endpoint_info['remotehost'] = remotehost
    global_endpoint_info['remoteport'] = remoteport
    global_endpoint_info['timestamp'] = localtimestamp
    global_endpoint_info['timesource'] = 'local'
    global_endpoint_info['localtimestamp'] = localtimestamp
    global_endpoint_info['remotetimestamp'] = None
    return sock
socket.create_connection = _fake_create_connection

# Likewise, monkey patch make_response to intercept HTTP headers,
# and save the remote server date.
_real_make_response = RESTClient.make_response
def _fake_make_response(self, res, *args, **kwargs):
    remotetimestamp = res.headers.get('Date')
    if remotetimestamp:
        global_endpoint_info['timestamp'] = remotetimestamp
        global_endpoint_info['timesource'] = 'remote'
        global_endpoint_info['remotetimestamp'] = remotetimestamp
    return _real_make_response(self, res, *args, **kwargs)
RESTClient.make_response = _fake_make_response

global_endpoint_info = {}
