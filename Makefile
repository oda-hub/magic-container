REPO=odahub/magic
IMAGE=$(REPO):$(shell git describe --always)
CONTAINER=magic

listen: 
	gunicorn magic_data_server.backend_api:micro_service

run: build
	docker rm -f $(CONTAINER) || true
	docker run \
                -v $(PWD)/magic-backend/magic_data_server/config_dir/config.yml:/conf/magic_data_server/config.yml \
                -p 8000:5001 \
                -it \
	        --rm \
                --name $(CONTAINER) $(IMAGE)
	        #-e ODATESTS_BOT_PASSWORD=$(shell cat testbot-password.txt) \

build:
	rm -fv magic-backend/dist/*
	docker build --pull -t $(IMAGE) .

push: build
	docker push $(IMAGE)
	docker tag $(IMAGE) $(REPO):latest
	docker push $(REPO):latest

test:
	mypy *.py
	#pylint -E  *.py
	python -m pytest  -sv

.FORCE:
