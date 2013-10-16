# com_dir = ../../../common/js
COM_DIR ?= /usr/share/dde/resources/common/js

COM_COFFEE = $(COM_DIR)/animation.coffee $(COM_DIR)/utils.coffee $(COM_DIR)/module.coffee $(COM_DIR)/selector.coffee $(COM_DIR)/utils.coffee $(COM_DIR)/widget.coffee

all: ${COM_COFFEE} clock.coffee
	coffee -cj clock.js $^
