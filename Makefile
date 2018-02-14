INSTALL_ARGS := $(if $(PREFIX),--prefix $(PREFIX),)

# Default rule
default:
	jbuilder build evaluate.exe

clean:
	rm -rf _build

.PHONY: default clean
