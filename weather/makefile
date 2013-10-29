name = weather
# com_dir = ../../..//common/js
COM_DIR ?= /usr/share/dde/resources/common/js

COM_COFFEE = $(COM_DIR)/animation.coffee $(COM_DIR)/utils.coffee $(COM_DIR)/module.coffee $(COM_DIR)/selector.coffee $(COM_DIR)/utils.coffee $(COM_DIR)/widget.coffee

all: compile generate_mo


compile: $(COM_COFFEE) yahooservice.coffee weatherdata.coffee data.coffee clientcityid.coffee citymoremenu.coffee weather.coffee
	coffee -cj weather.js $^

generate_mo:
	cd ../; python ./generate_mo $(name)

update_po:
	cd ../; python ./update_po $(name)
