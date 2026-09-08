import os

from flask import Flask


def create_app() -> Flask:
    # create and configure the app
    app = Flask(__name__, instance_relative_config=True)

    # ensure the instance folder exists
    os.makedirs(app.instance_path, exist_ok=True)

    # a simple page that says hello
    @app.route("/hello")
    def hello() -> str:
        return "Hello, World!"

    return app
