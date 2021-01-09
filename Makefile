PREFIX = /usr/bin
PROG = isfree

install:
	@mkdir -p "${PREFIX}"
	@install -Dm755 "${PROG}" "${PREFIX}"/
	@printf "Successfully installed ${PROG}\n"

uninstall:
	@rm "${PREFIX}/${PROG}" \
	printf "Successfully uninstalled ${PROG}\n"
