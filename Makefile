# $FreeBSD: $

PORTNAME=	lwjgl
DISTVERSION=	3.2.0
CATEGORIES=	games java

MAINTAINER=	mmokhi@FreeBSD.org
COMMENT=	Lightweight Java Game Library

LICENSE=	BSD3CLAUSE

BUILD_DEPENDS=	${JAVALIBDIR}/jutils/jutils.jar:games/jutils \
		${JAVALIBDIR}/jinput/jinput.jar:games/jinput
LIB_DEPENDS=	libicuuc.so:devel/icu
RUN_DEPENDS:=	${BUILD_DEPENDS}

ONLY_FOR_ARCHS=	i386 amd64

USE_JAVA=	yes
USE_LDCONFIG=	yes

USE_GITHUB=	yes
GH_ACCOUNT=	LWJGL
GH_PROJECT=	lwjgl3
GH_TAGNAME=	b60d7f9

JAVA_VERSION=	1.7+
JAVA_OS=	native
JAVA_VENDOR=	openjdk
USE_ANT=	yes
USE_GCC=	yes
USE_XORG=	xcursor xrandr xxf86vm
USES=		pkgconfig
USE_GNOME=	glib20 gtk30
MAKE_ENV+=	CLASSPATH=${JAVALIBDIR}/jutils/jutils.jar:${JAVALIBDIR}/jinput/jinput.jar:${WRKSRC}/${DISTNAME}/jar/
ALL_TARGET=	jars compile_native

PLIST_FILES=	%%JAVAJARDIR%%/${PORTNAME}/${PORTNAME}.jar \
		%%JAVAJARDIR%%/${PORTNAME}/${PORTNAME}_test.jar \
		%%JAVAJARDIR%%/${PORTNAME}/${PORTNAME}_util.jar \
		%%JAVAJARDIR%%/${PORTNAME}/${PORTNAME}_util_applet.jar
PLIST_DIRS=	%%JAVAJARDIR%%/${PORTNAME} \
		lib/${PORTNAME}${PORTVERSION}

.include <bsd.port.pre.mk>

.if ${ARCH} == i386
PLIST_FILES+=	lib/${PORTNAME}${PORTVERSION}/lib${PORTNAME}.so
LWJGL_BUILD_ARCH=x86
.endif

.if ${ARCH} == amd64
PLIST_FILES+=	lib/${PORTNAME}${PORTVERSION}/lib${PORTNAME}64.so
LWJGL_BUILD_ARCH=x64
.endif

MAKE_ENV+=	LWJGL_BUILD_ARCH=${LWJGL_BUILD_ARCH} LWJGL_BUILD_OFFLINE=yes
#Getting: https://github.com/JetBrains/kotlin/releases/download/v1.2.71/kotlin-compiler-1.2.71.zip
#  [kotlinc] To: /wrkdirs/usr/ports/games/lwjgl3/work/lwjgl3-b60d7f9/bin/libs/kotlin-compiler-1.2.71.zip
#

post-patch:
	@${REINPLACE_CMD} -e 's|%GCCVER%|${_USE_GCC}|g' \
		${WRKSRC}/config/freebsd/build.xml

do-install:
	@${MKDIR} ${STAGEDIR}${JAVAJARDIR}/${PORTNAME}
.for _jar in ${PLIST_FILES:M*.jar}
	${INSTALL_DATA} ${WRKSRC}/libs/${_jar:T} \
		${STAGEDIR}${JAVAJARDIR}/${PORTNAME}
.endfor
	@${MKDIR} ${STAGEDIR}${PREFIX}/lib/${PORTNAME}${PORTVERSION}
.if ${ARCH} == i386
	${INSTALL_DATA} ${WRKSRC}/libs/freebsd/lib${PORTNAME}.so \
		${STAGEDIR}${PREFIX}/lib/${PORTNAME}${PORTVERSION}
.endif
.if ${ARCH} == amd64
	${INSTALL_DATA} ${WRKSRC}/libs/freebsd/lib${PORTNAME}64.so \
		${STAGEDIR}${PREFIX}/lib/${PORTNAME}${PORTVERSION}
.endif

.include <bsd.port.post.mk>
