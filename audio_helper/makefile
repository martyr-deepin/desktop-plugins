# com_dir = ../../../common/js
COM_DIR ?= /usr/share/dde/resources/common/js

all: $(COM_DIR)/module.coffee $(COM_DIR)/selector.coffee $(COM_DIR)/animation.coffee $(COM_DIR)/widget.coffee $(COM_DIR)/plugin.coffee $(COM_DIR)/utils.coffee audio_helper.coffee
	coffee -cj audio_helper.js $^
