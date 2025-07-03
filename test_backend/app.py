from flask import Flask, send_from_directory, abort
import os
import time

app = Flask(__name__)

# Folder where images are stored
IMAGE_FOLDER = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'images')

# Delay time in seconds (you can change this value)
RESPONSE_DELAY_SECONDS = 0.7

@app.route('/images/<path:filename>')
def serve_image(filename):
    time.sleep(RESPONSE_DELAY_SECONDS)  # Add artificial lag

    try:
        return send_from_directory(IMAGE_FOLDER, filename)
    except FileNotFoundError:
        abort(404)

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=3000, debug=True)
