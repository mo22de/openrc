# rules to build a library
# based on FreeBSD's bsd.lib.mk

# Copyright 2008 Roy Marples

SHLIB_NAME=		lib${LIB}.so.${SHLIB_MAJOR}
SHLIB_LINK=		lib${LIB}.so
SONAME?=		${SHLIB_NAME}

OBJS+=			${SRCS:.c=.o}
SOBJS+=			${OBJS:.o=.So}
_LIBS=			lib${LIB}.a ${SHLIB_NAME}

.SUFFIXES:		.So

.c.So:
	${CC} ${PICFLAG} -DPIC ${CFLAGS} -c $< -o $@

all: depend ${_LIBS}

lib${LIB}.a:	${OBJS} ${STATICOBJS}
	@${ECHO} building static library $@
	${AR} rc $@ $^
	${RANLIB} $@

${SHLIB_NAME}: ${VERSION_MAP}
LDFLAGS+=	-Wl,--version-script=${VERSION_MAP}
# We need to ensure we use libraries in /lib
LDFLAGS+=	-L/${LIBNAME} -Wl,-rpath=/${LIBNAME}

${SHLIB_NAME}:	${SOBJS}
	@${ECHO} building shared library $@
	@rm -f $@ ${SHLIB_LINK}
	@ln -fs $@ ${SHLIB_LINK}
	${CC} ${LDFLAGS} -shared -Wl,-x \
	-o $@ -Wl,-soname,${SONAME} \
	${SOBJS} ${LDADD}

install: all
	${INSTALL} -d ${DESTDIR}${LIBDIR}
	${INSTALL} -m ${LIBMODE} lib${LIB}.a ${DESTDIR}${LIBDIR}
	${INSTALL} -d ${DESTDIR}${SHLIBDIR}
	${INSTALL} -m ${LIBMODE} ${SHLIB_NAME} ${DESTDIR}${SHLIBDIR}
	ln -fs ${SHLIB_NAME} ${DESTDIR}${SHLIBDIR}/${SHLIB_LINK}
	${INSTALL} -d ${DESTDIR}${INCDIR}
	for x in ${INCS}; do ${INSTALL} -m ${INCMODE} $$x ${DESTDIR}${INCDIR}; done

clean:
	rm -f ${OBJS} ${SOBJS} ${_LIBS} ${SHLIB_LINK} ${CLEANFILES}

include ${MK}/sys.mk
include ${MK}/depend.mk