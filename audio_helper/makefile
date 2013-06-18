# com_dir = ../../../common/js
COM_DIR ?= /usr/share/dde/resources/common/js

all: $(wildcard $(COM_DIR)/*.coffee) audio_helper.coffee
	coffee -cj audio_helper.js $^
