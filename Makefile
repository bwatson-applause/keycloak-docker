DOCKER_AVAILABLE:=$(shell docker info &> /dev/null && echo 0 || echo 1)

TARGET_DIR=target
IMAGE_TARGET_DIR=$(TARGET_DIR)/image

MODULES_TARGET_DIR=$(IMAGE_TARGET_DIR)/modules

POSTGRES_JAR_FILE=postgresql-9.3-1102-jdbc3.jar
POSTGRES_JAR_URL=http://central.maven.org/maven2/org/postgresql/postgresql/9.3-1102-jdbc3/$(POSTGRES_JAR_FILE)

POSTGRES_MODULE_TARGET_DIR=$(MODULES_TARGET_DIR)/system/layers/base/org/postgresql/jdbc/main
POSTGRES_JAR_TARGET=$(POSTGRES_MODULE_TARGET_DIR)/$(POSTGRES_JAR_FILE)
POSTGRES_MODULE_DESCRIPTOR=$(POSTGRES_MODULE_TARGET_DIR)/module.xml

JGROUP_MODULE_TARGET_DIR=$(MODULES_TARGET_DIR)/system/layers/base/org/jgroups/main
JGROUP_MODULE_DESCRIPTOR=$(JGROUP_MODULE_TARGET_DIR)/module.xml

CONFIG_SRC_DIR=$(IMAGE_TARGET_DIR)/configuration
CONFIG_TARGET_DIR=$(IMAGE_TARGET_DIR)/standalone/configuration

STANDALONE_CONFIG=configuration/standalone-ha.xml
STANDALONE_CONFIG_TARGET=$(CONFIG_TARGET_DIR)/standalone.xml

KEYCLOAK_SERVER_CONFIG=configuration/keycloak-server.json
KEYCLOAK_SERVER_CONFIG_TARGET=$(CONFIG_TARGET_DIR)/keycloak-server.json

IMAGE_CONTENTS=\
	$(POSTGRES_MODULE_DESCRIPTOR) \
	$(POSTGRES_JAR_TARGET) \
	$(JGROUP_MODULE_DESCRIPTOR) \
	$(STANDALONE_CONFIG_TARGET) \
	$(KEYCLOAK_SERVER_CONFIG_TARGET)

all: $(IMAGE_CONTENTS)
ifeq ($(DOCKER_AVAILABLE),1)
	$(error Docker is not available in the current environment)
endif
	@docker version
	@docker build -t applause/keycloak .

.PHONY: clean

clean:
	@echo Cleaning target directory.
	@rm -rf $(TARGET_DIR)

$(POSTGRES_MODULE_DESCRIPTOR): modules/postgres/module.xml
	@echo Creating PostgreSQL module descriptor.
	@mkdir -p $(POSTGRES_MODULE_TARGET_DIR)
	@cat modules/postgres/module.xml | sed 's/$$POSTGRES_JAR_FILE/$(POSTGRES_JAR_FILE)/g' > $(POSTGRES_MODULE_DESCRIPTOR)

$(POSTGRES_JAR_TARGET):
	@echo Downloading PostgreSQL JDBC jar file.
	@mkdir -p $(POSTGRES_MODULE_TARGET_DIR)
	@curl -\# -o $(POSTGRES_MODULE_TARGET_DIR)/$(POSTGRES_JAR_FILE) $(POSTGRES_JAR_URL)
	@jar -tf $(POSTGRES_MODULE_TARGET_DIR)/$(POSTGRES_JAR_FILE) &> /dev/null

$(JGROUP_MODULE_DESCRIPTOR): modules/jgroups/module.xml
	@mkdir -p $(JGROUP_MODULE_TARGET_DIR)
	@cp -v modules/jgroups/module.xml $(JGROUP_MODULE_DESCRIPTOR)

$(STANDALONE_CONFIG_TARGET): $(STANDALONE_CONFIG)
	@mkdir -p $(CONFIG_TARGET_DIR)
	@cp -v $(STANDALONE_CONFIG) $(STANDALONE_CONFIG_TARGET)

$(KEYCLOAK_SERVER_CONFIG_TARGET): $(KEYCLOAK_SERVER_CONFIG)
	@mkdir -p $(CONFIG_TARGET_DIR)
	@cp -v $(KEYCLOAK_SERVER_CONFIG) $(KEYCLOAK_SERVER_CONFIG_TARGET)
