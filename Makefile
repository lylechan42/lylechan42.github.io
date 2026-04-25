.PHONY: help install build serve clean fix-permissions

DOCKER_IMAGE ?= ruby:3.2
PORT ?= 4000
JEKYLL_ENV ?= development

# Run Ruby/Jekyll as your host user, not as root, so generated files remain editable.
DOCKER_RUN = docker run --rm -it \
	--user "$$(id -u):$$(id -g)" \
	-v "$${PWD}":/srv/jekyll \
	-w /srv/jekyll \
	-e HOME=/tmp \
	-e BUNDLE_PATH=vendor/bundle \
	-e BUNDLE_APP_CONFIG=/tmp/bundle \
	-e JEKYLL_ENV=$(JEKYLL_ENV) \
	$(DOCKER_IMAGE)

help:
	@printf '%s\n' 'Targets:'
	@printf '%s\n' '  make install          Install Ruby gems into ignored vendor/bundle/'
	@printf '%s\n' '  make build            Compile the site into _site/'
	@printf '%s\n' '  make serve            Serve local preview at http://127.0.0.1:4000/'
	@printf '%s\n' '  make clean            Remove generated Jekyll/Bundler artifacts'
	@printf '%s\n' '  make fix-permissions  Chown root-owned files in this repo back to you'

install:
	$(DOCKER_RUN) bash -lc 'git config --global --add safe.directory /srv/jekyll && bundle install'

build:
	$(DOCKER_RUN) bash -lc 'git config --global --add safe.directory /srv/jekyll && bundle install && bundle exec jekyll build'

serve:
	docker run --rm -it \
		--user "$$(id -u):$$(id -g)" \
		-p $(PORT):$(PORT) \
		-v "$${PWD}":/srv/jekyll \
		-w /srv/jekyll \
		-e HOME=/tmp \
		-e BUNDLE_PATH=vendor/bundle \
		-e BUNDLE_APP_CONFIG=/tmp/bundle \
		-e JEKYLL_ENV=$(JEKYLL_ENV) \
		$(DOCKER_IMAGE) \
		bash -lc 'git config --global --add safe.directory /srv/jekyll && bundle install && bundle exec jekyll serve --host 0.0.0.0 --port $(PORT)'

clean:
	rm -rf _site .jekyll-cache .sass-cache vendor/bundle

fix-permissions:
	sudo find . -user root -exec chown -h "$$(id -u):$$(id -g)" {} +
