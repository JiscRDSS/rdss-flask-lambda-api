from flask_lambda import FlaskLambda

from .models import db


def create_app():
    app = FlaskLambda(__name__)
    # Load the default configuration
    app.config.from_object('config.default')
    # Load the file specified by the APP_CONFIG_FILE environment variable
    # Variables defined here will override those in the default configuration
    app.config.from_envvar('APP_CONFIG_FILE')

    from .api import api as api_blueprint

    db.init_app(app)

    # register blueprint
    app.register_blueprint(api_blueprint)

    return app
