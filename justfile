# Docs: https://just.systems/man/en/

project_name := "data-rev-mlops"
app_py := "TO_BE_DEFINED"
server_port := "TO_BE_DEFINED"

set dotenv-load

# show available commands
help:
  @just -l


secrets:
    #cp ../beach-swim/.secrets.toml .

# Create the local Python venv (.venv_{{project_name}}) and install requirements-dev/-deploy(.txt)

venv dev_deploy:
	#!/usr/bin/env bash
	pip-compile requirements-{{dev_deploy}}.in
	python3 -m venv .venv_{{dev_deploy}}_{{project_name}}
	. .venv_{{dev_deploy}}_{{project_name}}/bin/activate
	python3 -m pip install --upgrade pip
	pip install --require-virtualenv --log pip_install_{{project_name}}.log -r requirements-{{dev_deploy}}.txt
	python -m ipykernel install --user --name .venv_{{dev_deploy}}_{{project_name}}
	echo -e '\n' source .venv_{{dev_deploy}}_{{project_name}}/bin/activate '\n'

dev-venv:
	#!/usr/bin/env bash
	pip-compile requirements-dev.in
	python3 -m venv .venv_dev_{{project_name}}
	. .venv_dev_{{project_name}}/bin/activate
	python3 -m pip install --upgrade pip
	pip install --require-virtualenv --log pip_install_{{project_name}}.log -r requirements-dev.txt
	python -m ipykernel install --user --name .venv_dev_{{project_name}}
	echo -e '\n' source .venv_dev_{{project_name}}/bin/activate '\n'


# Note: no Jupyter or pytest etc in deploy
deploy-venv:
	#!/usr/bin/env bash
	pip-compile requirements-deploy.in -o requirements-deploy.txt
	python3 -m venv .venv_deploy_{{project_name}}
	. .venv_deploy_{{project_name}}/bin/activate
	python3 -m pip install --upgrade pip
	pip install --require-virtualenv -r requirements-deploy.txt
	echo -e '\n' source .venv_deploy_{{project_name}}/bin/activate '\n'


update-dev-reqs:
	python3 -m pip install --upgrade pip
	pip-compile requirements-dev.in
	pip install -r requirements-dev.txt --upgrade


update-deploy-reqs:
	python3 -m pip install --upgrade pip
	pip-compile requirements-deploy.in
	pip install -r requirements-deploy.txt --upgrade


alt-dev-pip-install:
	#!/usr/bin/env bash
	pip-compile requirements-dev.in
	python3 -m venv .venv_dev_{{project_name}}
	. .venv_dev_{{project_name}}/bin/activate
	cat requirements-dev.txt | cut -f1 -d"#" | sed '/^\s*$/d' | xargs -n 1 pip install
	python3 -m pip install --upgrade pip
	echo -e '\n' source .venv_dev_{{project_name}}/bin/activate '\n'


# See custom dvenv command defined in ~/.zshrc

rm-dev-venv:
	#!/usr/bin/env bash
	dvenv
	rm -rf .venv_dev_{{project_name}}


test:
    pytest

# Run app.py (in Streamlit) locally

run: 
    streamlit run {{app_py}} --server.port={{server_port}} --server.address=localhost

# Build and run app.py in a (local) Docker container

container: 
    docker build . -t {{project_name}}
    docker run -p {{server_port}}:{{server_port}} {{project_name}}