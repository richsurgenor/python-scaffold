PACKAGE = package_name

DOCKER_IMAGE = $(PACKAGE)-env
DOCKER_HOST_USER_PERMS = -v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro
DOCKER_VOLUMES = -v $(PWD):/tmp/build $(DOCKER_HOST_USER_PERMS)
DOCKER_USER = -u $(shell id -u):$(shell id -g)
DOCKER_RUN_FLAGS = --rm $(DOCKER_VOLUMES) $(DOCKER_USER) -w /tmp/build
DOCKER_COMMAND_BASE = docker run --rm $(DOCKER_RUN_FLAGS) $(DOCKER_IMAGE)

ENVIRONMENTS = analysis py27-test py3-test
DOCKER_ENVIRONMENTS = $(patsubst %,%-docker,$(ENVIRONMENTS))
ENVIRONMENT = $(patsubst %-docker, %, $@)
ENVIRONMENT_METAS = $(patsubst %,.python_scaffold_meta_venv_%,$(ENVIRONMENTS))
DOCKER_ENVIRONMENT_METAS = $(patsubst %,.python_scaffold_meta_venv_%,$(DOCKER_ENVIRONMENTS))


usage:
	@echo "***********************************************************************************"
	@echo "all - Runs all default tox environments"
	@echo "$(ENVIRONMENTS) - run tox -e <environment>"
	@echo "target-docker - run target in docker environment (e.g all-docker, py27-test-docker)"
	@echo "clean - clean up generated files"
	@echo "***********************************************************************************"


all: $(ENVIRONMENT_METAS)
	tox

.SECONDEXPANSION:

.PHONY: $(ENVIRONMENTS)
$(ENVIRONMENTS): .python_scaffold_meta_venv_$$@
	tox -e $(ENVIRONMENT)

.PHONY: all-docker
all-docker: build-docker $(DOCKER_ENVIRONMENT_METAS)
	$(DOCKER_COMMAND_BASE) tox

.PHONY: $(DOCKER_ENVIRONMENTS)
$(DOCKER_ENVIRONMENTS): build-docker .python_scaffold_meta_venv_$$@
	$(DOCKER_COMMAND_BASE) tox -e $(ENVIRONMENT)

.PHONY: build-docker
build-docker: .python_scaffold_meta_docker_build



clean:
	@find . -regextype posix-egrep -regex "cache|(.+py[oc])" -delete
	@rm -rf .py27 .py3 .analysis *cov* *results* $(PACKAGE).egg-info .tox .audit .coverage .cache  .python_scaffold_meta* dist/ build/

# Special targets to force venv regeneration
# on requirement file changes
.python_scaffold_meta_docker_build: Dockerfile
	docker build --tag $(DOCKER_IMAGE) .
	@touch $@

.python_scaffold_meta_venv_analysis: analysis-requirements.txt
	@echo "(Re-)creating virtualenv for analysis"
	tox --notest -r -e analysis
	@touch $@

.python_scaffold_meta_venv_py27-test: requirements.txt test-requirements.txt
	@echo "(Re-)creating virtualenv for py27-test"
	tox --notest -r -e py27-test
	@touch $@

.python_scaffold_meta_venv_py3-test: requirements.txt test-requirements.txt
	@echo "(Re-)creating virtualenv for py3-test"
	tox --notest -r -e py3-test
	@touch $@


.python_scaffold_meta_venv_analysis-docker: analysis-requirements.txt .python_scaffold_meta_docker_build
	@echo "(Re-)creating virtualenv for analysis (Docker)"
	$(DOCKER_COMMAND_BASE) tox --notest -r -e analysis
	@touch $@

.python_scaffold_meta_venv_py27-test-docker: requirements.txt test-requirements.txt .python_scaffold_meta_docker_build
	@echo "(Re-)creating virtualenv for py27-test (Docker)"
	$(DOCKER_COMMAND_BASE) tox --notest -r -e py27-test
	@touch $@

.python_scaffold_meta_venv_py3-test-docker: requirements.txt test-requirements.txt .python_scaffold_meta_docker_build
	@echo "(Re-)creating virtualenv for py3-test (Docker)"
	$(DOCKER_COMMAND_BASE) tox --notest -r -e py3-test
	@touch $@
