# com_dir = ../../..//common/js
com_dir = /usr/share/dde/resources/common/js

com_coffee = $(wildcard $(com_dir)/*.coffee)

all: compile generate_mo


compile: ${com_coffee} $(wildcard ./*.coffee)
	coffee -cj weather.js $^

generate_mo:
	python ./mo_generator

update_po:
	python ./update_po
