import logging
import os

import flask
import ai


CLIENT_SECRET = "2Iboq5atXoARn1DrUnqUVfVGKaRcHXp1" # TODO


app = flask.Flask(__name__)

logging_ai: ai.AI = ai.AI()

os.environ["OPENAI_API_KEY"] = ai.openai_api_key


@app.route("/", methods=["GET"])
def main():
    message: str = flask.request.args.get("message")
    log_file: str = flask.request.args.get("logFile")
    session_id: str = flask.request.args.get("sessionId")

    logging.info(f"Received new request from sessionq {session_id} with message: {message}")

    return logging_ai.generate_response(message, log_file, session_id), 200


if __name__ == "__main__":
    logging.info("Starting server...")
    app.run(host='0.0.0.0', port=5000)
