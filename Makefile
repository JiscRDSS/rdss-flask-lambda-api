COVERAGE_MIN = 40

server:
	@FLASK_APP=run.py flask run

server-debug:
	@$(shell FLASK_DEBUG=1 make server)

migrate:
	@./manage.py db upgrade

server-docker: migrate server

name:
	@echo $(shell basename $(PWD))

env:
	@virtualenv -p python3 env

deps:
	@pip install -r requirements.txt
	@pre-commit install

deps-update:
	@pip install -r requirements-to-freeze.txt --upgrade
	@pip freeze > requirements.txt

deps-uninstall:
	@pip uninstall -yr requirements.txt
	@pip freeze > requirements.txt

lint:
	@pre-commit run \
		--allow-unstaged-config \
		--all-files \
		--verbose

autopep8:
	@autopep8 . --recursive --in-place --pep8-passes 2000 --verbose

autopep8-stats:
	@pep8 --quiet --statistics .

config/testing.py:
	@cp config/testing.py.sample config/testing.py

test: config/testing.py
	@pytest --cov-fail-under $(COVERAGE_MIN) --cov=app --cov-report html:htmlcov

test-docker: migrate lint test

test-debug:
	@pytest --pdb

test-deploy:
	@http-prompt $(shell cd infra && terraform output api_url)

clean:
	@find . -name '__pycache__' | xargs rm -rf

.PHONY: deps* lint test* clean autopep8* migrate server*
