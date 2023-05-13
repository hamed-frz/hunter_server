from flask import Flask, request
import requests
import flask
import urllib
app = Flask(__name__)

@app.route('/reqSSRF', methods=['GET', 'POST','OPTIONS'])
def send_request():
    # Extract HTTP parts of the request
    http_method = request.method
    http_url = request.url
    http_headers = request.headers
    http_data = str(request.get_data())

    # Send HTTP parts to Discord webhook
    webhook_url = "__SSRF_DISCORD__"
    webhook_data = {}

    message = [{ "description":f"\
                              Sender ip address:\n{request.headers.getlist('X-Forwarded-For')[0]}\n\n \
                              -------------------------------------------------------------------------\n\
                             ```Method: {http_method} \nURL: {http_url} \n\nHeaders:\n{http_headers}\nData:\n{http_data}```", \
                             "title":"SSRF Blind Report", \
                             }]

    webhook_data["embeds"] = message

    requests.post(webhook_url, json = webhook_data)


    # Set Access-Control-Allow-Origin header to allow all origins
    response_headers = {
        'Access-Control-Allow-Origin': '*'
    }
    response = "OK\n"
    resp = flask.Response(response)
    resp.headers['Access-Control-Allow-Origin'] = request.environ.get('HTTP_ORIGIN', 'default value')
    return resp


if __name__ == '__main__':
    app.run()
