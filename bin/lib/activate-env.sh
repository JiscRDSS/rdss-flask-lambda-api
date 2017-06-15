#!/usr/bin/env bash


sourceEnv() {
	if [[ -f .env ]]; then
		. .env
	fi
}

sourceDeployTerraform() {
	if [[ -f .env.deploy ]]; then
		. .env.deploy
	fi
}

activatePythonEnv() {
	if [[ ! -d env ]]; then
		make env
	fi

	if [[ $VIRTUAL_ENV != $PWD/env ]]; then
		. env/bin/activate
	fi
}
