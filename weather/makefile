name = weather
# com_dir = ../../..//common/js
COM_DIR ?= /usr/share/dde/resources/common/js

COM_COFFEE = $(wildcard $(COM_DIR)/*.coffee)

all: compile generate_mo


compile: $(COM_COFFEE) $(wildcard ./*.coffee)
	coffee -cj weather.js $^

generate_mo:
	cd ../; python ./generate_mo $(name)

update_po:
	cd ../; python ./update_po $(name)
