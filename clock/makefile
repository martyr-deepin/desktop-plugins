# com_dir = ../../../common/js
COM_DIR ?= /usr/share/dde/resources/common/js

all: $(wildcard $(COM_DIR)/*.coffee) clock.coffee
	coffee -cj clock.js $^
