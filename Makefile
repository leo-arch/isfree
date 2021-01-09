PREFIX = /usr/bin
PROG = isfree

install:
	@mkdir -p ${PREFIX} 2>/dev/null
	@if [ -f ${PREFIX}/${PROG} ]; then \
		printf "'${PREFIX}/${PROG}': File already exists\n"; \
		exit 1; \
	fi
	@install -Dm755 "${PROG}" "${PREFIX}"/ \
	&& printf "Successfully installed ${PROG}\n" \
	|| printf "Could not install ${PROG}"

uninstall:
	@if ! [ -f ${PREFIX}/${PROG} ]; then \
		printf "'${PREFIX}/${PROG}': No such file or directory\n"; \
		exit 1; \
	fi
	@rm "${PREFIX}/${PROG}" \
	&& printf "Successfully uninstalled ${PROG}\n" \
	|| printf "Could not uninstall ${PROG}"
