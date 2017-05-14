from flask import Blueprint
from flask import request, jsonify
from werkzeug.exceptions import BadRequest

from app.models import Artist, Album, db
from .errors import unprocessable_entity, error_message
from .schemas import paginator_schema, artist_schema, album_schema

api = Blueprint('api', __name__)


@api.app_errorhandler(404)
def handle404(error=None):
    return error_message(404, 'Not found url {}'.format(request.url))


@api.app_errorhandler(405)
def handle405(error=None):
    return error_message(405, 'Method not supported')


@api.app_errorhandler(500)
def handle500(error=None):
    return error_message(500, 'Something went wrong')


def get_paginator():
    paginator, errors = paginator_schema.load(request.args)
    if errors:
        raise BadRequest(errors)
    return paginator


@api.route('/healthz', methods=('HEAD', 'GET'))
def handle_healthcheck():
    return 'ok'


@api.route('/artists', methods=('GET', 'POST'))
def handle_artists():
    if request.method == 'POST':
        artist, errors = artist_schema.load(request.form, session=db.session)
        if errors:
            return unprocessable_entity(errors)

        db.session.add(artist)
        db.session.commit()

        return jsonify(artist_schema.dump(artist).data)

    paginator = get_paginator()
    artists = Artist.query.order_by('id').paginate(
        page=paginator['page'],
        per_page=paginator['per_page'],
        error_out=False
    ).items

    return jsonify(artist_schema.dump(artists, many=True).data)


@api.route('/artist/<int:artist_id>', methods=('GET', 'PUT', 'DELETE'))
def handle_artist(artist_id):
    if request.method == 'PUT':
        artist = Artist.query.get_or_404(artist_id)
        artist, errors = artist_schema.load(
            request.form,
            partial=True,
            instance=artist,
            session=db.session
        )
        if errors:
            return unprocessable_entity(errors)

        db.session.add(artist)
        db.session.commit()

        return jsonify(artist_schema.dump(artist).data)

    if request.method == 'DELETE':
        artist = Artist.query.get_or_404(artist_id)

        Album.query.filter_by(artist_id=artist_id).delete()
        db.session.delete(artist)
        db.session.commit()

        return '', 204

    artist = Artist.query.get_or_404(artist_id)
    return jsonify(artist_schema.dump(artist).data)


@api.route('/albums', methods=('GET', 'POST'))
def handle_albums():
    if request.method == 'POST':
        album, errors = album_schema.load(request.form, session=db.session)
        if errors:
            return unprocessable_entity(errors)

        db.session.add(album)
        db.session.commit()

        return jsonify(album_schema.dump(album).data)

    paginator = get_paginator()
    albums = Album.query.order_by('id').paginate(
        page=paginator['page'],
        per_page=paginator['per_page'],
        error_out=False
    ).items

    return jsonify(album_schema.dump(albums, many=True).data)


@api.route('/album/<int:album_id>', methods=('GET', 'PUT', 'DELETE'))
def handle_album(album_id):
    if request.method == 'PUT':
        album = Album.query.get_or_404(album_id)
        album, errors = album_schema.load(
            request.form,
            partial=True,
            instance=album,
            session=db.session
        )
        if errors:
            return unprocessable_entity(errors)

        db.session.add(album)
        db.session.commit()
        return jsonify(album_schema.dump(album).data)

    if request.method == 'DELETE':
        album = Album.query.get_or_404(album_id)
        db.session.delete(album)
        db.session.commit()

        return '', 204

    album = Album.query.get_or_404(album_id)
    return jsonify(album_schema.dump(album).data)
